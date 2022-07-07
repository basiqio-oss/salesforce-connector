public with sharing class BasiqConnectorWidgetController {
	private final static Set<String> supportedObjects = new Set<String>{ 'Contact', 'Lead' };

	public static IBasiqAPI basiqApi {
		get {
			if (basiqApi == null) {
				basiqApi = new BasiqConnectAPI();
				return basiqApi;
			}
			return basiqApi;
		}
		set {
			if (value == null) {
				return;
			}
			basiqApi = value;
		}
	}

	public static BasiqConnectorSettings__c cSettings {
		get {
			if (cSettings == null) {
				cSettings = BasiqConnectorSettings__c.getOrgDefaults();
			}
			return cSettings;
		}
		set {
			if (value == null) {
				return;
			}
			cSettings = value;
		}
	}

	public static IBigData bigData {
		get {
			if (bigData == null) {
				bigData = new BigData();
				return bigData;
			}
			return bigData;
		}
		set {
			if (value == null) {
				return;
			}
			bigData = value;
		}
	}

	static final Map<String, Map<String, String>> statusesMappings = new Map<String, Map<String, String>>{
		'verify-credentials' => new Map<String, String>{ 'pending' => 'Verifying…', 'in-progress' => 'Verifying…', 'success' => 'User verified' },
		'retrieve-accounts' => new Map<String, String>{ 'pending' => 'Connecting…', 'in-progress' => 'Fetching accounts…', 'success' => 'Accounts fetched' },
		'retrieve-transactions' => new Map<String, String>{ 'pending' => 'Retrieving transactions…', 'in-progress' => 'Retrieving transactions…', 'success' => 'Active' }
	};

	@AuraEnabled
	public static String getBasiqConnectLinkFromObject(String recordId, String objectName) {
		String link;
		switch on objectName {
			when 'Contact' {
				Contact contact = [SELECT Id, BasiqConnectURL__c FROM Contact WHERE Id = :recordId LIMIT 1];
				link = contact.BasiqConnectURL__c;
			}
			when 'Lead' {
				Lead lead = [SELECT Id, BasiqConnectURL__c FROM Lead WHERE Id = :recordId LIMIT 1];
				link = lead.BasiqConnectURL__c;
			}
		}
		return link;
	}

	@AuraEnabled
	public static String getBasiqLink(String recordId, String objectName) {
		validateApiKeySettings();
		validateFieldsSettings();
		validateObjectType(objectName);

		sObject targetObject = getTargetObject(recordId, objectName, cSettings);
		Map<String, String> tragetObjectData = getTargetObjectData(targetObject, objectName, cSettings);
		String basiqUserId = tragetObjectData.get('basiqUserId');
		String email = tragetObjectData.get('email');
		String mobile = tragetObjectData.get('mobile');

		if (String.isBlank(mobile)) {
			throw new AuraHandledException(new ControllerErrorMessage('Missing mobile number', 'Mobile number must be provided', 'Error').GetJson());
		}

		if (!validateEmail(email)) {
			throw new AuraHandledException(new ControllerErrorMessage('Wrong email format', 'Check the email address and try again', 'Email format not valid').GetJson());
		}

		if (!validateMobileNumber(mobile)) {
			throw new AuraHandledException(new ControllerErrorMessage('Wrong mobile phone format', 'Incorrect mobile phone number format (should start with \'+\')', 'Mobile phone format not valid').GetJson());
		}

		String accessToken = getAccessToken();
		HttpResponse response;
		if (String.isEmpty(basiqUserId)) {
			response = basiqApi.CreateUser(accessToken, email, mobile);
			validateResponse(response, 201, 'Failed to create Basiq user');

			Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
			basiqUserId = (string) results.get('id');
			targetObject.put('BasiqUserId__c', basiqUserId);
		}

		response = basiqApi.CreateAuthLink(accessToken, basiqUserId, mobile);
		validateResponse(response, 201, 'Failed to create Basiq connection link');

		response = basiqApi.GetAuthLink(accessToken, basiqUserId);
		validateResponse(response, 200, 'Failed to get Basiq connection link');
		
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		Map<String, Object> links = (Map<String, Object>) results.get('links');
		String basiqLink = (String) links.get('public');
		targetObject.put('BasiqConnectURL__c', basiqLink);
		update targetObject;

		return basiqLink;
	}

	@AuraEnabled
	public static void deleteBasiqLink(String recordId, String objectName) {
		validateApiKeySettings();
		validateObjectType(objectName);

		String basiqUserId = getBasiqUserId(recordId, objectName);
		String accessToken = getAccessToken();

		HttpResponse response = basiqApi.DeleteAuthLink(accessToken, basiqUserId);
		validateResponse(response, 204, 'Failed to delete Basiq connection link');

		sObject targetObject = getTargetObject(recordId, objectName, cSettings);
		targetObject.put('BasiqConnectURL__c', '');

		update targetObject;
	}

	@AuraEnabled
	public static String fetchExistingConnectionObjects(String recordId, String objectName) {
		validateObjectType(objectName);

		String basiqUserId = getBasiqUserId(recordId, objectName);

		List<Map<String, String>> resultData = new List<Map<String, String>>();

		List<BasiqEntityConnection_v2__c> connections = [SELECT Id, BasiqConnectionId__c, Status__c, InstitutionName__c, Logo__c, LastUsed__c FROM BasiqEntityConnection_v2__c WHERE BasiqUserId__c = :basiqUserId];
		for (BasiqEntityConnection_v2__c connection : connections) {
			Map<String, String> resultDataMap = new Map<String, String>();
			resultDataMap.put('id', connection.BasiqConnectionId__c);
			resultDataMap.put('institution', connection.InstitutionName__c);
			resultDataMap.put('status', connection.Status__c.capitalize());
			resultDataMap.put('logo', connection.Logo__c);
			resultDataMap.put('lastUsed', convertToString(connection.LastUsed__c));
			resultData.add(resultDataMap);
		}

		return JSON.serialize(resultData);
	}
	
	@AuraEnabled
	public static String revokeConnection(String recordId, String objectName, String connectionId) {
		validateObjectType(objectName);
		
		String basiqUserId = getBasiqUserId(recordId, objectName);

		List<BasiqEntityConnection_v2__c> connections = [SELECT Id, BasiqUserId__c, BasiqConnectionId__c FROM BasiqEntityConnection_v2__c WHERE BasiqUserId__c = :basiqUserId AND BasiqConnectionId__c = :connectionId];
		if (connections.isEmpty()) {
			return null;
		}
		validateIsDeletable(connections);
		
		BasiqEntityConnection_v2__c connection = connections[0];
		
		String accessToken = getAccessToken();

		HttpResponse response = basiqApi.DeleteConnection(accessToken, basiqUserId, connection.BasiqConnectionId__c);
		validateResponse(response, 204, 'Failed to delete Basiq connection ' + connection.BasiqConnectionId__c);
	
		delete connection;

		return connectionId;
	}

	@AuraEnabled
	public static String retriveConnections(String recordId, String objectName) {
		validateObjectType(objectName);

		String basiqUserId = getBasiqUserId(recordId, objectName);
		if (String.isEmpty(basiqUserId)) {
			return null;
		}

		List<BasiqEntityConnection_v2__c> oldConnections = [SELECT Id, BasiqUserId__c, BasiqConnectionId__c FROM BasiqEntityConnection_v2__c WHERE BasiqUserId__c = :basiqUserId];
		validateIsDeletable(oldConnections);

		String accessToken = getAccessToken();

		HttpResponse response = basiqApi.GetConnectionList(accessToken, basiqUserId);
		validateResponse(response, 200, 'Failed to retrive Basiq connection data');

		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		List<Object> connectionResponseData = (List<Object>) results.get('data');

		List<Map<String, String>> resultData = new List<Map<String, String>>();
		List<BasiqEntityConnection_v2__c> connections = new List<BasiqEntityConnection_v2__c>();
		for (Object connectionResponseDatum : connectionResponseData) {
			Map<String, Object> connectionDatum = (Map<String, Object>) connectionResponseDatum;
			Map<String, Object> connectionDatumInstitution = (Map<String, Object>) connectionDatum.get('institution');

			response = basiqApi.GetInstitution(accessToken, (String) connectionDatumInstitution.get('id'));
			validateResponse(response, 200, 'Failed to get Basiq Institution for Basiq Connection ' + (String) connectionDatum.get('id'));
			
			Map<String, Object> institutionResponseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
			Map<String, Object> logoReponseData = (Map<String, Object>) institutionResponseData.get('logo');
			Map<String, Object> logoLinksReponseData = (Map<String, Object>) logoReponseData.get('links');

			BasiqEntityConnection_v2__c connection = new BasiqEntityConnection_v2__c();
			assignLookup(connection, objectName, recordId);
			connection.BasiqConnectionId__c = (String) connectionDatum.get('id');
			connection.BasiqUserId__c = basiqUserId;
			connection.Status__c = (String) connectionDatum.get('status');
			connection.LastUsed__c = convertToDateTime((String) connectionDatum.get('lastUsed'));
			connection.BasiqInstitutionId__c = (String) institutionResponseData.get('id');
			connection.InstitutionName__c = (String) institutionResponseData.get('name');
			connection.Country__c = (String) institutionResponseData.get('country');
			connection.Logo__c = (String) logoLinksReponseData.get('square');
			connections.add(connection);

			Map<String, String> resultDataMap = new Map<String, String>();
			resultDataMap.put('id', connection.BasiqConnectionId__c);
			resultDataMap.put('institution', connection.InstitutionName__c);
			resultDataMap.put('status', connection.Status__c.capitalize());
			resultDataMap.put('logo', connection.Logo__c);
			resultDataMap.put('lastUsed', convertToString(connection.LastUsed__c));
			resultData.add(resultDataMap);
		}

		delete oldConnections;

		validateIsCreatable(connections);
		insert connections;
		
		return JSON.serialize(resultData);
	}

	@AuraEnabled
	public static String refreshConnections(String recordId, String objectName, String connectionIdListData) {
		validateObjectType(objectName);

		String basiqUserId = getBasiqUserId(recordId, objectName);
		String accessToken = getAccessToken();

		List<String> connectionIdList = (List<String>) JSON.deserialize(connectionIdListData, Type.forName('List<String>'));
		List<BasiqEntityConnectionRefreshJob_v2__c> jobsToDelete = new List<BasiqEntityConnectionRefreshJob_v2__c>();
		List<BasiqEntityConnectionRefreshJob_v2__c> connectionRefreshJobs = new List<BasiqEntityConnectionRefreshJob_v2__c>();
		List<Map<String, String>> resultData = new List<Map<String, String>>();

		for (String connectionId : connectionIdList) {
			Map<String, String> refreshResult = new Map<String, String>();
			refreshResult.put('id', connectionId);
			List<BasiqEntityConnectionRefreshJob_v2__c> oldConnectionRefreshJobs = [SELECT Id, BasiqJobId__c FROM BasiqEntityConnectionRefreshJob_v2__c WHERE BasiqConnectionId__c = :connectionId];
			for (BasiqEntityConnectionRefreshJob_v2__c job : oldConnectionRefreshJobs) {
				jobsToDelete.add(job);
			}

			try {
				connectionRefreshJobs.add(refreshConnection(accessToken, basiqUserId, connectionId));
			} catch (AuraHandledException aex) {
				refreshResult.put('error', aex.getMessage());
			}
			resultData.add(refreshResult);
		}

		validateIsDeletable(jobsToDelete);
		delete jobsToDelete;

		validateIsCreatable(connectionRefreshJobs);
		insert connectionRefreshJobs;
		
		return JSON.serialize(resultData);
	}

	@AuraEnabled
	public static String checkRefreshJobStatuses(String recordId, String objectName, String connectionIdListData) {
		validateObjectType(objectName);

		String basiqUserId = getBasiqUserId(recordId, objectName);
		String accessToken = getAccessToken();

		List<String> connectionIdList = (List<String>) JSON.deserialize(connectionIdListData, Type.forName('List<String>'));
		List<BasiqEntityConnectionRefreshJob_v2__c> jobsToDelete = new List<BasiqEntityConnectionRefreshJob_v2__c>();
		List<BasiqEntityConnection_v2__c> connectionsToUpdate = new List<BasiqEntityConnection_v2__c>();
		List<Map<String, Object>> resultData = new List<Map<String, Object>>();

		for (String connectionId : connectionIdList) {
			Map<String, Object> refreshResult = new Map<String, Object>();
			refreshResult.put('id', connectionId);
			try {
				Map<String, String> result = checkRefreshJobStatus(accessToken, basiqUserId, recordId, objectName, connectionId, jobsToDelete, connectionsToUpdate);
				if (result != null) {
					refreshResult.put('data', result);
				}
			} catch (AuraHandledException aex) {
				refreshResult.put('error', aex.getMessage());
			}
			resultData.add(refreshResult);
		}

		if (!connectionsToUpdate.isEmpty()) {
			validateIsCreatable(connectionsToUpdate);
			update connectionsToUpdate;
		}

		if (!jobsToDelete.isEmpty()) {
			validateIsDeletable(jobsToDelete);
			delete jobsToDelete;
		}

		return JSON.serialize(resultData);
	}

	@AuraEnabled
	public static void storeConnectionFinancialData(String recordId, String objectName, String connectionId) {
		validateObjectType(objectName);

		String basiqUserId = getBasiqUserId(recordId, objectName);
		
		List<BasiqEntityConnection_v2__c> connections = [SELECT Id, BasiqUserId__c, BasiqConnectionId__c FROM BasiqEntityConnection_v2__c WHERE BasiqUserId__c = :basiqUserId AND BasiqConnectionId__c = :connectionId LIMIT 1];
		if (connections.isEmpty()) {
			return;
		}

		String accessToken = getAccessToken();

		HttpResponse response = basiqApi.GetConnection(accessToken, basiqUserId, connectionId);
		validateResponse(response, 200, 'Failed to get Basiq Connection data');

		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		Map<String, Object> connectionResponseLinkData = (Map<String, Object>) results.get('links');
		List<String> connectionLinkData = new List<String>();
		String accountsLink = (String) connectionResponseLinkData.get('accounts');

		response = basiqApi.GetRequest(accessToken, accountsLink);
		validateResponse(response, 200, 'Failed to get Basiq Accounts data');
		
		results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		List<Object> accountReponseData = (List<Object>) results.get('data');

		List<BasiqEntityAccount_v2__c> oldAccounts = [SELECT Id, BasiqConnectionId__c, BasiqAccountId__c FROM BasiqEntityAccount_v2__c WHERE BasiqConnectionId__c = :connectionId];
		List<BasiqEntityAccount_v2__c> accounts = new List<BasiqEntityAccount_v2__c>();
		
		for (Object accountReponseDatum : accountReponseData) {
			Map<String, Object> accountDatum = (Map<String, Object>) accountReponseDatum;

			BasiqEntityAccount_v2__c account = new BasiqEntityAccount_v2__c();
			assignLookup(account, objectName, recordId);
			account.BasiqEntityConnection__c = connections[0].Id;
			account.BasiqConnectionId__c = connections[0].BasiqConnectionId__c;
			account.BasiqAccountId__c = (String) accountDatum.get('id');
			if (validateKey(accountDatum, 'accountNo')) {
				account.AccountNumber__c = (String) accountDatum.get('accountNo');
			}
			if (validateKey(accountDatum, 'currency')) {
				account.Currency__c = (String) accountDatum.get('currency');
			}
			if (validateKey(accountDatum, 'balance')) {
				account.Balance__c = decimal.valueOf((String) accountDatum.get('balance'));
			}
			if (validateKey(accountDatum, 'availableFunds')) {
				account.AvailableFunds__c = decimal.valueOf((String) accountDatum.get('availableFunds'));
			}
			if (validateKey(accountDatum, 'status')) {
				account.Status__c = (String) accountDatum.get('status');
			}
			if (validateKey(accountDatum, 'accountHolder')) {
				account.AccountHolder__c = (String) accountDatum.get('accountHolder');
			}

			accounts.add(account);
		}

		String transactionsLink = (String) connectionResponseLinkData.get('transactions');
		response = basiqApi.GetRequest(accessToken, transactionsLink + ',transaction.status.eq(\'posted\')');
		validateResponse(response, 200, 'Failed to get Basiq Transactions data');

		results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		List<Object> transactionsResponseData = (List<Object>) results.get('data');
		Map<String, Object> linksResponseData = (Map<String, Object>) results.get('links');
		String nextTransactions = (String) linksResponseData.get('next');
		List<BasiqEntityTransaction_v2__c> transactions = new List<BasiqEntityTransaction_v2__c>();

		parseTransactionDataResult(transactions, transactionsResponseData, objectName, recordId);

		while (nextTransactions != null) {
			response = basiqApi.GetRequest(accessToken, nextTransactions);
			validateResponse(response, 200, 'Failed to get Basiq Transactions data');

			results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
			transactionsResponseData = (List<Object>) results.get('data');
			linksResponseData = (Map<String, Object>) results.get('links');
			nextTransactions = (String) linksResponseData.get('next');
			parseTransactionDataResult(transactions, transactionsResponseData, objectName, recordId);
		}

		if (!oldAccounts.isEmpty()) {
			validateIsDeletable(oldAccounts);
			delete oldAccounts;
		}

		if (!accounts.isEmpty()) {
			validateIsCreatable(accounts);
			insert accounts;
		}

		
		if (!transactions.isEmpty()) {
			validateIsCreatable(transactions);
			Map<String,String> accountIds = new Map<String,String>();
			for (BasiqEntityAccount_v2__c account : accounts) {
				accountIds.put(account.BasiqAccountId__c, account.Id);
			}
			for (BasiqEntityTransaction_v2__c trans : transactions) {
				trans.BasiqEntityAccount__c = accountIds.get(trans.BasiqAccountId__c);
			}
			insert transactions;
		}
	}

	@AuraEnabled
	public static String postAffordabilityReport(String recordId, String objectName) {
		validateObjectType(objectName);

		String basiqUserId = getBasiqUserId(recordId, objectName);
		String accessToken = getAccessToken();

		HttpResponse response = basiqApi.PostAffordability(accessToken, basiqUserId, '', 'application/json');
		validateResponse(response, 200, 'Failed to generate Addordability report');

		Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		Map<String, Object> summary = (Map<String, Object>) body.get('summary');
		Map<String, Object> regularIncome = (Map<String, Object>) summary.get('regularIncome');
		Map<String, Object> previous3Months = (Map<String, Object>) regularIncome.get('previous3Months');

		BasiqEntityAffordability_v2__c affordability = new BasiqEntityAffordability_v2__c();
		assignLookup(affordability, objectName, recordId);
		if (validateKey(summary, 'assets')) {
			affordability.Assets__c = decimal.valueOf((String) summary.get('assets'));
		}
		if (validateKey(previous3Months, 'avgMonthly')) {
			affordability.AvgRegularIncome3Months__c = decimal.valueOf((String) previous3Months.get('avgMonthly'));
		}
		if (validateKey(body, 'id')) {
			affordability.BasiqAffordabilityId__c = (String) body.get('id');
		}
		affordability.BasiqUserId__c = basiqUserId;
		if (validateKey(body, 'coverageDays')) {
			affordability.CoverageDays__c = (Integer) body.get('coverageDays');
		}
		if (validateKey(summary, 'creditLimit')) {
			affordability.CreditLimit__c = decimal.valueOf((String) summary.get('creditLimit'));
		}
		if (validateKey(summary, 'expenses')) {
			affordability.Expenses__c = decimal.valueOf((String) summary.get('expenses'));
		}
		if (validateKey(body, 'fromMonth')) {
			affordability.FromMonth__c = (String) body.get('fromMonth');
		}
		if (validateKey(body, 'generatedDate')) {
			affordability.GeneratedDate__c = convertToDateTime((String) body.get('generatedDate'));
		}
		if (validateKey(summary, 'liabilities')) {
			affordability.Liabilities__c = decimal.valueOf((String) summary.get('liabilities'));
		}
		if (validateKey(summary, 'netPosition')) {
			affordability.NetPosition__c = decimal.valueOf((String) summary.get('netPosition'));
		}
		if (validateKey(summary, 'savings')) {
			affordability.Savings__c = decimal.valueOf((String) summary.get('savings'));
		}
		if (validateKey(body, 'toMonth')) {
			affordability.ToMonth__c = (String) body.get('toMonth');
		}

		BasiqEntityIncome_v2__c income = fetchIncomeData(accessToken, body, objectName, recordId);
		
		validateIsCreatable(affordability);
		insert affordability;
		
		if (income != null) {
			validateIsCreatable(income);
			income.BasiqEntityAffordability__c = affordability.Id;
			insert income;
		}
		
		return affordability.BasiqAffordabilityId__c;
	}

	@AuraEnabled
	public static Void postPDFAffordabilityReport(String recordId, String objectName) {
		validateObjectType(objectName);

		String basiqUserId = getBasiqUserId(recordId, objectName);
		String accessToken = getAccessToken();

		HttpResponse response = basiqApi.PostAffordability(accessToken, basiqUserId, '', 'application/pdf');
		validateResponse(response, 201, 'Failed to generate PDF Addordability report');

		blob bloby = response.getBodyAsBlob();
		Attachment attach = new Attachment();
		attach.contentType = 'application/octet-stream';
		attach.name = getRecordFullName(recordId, objectName) + ' - Affordability Report - ' + getCurrentDateTime() + '.pdf';
		attach.parentId = recordId;
		attach.body = bloby;
		insert attach;
	}

	private static BasiqEntityIncome_v2__c fetchIncomeData(String accessToken, Map<String, Object> affordabilityBody, String objectName, String recordId) {
		if (!validateKey(affordabilityBody, 'links')) {
			return null;
		}
		Map<String, Object> affordabilityLinkData = (Map<String, Object>) affordabilityBody.get('links');
		if (!validateKey(affordabilityLinkData, 'income')) {
			return null;
		}
		String incomeLink = (String) affordabilityLinkData.get('income');
		if (String.isBlank(incomeLink)) {
			return null;
		}
		
		BasiqEntityIncome_v2__c income = new BasiqEntityIncome_v2__c();
		assignLookup(income, objectName, recordId);

		HttpResponse response = basiqApi.GetRequest(accessToken, incomeLink);
		validateResponse(response, 200, 'Failed to get Basiq Income data');
		
		Map<String, Object> incomeBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		income.BasiqAffordabilityId__c = (String) affordabilityBody.get('id');
		income.BasiqIncomeId__c = (String) incomeBody.get('id');
		if (validateKey(incomeBody, 'coverageDays')) {
			income.CoverageDays__c = (Integer) incomeBody.get('coverageDays');
		}
		if (validateKey(incomeBody, 'fromMonth')) {
			income.FromMonth__c = (String) incomeBody.get('fromMonth');
		}
		if (validateKey(incomeBody, 'toMonth')) {
			income.ToMonth__c = (String) incomeBody.get('toMonth');
		}
		
		Map<String, Object> summary = (Map<String, Object>) incomeBody.get('summary');
		if (validateKey(summary, 'irregularIncomeAvg')) {
			income.IrregularIncomeAverage__c = decimal.valueOf((String) summary.get('irregularIncomeAvg'));
		}
		if (validateKey(summary, 'regularIncomeAvg')) {
			income.RegularIncomeAverage__c = decimal.valueOf((String) summary.get('regularIncomeAvg'));
		}
		if (validateKey(summary, 'regularIncomeYear')) {
			income.RegularIncomeYear__c = decimal.valueOf((String) summary.get('regularIncomeYear'));
		}
		if (validateKey(summary, 'regularIncomeYTD')) {
			income.RegularIncomeYTD__c = decimal.valueOf((String) summary.get('regularIncomeYTD'));
		}

		return income;
	}

	@TestVisible
	private static void parseTransactionDataResult(List<BasiqEntityTransaction_v2__c> transactions, List<Object> transactionResponseData, String objectName, String recordId) {
		for (Object transactionResponseDatum : transactionResponseData) {
			Map<String, Object> transactionDatum = (Map<String, Object>) transactionResponseDatum;

			BasiqEntityTransaction_v2__c basiqTransaction = new BasiqEntityTransaction_v2__c();
			assignLookup(basiqTransaction, objectName, recordId);
			basiqTransaction.BasiqTransactionId__c = (String) transactionDatum.get('id');
			if (validateKey(transactionDatum, 'account')) {
				basiqTransaction.BasiqAccountId__c = (String) transactionDatum.get('account');
			}
			if (validateKey(transactionDatum, 'amount')) {
				basiqTransaction.Amount__c = decimal.valueOf((String) transactionDatum.get('amount'));
			}
			if (validateKey(transactionDatum, 'balance')) {
				basiqTransaction.Balance__c = decimal.valueOf((String) transactionDatum.get('balance'));
			}
			if (validateKey(transactionDatum, 'status')) {
				basiqTransaction.Status__c = (String) transactionDatum.get('status');
			}
			if (validateKey(transactionDatum, 'description')) {
				basiqTransaction.Description__c = (String) transactionDatum.get('description');
			}
			if (validateKey(transactionDatum, 'transactionDate')) {
				basiqTransaction.TransactionDate__c = convertToDateTime((String) transactionDatum.get('transactionDate'));
			}
			if (validateKey(transactionDatum, 'postDate')) {
				basiqTransaction.PostDate__c = convertToDateTime((String) transactionDatum.get('postDate'));
			}
			if (validateKey(transactionDatum, 'direction')) {
				basiqTransaction.Direction__c = (String) transactionDatum.get('direction');
			}
			if (validateKey(transactionDatum, 'class')) {
				basiqTransaction.Class__c = (String) transactionDatum.get('class');
			}
			Map<String, Object> subClassData = (Map<String, Object>) transactionDatum.get('subClass');
			if (subClassData != null) {
				basiqTransaction.SubClass__c = (String) subClassData.get('code') + ':' + (String) subClassData.get('title');
			}

			transactions.add(basiqTransaction);
		}
	}

	private static Map<String, String> checkRefreshJobStatus(String accessToken, String basiqUserId, String recordId, String objectName, String connectionId, List<BasiqEntityConnectionRefreshJob_v2__c> jobsToDelete, List<BasiqEntityConnection_v2__c> connectionsToUpdate) {
		List<BasiqEntityConnectionRefreshJob_v2__c> connectionRefreshJob = [SELECT Id, BasiqJobId__c FROM BasiqEntityConnectionRefreshJob_v2__c WHERE BasiqConnectionId__c = :connectionId LIMIT 1];
		if (connectionRefreshJob.size() == 0) {
			return null;
		}

		HttpResponse response = basiqApi.GetJob(accessToken, connectionRefreshJob[0].BasiqJobId__c);
		validateResponse(response, 200, 'Failed to get Basiq Job data');

		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		List<Object> steps = (List<Object>) results.get('steps');
		Integer finishedSteps = 0;

		Map<String, String> resultData = new Map<String, String>();
		String statusResponse, titleResponse;
		Map<String, Object> result;
		for (Object step : steps) {
			Map<String, Object> stepData = (Map<String, Object>) step;
			statusResponse = (String) stepData.get('status');
			titleResponse = (String) stepData.get('title');
			result = (Map<String, Object>) stepData.get('result');
			if (statusResponse != 'success') {
				break;
			}
		}

		resultData.put('id', connectionRefreshJob[0].BasiqJobId__c);

		Map<String, String> statusMapping = statusesMappings.get(titleResponse);
		if (statusMapping != null) {
			String status = statusMapping.get(statusResponse);
			if (status != null) {
				resultData.put('message', status);
			} else {
				resultData.put('message', titleResponse + ':' + statusResponse);
			}
		} else {
			if (statusResponse == 'failed') {
				String errMsg = (String) result.get('detail');
				resultData.put('message', errMsg);
				jobsToDelete.add(connectionRefreshJob[0]);
				BasiqEntityConnection_v2__c connectionToUpdate = updateConnectionStatus(accessToken, basiqUserId, connectionId, errMsg);
				if (connectionToUpdate != null) {
					connectionsToUpdate.add(connectionToUpdate);
				}
			} else {
				resultData.put('message', titleResponse + ':' + statusResponse);
			}
		}

		resultData.put('title', titleResponse);
		resultData.put('status', statusResponse);

		if (titleResponse == 'retrieve-transactions' && statusResponse == 'success') {
			BasiqEntityConnection_v2__c connectionToUpdate = updateConnectionStatus(accessToken, basiqUserId, connectionId, resultData.get('message'));
			if (connectionToUpdate != null) {
				resultData.put('lastUsed', convertToString(connectionToUpdate.LastUsed__c));
				connectionsToUpdate.add(connectionToUpdate);
			}
			jobsToDelete.add(connectionRefreshJob[0]);
		}

		return resultData;
	}

	private static BasiqEntityConnectionRefreshJob_v2__c refreshConnection(String accessToken, String basiqUserId, String connectionId) {
		HttpResponse response = basiqApi.RefreshConnection(accessToken, basiqUserId, connectionId);
		validateResponse(response, 202, 'Failed to refresh connection with ID: ' + connectionId);

		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		String connectionRefreshJobId = (String) results.get('id');

		BasiqEntityConnectionRefreshJob_v2__c connectionRefreshJob = new BasiqEntityConnectionRefreshJob_v2__c();
		connectionRefreshJob.BasiqJobId__c = connectionRefreshJobId;
		connectionRefreshJob.BasiqUserId__c = basiqUserId;
		connectionRefreshJob.BasiqConnectionId__c = connectionId;

		return connectionRefreshJob;
	}

	private static BasiqEntityConnection_v2__c updateConnectionStatus(String accessToken, String basiqUserId, String connectionId, String status) {
		List<BasiqEntityConnection_v2__c> connections = [SELECT Id, BasiqUserId__c, BasiqConnectionId__c, BasiqInstitutionId__c, Country__c, InstitutionName__c, LastUsed__c, Logo__c, Status__c FROM BasiqEntityConnection_v2__c WHERE BasiqUserId__c = :basiqUserId AND BasiqConnectionId__c = :connectionId];
		if (connections.isEmpty()) {
			return null;
		}
		BasiqEntityConnection_v2__c connection = connections[0];

		if (status == 'Active') {
			HttpResponse response = basiqApi.GetConnection(accessToken, basiqUserId, connectionId);
			validateResponse(response, 200, 'Failed to retrive Basiq Connection data');

			Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

			connection.Status__c = status;
			connection.LastUsed__c = convertToDateTime((String) results.get('lastUsed'));
		}

		return connection;
	}
	
	private static Datetime convertToDateTime(String value) {
		return (Datetime) JSON.deserialize('"' + value + '"', Datetime.class);
	}

	private static String convertToString(Datetime value) {
		return value.formatGmt('yyyy-MM-dd\'T\'HH:mm:ssXXX');
	}

	private static String getBasiqUserId(String recordId, String objectName) {
		sObject targetObject = getTargetObject(recordId, objectName, cSettings);
		Map<String, String> tragetObjectData = getTargetObjectData(targetObject, objectName, cSettings);
		return tragetObjectData.get('basiqUserId');
	}

	private static String getAccessToken() {
		HttpResponse response = basiqApi.GetToken(cSettings.Basiq_Api_Key__c);
		validateResponse(response, 200, 'Failed to get Basiq access token');

		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		return (string) results.get('access_token');
	}

	private static String getCurrentDateTime() {
		return Datetime.now().format('yyyy-MM-dd-HH-mm-ss-z');
	}

	private static Map<String, String> getTargetObjectData(sObject targetObject, String objectName, BasiqConnectorSettings__c cSettings) {
		Map<String, String> targetObjectData = new Map<String, String>();
		String basiqUserId, mobile, email;

		switch on objectName {
			when 'Contact' {
				email = (String) targetObject.get(cSettings.ContactEmailMapping__c);
				mobile = (String) targetObject.get(cSettings.ContactMobileMapping__c);
			}
			when 'Lead' {
				email = (String) targetObject.get(cSettings.LeadEmailMapping__c);
				mobile = (String) targetObject.get(cSettings.LeadMobileMapping__c);
			}
		}
		basiqUserId = (String) targetObject.get('BasiqUserId__c');

		targetObjectData.put('basiqUserId', basiqUserId);
		targetObjectData.put('email', email);
		targetObjectData.put('mobile', mobile);

		return targetObjectData;
	}

	private static sObject getTargetObject(String recordId, String objectName, BasiqConnectorSettings__c cSettings) {
		String query;
		List<String> fieldList = new List<String>();
		switch on objectName {
			when 'Contact' {
				fieldList.add('BasiqUserId__c');
				fieldList.add('BasiqConnectURL__c');
				fieldList.add(cSettings.ContactEmailMapping__c);
				fieldList.add(cSettings.ContactMobileMapping__c);
			}
			when 'Lead' {
				fieldList.add('BasiqUserId__c');
				fieldList.add('BasiqConnectURL__c');
				fieldList.add(cSettings.ContactEmailMapping__c);
				fieldList.add(cSettings.ContactMobileMapping__c);
			}
			when else {
				return null;
			}
		}

		sObject targetObject = database.query('Select ' + String.join(fieldList, ',') + ' FROM ' + objectName + ' Where Id = :recordId limit 1');
		return targetObject;
	}

	private static String getRecordFullName(String recordId, String objectName) {
		String fullName = 'John Doe';
		switch on objectName {
			when 'Contact' {
				Contact contact = [SELECT Id, FirstName, LastName FROM Contact WHERE Id = :recordId LIMIT 1];
				fullName = contact.FirstName + ' ' + contact.LastName;
			}
			when 'Lead' {
				Lead lead = [SELECT Id, FirstName, LastName FROM Lead WHERE Id = :recordId LIMIT 1];
				fullName = lead.FirstName + ' ' + lead.LastName;
			}
		}
		return fullName;
	}

	private static Void validateObjectType(String objectName) {
		if (!supportedObjects.contains(objectName)) {
			throw new AuraHandledException(new ControllerErrorMessage('Unsupported Object type', 'Object type ' + objectName + ' is not supported!', 'Unsupported Object type').GetJson());
		}
	}

	private static void validateApiKeySettings() {
		if (String.isEmpty(cSettings.Basiq_Api_Key__c)) {
			throw new AuraHandledException('API Key not configured');
		}
	}

	private static void validateFieldsSettings() {
		if (String.isEmpty(cSettings.ContactEmailMapping__c)) {
			throw new AuraHandledException('Contact email map field not confgured');
		} else if (String.isEmpty(cSettings.ContactMobileMapping__c)) {
			throw new AuraHandledException('Contact mobile map field not confgured');
		} else if (String.isEmpty(cSettings.LeadEmailMapping__c)) {
			throw new AuraHandledException('Lead email map field not confgured');
		} else if (String.isEmpty(cSettings.LeadMobileMapping__c)) {
			throw new AuraHandledException('Lead mobile map field not confgured');
		}
	}

	private static Boolean validateMobileNumber(String mobile) {
		if (mobile == null) {
			return false;
		}
		return Pattern.matches('\\+[0-9]{10}+[0-9]*', mobile);
	}

	private static Boolean validateEmail(String email) {
		if (email == null) {
			return false;
		}
		return Pattern.matches('^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$', email);
	}

	@TestVisible
	private static void validateIsDeletable(List<SObject> sos) {
		if (sos.isEmpty()) {
			return;
		}

		validateIsDeletable(sos[0]);
	}

	@TestVisible
	private static void validateIsDeletable(SObject so) {
		if (!so.getsObjectType().getDescribe().isDeletable()) {
			throw new AuraHandledException(new ControllerErrorMessage(so.getsObjectType() + ' is not deleteable', 'Failed to delete ' + so.getsObjectType() + ' records', 'Error').GetJson());
		}
	}

	@TestVisible
	private static void validateIsCreatable(List<SObject> sos) {
		if (sos.isEmpty()) {
			return;
		}

		validateIsCreatable(sos[0]);
	}

	@TestVisible
	private static void validateIsCreatable(SObject so) {
		if (!so.getsObjectType().getDescribe().isCreateable()) {
			throw new AuraHandledException(new ControllerErrorMessage(so.getsObjectType() + ' is not createable', 'Failed to create ' + so.getsObjectType() + ' records', 'Error').GetJson());
		}
	}

	@TestVisible
	private static void validateResponse(HttpResponse response, Integer code, String errorMessage) {
		if (response.getStatusCode() != code) {
			throw new AuraHandledException(new ControllerErrorMessage('status: ' + response.getStatusCode() + 'body: ' + response.getBody(), errorMessage, 'Error').GetJson());
		}
	}

	@TestVisible
	private static Boolean validateKey(Map<String, Object> dict, String key) {
		if (dict.isEmpty() || !dict.containsKey(key) || dict.get(key) == null) {
			return false;
		}
		
		if (dict.get(key) instanceof String) {
			return !String.isBlank((String) dict.get(key));
		}

		return true;
	}

	private static void assignLookup(BasiqEntityConnection_v2__c entity, String objectName, String recordId) {
		switch on objectName {
			when 'Contact' {
				entity.Contact__c = recordId;
			}
			when 'Lead' {
				entity.Lead__c = recordId;
			}
		}
	}

	private static void assignLookup(BasiqEntityAccount_v2__c entity, String objectName, String recordId) {
		switch on objectName {
			when 'Contact' {
				entity.Contact__c = recordId;
			}
			when 'Lead' {
				entity.Lead__c = recordId;
			}
		}
	}

	private static void assignLookup(BasiqEntityTransaction_v2__c entity, String objectName, String recordId) {
		switch on objectName {
			when 'Contact' {
				entity.Contact__c = recordId;
			}
			when 'Lead' {
				entity.Lead__c = recordId;
			}
		}
	}

	private static void assignLookup(BasiqEntityAffordability_v2__c entity, String objectName, String recordId) {
		switch on objectName {
			when 'Contact' {
				entity.Contact__c = recordId;
			}
			when 'Lead' {
				entity.Lead__c = recordId;
			}
		}
	}

	private static void assignLookup(BasiqEntityIncome_v2__c entity, String objectName, String recordId) {
		switch on objectName {
			when 'Contact' {
				entity.Contact__c = recordId;
			}
			when 'Lead' {
				entity.Lead__c = recordId;
			}
		}
	}
}
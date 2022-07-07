@isTest
public class BasiqConnectorWidgetControllerTest {
	@isTest
	private static void testGetBasiqLink() {
		BasiqConnectorWidgetController.basiqApi = new BasiqAPIMock();

		constructSettings();

		Contact contact = new Contact();
		contact.Email = 'test@test.test';
		contact.MobilePhone = '+123456789012';
		contact.LastName = 'Testic';

		insert contact;

		String link = BasiqConnectorWidgetController.getBasiqLink(contact.Id, 'Contact');
		System.assert(!String.isEmpty(link));

		delete contact;

		Lead lead = new Lead();
		lead.Email = 'test@test.test';
		lead.MobilePhone = '+123456789012';
		lead.LastName = 'Testic';
		lead.Company = 'Test inc';
		insert lead;

		link = BasiqConnectorWidgetController.getBasiqLink(lead.Id, 'Lead');
		System.assert(!String.isEmpty(link));

		delete lead;
	}

	@isTest
	private static void testGetBasiqLinkNoEmail() {
		AuraHandledException aex = null;

		BasiqConnectorWidgetController.basiqApi = new BasiqAPIMock();

		constructSettings();

		Contact contact = new Contact();
		contact.LastName = 'Testic';
		contact.MobilePhone = '+123213213';

		insert contact;
		try {
			String link = BasiqConnectorWidgetController.getBasiqLink(contact.Id, 'Contact');
		} catch (AuraHandledException e) {
			aex = e;
		}
		delete contact;

		System.assertNotEquals(null, aex);
	}

	@isTest
	private static void testGetBasiqLinkNoMobile() {
		AuraHandledException aex = null;

		BasiqConnectorWidgetController.basiqApi = new BasiqAPIMock();

		constructSettings();

		Contact contact = new Contact();
		contact.LastName = 'Testic';
		contact.Email = 'test@test.test';

		insert contact;
		try {
			String link = BasiqConnectorWidgetController.getBasiqLink(contact.Id, 'Contact');
		} catch (AuraHandledException e) {
			aex = e;
		}
		delete contact;

		System.assertNotEquals(null, aex);
	}

	@isTest
	private static void testGetBasiqLinkNoEmailAndNoMobile() {
		AuraHandledException aex = null;

		BasiqConnectorWidgetController.basiqApi = new BasiqAPIMock();

		constructSettings();

		Contact contact = new Contact();
		contact.LastName = 'Testic';

		insert contact;
		try {
			String link = BasiqConnectorWidgetController.getBasiqLink(contact.Id, 'Contact');
		} catch (AuraHandledException e) {
			aex = e;
		}
		delete contact;

		System.assertNotEquals(null, aex);
	}

	@isTest
	private static void testGetBasiqLinkWrongObjectType() {
		AuraHandledException aex = null;

		BasiqConnectorWidgetController.basiqApi = new BasiqAPIMock();

		constructSettings();

		Contact contact = new Contact();
		contact.LastName = 'Testic';

		insert contact;

		try {
			String link = BasiqConnectorWidgetController.getBasiqLink(contact.Id, 'Contact11');
		} catch (AuraHandledException e) {
			aex = e;
		}
		delete contact;
		System.assertNotEquals(null, aex);
	}

	@isTest
	private static void testGetBasiqConnectLinkFromObject() {
		constructSettings();

		Contact contact = new Contact();
		contact.Email = 'test@test.test';
		contact.MobilePhone = '+123213213';
		contact.LastName = 'Testic';
		contact.BasiqConnectURL__c = 'https://connect.basiq.io/lk-520';

		Lead lead = new Lead();
		lead.Email = 'testl@test.test';
		lead.MobilePhone = '+1232132130';
		lead.LastName = 'Testil';
		lead.Company = 'Comp';
		lead.BasiqConnectURL__c = 'https://connect.basiq.io/lk-520l';

		insert contact;
		insert lead;

		String contactLink = BasiqConnectorWidgetController.getBasiqConnectLinkFromObject(contact.Id, 'Contact');
		String leadLink = BasiqConnectorWidgetController.getBasiqConnectLinkFromObject(lead.Id, 'Lead');
		System.assert(!String.isEmpty(contactLink));
		System.assert(!String.isEmpty(leadLink));

		delete contact;
		delete lead;
	}

	@isTest
	private static void testDeleteBasiqLink() {
		constructSettings();
		BasiqConnectorWidgetController.basiqApi = new BasiqAPIMock();

		Contact contact = new Contact();
		contact.Email = 'test@test.test';
		contact.MobilePhone = '+123456789012';
		contact.LastName = 'Testic';

		insert contact;

		String link = BasiqConnectorWidgetController.getBasiqLink(contact.Id, 'Contact');
		System.assert(!String.isEmpty(link));
		BasiqConnectorWidgetController.deleteBasiqLink(contact.Id, 'Contact');

		delete contact;
	}

	@isTest
	private static void testFetchExistingConnectionObjects() {
		constructSettings();
		BasiqConnectorWidgetController.bigData = new BigDataMock();

		Contact contact = new Contact();
		contact.Email = 'test@test.test';
		contact.MobilePhone = '+123213213';
		contact.LastName = 'Testic';
		contact.BasiqConnectURL__c = 'https://connect.basiq.io/lk-520';
		contact.BasiqUserId__c = '12234213';

		BasiqEntityConnection_v2__c connection = new BasiqEntityConnection_v2__c();
		connection.BasiqConnectionId__c = 'connectionId1';
		connection.BasiqUserId__c = contact.BasiqUserId__c;
		connection.InstitutionName__c = 'institucija';
		connection.LastUsed__c = Datetime.now();
		connection.Logo__c = 'logo.com';
		connection.Status__c = 'active';

		insert contact;
		insert connection;
		
		String resultsData = BasiqConnectorWidgetController.fetchExistingConnectionObjects(contact.Id, 'Contact');
		List<Object> resultList = (List<Object>) JSON.deserializeUntyped(resultsData);
		System.assertNotEquals(null, resultList);
		System.assertEquals(1, resultList.size());
		
		delete contact;
		delete connection;
	}

	@isTest
	private static void testRevokeConnection() {
		constructSettings();
		BasiqConnectorWidgetController.basiqApi = new BasiqAPIMock();
		BasiqConnectorWidgetController.bigData = new BigDataMock();

		Contact contact = new Contact();
		contact.Email = 'test@test.test';
		contact.MobilePhone = '+123213213';
		contact.LastName = 'Testic';
		contact.BasiqConnectURL__c = 'https://connect.basiq.io/lk-520';
		contact.BasiqUserId__c = '12234213';

		BasiqEntityConnection_v2__c connection = new BasiqEntityConnection_v2__c();
		connection.BasiqConnectionId__c = 'connectionId1';
		connection.BasiqUserId__c = contact.BasiqUserId__c;
		connection.InstitutionName__c = 'institucija';
		connection.LastUsed__c = Datetime.now();
		connection.Logo__c = 'logo.com';
		connection.Status__c = 'active';

		insert contact;
		insert connection;

		String resultsData = BasiqConnectorWidgetController.revokeConnection(contact.Id, 'Contact', 'connectionId1');
		System.assertEquals('connectionId1', resultsData);

		delete contact;
	}

	@isTest
	private static void testRetriveConnections() {
		constructSettings();
		BasiqConnectorWidgetController.basiqApi = new BasiqAPIMock();
		BasiqConnectorWidgetController.bigData = new BigDataMock();

		Contact contact = new Contact();
		contact.Email = 'test@test.test';
		contact.MobilePhone = '+123213213';
		contact.LastName = 'Testic';
		contact.BasiqConnectURL__c = 'https://connect.basiq.io/lk-520';
		contact.BasiqUserId__c = '12234213';

		BasiqEntityConnection_v2__c connection = new BasiqEntityConnection_v2__c();
		connection.BasiqConnectionId__c = 'connectionId1';
		connection.Status__c = 'active';
		connection.LastUsed__c = (Datetime) JSON.deserialize('"' + '2017-09-28T11:15:09Z' + '"', Datetime.class); // TODO
		connection.BasiqUserId__c = contact.BasiqUserId__c;
		connection.Logo__c = 'logo.com';
		connection.InstitutionName__c = 'institucija';

		insert contact;
		insert connection;

		String resultData = BasiqConnectorWidgetController.retriveConnections(contact.Id, 'Contact');
		List<Object> resultList = (List<Object>) JSON.deserializeUntyped(resultData);
		Map<String, Object> result = (Map<String, Object>) resultList[0];
		System.assertEquals((String) result.get('id'), 'lk-666');
		System.assertEquals((String) result.get('status'), 'Active');
		System.assertEquals((String) result.get('institution'), 'Banka Mesa');
		System.assertEquals((String) result.get('lastUsed'), '2017-09-28T11:15:09Z');
		System.assertEquals((String) result.get('logo'), 'logo');

		delete contact;
	}

	@isTest
	private static void testRefreshConnections() {
		constructSettings();
		BasiqConnectorWidgetController.basiqApi = new BasiqAPIMock();
		BasiqConnectorWidgetController.bigData = new BigDataMock();

		Contact contact = new Contact();
		contact.Email = 'test@test.test';
		contact.MobilePhone = '+123213213';
		contact.LastName = 'Testic';
		contact.BasiqConnectURL__c = 'https://connect.basiq.io/lk-520';
		contact.BasiqUserId__c = '12234213';

		BasiqEntityConnection_v2__c connection = new BasiqEntityConnection_v2__c();
		connection.BasiqConnectionId__c = 'connectionId1';
		connection.Status__c = 'active';
		connection.LastUsed__c = Datetime.now();
		connection.BasiqUserId__c = contact.BasiqUserId__c;
		connection.Logo__c = 'logo.com';
		connection.InstitutionName__c = 'institucija';

		insert contact;
		insert connection;

		BasiqConnectorWidgetController.refreshConnections(contact.Id, 'Contact', '["connectionId1"]');
		List<BasiqEntityConnectionRefreshJob_v2__c> jobs = [SELECT Id FROM BasiqEntityConnectionRefreshJob_v2__c WHERE BasiqUserId__c = :contact.BasiqUserId__c];
		System.assertEquals(jobs.size(), 1);

		delete jobs;
		delete contact;
		delete connection;
	}

	@isTest
	private static void testCheckRefreshJobStatuses() {
		constructSettings();
		BasiqConnectorWidgetController.basiqApi = new BasiqAPIMock();
		BasiqConnectorWidgetController.bigData = new BigDataMock();

		Contact contact = new Contact();
		contact.Email = 'test@test.test';
		contact.MobilePhone = '+123213213';
		contact.LastName = 'Testic';
		contact.BasiqConnectURL__c = 'https://connect.basiq.io/lk-520';
		contact.BasiqUserId__c = '12234213';

		BasiqEntityConnection_v2__c connection = new BasiqEntityConnection_v2__c();
		connection.BasiqConnectionId__c = 'connectionId1';
		connection.Status__c = 'active';
		connection.LastUsed__c = (Datetime) JSON.deserialize('"' + '2017-09-28T11:15:09Z' + '"', Datetime.class);
		connection.BasiqUserId__c = contact.BasiqUserId__c;
		connection.Logo__c = 'logo.com';
		connection.InstitutionName__c = 'institucija';

		BasiqEntityConnectionRefreshJob_v2__c connectionRefreshJob = new BasiqEntityConnectionRefreshJob_v2__c();
		connectionRefreshJob.BasiqJobId__c = 'connectionRefreshJobId1';
		connectionRefreshJob.BasiqUserId__c = contact.BasiqUserId__c;
		connectionRefreshJob.BasiqConnectionId__c = connection.BasiqConnectionId__c;

		insert contact;
		insert connection;
		insert connectionRefreshJob;

		String resultsData = BasiqConnectorWidgetController.checkRefreshJobStatuses(contact.Id, 'Contact', '["connectionId1"]');
		System.assert(!String.isEmpty(resultsData));

		delete connection;
		delete contact;
	}

	@isTest
	private static void testStoreConnectionFinancialData() {
		constructSettings();
		BasiqConnectorWidgetController.basiqApi = new BasiqAPIMock();
		BasiqConnectorWidgetController.bigData = new BigDataMock();

		Contact contact = new Contact();
		contact.Email = 'test@test.test';
		contact.MobilePhone = '+123213213';
		contact.LastName = 'Testic';
		contact.BasiqConnectURL__c = 'https://connect.basiq.io/lk-520';
		contact.BasiqUserId__c = '12234213';

		BasiqEntityConnection_v2__c connection = new BasiqEntityConnection_v2__c();
		connection.BasiqUserId__c = contact.BasiqUserId__c;
		connection.BasiqConnectionId__c = 'connectionId1';
		connection.InstitutionName__c = 'institucija';
		connection.LastUsed__c = Datetime.now();
		connection.Logo__c = 'logo.com';
		connection.Status__c = 'active';

		insert contact;
		insert connection;

		BasiqConnectorWidgetController.storeConnectionFinancialData(contact.Id, 'Contact', 'connectionId1');
		List<BasiqEntityAccount_v2__c> accounts = [SELECT Id FROM BasiqEntityAccount_v2__c WHERE BasiqConnectionId__c = :connection.Id];
		System.assert(accounts.isEmpty());

		delete connection;
		delete contact;
	}

	@isTest
	private static void testPostAffordabilityReport() {
		constructSettings();
		BasiqConnectorWidgetController.basiqApi = new BasiqAPIMock();
		BasiqConnectorWidgetController.bigData = new BigDataMock();

		Contact contact = new Contact();
		contact.Email = 'test@test.test';
		contact.MobilePhone = '+123213213';
		contact.LastName = 'Testic';
		contact.BasiqConnectURL__c = 'https://connect.basiq.io/lk-520';
		contact.BasiqUserId__c = '12234213';

		insert contact;

		BasiqConnectorWidgetController.postAffordabilityReport(contact.Id, 'Contact');

		List<BasiqEntityAffordability_v2__c> affordabilities = [SELECT Id FROM BasiqEntityAffordability_v2__c WHERE BasiqUserId__c = :contact.BasiqUserId__c];
		System.assert(!affordabilities.isEmpty());

		delete affordabilities;
		delete contact;
	}

	@isTest
	private static void testPostPDFAffordabilityReport() {
		constructSettings();
		BasiqConnectorWidgetController.basiqApi = new BasiqAPIMock();

		Contact contact = new Contact();
		contact.Email = 'test@test.test';
		contact.MobilePhone = '+123213213';
		contact.LastName = 'Testic';
		contact.BasiqConnectURL__c = 'https://connect.basiq.io/lk-520';
		contact.BasiqUserId__c = '12234213';

		insert contact;

		BasiqConnectorWidgetController.postPDFAffordabilityReport(contact.Id, 'Contact');

		List<Attachment> attachments = [SELECT Id FROM Attachment WHERE parentId = :contact.Id];
		System.assertEquals(1, attachments.size());

		delete contact;
	}

	@isTest
	private static void testParseTransactionDataResult() {
		Contact contact = new Contact();
		contact.Email = 'test@test.test';
		contact.MobilePhone = '+123213213';
		contact.LastName = 'Testic';
		contact.BasiqConnectURL__c = 'https://connect.basiq.io/lk-520';
		contact.BasiqUserId__c = '12234213';

		insert contact;

		List<BasiqEntityTransaction_v2__c> transactions = new List<BasiqEntityTransaction_v2__c>();
		
		String body = '{"type":"list","count":1,"size":432,"data":[{"type":"transaction","id":"fx789e","status":"posted","description":"FLIGHT CENTRE CO    BRISB    QL","postDate":"2017-11-10T21:46:44Z","transactionDate":"2017-11-09T00:00:00Z","amount":"-139.98","balance":"356.50","account":"s55bf3","institution":"AU00101","connection":"8fce3b","direction":"debit","class":"payment","subClass":{"code":"722","title":"Travel Agency and Tour Arrangement Services"}}]}';
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(body);
		List<Object> transactionsResponseData = (List<Object>) results.get('data');
		
		try {
			BasiqConnectorWidgetController.parseTransactionDataResult(transactions, transactionsResponseData, 'Contact', contact.Id);
			System.assert(true);
		} catch (Exception e) {
			System.assert(false);
		}

		delete contact;
	}

	@isTest
	private static void testValidateResponse() {
		HttpResponse response = new HttpResponse();
		response.setStatusCode(200);
		
		try {
			BasiqConnectorWidgetController.validateResponse(response, 200, 'Error');
			System.assert(true);
		} catch(Exception e) {
			System.assert(false);
		}
	}

	@isTest
	private static void testValidateIsDeletable() {
		BasiqEntityConnection_v2__c connection = new BasiqEntityConnection_v2__c();
		List<BasiqEntityConnection_v2__c> connections = new List<BasiqEntityConnection_v2__c>();
		connections.add(connection);
		try {
			BasiqConnectorWidgetController.validateIsDeletable(connection);
			BasiqConnectorWidgetController.validateIsDeletable(connections);
			System.assert(true);
		} catch(Exception e) {
			System.assert(false);
		}
	}

	@isTest
	private static void testValidateIsCreatable() {
		BasiqEntityConnection_v2__c connection = new BasiqEntityConnection_v2__c();
		List<BasiqEntityConnection_v2__c> connections = new List<BasiqEntityConnection_v2__c>();
		connections.add(connection);
		try {
			BasiqConnectorWidgetController.validateIsCreatable(connection);
			BasiqConnectorWidgetController.validateIsCreatable(connections);
			System.assert(true);
		} catch(Exception e) {
			System.assert(false);
		}
	}

	@isTest
	private static void testValidateKey() {
		Map<String, Object> dict = new Map<String, Object>();
		dict.put('key1', 'value1');
		dict.put('key2', 2);
		
		Boolean valid1 = BasiqConnectorWidgetController.validateKey(dict, 'key1');
		System.assert(valid1);

		Boolean valid2 = BasiqConnectorWidgetController.validateKey(dict, 'key2');
		System.assert(valid2);

		Boolean invalid = BasiqConnectorWidgetController.validateKey(dict, 'key3');
		System.assert(!invalid);
	}

	private static void constructSettings() {
		BasiqConnectorSettings__c settings = new BasiqConnectorSettings__c();
		settings.Basiq_Api_Key__c = 'ag3nt47';
		settings.ContactEmailMapping__c = 'email';
		settings.ContactMobileMapping__c = 'mobilephone';
		settings.LeadEmailMapping__c = 'email';
		settings.LeadMobileMapping__c = 'mobilephone';
		BasiqConnectorWidgetController.cSettings = settings;
	}
}
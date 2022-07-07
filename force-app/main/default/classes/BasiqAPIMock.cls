@isTest
public class BasiqAPIMock implements IBasiqAPI {
	private final static List<String> methodNames = new List<String>{
		'GetRequest',
		'PostRequest',
		'DeleteRequest',
		'GetToken',
		'CreateUser',
		'CreateAuthLink',
		'GetAuthLink',
		'DeleteAuthLink',
		'GetAccountList',
		'GetConnection',
		'GetInstitution',
		'GetTransactionList',
		'GetConnectionList',
		'DeleteConnection',
		'RefreshConnection',
		'GetJob',
		'PostAffordability'
	};

	private Map<String, Boolean> successMap;

	public BasiqAPIMock() {
		successMap = new Map<String, Boolean>();
		for (String methodName : methodNames) {
			successMap.put(methodName, true);
		}
	}

	public HTTPResponse GetRequest(String accessToken, String endPoint) {
		HttpResponse response = new HttpResponse();
		if (successMap.get('GetRequest')) {
			response.setStatusCode(200);
			if (endPoint == 'accList') {
				response.setBody(
					'{"type": "list","data": [' +
					'{"type": "account", "id": "12345", "accountNo": "600000-157441965", "connection": "lk-9t9", "institution":"SR666999" },' +
					'{"type": "account","id": "67890", "accountNo": "600000-157441111", "connection": "lk-9t9", "institution":"SR666999" }]}'
				);
			} else if (endPoint.contains('transList')) {
				response.setBody('{"type": "list", "size": 432, "data": [{"type": "transaction",  "id": "fx789e", "status": "posted", "description": "FLIGHT CENTRE CO    BRISB    QL", "balance": "356.50", "account":"12345"}], "links":{"next": null}}');
			} else if (endPoint.contains('incomesList')) {
				response.setBody('{"type":"income","id":"s55bf4","fromMonth":"2018-11","toMonth":"2019-11","coverageDays":394,"generatedDate":"2019-12-10T05:49:15","summary":{"regularIncomeAvg":"18098.00","regularIncomeYTD":"90490.00","regularIncomeYear":"217176.00","irregularIncomeAvg":"55.00"}}');
			}
		} else {
			response.setStatusCode(400);
		}
		return response;
	}

	public HTTPResponse PostRequest(String accessToken, String endPoint, String body, String accept) {
		HttpResponse response = new HttpResponse();
		if (successMap.get('PostRequest')) {
			response.setStatusCode(201);
		} else {
			response.setStatusCode(400);
		}
		return response;
	}

	public HTTPResponse DeleteRequest(String accessToken, String endPoint) {
		HttpResponse response = new HttpResponse();
		if (successMap.get('DeleteRequest')) {
			response.setStatusCode(204);
		} else {
			response.setStatusCode(400);
		}
		return response;
	}

	public HTTPResponse GetToken(String apiKey) {
		HttpResponse response = new HttpResponse();
		if (successMap.get('GetToken')) {
			response.setStatusCode(200);
			// Note to Salesforce:
			// Not real access token. Real access tokens are JWT tokens.
			// This class and its mocked data are used only for testing purposes in BasiqConnectorInstallerControllerTest and BasiqConnectorWidgetControllerTest.
			response.setBody('{"access_token":"mocked_access_token"}'); 
		} else {
			response.setStatusCode(400);
		}
		return response;
	}

	public HTTPResponse CreateUser(String accessToken, String email, String mobile) {
		HttpResponse response = new HttpResponse();
		if (successMap.get('CreateUser')) {
			response.setStatusCode(201);
			response.setBody('{"id":"lk-9t9"}');
		} else {
			response.setStatusCode(400);
		}
		return response;
	}

	public HTTPResponse CreateAuthLink(String accessToken, String userId, String mobile) {
		HttpResponse response = new HttpResponse();
		if (successMap.get('CreateAuthLink')) {
			response.setStatusCode(201);
		} else {
			response.setStatusCode(400);
		}
		return response;
	}

	public HTTPResponse GetAuthLink(String accessToken, String userId) {
		HttpResponse response = new HttpResponse();
		if (successMap.get('GetAuthLink')) {
			response.setStatusCode(200);
			response.setBody('{"type": "auth_link", "links": {"public": "https://connect.basiq.io/lk-4d4"}}');
		} else {
			response.setStatusCode(400);
		}

		return response;
	}

	public HTTPResponse DeleteAuthLink(String accessToken, String userId) {
		HttpResponse response = new HttpResponse();
		if (successMap.get('DeleteAuthLink')) {
			response.setStatusCode(204);
		} else {
			response.setStatusCode(400);
		}

		return response;
	}

	public HTTPResponse GetAccountList(String accessToken, String userId) {
		HttpResponse response = new HttpResponse();
		if (successMap.get('GetAccountList')) {
			String body =
				'{"type": "list","data": [' +
				'{"type": "account", "id": "12345", "accountNo": "600000-157441965", "connection": "lk-9t9", "institution":"SR666999" },' +
				'{"type": "account","id": "67890", "accountNo": "600000-157441111", "connection": "lk-9t9", "institution":"SR666999" }]}';
			response.setStatusCode(200);
			response.setBody(body);
		} else {
			response.setStatusCode(400);
		}

		return response;
	}

	public HTTPResponse GetConnection(String accessToken, String userid, String connectionId) {
		HttpResponse response = new HttpResponse();

		if (successMap.get('GetConnection')) {
			response.setStatusCode(200);
			response.setBody('{"type": "connection", "id": "lk-9t9", "lastUsed": "2017-09-28T11:15:09Z", "status": "active", "institution": { "type": "institution", "id": "SR666999"}, "links": {"accounts": "accList", "transactions": "transList"}}');
		} else {
			response.setStatusCode(400);
		}

		return response;
	}

	public HTTPResponse GetInstitution(String accessToken, String institutionId) {
		HttpResponse response = new HttpResponse();
		if (successMap.get('GetInstitution')) {
			response.setStatusCode(200);
			response.setBody('{"type": "institution", "id": "SR666999", "name": "Banka Mesa", "country": "Serbia", "status": "propala", "logo":{"links":{"square":"logo"}}}');
		} else {
			response.setStatusCode(400);
		}

		return response;
	}

	public HTTPResponse GetTransactionList(String accessToken, String userId, String accountId) {
		HttpResponse response = new HttpResponse();
		if (successMap.get('GetTransactionList')) {
			response.setStatusCode(200);
			response.setBody('{"type": "list", "size": 432, "data": [{"type": "transaction",  "id": "fx789e", "status": "posted", "description": "FLIGHT CENTRE CO    BRISB    QL", "balance": "356.50"}]}');
		} else {
			response.setStatusCode(400);
		}

		return response;
	}

	public HTTPResponse GetConnectionList(String accessToken, String userId) {
		HttpResponse response = new HttpResponse();
		if (successMap.get('GetConnectionList')) {
			response.setStatusCode(200);
			response.setBody('{"type": "list", "data": [{"type": "connection", "id": "lk-666", "status": "active", "lastUsed": "2017-09-28T11:15:09Z",' + ' "institution": { "type": "institution","id": "SR666999"},' + '"links": {"accounts": "accList", "transactions": "transList"}}]}');
		} else {
			response.setStatusCode(400);
		}

		return response;
	}

	public HTTPResponse DeleteConnection(String accessToken, String userId, String connectionId) {
		HttpResponse response = new HttpResponse();
		if (successMap.get('DeleteConnection')) {
			response.setStatusCode(204);
		} else {
			response.setStatusCode(400);
		}

		return response;
	}

	public HTTPResponse RefreshConnection(String accessToken, String userId, String connectionId) {
		HttpResponse response = new HttpResponse();
		if (successMap.get('RefreshConnection')) {
			response.setStatusCode(202);
			response.setBody('{"type": "job", "id": "1312FTP"}');
		} else {
			response.setStatusCode(400);
		}

		return response;
	}

	public HTTPResponse GetJob(String accessToken, String jobId) {
		HttpResponse response = new HttpResponse();
		if (successMap.get('GetJob')) {
			response.setStatusCode(200);
			response.setBody(
				'{"type": "job", "id": "1312FTP", "created": "2016-06-08T09:10:32.000Z", "updated": "2016-06-08T09:14:28.000Z",' +
				'"steps": [{"title": "verify-credentials", "status": "success", "result": null},' +
				'{"title": "retrieve-accounts", "status": "success","result": null}, ' +
				'{"title": "retrieve-transactions", "status": "success", "result": null }]}'
			);
		} else {
			response.setStatusCode(400);
		}

		return response;
	}

	public HTTPResponse PostAffordability(String accessToken, String userId, String body, String accept) {
		HttpResponse response = new HttpResponse();
		if (successMap.get('PostAffordability')) {
			if (accept == 'application/json') {
				response.setStatusCode(200);
				response.setBody(
					'{"type":"affordability","id":"s55bf3","fromMonth":"2019-03","toMonth":"2020-03","coverageDays":392,"generatedDate":"2020-03-26T06:56:44","summary":{"assets":"59983.11","liabilities":"-323946.20","netPosition":"-263963.09","creditLimit":"20000.00","expenses":"-12046.00","savings":"93.00","regularIncome":{"previous3Months":{"avgMonthly":"18098.00"}}},"links":{"self":"self","income":"incomesList","expenses":"expensesList"}}'
				);
			} else if (accept == 'application/pdf') {
				response.setStatusCode(201);
				response.setBody('JVBERCg==');
			} else {
				response.setStatusCode(400);
			}
		} else {
			response.setStatusCode(400);
		}

		return response;
	}
}
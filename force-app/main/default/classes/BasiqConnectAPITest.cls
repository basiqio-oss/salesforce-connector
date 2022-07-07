@isTest
public class BasiqConnectAPITest {
	@isTest
	private static void testGetToken() {
		BasiqConnectAPI api = new BasiqConnectAPI();
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('basiqApiConnectMockResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json');

		Test.setMock(HttpCalloutMock.class, mock);

		HTTPResponse res = api.GetToken('apiKey');

		System.assertEquals(200, res.getStatusCode());
		System.assertEquals('application/json', res.getHeader('Content-Type'));
	}

	@isTest
	private static void testGetRequest() {
		BasiqConnectAPI api = new BasiqConnectAPI();
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('basiqApiConnectMockResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json');

		Test.setMock(HttpCalloutMock.class, mock);

		HTTPResponse res = api.GetRequest('accessToken', 'endPoint');

		System.assertEquals(200, res.getStatusCode());
		System.assertEquals('application/json', res.getHeader('Content-Type'));
	}

	@isTest
	private static void testDeleteRequest() {
		BasiqConnectAPI api = new BasiqConnectAPI();
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('basiqApiConnectMockResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json');

		Test.setMock(HttpCalloutMock.class, mock);

		HTTPResponse res = api.DeleteRequest('accessToken', 'endPoint');

		System.assertEquals(200, res.getStatusCode());
		System.assertEquals('application/json', res.getHeader('Content-Type'));
	}

	@isTest
	private static void testPostRequest() {
		BasiqConnectAPI api = new BasiqConnectAPI();
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('basiqApiConnectMockResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json');

		Test.setMock(HttpCalloutMock.class, mock);

		HTTPResponse res = api.PostRequest('accessToken', 'endPoint', '', 'application/json');

		System.assertEquals(200, res.getStatusCode());
		System.assertEquals('application/json', res.getHeader('Content-Type'));
	}

	@isTest
	private static void testCreateUser() {
		BasiqConnectAPI api = new BasiqConnectAPI();
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('basiqApiConnectMockResponse');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json');

		Test.setMock(HttpCalloutMock.class, mock);

		HTTPResponse res = api.CreateUser('apiKey', 'email@email.com', '+12321456');

		System.assertEquals(201, res.getStatusCode());
		System.assertEquals('application/json', res.getHeader('Content-Type'));

		res = api.CreateUser('apiKey', '', '+12321456');

		System.assertEquals(201, res.getStatusCode());
		System.assertEquals('application/json', res.getHeader('Content-Type'));

		res = api.CreateUser('apiKey', 'email@email.com', '');

		System.assertEquals(201, res.getStatusCode());
		System.assertEquals('application/json', res.getHeader('Content-Type'));
	}

	@isTest
	private static void testCreateAuthLink() {
		BasiqConnectAPI api = new BasiqConnectAPI();
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('basiqApiConnectMockResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json');

		Test.setMock(HttpCalloutMock.class, mock);

		HTTPResponse res = api.CreateAuthLink('token', '1232145', '');

		System.assertEquals(200, res.getStatusCode());
		System.assertEquals('application/json', res.getHeader('Content-Type'));

		res = api.CreateAuthLink('token', '1232145', '+12321456');

		System.assertEquals(200, res.getStatusCode());
		System.assertEquals('application/json', res.getHeader('Content-Type'));
	}

	@isTest
	private static void testGetAuthLink() {
		BasiqConnectAPI api = new BasiqConnectAPI();
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('basiqApiConnectMockResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json');

		Test.setMock(HttpCalloutMock.class, mock);

		HTTPResponse res = api.GetAuthLink('token', '1232145');

		System.assertEquals(200, res.getStatusCode());
		System.assertEquals('application/json', res.getHeader('Content-Type'));
	}

	@isTest
	private static void testDeleteAuthLink() {
		BasiqConnectAPI api = new BasiqConnectAPI();
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('basiqApiConnectMockResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json');

		Test.setMock(HttpCalloutMock.class, mock);

		HTTPResponse res = api.DeleteAuthLink('token', '1232145');

		System.assertEquals(200, res.getStatusCode());
		System.assertEquals('application/json', res.getHeader('Content-Type'));
	}

	@isTest
	private static void testGetAccountList() {
		BasiqConnectAPI api = new BasiqConnectAPI();
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('basiqApiConnectMockResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json');

		Test.setMock(HttpCalloutMock.class, mock);

		HTTPResponse res = api.GetAccountList('token', '1232145');

		System.assertEquals(200, res.getStatusCode());
		System.assertEquals('application/json', res.getHeader('Content-Type'));
	}

	@isTest
	private static void testGetConnection() {
		BasiqConnectAPI api = new BasiqConnectAPI();
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('basiqApiConnectMockResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json');

		Test.setMock(HttpCalloutMock.class, mock);

		HTTPResponse res = api.GetConnection('token', '1232145', '777');

		System.assertEquals(200, res.getStatusCode());
		System.assertEquals('application/json', res.getHeader('Content-Type'));
	}

	@isTest
	private static void testGetInstitution() {
		BasiqConnectAPI api = new BasiqConnectAPI();
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('basiqApiConnectMockResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json');

		Test.setMock(HttpCalloutMock.class, mock);

		HTTPResponse res = api.GetInstitution('token', '1232145');

		System.assertEquals(200, res.getStatusCode());
		System.assertEquals('application/json', res.getHeader('Content-Type'));
	}

	@isTest
	private static void testGetTransactionList() {
		BasiqConnectAPI api = new BasiqConnectAPI();
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('basiqApiConnectMockResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json');

		Test.setMock(HttpCalloutMock.class, mock);

		HTTPResponse res = api.GetTransactionList('token', '1232145', '888');

		System.assertEquals(200, res.getStatusCode());
		System.assertEquals('application/json', res.getHeader('Content-Type'));
	}

	@isTest
	private static void testGetConnectionList() {
		BasiqConnectAPI api = new BasiqConnectAPI();
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('basiqApiConnectMockResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json');

		Test.setMock(HttpCalloutMock.class, mock);

		HTTPResponse res = api.GetConnectionList('token', '1232145');

		System.assertEquals(200, res.getStatusCode());
		System.assertEquals('application/json', res.getHeader('Content-Type'));
	}

	@isTest
	private static void testDeleteConnection() {
		BasiqConnectAPI api = new BasiqConnectAPI();
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('basiqApiConnectMockResponse');
		mock.setStatusCode(204);
		mock.setHeader('Content-Type', 'application/json');

		Test.setMock(HttpCalloutMock.class, mock);

		HTTPResponse res = api.DeleteConnection('token', '1232145', '666');

		System.assertEquals(204, res.getStatusCode());
		System.assertEquals('application/json', res.getHeader('Content-Type'));
	}

	@isTest
	private static void testRefreshConnection() {
		BasiqConnectAPI api = new BasiqConnectAPI();
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('basiqApiConnectMockResponse');
		mock.setStatusCode(201);
		mock.setHeader('Content-Type', 'application/json');

		Test.setMock(HttpCalloutMock.class, mock);

		HTTPResponse res = api.RefreshConnection('token', '1232145', '666');

		System.assertEquals(201, res.getStatusCode());
		System.assertEquals('application/json', res.getHeader('Content-Type'));
	}

	@isTest
	private static void testGetJob() {
		BasiqConnectAPI api = new BasiqConnectAPI();
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('basiqApiConnectMockResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json');

		Test.setMock(HttpCalloutMock.class, mock);

		HTTPResponse res = api.GetJob('token', '1232145');

		System.assertEquals(200, res.getStatusCode());
		System.assertEquals('application/json', res.getHeader('Content-Type'));
	}

	@isTest
	private static void testPostAffordability() {
		BasiqConnectAPI api = new BasiqConnectAPI();
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('basiqApiConnectMockResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json');

		Test.setMock(HttpCalloutMock.class, mock);

		HTTPResponse res = api.PostAffordability('token', '1232145', 'TODO', 'application/json');

		System.assertEquals(200, res.getStatusCode());
		System.assertEquals('application/json', res.getHeader('Content-Type'));
	}
}
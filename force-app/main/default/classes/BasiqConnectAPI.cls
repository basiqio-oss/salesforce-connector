public class BasiqConnectAPI implements IBasiqAPI {
	private final String endPoint = 'https://au-api.basiq.io';

	public HTTPResponse GetToken(String apiKey) {
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setTimeout(30000);
		request.setEndpoint(endPoint + '/token');
		request.setMethod('POST');
		request.setHeader('Authorization', 'Basic ' + apiKey);
		request.setHeader('basiq-version', '2.0');
		request.setHeader('Content-Type', 'application/x-www-form-urlencoded');

		HttpResponse response = http.send(request);

		return response;
	}

	public HTTPResponse GetRequest(String accessToken, String endPoint) {
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setTimeout(30000);
		request.setEndpoint(endPoint);
		request.setMethod('GET');
		request.setHeader('Authorization', 'Bearer ' + accessToken);
		request.setHeader('Content-Type', 'application/json');

		HttpResponse response = http.send(request);

		return response;
	}

	public HTTPResponse DeleteRequest(String accessToken, String endPoint) {
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setTimeout(30000);
		request.setEndpoint(endPoint);
		request.setMethod('DELETE');
		request.setHeader('Authorization', 'Bearer ' + accessToken);
		request.setHeader('Content-Type', 'application/json');

		HttpResponse response = http.send(request);

		return response;
	}

	public HTTPResponse PostRequest(String accessToken, String endPoint, String body, String accept) {
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setTimeout(30000);
		request.setEndpoint(endPoint);
		request.setMethod('POST');
		request.setHeader('Authorization', 'Bearer ' + accessToken);
		request.setHeader('Content-Type', 'application/json');
		request.setHeader('Accept', accept);
		request.setBody(body);
		HttpResponse response = http.send(request);

		return response;
	}

	public HTTPResponse CreateUser(String accessToken, String email, String mobile) {
		Map<String, String> requestParameters = new Map<String, String>();
		if (!String.isEmpty(email)) {
			requestParameters.put('email', email);
		}
		if (!String.isEmpty(mobile)) {
			requestParameters.put('mobile', mobile);
		}

		return PostRequest(accessToken, endPoint + '/users', JSON.serialize(requestParameters), 'application/json');
	}

	public HTTPResponse CreateAuthLink(String accessToken, String userId, String mobile) {
		Map<String, String> requestParameters = new Map<String, String>();
		if (!String.isEmpty(mobile)) {
			requestParameters.put('mobile', mobile);
		}

		return PostRequest(accessToken, endPoint + '/users/' + userId + '/auth_link', JSON.serialize(requestParameters), 'application/json');
	}

	public HTTPResponse GetAuthLink(String accessToken, String userId) {
		return GetRequest(accessToken, endPoint + '/users/' + userId + '/auth_link');
	}

	public HttpResponse DeleteAuthLink(String accessToken, String userId) {
		return DeleteRequest(accessToken, endPoint + '/users/' + userId + '/auth_link');
	}

	public HTTPResponse GetAccountList(String accessToken, String userId) {
		return GetRequest(accessToken, endPoint + '/users/' + userid + '/accounts');
	}

	public HTTPResponse GetConnection(String accessToken, String userid, String connectionId) {
		return GetRequest(accessToken, endPoint + '/users/' + userid + '/connections/' + connectionId);
	}

	public HTTPResponse GetInstitution(String accessToken, String institutionId) {
		return GetRequest(accessToken, endPoint + '/institutions/' + institutionId);
	}

	public HTTPResponse GetTransactionList(String accessToken, String userId, String accountId) {
		return GetRequest(accessToken, endPoint + '/users/' + userId + '/transactions?filter=account.id.eq(\'' + accountId + '\')');
	}

	public HTTPResponse GetConnectionList(String accessToken, String userId) {
		return GetRequest(accessToken, endPoint + '/users/' + userId + '/connections');
	}

	public HTTPResponse DeleteConnection(String accessToken, String userId, String connectionId) {
		return DeleteRequest(accessToken, endPoint + '/users/' + userId + '/connections/' + connectionId);
	}

	public HTTPResponse RefreshConnection(String accessToken, String userId, String connectionId) {
		return PostRequest(accessToken, endPoint + '/users/' + userId + '/connections/' + connectionId + '/refresh', '', 'application/json');
	}

	public HTTPResponse GetJob(String accessToken, String jobId) {
		return GetRequest(accessToken, endPoint + '/jobs/' + jobId);
	}

	public HTTPResponse PostAffordability(String accessToken, String userId, String body, String accept) {
		return PostRequest(accessToken, endPoint + '/users/' + userId + '/affordability', body, accept);
	}
}
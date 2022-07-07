public interface IBasiqAPI {
	HTTPResponse GetToken(String apiKey);

	HTTPResponse GetRequest(String accessToken, String endPoint);
	HTTPResponse PostRequest(String accessToken, String endPoint, String body, String accept);
	HTTPResponse DeleteRequest(String accessToken, String endPoint);

	HTTPResponse CreateUser(String accessToken, String email, String mobile);
	HTTPResponse CreateAuthLink(String accessToken, String userId, String mobile);
	HTTPResponse GetAuthLink(String accessToken, String userId);
	HTTPResponse DeleteAuthLink(String accessToken, String userId);
	HTTPResponse GetAccountList(String accessToken, String userId);
	HTTPResponse GetConnection(String accessToken, String userid, String connectionId);
	HTTPResponse GetInstitution(String accessToken, String institutionId);
	HTTPResponse GetTransactionList(String accessToken, String userId, String accountId);
	HTTPResponse GetConnectionList(String accessToken, String userId);
	HTTPResponse DeleteConnection(String accessToken, String userId, String connectionId);
	HTTPResponse RefreshConnection(String accessToken, String userId, String connectionId);
	HTTPResponse GetJob(String accessToken, String jobId);
	HttpResponse PostAffordability(String accessToken, String userId, String body, String accept);
}
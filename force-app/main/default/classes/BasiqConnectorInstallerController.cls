public with sharing class BasiqConnectorInstallerController {
	private static final String mappingMetadataDeveloperName = 'BasiqMappings';

	public static IBasiqAPI basiqApi {
		get {
			if (basiqApi == null) {
				basiqApi = new BasiqConnectAPI();
				return basiqApi;
			}
			return basiqApi;
		}
		set {
			basiqApi = value;
		}
	}

	public static BasiqConnectorSettings__c cSettings {
		get {
			if (cSettings == null) {
				cSettings = BasiqConnectorSettings__c.getOrgDefaults();
				if (cSettings.Id == null) {
					if (!BasiqConnectorSettings__c.sObjectType.getDescribe().isCreateable()) {
						throw new AuraHandledException(new ControllerErrorMessage('BasiqConnectorSettings__c is not creatable', 'Failed to create Basiq Connector Settings').GetJson());
					}
					insert cSettings;
				}
			}
			return cSettings;
		}
		set {
			cSettings = value;
		}
	}

	@AuraEnabled
	public static Void checkBasiqApiKey(String apiKey) {
		HttpResponse response = basiqApi.GetToken(apiKey);
		if (response.getStatusCode() != 200) {
			throw new AuraHandledException(response.getStatus());
		}
	}

	@AuraEnabled
	public static Void storeApiKey(String apiKey) {
		cSettings.Basiq_Api_Key__c = apiKey;
		if (!BasiqConnectorSettings__c.sObjectType.getDescribe().isUpdateable()) {
			throw new AuraHandledException(new ControllerErrorMessage('BasiqConnectorSettings__c is not updateable', 'Failed to update Basiq Connector Settings').GetJson());
		}
		update cSettings;
	}

	@AuraEnabled
	public static Void removeApiKey() {
		cSettings.Basiq_Api_Key__c = '';
		if (!BasiqConnectorSettings__c.sObjectType.getDescribe().isUpdateable()) {
			throw new AuraHandledException(new ControllerErrorMessage('BasiqConnectorSettings__c is not updateable', 'Failed to update Basiq Connector Settings').GetJson());
		}
		update cSettings;
	}

	@AuraEnabled
	public static Boolean checkStoredApiKey() {
		return String.isNotBlank(cSettings.Basiq_Api_Key__c);
	}

	@AuraEnabled
	public static List<String> getLeadFieldApiNames() {
		Schema.DescribeSObjectResult r = Lead.sObjectType.getDescribe();
		List<String> apiNameList = new List<String>();
		for (string apiName : r.fields.getMap().keySet()) {
			apiNameList.add(apiName);
		}
		return apiNameList;
	}

	@AuraEnabled
	public static List<String> getContactFieldApiNames() {
		Schema.DescribeSObjectResult r = Contact.sObjectType.getDescribe();
		List<String> apiNameList = new List<String>();
		for (string apiName : r.fields.getMap().keySet()) {
			apiNameList.add(apiName);
		}
		return apiNameList;
	}

	@AuraEnabled
	public static Void storeMappingFields(String contactEmail, String contactMobile, String leadEmail, String leadMobile) {
		cSettings.ContactEmailMapping__c = contactEmail;
		cSettings.ContactMobileMapping__c = contactMobile;
		cSettings.LeadEmailMapping__c = leadEmail;
		cSettings.LeadMobileMapping__c = leadMobile;

		if (!BasiqConnectorSettings__c.sObjectType.getDescribe().isUpdateable()) {
			throw new AuraHandledException(new ControllerErrorMessage('BasiqConnectorSettings__c is not updateable', 'Failed to update Basiq Connector Settings').GetJson());
		}
		update cSettings;
	}
}
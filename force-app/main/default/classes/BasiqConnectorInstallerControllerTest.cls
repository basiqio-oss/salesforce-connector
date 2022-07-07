@isTest
public class BasiqConnectorInstallerControllerTest {
    
    @isTest
    public static void testCheckBasiqApiKey() {
        BasiqConnectorInstallerController.basiqApi = new BasiqAPIMock();
        AuraHandledException aex = null;
        
        try {
            BasiqConnectorInstallerController.checkBasiqApiKey('742617000027');
        } catch(AuraHandledException e) {
            aex = e;
        }
        
        System.assertEquals(null, aex);
    }

    @isTest
    public static void testCheckStoredApiKey() {
        BasiqConnectorSettings__c settings = new BasiqConnectorSettings__c();
        Settings.Basiq_Api_Key__c = '742617000027';
        BasiqConnectorInstallerController.cSettings = settings;
        
        Boolean valid = BasiqConnectorInstallerController.checkStoredApiKey();
        System.assert(valid);
    }
    
    @isTest 
    public static void testStoreApiKey() {
        BasiqConnectorSettings__c settings = new BasiqConnectorSettings__c();
        insert settings;
        BasiqConnectorInstallerController.cSettings = settings;
        
        BasiqConnectorInstallerController.storeApiKey('742617000027');
        
        System.assertEquals('742617000027', BasiqConnectorInstallerController.cSettings.Basiq_Api_Key__c);
        
        BasiqConnectorInstallerController.cSettings = null;
        delete settings;
    }

    @isTest
    public static void testRemoveApiKey() {
        BasiqConnectorSettings__c settings = new BasiqConnectorSettings__c();
        Settings.Basiq_Api_Key__c = '742617000027';
        insert settings;
        BasiqConnectorInstallerController.cSettings = settings;
        
        try {
            BasiqConnectorInstallerController.removeApiKey();
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
        
        delete settings;
    }

    @isTest
    public static void testGetLeadFieldApiNames() {
        List<String> names = BasiqConnectorInstallerController.getLeadFieldApiNames();
        System.assert(!names.isEmpty());
    }

    @isTest
    public static void testGetContactFieldApiNames() {
        List<String> names = BasiqConnectorInstallerController.getContactFieldApiNames();
        System.assert(!names.isEmpty());
    }
    
    @isTest
    public static void testStoreMappingFields() {
        BasiqConnectorSettings__c settings = new BasiqConnectorSettings__c();
        insert settings;
        BasiqConnectorInstallerController.cSettings = settings;
        
        List<String> contactFieldList = BasiqConnectorInstallerController.getContactFieldApiNames();
        List<String> leadFieldList = BasiqConnectorInstallerController.getLeadFieldApiNames();
        
        BasiqConnectorInstallerController.storeMappingFields(contactFieldList[0], 
                                                        contactFieldList[1], 
                                                        leadFieldList[0], 
                                                        leadFieldList[1]);
        
        System.assertEquals(contactFieldList[0], BasiqConnectorInstallerController.cSettings.ContactEmailMapping__c);
        System.assertEquals(contactFieldList[1], BasiqConnectorInstallerController.cSettings.ContactMobileMapping__c);
        System.assertEquals(leadFieldList[0], BasiqConnectorInstallerController.cSettings.LeadEmailMapping__c);
        System.assertEquals(leadFieldList[1], BasiqConnectorInstallerController.cSettings.LeadMobileMapping__c);
        
        BasiqConnectorInstallerController.cSettings = null;
        delete settings;
    }
}
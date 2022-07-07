@isTest
public class BigDataTest {
  @isTest
  private static void testInsertImmediate() {
    BasiqConnectorWidgetController.bigData = new BigDataMock();

    Database.SaveResult result = BasiqConnectorWidgetController.bigData.insertImmediate(new BasiqEntityBigConnection__b());
    System.assertEquals(null, result);
    
    List<Database.SaveResult> results = BasiqConnectorWidgetController.bigData.insertImmediate(new List<BasiqEntityBigConnection__b>());
		System.assertEquals(null, results);
  }

  @isTest
  private static void testDeleteImmediate() {
    BasiqConnectorWidgetController.bigData = new BigDataMock();

    Database.DeleteResult result = BasiqConnectorWidgetController.bigData.deleteImmediate(new BasiqEntityBigConnection__b());
    System.assertEquals(null, result);
    
    List<Database.DeleteResult> results = BasiqConnectorWidgetController.bigData.deleteImmediate(new List<BasiqEntityBigConnection__b>());
		System.assertEquals(null, results);
  }
}
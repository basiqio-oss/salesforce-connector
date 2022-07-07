@isTest
public class BigDataMock implements IBigData {
	public Database.SaveResult insertImmediate(SObject sobjectData) {
		return null;
	}

	public List<Database.SaveResult> insertImmediate(List<SObject> sobjectsData) {
		return null;
	}

	public Database.DeleteResult deleteImmediate(SObject sobjectData) {
		return null;
	}

	public List<Database.DeleteResult> deleteImmediate(List<SObject> sobjectsData) {
		return null;
	}
}
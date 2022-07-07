public with sharing class BigData implements IBigData {
	public Database.SaveResult insertImmediate(SObject sobjectData) {
		return database.insertImmediate(sobjectData);
	}

	public List<Database.SaveResult> insertImmediate(List<SObject> sobjectsData) {
		return database.insertImmediate(sobjectsData);
	}

	public Database.DeleteResult deleteImmediate(SObject sobjectData) {
		return database.deleteImmediate(sobjectData);
	}

	public List<Database.DeleteResult> deleteImmediate(List<SObject> sobjectsData) {
		return database.deleteImmediate(sobjectsData);
	}
}
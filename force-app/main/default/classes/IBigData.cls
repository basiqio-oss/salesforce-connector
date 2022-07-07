public interface IBigData {
	Database.SaveResult insertImmediate(SObject sobjectData);
	List<Database.SaveResult> insertImmediate(List<SObject> sobjectsData);
	Database.DeleteResult deleteImmediate(SObject sobjectData);
	List<Database.DeleteResult> deleteImmediate(List<SObject> sobjectsData);
}
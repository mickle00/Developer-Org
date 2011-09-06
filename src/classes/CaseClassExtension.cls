public with sharing class CaseClassExtension {
	
// Will add to the Case Class? Should we break it out separately?	

//for Before Insert
public void beforeNewTroubleshootingCase(List<Case> myCases){
	for (Case myCase : myCases){
		if (myCase.RecordTypeId == troubleshootingRecordType){
			myCase.OwnerId = troubleshootingQueueId;
			myCase.Involved_Teams__c = getAllInvolvedTeamsPicklistValue();
		}	
	}
}

// for Before Update
public void beforeUpdateTroubleshootingCase(Map<Id, Case> newCaseIDtoCaseMap, Map<Id, Case> oldCaseIDtoCaseMap){
	for (Case myCase : newCaseIDtoCaseMap.values()){
		if (myCase.OwnerId == troubleshootingQueueId) myCase.RecordTypeId = troubleshootingRecordType;
		if (oldCaseIDtoCaseMap.get(myCase.id).RecordTypeId != troubleshootingRecordType && newCaseIDtoCaseMap.get(myCase.id).RecordTypeId == troubleshootingRecordType){
			myCase.Involved_Teams__c = getAllInvolvedTeamsPicklistValue();
		}
	}
}

// for After Insert
public void afterNewTroubleshootingCase(List<Case> myCases){
	List<Checkoff_Junction__c> newCheckoffJunctionsToInsert = new List<Checkoff_Junction__c>();
	for (Case myCase : myCases){
		if (myCase.RecordTypeId == troubleshootingRecordType){
			for (Case_Checkoff__c chk : checkoffs){
				Checkoff_Junction__c checkoffJunctionToAdd = new Checkoff_Junction__c(Case__c = myCase.Id, Case_Checkoff__c = chk.Id);
				newCheckoffJunctionsToInsert.add(checkoffJunctionToAdd);
			}				
		}	
	}
	insert newCheckoffJunctionsToInsert;
}

// for After Update
public void afterUpdateTroubleshootingCase(Map<Id, Case> newCaseIDtoCaseMap, Map<Id, Case> oldCaseIDtoCaseMap){
	Map<Id, Integer> caseCheckoffJunctionCount = new Map<Id, Integer>();
	List<Checkoff_Junction__c> newCheckoffJunctions = new List<Checkoff_Junction__c>();
	
	for (AggregateResult ar : 
			[SELECT Case__c, count(id) total FROM Checkoff_Junction__c WHERE Case__c IN : newCaseIDtoCaseMap.keyset() GROUP BY Case__c]){
		Id i = (Id) ar.get('Case__c');
		Integer tot = (Integer) ar.get('total');
		caseCheckoffJunctionCount.put(i, tot);
	}
		
	for (Case myCase : newCaseIDtoCaseMap.values()){
			if (!caseCheckoffJunctionCount.containsKey(myCase.Id)){
				if (myCase.RecordTypeId == troubleshootingRecordType){
					for (Case_Checkoff__c chk : checkoffs){
						Checkoff_Junction__c checkoffJunctionToAdd = new Checkoff_Junction__c(Case__c = myCase.Id, Case_Checkoff__c = chk.Id);
						newCheckoffJunctions.add(checkoffJunctionToAdd);
						caseCheckoffJunctionCount.put(myCase.Id, 1);
					}
				}
			}		
	}	
	insert newCheckoffJunctions;
}
/**

PRIVATE METHODS



TODO

Private to scope down to troubleshooting cases
**/

// Can I reuse some methods in your Utilities Class to get this Queue && Record Type??
private Id troubleshootingRecordType = [SELECT Id FROM RecordType WHERE DeveloperName ='Troubleshooting' and sObjectType = 'Case' LIMIT 1].Id;
private Id troubleshootingQueueId = [SELECT Id, Name,(SELECT Id,SobjectType FROM QueueSobjects WHERE SobjectType = 'Case') FROM Group WHERE type = 'Queue' and Name = 'Troubleshooting Transport Queue' LIMIT 1].Id;

// List of all of the Checkoff Teams. Currently 11 Teams.
private List<Case_Checkoff__c> checkoffs = [SELECT Id from Case_Checkoff__c];

// build all all possible values of Involved_Teams__c into a semicolon seperated string
private String getAllInvolvedTeamsPicklistValue(){
  String involvedTeams = '';
  Schema.DescribeFieldResult fieldResult = Case.Involved_Teams__c.getDescribe();
  List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
  for (Schema.PicklistEntry picklistEntry : picklistEntries){
    involvedTeams = involvedTeams + picklistEntry.getValue() + ';';
  }
  return involvedTeams;
}
}
public with sharing class POS_Class {

//List of all POSs in SFDC
private static List<POS__c> POSlist = [SELECT Name, Brand__c, Id 
                                       FROM POS__c]; 

//build a unique name from the POS, with Name + Brand
private static string UniquePOSname(POS__c myPOC){
  string dash = '-';
  string brand = myPOC.Brand__c;
  // trap for Hotwire.com or any other POS which don't have a brand
  if(myPOC.Brand__c == null || myPOC.Brand__c == ''){
  	dash = '';
  	brand ='';
  }
  
  string uname = brand + dash + myPOC.Name;
  return uname;	
}

//build a map of uniquePOSname, to POS Id
private static Map<String, ID> POSidMap(){
	Map <String, Id> tempPOSidMap = new Map<String, Id> ();
	for (POS__c p : POSlist){
 		tempPOSidMap.put(UniquePOSname(p), p.Id);
	}
	return tempPOSidMap;
}
//Get the ID value of the POS__c using the unique name.
private static Id getPOSid(String uniquePOSname){
 return POSidMap().get(uniquePOSname);
}

//use this if trigger.isInsert....if it's insert cannot pass trigger.oldmap as it's null
public void LinkPOStoNewCase(List<Case> cases){
	List<POS_Junction__c> newJunctions = new List<POS_Junction__c>();
	List<String> insertedPOSes = new List<String>();
	for(Case c: cases){
		string allPOS = c.POS__c;
		if (c.POS__c != NULL) insertedPOSes = allPOS.split(';');
		for (String p : insertedPOSes){
			POS_Junction__c newposjunc = new POS_Junction__c(Case__c = c.id, POS__c = getPOSid(p));
	 		if(newposjunc.POS__c != NULL) newjunctions.add(newposjunc);	
		}
	}
	insert newjunctions;
}

//use this is if trigger.isUpdate. Passses both the trigger.newMap and trigger.oldMap to compare the values
public void updateCasePOS(Map<Id, Case> toldmap, Map<Id, Case> tnewmap){

	List<POS_Junction__c> newJunctions = new List<POS_Junction__c>();
	List<POS_Junction__c> deleteJunctions = new List<POS_Junction__c>();	
	
	List<POS_Junction__c> POSjunctionlist =  [SELECT Id, Case__c, POS__r.Name, POS__r.Brand__c 
	                                          FROM POS_Junction__c 
	                                          WHERE Case__c IN: tnewmap.keyset()];

	for (Case c : tnewmap.values()){		
		if(tnewmap.get(c.id).POS__c == toldmap.get(c.id).POS__c){
			system.debug('No changes were made to Case: ' + c);
		}
		else{
			//build a set of newPOses
			List<String> newPOS = new List<String>();
			Set<String> newPOSset = new Set<String>();
			if (c.POS__c != NULL) newPOS = c.POS__c.split(';');
			newPOSset.addAll(newPOS);
			
			//build a set of oldPOSs
			List<String> oldPOS = new List<String>();
			if (toldmap.get(c.id).POS__c != NULL) oldPOS = toldmap.get(c.id).POS__c.split(';');
			Set<String> oldPOSset = new Set<String>();
			oldPOSset.addAll(oldPOS);			
			
			//compare sets to insert POSs that have been added
			Set<String> toAdd = new Set<String>();
			toAdd = newPOSset.clone();
			toAdd.removeAll(oldPOSset);
			
			//compare sets to remove POSs that have been deleted
			Set<String> toDelete = new Set<String>();
			toDelete = oldPOSset.clone();
			toDelete.removeAll(newPOSset);
			
			//add the new POS Junctions Records
			for (String p : toAdd){
				POS_Junction__c newposjunc = new POS_Junction__c(Case__c = c.id, POS__c = getPOSid(p));
				if(newposjunc.Case__c != null && newposjunc.POS__c != null) newjunctions.add(newposjunc);
			}
			
			//delete the POS Junctions Records that have been removed
			//need to figure out a more elegant way of mapping these.
			for (String d : toDelete){				
				for (POS_Junction__c pj : POSjunctionlist){
					String fakekey = UniquePOSname(pj.POS__r);
					if (pj.Case__c == c.id && fakekey == d){
						deletejunctions.add(pj);						
					}
				}				
			}
		}
	}
	insert newjunctions;
	delete deleteJunctions;
}


  /**
  
  TEST METHODS
  
  **/
  
  private static testMethod void TestPOSClass() {
  	POS_Class pos = new POS_Class();
  	
  	List <Case> testCases = new List<Case>();
  	Case cs = new Case(Subject = 'TestCase', Status = 'New', POS__c = 'Expedia-Netherlands;Expedia-Singapore');
  	testCases.add(cs);
  	insert testCases;
  	pos.LinkPOStoNewCase(testCases);  	

  	Map<Id, Case> cMapOld = new Map<Id, Case>();
  	Map<Id, Case> cMapNew = new Map<Id, Case>();
  	for (Case c : testCases){
  		cMapOld.put(c.Id, c);
  	}
  	Case cs2 = [SELECT Id, POS__c FROM Case WHERE Id = :cs.Id];
  	cs2.POS__c = 'Expedia-Japan';
  	//update cs2;
  	
  	cMapNew.put(cs2.Id, cs2);  	
  	pos.updateCasePOS(cMapOld, cMapNew);
  		
  }
}
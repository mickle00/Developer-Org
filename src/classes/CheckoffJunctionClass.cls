public with sharing class CheckoffJunctionClass {
	
  // for Before Insert. 
	//Simply Make sure that all junctions state that it's not ready to close
  public void beforeInsertCheckoffJunction(List<Checkoff_Junction__c> myCheckoffJunctions){
		for (Checkoff_Junction__c myCheckoffJunction : myCheckoffJunctions){
			// TODO - CHANGE FIELD NAME		
			myCheckoffJunction.Ready_to_Close2__c = 'No';
		}
  }
	
	// for After Update
	// Update the Status to be either Open or Closed
	// Sync the InvolvedTeams Picklist on the Case object, so that views can be configured.
	public void afterUpdateCheckoffJunction(Map<Id, Checkoff_Junction__c> newIdToCheckOffJunctionMap, Map<Id, Checkoff_Junction__c> oldIdToCheckOffJunctionMap){
		buildAllMaps(newIdToCheckOffJunctionMap);
		updateCaseStatusAndInvolvedTeams(newIdToCheckOffJunctionMap, oldIdToCheckOffJunctionMap);
	}
	
	/**
	PRIVATE METHODS
	**/
	
	private Map<Id, Case> caseIDtoCase = new Map<Id, Case>();
	private Map<Id, String> CheckoffJunctionIDtoTeamNameMap = new Map<Id, String>();
	private Map<Id, Integer> caseStatusCount = new Map<Id, Integer>();
	private Map<String, Id> queueNametoID = new Map<String, Id>();
	
	private void buildAllMaps(Map<Id, Checkoff_Junction__c> newIdToCheckOffJunctionMap){
		Set<Id> CaseIDs = getCaseIDs(newIdToCheckOffJunctionMap.values());
		buildCaseIDtoCaseMap(CaseIDs);
		buildCheckoffJunctionIDtoTeamNameMap(newIdToCheckOffJunctionMap.keySet());
		buildCaseStatusCountMap(CaseIDs);
		buildQueueNameToIdMap();
	}
	
	private Set<Id> getCaseIDs(List<Checkoff_Junction__c> myCheckoffJunctions){
	  Set<Id>CaseIDs = new Set<Id>();
	  for (Checkoff_Junction__c myCheckoffJunction : myCheckoffJunctions){
	    CaseIDs.add(myCheckoffJunction.Case__c);
	  }
	  return CaseIDs;
	}
	
	private void buildCaseIDtoCaseMap(Set<Id> CaseIDs){
	  List<Case> affectedCases = [SELECT Id, Involved_Teams__c, OwnerId, Status FROM Case WHERE Id IN :CaseIDs];
	  for (Case myCase : affectedCases){
	    caseIDtoCase.put(myCase.Id, myCase);
	  }
	}
	
	private void buildCheckoffJunctionIDtoTeamNameMap(Set<Id> cjIDs){
	  for (Checkoff_Junction__c myCheckoffJunction :
	      [SELECT Id, Case_Checkoff__r.Name FROM Checkoff_Junction__c WHERE ID IN : cjIDs]){
	    CheckoffJunctionIDtoTeamNameMap.put(myCheckoffJunction.Id, myCheckoffJunction.Case_Checkoff__r.Name);   
	  }
	}
	
	//Iterate thru Junction, build a set of CaseIDs that are ready to close.
	// One less query
	private void buildCaseStatusCountMap(Set<Id> CaseIDs){  
	  for (AggregateResult ar : 
	      [SELECT Case__c, count(id) total FROM Checkoff_Junction__c WHERE Case__c IN : CaseIDs AND Ready_to_Close2__c != 'Yes' Group By Case__c]){
	    Id i = (Id) ar.get('Case__c');
	    Integer tot = (Integer) ar.get('total');
	    CaseStatusCount.put(i, tot);
	  }
	}
	//In order for this to work, Queue Name == Case_Checkoff__c.Name == Picklist Value 
	private void buildQueueNameToIdMap(){
		List<Group> myQueues = [SELECT Name, (SELECT Id,SobjectType FROM QueueSobjects WHERE SobjectType = 'Case') FROM Group WHERE type = 'Queue'];
		for (Group myQueue : myQueues){
			queueNametoID.put(myQueue.Name, myQueue.Id);
		}
	}
	
	private void updateCaseStatusAndInvolvedTeams (Map<Id, Checkoff_Junction__c> newIdToCheckOffJunctionMap, Map<Id, Checkoff_Junction__c> oldIdToCheckOffJunctionMap){
		Map<Id, Case> casesToUpdateMap = new Map<Id, Case>();
		
		for (Checkoff_Junction__c myCheckoffJunction : newIdToCheckOffJunctionMap.values()){
			Case myCase;
			if (casesToUpdateMap.containsKey(myCheckoffJunction.Case__c)){
				myCase = casesToUpdateMap.get(myCheckoffJunction.Case__c);
			}
			else{
				myCase = caseIDtoCase.get(myCheckoffJunction.Case__c);
			}
			String checkoffJunctionTeamName = CheckoffJunctionIDtoTeamNameMap.get(myCheckoffJunction.Id);
			if (myCase.Involved_Teams__c == null) myCase.Involved_Teams__c = '';
			if (!caseStatusCount.containsKey(myCheckoffJunction.Case__c)){
				if (myCase.OwnerId == queueNametoID.get('Troubleshooting Transport Queue')){
					// do whatever they want to do for when no team accepts ownership
				}
				else{
				  myCase.Status = 'Closed';
				}
			}
			//changed to involved
			if (myCheckoffJunction.Involvement_Needed__c != 'Owner'){
				if (oldIdToCheckOffJunctionMap.get(myCheckoffJunction.Id).Involvement_Needed__c == 'Owner' && myCase.OwnerId == queueNametoID.get(checkoffJunctionTeamName)){
					myCase.OwnerId = queueNametoID.get('Troubleshooting Transport Queue');
				}		 
			}
			if (myCheckoffJunction.Involvement_Needed__c == 'No'){
				if (checkoffJunctionTeamName != NULL && myCase.Involved_Teams__c.contains(checkoffJunctionTeamName)){
					myCase.Involved_Teams__c = myCase.Involved_Teams__c.replace(checkoffJunctionTeamName, '');				
				}
				// if the Case has one team that says it isn't okay to close, change the status to open...but only if the status is already New or Closed.
				// ie if the status is "Reply: Customer Email" do NOT change the status to open.
				if (caseStatusCount.containsKey(myCheckoffJunction.Case__c) && (myCase.Status == 'New' || myCase.Status == 'Closed')){
					myCase.Status = 'Open';
				}
			}
			if (myCheckoffJunction.Involvement_Needed__c == 'Yes (Not Owner)' || myCheckoffJunction.Involvement_Needed__c == 'Unknown' || myCheckoffJunction.Involvement_Needed__c == 'Owner'){
				if (caseStatusCount.containsKey(myCheckoffJunction.Case__c) && (myCase.Status == 'New' || myCase.Status == 'Closed')){
					myCase.Status = 'Open';
				}
				if (checkoffJunctionTeamName != NULL && !myCase.Involved_Teams__c.contains(checkoffJunctionTeamName)){
					myCase.Involved_Teams__c = myCase.Involved_Teams__c + ';' + checkoffJunctionTeamName;
				}
			}
			// Built in logic here incase the owner is transferred to a queue, and then transferred to an individual user, it wont be transferred back to the queue if checkoff junction is updated
			Set<Id> queueIDs = new Set<Id>();
			queueIDs.addAll(queueNametoID.values());
		  if (myCheckoffJunction.Involvement_Needed__c == 'Owner' && queueIDs.contains(myCase.OwnerId)){
		  	myCase.OwnerId = queueNametoID.get(checkoffJunctionTeamName);
		  }
		  casesToUpdateMap.put(myCheckoffJunction.Case__c, myCase);
		}
		update casesToUpdateMap.values();
	}
}
public class testCaseControllerExtension {

public List <Checkoff_Junction__c> chkJunc;

public boolean renderOwner;

public void getRenderOwner(){
	renderOwner = True;
	for (Checkoff_Junction__c ck : chkJunc){		
    	if (ck.Involvement_Needed__c == 'Owner') renderOwner = False;    	
	}
}

public Id troubleshootingQueueId = [SELECT Id, Name,(SELECT Id,SobjectType FROM QueueSobjects WHERE SobjectType = 'case') FROM Group WHERE type = 'Queue' and Name = 'Troubleshooting Transport Queue' LIMIT 1].Id;

public Id cid(){
	return cs.id;
}

//public id n;

//not used
public string getTime(){
	datetime myDateTime = datetime.now();
	string t = string.valueof(MyDateTime.format('MMMMMMMM d, yyyy'));
	string v = string.valueof(MyDateTime.format('hh:mm a'));
	return t + '<br/>' + v;
}

private final Case cs;
//private Case c2;

public testCaseControllerExtension(ApexPages.StandardController controller){
	this.cs = (Case)controller.getRecord();	
	//n = cid();
	chkJunc = [SELECT Id, Involvement_Needed__c, Case_Checkoff__r.Name, Additional_Comments__c, Ready_to_Close__c, Ready_to_Close2__c, LastModified__c, LastModifiedDate, LastModifiedById, LastModifiedBy.LastName, LastModifiedBy.FirstName from Checkoff_Junction__c WHERE Case__c = :cid() ORDER BY Case_Checkoff__r.Name Asc ];
	//c2 = [SELECT Id, OwnerId, Status FROM Case WHERE Id = :cid()];
	getRenderOwner();
}


//public List <Checkoff_Junction__c> chkJunc = [SELECT Id, Additional_Work_Required__c, Case_Checkoff__r.Name, Additional_Comments__c from Checkoff_Junction__c WHERE Case__c = :cid()];

public List<SelectOption> getallOptions(){
	List<SelectOption> all = new List<SelectOption>();
	all.add(new SelectOption('Unknown','Unknown'));
    all.add(new SelectOption('No','No'));
    all.add(new SelectOption('Yes (Not Owner)','Yes (Not Owner)'));
    all.add(new SelectOption('Owner','Owner', false));
    return all;
}

public List<SelectOption> getYNList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('No','No'));
        options.add(new SelectOption('Yes','Yes'));
        return options;
    }
    
public List<SelectOption> getInvolvementList() {
		List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Unknown','Unknown'));
        options.add(new SelectOption('No','No'));
        options.add(new SelectOption('Yes (Not Owner)','Yes (Not Owner)'));
	
	// if the owner is the troubleshooting queue, display owner as a field
	// if (c2.OwnerId == troubleshootingQueueId){
	
	if (renderOwner == True){        
        options.add(new SelectOption('Owner','Owner', false));
        return options;
    }
    // if the owner is NOT the troubleshooting queue, display owner as a NON SELECTABLE field
    else {    	
        options.add(new SelectOption('Owner','Owner', true)); 
        return options;
    }
}

public List<Checkoff_Junction__c> getChkJunc(){
	return chkJunc;
}


 public PageReference editTeams() {
 	PageReference nextPage = Page.testCase; 		
	//nextPage.setredirect(true);
	// bulid a copy of the junction relationships that we can revert to, should we cancel
	//chkJuncOld = chkJunc.deepClone(true);
	//build a copy of the case that we can revert to, should we cancel the changes
	//csOld = c2.clone(true, true);
	nextPage.setredirect(false);
	return nextPage; 
 }
 
  public PageReference saveTeams() {
  	//system.debug('is this working????');
  	//system.debug('csid: ' + cs.id);
  	//system.debug('n: ' + n);
  	
  	//c2 = [SELECT Id, OwnerId FROM Case WHERE Id = :cid()];    
 	//PageReference nextPage = new PageReference('/'+c2.id);
 	
 	//PageReference nextPage = new PageReference('http://www.google.com');
 	
 	
 	List<Checkoff_Junction__c>oldChkJunc = [SELECT Id, Involvement_Needed__c, Case_Checkoff__r.Name, Additional_Comments__c, Ready_to_Close__c, Ready_to_Close2__c from Checkoff_Junction__c WHERE Case__c = :cid() ORDER BY Case_Checkoff__r.Name Asc ];
 	Map<Id, Checkoff_Junction__c> oldMap = new Map<Id, Checkoff_Junction__c>();
 	
 	for (Checkoff_Junction__c cj : oldChkJunc){
 		oldMap.put(cj.Id, cj);
 	}
 	
 	List<Checkoff_Junction__c> chkToUpdate = new List<Checkoff_Junction__c>();
 	
 	for (Checkoff_Junction__c cj : chkJunc){
 		
   		if (cj.Involvement_Needed__c == 'No') cj.Ready_to_Close2__c = 'Yes';
    	if (cj.Involvement_Needed__c == 'Unknown') cj.Ready_to_Close2__c = 'No';    	    	
 		
 		Checkoff_Junction__c old = oldMap.get(cj.Id);
 		String newComments = cj.Additional_Comments__c;
 		if (newComments == NULL) newComments = '';
 		String oldComments = old.Additional_Comments__c;
 		if (oldComments == NULL) oldComments = '';
 		//see if anything has changed
 		if (cj.Involvement_Needed__c != old.Involvement_Needed__c || cj.Ready_to_Close2__c != old.Ready_to_Close2__c || newComments != oldComments){
 			chkToUpdate.add(cj);
 		}
 		//system.debug('New Comments Are: ' + newComments);
 		//system.debug('Old Comments Are: ' + oldComments);
 	}
 	update chkToUpdate;
 	//n = cid();
 	PageReference nextPage = new PageReference('/'+ cid());
 	nextPage.setredirect(false);
 	//update chkJunc;
	//nextPage.setredirect(true);
	return nextPage;
 }
 
 public PageReference cancelTeams() {
  	//cid();
    //c2 = [SELECT Id, OwnerId FROM Case WHERE Id = :cid()];
    //update chkJuncOld;
    //update csOld;
 	//PageReference nextPage = new PageReference('/'+c2.id);
 	PageReference nextPage = new PageReference('/'+ cid());
	//nextPage.setredirect(true);
	return nextPage; 
 }
 
 //Used for TeamA & TeamB button that may or may not be obsolete now
 //button to remove certain teams from junction table
 public PageReference teamPreBooking() {
 	List<Checkoff_Junction__c> obsoleteTeams = [SELECT Id, Involvement_Needed__c from Checkoff_Junction__c 
 												WHERE(
 													Case_Checkoff__r.Name = 'Air Fulfillment Process & Support' OR
 												 	Case_Checkoff__r.Name = 'Quality' OR
 												 	Case_Checkoff__r.Name = 'Regional Team' OR
 												 	Case_Checkoff__r.Name = 'Settlement & Reporting' OR
 												 	Case_Checkoff__r.Name = 'Ticketing & Schedule Change' OR
 												 	Case_Checkoff__r.Name = 'Training'											 	
 												)
 												AND Case__c = :cid()];
 	system.debug(obsoleteTeams.size());
 	
 	for (Checkoff_Junction__c cj : obsoleteTeams){
 		cj.Involvement_Needed__c = 'No';
 		cj.Ready_to_Close2__c = 'Yes';
 	}
 	update obsoleteTeams;
 	PageReference nextPage = new PageReference('/'+ cid());
 	return nextPage;
 }
 
 
 //Used for TeamA & TeamB button that may or may not be obsolete now
  public PageReference teamFulfillment() {
 	List<Checkoff_Junction__c> obsoleteTeams = [SELECT Id, Involvement_Needed__c from Checkoff_Junction__c 
 												WHERE(
 													Case_Checkoff__r.Name = 'Air Configuration & Pricing Research' OR
 												 	Case_Checkoff__r.Name = 'Airline Debit Memos' OR
 												 	Case_Checkoff__r.Name = 'Car Operations' OR
 												 	Case_Checkoff__r.Name = 'Commissions' OR
 												 	Case_Checkoff__r.Name = 'Fare Filing' OR
 												 	Case_Checkoff__r.Name = 'Regional Team' 											 	
 												)
 												AND Case__c = :cid()];

 	system.debug(obsoleteTeams.size());
 	
 	for (Checkoff_Junction__c cj : obsoleteTeams){
 		cj.Involvement_Needed__c = 'No';
 		cj.Ready_to_Close2__c = 'Yes';
 	}
 	update obsoleteTeams;
 	PageReference nextPage = new PageReference('/'+ cid());
 	return nextPage;
 }

public void UpdateRecords(){
 //public PageReference UpdateRecords() {
    // this simple line of code finds out which column was changed and update the 
    // relevant account record accordingly!
   
    //update chkJunc;
    getRenderOwner();
    //getChkJunc();
    //cid();
    //c2 = [SELECT Id, OwnerId FROM Case WHERE Id = :cid()];       
    //return null;
    //PageReference test = new PageReference ('http://www.google.com');
    //return test;
    //PageReference nextPage = new PageReference('/'+c2.id);
	//nextPage.setredirect(true);
	//return nextPage;
    
  }
  /**
  
  TEST METHODS
  
  **/
  private static testMethod void TestCaseControllerExtension() {
  	
  	Id rId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Troubleshooting' limit 1].id;
  	Case cs = new Case(Subject = 'Test Case', RecordTypeId = rId, Status = 'New');
	insert cs;
  	 	
  	ApexPages.StandardController stdCon = new ApexPages.StandardController(cs);
  	testCaseControllerExtension contTest = new testCaseControllerExtension(stdCon);
  	
  	Id qId = contTest.troubleshootingQueueId;
  	
  	contTest.getRenderOwner();
  	contTest.getTime();
  	contTest.cid();
  	
  	contTest.getallOptions();
  	contTest.getYNList();
  	contTest.getInvolvementList();
  	contTest.getChkJunc();
  	contTest.editTeams();
  	contTest.saveTeams();
  	contTest.cancelTeams();
  	contTest.teamPreBooking();
  	contTest.teamFulfillment();
  	contTest.UpdateRecords();
  }

}
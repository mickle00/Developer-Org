public with sharing class troubleCaseControllerExtension {

    // Built out in the constructor
    public List <Checkoff_Junction__c> checkoffJunctions;
    
    // Whether or not the Owner is rendered as an available picklist option
    //public boolean renderOwner;
    
    public boolean hasOwner{get;}
    
    public boolean hasOwner(){
    for (Checkoff_Junction__c myCheckoffJunction : checkoffJunctions){    
     if (myCheckoffJunction.Involvement_Needed__c == 'Owner') return true;     
    }
        return false;
    }
    
    /**
    // Update  to see if Owner has been selected by any team
    public void getRenderOwner(){
      renderOwner = True;
      for (Checkoff_Junction__c myCheckoffJunction : checkoffJunctions){    
          if (myCheckoffJunction.Involvement_Needed__c == 'Owner') renderOwner = False;     
      }
    }
    
    **/
    //public Id troubleshootingQueueId = [SELECT Id, Name,(SELECT Id,SobjectType FROM QueueSobjects WHERE SobjectType = 'case') FROM Group WHERE type = 'Queue' and Name = 'Troubleshooting Transport Queue' LIMIT 1].Id;
    
    private final Case finalCase;
    
    public Id getCaseId(){
      return finalCase.id;
    }
    
    public troubleCaseControllerExtension(ApexPages.StandardController controller){
      this.finalCase = (Case)controller.getRecord(); 
      // TODO
      checkoffJunctions = [SELECT Id, Involvement_Needed__c, Case_Checkoff__r.Name, Additional_Comments__c, Ready_to_Close__c, Ready_to_Close2__c, LastModified__c, LastModifiedDate, LastModifiedById, LastModifiedBy.LastName, LastModifiedBy.FirstName from Checkoff_Junction__c WHERE Case__c = :getCaseId() ORDER BY Case_Checkoff__r.Name Asc ];
      //getRenderOwner();
    }
        
    // All Options for the Involvement Needed Picklist
    public List<SelectOption> getallOptions(){
    List<SelectOption> all = new List<SelectOption>();
          all.add(new SelectOption('Unknown','Unknown'));
          all.add(new SelectOption('No','No'));
          all.add(new SelectOption('Yes (Not Owner)','Yes (Not Owner)'));
        all.add(new SelectOption('Owner','Owner', false));
    return all;
    }
        
    // All Options, with Owner grayed out if it has already been selected, or selectable if it hasn't already been selected
  public List<SelectOption> getInvolvementList() {
    List<SelectOption> options = new List<SelectOption>();
      options.add(new SelectOption('Unknown','Unknown'));
      options.add(new SelectOption('No','No'));
      options.add(new SelectOption('Yes (Not Owner)','Yes (Not Owner)'));     
      
      if (this.hasOwner() == true){        
      options.add(new SelectOption('Owner','Owner', true));
      return options;
      }    
        // if the owner is NOT the troubleshooting queue, display owner as a NON SELECTABLE field
        else {      
      options.add(new SelectOption('Owner','Owner', false)); 
        return options;
        }
    }
    
    // Yes or No for the Ready to Close field. By manually building it out in the controller we get rid of the "---None---" option.
  public List<SelectOption> getYNList() {
    List<SelectOption> options = new List<SelectOption>();
      options.add(new SelectOption('No','No'));
      options.add(new SelectOption('Yes','Yes'));
    return options;
  }

  public List<Checkoff_Junction__c> getCheckoffJunctions(){
    return checkoffJunctions;
    }
    
    // Go to the Edit Page
    public PageReference editTeams() {
      PageReference nextPage = Page.troubleshootingCaseEditPage;     
      nextPage.setredirect(false);
      return nextPage; 
  }
    
  // Save the InvolvementNeeded Page and return to the Case
  public PageReference saveTeams() {      
    List<Checkoff_Junction__c> oldCheckoffJunctions = [SELECT Id
                                                             ,Involvement_Needed__c
                                                             ,Case_Checkoff__r.Name
                                                             ,Additional_Comments__c
                                                             ,Ready_to_Close__c
                                                             ,Ready_to_Close2__c 
                                                         FROM Checkoff_Junction__c 
                                                        WHERE Case__c = :finalCase.Id 
                                                     ORDER BY Case_Checkoff__r.Name Asc];
                                                     
      Map<Id, Checkoff_Junction__c> oldCheckoffJunctionIdtoCheckoffJunctionMap = new Map<Id, Checkoff_Junction__c>();
      
      for (Checkoff_Junction__c myOldCheckoffJunction : oldCheckoffJunctions){
        oldCheckoffJunctionIdtoCheckoffJunctionMap.put(myOldCheckoffJunction.Id, myOldCheckoffJunction);
      }
      
      List<Checkoff_Junction__c> checkoffJunctionsToUpdate = new List<Checkoff_Junction__c>();
      
      for (Checkoff_Junction__c currentCheckoffJunction : checkoffJunctions){
      if (currentCheckoffJunction.Involvement_Needed__c == 'No') {
        currentCheckoffJunction.Ready_to_Close2__c = 'Yes';
      }
        if (currentCheckoffJunction.Involvement_Needed__c == 'Unknown') {
            currentCheckoffJunction.Ready_to_Close2__c = 'No';            
        }
        Checkoff_Junction__c oldCheckoffJunction = oldCheckoffJunctionIdtoCheckoffJunctionMap.get(currentCheckoffJunction.Id);
        String newComments = currentCheckoffJunction.Additional_Comments__c;
        if (newComments == NULL) newComments = '';
        String oldComments = oldCheckoffJunction.Additional_Comments__c;
        if (oldComments == NULL) oldComments = '';
        //see if anything has changed
        if ((currentCheckoffJunction.Involvement_Needed__c != oldCheckoffJunction.Involvement_Needed__c) || 
           (currentCheckoffJunction.Ready_to_Close2__c != oldCheckoffJunction.Ready_to_Close2__c) || 
           (newComments != oldComments)){
          checkoffJunctionsToUpdate.add(currentCheckoffJunction);
        }
      }
      update checkoffJunctionsToUpdate; 
      return reloadPage(false);
  }
     
     // Cancel any of the edits since the last save
  public PageReference cancelTeams() {
    return reloadPage(false);
  }
     
  //Used for Team PreBooking Button
    //button to remove certain teams from junction table
  /**
  public PageReference teamPreBooking() {
    List<Checkoff_Junction__c> obsoleteTeams = [SELECT Id, Involvement_Needed__c 
                                                FROM Checkoff_Junction__c 
                                                WHERE(
                                                                                  Case_Checkoff__r.Name = 'Air Fulfillment Process & Support' OR
                                                                                  Case_Checkoff__r.Name = 'Quality' OR
                                                                                  Case_Checkoff__r.Name = 'Regional Team' OR
                                                                                  Case_Checkoff__r.Name = 'Settlement & Reporting' OR
                                                                                  Case_Checkoff__r.Name = 'Schedule Change' OR
                                                                                  Case_Checkoff__r.Name = 'Ticketing' OR
                                                                                  Case_Checkoff__r.Name = 'Training'                        
                                                                        )
                                                                        AND Case__c = :getCaseId()];
      
    for (Checkoff_Junction__c myCheckoffJunction : obsoleteTeams){
      myCheckoffJunction.Involvement_Needed__c = 'No';
      myCheckoffJunction.Ready_to_Close2__c = 'Yes';
      }
      update obsoleteTeams;
      PageReference nextPage = new PageReference('/'+ getCaseId());
      return nextPage;
  }
  **/
  
  public PageReference teamPreBooking(){        
    removeObsoleteTeams(new List<String>{'Training', 'Ticketing', 'Air Fulfillment Process & Support', 'Quality', 'Settlement & Reporting', 'Regional Team', 'Schedule Change'});
    return reloadPage(false);
  }

     
    //Used for Team Fulfillment button
    public PageReference teamFulfillment() {
    removeObsoleteTeams(new List<String>{'Air CPR', 'ADM', 'CarOps', 'Commissions', 'Fare Filing', 'Regional Team'});
        return reloadPage(false);
    }
    
    public string getCSSStyle(Checkoff_Junction__c myCheckoffJunction){
        if(myCheckoffJunction.Involvement_Needed__c == 'Yes (Not Owner)' || myCheckoffJunction.Involvement_Needed__c == 'Owner'){
            return 'workingTeam';
        }
        else{
            return 'nonWorkingTeam';
        }
    }
    
    /**
    public PageReference teamFulfillment() {
    List<Checkoff_Junction__c> obsoleteTeams = [SELECT Id, Involvement_Needed__c 
                                                FROM Checkoff_Junction__c 
                                                                        WHERE(
                                                                          Case_Checkoff__r.Name = 'Air CPR' OR
                                                                          Case_Checkoff__r.Name = 'ADM' OR
                                                                          Case_Checkoff__r.Name = 'CarOps' OR
                                                                          Case_Checkoff__r.Name = 'Commissions' OR
                                                                          Case_Checkoff__r.Name = 'Fare Filing' OR
                                                                          Case_Checkoff__r.Name = 'Regional Team'                         
                                                                        )
                                                                        AND Case__c = :getCaseId()];
    
      
    for (Checkoff_Junction__c myCheckoffJunction : obsoleteTeams){
      myCheckoffJunction.Involvement_Needed__c = 'No';
      myCheckoffJunction.Ready_to_Close2__c = 'Yes';
    }
      update obsoleteTeams;
      
      
      PageReference nextPage = new PageReference('/'+ getCaseId());
      return nextPage;
  }
  **/
    
    //incase we want to do anything else when page is refreshsed/updated
    public void UpdateRecords(){
    //getRenderOwner();
    //this.getInvolvementList();   
  }
  
  /**
  
  PRIVATE METHODS
  
  **/
  
  private PageReference reloadPage(boolean setRedirect){
    PageReference nextPage = new PageReference('/'+ getCaseId());
    if (setRedirect == true) nextPage.setredirect(true);
    if (setRedirect == false) nextPage.setredirect(false);
    return nextPage;
  }  
  
  private void removeObsoleteTeams(List<String> myObsoleteTeams){
    string queryWhere = '';
    if (myObsoleteTeams.size() == 1){
        queryWhere = 'Case_Checkoff__r.Name = \'' + myObsoleteTeams[0] + '\'';
    }
    if (myObsoleteTeams.size() > 1){
        Integer teamCount = 1;
        for (String teamName : myObsoleteTeams){
         queryWhere = queryWhere + 'Case_Checkoff__r.Name = \'' + teamName + '\''; // + '\'OR ';
         if (teamCount < myObsoleteTeams.size()){
          queryWhere = queryWhere + 'OR ';
         }
         teamCount = teamCount + 1;
      }
    //queryWhere = queryWhere.substring(0,queryWhere.length()-3);
    }
    //Wrapping this in a try/catch method.....better safe than sorry
    try{
        List<Checkoff_Junction__c> obsoleteCheckoffJunctions = Database.query('SELECT Id, Involvement_Needed__c FROM Checkoff_Junction__c WHERE (' + queryWhere + ')AND Case__c = \'' + getCaseId() + '\'');                                                               
      
        for (Checkoff_Junction__c myCheckoffJunction : obsoleteCheckoffJunctions){
          myCheckoffJunction.Involvement_Needed__c = 'No';
          myCheckoffJunction.Ready_to_Close2__c = 'Yes';
        }
        update obsoleteCheckoffJunctions;
    } catch (Exception e){
        system.debug ('troubleshootingCaseControllerExtension Error: ' + e + 'Case #: ' + getCaseId());
    }
  }
  
  /**
  
  TEST METHODS
  
  **/
      
  private static testMethod void testTroubleshootingCaseControllerExtension() {     
    Id rId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Troubleshooting' limit 1].id;
      Case cs = new Case(Subject = 'Test Case', RecordTypeId = rId, Status = 'New');
      insert cs;
          
      ApexPages.StandardController stdCon = new ApexPages.StandardController(cs);
      troubleCaseControllerExtension contTest = new troubleCaseControllerExtension(stdCon);
        
      //Id qId = contTest.troubleshootingQueueId;
        
    //contTest.getRenderOwner();
    contTest.getCaseId();
    
    contTest.getallOptions();
    contTest.getYNList();
    contTest.getInvolvementList();
    contTest.getCheckoffJunctions();
    contTest.editTeams();
    contTest.saveTeams();
    contTest.cancelTeams();
    contTest.teamPreBooking();
    contTest.teamFulfillment();
    contTest.UpdateRecords();
    
    //build in assertions
  }
}
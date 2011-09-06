public class CaseClass {
  public Map<String,Contact> createdContactsByEmail = new Map<String,Contact>(); 
  public Map<String,Contact> existingContacts = new Map<String,Contact>();
  public Map<String,String> casePriority = new Map<String,String>();
  public Map<String,Id> emailContactId = new Map<String,Id>();
  public Map<String,Id> emailAccountId = new Map<String,Id>();
  public Map<String,Id> nameToQueueId = new Map<String,Id>(); 

  //____________________________________________________
  public Map<String,List<Account_Contact__c>> emailToListOfAccountContacts = new Map<String,List<Account_Contact__c>>();
  public Map<String,List<Contact>> emailToListOfContacts = new Map<String,List<Contact>>(); 
  //----------------------------------------------------
    
  public String sfdcURL = 'https://na8.salesforce.com/'; // CHANGE Per environment
  public CaseClass(){}
    
  public Case processEmail(Messaging.Inboundemail email, String recordType) {
        
    Case myCase = new Case();
    EmailMessage newEmail = new EmailMessage();
    Map<String,RecordType> mapRecordTypes = Utilities.getRecordTypesMap('Case');
      
    EmailMessageClass objEmail = new EmailMessageClass();
    TaskClass objTask = new TaskClass();  
    Id replyEmailCaseParentId = objTask.getTaskParentId(email.subject); 
        
    if(replyEmailCaseParentId != null) { // creat new email message object  
      myCase = this.updateCase(replyEmailCaseParentId, email);	
    }
    else{ // New Case  
    	myCase = this.insertCase(email,recordType, mapRecordTypes);  
    }
    
    if(myCase != null){ //handle any attachments
      EmailUtilities objEmailUtilities = new EmailUtilities();
      objEmailUtilities.saveAttachmentsToCaseFromInboundEmail(email, myCase.Id);            
    }
    return myCase;
  }
       
  public void linkAccountAndContactToCase(Case[] cases){
        
    system.debug('>>>> linkAccountAndContactToCase size = ' + cases.size());
        
    ContactClass objContact = new ContactClass();
    AccountContactClass objAccountContact = new AccountContactClass();
    List<Case> casesToCreate = new List<Case>();
      
      // 1.) Get Set of all the emails in the incoming cases
      Set<String> suppliedEmails = new Set<String>(this.getSuppliedEmails(cases));
      
      // 2.) Get a map with email, supplied name for parsing into fname and lname
      Map<String,String> suppliedEmailsAndNames = new Map<String,String>(this.getSuppliedEmailsAndNames(cases));
      
      Set<String> emailContactKeys = new Set<String>(EmailUtilities.getEmailContactKeys(cases)); 
      
      // 3.) Get All existing contacts <Email, Contact>
      //existingContacts = objContact.getExistingContacts(suppliedEmails);
      emailToListOfContacts = objContact.getExistingContacts(suppliedEmails);
      
      // Set of all matching emails in contact table
      Set<String> existingContactEmails = new Set<String>(emailToListOfContacts.keySet());
       
      // 4.) Get a List of contacts that need to be added
      List<Contact> contactsToCreate = new List<Contact>(objContact.getContactsToCreate(suppliedEmails, suppliedEmailsAndNames, existingContactEmails));
      
      system.debug('<<<<<<<<<<<<<before contact to create>>>>>>>>>>>');
      try{ //insert new contacts
        
        insert contactsToCreate;
      }
      catch (system.Dmlexception e) {
        system.debug('DML Exception >>> ' + e.getMessage());
        return;
      }
      
      // 5.) add new contacts to map of existing contacts
      for(Contact c : contactsToCreate){
        List<Contact> newContact = new List<Contact>();
        newContact.add(c);
        emailToListOfContacts.put(c.Email,newContact);
        createdContactsByEmail.put(c.Email,c);
      }
        
      // 6.)  Get a map of all emails and the number of times found in AccountContacts
      Map<String,Integer> emailCount = new Map<String,Integer>();   
      emailCount = objAccountContact.getEmailCountsForEmails(suppliedEmails);
    
      // 7.)  Get a list of all AccountContact Records, Contact Id, Account Id, Case Priority for All Emails
      List<Account_Contact__c> matchingAccountContacts = objAccountContact.getAllByContactEmail(suppliedEmails);
      
      // 7a.) Get a map of email to list of account contacts
      emailToListOfAccountContacts = objAccountContact.getEmailToListOfAccountContacts(matchingAccountContacts);
      
      // 8.) Query the AccountContactTable for contacts with this email address
      for (Account_Contact__c accountContact : matchingAccountContacts) {
        
        //TODO: TO CHANGE METHOD NAME
        this.editMaps(accountContact);   
      }
      
      for (Case thisCase : cases){
        
        // get Contacts from Map to iterate over them 
        system.debug('>>>>>> CASE CLASS inside Case LOOP');
        system.debug('>>>> SUPPLIED EMAIL IS = ' + thisCase.suppliedEmail); 
        //system.debug('Size of loop is' + emailToListOfContacts.get(thisCase.suppliedEmail).size());           
        system.debug('Existing Contacts is  ' + existingContacts);     
      
        //this loop has 0 items in it...         
        for(Contact c : emailToListOfContacts.get(thisCase.suppliedEmail)){

          system.debug ('CONTACT PRIORITY = >>>>>>>' + c.Case_Priority__c);
          String contactPriority = c.Case_Priority__c;          
          String accountPriority = casePriority.get(c.email);
        
          if(!casePriority.containsKey(c.email) || casePriority.get(c.email) == NULL || casePriority.get(c.email) == '') { //mps
              casePriority.put(c.email,c.Case_Priority__c);
          }
          else {
              if(contactPriority != null) {
                  try {
                      if(integer.valueOf(contactPriority) < integer.valueOf(accountPriority)){
                        CasePriority.put(c.email,c.Case_Priority__c);
                      }
                  }
                catch (TypeException e) {
                    system.debug('Exception: ' + e);
                }
              }
          }
        }
        // Get the size of the list of contacts for the email
        Integer contactListSize = emailToListOfContacts.get(thisCase.suppliedEmail).size();
        
        // get the list of contacts by email and check size of list 
        if(contactListSize == 0) {
            // do something
            system.debug('Why dont we have a contact?');
        }
        else {
          if (casePriority.get(thisCase.SuppliedEmail) != NULL) thisCase.Priority = casePriority.get(thisCase.SuppliedEmail); //mps
          Integer accountContactListSize = 0;
          system.debug('*** CaseClass.LinkAccountsAndContacts' + emailToListOfAccountContacts.get(thisCase.suppliedEmail));
          if(emailToListOfAccountContacts.get(thisCase.suppliedEmail) != null) {
            accountContactListSize = emailToListOfAccountContacts.get(thisCase.suppliedEmail).size();
          }
            
          if(contactListSize == 1) {
            thisCase.ContactId = emailToListOfContacts.get(thisCase.suppliedEmail)[0].Id;               
            
            if(accountContactListSize == 0) {
              thisCase.Contact_Account_Lookup_Results__c = 'No Account Contacts';   
            }
            else if(accountContactListSize == 1) {
                thisCase.AccountId = emailToListOfAccountContacts.get(thisCase.suppliedEmail)[0].Account__c;
                thisCase.Contact_Account_Lookup_Results__c = 'Only One Match Found; Linked'; //MPS Added
            }
            else { // List of account contacts 
                
                // Build out web lookup status field to display possible accounts per contact
                thisCase.Contact_Account_Lookup_Results__c = this.buildAccountContactPossiblesText(emailToListOfAccountContacts.get(thisCase.suppliedEmail));
            }
          }
          
          /** MPS ADDED  **/          
          if(contactListSize > 1) {
          	if(accountContactListSize > 0){         	    	
             	thisCase.Contact_Account_Lookup_Results__c = this.buildAllPossiblesText(emailToListOfAccountContacts.get(thisCase.suppliedEmail), emailToListofContacts.get(thisCase.suppliedEmail));
          	}else{
            	List<Account_Contact__c> noAC = new List<Account_Contact__c>(); 
            	thisCase.Contact_Account_Lookup_Results__c = this.buildAllPossiblesText(noAC, emailToListofContacts.get(thisCase.suppliedEmail));            	           	
            }
          }
          /** MPS ADDED  **/          
        }
      } // END Case Loop
      system.debug('End of time size of loop is' + existingContacts.values().size());
    } // END linkAccountAndContactToCase
    
    /////// Private Methods  
    
    private Case insertCase(Messaging.InboundEmail email, String recordType, Map<String,RecordType> mapRecordTypes) {
    	
    	String plainTextEmailRecipientsList = EmailUtilities.buildEmailRecipientsText(email.toAddresses, email.ccAddresses, '\n');
    	String htmlBodyEmailRecipientsList = EmailUtilities.buildEmailRecipientsText(email.toAddresses, email.ccAddresses, '<br/>');
    	
    	String plainTextDescription = plainTextEmailRecipientsList + email.plainTextBody;
    	if (plainTextDescription.length() > 32000) plainTextDescription = Utilities.truncateField(plainTextDescription, 32000, '\n');
    	String richTextDescription = htmlBodyEmailRecipientsList + email.htmlBody;
    	if (richTextDescription.length() > 32000) richTextDescription = Utilities.truncateField(richTextDescription, 32000, '<br/>');
    	    	
    	Case myCase = new Case(Description = plainTextDescription
    	                      ,Subject = email.subject
    	                      ,SuppliedEmail = email.fromAddress
    	                      ,SuppliedName = email.fromName
    	                      ,RecordTypeId = mapRecordTypes.get(recordType).Id
    	                      ,Origin = 'Email'
    	                      ,Description_Rich_Text__c = richTextDescription
    	                      //MPS ADDED
    	                      ,Email_Recipients__c = EmailUtilities.buildEmailRecipientsField(email.toAddresses, email.ccAddresses));
    	
      database.DMLOptions dmo = new database.DMLOptions();
        
      AssignmentRule[] ar = [SELECT Id 
                               FROM AssignmentRule 
                              WHERE Active = True];
                               
      if(ar.size() != 0) {
        dmo.AssignmentRuleHeader.assignmentRuleId = ar[0].Id;
      }
      
      dmo.AssignmentRuleHeader.useDefaultRule = false;
      dmo.EmailHeader.triggerUserEmail = false;
      dmo.EmailHeader.triggerAutoResponseEmail = false;

      myCase.setOptions(dmo);

      try {
        insert myCase;
        // Requery the DB to get the new case number.
        // STUPID that we have to do this.
        // How can we return the new case number when record is inserted
        myCase = this.getCase(myCase.Id);
                   
        system.debug('*** CaseClass.CreateCase => RecordType = ' + myCase.RecordType.DeveloperName + ' ***');
                
        String subject = 'Thank you for contacting Expedia Support.  Case Number: ' + myCase.CaseNumber + ' ' + Utilities.getCaseThreadId(myCase.Id);
        //String plainTextBody = this.getCaseAutoResponseEmailBodyText(myCase.CaseNumber,myCase.RecordType.DeveloperName);
        
        String plainTextBody = this.getNewCaseAutoResponseEmailText(myCase.caseNumber, myCase.Id, recordType, 
          email.toAddresses, email.ccAddresses, email.plainTextBody, email.subject);
          
        
        if(!EmailUtilities.suppressSpamEmails(email.fromAddress) && !EmailUtilities.suppressEmailAutoResponse(email.fromAddress)) { // Do not reply to Closed-Spam known email addresses
          system.debug('*** CaseClass.CreatCase sending auto response for RecordType => ' + recordType + ' ***');
        	system.debug('*** CaseClass.CreatCase sending auto response for ReplyToAlias => ' + EmailUtilities.getExpediaReplyToAlias(recordType) + ' ***');
        	system.debug('*** CaseClass.CreatCase sending auto response for ReplyToAliasName => ' + EmailUtilities.getExpediaReplyToAliasName(recordType) + ' ***');
        	
          EmailUtilities.sendSingleEmailMessage(new String[] {email.fromAddress}, new String[]{}, 
            EmailUtilities.getExpediaReplyToAlias(recordType), 
            EmailUtilities.getExpediaReplyToAliasName(recordType), plainTextBody, subject, null);
            
            // MPS MOVED TO WITHIN THE IF LOOP 5/3/11. DON'T WANT TO BE LOGGING EMAIL/TASKS FOR AUTO-RESPONSES 
            // WHICH WE DON'T SEND
            
        	system.debug('*** CaseClass.CreateCase => Before Create Task ***');
        	// create a task for auto response
        	TaskClass objTask = new TaskClass();
        	objTask.createTask(myCase.Id, myCase.ContactId, myCase.CreatedById, plainTextBody, subject,
          		'Completed', system.today());
        
        	system.debug('*** CaseClass.CreateCase => Before Create EmailMessage ***');
        	// log the auto repsonse message as an email message on the case
        	EmailMessageClass objEmail = new EmailMessageClass();
        	objEmail.createEmailMessage(myCase.Id, subject, 'donotreply.gso@expedia.com', 
          		'Expedia GSO', email.fromAddress, plainTextBody, EmailMessageClass.enumEmailStatus.sent, false);
        }
      }
      catch (system.Dmlexception dmlE) {
        system.debug('*** CaseClass.CreateCase After case Insert. DML Exception ' + dmlE.getMessage() + ' ***');
      }
      catch (Exception e) {
        system.debug('*** CaseClass.CreateCase After case Insert. Exception ' + e.getMessage() + ' ***');
      }
      
      return myCase;
    }
    
    private Case updateCase(Id caseId, Messaging.InboundEmail email) {
    	
    	// get parent case      
      Case myCase = this.getCase(caseId);
        
      //update status to reflect reply email                        
      myCase.Status = 'Reply: Customer Email';
        
      // create a task
      TaskClass objTask = new TaskClass();
      objTask.createTask(myCase.Id, myCase.ContactId, myCase.CreatedById, email.plainTextBody, 
        email.subject,'Completed',system.today());
        
      // log the email message
      EmailMessageClass objEmail = new EmailMessageClass();
      objEmail.createEmailMessage(myCase.Id, email.subject, email.fromAddress, email.fromName, '',
        email.plainTextBody, EmailMessageClass.enumEmailStatus.replied, true);
        
      update myCase;
      
      return myCase;
    	
    }   

    private void editMaps(Account_Contact__c accountContact) {
       // add the contacts id to the map emailcid with email address as the key
         this.emailContactId.put(accountContact.contact__r.email, accountContact.contact__c);
            // add the account id to the map emailaid with email address as the key
         this.emailAccountId.put(accountContact.contact__r.email, accountContact.account__c);
            // add the priority to the map. Because priority are queried desc, the last item should always be the lowest (1) priority
            // the NULLS FIRST part of the SOQL doesn't appear to be working because the value is transversed via a relationship query, so I'll simply weed out the NULLs...that wasn't very fun to troubleshoot        
            //system.debug('The account rating is ' + ac.account__r.rating);
         if (accountContact.account__r.rating != NULL) this.casePriority.put(accountContact.contact__r.email, accountContact.account__r.rating);        
        
    }
    
    private Map<String,Case> getSuppliedEmailsAndCases(Case[] cases){
        
      Map<String,Case> suppliedEmailsAndCases = new Map<String,Case>();
      for(Case c : cases) {
        suppliedEmailsAndCases.put(c.suppliedEmail,c);
      }
      return suppliedEmailsAndCases;
      
    } 
    
    private Map<String,String> getSuppliedEmailsAndNames(Case[] cases){
    
        Map<String,String> suppliedEmailsAndNames = new Map<String,String>();
        for(Case myCase : cases){
            if(myCase.SuppliedEmail != null && !suppliedEmailsAndNames.containsKey(myCase.SuppliedEmail)){
              suppliedEmailsAndNames.put(myCase.SuppliedEmail, myCase.SuppliedName);
            }
        }
        return suppliedEmailsAndNames;
    }
    
    
    private Set<String> getSuppliedEmails(Case[] cases){
        Set<String> suppliedEmails = new Set<String>();
        for(Case thisCase : cases) {
          if(thisCase.SuppliedEmail != null){
              system.debug('>>>>>> CaseClass.getSuppliedEmails Case Id = ' + thisCase.Id );
            suppliedEmails.add(thisCase.SuppliedEmail);
          } 
      }
        return suppliedEmails;
    }
   
    private Map<String,Integer> getEmailCount(Set<String> allEmails){
      List<AggregateResult> emailCountList = [Select Contact__r.Email,count(id) Total
                                                From Account_Contact__c
                                               Where Contact__r.Email IN :allEmails
                                               Group By Contact__r.Email
                                               Order by count(id) asc];
      
      Map<String,Integer> emailCounts = new Map<String,Integer>();
      
      for(AggregateResult ar : emailCountList){
        String email = (String) ar.get('Email');
        Integer total = (Integer) ar.get('Total');
        emailCounts.put(email,total);
      }
      return emailCounts;
        
    }
        
    private void singleAccountContactForEmail(Case myCase) {
        myCase.Priority = casePriority.get(myCase.suppliedEmail);
        // get contact id
        myCase.ContactId = emailContactId.get(myCase.suppliedEmail);
            // assign the account id
        myCase.AccountId = emailAccountId.get(myCase.suppliedEmail);
            // update status to show only one row was found
        myCase.Contact_Account_Lookup_Results__c = 'Only one match found; linked ' + String.valueOf(Date.today());
        
    }
    
    /** MPS ADDED  **/
    private String buildAllPossiblesText(List<Account_Contact__c> myAccountContacts, List<Contact> myContacts) {        
        String returnText;
        Id cid;
        returnText = Utilities.appendToString(returnText, '<Strong><i><u>Multiple Possibilities: </u></i></strong><br><ul>');
        for(Contact contact : myContacts){          
            cid = contact.id;           
            returnText = Utilities.appendToString(returnText, this.buildMultipleContactText(contact));
            returnText = Utilities.appendToString(returnText, '<ul>');          
            for(Account_Contact__c accountContact : myAccountContacts){             
                if (accountContact.Contact__c == cid){          
                    returnText = Utilities.appendToString(returnText,
                    this.buildMultipleAccountContactText(accountContact));                  
                }           
            }
             returnText = Utilities.appendToString(returnText, '</ul>');                                 
        }       
        return returnText; 
    }   
    /** MPS ADDED  **/
    
    private String buildAccountContactPossiblesText(List<Account_Contact__c> myAccountContacts) {
        
        String returnText;
        // Handles the account contact mapping
        //returnText = myAccountContacts.size() + ' possible Accounts found.' +
        //'<br/><br/><strong><u>Possibilities Include:</u></strong><ol>';
        for(Account_Contact__c accountContact : myAccountContacts){
          returnText = Utilities.appendToString(returnText,
            this.buildMultipleAccountContactText(accountContact)); 
        }
        return returnText;  // = Utilities.appendToString(returnText,'</ol>');
    }
    
    private String getEmailHtmlBodyText(String emailHtmlBody, String plainTextBody) {
    	
      String htmlBody = '';
      if(emailHtmlBody == null) {
    	  htmlBody = plainTextBody;
      }
      else {
    	  htmlBody = emailHtmlBody;
      }
      return htmlBody;
      
    }
    
    private void noAccountContactForEmail(Case myCase){
        //ToDo
        myCase.ContactId = existingContacts.get(myCase.SuppliedEmail).Id;
        myCase.Contact_Account_Lookup_Results__c = createdContactsByEmail.containsKey(myCase.suppliedEmail) ? 'New contact created.' : 'Contact has no associated accounts.';
    }
    
    private String buildMultipleAccountContactText(Account_Contact__c accountContact) {
        //String contactURL = sfdcURL + accountContact.Contact__c;
        String accountURL = sfdcURL + accountContact.Account__c;
        
        return '<li><a href="' + accountURL + '">' + accountContact.Account__r.Name + '</li>';
        
    }
    
    private String buildMultipleContactText(Contact contact) {
        String contactURL = sfdcURL + contact.Id;
        String fullname;
        if (contact.FirstName == NULL){
        	fullname = contact.LastName;
        }
        else{
        	fullname = contact.FirstName + ' ' + contact.LastName;
        }
           
        return '<li><a href="' + contactURL + '">' + fullname + '</li>';       
    }
        
    private String getNewCaseAutoResponseEmailText(String caseNumber, Id caseId, String recordType, String[] toAddresses,
      String[] ccAddresses, String plainTextBody, String subject) {
    	
    	String teamSignature = 'Expedia Support';
    	
    	if (recordType == 'Geography') teamSignature = 'Expedia Geography Team';
    	if (recordType == 'Destination_Services') teamSignature = 'Destination Services Content Team';
    	if (recordType == 'Ticketing') teamSignature = 'GTP Support Team';
      if (recordType == 'Schedule_Change') teamSignature = 'ASC Support Team';
    	
    	return 'Thank you for contacting Expedia Support. A case has been created to help track your issue through its resolution.' +
    	       '\n\n' +
    	       'Your Case Number is: ' + caseNumber +'.' +
    	       '\n\n' +
    	       'Thank you,' +
    	       '\n\n' +
             teamSignature + '\n\n' +
             '* When sending us a reply, please ensure that the "Subject" of your email is unchanged ' + 
             'and includes the case reference number.\n\n' +
             '------------------Your Request----------------------\n\n' +
             'To: ' + this.getAutoResponseEmailAddresses(toAddresses) + '\n' +
             'CC: ' + this.getAutoResponseEmailAddresses(ccAddresses) + '\n' +
             'Subject: ' + subject + '\n' +  
             '\n' + plainTextBody +
             '\n\n\n\n' + Utilities.getCaseThreadId(caseId);
    }
    
    private String getAutoResponseEmailAddresses(String[] emailAddresses) {
      if(emailAddresses == null) return '';
      
      String finalEmailAddresses = '';
      
      for(String emailAddress : emailAddresses) {
      	if(finalEmailAddresses == '') {
      		finalEmailAddresses = emailAddress;
      	}
      	else {
      		finalEmailAddresses = finalEmailAddresses + '; ' + emailAddress;
      	}     	
      }
      return finalEmailAddresses;
    }
    
    private Case getCase(Id caseId) {
      return [Select Id
                    ,Status
                    ,OwnerId
                    ,CreatedById
                    ,ContactId
                    ,Case.RecordType.DeveloperName
                    ,CaseNumber
                From Case
               Where Case.Id = :caseId]; 
    }
}
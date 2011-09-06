public with sharing class EmailUtilities {
	
	public EmailUtilities() {}
		
	public static Set<String> getEmailContactKeys(Case[] cases){
		Set<String> emailContactKeys = new Set<String>();
		String firstName = '';
		String lastName = '';
		List<String> parsedSuppliedName = new List<String>();
		
		for(Case myCase : cases) {
			parsedSuppliedName = EmailUtilities.parseSuppliedName(myCase.suppliedName);
						
			if(parsedSuppliedName.size() == 1) {
      	  	lastName = parsedSuppliedName[0];
      		}
      		else {
        	firstName = parsedSuppliedName[0];
      		lastName = parsedSuppliedName[1];
      		}
			
		  emailContactKeys.add(Utilities.generateIntegrationContactKey(myCase.suppliedEmail,firstName,lastName));
		}
		
		return emailContactkeys;
	}
	
	public static List<String> parseSuppliedName(String suppliedName){
	  List<String> parsedName = new List<String>();
	  
	  system.debug('>>>> EmailUtilities.parseSuppliedName(String suppliedName = ' + suppliedName + ')');
	  if (suppliedName != NULL && suppliedName != '') {
	  	List<String> nameparts = suppliedName.split(' ', 2);
	    
	    for(String namepart : nameparts) {
	      parsedName.add(namepart);
	    }
	  }
	  else {
	  	parsedName.add('NoName');
	  }
	  return parsedName;   	
	}
	
	public static void sendSingleEmailMessage(String[] toAddresses, String[] ccAddresses, String replyTo, 
	  String senderDisplayName, String plainTextBody, String subject, Id orgWideEmailAddressId){
	   // First, reserve email capacity for the current Apex transaction to ensure  
    // that we won't exceed our daily email limits when sending email after  
    // the current transaction is committed.  
    //Messaging.reserveSingleEmailCapacity(2);
    // Processes and actions involved in the Apex transaction occur next,  
    // which conclude with sending a single email.  
    // Now create a new single email message object  
    // that will send out a single email to the addresses in the To, CC & BCC list.  
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    // Strings to hold the email addresses to which you are sending the email.  
    
    system.debug('Email Util toAddresses=' + toAddresses);
    // Assign the addresses for the To and CC lists to the mail object.  
    mail.setToAddresses(toAddresses);
    if (ccAddresses.size() > 0) mail.setCcAddresses(ccAddresses);
    
    if (orgWideEmailAddressId != null) {
    	mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
    }
    else {
      // Specify the address used when the recipients reply to the email.   
      mail.setReplyTo(replyTo);
      // Specify the name used as the display name.  
      mail.setSenderDisplayName(senderDisplayName);
    }
    // Specify the subject line for your email address.  
    mail.setSubject(subject);
    // Set to True if you want to BCC yourself on the email.  
    //mail.setBccSender(false);
    // Optionally append the salesforce.com email signature to the email.  
    // The email address of the user executing the Apex Code will be used.  
    mail.setUseSignature(false);
    // Specify the text content of the email.  
    mail.setPlainTextBody(plainTextBody);
    
    // Send the email you have created.
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	
	}
	
	public void saveAttachmentsToCaseFromInboundEmail(Messaging.InboundEmail email, Id caseId) {
  	// Binary Attachments for the case
    if (email.binaryAttachments!=null && email.binaryAttachments.size() > 0) {
      for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {

        System.debug('Binary Attachments - filename: ' + email.binaryAttachments[i].filename);
        System.debug('Binary Attachments - size: ' +   email.binaryAttachments[i].mimeTypeSubType);
            
        Attachment a = new Attachment(ParentId = caseId,
                                      Name = email.binaryAttachments[i].filename,
                                      //Name = getFileExtension(email.binaryAttachments[i].filename, email.binaryAttachments[i].body), 
                                      Body = email.binaryAttachments[i].body);
          insert a;
        }
      } 
      // Text Attachments for case       
      if (email.textAttachments!=null && email.textAttachments.size() > 0) { System.debug('Text Attachments');
        for (integer i = 0 ; i < email.textAttachments.size() ; i++) {

          System.debug('Text Attachments - filename: ' + email.textAttachments[i].filename);
          System.debug('Text Attachments - size: ' +   email.textAttachments[i].mimeTypeSubType);
          Attachment b = new Attachment(ParentId = caseId,
                                        Name = email.textAttachments[i].filename,
                                        //Name = getFileExtension(email.textAttachments[i].filename,Blob.valueOf(email.textAttachments[i].body)), 
                                        Body = Blob.valueOf(email.textAttachments[i].body));
          insert b;
       }
     } //end Attachements code for case     
  }
  
  public static Boolean suppressEmailAutoResponse(String fromAddress) {
    // List of email address that will not get an auto response email
    return fromAddress.toLowerCase().contains('noreply') ||
    	     fromAddress.toLowerCase().contains('no-reply') ||
    	     fromAddress.toLowerCase().contains('no_reply') ||
    	     fromAddress.toLowerCase().contains('donotreply') ||
    	     fromAddress.toLowerCase().contains('do-not-reply') ||
    	     fromAddress.toLowerCase().contains('do_not_reply') ||
    	     fromAddress.toLowerCase().contains('content@expedia.com') ||
    	     fromAddress.toLowerCase().contains('geosup@expedia.com') ||
    	     fromAddress.toLowerCase().contains('hotelphotos@expedia.com') ||
    	     fromAddress.toLowerCase().contains('dsmaint@expedia.com') ||
    	     fromAddress.toLowerCase().contains('hdm@expedia.com') ||
    	     fromAddress.toLowerCase().contains('travopin@expedia.com') ||
    	     fromAddress.toLowerCase().contains('askexpedia@expediapartnercentral.com') || // added 4/26/11 by MPS
    	     fromAddress.toLowerCase().contains('mm@expedia.com') || // added 5/2/11 by MPS
    	     fromAddress.toLowerCase().contains('infosite@expedia.com') || // added 5/2/11 by MPS
    	     fromAddress.toLowerCase().contains('dchelp@expedia.com') || // added 5/3/11 by MPS
    	     fromAddress.toLowerCase().contains('ratings@expedia.com') || // added 5/3/11 by MPS
    	     fromAddress.toLowerCase().contains('hothelp@expedia.com') || // added 5/3/11 by MPS
    	     fromAddress.toLowerCase().contains('lodgeops@expedia.com') || // added 5/3/11 by MPS
    	     fromAddress.toLowerCase().contains('relomgt@expedia.com') || // added 5/3/11 by MPS
    	     fromAddress.toLowerCase().contains('dshelp@expedia.com') || // added 5/3/11 by MPS
    	     fromAddress.toLowerCase().contains('lo-hps-m@expedia.com') || // added 5/3/11 by MPS
    	     fromAddress.toLowerCase().contains('sfhelp@expedia.com') || // added 5/6/11 by MPS    	     
    	     fromAddress.toLowerCase().contains('partner@expedia.com') ||  // added 4/22/11 by MPS 
    	     fromAddress.toLowerCase().contains('assistance-ee@expedia.com') ||
    	     fromAddress.toLowerCase().contains('assistanceafrica@expedia.com') ||
    	     fromAddress.toLowerCase().contains('assistanceamer@expedia.com') ||
    	     fromAddress.toLowerCase().contains('assistanceanz@expedia.com') ||
    	     fromAddress.toLowerCase().contains('assistanceapac@expedia.com') ||
    	     fromAddress.toLowerCase().contains('assistanceaustria@expedia.com') ||
    	     fromAddress.toLowerCase().contains('assistancebnlx@expedia.com') ||
    	     fromAddress.toLowerCase().contains('assistancecanada@expedia.com') ||
    	     fromAddress.toLowerCase().contains('assistancecn@expedia.com') ||
           fromAddress.toLowerCase().contains('assistancecyprus@expedia.com') ||
           fromAddress.toLowerCase().contains('assistanceczech@expedia.com') ||
           fromAddress.toLowerCase().contains('assistancedenmark@expedia.com') ||
           fromAddress.toLowerCase().contains('assistanceeasterneurope@expedia.com') ||
           fromAddress.toLowerCase().contains('assistanceemea@expedia.com') ||
           fromAddress.toLowerCase().contains('assistancefinland@expedia.com') ||
           fromAddress.toLowerCase().contains('assistancefr@expedia.com') ||
           fromAddress.toLowerCase().contains('assistancegreece@expedia.com') ||
           fromAddress.toLowerCase().contains('assistancehk@expedia.com') ||
           fromAddress.toLowerCase().contains('assistanceiceland@expedia.com') ||
           fromAddress.toLowerCase().contains('assistanceid@expedia.com') ||
           fromAddress.toLowerCase().contains('assistanceie@expedia.com') ||
           fromAddress.toLowerCase().contains('assistancein@expedia.com') ||
           fromAddress.toLowerCase().contains('assistanceindianocean@expedia.com') ||
           fromAddress.toLowerCase().contains('assistanceisrael@expedia.com') ||
           fromAddress.toLowerCase().contains('assistancejp@expedia.com') ||
           fromAddress.toLowerCase().contains('assistancekh@expedia.com') ||
           fromAddress.toLowerCase().contains('assistancekr@expedia.com') ||
           fromAddress.toLowerCase().contains('assistancemalta@expedia.com') ||
           fromAddress.toLowerCase().contains('assistancemiddleeast@expedia.com') ||
           fromAddress.toLowerCase().contains('assistancemy@expedia.com') ||
           fromAddress.toLowerCase().contains('assistancenorway@expedia.com') ||
           fromAddress.toLowerCase().contains('assistanceph@expedia.com') ||
           fromAddress.toLowerCase().contains('assistancepoland@expedia.com') ||
           fromAddress.toLowerCase().contains('assistancerussia@expedia.com') ||
           fromAddress.toLowerCase().contains('assistancerussian@expedia.com') ||
           fromAddress.toLowerCase().contains('assistancesg@expedia.com') ||
           fromAddress.toLowerCase().contains('assistancesweden@expedia.com') ||
           fromAddress.toLowerCase().contains('assistanceswiss@expedia.com') ||
           fromAddress.toLowerCase().contains('assistanceth@expedia.com') ||
           fromAddress.toLowerCase().contains('assistanceturkey@expedia.com') ||
           fromAddress.toLowerCase().contains('assistancetw@expedia.com') ||
           fromAddress.toLowerCase().contains('assistanceuk@expedia.com') ||
           fromAddress.toLowerCase().contains('assistancevn@expedia.com') ||
           fromAddress.toLowerCase().contains('info@bbgliartisti.com');
  }
  
  
  // Do not reply if email address has x number of closed-spam cases
  public static Boolean suppressSpamEmails(String fromAddress) {
  	integer closedSpamEmailThreshold = 10;
  	List<Case> spamCases = [SELECT Id FROM Case WHERE Status = 'Closed - Spam' AND suppliedEmail = :fromAddress limit :closedSpamEmailThreshold];
    system.debug ('EXCEEDED MAX SPAM EMAILS: '+ string.valueOf(spamCases.size() == closedSpamEmailThreshold));
    return spamCases.size() == closedSpamEmailThreshold;
  }
  
  public static String getExpediaReplyToAlias(String recordType) {
  	
  	if (recordType == 'Geography') return 'geosup@expedia.com';
  	if (recordType == 'Destination_Services') return 'dsmaint@expedia.com';
  	if (recordType == 'Ticketing') return 'tktwfm@expedia.com';
  	if (recordType == 'Schedule_Change') return 'ascwfm@expedia.com';
  	if (recordType == 'Quality') return 'dharma.quality@2tpne6jo6xmz23mk0u8otcufk.mcofzma0.m.apex.sandbox.salesforce.com';
  	
  	return 'donotreply.gso@expedia.com';
  }
  
  public static String getExpediaReplyToAliasName(String recordType) {
  	if (recordType == 'Geography') return 'Geography Change Requests';
  	if (recordType == 'Destination_Services') return 'Destination Services Content Maintenance';
  	if (recordType == 'Ticketing') return 'GTP Support';
  	if (recordType == 'Schedule_Change') return 'ASC Support';
  	if (recordType == 'Quality') return 'Dharma Test -- Quality';
  	
  	return 'Expedia GSO';
  	
  }
  
  public static Map<String,Id> getOrgWideEmailDisplayNameToId() {
  	
  	Map<String,Id> orgWideEmailDisplayNameToId = new Map<String,Id>();
    
    OrgWideEmailAddress[] orgEmailAddresses = [Select Id
                                                     ,DisplayName
                                                 From OrgWideEmailAddress];
                                                 
    for (OrgWideEmailAddress orgEmail : orgEmailAddresses) {
    	orgWideEmailDisplayNameToId.put(orgEmail.DisplayName,orgEmail.Id);
    }
    
    return orgWideEmailDisplayNameToId;
  }
  
  public static String buildEmailRecipientsText(String[] toAddresses, String[] ccAddresses, String newLine) {
  	
    String emailRecipientsHeader = '-------------- EMAIL ADDRESS(s) SENT TO ---------------' + newLine + newLine;
    String emailCCRecipientsHeader = newLine + newLine + '-------------- CC ADDRESS(s) SENT TO ---------------' + newLine + newLine;
    String flatToAddresses = '';
    String flatCCAddresses = '';
    
    String returnText = '';
    
    for(String emailAddress : toAddresses) {
    	if (flatToAddresses.length() == 0) {
    	  flatToAddresses = emailAddress + ';';
    	}
    	else {
    	  flatToAddresses = flatToAddresses + newLine + emailAddress + newLine;
    	}
    	
    }
    if (ccAddresses != null) {
      for (String ccAddress : ccAddresses) {
    	  if (flatCCAddresses.length() == 0) {
    		  flatCCAddresses = ccAddress + ';';
    	  }
    	  else {
    	    flatCCAddresses = flatCCAddresses + newline + ccAddress + newLine;
    	  }
      }
    }
    
    returnText = emailRecipientsHeader + flatToAddresses;
    if (flatCCAddresses.length() != 0) {
    	returnText = returnText + emailCCRecipientsHeader + flatCCaddresses;
    }
    
    returnText = returnText + newLine + newLine + '------------------------------------------------------' + newLine + newLine;
    
    return returnText;
  }
  
  //MPS ADDED
  public static String buildEmailRecipientsField(String[] toAddresses, String[] ccAddresses){
  	string returnText = '';	
  	// Emails in the "To" address will appear capital
  	for (String emailAddress : toAddresses){
  		string formattedEmailAddress = formatEmailAddress(emailAddress).toUpperCase();		
  		returnText = returnText + formattedEmailAddress + '; '; //space after semicolon to not interfere with linebreaks
  	}
  	// Emails in the "CC" address will appear lowercase  	
  	if (ccAddresses != NULL) {
	  	for (String ccAddress : ccAddresses){
	  		string formattedCcAddress = formatEmailAddress(ccAddress).toLowerCase();	  		
	      returnText = returnText + formattedCcAddress + '; '; //space after semicolon to not interfere with linebreaks
	    }
  	}
  	// trap if exceeds Text Area field length. 255 characters should be more than enough, but if there are a lot of CCs etc
  	// could also increase the field length.
  	if (returnText.length() > 255){
  		returnText = returnText.substring(0,254);
  	} 
    return returnText;
  }
  
  private static String formatEmailAddress(String emailAddress){
  	string formattedEmailAddress;
    if (emailAddress.contains('<') && emailAddress.contains('>')){
     formattedEmailAddress = emailAddress.substring(emailAddress.indexOf('<')+1, emailAddress.lastIndexOf('>'));
    }
    else{
     formattedEmailAddress = emailAddress;
    }
    return formattedEmailAddress;
  }
  
  private string getFileExtension(String filename, Blob body){
  	if (filename.contains('.')){
  		//Look for the . near the end of the filename
  		Integer dotPlace = filename.length() - filename.lastIndexOf('.');
  		system.debug('####FILENAME#### ' + filename);
  		system.debug('####DOTPLACE#### ' + dotPlace);
  		
  		// Verify if the last . has between 2 and 4 characters after it
  		// ie a typical file extension
  		// Trying not to do this for My.File.6.16.11   		
  		if (dotPlace > 2 && dotplace < 6){
  			return filename;
  		}
  	}
  	
  	String myBody = body.toString();
  	
  	// not closing HTML tag as most are something like <html xmlns		
  	if (myBody.toLowerCase().contains('<html')){
  		return filename +'.html';
  	}
  	else{
  		return filename + '.txt';
  	}  	  	
  }
}
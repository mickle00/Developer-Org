public with sharing class EmailServicesUtilities {
	
	public EmailMessage newReplyEmailMessage(Messaging.Inboundemail email){
		
		EmailMessage objEmail = new EmailMessage();
		Id parentCaseId = null;
		
		if(email.subject.contains('ref:')){
			parentCaseId = this.EmailThreadParentId(email.subject);
		}    
		objEmail.ParentId = parentCaseId;
		objEmail.Incoming = true;
		objEmail.Subject = email.subject;
		objEmail.FromAddress = email.fromAddress;
		objEmail.FromName = email.fromName;
		objEmail.TextBody = email.plainTextBody;
	 	objEmail.MessageDate = system.now();
	 	objEmail.Status = '2'; // Picklist value for 'Replied'

		return objEmail;
				
	}
	
	private Id EmailThreadParentId(String subject) {
	  
	  Id parentCaseId = null;
	 
	  String queryWhere = this.EmailThreadReferenceId(subject);
	  
	  queryWhere = '%' + queryWhere + '%';
	  
	  List<Task> tasks = [Select whatId
	                        From Task
	                       Where Subject like :queryWhere LIMIT 1];
	                                         
	 if(tasks.isEmpty()){
	 	return null;
	 }
	 else {
	  return tasks[0].WhatId;	
	  }
	}
	
	private String EmailThreadReferenceId(String subject) {
      Integer firstRef = subject.indexof('ref:');
	  Integer lastRef = subject.lastindexof(':ref') + 4;
			
      return subject.substring(firstRef,lastRef);
	}
	
	public void saveAttachmentsToCaseFromInboundEmail(Messaging.InboundEmail email, Id caseId) {
  	// Binary Attachments for the case
    if (email.binaryAttachments!=null && email.binaryAttachments.size() > 0) {
      for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {

        System.debug('Binary Attachments - filename: ' + email.binaryAttachments[i].filename);
        System.debug('Binary Attachments - size: ' +   email.binaryAttachments[i].mimeTypeSubType);
            
        Attachment a = new Attachment(ParentId = caseId,
                                      Name = email.binaryAttachments[i].filename, 
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
                                        Body = Blob.valueOf(email.textAttachments[i].body));
          insert b;
       }
     } //end Attachements code for case     
  }
  
  public static TestMethod void testThis(){
  	Messaging.Inboundemail email = new Messaging.Inboundemail();
  	Case objCase = new Case();
  	
  	EmailMessage objEmail = new EmailMessage();
  	email.subject = 'This is a test! [ref:Whoa:ref]';
  	email.fromAddress = 'yuk@yuky.com';
  	email.plainTextBody = 'I just want to test this class';
  	
  	EmailServicesUtilities objEmailUtil = new EmailServicesUtilities();
  	objEmail = objEmailUtil.newReplyEmailMessage(email);
  	
  	objCase.Description = 'Test Case';
  	insert objCase;
  	
  	objEmailUtil.saveAttachmentsToCaseFromInboundEmail(email,objCase.id);
  	
  	
  }
}
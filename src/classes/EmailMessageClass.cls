public with sharing class EmailMessageClass {
	
	public enum enumEmailStatus{newMessage, unread, replied, sent}
	
	//constructor
	public EmailMessageClass() {}
	
	public void createEmailMessage(Id parentId, String subject, String fromAddress, String fromName,
	  String toAddress, String textBody, enumEmailStatus status,Boolean incoming) {
	  	
	  system.debug('***EmailMessageClass.createEmailMessage before insert ***');
	
	  EmailMessage newEmail = new EmailMessage(ParentId = parentId
	                                          ,Incoming = incoming
	                                          ,Subject = subject
	                                          ,FromAddress = fromAddress
	                                          ,FromName = fromName
	                                          ,ToAddress = toAddress
	                                          ,TextBody = textBody
	                                          ,MessageDate = system.now()
	                                          ,Status = String.valueOf(status.ordinal()));
	  
	  insert newEmail;
	 
	}
}
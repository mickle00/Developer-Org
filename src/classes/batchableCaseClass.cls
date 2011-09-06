global class batchableCaseClass implements Database.Batchable<sObject>{
		
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator([SELECT Id
												,Status
												,Description_Rich_Text__c
										   FROM Case 
										  WHERE Status != 'Closed']);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		system.debug('hi');
		for (sObject mySobject : scope){
			// type cast sObject as a Case
			Case myCase = (Case)mySobject;
			myCase.Description_Rich_Text__c = 'Batch Apex Update';
		}
		update scope;
	}
	
	global void finish (Database.BatchableContext BC){
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'a-mistewart@expedia.com'}; 
        mail.setToAddresses(toAddresses); 
        mail.setSubject('Batch Apex Completed.');
        mail.setPlainTextBody('It has been done');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });		
	}
}
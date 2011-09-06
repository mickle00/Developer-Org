public with sharing class visualforceEmail {
	public Id Case_Id {get; set;}
	public String emailTemplateType {get; set;}
	//public visualforceEmail(){}
	
	public string getEmailBody(){
		//try catch to view template preview out of the scope of a case
		try {
			Case myCase = [SELECT Id
								  ,Account.Language__c 
							 FROM Case 
							WHERE Id = :Case_Id limit 1];
			
			Translated_Email__c myEmailLanguage = [SELECT Id
													      ,Email_Body__c 
											  	     FROM Translated_Email__c 
											  	    WHERE Language__c = :myCase.Account.Language__c 
											  	      AND Email_Template__r.Name = :emailTemplateType limit 1];
			return myEmailLanguage.Email_Body__c;
		}
		// Defaults to the English template if the Account doesn't have a language
		catch (Exception e){
			Translated_Email__c myEmailLanguage = [SELECT Id
													      ,Email_Body__c 
											  	     FROM Translated_Email__c 
											  	    WHERE Language__c = 'English'
											  	      AND Email_Template__r.Name = :emailTemplateType limit 1];
			return myEmailLanguage.Email_Body__c;
		}				
	}
}
/*
* Test class for the TransferIndustryContacts trigger 
*/
public with sharing class Test_TransferIndustryContacts {

    //Declare test method
    public static testmethod void doTest() {
        
        //Create a new lead that will be converted into a new account and contact
        Lead newLead = new Lead(lastname = 'Test1_Lname', company='Test1_Acct');
        insert newLead;
        
        //Create the LeadConvert object
        Database.LeadConvert lc = new database.LeadConvert();
        
        //Set the newly inserted lead as the target to this LeadConvert
        lc.setLeadId(newLead.id);
        
        //Set the required ConvertedStatus field
        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted = true limit 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        //execute lead conversion
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        //Confirm that the new contact belongs to the correct account
        //as assigned by the trigger (Account ID = 00100000005Q96h)
        Contact newContact = [SELECT Id, AccountId FROM Contact WHERE Id = :lcr.getContactId()];
        System.assert(newContact.AccountId == '00100000005Q96h');
    }

}
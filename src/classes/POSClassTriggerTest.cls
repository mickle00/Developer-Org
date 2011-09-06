@isTest
private class POSClassTriggerTest {
	
    static testMethod void POSClassTriggerTest() {
		Case cs = new Case(Subject = 'TestCase', Status = 'New', POS__c = 'Expedia-Netherlands;Expedia-Singapore');
		insert cs;

		Case cs2 = [SELECT Id, POS__c FROM Case WHERE Id = :cs.Id];
		cs2.POS__c = 'Expedia-Japan';
		update cs2;
    }
}
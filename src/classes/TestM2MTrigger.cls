@isTest
private class TestM2MTrigger {
	static testMethod void testTrigger(){
		
		Account[] testaccts = new Account[] {
			new Account(Name = '999TestAcct0'),
			new Account(Name = '999TestAcct1', Rating = '1'),
			new Account(Name = '999TestAcct2', Rating = '2'),
			new Account(Name = '999TestAcct3', Rating = '3'),
			new Account(Name = '999TestAcct4', Rating = '4'),
			new Account(Name = '999TestAcct5', Rating = 'NoAccountNumber')
		};
		insert testaccts;
		
		Map <String, Id> testacctid = new Map<String, Id> ();
		
		for (Account a : testaccts){
			system.debug ('Name: ' + a.Name + 'Id: ' + a.Id);
			testacctid.put(a.Name, a.Id);
		}
				
		Contact[] testcontacts = new Contact[]{
			new Contact (LastName = '999Test1', Email = '999test@test.com', Priority__c = '2'),
			new Contact (LastName = '999Test2', Email = '999test@test.com', Priority__c = '2'),
			new Contact (LastName = '999Test3', Email = '999fake@fake.com', Priority__c = '1'),
			new Contact (LastName = '999Test4', Email = '999only1@example.com', Priority__c = '4'),
			new Contact (LastName = '999Test5', Email = '999no@email.com', Priority__c = '3'),
			new Contact (LastName = '999Test6', Email = '999no6@email.com'),
			new Contact (LastName = '999Test7', Email = '999nonumber@email.com', Priority__c = 'NOTANUMBER'),
			new Contact (LastName = '999Test8', Email = '999noaccount@email.com', Priority__c = '2'),
			new Contact (LastName = '999Test9', Email = '999dupe@email.com', Priority__c = '2')
	
		};
		insert testcontacts;
		
		Map <String, Id> testcontactid = new Map<String, Id> ();
		
		for (Contact c : testcontacts){
			system.debug ('LastName: ' + c.LastName + 'Id: ' + c.Id);
			testcontactid.put(c.LastName, c.Id);
		}
		
		Account_Contact__c[] testjunctiontable = new Account_Contact__c[]{
			new Account_Contact__c (Account__c = testacctid.get('999TestAcct1'), Contact__c = testcontactid.get('999Test1')),
			new Account_Contact__c (Account__c = testacctid.get('999TestAcct1'), Contact__c = testcontactid.get('999Test4')),
			new Account_Contact__c (Account__c = testacctid.get('999TestAcct4'), Contact__c = testcontactid.get('999Test6')),
			new Account_Contact__c (Account__c = testacctid.get('999TestAcct2'), Contact__c = testcontactid.get('999Test7')),
			new Account_Contact__c (Account__c = testacctid.get('999TestAcct3'), Contact__c = testcontactid.get('999Test3')),
			new Account_Contact__c (Account__c = testacctid.get('999TestAcct1'), Contact__c = testcontactid.get('999Test9')),
			new Account_Contact__c (Account__c = testacctid.get('999TestAcct3'), Contact__c = testcontactid.get('999Test9'))
		};
		insert testjunctiontable;
		
		Case[] testcases = new Case[] {
			new Case(Subject = 'Test Case1', SuppliedEmail= '999test@test.com'),
			new Case(Subject = 'Test Case2', SuppliedEmail= '999only1@example.com'),
			new Case(Subject = 'Test Case3', SuppliedEmail= '999fake@fake.com'),
			new Case(Subject = 'Test Case4', SuppliedEmail= '999notin@thedatabase.com'),
			new Case(Subject = 'Test Case5', SuppliedEmail= '999nonumber@email.com'),
			new Case(Subject = 'Test Case6', SuppliedEmail= '999noaccount@email.com'),
			new Case(Subject = 'Test Case7', SuppliedEmail= '999dupe@email.com'),
			new Case(Subject = 'Test Case8', SuppliedName = 'Test User', SuppliedEmail= 'neverevergoingtobeinthere@test.com'),
			new Case(Subject = 'Test Case9', SuppliedName = 'Test', SuppliedEmail= 'neverevergoingtobeinthere2@test.com'),
			new Case(Subject = 'Test Case10', SuppliedName = 'Three Named Person', SuppliedEmail= 'neverevergoingtobeinthere3@test.com')
		};
		
		for (integer i = 0; i < 150; i++){
			Case c = new Case(Subject ='Test'+i, SuppliedEmail = i+'test@email.com');
			testcases.add(c);
		}
		
		system.debug(testcases.size());
		
		Case[] testonecase = new Case[] {
			new Case(Subject = 'Test Case Only 1', SuppliedEmail= '999dupe@email.com')
		};
										
		Test.startTest();
		insert testcases;
		insert testonecase;
		Test.stopTest();
		
		Set<Id> CaseIDs = new Set<Id>(); 		
			
		for (Case c : testcases) CaseIDs.add(c.Id);		
		
		Map <String, String> TestCasePriority = new Map<String, String> ();
		Map <String, String> TestCaseAcctName = new Map<String, String> ();
		Map <String, String> TestCaseContactName = new Map<String, String> ();
				
		for (Case c : 
			[SELECT Id, Subject, Priority, Account.Name, Contact.LastName FROM Case WHERE Id IN : CaseIDs]){
				TestCasePriority.put(c.Subject, c.Priority);
				TestCaseAcctName.put(c.Subject, c.Account.Name);
				TestCaseContactName.put(c.Subject, c.Contact.LastName);
		}
		
		system.assert(TestCasePriority.get('Test Case1') == '1');
		system.debug('ACCOUNT NAME IS: ' + TestCaseAcctName.get('Test Case1'));
		system.assert(TestCaseAcctName.get('Test Case1') == '999TestAcct1');
		
		system.assert(TestCasePriority.get('Test Case2') == '1');		
		system.assert(TestCasePriority.get('Test Case3') == '1');
		// Need to be careful...this case will have the default priority value		
		system.assert(TestCasePriority.get('Test Case4') > '3');		
		system.assert(TestCasePriority.get('Test Case5') == '2');
		system.assert(TestCasePriority.get('Test Case6') == '2');
	}
}
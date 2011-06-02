trigger populateCompletedField on Task (after update, after insert) {

// Populate Completed__c Field on Task with information from Completed_Date__c.

Set<ID> taskz = new Set<ID>(); 

for (Task z : trigger.New) if (z.One__c != z.Two__c) {
    taskz.add(z.Id);
    }
    
    List<Task> tasks= 
        [SELECT t.Id, t.One__c, t.Two__c
         FROM Task t WHERE Id IN :taskz];
         
  
  
    for (Task ta: tasks) {
    ta.One__c = ta.Two__c;
    }
    update tasks;
}
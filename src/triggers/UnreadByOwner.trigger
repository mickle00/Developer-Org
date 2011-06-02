trigger UnreadByOwner on Lead (before update, before insert) {
    for (lead l : trigger.New)
       l.Unread__c = l.ISUNREADBYOWNER;  
   
}
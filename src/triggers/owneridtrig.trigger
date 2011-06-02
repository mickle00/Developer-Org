trigger owneridtrig on Opportunity (before update, before insert) {
    for (opportunity o : trigger.New) 
    o.User__c = o.OwnerID;
}
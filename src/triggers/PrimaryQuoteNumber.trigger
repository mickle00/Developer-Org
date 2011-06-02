// This was made by using new custom objects, based off of a managed package
// because this isn't the exact managed package, names will be slightly different.
// I have no way of testing this against any existing validation rules or custom 
// triggers that are included in the managed package. Hopefully this can be a start.
//  | ------------------------------------------------------------------------------|
//  |                                   Key                                         |
//  |                   Managed Package  =  Mike's Custom Object                    |
//  |                   ----------------------------------------                    |
//  |                    SBQQ__Quote__c  =  SBQQ_Quote__c                           |
//  |                       (note the 2nd underscore after SBQQ)                    |
//  |               SBQQ__Opportunity__c =  Opportunity__c                          |
//  |                   SBQQ__Primary__c =  Primary__c                              |
//  |                                                                               |
//  | ------------------------------------------------------------------------------|
// This trigger is firing everytime after a quote is inserted or updated. 
// This is because new quotes need to be linked to an opportunity, 
// so we can't get the ID until it's been created.
// I don't think we have to worry about governor limits (yet) 
// although 4 SOQL queries is starting to worry me. There is probably a better
// way to get this down into 2 queries.


trigger PrimaryQuoteNumber on SBQQ_Quote__c (after update, after insert, after delete) {


    Set<String> qoppiddel = new Set<String>();
    try{
    for (SBQQ_Quote__c y : trigger.Old) {
        if(trigger.isDelete){
            if(y.Primary__c == true){
            qoppiddel.add(y.Opportunity__c);
            }
        }
    }
    }
         catch (Exception e){
                System.debug('ERROR:' + e);
            }
            
    Map<Id, String> qmapdel = new Map<Id, String> ();
        for (SBQQ_Quote__c yy : 
            [SELECT Name, Opportunity__c from SBQQ_Quote__c WHERE Opportunity__c IN :qoppiddel AND Primary__c = True ORDER BY Name ASC])
                                 
                qmapdel.put (yy.Opportunity__c, yy.Name);  
                
    List<Opportunity> oppsdel = [SELECT Id, qtest__c from Opportunity WHERE Id IN :qoppiddel];
    
    for (Opportunity oo : oppsdel){
            oo.qtest__c = qmapdel.get(oo.Id);
            }
        // apply the changes to the database.
        update oppsdel;
        


    // Create a set to hold all of the opportunity IDs
    Set<String> qoppid = new Set<String>();
    // Create a set to hold all of the opportunity IDs from
    // quotes that used to be primary, but no longer are.
    Set<String> qoppidold = new Set<String>();    
    
    // Loop through every quote that is affected by this trigger
    // Add the IDs for all opportunities that are now the primary quote to 
    // the set qoppid. Add all the IDs for opportunities of quotes
    // that used to be primary, but no longer are.
    try{
    for (SBQQ_Quote__c q : trigger.New){
        if (q.Primary__c == false){
            try{
            for (Integer i = 0; i < Trigger.new.size(); i++){
                if (Trigger.old[i].Primary__c == true){
                    qoppidold.add(q.Opportunity__c);
                    }
                }
            
            }
            catch (Exception e){
                System.debug('ERROR:' + e);
            }
            }
        if (q.Primary__c == true){
            qoppid.add(q.Opportunity__c);
            }
        }
        }
             catch (Exception e){
                System.debug('ERROR:' + e);
            }
        
    // For quotes that used to be the primary quote, but no longer
    // query the database to see if there is an alternative primary quote
    // if not, this will be null, and will result in the value being zeroed 
    // out on the opportunity
    Map<Id, String> qmapold = new Map<Id, String> ();
        for (SBQQ_Quote__c q : 
            [SELECT Name, Opportunity__c from SBQQ_Quote__c WHERE Opportunity__c IN :qoppidold AND Primary__c = True ORDER BY Name ASC])                  
                qmapold.put (q.Opportunity__c, q.Name);     
                
    // Create a list of opportunities to be updated. Query the database for only those in our qoppidold set above.
    List<Opportunity> oppsold = [SELECT Id, qtest__c from Opportunity WHERE Id IN :qoppidold];

    // loop through the opportunities that have quotes that are no longer primary. 
    // Change the custom field on Opportunity qtest 
    // to the Quote Name which is mapped to the Opportunity ID from above qmapold.
    // Note: 9 times out of 10 this will just zero out the value on opportunity.
    // However, in case there were duplicate primary quotes, this will choose the 
    // current hightest quote number.
    
    for (Opportunity o : oppsold){
            o.qtest__c = qmapold.get(o.Id);
            }
        // apply the changes to the database.
        update oppsold;
    
    // If there are no opportunity records stop. Without this, 
    // the Apex trigger might crash *shrug*. 
    // Someone told me it was a good idea, even though in my testing
    // the Apex trigger doesn't appear to crash without it.
    
    if (qoppid.isEmpty()) return;    
    
    
    // create a map linking Opportunity IDs to the Primary Quote # based on qoppid set above. 
    
    // Note: If there are 2 "primary" quotes on an opportunity, it's going 
    // to get higher quote # to put in the map. Since mapvalues must be unique
    // it won't add any additional. Hopefully there is already a trigger or validation 
    // rules or something in place that would prevent this from happening.
    
    Map<Id, String> qmap = new Map<Id, String> ();
    for (SBQQ_Quote__c q : 
        [SELECT Name, Opportunity__c from SBQQ_Quote__c WHERE Opportunity__c IN :qoppid AND Primary__c = True ORDER BY Name ASC])                  
            qmap.put (q.Opportunity__c, q.Name); 
    
    
    // Create a list of opportunities to be updated. Query the database for only those in our qoppid set above.
    List<Opportunity> opps = [SELECT Id, qtest__c from Opportunity WHERE Id IN :qoppid];
    
    
    // loop through the opportunities that are affected above. Change the custom field on Opportunity qtest 
    // to the Quote Name which is mapped to the Opportunity ID from above qmap.
    for (Opportunity o : opps){
            o.qtest__c = qmap.get(o.Id);
        }
        // apply the changes to the database.
        update opps;

}
// TODOS
// If returns multiple, compare Web Name with Contact Name???? (going up in complexity fast)
// Build logic for the M2M relationship between contacts and accounts....if multiple, 
// get the account rating to be used when building case priority <-- already included in workflow rules?
// 
//Advanced TODOs
// Build advanced logic for looking up based on domain if no exact matches? 
// Would need to weed out gmail, yahoo, etc

trigger LookupEmail on Case (before insert) {
    // We're firing before insert on the trigger     
    // Build a set of all emails that are applied. Need to do
    // this in order to bulkify the trigger
    
    Set<String> allemails = new Set<String>();
    Integer numofemail = 0;
    Date myDate = Date.Today();
    String sDate = String.valueOf(myDate);
    
    //loop through the new casses, and if it comes from Web2Case
    // or Email2Case the SuppliedEmail should be populated.
    // if it's null, we do not add it to the list
    
    for (case c : trigger.New) if (c.SuppliedEmail != null) allemails.add(c.SuppliedEmail);
    
    // Create a map of Email to Contact ID
    Map <String, Id> emailcid = new Map<String, Id> ();
    // Create a map of Email to Account ID, based on the Contacts Account
    Map <String, Id> emailaid = new Map<String, Id> ();
    // Create a map of Email to the number of occurances of this email
    Map <String, Integer> emailcount = new Map<String, Integer> ();
    // Create a list of all emails, and the number of occurances
    List<AggregateResult> emailcountlist = [SELECT email, count(id) total FROM Contact WHERE Email IN : allemails GROUP BY email];
    
    //Loop throug the results and map the email to the number of occurances
    for (AggregateResult e : emailcountlist)
    {
        String em =  (String) e.get('email');
        Integer tot = (integer) e.get('total');
        emailcount.put(em, tot);
    }    
    
    // Query the database for contacts with this email address
    for (contact ct :
        [SELECT Id, email, accountid FROM Contact WHERE Email IN : allemails])
        {
            // add the contacts id to the map emailcid with email address as the key
            emailcid.put(ct.email, ct.Id);
            // add the account id to the map emailaid with email address as the key
            emailaid.put(ct.email, ct.accountid);
        }
    // for all of the affected cases, add the contactid and account id
    // Shouldn't need to worry about this being error prone, due to SuppliedEmail being NULL
    // However, may want to make this a little cleaner.
    
    for (case c : trigger.New)
        if (c.SuppliedEmail != null){
        {
        // figure out how many times email address came up
        numofemail = emailcount.get(c.SuppliedEmail);
        // if one, auto link to contact (and the contacts account), and change status to linked
        if (numofemail == 1){
            // get and assign the contact id based on email
            c.contactid = emailcid.get(c.SuppliedEmail);
            // get and assign the account id based on email & account
            c.accountid = emailaid.get(c.SuppliedEmail);
            c.Web_Email_Lookup_Status__c = 'Only one match found; linked: '+sDate;
            // can't use Case ID or Case Number in the debug since they haven't been created yet. 
            // I wanted to provide some level of visibility, so using subject line
            system.debug(c.Subject + ' successfully linked');
        
        // if more than one, display how many that were found on custom field
        }else if (numofemail > 1){
            // if there is only one item in the trigger, we should have a ton more flexibility without hitting governor limits
            // i tried to bulkify this trigger as much as possible, so even if we do large dataloads it won't break
            if (trigger.new.size()==1){
                c.Web_Email_Lookup_Status__c = numofemail + ' Matching Emails Found on '+ sDate +'; Not Linked' +'\nPossibilities Include:\n';
                List<Contact> allcontacts = [SELECT Id, AccountId, Account.Name, Name, Email FROM Contact WHERE Email IN : allemails];
                for (Contact ct : allcontacts){
                    // really don't like hardcoding the instance URL here....will have to look at getting this a better way
                    c.Web_Email_Lookup_Status__c = c.Web_Email_Lookup_Status__c + '\n'+ ct.Account.Name + ' - ' +ct.Name+ ' - ' + 'https://na3.salesforce.com/'+ct.Id  ;
                }               
            } else {
            c.Web_Email_Lookup_Status__c = numofemail + ' Matching Emails Found on '+ sDate +'; Not Linked';
            system.debug(c.Subject + ' has multiple matching emails, not linked');
            }
        // if none were found, display that on custom field
        }
        else {
            c.Web_Email_Lookup_Status__c = 'No Matching Email Found. Attempted: '+ sDate;
            system.debug(c.Subject + ' has no matching emails, not linked');
        }
    }
}}
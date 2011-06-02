public class MikeyController {

    Account account;
    Contact contact;

    public PageReference save() {
        update account;
        PageReference secondPage = Page.mySecondPage;
        secondPage.setRedirect(true);
        secondPage.getParameters().put('id',account.id); 
        return secondPage; 
    }

    public String getName() {
        return 'MikeyController';
    }

    public Account getAccount() {
        if(account == null) 
            account = [select id, name, site from Account 
                       where id = :ApexPages.currentPage().getParameters().get('id')];
        return account; 
    } 
    
   public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                      [select name,closedate from Opportunity WHERE AccountID = :ApexPages.currentPage().getParameters().get('id') ]));
            }
            return setCon;
        }
        set;
    }
    
    
     public List<Opportunity> getOpportunities() {
         return (List<Opportunity>) setCon.getRecords();
    }
    
}
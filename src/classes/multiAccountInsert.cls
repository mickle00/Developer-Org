public class multiAccountInsert{

    public List<Account> accts {get; set;}
    public List<Contact> cts {get; set;}
    
    public multiAccountInsert(){
        accts = new List<Account>();
        accts.add(new Account());
        cts = new List<Contact>();
        cts.add(new Contact());
    }
    
    public void addrow(){
        accts.add(new Account());
    }
    
          
    public void addrowc(){
        cts.add(new Contact());
    }
    
    public PageReference save(){
        insert accts;
        insert cts;
        PageReference home = new PageReference('/home/home.jsp');
        home.setRedirect(true);
        return home;
    }
}
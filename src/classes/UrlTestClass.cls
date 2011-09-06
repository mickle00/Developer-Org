public class UrlTestClass {
public String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm(); 
    public String getURlValue() {
            return sfdcURL ;
    }
   public void URLTest(Account ac)
   {
     //  account ac = new account (id=i);
       ac.website = sfdcURL ;
       
   }

}
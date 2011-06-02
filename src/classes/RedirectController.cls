public class RedirectController {
  public ApexPages.PageReference redirect() {
    String Url = ApexPages.currentPage().getParameters().get('url');
    if(url==null || url=='')
      return null;
    ApexPages.PageReference ref = new ApexPages.PageReference(url);
    Tracker__c tracker = new Tracker__c(Url__c=url);
    insert tracker;
    ref.setRedirect(true);
    return ref;
  }
}
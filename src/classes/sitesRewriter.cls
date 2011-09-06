global class sitesRewriter implements Site.UrlRewriter {
/**
 //Variables to represent the friendly URLs for pages
 String DIRECTORY = '/ty';

 //Variables to represent my custom Visualforce pages that display page information
 String VISUALFORCE_PAGE = '/page?pageid=';

 // The first global method for mapping external URL to an internal one
**/
 global PageReference mapRequestUrl(PageReference myFriendlyUrl){
 /**
    String url = myFriendlyUrl.getUrl();
    system.debug('THE URL IS ====>' + url);
    if(url.startsWith(DIRECTORY)){
      // String name = url.substring(DIRECTORY.length(),url.length());
       //Select the ID of the page that matches the name from the URL
       //Page__c site_page = [select id from Page__c where name =:name LIMIT 1];
       //Construct a new page reference in the form of my Visualforce page
       //return new PageReference(VISUALFORCE_PAGE + site_page.id);
       return Page.GSOHomeThankYou;
    }

    //If the URL isn't in the form of a cmasforce page, continue with the request
    //return null;
      **/
    return null; 
  
  }

  // The second global method for mapping internal Ids to URLs

  global List<PageReference> generateUrlFor(List<PageReference> mySalesforceUrls){
  /**
    //A list of pages to return after all the links have been evaluated
    List<PageReference> myFriendlyUrls = new
    List<PageReference>();
    for(PageReference mySalesforceUrl : mySalesforceUrls){
      //Get the URL of the page
      String url = mySalesforceUrl.getUrl();

      //If this looks like a page that needs to be mapped, transform it
      if(url.startsWith(VISUALFORCE_PAGE)){
        //Extract the ID from the query parameter
        String id= url.substring(VISUALFORCE_PAGE.length(), url.length());
        //Query for the name of the cmsforce page to put in the URL
        //Page__c site_page2 = [select name from Page__c where id =:id LIMIT 1];

        //Construct the new URL
        //myFriendlyUrls.add(new PageReference(DIRECTORY+ site_page2.name));
     }  

     else {

       //If this doesn't start like an cmsforce page, don't do any transformations
       myFriendlyUrls.add(mySalesforceUrl);
     }
  }

  //Return the full list of pages
   **/
  return null;
 
  }
}
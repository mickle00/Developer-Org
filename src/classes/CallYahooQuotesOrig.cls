global class CallYahooQuotesOrig
{
    @future(callout=true)
    public static void getQuotes()
    {   //for our simple example we are going to just update the quotes on one Account
       Account acct = [select id, TickerSymbol, stock_price__c from account where name = 'Salesforce.com'];
   
       //where f stands for the fields to be displayed (in this case: s - symbol; l1 - last price; c1 - change; d1 = last date)
       // String url = 'http://quote.yahoo.com/d/quotes.csv?s='+acct.TickerSymbol+'&f=sl1c1d1&e=.csv';
     
     String url = 'http://download.finance.yahoo.com/d/quotes.csv?s='+acct.TickerSymbol+'&f=l1&e=.csv';
    
    Http h = new Http();
    
    HttpRequest req = new HttpRequest();
    req.setEndpoint(url);
    req.setMethod('GET');
    
    HttpResponse res = h.send(req);
    
    //omitting error handling for example
    acct.stock_price__c = decimal.valueOf(res.getBody().trim());  
    update acct;  
   }

}
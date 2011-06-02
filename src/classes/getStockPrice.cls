global class getStockPrice implements Schedulable
{ 
 global void execute(SchedulableContext ctx)
 {
 //call a future method so we can do callouts within a schedule
    CallYahooQuotes.getQuotes();
 }
}
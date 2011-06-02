global class StockPriceJobScheduler
{
 global void StockPriceJobScheduler() {}
 
 public static void start()
 {
 //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
 System.schedule('Stock Price Update', '0 0 1-23 * * ?', new getStockPrice());
 }
}
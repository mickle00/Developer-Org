public with sharing class RecursiveTrigger {

    // Static variables are local to the context of a Web request    
    // (or testMethod during a runTests call)    
    // Therefore, this variable will be initialized as false    
    // at the beginning of each Web request which accesses it.    

    private static boolean alreadyFiredTrigger = false;
    public static boolean hasAlreadyFiredTrigger() {
        return alreadyFiredTrigger;
    }

    // By setting the variable to true, it maintains this    
    // new value throughout the duration of the request      
    // (or testMethod)  
    
    public static void setAlreadyFiredTrigger() {
        alreadyFiredTrigger = true;
    }
}
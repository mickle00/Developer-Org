trigger mikeytest on Lead (before update, before insert) {

for (Lead l : Trigger.new){
    if(Trigger.new.size() > 1 ){
    
    //DO THE FIRST PART OF CODE THAT WORKS
    
    }
    
    ELSE {
    
    //DO THE BULK TRIGGER CODE
   
    }

}
}
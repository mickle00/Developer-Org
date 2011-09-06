public with sharing class ByRefTest {
	
	public ByRefTest(){}
	
	public void returnByRefValues(Set<String> newSet){
		
		
		newSet.add('From method');
		
	}

}
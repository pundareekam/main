global class TMOS_BatchApexDishOptionStatusUpdate implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, NOD_Issue_Date__c, Dish_Status__c FROM Dish_Option__c Where Dish_Status__c != ' + '"Declined/Did Not Respond"';            
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Dish_Option__c> listDishOptions) {
        
        // process each batch of records default size is 200
        for(Dish_Option__c dishOption : listDishOptions) {        
            IF ( dishOption.NOD_Issue_Date__c == null) {
                dishOption.Dish_Status__c = 'First Option Period';
            } else if( Date.today() < dishOption.NOD_Issue_Date__c && Date.today().addDays(120) > dishOption.NOD_Issue_Date__c ) {
                dishOption.Dish_Status__c = 'Response Not Recieved';
            } else if(Date.today().addDays(60) < dishOption.NOD_Issue_Date__c && Date.today().addDays(120) > dishOption.NOD_Issue_Date__c ) {
                
            }
             
        }
        try {
            // Update the Account Record
            update listDishOptions;
         
        } catch(Exception e) {
            System.debug(e);
        }
         
    }
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}
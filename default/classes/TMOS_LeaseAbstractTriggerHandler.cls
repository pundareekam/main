/**************************************************************************************************************/
// Purpose: To Upsert Lease_Abstract__c object when a record is inserted in a Lease_Abstract_Update__e Event 
// Registered Callers: TMOS_LeaseAbstractTrigger, TMOS_LeaseAbstractTigger_TEST
// Requirement User Story:
// Date & Developer: 12/30/2020 & BVELU
/**************************************************************************************************************/
public class TMOS_LeaseAbstractTriggerHandler {
    //Map to store SiteName and SiteId for existing Divestiture_Site__c records
    Map<String, Id> mapDivestitureSites = new Map<String, Id>(); 
    //Map to store Lease_ID__c and Id for existing Lease Abstract records
    Map<String, Id> mapLeaseAbstract = new Map<String, Id>(); 
    
    public void processTrigger(List<Lease_Abstract_Update__e> lstOfEvtLeaseAbstractObject){
        System.debug('In to trigger handler');
        System.debug('Total No of Events Received: ' + lstOfEvtLeaseAbstractObject.size());
        if(!lstOfEvtLeaseAbstractObject.isEmpty()){
            List<Lease_Abstract__c> lstLeaseAbstract = new List<Lease_Abstract__c>();
            List<Lease_Abstract__c> insertLeasAbstracts = new List<Lease_Abstract__c>(); // Insert LAs
            Map<Id, Lease_Abstract__c> updateLeaseAbstractsMap = new Map<Id, Lease_Abstract__c>(); //UPdate LAs
            Set<String> setLeaseAbstractIds = new Set<String>(); //Set to store LeaseAbstractId from Trigger.New (lstOfEvtLeaseAbstractObject)
            Set<String> setDivestitureSites = new Set<String>(); //Set to store DivestitureSite Names from Trigger.New (lstOfEvtLeaseAbstractObject)    
            
            //Populate the sets to hold the Divestiture Site Names and Lease_ID from trigger variable.
            for(Lease_Abstract_Update__e evtLeaseAbstract : lstOfEvtLeaseAbstractObject){
                if (evtLeaseAbstract.Lease_ID__c != '' && evtLeaseAbstract.Lease_ID__c != null) {
                    setLeaseAbstractIds.add(evtLeaseAbstract.Lease_ID__c);
                } else {
                    System.debug('Received Lease ID as Blank:' + evtLeaseAbstract);
                }
                if (evtLeaseAbstract.Divestiture_Site_ID_Text__c != '' && evtLeaseAbstract.Divestiture_Site_ID_Text__c != null){
                    setDivestitureSites.add(evtLeaseAbstract.Divestiture_Site_ID_Text__c);                    
                }
            } 
            //Fetch Divestiture SiteId and SiteNames for the set of SiteNames we have in setDivestitureSites and populate the mapDivestitureSites with SiteName and SiteId
            if(!setDivestitureSites.isEmpty()){
                for(Divestiture_Site__c objDS: [Select Id, Name from Divestiture_Site__c where Name IN : setDivestitureSites]){
                    mapDivestitureSites.put(objDS.Name, objDS.Id);
                }
            }
            //Fetch LeaseAbstract Id and Lease_ID__c for the set of Lease_ID__c we have in setLeaseAbstractIds and populate the mapLeaseAbstract with  Id and Lease_ID__c
            if(!setLeaseAbstractIds.isEmpty()){
                for(Lease_Abstract__c objLARef :  [Select Id, Lease_ID__c from Lease_Abstract__c where Lease_ID__c IN : setLeaseAbstractIds]){
                    mapLeaseAbstract.put(objLARef.Lease_ID__c, objLARef.Id);
                }
            }
            //Create Lease_Abstract__c object instance map the values from the Event object. 
            //Populate the Divestriture SiteId and LeaseAbstractId for existing objects from the Map and Bulkify the lstLeaseAbstract to upsert
            for(Lease_Abstract_Update__e evtLeaseAbstract : lstOfEvtLeaseAbstractObject){
                if (mapEventToObject(evtLeaseAbstract).Id == null) {
                    insertLeasAbstracts.add(mapEventToObject(evtLeaseAbstract));
                } else {
                    updateLeaseAbstractsMap.put(mapEventToObject(evtLeaseAbstract).Id, mapEventToObject(evtLeaseAbstract)); 
                }
            }
            
            //Insert LAs
            if (insertLeasAbstracts.size() > 0) {
                try{
                    insert insertLeasAbstracts;
                } catch(DmlException e) {
                    System.debug('DML Exception Occured Insert: ' + e.getMessage());
                    insertLog('DML Exception Occured Insert: ' + e.getMessage(), lstOfEvtLeaseAbstractObject.size(), insertLeasAbstracts.size(), updateLeaseAbstractsMap.size());
                } 
            }
            
            //Update LAs
            if (updateLeaseAbstractsMap.size() > 0) {
                try {
                    update updateLeaseAbstractsMap.values();
                } catch(DmlException e) {
                    System.debug('DML Exception Occured Update: ' + e.getMessage());
                    insertLog('DML Exception Occured Update: ' + e.getMessage(), lstOfEvtLeaseAbstractObject.size(), insertLeasAbstracts.size(), updateLeaseAbstractsMap.size() );
                }  
            }           
            //Insert Success message
            System.debug('Records Received: '+ lstOfEvtLeaseAbstractObject.size() + ' Updated: ' + updateLeaseAbstractsMap.size() + ' Inserted: ' + insertLeasAbstracts.size());
            insertLog('Records Received: '+ lstOfEvtLeaseAbstractObject.size() + ' Updated: ' + updateLeaseAbstractsMap.size() + ' Inserted: ' + insertLeasAbstracts.size(), lstOfEvtLeaseAbstractObject.size(), insertLeasAbstracts.size(), updateLeaseAbstractsMap.size() );
        }
    }
    public Lease_Abstract__c mapEventToObject(Lease_Abstract_Update__e evtLeaseAbstract){
        Lease_Abstract__c objLA = new Lease_Abstract__c();
        //Map Id to field to existing Lease Record, if found
        if(!mapLeaseAbstract.isEmpty()){
            if (mapLeaseAbstract.containsKey(evtLeaseAbstract.Lease_ID__c)) {                
                objLA.Id = mapLeaseAbstract.get(evtLeaseAbstract.Lease_ID__c);                                                
            } else {
                objLA.Name = evtLeaseAbstract.Divestiture_Site_ID_Text__c + '_LA';   
            }   
        }  else {
            objLA.Name = evtLeaseAbstract.Divestiture_Site_ID_Text__c + '_LA';
        }     
        
        objLA.Lease_ID__c = evtLeaseAbstract.Lease_ID__c;
        if(evtLeaseAbstract.Current_Monthly_Rent__c != null){
            objLA.Current_Monthly_Rent__c = evtLeaseAbstract.Current_Monthly_Rent__c / 12;
        }
        
        if (!mapDivestitureSites.isEmpty()){
            if (mapDivestitureSites.containsKey(evtLeaseAbstract.Divestiture_Site_ID_Text__c)) {  
                objLA.Divestiture_Site__c = mapDivestitureSites.get(evtLeaseAbstract.Divestiture_Site_ID_Text__c);  
            }
        }
        objLA.Divestiture_Site_ID_Text__c = evtLeaseAbstract.Divestiture_Site_ID_Text__c; // Discuss with PK
        objLA.Holdover__c = evtLeaseAbstract.Holdover__c;
        //Map Landlord details
        objLA.Landlord_Address__c = evtLeaseAbstract.Landlord_Address__c;
        objLA.Landlord_City__c = evtLeaseAbstract.Landlord_City__c;
        if (evtLeaseAbstract.Landlord_Email__c != null && evtLeaseAbstract.Landlord_Email__c != ''){
            if (checkEmail(evtLeaseAbstract.Landlord_Email__c)) {
                objLA.Landlord_Email__c = evtLeaseAbstract.Landlord_Email__c;
            }           
        }
        objLA.Landlord_Phone__c = evtLeaseAbstract.Landlord_Phone__c;
        objLA.Landlord_Site_ID__c = evtLeaseAbstract.Landlord_Site_ID__c;
        objLA.Landlord_State__c = evtLeaseAbstract.Landlord_State__c;
        objLA.Landlord_Zip_Code__c = evtLeaseAbstract.Landlord_Zip_Code__c;
        //Map Lease details
        objLA.Lease_Landlord__c = evtLeaseAbstract.Lease_Landlord__c;
        objLA.Lease_Name__c = evtLeaseAbstract.Lease_Name__c;
        objLA.Lease_Status__c = evtLeaseAbstract.Lease_Status__c;
        objLA.Lease_Term_End_Date__c = evtLeaseAbstract.Lease_Term_End_Date__c;
        objLA.Lease_Use__c = evtLeaseAbstract.Lease_Use__c;
        objLA.MLA__c = evtLeaseAbstract.MLA__c;
        //objLA.MLA_ID_C__c = evtLeaseAbstract.MLA_ID_C__c; ?
        objLA.NNR_Critical_Date__c = evtLeaseAbstract.NNR_Critical_Date__c;
        objLA.NNR_Reason__c = evtLeaseAbstract.NNR_Reason__c;
        objLA.Payee__c = evtLeaseAbstract.Payee__c;
        objLA.Square_Feet_of_Ground_Lease__c = evtLeaseAbstract.Square_Feet_of_Ground_Lease__c;
        objLA.T_Mobile_Unfettered_Assig_Right__c = evtLeaseAbstract.T_Mobile_Unfettered_Assig_Right__c;
        objLA.T_Mobile_Unfettered_Assig_Right_Doc__c = evtLeaseAbstract.T_Mobile_Unfettered_Assig_Right_Doc__c;
        objLA.T_Mo_Unfet_Modification_Right_Doc__c = evtLeaseAbstract.T_Mo_Unfet_Modification_Right_Doc__c;
        objLA.T_Mo_Unfet_Modification_Rights__c = evtLeaseAbstract.T_Mo_Unfet_Modification_Rights__c;
        objLA.T_Mo_Unfet_Termination_Rights__c = evtLeaseAbstract.T_Mo_Unfet_Termination_Rights__c;
        objLA.T_Mo_Unf_Termination_Doc_Section__c = evtLeaseAbstract.T_Mo_Unf_Termination_Doc_Section__c;
        objLA.Unres_24_7_Access_Rights_Doc_Sec__c = evtLeaseAbstract.Unres_24_7_Access_Rights_Doc_Sec__c;
        objLA.Unrestricted_24_7_Access_Rights__c = evtLeaseAbstract.Unrestricted_24_7_Access_Rights__c;
        return objLA;
    }
    public void insertLog(String sErrorText, Integer totalEventsReceived, Integer totalEventsInserted, Integer totalEventsUpdated){
        Platform_Event_Log__c objLog = new Platform_Event_Log__c();
        objLog.Event_Name__c = 'Lease_Abstract_Update__e';
        objLog.Name = 'Lease Abstract: ' + String.valueOf(datetime.now());
        objLog.Process_Date__c = date.today();
        objLog.Total_No_of_Event_Received__c = totalEventsReceived;
        objLog.Total_No_of_Events_Inserted__c = totalEventsInserted;
        objLog.Total_No_of_Events_Updated__c = totalEventsUpdated;
        objLog.Message__c = sErrorText;
        insert objLog;
    }
    
    public  Boolean checkEmail(String sEmail) {
        Boolean returnValue = true;
        String InputEmail = sEmail;
        String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';  
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(InputEmail);
        if (!MyMatcher.matches()) {
            returnValue = false;
        }
        return returnValue;    
    }  
}
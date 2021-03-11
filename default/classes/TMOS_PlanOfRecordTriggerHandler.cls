/*************************************************************************************************************************/
// Purpose: To Upsert Plan_Of_Record__c object when a record is inserted in a Plan_of_Record_Update__e (Platform Event)
// Registered Callers: TMOS_PlanOfRecordTrigger and TMOS_PlanOfRecordTigger_TEST
// Requirement User Story:
// Update / Insert Rule: If the Event record finds a match for the combination of  MacroSite, PlanOfRecordType and ProjectId
// 						 then it will be an update, else it will be an insert.
// Date & Developer: 01/06/2021 & BVELU
/************************************************************************************************************************/
public class TMOS_PlanOfRecordTriggerHandler {
    
    Map<String, String> mapPOR = new Map<String, Id>();
    Map<String, Id> mapOfMacroSiteNameId = new Map<String, Id>();
    public void processTrigger(List<Plan_of_Record_Update__e> lstPlanofRecordEvents){
        System.debug('Into Plan of Record Trigger Handler');
        System.debug('Total No of Plan of Reords Received: ' + lstPlanofRecordEvents.size());
        if(!lstPlanofRecordEvents.isEmpty()){
            
            Map<Id, Plan_Of_Record__c> updatePORmap = new Map<Id, Plan_Of_Record__c>();
            List<Plan_Of_Record__c> insertPORlist = new List<Plan_Of_Record__c>();           
            Set<String> setMacroSites = new Set<String>();
            set<String> setPORKey = new Set<String>();
            
            //Extract the set of MacroSites, PlanOfRecordType and ProjectId from each instance of the event
            for(Plan_of_Record_Update__e evtPOR: lstPlanofRecordEvents){
                System.debug('Received Event obejct :-->' + evtPOR);
                if(evtPOR.Macro_Site__c !=null && evtPOR.Macro_Site__c != ''){
                    setMacroSites.add(evtPOR.Macro_Site__c.split('-')[0]); 
                    setPORKey.add(evtPOR.Macro_Site__c.split('-')[0] + evtPOR.POR_Type__c + evtPOR.Project_ID__c);
                } else {
                    setPORKey.add(evtPOR.POR_Type__c + evtPOR.Project_ID__c);
                }
            }
            
            // Query the Macro_Site__c to find a match with Name with the Set: setMacroSites, macroSite.Divestiture_Site__r.Name
            for(Macro_Site__c objMacroSite : [SELECT Name, Divestiture_Site__r.Name From Macro_Site__c Where Divestiture_Site__r.Name IN :setMacroSites]){ 
                if(objMacroSite.Divestiture_Site__r.Name != null && objMacroSite.Divestiture_Site__r.Name != ''){
                    // Build of Map of Site Name (with assumptiom: matches Site_ID_Text__c on POR) and Id   
                    mapOfMacroSiteNameId.put(objMacroSite.Divestiture_Site__r.Name, objMacroSite.Id);                    
                }
            }   

            //Query PlanofRecord sObject for the set of MacroSites, PlanOfRecordType and ProjectId
            for(Plan_Of_Record__c objPOR: [SELECT Site_ID_Text__c, POR_Type__c, Project_ID__c From Plan_Of_Record__c Where POR_Key__c IN :setPORKey]){
                if(objPOR.Site_ID_Text__c == null || objPOR.Site_ID_Text__c == '' ) {
                    mapPOR.put( objPOR.POR_Type__c + objPOR.Project_ID__c, objPOR.Id);
                } else {
                    mapPOR.put(objPOR.Site_ID_Text__c.split('-')[0] + objPOR.POR_Type__c + objPOR.Project_ID__c, objPOR.Id);
                }
            }
           
            for(Plan_of_Record_Update__e evtObj: lstPlanofRecordEvents){
                Plan_Of_Record__c por = new Plan_Of_Record__c();
                por = mapEventObjectTosObject(evtObj);
                if (por.Id == null) {
                    insertPORlist.add(por);  
                } else {
                    updatePORmap.put(por.Id, por);
                }
            }	
            
            //Perform DML operations
            //Insert PORs
            if (insertPORlist.size() > 0) {
                try{
                    insert insertPORlist;
                } catch(DmlException e) {
                    System.debug('DML Exception Occured Insert: ' + e.getMessage());
                    insertLog('DML Exception Occured Insert: ' + e.getMessage(), lstPlanofRecordEvents.size(), insertPORlist.size(), updatePORmap.size());
                } 
            }
            
            //Update PORs
            if (updatePORmap.size() > 0) {
                try {
                    update updatePORmap.values();
                } catch(DmlException e) {
                    System.debug('DML Exception Occured Update: ' + e.getMessage());
                    insertLog('DML Exception Occured Update: ' + e.getMessage(), lstPlanofRecordEvents.size(), insertPORlist.size(), updatePORmap.size() );
                }  
            }    
            
            //Insert Success message
            System.debug('Records Received: '+ lstPlanofRecordEvents.size() + ' Updated: ' + updatePORmap.size() + ' Inserted: ' + insertPORlist.size());
            insertLog('Records Received: '+ lstPlanofRecordEvents.size() + ' Updated: ' + updatePORmap.size() + ' Inserted: ' + insertPORlist.size(), lstPlanofRecordEvents.size(), insertPORlist.size(), updatePORmap.size() );
            
        }
    }
    public Plan_Of_Record__c mapEventObjectTosObject(Plan_of_Record_Update__e evtObj){        
        
        Plan_Of_Record__c planofRec = new Plan_Of_Record__c();
        String macroSite = '';
        if (evtObj.Macro_Site__c == null || evtObj.Macro_Site__c == '') 
            macroSite = '';
        else
            macroSite = evtObj.Macro_Site__c.split('-')[0];
        
        System.debug('Match Key: ' + macroSite + evtObj.POR_Type__c + evtObj.Project_ID__c);
        
        if(mapPOR.containsKey(macroSite + evtObj.POR_Type__c + evtObj.Project_ID__c)){
            planofRec.Id = mapPOR.get(macroSite + evtObj.POR_Type__c + evtObj.Project_ID__c);
        }
        
        planofRec.Close_Out_Complete_Date__c = evtObj.Close_Out_Complete_Date__c;
        planofRec.Close_Out_Complete_Status__c = evtObj.Close_Out_Complete_Status__c;
        planofRec.Decom_Reason_Code__c = evtObj.Decom_Reason_Code__c;
        planofRec.POR_Status__c = evtObj.POR_Status__c;
        planofRec.POR_Type__c = evtObj.POR_Type__c; //Key Field
        planofRec.Release_Type__c = evtObj.Release_Type__c;
        planofRec.Remove_Equipment_Status__c = evtObj.Remove_Equipment_Status__c;
        planofRec.Remove_Equipment_Date__c = evtObj.Remove_Equipment_Date__c; //Review with PK
        planofRec.Site_Decommissioned_Date__c = evtObj.Site_Decommissioned_Date__c;
        planofRec.Site_Decommissioned_Status__c = evtObj.Site_Decommissioned_Status__c;
        if(evtObj.Macro_Site__c !=null && evtObj.Macro_Site__c != ''){
            planofRec.Site_ID_Text__c = evtObj.Macro_Site__c.split('-')[0];
            planofRec.Macro_Site__c = mapOfMacroSiteNameId.get(evtObj.Macro_Site__c.split('-')[0]); //Key Field
        }
        planofRec.Transmission_Ended_Site_Off_Air__c = evtObj.Transmission_Ended_Site_Off_Air__c;
        planofRec.Transmission_Ended_Site_Off_Air_Status__c = evtObj.Transmission_Ended_Site_Off_Air_Status__c;        
        planofRec.Project_ID__c = evtObj.Project_ID__c; //Key Field
        return planofRec;
    }
    
    
    public void insertLog(String sErrorText, Integer totalEventsReceived, Integer totalEventsInserted, Integer totalEventsUpdated){
        Platform_Event_Log__c objLog = new Platform_Event_Log__c();
        objLog.Event_Name__c = 'Plan_Of_Record_Update__e';
        objLog.Name = 'Plan Of Record: ' + String.valueOf(datetime.now());
        objLog.Process_Date__c = date.today();
        objLog.Total_No_of_Event_Received__c = totalEventsReceived;
        objLog.Total_No_of_Events_Inserted__c = totalEventsInserted;
        objLog.Total_No_of_Events_Updated__c = totalEventsUpdated;
        objLog.Message__c = sErrorText;
        insert objLog;
    }
}
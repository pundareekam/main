/***********************************************************************************************************************************************************************************
*	Purpose: To Upsert Macro_Site__c object when a record is inserted in a Macro_Site_Update__e Event 
*	Registered Callers: TMOS_MacroSiteUpdateTrigger, TMOS_MacroSiteUpdateTigger_TEST
*	Requirement User Story:
*	Date & Developer: 1/12/2021 & BVELU
*	1.	If Macro_Site_Id__c is not blank, Check for existing record Macro site id using Macro_Site_Id from Event Record and Upsert the existing record.
*		SOQL for search: SELECT Id From Macro_Site__c WHERE Divestiture_Site_Text__c = Macro_Site_ID__c
*	2.	If Cascade_Id_Legacy_Sprint__c is not blank, Check for existing record Macro site id using Cascade_Id_Legacy_Sprint__c from Event Record and Upsert the existing record
*		SOQL for search: SELECT Id From Macro_Site__c WHERE Divestiture_Site_Text__c = Cascade_Id_Legacy_Sprint__c
*	3.	If you don’t find existing Macro Site Record using Macro Site Id or Cascade Id or both fields are blank ignore the record	
***********************************************************************************************************************************************************************************/
public class TMOS_MacroSiteUpdateTriggerHandler {
    
    Map<String, Macro_Site__c> mapMacroSiteIdObject = new Map<String, Macro_Site__c>();
    public void processTrigger(List<Macro_Site_Update__e> lstMacroSiteEvents){
        
        Set<String> setmacroSiteIds = new Set<String>();
        Set<String> setcascadeIds = new Set<String>();
        Map<Id, Macro_Site__c> updateMacroSitemap = new Map<Id, Macro_Site__c>();
        System.debug('totalEventsReceived :' + lstMacroSiteEvents.size());
        
        for(Macro_Site_Update__e evtObj: lstMacroSiteEvents){
            if(evtObj.Macro_Site_ID__c != null && evtObj.Macro_Site_ID__c != ''){
                setmacroSiteIds.add(evtObj.Macro_Site_ID__c);
            } else if(evtObj.Cascade_ID_Legacy_Sprint__c != null && evtObj.Cascade_ID_Legacy_Sprint__c != ''){
                setmacroSiteIds.add(evtObj.Cascade_ID_Legacy_Sprint__c);
            }
        }        
        for(Macro_Site__c macroSite : [SELECT Divestiture_Site__r.Name, Divestiture_Site__c, Cascade_ID_Legacy_Sprint__c From Macro_Site__c WHERE Divestiture_Site__r.Name IN: setmacroSiteIds]){
            if(macroSite.Divestiture_Site__r.Name != null){
                mapMacroSiteIdObject.put(macroSite.Divestiture_Site__r.Name, macroSite); 
            }
        }
        
        for( Macro_Site_Update__e evtRec: lstMacroSiteEvents){
            Macro_Site__c objMacroSite = new Macro_Site__c();   
            objMacroSite = mapEventToSobject(evtRec);
            if(objMacroSite.Id != null){
                updateMacroSitemap.put(objMacroSite.Id, objMacroSite);
            } else {
                System.debug('Event to be Inserted in Future: ' + evtRec);
            }                
        }
        
        //Perform DMl operation on the bulkified updateMacroSitemap.values (Macro_Site__c)
        if(!updateMacroSitemap.isEmpty()){
            try{ 
                update updateMacroSitemap.values();     
            } catch(DmlException e){
                System.debug('DML exception occured Update: ' +  e.getMessage());
                insertLog('DML Exception Occured Update: ' + e.getMessage(), lstMacroSiteEvents.size(),0,updateMacroSitemap.size());
            }
            
            System.debug('Records Received: '+ lstMacroSiteEvents.size() + ' Updated: ' + updateMacroSitemap.size() + ' Inserted: 0');
            insertLog('Records Received: '+ lstMacroSiteEvents.size() + ' Updated: ' + updateMacroSitemap.size() + ' Inserted: 0', lstMacroSiteEvents.size(),0,updateMacroSitemap.size());
            
        }
    }
    public Macro_Site__c mapEventToSobject(Macro_Site_Update__e evtRec){
        Macro_Site__c objMacroSite = new Macro_Site__c(); 
        if(mapMacroSiteIdObject.containsKey(evtRec.Macro_Site_ID__c)){
            objMacroSite.Id = mapMacroSiteIdObject.get(evtRec.Macro_Site_ID__c).Id;     
            objMacroSite.Divestiture_Site__c = mapMacroSiteIdObject.get(evtRec.Macro_Site_ID__c).Divestiture_Site__c;
        } else if(mapMacroSiteIdObject.containsKey(evtRec.Cascade_ID_Legacy_Sprint__c)){
            objMacroSite.Id = mapMacroSiteIdObject.get(evtRec.Cascade_ID_Legacy_Sprint__c).Id;   
            objMacroSite.Divestiture_Site__c = mapMacroSiteIdObject.get(evtRec.Cascade_ID_Legacy_Sprint__c).Divestiture_Site__c;
        } 
        objMacroSite.Address__c = evtRec.Address__c;
        objMacroSite.City__c = evtRec.City__c;	
        objMacroSite.Decomm_Reason_Code__c = evtRec.Decomm_Reason_Code__c;	
        objMacroSite.Forced_Relocation_Code__c = evtRec.Forced_Relocation_Code__c;	
        objMacroSite.Forecasted_Logical_Decommission_Date__c = evtRec.Forecasted_Logical_Decommission_Date__c;	
        objMacroSite.Lattitude__c= evtRec.Lattitude__c;	
        objMacroSite.Legacy_Network__c= evtRec.Legacy_Network__c;
        objMacroSite.Lattitude__c= evtRec.Lattitude__c;
        objMacroSite.Longitude__c= evtRec.Longitude__c;
        objMacroSite.MLA_Flag__c= evtRec.MLA_Flag__c;
        objMacroSite.Market__c= evtRec.Market__c;
        objMacroSite.Rad_Center_ft__c= evtRec.Rad_Center_ft__c;
        objMacroSite.Region__c= evtRec.Region__c;
        objMacroSite.Site_Class__c= evtRec.Site_Class__c;
        objMacroSite.Site_Name__c= evtRec.Site_Name__c;
        objMacroSite.Site_Status__c= evtRec.Site_Status__c;
        objMacroSite.Cascade_ID_Legacy_Sprint__c = evtRec.Cascade_ID_Legacy_Sprint__c;
        objMacroSite.State__c= evtRec.State__c;
        objMacroSite.Structure_Type__c= evtRec.Structure_Type__c;
        objMacroSite.Zip_Code__c= evtRec.Zip_Code__c;
        return objMacroSite;    
    }
    public void insertLog(String sErrorText, Integer totalEventsReceived, Integer totalEventsInserted, Integer totalEventsUpdated){
        Platform_Event_Log__c objLog = new Platform_Event_Log__c();
        objLog.Event_Name__c = 'Macro_Site_Update__e';
        objLog.Name = 'Macro Site: ' + String.valueOf(datetime.now());
        objLog.Process_Date__c = date.today();
        objLog.Total_No_of_Event_Received__c = totalEventsReceived;
        objLog.Total_No_of_Events_Inserted__c = totalEventsInserted;
        objLog.Total_No_of_Events_Updated__c = totalEventsUpdated;
        objLog.Message__c = sErrorText;
        insert objLog;
    }
}
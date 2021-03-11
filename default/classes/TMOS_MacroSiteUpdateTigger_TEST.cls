/***********************************************************************************************************************************************************************************
*	Purpose: To provide code coverage for the TMOS_MacroSiteUpdateTrigger, TMOS_MacroSiteUpdateTigger_Handler
*	Registered Callers: Unit Test and Deployment vlaidations
*	Requirement User Story:
*	Date & Developer: 1/14/2021 & BVELU
************************************************************************************************************************************************************************************/
@isTest
public class TMOS_MacroSiteUpdateTigger_TEST {
    static Integer maxRecords = 20;
        static Map<String, String> mapDivSiteNameId = new Map<String, String>(); 
	@testSetup
    public static void setupTestData(){
        List<Divestiture_Site__c> lstDivSite = new List<Divestiture_Site__c>();
        for(Integer i=1; i<=maxRecords; i++){
       		Divestiture_Site__c objDivSite = new Divestiture_Site__c();
            objDivSite.Name = 'Test Divestiture' + i;
             //setDivestitureName.add(objDivSite.Name);
            lstDivSite.add(objDivSite);
        }
        insert lstDivSite;
        for(Divestiture_Site__c divSite: lstDivSite){
        	mapDivSiteNameId.put(divSite.Site_Name__c, divSite.Id);
        }
        //Create Macro Site        
        List<Macro_Site__c> lstMacroSite = new List<Macro_Site__c>();
        for(Integer i=1; i<=(maxRecords/2); i++){
       		Macro_Site__c objMacroSite = new Macro_Site__c();
            //objMacroSite.Name = 'Test Divestiture' + i;
            objMacroSite.Site_Name__c = 'Test Divestiture' + i;
        	objMacroSite.Divestiture_Site__c = mapDivSiteNameId.get('Test Divestiture' + i);
            lstMacroSite.add(objMacroSite);
        }
        for(Integer i=(maxRecords/2)+1; i<=maxRecords; i++){
       		Macro_Site__c objMacroSite = new Macro_Site__c();
            objMacroSite.Cascade_ID_Legacy_Sprint__c = 'Test Divestiture' + i;
        	objMacroSite.Divestiture_Site__c = mapDivSiteNameId.get('Test Divestiture' + i);
            lstMacroSite.add(objMacroSite);
        }
        insert lstMacroSite;
    }
    @isTest
    static void singlePlanUpdateMacroSiteId(){
        List<Macro_Site_Update__e> lstMacroSiteEvent = new List<Macro_Site_Update__e>();
        Macro_Site_Update__e evtRec = new Macro_Site_Update__e();
        evtRec.Macro_Site_ID__c = 'Test Divestiture1';
        evtRec.Address__c = 'Test Address';
        evtRec.City__c = 'Marlton';	
        evtRec.Decomm_Reason_Code__c = 'Teast Reason Code';	
        evtRec.Forced_Relocation_Code__c = 'Test Forced Relocation Code';	
        //evtRec.Forecasted_Logical_Decommission_Date__c = 'Test Forecasted Logical Decomm Date';	
        evtRec.Lattitude__c = 'Test Lat';	
        evtRec.Legacy_Network__c = 'Test Metro PCS';
        evtRec.Longitude__c = 'Test Longitude';
        evtRec.MLA_Flag__c = 'Y';
        evtRec.Market__c = 'North East';
        evtRec.Rad_Center_ft__c = '10';
        evtRec.Region__c ='Test North East';
        evtRec.Site_Class__c = 'A';
        evtRec.Site_Status__c = 'Active';
        //evtRec.Cascade_ID_Legacy_Sprint__c = 'Test Divestiture1';
        evtRec.State__c = 'NJ';
        evtRec.Structure_Type__c = 'Tower';
        evtRec.Zip_Code__c = '08050';
        lstMacroSiteEvent.add(evtRec);
        Test.startTest();
        publishEvent(lstMacroSiteEvent);
        Test.stopTest();
        system.debug('MacroSite Object:' + [Select Region__c, Name from Macro_Site__c where Region__c = 'Test North East' and Divestiture_Site__r.name = 'Test Divestiture1']);
        //MacroSite Object:(Macro_Site__c:{Region__c=Test North East, Name=Test Divestiture1_MS, Divestiture_Site__c=a1fZ0000004MIm7IAG, Id=a2MZ0000001zRekMAE})
        Integer recCount = [Select count() from Macro_Site__c where Region__c = 'Test North East' and Divestiture_Site__r.name = 'Test Divestiture1'];
        System.assertEquals(1, recCount, 'Not an expected count');
    }
    @isTest
    static void singlePlanUpdateCascadeId(){
        List<Macro_Site_Update__e> lstMacroSiteEvent = new List<Macro_Site_Update__e>();
        Macro_Site_Update__e evtRec = new Macro_Site_Update__e();
        //evtRec.Macro_Site_ID__c = 'Test Divestiture7';
        evtRec.Address__c = 'Test Address';
        evtRec.City__c = 'Marlton';	
        evtRec.Decomm_Reason_Code__c = 'Teast Reason Code';	
        evtRec.Forced_Relocation_Code__c = 'Test Forced Relocation Code';	
        //evtRec.Forecasted_Logical_Decommission_Date__c = 'Test Forecasted Logical Decomm Date';	
        evtRec.Lattitude__c = 'Test Lat';	
        evtRec.Legacy_Network__c = 'Test Metro PCS';
        evtRec.Longitude__c = 'Test Longitude';
        evtRec.MLA_Flag__c = 'Y';
        evtRec.Market__c = 'North East Upper';
        evtRec.Rad_Center_ft__c = '10';
        evtRec.Region__c ='Test North East Upper';
        evtRec.Site_Class__c = 'A';
        evtRec.Site_Status__c = 'Active';
        evtRec.Cascade_ID_Legacy_Sprint__c = 'Test Divestiture7';
        evtRec.State__c = 'NJ';
        evtRec.Structure_Type__c = 'Tower';
        evtRec.Zip_Code__c = '08050';
        lstMacroSiteEvent.add(evtRec);
        Test.startTest();
        publishEvent(lstMacroSiteEvent);
        Test.stopTest();
        System.debug('MacroSite Object:' + [Select Region__c, Name from Macro_Site__c where Region__c = 'Test North East Upper' and Divestiture_Site__r.name = 'Test Divestiture7']);
        Integer recCount = [Select count() from Macro_Site__c where Region__c = 'Test North East Upper' and Divestiture_Site__r.name = 'Test Divestiture7'];
        System.assertEquals(1, recCount, 'Not an expected count');
    }
    @isTest
    static void multiPlanUpdateMacroSiteId(){
        List<Macro_Site_Update__e> lstMacroSiteEvent = new List<Macro_Site_Update__e>();
        Set<String> setDivestitureName = new Set<String>();
        for(Integer i=1;i<=maxRecords; i++)
        {
            Macro_Site_Update__e evtRec = new Macro_Site_Update__e();
            evtRec.Macro_Site_ID__c = 'Test Divestiture' + i;
            evtRec.Address__c = 'Test Address';
            evtRec.City__c = 'Marlton';	
            evtRec.Decomm_Reason_Code__c = 'Teast Reason Code';	
            evtRec.Forced_Relocation_Code__c = 'Test Forced Relocation Code';	
            //evtRec.Forecasted_Logical_Decommission_Date__c = 'Test Forecasted Logical Decomm Date';	
            evtRec.Lattitude__c = 'Test Lat';	
            evtRec.Legacy_Network__c = 'Test Metro PCS';
            evtRec.Longitude__c = 'Test Longitude';
            evtRec.MLA_Flag__c = 'Y';
            evtRec.Market__c = 'North East';
            evtRec.Rad_Center_ft__c = '10';
            evtRec.Region__c ='Test North East';
            evtRec.Site_Class__c = 'A';
            evtRec.Site_Status__c = 'Active';
            //evtRec.Cascade_ID_Legacy_Sprint__c = 'Test Divestiture1';
            evtRec.State__c = 'NJ';
            evtRec.Structure_Type__c = 'Tower';
            evtRec.Zip_Code__c = '08050';
            setDivestitureName.add(evtRec.Macro_Site_ID__c);
            lstMacroSiteEvent.add(evtRec);
        }
        Test.startTest();
        publishEvent(lstMacroSiteEvent);
        Test.stopTest();
        system.debug('MacroSite Object:' + [Select Region__c, Name from Macro_Site__c where Region__c = 'Test North East' and Divestiture_Site__r.name in: setDivestitureName]);
        //MacroSite Object:(Macro_Site__c:{Region__c=Test North East, Name=Test Divestiture1_MS, Divestiture_Site__c=a1fZ0000004MIm7IAG, Id=a2MZ0000001zRekMAE})
        Integer recCount = [Select count() from Macro_Site__c where Region__c = 'Test North East' and Divestiture_Site__r.name in: setDivestitureName];
        System.assertEquals(maxRecords, recCount, 'Not an expected count');
    }
    @isTest
    static void multiPlanUpdateCascadeId(){
        List<Macro_Site_Update__e> lstMacroSiteEvent = new List<Macro_Site_Update__e>();
        Set<String> setDivestitureName = new Set<String>();
        for(Integer i=1;i<=maxRecords; i++)
        {
            Macro_Site_Update__e evtRec = new Macro_Site_Update__e();
            //evtRec.Macro_Site_ID__c = 'Test Divestiture' + i;
            evtRec.Address__c = 'Test Address';
            evtRec.City__c = 'Marlton';	
            evtRec.Decomm_Reason_Code__c = 'Teast Reason Code';	
            evtRec.Forced_Relocation_Code__c = 'Test Forced Relocation Code';	
            //evtRec.Forecasted_Logical_Decommission_Date__c = 'Test Forecasted Logical Decomm Date';	
            evtRec.Lattitude__c = 'Test Lat';	
            evtRec.Legacy_Network__c = 'Test Metro PCS';
            evtRec.Longitude__c = 'Test Longitude';
            evtRec.MLA_Flag__c = 'Y';
            evtRec.Market__c = 'North East';
            evtRec.Rad_Center_ft__c = '10';
            evtRec.Region__c ='Test South West';
            evtRec.Site_Class__c = 'A';
            evtRec.Site_Status__c = 'Active';
            evtRec.Cascade_ID_Legacy_Sprint__c = 'Test Divestiture' + i;
            evtRec.State__c = 'NJ';
            evtRec.Structure_Type__c = 'Tower';
            evtRec.Zip_Code__c = '08050';
            setDivestitureName.add(evtRec.Cascade_ID_Legacy_Sprint__c);
            lstMacroSiteEvent.add(evtRec);
        }
        Test.startTest();
        publishEvent(lstMacroSiteEvent);
        Test.stopTest();
        system.debug('MacroSite Object:' + [Select Region__c, Name from Macro_Site__c where Region__c = 'Test South West' and Divestiture_Site__r.name in: setDivestitureName]);
        //MacroSite Object:(Macro_Site__c:{Region__c=Test North East, Name=Test Divestiture1_MS, Divestiture_Site__c=a1fZ0000004MIm7IAG, Id=a2MZ0000001zRekMAE})
        Integer recCount = [Select count() from Macro_Site__c where Region__c = 'Test South West' and Divestiture_Site__r.name in: setDivestitureName];
        System.assertEquals(maxRecords, recCount, 'Not an expected count');
    }
    static void publishEvent(List<Macro_Site_Update__e> lstMacroSiteEvent){
         //TMOS_MacroSiteUpdateTriggerHandler trigHandle = new TMOS_MacroSiteUpdateTriggerHandler();
         //trigHandle.processTrigger(lstMacroSiteEvent);
        Database.SaveResult[] lstResult = EventBus.publish(lstMacroSiteEvent);
        for(Database.SaveResult res: lstResult){
            if(res.isSuccess()){
                System.debug('Successfully published event.');
            }              
        }       
    }
}
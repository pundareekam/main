/*************************************************************************************************************************/
// Purpose: To provide test coverage for TMOS_PlanOfRecordTrigger & TMOS_PlanOfRecordTriggerHandler
// Registered Callers: TMOS_PlanOfRecordTrigger, 
// Requirement User Story:
// Update / Insert Rule: If the Event record finds a match for the combination of  MacroSite, PlanOfRecordType and ProjectId
// 						 then it will be an update, else it will be an insert.
// Date & Developer: 01/06/2021 & BVELU
/************************************************************************************************************************/
@isTest
public class TMOS_PlanOfRecordTigger_TEST {
    static Integer maxRecords = 10;
    static Map<String, String> mapDivSiteNameId = new Map<String, String>(); 
    static Map<String, String> mapMacroSiteNameId = new Map<String, String>();
   
    @testSetup
    static void createTestData(){
        //Create Divestiture Site Record - Divestiture_Site__c           	
        List<Divestiture_Site__c> lstDivSite = new List<Divestiture_Site__c>();
        for(Integer i=1; i<=maxRecords; i++){
            Divestiture_Site__c objDivSite = new Divestiture_Site__c();
            objDivSite.Name = 'Test Divestiture' + i;
            objDivSite.Site_Name__c = 'Test Divestiture' + i;
            lstDivSite.add(objDivSite);
        }
        insert lstDivSite;
        for(Divestiture_Site__c divSite: lstDivSite){
            mapDivSiteNameId.put(divSite.Site_Name__c, divSite.Id);
        }
        
        //get Plan of Records
        for(Macro_Site__c macroSite : [Select Id, Name from Macro_Site__c where Divestiture_Site__r.Name like 'Test Divestiture%']){
            mapMacroSiteNameId.put(macroSite.Name, macroSite.Id);
        }
        System.debug('Test Data **mapMacroSiteNameId** -->' + mapMacroSiteNameId);
        List<Plan_Of_Record__c> lstTestPlanOfRecords = new List<Plan_Of_Record__c>();
        Map<String, String> mapPORKeysId = new Map<String, String>();
        for(Integer i=1; i<= maxRecords; i++){
            Plan_Of_Record__c objTestPlanofRec = new Plan_Of_Record__c();
            objTestPlanofRec.POR_Type__c = 'CWE-WiMAX Decomm';
            objTestPlanofRec.Project_ID__c = '100' + String.valueOf(i);     
            objTestPlanofRec.Macro_Site__c = mapMacroSiteNameId.get('Test Divestiture' + String.valueOf(i) + '_MS'); 
            lstTestPlanOfRecords.add(objTestPlanofRec);
        }
        if(!lstTestPlanOfRecords.isEmpty()){
            insert lstTestPlanOfRecords;
            System.debug('Test Data **lstTestPlanOfRecords** -->' + lstTestPlanOfRecords);
        }     
        // Insert Plan of Record
        Plan_Of_Record__c p = new Plan_Of_Record__c();
        p.Site_ID_Text__c = 'TEST MACRO SITE';
        p.POR_Type__c = 'DECOM';
        p.Project_ID__c = 'TESTPROJ1';
        insert p;
    }
    @isTest
    static void singlePlanInsertTest(){
        List<Plan_of_Record_Update__e> lstPOREvent = new List<Plan_of_Record_Update__e>();
        Plan_of_Record_Update__e evt = new Plan_of_Record_Update__e();
        evt.POR_Type__c = 'DECOM';
        evt.Project_ID__c = '1999';
        evt.Macro_Site__c = 'Test MacroSite';
        //evt.Site_ID_Text__c = 'Test MacroSite';
        lstPOREvent.add(evt);
        Test.startTest();
        publishEvent(lstPOREvent);
        Test.stopTest();
        List<Plan_Of_Record__c> lstofPlanRecords = [Select POR_Type__c, Project_ID__c, Macro_Site__c from Plan_Of_Record__c where Project_ID__c = '1999' and POR_Type__c = 'DECOM'];
        system.debug('lstofPlanRecords :' + lstofPlanRecords);
        Integer recCount = [Select count() from Plan_Of_Record__c where Project_ID__c = '1999' and POR_Type__c = 'DECOM'];
        System.assertEquals(1, recCount, 'Not an expected count');
        if(!lstofPlanRecords.isEmpty()){
            for(Plan_Of_Record__c plan: lstofPlanRecords){
                System.assertEquals('1999', plan.Project_ID__c, 'Not an expected Project Id');
                System.assertEquals('DECOM', plan.POR_Type__c, 'Not an expected Plan Type');
            }
        }
    }
    @isTest
    static void multiplePlanInsertTest(){
        List<Plan_of_Record_Update__e> lstPOREvent = new List<Plan_of_Record_Update__e>();
        for(Integer k=1; k<=maxRecords;k++){
            Plan_of_Record_Update__e evt = new Plan_of_Record_Update__e();
            evt.POR_Type__c = 'DECOM';
            evt.Project_ID__c = '5000Test'+ k;
            //evt.Macro_Site__c =  mapMacroSiteNameId.get('Test MacroSite New' + k + '_a');
            evt.Macro_Site__c = 'Test MacroSite New' + k;
            evt.Site_ID_Text__c = mapMacroSiteNameId.get('Test MacroSite New' + k);
            lstPOREvent.add(evt);
        }
        Test.startTest();
        publishEvent(lstPOREvent);
        Test.stopTest();        
        Integer recCount = [Select count() from Plan_Of_Record__c where Project_ID__c like '5000Test%' and POR_Type__c = 'DECOM'];
        System.assertEquals(maxRecords, recCount, 'Not an expected count');
    }
    @isTest
    static void singlePlanUpdateRecordFoundTest(){
        List<Plan_of_Record_Update__e> lstPOREvent = new List<Plan_of_Record_Update__e>();
        Plan_of_Record_Update__e evt = new Plan_of_Record_Update__e();
        evt.POR_Type__c = 'CWE-WiMAX Decomm';
        evt.Project_ID__c = '1001'; 
        evt.Macro_Site__c = 'Test Divestiture1-MS';  
        //evt.Site_ID_Text__c = planrec.Site_ID_Text__c;    
        evt.POR_Status__c = 'Active';
        lstPOREvent.add(evt);
        Test.startTest();
        publishEvent(lstPOREvent);
        Test.stopTest();
        Integer newCount = [Select count() from Plan_Of_Record__c where Project_ID__c = '1001' and POR_Type__c = 'CWE-WiMAX Decomm' and POR_Status__c = 'Active'];
        System.debug('newCount:' + newCount);
        System.assertEquals(1, newCount, 'Not an expected count');    
    }
    @isTest
    static void singlePlanUpdateRecordNotFoundTest(){
        List<Plan_of_Record_Update__e> lstPOREvent = new List<Plan_of_Record_Update__e>();
        Plan_of_Record_Update__e evt = new Plan_of_Record_Update__e();
        evt.POR_Type__c = 'DECOMM';
        evt.Project_ID__c = '99019';
        evt.Macro_Site__c = 'Test Divestiture1';
        evt.POR_Status__c = 'In Active';
        lstPOREvent.add(evt);
        Test.startTest();
        publishEvent(lstPOREvent);
        Test.stopTest();
        Integer newCount = [Select count() from Plan_Of_Record__c where Project_ID__c = '99019' and POR_Type__c = 'DECOMM' and POR_Status__c = 'In Active'];
        System.assertEquals(1, newCount, 'Not an expected count');     
    }
    @isTest
    static void multiplePlanUpdateTest(){     
        List<Plan_of_Record_Update__e> lstPOREvent = new List<Plan_of_Record_Update__e>();
        for(Integer k=1; k<=maxRecords;k++){
            Plan_of_Record_Update__e evt = new Plan_of_Record_Update__e();
            evt.POR_Type__c = 'CWE-WiMAX Decomm';
            evt.Project_ID__c = '100' + String.valueOf(k);  
            evt.Macro_Site__c = 'Test Divestiture' + String.valueOf(k);  
            evt.POR_Status__c = 'Suspended';
            lstPOREvent.add(evt);            
        }
        Test.startTest();
        publishEvent(lstPOREvent);
        Test.stopTest();
        Integer newCount = [Select count() from Plan_Of_Record__c where POR_Status__c = 'Suspended'];
        System.assertEquals(maxRecords, newCount, 'Not an expected count');
    }
    static void publishEvent(List<Plan_of_Record_Update__e> lstPOREvents){
        Database.SaveResult[] lstResult = EventBus.publish(lstPOREvents);
        for(Database.SaveResult res: lstResult){
            if(res.isSuccess()){
                System.debug('Successfully published event.');
            }              
        }        
    }
    
    @isTest
    static void noMacroSiteTest(){
        List<Plan_of_Record_Update__e> lstPOREvent = new List<Plan_of_Record_Update__e>();
        Plan_of_Record_Update__e evt = new Plan_of_Record_Update__e();
        evt.POR_Type__c = 'DECOMM1';
        evt.Project_ID__c = '990191';
        evt.POR_Status__c = 'In Active';
        lstPOREvent.add(evt);
        Test.startTest();
        publishEvent(lstPOREvent);
        Test.stopTest();
        Integer newCount = [Select count() from Plan_Of_Record__c where Project_ID__c = '990191' and POR_Type__c = 'DECOMM1' and POR_Status__c = 'In Active'];
        System.assertEquals(1, newCount, 'Not an expected count1');     
    }
    
    @isTest
    static void updatePORTest(){
        // Insert Divestiture Site
        Divestiture_Site__c objDivSite = new Divestiture_Site__c();
        objDivSite.Name = 'TEST MACRO SITE Bala';
        objDivSite.Site_Name__c = 'TEST MACRO SITE Bala';
        insert objDivSite;
        //Get MAcroSiteId
        Macro_Site__c macroSite = [Select Id, Name from Macro_Site__c where Divestiture_Site__r.Name = 'TEST MACRO SITE Bala'];
        // Insert Plan of Record
        Plan_Of_Record__c p = new Plan_Of_Record__c();
        p.Site_ID_Text__c = 'TEST MACRO SITE Bala';
        p.POR_Type__c = 'DECOM';
        p.Project_ID__c = 'TESTPROJ1';
        p.Macro_Site__c = macroSite.Id;
        insert p;
        String sKey = (macroSite.Name).split('_')[0] + p.POR_Type__c + p.Project_ID__c;
        //Site_ID_Text__c.split('-')[0]
        System.debug('sKey:' + sKey);
        //POR_Key__c=TEST MACRO SITE Bala*DECOM*TESTPROJ1
        System.debug('POR Inserted: ' + ([SELECT Site_ID_Text__c, Macro_Site__c, Macro_Site__r.Id, Macro_Site__r.Name, POR_Type__c, Project_ID__c, POR_Key__c From Plan_Of_Record__c Where Site_ID_Text__c = 'TEST MACRO SITE Bala' ]));        
        System.debug('POR Inserted: ' + ([SELECT Site_ID_Text__c, Macro_Site__c, Macro_Site__r.Id, Macro_Site__r.Name, POR_Type__c, Project_ID__c, POR_Key__c From Plan_Of_Record__c Where POR_Key__c =: sKey]));        
        List<Plan_of_Record_Update__e> lstPOREvent = new List<Plan_of_Record_Update__e>();
        Plan_of_Record_Update__e evt = new Plan_of_Record_Update__e();
        evt.Macro_Site__c = 'TEST MACRO SITE Bala';
        evt.POR_Type__c = 'DECOM';
        evt.Project_ID__c = 'TESTPROJ1';
        evt.POR_Status__c = 'In Active';
        lstPOREvent.add(evt);
        Test.startTest();
        publishEvent(lstPOREvent);
        Test.stopTest();
        Integer newCount = [Select count() from Plan_Of_Record__c where Project_ID__c = 'TESTPROJ1' and POR_Type__c = 'DECOM' and POR_Status__c = 'In Active'];
        System.assertEquals(1, newCount, 'Updated Record Count');     
    }
    @isTest
    static void updatePORTest_NoSiteIdText(){
       
        // Insert Plan of Record
        Plan_Of_Record__c p = new Plan_Of_Record__c();
        p.Site_ID_Text__c = '';
        p.POR_Type__c = 'DECOM';
        p.Project_ID__c = 'TESTPROJ1';
        insert p;
        String sKey = p.POR_Type__c + p.Project_ID__c;
        //Site_ID_Text__c.split('-')[0]
        System.debug('sKey:' + sKey);

        List<Plan_of_Record_Update__e> lstPOREvent = new List<Plan_of_Record_Update__e>();
        Plan_of_Record_Update__e evt = new Plan_of_Record_Update__e();
        evt.Macro_Site__c = '';
        evt.POR_Type__c = 'DECOM';
        evt.Project_ID__c = 'TESTPROJ1';
        evt.POR_Status__c = 'In Active';
        lstPOREvent.add(evt);
        Test.startTest();
        publishEvent(lstPOREvent);
        Test.stopTest();
        Integer newCount = [Select count() from Plan_Of_Record__c where Project_ID__c = 'TESTPROJ1' and POR_Type__c = 'DECOM' and POR_Status__c = 'In Active'];
        System.assertEquals(1, newCount, 'Updated Record Count');     
    }
}
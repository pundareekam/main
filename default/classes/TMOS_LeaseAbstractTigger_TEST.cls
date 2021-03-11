/**************************************************************************************************************/
// Purpose: Test class to provide coverage for: TMOS_LeaseAbstractTrigger, TMOS_LeaseAbstractTriggerHandler 
// Registered Callers: Test Suites, Test Runs
// Requirement User Story:
// Date & Developer: 01/04/2021 & BVELU
/**************************************************************************************************************/
@isTest
class TMOS_LeaseAbstractTigger_TEST {
    @testSetup 
    static void CreateTestData() {
        Integer maxRecords = 10;
        Map<String, String> mapDivSiteName_Id = new Map<String, String>();
        Map<String, String> mapLeaseId = new Map<String, String>();
     	//Create Divestiture Site Record - Divestiture_Site__c
     	List<Divestiture_Site__c> lstDivSite = new List<Divestiture_Site__c>();
        for(Integer i=1; i<=maxRecords; i++){
       		Divestiture_Site__c objDivSite = new Divestiture_Site__c();
            objDivSite.Name = 'Test Divestiture' + i;
        	objDivSite.Site_Name__c = 'Test Divestiture' + i;
            lstDivSite.add(objDivSite);
        }
        insert lstDivSite;
        for(Divestiture_Site__c DivSite: lstDivSite){
        	mapDivSiteName_Id.put(DivSite.Site_Name__c, DivSite.Id);
        }
     	//Create Lease Abstract Record - Lease_Abstract__c
     	List<Lease_Abstract__c> lstLeaseAbstract = new List<Lease_Abstract__c>();
        for(Integer k=1; k<=maxRecords; k++){
            Lease_Abstract__c objLA = new Lease_Abstract__c();
            objLA.Lease_ID__c = '99' + k;
            objLA.Current_Monthly_Rent__c = 5000;
            objLA.Landlord_City__c = 'New York';
            objLA.Divestiture_Site__c = mapDivSiteName_Id.get('Test Site' + k);
            objLA.Divestiture_Site_ID_Text__c = mapDivSiteName_Id.get('Test Site' + k);
            objLA.Lease_Name__c = '99 Test Lease' + k;                   
            lstLeaseAbstract.add(objLA);
        }
        insert lstLeaseAbstract;     
    } 
    @isTest 
    static void singleEventToInsertLA(){
        Integer j = 1;
        List<Lease_Abstract_Update__e> lstLeaseAb = new List<Lease_Abstract_Update__e>();
        Lease_Abstract_Update__e LAevt = new Lease_Abstract_Update__e();
        //LAevt.Lease_ID__c = [Select Id from Lease_Abstract__c where Lease_ID__c = '991123'][0].Id;
        LAevt.Lease_ID__c = '1-12345';
        //LAevt.Lease_Name__c = '99 Test Lease1123' + j;  
        //LAevt.Divestiture_Site_ID_Text__c = [Select Id from Divestiture_Site__c where Site_Name__c = 'Test Site1'][0].Id;
         LAevt.Divestiture_Site_ID_Text__c = '19021';
        LAevt.Holdover__c = '';
        LAevt.Landlord_Address__c = j + ', Test Address';
        LAevt.Landlord_City__c = 'Edison';
        LAevt.Landlord_Email__c = 'balamurugan.velu1@tmobile.com';
        LAevt.Landlord_Phone__c = '201-234-7656';
        LAevt.Landlord_Site_ID__c = '1-123';
        LAevt.Landlord_State__c = 'NJ';
        LAevt.Landlord_Zip_Code__c = '08053';
        LAevt.Lease_Landlord__c = 'Test Landlord';
        LAevt.Lease_Name__c = 'Test Landlord Lease';
        LAevt.Lease_Status__c = 'Active';
        LAevt.Lease_Term_End_Date__c = date.parse('5/1/2021');
        LAevt.Lease_Use__c = 'Active';
        LAevt.Current_Monthly_Rent__c = 12345.45;
        LAevt.MLA__c = 'Yes';
        //objLA.MLA_ID_C__c = evtLeaseAbstract.MLA_ID_C__c; ?
        LAevt.NNR_Critical_Date__c = date.parse('02/05/2020');
        LAevt.NNR_Reason__c = 'Test Reason';
        LAevt.Payee__c = 'Test Payee';
        LAevt.Square_Feet_of_Ground_Lease__c = 10256;
        LAevt.T_Mobile_Unfettered_Assig_Right__c = 'Yes';
        LAevt.T_Mobile_Unfettered_Assig_Right_Doc__c = 'Yes'; 
        LAevt.T_Mo_Unfet_Modification_Right_Doc__c = 'No';
        LAevt.T_Mo_Unfet_Modification_Rights__c = 'No';
        LAevt.T_Mo_Unfet_Termination_Rights__c ='Yes';
        LAevt.T_Mo_Unf_Termination_Doc_Section__c = 'Yes';
        LAevt.Unres_24_7_Access_Rights_Doc_Sec__c = 'Yes';
        LAevt.Unrestricted_24_7_Access_Rights__c = 'Yes';
        lstLeaseAb.add(LAevt);
        //TMOS_LeaseAbstractTriggerHandler.processTrigger(lstLeaseAb);
        Test.startTest();
        publishEvent(lstLeaseAb);
        Test.stopTest();
       	Lease_Abstract__c LARecord = [select Lease_Name__c from Lease_Abstract__c where Lease_ID__c = '1-12345' Limit 1];
        System.assertEquals('Test Landlord Lease', LARecord.Lease_Name__c, 'Looks like the record was not inserted');
    }
    @isTest 
    static void singleEventToUpdateLA(){
        Integer j = 1;
        List<Lease_Abstract_Update__e> lstLeaseAb = new List<Lease_Abstract_Update__e>();
        Lease_Abstract_Update__e LAevt = new Lease_Abstract_Update__e();
        //String LAId = [Select Id from Lease_Abstract__c where Lease_ID__c = '991' Limit 1][0].Id;
        String LAId = '991';
        LAevt.Lease_ID__c = LAId;
        system.debug('LAId : ' + LAId);
        //LAevt.Lease_Name__c = '99 Test Lease1123' + j;  
        //String DivestitureSiteId = [Select Id from Divestiture_Site__c where Site_Name__c = 'Test Divestiture1' Limit 1][0].Id;
        String DivestitureSiteId = 'Test Divestiture1';
        system.debug('DivestitureSiteId : ' + DivestitureSiteId);
        LAevt.Divestiture_Site_ID_Text__c = DivestitureSiteId;
        LAevt.Holdover__c = '';
        LAevt.Landlord_Address__c = j + ', Test Address';
        LAevt.Landlord_City__c = 'Edison';
        LAevt.Landlord_Email__c = 'balamurugan.velu1@tmobile.com';
        LAevt.Landlord_Phone__c = '201-234-7656';
        LAevt.Landlord_Site_ID__c = '1-123';
        LAevt.Landlord_State__c = 'NJ';
        LAevt.Landlord_Zip_Code__c = '08053';
        LAevt.Lease_Landlord__c = 'Test Landlord';
        LAevt.Lease_Name__c = 'Test Landlord Lease Updated';
        LAevt.Lease_Status__c = 'Active';
        LAevt.Lease_Term_End_Date__c = date.parse('5/1/2021');
        LAevt.Lease_Use__c = 'Active';
        LAevt.MLA__c = 'Yes';
        //objLA.MLA_ID_C__c = evtLeaseAbstract.MLA_ID_C__c; ?
        LAevt.NNR_Critical_Date__c = date.parse('02/05/2020');
        LAevt.NNR_Reason__c = 'Test Reason';
        LAevt.Payee__c = 'Test Payee';
        LAevt.Square_Feet_of_Ground_Lease__c = 10256;
        LAevt.T_Mobile_Unfettered_Assig_Right__c = 'Yes';
        LAevt.T_Mobile_Unfettered_Assig_Right_Doc__c = 'Yes'; 
        LAevt.T_Mo_Unfet_Modification_Right_Doc__c = 'No';
        LAevt.T_Mo_Unfet_Modification_Rights__c = 'No';
        LAevt.T_Mo_Unfet_Termination_Rights__c ='Yes';
        LAevt.T_Mo_Unf_Termination_Doc_Section__c = 'Yes';
        LAevt.Unres_24_7_Access_Rights_Doc_Sec__c = 'Yes';
        LAevt.Unrestricted_24_7_Access_Rights__c = 'Yes';
        lstLeaseAb.add(LAevt);
        //TMOS_LeaseAbstractTriggerHandler.processTrigger(lstLeaseAb);
        Test.startTest();
        publishEvent(lstLeaseAb);
        Test.stopTest();
       	Lease_Abstract__c LARecord = [select Lease_Name__c, Divestiture_Site_ID_Text__c from Lease_Abstract__c where Lease_ID__c =: LAId Limit 1];
        System.assertEquals('Test Landlord Lease Updated', LARecord.Lease_Name__c, 'Looks like the record was not inserted');
        System.assertEquals(DivestitureSiteId, LARecord.Divestiture_Site_ID_Text__c, 'Looks like the Divestiture_Site_ID_Text__c was not Updated');
    }
    @isTest 
    static void multipleEventToUpdateLA(){
        Integer j = 1;
        Integer maxRecords = 10;
        Map<String, String> mapDivSiteName_Id = new Map<String, String>();
        Map<String, String> mapLeaseId = new Map<String, String>();
        List<Lease_Abstract_Update__e> lstLeaseAb = new List<Lease_Abstract_Update__e>();
        List<Lease_Abstract__c> lstLAC = [Select Lease_ID__c from Lease_Abstract__c];
        for(Lease_Abstract__c LAC: lstLAC){
            mapLeaseId.put(LAC.Lease_ID__c, LAC.Id);
            system.debug('Lease_ID__c:' + LAC.Lease_ID__c + '**' + 'Id:' +  LAC.Id);
        }
        List<Divestiture_Site__c> lstDivestitureSite = [Select Site_Name__c from Divestiture_Site__c];
        for(Divestiture_Site__c DivSite: lstDivestitureSite){
        	mapDivSiteName_Id.put(DivSite.Site_Name__c, DivSite.Id);
            system.debug('Site_Name__c:' + DivSite.Site_Name__c + '**' + 'Id:' +  DivSite.Id);
        }
        for(j=1;j<=maxRecords;j++){
            Lease_Abstract_Update__e LAevt = new Lease_Abstract_Update__e();
            //String LAId = mapLeaseId.get('99' + j);
            String LAId = '99' + j;
            system.debug('Lease_Id__c:' +  LAId);
            LAevt.Lease_ID__c = LAId;
            //String DivestitureSiteId = mapDivSiteName_Id.get('Test Divestiture' + j);
            String DivestitureSiteId = 'Test Divestiture' + j;
            system.debug('Divestiture_Site_ID_Text__c :' +  DivestitureSiteId);
            LAevt.Divestiture_Site_ID_Text__c = DivestitureSiteId;
            LAevt.Holdover__c = '';
            LAevt.Landlord_Address__c = j + ', Test Address';
            LAevt.Landlord_City__c = 'TrentonN';
            LAevt.Landlord_Email__c = 'balamurugan.velu1@tmobile.com';
            LAevt.Landlord_Phone__c = '201-234-7656';
            LAevt.Landlord_Site_ID__c = '1-123';
            LAevt.Landlord_State__c = 'NJ';
            LAevt.Landlord_Zip_Code__c = '08053';
            LAevt.Lease_Landlord__c = 'Test Landlord';
            LAevt.Lease_Name__c = 'Test Landlord Lease Updated';
            LAevt.Lease_Status__c = 'Active';
            LAevt.Lease_Term_End_Date__c = date.parse('5/1/2021');
            LAevt.Lease_Use__c = 'Active';
            LAevt.MLA__c = 'Yes';
            //objLA.MLA_ID_C__c = evtLeaseAbstract.MLA_ID_C__c; ?
            LAevt.NNR_Critical_Date__c = date.parse('02/05/2020');
            LAevt.NNR_Reason__c = 'Test Reason';
            LAevt.Payee__c = 'Test Payee';
            LAevt.Square_Feet_of_Ground_Lease__c = 10256;
            LAevt.T_Mobile_Unfettered_Assig_Right__c = 'Yes';
            LAevt.T_Mobile_Unfettered_Assig_Right_Doc__c = 'Yes'; 
            LAevt.T_Mo_Unfet_Modification_Right_Doc__c = 'No';
            LAevt.T_Mo_Unfet_Modification_Rights__c = 'No';
            LAevt.T_Mo_Unfet_Termination_Rights__c ='Yes';
            LAevt.T_Mo_Unf_Termination_Doc_Section__c = 'Yes';
            LAevt.Unres_24_7_Access_Rights_Doc_Sec__c = 'Yes';
            LAevt.Unrestricted_24_7_Access_Rights__c = 'Yes';
            lstLeaseAb.add(LAevt);
        }
        //TMOS_LeaseAbstractTriggerHandler.processTrigger(lstLeaseAb);
        Test.startTest();
        publishEvent(lstLeaseAb);
        Test.stopTest();
       	Integer numberOfLARecords = [select count() from Lease_Abstract__c where Landlord_City__c = 'TrentonN'];
        System.assertEquals(maxRecords, numberOfLARecords, 'Test case Failed. Code not working as expected');
        //System.assertEquals(DivestitureSiteId, LARecord.Divestiture_Site_ID_Text__c, 'Looks like the Divestiture_Site_ID_Text__c was not Updated');
    }
    @isTest 
    static void multipleEventToInsertLA(){
        Integer j = 1;
        Integer maxRecords = 10;
        Map<String, String> mapDivSiteName_Id = new Map<String, String>();
        Map<String, String> mapLeaseId = new Map<String, String>();
        List<Lease_Abstract_Update__e> lstLeaseAb = new List<Lease_Abstract_Update__e>();
        List<Lease_Abstract__c> lstLAC = [Select Lease_ID__c from Lease_Abstract__c];
        for(Lease_Abstract__c LAC: lstLAC){
            mapLeaseId.put(LAC.Lease_ID__c, LAC.Id);
        }
        List<Divestiture_Site__c> lstDivestitureSite = [Select Site_Name__c from Divestiture_Site__c];
        for(Divestiture_Site__c DivSite: lstDivestitureSite){
        	mapDivSiteName_Id.put(DivSite.Site_Name__c, DivSite.Id);
        }
        for(j=1;j<=maxRecords;j++){
            Lease_Abstract_Update__e LAevt = new Lease_Abstract_Update__e();
            String LAId = '1100' + j;
            LAevt.Lease_ID__c = LAId;
            String DivestitureSiteId = '11101' + j;
            LAevt.Divestiture_Site_ID_Text__c = DivestitureSiteId;
            LAevt.Holdover__c = '';
            LAevt.Landlord_Address__c = j + ', Test Address';
            LAevt.Landlord_City__c = 'MarltonN';
            LAevt.Landlord_Email__c = 'balamurugan.velu1@tmobile.com';
            LAevt.Landlord_Phone__c = '201-234-7656';
            LAevt.Landlord_Site_ID__c = '1-123' + j;
            LAevt.Landlord_State__c = 'NJ';
            LAevt.Landlord_Zip_Code__c = '08053';
            LAevt.Lease_Landlord__c = 'Test Landlord';
            LAevt.Lease_Name__c = 'Test Landlord Lease Updated';
            LAevt.Lease_Status__c = 'Active';
            LAevt.Lease_Term_End_Date__c = date.parse('5/1/2021');
            LAevt.Lease_Use__c = 'Active';
            LAevt.MLA__c = 'Yes';
            //objLA.MLA_ID_C__c = evtLeaseAbstract.MLA_ID_C__c; ?
            LAevt.NNR_Critical_Date__c = date.parse('02/05/2020');
            LAevt.NNR_Reason__c = 'Test Reason';
            LAevt.Payee__c = 'Test Payee';
            LAevt.Square_Feet_of_Ground_Lease__c = 10256;
            LAevt.T_Mobile_Unfettered_Assig_Right__c = 'Yes';
            LAevt.T_Mobile_Unfettered_Assig_Right_Doc__c = 'Yes'; 
            LAevt.T_Mo_Unfet_Modification_Right_Doc__c = 'No';
            LAevt.T_Mo_Unfet_Modification_Rights__c = 'No';
            LAevt.T_Mo_Unfet_Termination_Rights__c ='Yes';
            LAevt.T_Mo_Unf_Termination_Doc_Section__c = 'Yes';
            LAevt.Unres_24_7_Access_Rights_Doc_Sec__c = 'Yes';
            LAevt.Unrestricted_24_7_Access_Rights__c = 'Yes';
            lstLeaseAb.add(LAevt);
        }
        //TMOS_LeaseAbstractTriggerHandler.processTrigger(lstLeaseAb);
        Test.startTest();
        publishEvent(lstLeaseAb);
        Test.stopTest();
       	Integer numberOfLARecords = [select count() from Lease_Abstract__c where Landlord_City__c = 'MarltonN'];
        System.assertEquals(maxRecords, numberOfLARecords, 'Test case Failed. Code not working as expected');
        //System.assertEquals(DivestitureSiteId, LARecord.Divestiture_Site_ID_Text__c, 'Looks like the Divestiture_Site_ID_Text__c was not Updated');
    }
    static void publishEvent(List<Lease_Abstract_Update__e> lstLeaseAb){
         Database.SaveResult[] lstResult = EventBus.publish(lstLeaseAb);
        for(Database.SaveResult res: lstResult){
            if(res.isSuccess()){
                System.debug('Successfully published event.');
            }              
        }        
    }
    
    @isTest 
    static void LeaseAbstractUpdateEvent_Trigger(){
        //Code for Trigger coverage
        Lease_Abstract_Update__e newEvent = new Lease_Abstract_Update__e();
        String LAId = '5678';
        newEvent.Lease_ID__c = LAId;
        String DivestitureSiteId = '5678';
        newEvent.Divestiture_Site_ID_Text__c = DivestitureSiteId;
        newEvent.Holdover__c = 'Test';
        newEvent.Landlord_Address__c = '100, Test Address';
        newEvent.Landlord_City__c = 'Seatle';
        newEvent.Landlord_Email__c = 'balamurugan.velu1@tmobile.com';
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(newEvent);  
        Test.stopTest();
        System.debug('sr.isSuccess()' + sr.isSuccess());
        System.assertEquals(true, sr.isSuccess());
        if (sr.isSuccess()) {
            System.debug('Successfully published event');
        }       
    }
    
    @isTest 
    static void InvalidEmailAddressCheck(){
        //Code for Trigger coverage
        Lease_Abstract_Update__e newEvent = new Lease_Abstract_Update__e();
        String LAId = '5678';
        newEvent.Lease_ID__c = LAId;
        String DivestitureSiteId = '5678';
        newEvent.Divestiture_Site_ID_Text__c = DivestitureSiteId;
        newEvent.Holdover__c = 'Test';
        newEvent.Landlord_Address__c = '100, Test Address';
        newEvent.Landlord_City__c = 'Seatle';
        newEvent.Landlord_Email__c = 'balamurugan::@tmobile.com';
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(newEvent);  
        Test.stopTest();
        System.debug('sr.isSuccess()' + sr.isSuccess());
        System.assertEquals(true, sr.isSuccess());
        if (sr.isSuccess()) {
            System.debug('Successfully published event');
        }       
    }
}
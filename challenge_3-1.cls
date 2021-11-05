/*

delete[select id from case];
CreateDefaultData.createDefaultData();
*/

@isTest
public with sharing class MaintenanceRequestHelperTest {
    
   @isTest public static void test1() {
        List<Case> newAfterTrigger_before = [
            select id 
            from case 
            where status = 'New' and type= 'Routine Maintenance'];  
        List<Equipment_Maintenance_Item__c> eq_maintenance_list_before = [
                select id
                from Equipment_Maintenance_Item__c 
                where Maintenance_Request__c IN : newAfterTrigger_before]; 

        //data factory
        List<Case> newCases = TestDataFactory.createMaintenanceRequest();
        List<Equipment_Maintenance_Item__c> newEqMaintenanceItem = 
            TestDataFactory.createJoinRecords(2);

        List<Equipment_Maintenance_Item__c> eq_maintenance_list_in_newcases = [
        select id
        from Equipment_Maintenance_Item__c 
        where Maintenance_Request__c IN : newCases];
        
        Test.startTest();
        for(Case caseItem : newCases){
            caseItem.status = 'Closed';
        }
        Database.SaveResult[] results = Database.update(newCases, false);
        Test.stopTest();
       


        for (Database.SaveResult sr : results) {
            System.assert(sr.isSuccess());
        }
        
        List<Case> newAfterTrigger = [
            select id 
            from case 
            where status = 'New' and type= 'Routine Maintenance'];
        List<Equipment_Maintenance_Item__c> eq_maintenance_list_in_newAfterTrigger = [
                select id
                from Equipment_Maintenance_Item__c 
                where Maintenance_Request__c IN : newAfterTrigger];
        
        //assertEquals(expected, actual, msg)
        system.assertEquals(newAfterTrigger_before.size() + newCases.size(), 
        newAfterTrigger.size());
        system.assertEquals(
            eq_maintenance_list_before.size() + eq_maintenance_list_in_newcases.size(), 
            eq_maintenance_list_in_newAfterTrigger.size());
    }
}
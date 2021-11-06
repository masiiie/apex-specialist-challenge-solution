/*

delete[select id from case];
CreateDefaultData.createDefaultData();


Line: 44, Column: 1
System.AssertException: Assertion Failed: Expected: 78, Actual: 82

Line: 44, Column: 1
System.AssertException: Assertion Failed: Expected: 86, Actual: 90


Line: 44, Column: 1
System.AssertException: Assertion Failed: Expected: 86, Actual: 90


Line: 44, Column: 1
System.AssertException: Assertion Failed: Expected: 94, Actual: 98

Line: 43, Column: 1
System.AssertException: Assertion Failed: Expected: 102, Actual: 106

*/

@isTest
public with sharing class MaintenanceRequestHelperTest {
    
   @isTest public static void test1() {
        List<Case> newBeforeTrigger = [
            select id 
            from case 
            where status = 'New' and type= 'Routine Maintenance'];  
        List<Equipment_Maintenance_Item__c> eqMaintenanceBefore = [
            select id
            from Equipment_Maintenance_Item__c
            where Maintenance_Request__c IN : newBeforeTrigger]; 

        //data factory
        List<Case> newCases = TestDataFactory.createMaintenanceRequest();
        List<Equipment_Maintenance_Item__c> newEqMaintenanceItem = 
            TestDataFactory.createJoinRecords(2, newCases);

        List<Equipment_Maintenance_Item__c> eqMaintenanceInNewcases = [
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
        List<Equipment_Maintenance_Item__c> eqMaintenanceInNewAfterTrigger = [
            select id
            from Equipment_Maintenance_Item__c 
            where Maintenance_Request__c IN : newAfterTrigger];
        
        //assertEquals(expected, actual, msg)
        system.assertEquals(newBeforeTrigger.size() + newCases.size(), newAfterTrigger.size());
        system.assertEquals(
            eqMaintenanceBefore.size() + eqMaintenanceInNewcases.size(), 
            eqMaintenanceInNewAfterTrigger.size());
    }
}
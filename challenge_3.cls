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

public with sharing class MaintenanceRequestHelperTest {
    
   public static void test1() 
   {
        List<Case> closedBeforeTrigger = [
            select id 
            from case 
            where status = 'Closed'];  
        List<Equipment_Maintenance_Item__c> eqMaintenanceBefore = [
            select id
            from Equipment_Maintenance_Item__c
            where Maintenance_Request__c IN : closedBeforeTrigger]; 

        //data factory
        List<Case> newCases = TestDataFactory.createMaintenanceRequest(300, false);
        List<Equipment_Maintenance_Item__c> newEqMaintenanceItem = 
            TestDataFactory.createJoinRecords(2, newCases);

        List<Equipment_Maintenance_Item__c> eqMaintenanceInNewcases = [
            select id
            from Equipment_Maintenance_Item__c 
            where Maintenance_Request__c IN : newCases];
        

        for(Case caseItem : newCases){
            caseItem.status = 'Closed';
        }
        Database.SaveResult[] results = Database.update(newCases, false);       


        for (Database.SaveResult sr : results) {
            System.assert(sr.isSuccess());
        }
        
        List<Case> closedAfterTrigger = [
            select id 
            from case 
            where status = 'Closed'];
        List<Equipment_Maintenance_Item__c> eqMaintenanceAfterTrigger = [
            select id
            from Equipment_Maintenance_Item__c 
            where Maintenance_Request__c IN : closedAfterTrigger];
        
        //assertEquals(expected, actual, msg)
        system.assertEquals(closedBeforeTrigger.size() + newCases.size(), closedAfterTrigger.size());
        system.assertEquals(
            eqMaintenanceBefore.size() + eqMaintenanceInNewcases.size(), 
            eqMaintenanceAfterTrigger.size());

        /*
        List<Case> ultimos = [
            select id 
            from Case where status='New' and Type='Routine Maintenance'
            order by CreatedDate desc 
            limit newCases.size()];
        List<AggregateResult> mins = 
            new List<AggregateResult>(
                [SELECT mr.id, mr.Date_Due__c, MIN(equipo.Maintenance_Cycle__c)min
                FROM Equipment_Maintenance_Item__c eqItem, eqItem.Equipment__r equipo, eqItem.Maintenance_Request__r mr
                WHERE Maintenance_Request__c IN : ultimos
                GROUP BY mr.id, mr.Date_Due__c]);
        for(AggregateResult ar : mins){
            system.assert((Decimal)ar.get('min'))
        }
        */
    }

    @isTest public static void negativeCase()
    {
        List<Case> cases = TestDataFactory.createMaintenanceRequest(6, true);
        List<Equipment_Maintenance_Item__c> newEqMaintenanceItem = 
            TestDataFactory.createJoinRecords(2, cases);

        List<Case> allCases = [select id from Case];
        List<Equipment_Maintenance_Item__c> allEMI = [select id from Equipment_Maintenance_Item__c];

        Test.startTest();
        for(Case negativeCase : cases){
            negativeCase.status = 'Closed';
        }
        update cases;
        Test.stopTest();

        system.assertEquals(allCases.size(), [select id from Case].size());
        system.assertEquals(allEMI.size(), [select id from Equipment_Maintenance_Item__c].size());
        
    }
}
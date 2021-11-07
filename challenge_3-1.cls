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

    public static void test2() 
   {
        List<Case> closedBeforeTrigger = [
            select id 
            from case 
            where status = 'Closed'];  
        List<Case> newCases = TestDataFactory.createMaintenanceRequest(5, false);


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
        system.assertEquals(0, eqMaintenanceAfterTrigger.size());
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

    @isTest public static void test3()
    {
        Case caseCreated = TestDataFactory.createMaintenanceRequest(1, false);
        List<Equipment_Maintenance_Item__c> newEqMaintenanceItem = 
            TestDataFactory.createJoinRecords(2, newCases);
        insert caseCreated;

        List<Product2> eqs = [select id, Maintenance_Cycle__c from Product2 limit 2];

        Equipment_Maintenance_Item__c eqM1 = new Equipment_Maintenance_Item__c(
            Equipment__c = eqs[0].Id, 
            Maintenance_Request__c = caseCreated.Id);
        Equipment_Maintenance_Item__c eqM2 = new Equipment_Maintenance_Item__c(
            Equipment__c = eqs[1].Id, 
            Maintenance_Request__c = caseCreated.Id);
        insert eqM1;
        insert eqM2;

        List<Case> cases = [select id from Case where status='New' and type='Routine Maintenance'];

        Test.startTest();
        caseCreated.status = 'Closed';
        update caseCreated;
        Test.stopTest();

        Case caseNew = [
            select id, Vehicle__c, Subject, Date_Reported__c, CreatedDate, Date_Due__c 
            from Case 
            order by CreatedDate desc 
            limit 1];
        List<Case> casesAfter = [select id from Case where status='New' and type='Routine Maintenance'];
        List<Equipment_Maintenance_Item__c> eqsAfter = [
            select id 
            from Equipment_Maintenance_Item__c
            where Maintenance_Request__c =: caseNew.Id and 
            (Equipment__c =: eqM1.Equipment__c or Equipment__c =: eqM2.Equipment__c)];

        integer minD = Integer.valueOf(math.min(eqs[0].Maintenance_Cycle__c, eqs[1].Maintenance_Cycle__c));
        
        system.assertEquals(cases.size()+1, casesAfter.size());
        system.assertEquals(caseCreated.Vehicle__c, caseNew.Vehicle__c);
        system.assertEquals(2, eqsAfter.size());
        system.assertNotEquals(null, caseNew.Subject);
        /*
        system.assertEquals(caseNew.Date_Reported__c, caseNew.CreatedDate);
        system.assertEquals(caseNew.Date_Reported__c + minD, caseNew.Date_Due__c);
`       */
    }

}
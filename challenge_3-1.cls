/*

delete[select id from case];
CreateDefaultData.createDefaultData();
*/

@isTest
public with sharing class MaintenanceRequestHelperTest {
    @isTest static void test1() {
        List<Case> newCases = [
            select id, status 
            from case 
            where status='New' and (type='Repair' or type='Routine Maintenance')];    
        
        // Perform test
        Test.startTest();
        for(Case caseItem : newCases){
            caseItem.status = 'Closed';
        }
        Database.SaveResult[] results = Database.update(toUpdate, false);
        //update newCases;
        Test.stopTest();


        for (Database.SaveResult sr : results) {
            System.assert(sr.isSuccess());
        }
        
        List<Case> listCase = [
            select id 
            from case 
            where status = 'New' and type= 'Routine Maintenance' and
            subject like 'This is a routine maintenance request! '];
        List<Equipment_Maintenance_Item__c> listEquipment1 = [
                select id
                from Equipment_Maintenance_Item__c 
                where Maintenance_Request__c IN : listCase];
        
        List<Equipment_Maintenance_Item__c> listEquipment2 = [
                select id
                from Equipment_Maintenance_Item__c 
                where Maintenance_Request__c IN : newCases];
        
        system.assertEquals(newCases.size(), listCase.size());
        system.assertEquals(listEquipment2.size(), listEquipment1.size());
    }
}
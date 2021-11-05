/*

delete[select id from case];
CreateDefaultData.createDefaultData();
*/

@isTest
public with sharing class MaintenanceRequestHelperTest {
    
    @isTest static void test1() {
        List<Case> newAfterTrigger_before = [
            select id 
            from case 
            where status = 'New' and type= 'Routine Maintenance' and
            subject like 'This is a routine maintenance request! '];  
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
        
        // Perform test
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
            where status = 'New' and type= 'Routine Maintenance' and
            subject like 'This is a routine maintenance request! '];
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


@isTest
public class TestDataFactory {
    public static List<Case> createMaintenanceRequest() {
        List<Vehicle__c> vehicles = [select id from Vehicle__c];
        List<Case> maintenanceRequests = new List<Case>();
        for(Vehicle__c vh : vehicles){
            maintenanceRequests.add(new Case(Vehicle__c = vh.Id, Type = 'Routine Maintenance', Date_Reported__c = Date.today()));
            insert maintenanceRequests;
        }
        return maintenanceRequests;
    }

    public static List<Equipment_Maintenance_Item__c> createJoinRecords(integer eq_size){
    List<Product2> equipment = [select id from Product2];
    List<Case> maintenanceRequest = [select id from Case]; 
    List<Equipment_Maintenance_Item__c> joinRecords = new List<Equipment_Maintenance_Item__c>();

    for(Case mr : maintenanceRequest){
        for(integer i=0; i< eq_size;i++){
            joinRecords.add(new Equipment_Maintenance_Item__c(Equipment__c = equipment.get(i).Id, Maintenance_Request__c = mr.Id));
        }
    }
    
    insert joinRecords;
    return joinRecords;
    }
}
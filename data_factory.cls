@isTest
public class TestDataFactory {
    public static List<Case> createMaintenanceRequest() {
        List<Vehicle__c> vehicles = [select id from Vehicle__c];
        List<Case> maintenanceRequests = new List<Case>();
        for(Vehicle__c vh : vehicles){
            maintenanceRequests.add(new Case(
                Vehicle__c = vh.Id, 
                Type = 'Routine Maintenance', 
                status = 'New',
                Date_Reported__c = Date.today()));
        }
        insert maintenanceRequests;
        return maintenanceRequests;
    }

    public static List<Equipment_Maintenance_Item__c> createJoinRecords(integer eq_size, List<Case> maintenanceRequest){
    List<Product2> equipment = [select id from Product2]; 
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
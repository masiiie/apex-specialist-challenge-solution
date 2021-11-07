@isTest
public class TestDataFactory {
    public static List<Case> createMaintenanceRequest(integer count, Boolean otherTypes) {
        List<Vehicle__c> vehicles = [select id from Vehicle__c limit :count];
        List<Case> maintenanceRequests = new List<Case>();

        String[] tipos1 = new String[]{'Mechanical', 'Electrical', 'Electronic', 'Structural', 'Other'};
        String[] tipos2 = new String[]{'Routine Maintenance', 'Repair'};
        
        integer indexVehicle = 0;
        for(integer i=0; i< count;i++){
            if(indexVehicle == vehicles.size()) indexVehicle = 0;
            String tipo = otherTypes ? 
                tipos1.get(math.mod(i, tipos1.size())) : 
                tipos2.get(math.mod(i, 2));
            maintenanceRequests.add(new Case(
                Vehicle__c = vehicles.get(indexVehicle).Id, 
                Type = tipo, 
                status = 'New',
                Date_Reported__c = Date.today()));
            indexVehicle++;
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
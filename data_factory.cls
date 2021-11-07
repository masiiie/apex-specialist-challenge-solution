@isTest public with sharing class TestDataFactory {
    public static List<Case> createMaintenanceRequest(integer count, Boolean otherTypes) {
        List<Vehicle__c> vehicles =  createVehicles();
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

    public static List<Vehicle__c> createVehicles(){
        List<Vehicle__c> vehicles = new List<Vehicle__c>();
        vehicles.add(new Vehicle__c(Name = 'Toy Hauler RV', Air_Conditioner__c = true, Bathrooms__c = 1, Bedrooms__c = 1, Model__c = 'Toy Hauler RV'));
        vehicles.add(new Vehicle__c(Name = 'Travel Trailer RV', Air_Conditioner__c = true, Bathrooms__c = 2, Bedrooms__c = 2, Model__c = 'Travel Trailer RV'));
        vehicles.add(new Vehicle__c(Name = 'Teardrop Camper', Air_Conditioner__c = true, Bathrooms__c = 1, Bedrooms__c = 1, Model__c = 'Teardrop Camper'));
        vehicles.add(new Vehicle__c(Name = 'Pop-Up Camper', Air_Conditioner__c = true, Bathrooms__c = 1, Bedrooms__c = 1, Model__c = 'Pop-Up Camper'));
        insert vehicles;
        return vehicles;
    }

    public static List<Product2> createEquipment(){
        List<Product2> equipments = new List<Product2>();
        equipments.add(new Product2(Warehouse_SKU__c = '55d66226726b611100aaf741',name = 'Generator 1000 kW', Replacement_Part__c = true,Cost__c = 100 ,Maintenance_Cycle__c = 100));
        equipments.add(new Product2(name = 'Fuse 20B',Replacement_Part__c = true,Cost__c = 1000, Maintenance_Cycle__c = 30  ));
        equipments.add(new Product2(name = 'Breaker 13C',Replacement_Part__c = true,Cost__c = 100  , Maintenance_Cycle__c = 15));
        equipments.add(new Product2(name = 'UPS 20 VA',Replacement_Part__c = true,Cost__c = 200  , Maintenance_Cycle__c = 60));
        insert equipments;
        return equipments;
        
    }

    public static List<Equipment_Maintenance_Item__c> createJoinRecords(integer eq_size, List<Case> maintenanceRequest){
    List<Product2> equipment = createEquipment(); 
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
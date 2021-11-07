public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    public void execute(QueueableContext context) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() == 200) {
            List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody()); 
            Map<String, Object> myMap = new Map<String, Object>();

            
            for(object item: results) {
                Map<String, Object> equipment = (Map<String, Object>) item;
                //System.debug(equipment.get('name') + '\n');
                myMap.put((String)equipment.get('_id'), equipment);
            }

            List<Product2> toUpdate = [
                select Replacement_Part__c, Cost__c, Current_Inventory__c, Lifespan_Months__c, Maintenance_Cycle__c, Warehouse_SKU__c
                from Product2
                where Warehouse_SKU__c IN: myMap.keyset()];
            List<string> updatedID = new List<string>();        

            for(product2 prod: toUpdate){
                updatedID.add((string)prod.Warehouse_SKU__c);
                Map<String, Object> info = (Map<String, Object>)myMap.get((string)prod.Warehouse_SKU__c);
                prod.Replacement_Part__c = true; //info.get('replacement');
                prod.Cost__c = (Decimal)info.get('cost');
                //prod.Current_Inventory__c = //info.get('replacement');
                prod.Lifespan_Months__c = (Decimal)info.get('lifespan');
                prod.Maintenance_Cycle__c = (Decimal)info.get('maintenanceperiod');
            }
            update toUpdate;

            /*
            replacement part (always true), 
            cost, 
            current inventory, 
            lifespan, 
            maintenance cycle, and 
            warehouse SKU
             */

            List<Product2> toInsert = new List<Product2>();
            for(string key: myMap.keyset()){
                if(!updatedID.contains(key)){
                    Map<String, Object> info = (Map<String, Object>)myMap.get(key);
                    toInsert.add(new Product2(
                        Maintenance_Cycle__c=(Decimal)info.get('maintenanceperiod'),
                        Lifespan_Months__c=(Decimal)info.get('lifespan'),
                        Cost__c=(Decimal)info.get('cost'),
                        Replacement_Part__c=true,
                        Warehouse_SKU__c=(string)info.get('_id'),
                        name=(string)info.get('name')
                    ));
                }
            }
            insert toInsert;
            
            system.debug('se actualizo todo!!!!');
        }    
    }
}

global class ScheduledWarehouseCalloutService implements Schedulable {
   global void execute(SchedulableContext SC) {
      System.enqueueJob(new WarehouseCalloutService());
   }
}
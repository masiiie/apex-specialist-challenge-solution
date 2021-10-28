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

            for(product2 prod: toUpdate){
                Map<String, Object> info = (Map<String, Object>)myMap.get((string)prod.Warehouse_SKU__c);
                prod.Replacement_Part__c = true; //info.get('replacement');
                prod.Cost__c = (Decimal)info.get('cost');
                //prod.Current_Inventory__c = //info.get('replacement');
                prod.Lifespan_Months__c = (Decimal)info.get('lifespan');
                prod.Maintenance_Cycle__c = (Decimal)info.get('maintenanceperiod');
            }
            update toUpdate;
            
            system.debug('se actualizo todo!!!!');
        }    
    }
}

global class ScheduledWarehouseCalloutService implements Schedulable {
   global void execute(SchedulableContext SC) {
      System.enqueueJob(new WarehouseCalloutService());
   }
}


public with sharing class DummyClass implements Queueable {
    public void execute(QueueableContext context) {
       system.debug('Loca que tu quieres??? 😅');  

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() == 200) {
            system.debug('Todo salio bien!!!! 😁');
        }
    }
}
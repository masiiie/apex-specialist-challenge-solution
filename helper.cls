public with sharing class MaintenanceRequestHelper {
    public static void updateWorkOrders(List<Case> maintenanceRequestClosed){
        List<Case> maintenanceRequests = new List<Case>();
        Map<Id,Case> oldNew = new Map<Id,Case>();
        // El id de los casos viejos con los equipos con los que se relacionaba
        Map<Id,List<Equipment_Maintenance_Item__c>> oldWithEquipment = new Map<Id,List<Equipment_Maintenance_Item__c>>();

        for(Case a : maintenanceRequestClosed) { 
            boolean cond1 = a.Status != 'Closed';
            boolean cond2 = a.Type != 'Repair' && a.Type != 'Routine Maintenance';
            if(cond1 || cond2) continue;
            
                        
            List<Equipment_Maintenance_Item__c> asociados = [
                SELECT Equipment__c 
                FROM Equipment_Maintenance_Item__c
                WHERE Maintenance_Request__c =: a.id
            ]; 

            
            oldWithEquipment.put(a.id, asociados);
            AggregateResult[] groupedResults = [
                SELECT MIN(equipo.Maintenance_Cycle__c)min 
                FROM Equipment_Maintenance_Item__c eqItem, eqItem.Equipment__r equipo
                WHERE id IN :asociados];

            Object minDueCycle =  groupedResults[0].get('min');

            Case newRequest = new Case(Vehicle__c = a.Vehicle__c, 
                Type = 'Routine Maintenance',
                Status = 'New',
                Subject = 'This is a routine maintenance request! ' + a.Vehicle__c,
                Date_Reported__c = Date.today(),
                Date_Due__c = Date.today() + 
                    (minDueCycle == null ? 0 : Integer.valueOf(minDueCycle)));
            maintenanceRequests.add(newRequest);
            oldNew.put(a.id, newRequest);
        } 
        insert maintenanceRequests;


        for (Id key : oldWithEquipment.keySet()) {
            List<Equipment_Maintenance_Item__c> newMaintenanceRequest = new List<Equipment_Maintenance_Item__c>();
            for(Equipment_Maintenance_Item__c item : oldWithEquipment.get(key)){
                newMaintenanceRequest.add(
                    new Equipment_Maintenance_Item__c(
                        Equipment__c = item.Equipment__c, 
                        Maintenance_Request__c = oldNew.get(key).Id));
            }
            insert newMaintenanceRequest;
        }
    }           
}


trigger MaintenanceRequest on Case (before update, after update) {
    if(Trigger.isAfter)
    {
        MaintenanceRequestHelper.updateWorkOrders(Trigger.New);
    }
}
public with sharing class MaintenanceRequestHelper {
    public static void updateWorkOrders(List<Case> maintenanceRequestClosed){
        List<Case> maintenanceRequests = new List<Case>();
        Map<Id,Case> oldNew = new Map<Id,Case>();
        
        // 
        // El id de los casos viejos con los equipos con los que se relacionaba
        List<AggregateResult> oldWithMinimun = 
            new List<AggregateResult>(
                [SELECT mr.id, mr.type, mr.Vehicle__c, mr.Status, MIN(equipo.Maintenance_Cycle__c)min
                FROM Equipment_Maintenance_Item__c eqItem, eqItem.Equipment__r equipo, eqItem.Maintenance_Request__r mr
                WHERE Maintenance_Request__c IN : maintenanceRequestClosed
                GROUP BY mr.id, mr.type, mr.Vehicle__c, mr.Status]);


        for(AggregateResult element : oldWithMinimun) {

            boolean cond1 = element.get('status') != 'Closed';
            boolean cond2 = element.get('type') != 'Repair' && element.get('type') != 'Routine Maintenance';
            if(cond1 || cond2) continue;
            

            Decimal minDueCycle = (Decimal)element.get('min');

            Case newRequest = new Case(Vehicle__c = (id)element.get('Vehicle__c'), 
                Type = 'Routine Maintenance',
                Status = 'New',
                Subject = 'This is a routine maintenance request! ' + element.get('Vehicle__c'),
                Date_Reported__c = Date.today(),
                Date_Due__c = Date.today() + 
                    (minDueCycle == null ? 0 : Integer.valueOf(minDueCycle)));
            maintenanceRequests.add(newRequest);
            oldNew.put((id)element.get('id'), newRequest);
        } 
        insert maintenanceRequests;


        List<Equipment_Maintenance_Item__c> revisiting = [
            SELECT Equipment__c, Maintenance_Request__c
            FROM Equipment_Maintenance_Item__c
            WHERE Maintenance_Request__c IN : oldNew.keySet()
        ];
        List<Equipment_Maintenance_Item__c> newMaintenanceRequest = new List<Equipment_Maintenance_Item__c>();
        for (Equipment_Maintenance_Item__c item : revisiting) {
            newMaintenanceRequest.add(
                    new Equipment_Maintenance_Item__c(
                        Equipment__c = item.Equipment__c, 
                        Maintenance_Request__c = oldNew.get(item.Maintenance_Request__c).id));
        }
        insert newMaintenanceRequest;
    }           
}


trigger MaintenanceRequest on Case (before update, after update) {
    if(Trigger.isAfter)
    {
        MaintenanceRequestHelper.updateWorkOrders(Trigger.New);
    }
}
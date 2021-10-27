/*
            List<Product2> asociados = [
                SELECT id, Maintenance_Cycle__c 
                FROM Product2
                WHERE id IN : (SELECT Equipment__c 
                FROM Equipment_Maintenance_Item__c
                WHERE Maintenance_Request__c =: a.id)
            ]; 

            
            oldWithEquipment.put(a.id, asociados);
            */
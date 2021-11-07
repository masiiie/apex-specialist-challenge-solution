@IsTest
public with sharing class WarehouseSyncScheduleTest {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    @testSetup
    static void setup() {
        TestDataFactory.createEquipment(); 
    }
    
    @isTest static void test1() {
        string[] names = new string[]{'Cooling Tower', 'UPS 1000 VA', 'Breaker 25A'};
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        
        Test.startTest();
        String jobId = System.schedule('ScheduledWarehouseCalloutService',
            CRON_EXP,
            new WarehouseSyncSchedule());
        System.assertEquals(0, [select id from product2 where name IN :names].size(), 'Tasks exist before job has run');
        Test.stopTest();    

        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
    }
}
trigger RepairPlanExpansionTrigger on Property_RepairItem__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) { 
   //長期修繕計画展開
    TriggerDispatcher.executeHandler(new RepairPlanExpansion());
}
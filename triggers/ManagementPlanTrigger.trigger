trigger ManagementPlanTrigger on CustomObject1__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	//物件別管理費用（予算と実績）
	//TriggerDispatcher.executeHandler(new ManagementPlan());
	TriggerDispatcher.executeHandler(new RepairPlanExpansion());
}
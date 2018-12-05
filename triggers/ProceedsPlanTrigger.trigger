trigger ProceedsPlanTrigger on CustomObject3__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	//物件別売上（予算と実績）
	//TriggerDispatcher.executeHandler(new ProceedsPlan());
	TriggerDispatcher.executeHandler(new RepairPlanExpansion());
}
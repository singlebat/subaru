trigger SetRepairPlanActualInfoTrigger on Opportunity (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
  		//長期修繕計画の実績を登録（20180605 Obj統合により不要になった。削除予定）
//    TriggerDispatcher.executeHandler(new SetRepairPlanActualInfo());
}
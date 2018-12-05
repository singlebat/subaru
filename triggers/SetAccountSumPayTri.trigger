trigger SetAccountSumPayTri on PaymentManage__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) { 

    TriggerDispatcher.executeHandler(new SetAccountSumPay());
}
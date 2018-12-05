public with sharing class SetAccountSumPay extends TriggerHandler {
    // トリガーの有効化判定フラグ
    public static Boolean TriggerDisabled = false;

    /**
    * @description トリガーの有効化判定処理。
    */
    public override Boolean IsDisabled(){
        return TriggerDisabled;
    }

    /**
     * @description before insert トリガーのハンドラ処理。
     * @param newList 対象データ。
     */
    public override void BeforeInsert(List<SObject> newList) {
        List<PaymentManage__c> proRepItemList = (List<PaymentManage__c>)newList;
    }

    /**
     * @description before update トリガーのハンドラ処理。
     * @param oldMap 更新前対象データ。
     * @param newMap 更新後対象データ。
     */
    public override void BeforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        List<PaymentManage__c> oldList = (List<PaymentManage__c>)oldMap.values();
        List<PaymentManage__c> newList = (List<PaymentManage__c>)newMap.values(); 
    }

    /**
     * @description before delete トリガーのハンドラ処理。
     * @param oldMap 対象データ。
     */
    public override void BeforeDelete(Map<Id, SObject> oldMap) {
        List<PaymentManage__c> oldList = (List<PaymentManage__c>)oldMap.values();
        
    }
    
     /**
     * @description after insert トリガーのハンドラ処理。
     * @param oldMap 新規作成前対象データ。
     */
    public override void AfterInsert(Map<Id, SObject> newMap) {
        List<PaymentManage__c> newList = (List<PaymentManage__c>)newMap.values();

    }

    /**
     * @description after update トリガーのハンドラ処理。
     * @param oldMap 更新前対象データ。
     * @param newMap 更新後対象データ。
     */
    public override void AfterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        List<PaymentManage__c> oldList = (List<PaymentManage__c>)oldMap.values();
        List<PaymentManage__c> newList = (List<PaymentManage__c>)newMap.values();
             
    }

    /**
     * @description after delete トリガーのハンドラ処理。
     * @param oldMap 対象データ。
     */
    public override void AfterDelete(Map<Id, SObject> oldMap) {
        List<PaymentManage__c> oldList = (List<PaymentManage__c>)oldMap.values();
        
        for (PaymentManage__c oldObj : oldList) { 
            SetAccountObj_SumPay(oldObj);
        }
    }
    
    // 取引先挿入処理
    private void SetAccountObj_SumPay( PaymentManage__c oldObj){
//system.debug('★★★:'+oldObj.Account__c);              
		if(oldObj.Account__c == null) return;  
        AggregateResult[] payItems = [SELECT Account__c, SUM(SummaryPay__c) sumPay FROM PaymentManage__c WHERE Account__c = :oldObj.Account__c GROUP BY Account__c ];

        // 対象取引先を取得
        Account accountInfo = [SELECT Id,Name,SummaryExpense__c FROM Account WHERE Id = :oldObj.Account__c]; 
//system.debug('◎◎:'+accountInfo.SummaryExpense__c);          
        if(payItems.size() == 0 ){
            accountInfo.SummaryExpense__c = 0;	// 支払合計金額
        } else {
            accountInfo.SummaryExpense__c = decimal.Valueof(string.valueof(payItems[0].get('sumPay')));	// 支払合計金額
        }
          
		update accountInfo;     
    }
 }
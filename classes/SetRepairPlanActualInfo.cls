public with sharing class SetRepairPlanActualInfo extends TriggerHandler {
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
        List<Opportunity> OppList = (List<Opportunity>)newList;

        // 長期修繕計画の重複Check
        for(Opportunity OppInfo : OppList){
           if (!checkDupPlanInput(OppInfo)) return;
        }
    }

    /**
     * @description before update トリガーのハンドラ処理。
     * @param oldMap 更新前対象データ。
     * @param newMap 更新後対象データ。
     */
    public override void BeforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        List<Opportunity> oldList = (List<Opportunity>)oldMap.values();
        List<Opportunity> newList = (List<Opportunity>)newMap.values(); 
       
        Integer su = 0;
 
        // oldの過去データ削除　
        for (Opportunity oldObj : oldList) {  
//system.debug('★★★:'+oldList[su].RepairPlan__c);
//system.debug('★★★:'+newList[su].RepairPlan__c);
            // 長期修繕計画の変更不可Check
            if (oldList[su].RepairPlan__c != newList[su].RepairPlan__c ){
                newList[su].RepairPlan__c.addError('長期修繕計画の変更はできません。');
                return;
            } 
            su++;
            
            deletePlanList(oldObj);
        }
    }

    /**
     * @description before delete トリガーのハンドラ処理。
     * @param oldMap 対象データ。
     */
    public override void BeforeDelete(Map<Id, SObject> oldMap) {
        List<Opportunity> oldList = (List<Opportunity>)oldMap.values();
        
        for (Opportunity oldObj : oldList) {             
            deletePlanList(oldObj);
        }
    }
    
     /**
     * @description after insert トリガーのハンドラ処理。
     * @param oldMap 新規作成前対象データ。
     */
    public override void AfterInsert(Map<Id, SObject> newMap) {
        List<Opportunity> newList = (List<Opportunity>)newMap.values();
        //*************************************
        //長期修繕計画の更新
        //*************************************
        {
            for (Opportunity newObj : newList) {             
                updatePlanList(newObj);
            }    
        }
    }

    /**
     * @description after update トリガーのハンドラ処理。
     * @param oldMap 更新前対象データ。
     * @param newMap 更新後対象データ。
     */
    public override void AfterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        List<Opportunity> oldList = (List<Opportunity>)oldMap.values();
        List<Opportunity> newList = (List<Opportunity>)newMap.values();

        // newのデータ反映
        for (Opportunity newObj : newList) { 
            updatePlanList(newObj);
        }   
    }

    /**
     * @description after delete トリガーのハンドラ処理。
     * @param oldMap 対象データ。
     */
    public override void AfterDelete(Map<Id, SObject> oldMap) {
        List<Opportunity> oldList = (List<Opportunity>)oldMap.values();    
    }
    
    // 長期修繕計画挿入処理
    private void updatePlanList( Opportunity newObj){
                
        // 物件収支（修繕）の実績情報を取得
        Opportunity oppInfo = 
//            [SELECT Id,RecordTypeId,StageName,SummaryPayment__c,CloseDate,SummaryRevenue__c,RepairPlan__c  FROM Opportunity WHERE Id = :newObj.Id ];
            [SELECT Id,RecordTypeId,StageName,CloseDate,RepairPlan__c  FROM Opportunity WHERE Id = :newObj.Id ];
        
        if(oppInfo.RepairPlan__c == null ) return;
        // 対象長期修繕計画を取得
        Longterm_repair_plan__c planInfo = [SELECT Id,Name FROM Longterm_repair_plan__c WHERE Id = :oppInfo.RepairPlan__c LIMIT 1];

        planInfo.RepairStatus__c = oppInfo.StageName;   // フェーズ(修繕ステータス)
        planInfo.ImpActualYear__c = String.valueOf(oppInfo.CloseDate.year()); // 実施年
//        planInfo.ActualExpense__c = oppInfo.SummaryPayment__c; // 費用
        
        update planInfo;
    }
    
    // 長期修繕計画の実績情報をNULLにする
    private void deletePlanList( Opportunity oldObj){
        // 物件収支（修繕）の実績情報を取得
        Opportunity oppInfo = [SELECT Id,RecordTypeId,RepairPlan__c  FROM Opportunity WHERE Id = :oldObj.Id ];
        
        if(oppInfo.RepairPlan__c == null ) return;

        // 対象長期修繕計画を取得
        Longterm_repair_plan__c planInfo = [SELECT Id,Name FROM Longterm_repair_plan__c WHERE Id = :oppInfo.RepairPlan__c LIMIT 1];

        planInfo.RepairStatus__c = '';  // フェーズ
        planInfo.ImpActualYear__c = ''; // 実施年
        planInfo.ActualExpense__c = null; // 費用
        
        update planInfo;
    }
    
    private boolean checkDupPlanInput(Opportunity newObj){
        
        if(newObj.RepairPlan__c == null){
            return false;
        }
//system.debug('★:::'+newObj.RepairPlan__c);         
        // 物件収支（修繕）の実績情報を取得
        List<Opportunity > opportunityObjList = [SELECT Id,RecordTypeId,RepairPlan__c  FROM Opportunity WHERE RepairPlan__c = :newObj.RepairPlan__c ];

        if (opportunityObjList.size() > 0 ) {
            newObj.RepairPlan__c.addError('同一長期修繕計画の選択はできません。');
            return false;
        }
               
        return true;
    }    
 }
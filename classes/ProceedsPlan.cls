public with sharing class ProceedsPlan extends TriggerHandler{
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
        List<CustomObject3__c> proRepItemList = (List<CustomObject3__c>)newList;
    }

    /**
     * @description before update トリガーのハンドラ処理。
     * @param oldMap 更新前対象データ。
     * @param newMap 更新後対象データ。
     */
    public override void BeforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        List<CustomObject3__c> oldList = (List<CustomObject3__c>)oldMap.values();
        List<CustomObject3__c> newList = (List<CustomObject3__c>)newMap.values(); 
    }

    /**
     * @description before delete トリガーのハンドラ処理。
     * @param oldMap 対象データ。
     */
    public override void BeforeDelete(Map<Id, SObject> oldMap) {
        List<CustomObject3__c> oldList = (List<CustomObject3__c>)oldMap.values();
        
        for (CustomObject3__c oldObj : oldList) {             
            deletePlanList(oldObj);
        }
    }

    /**
     * @description after insert トリガーのハンドラ処理。
     * @param oldMap 新規作成前対象データ。
     */
    public override void AfterInsert(Map<Id, SObject> newMap) {
        List<CustomObject3__c> newList = (List<CustomObject3__c>)newMap.values();
        //*************************************
        //長期修繕計画の自動展開
        //*************************************
        {
            //修繕計画リスト
            List<CustomOpportunity3__c> planList = new List<CustomOpportunity3__c>(); 

            for (CustomObject3__c newObj : newList) {             
                insertPlanList(planList,newObj);
            }

            // 長期計画挿入
            if (planList.size() > 0) {
                insert planList;
                
                setLastViewedDate();
            }        
        }
    }

    /**
     * @description after update トリガーのハンドラ処理。
     * @param oldMap 更新前対象データ。
     * @param newMap 更新後対象データ。
     */
    public override void AfterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        List<CustomObject3__c> oldList = (List<CustomObject3__c>)oldMap.values();
        List<CustomObject3__c> newList = (List<CustomObject3__c>)newMap.values();
        
        // oldの過去データ削除
        /*for (CustomObject3__c oldObj : oldList) {             
            deletePlanList(oldObj);
        }
        
        // newの修繕計画リスト展開
        List<CustomOpportunity3__c> planList = new List<CustomOpportunity3__c>(); 
        
        for (CustomObject3__c newObj : newList) { 
            insertPlanList(planList,newObj);
        }
        
        // 長期計画挿入
        if (planList.size() > 0) {
            insert planList;
            
            setLastViewedDate();
        }*/       
    }

    /**
     * @description after delete トリガーのハンドラ処理。
     * @param oldMap 対象データ。
     */
    public override void AfterDelete(Map<Id, SObject> oldMap) {
        List<CustomObject3__c> oldList = (List<CustomObject3__c>)oldMap.values();
    }


    // 長期修繕計画挿入処理
    private void insertPlanList( List<CustomOpportunity3__c> planList,CustomObject3__c newObj){

        CustomObject3__c proceedsPlan = [SELECT Id, 
        										Name, 
        										X1__c, //1月
        										X2__c, //2月
        										X3__c, //3月
        										X4__c, //4月
        										X5__c, //5月
        										X6__c, //6月
        										X7__c, //7月
        										X8__c, //8月
        										X9__c, //9月
        										X10__c, //10月
        										X11__c, //11月
        										X12__c, //12月
                                                Planned_Year__c, //計画年
        										Cycle_Year__c, //周期年
        										SalesBudgetNoTax__c, //予定売上（円）
        										Property_Name__r.Name, //物件名
                                                Property_Name__r.Id, //物件ID
        										Property_Name__r.completionDay__c, //物件 の 竣工年月日
             									Sales__r.Name //売上マスタ 管理名
             							FROM CustomObject3__c WHERE Id = :newObj.Id LIMIT 1];

        //計画修繕レコードタイプの指定
        RecordType recordTypes = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'CustomOpportunity3__c' AND Name = '計画'];
        //物件の 竣工年月日 後60年
        Integer completionYearAfter = proceedsPlan.Property_Name__r.completionDay__c.year() + 60;
        //計画年 数字

        Integer planYear =Integer.valueOf(proceedsPlan.Planned_Year__c);
        for(Integer i = 0; (planYear + i*proceedsPlan.Cycle_Year__c)  <= completionYearAfter; i++){
            //物件別売上（予算と実績）件数判断　Map (key = 予定月, vaule = 予定年 )
            Map<String,String> proceedsPlanNumMap = new Map<String,String>();
            if(proceedsPlan.X4__c){
                proceedsPlanNumMap.put('04', String.valueOf(planYear + i*proceedsPlan.Cycle_Year__c));
            }
            if(proceedsPlan.X5__c){
                proceedsPlanNumMap.put('05', String.valueOf(planYear + i*proceedsPlan.Cycle_Year__c));
            }
            if(proceedsPlan.X6__c){
                proceedsPlanNumMap.put('06', String.valueOf(planYear + i*proceedsPlan.Cycle_Year__c));
            }
            if(proceedsPlan.X7__c){
                proceedsPlanNumMap.put('07', String.valueOf(planYear + i*proceedsPlan.Cycle_Year__c));
            }
            if(proceedsPlan.X8__c){
                proceedsPlanNumMap.put('08', String.valueOf(planYear + i*proceedsPlan.Cycle_Year__c));
            }
            if(proceedsPlan.X9__c){
                proceedsPlanNumMap.put('09', String.valueOf(planYear + i*proceedsPlan.Cycle_Year__c));
            }
            if(proceedsPlan.X10__c){
                proceedsPlanNumMap.put('10', String.valueOf(planYear + i*proceedsPlan.Cycle_Year__c));
            }
            if(proceedsPlan.X11__c){
                proceedsPlanNumMap.put('11', String.valueOf(planYear + i*proceedsPlan.Cycle_Year__c));
            }
            if(proceedsPlan.X12__c){
                proceedsPlanNumMap.put('12', String.valueOf(planYear + i*proceedsPlan.Cycle_Year__c));
            }
            if(proceedsPlan.X1__c){
                proceedsPlanNumMap.put('01', String.valueOf(planYear + i*proceedsPlan.Cycle_Year__c + 1));
            }
            if(proceedsPlan.X2__c){
                proceedsPlanNumMap.put('02', String.valueOf(planYear + i*proceedsPlan.Cycle_Year__c + 1));
            }
            if(proceedsPlan.X3__c){
                proceedsPlanNumMap.put('03', String.valueOf(planYear + i*proceedsPlan.Cycle_Year__c + 1));
            }

            
            // 物件別売上（予算と実績）作成
            if(proceedsPlanNumMap != null && !proceedsPlanNumMap.isEmpty()){
                for(String skey : proceedsPlanNumMap.keySet()){
                    planList.add(new CustomOpportunity3__c(
                                    Field4__c = proceedsPlan.Id,  //売上計画番号  
                                    RecordTypeId = recordTypes.Id,  // 計画修繕レコードタイプの指定
                                    Name = proceedsPlanNumMap.get(skey) + skey + '_' + proceedsPlan.Property_Name__r.Name + '_' + proceedsPlan.Sales__r.Name,// 物件別管理名
                                    Field1__c = proceedsPlan.Property_Name__r.Id, //物件名
                                    Field14__c = proceedsPlanNumMap.get(skey), //予定年
                                    Field6__c = proceedsPlan.SalesBudgetNoTax__c, //予算（税抜）
                                    Field15__c = String.valueOf(Integer.valueOf(skey)) ));//予定月
                }
            }
        }
        
    }

    // 長期修繕計画削除処理(予定年>システム年は削除)
    private void deletePlanList( CustomObject3__c oldObj){

        // 今年以降は削除
        String thisYear = String.valueOf(system.today().year());       
        CustomOpportunity3__c[] delList = [SELECT Id, Name, Field4__c from CustomOpportunity3__c where Field4__c = :oldObj.Id]; // 全部削除（今年以降とかする必要あるか）

        delete delList;
    }

    // LastViewedDateの設定(最近参照したデータへの反映)
    private void setLastViewedDate( ) {
        CustomOpportunity3__c[] techContacts = [SELECT Id,Name FROM CustomOpportunity3__c FOR VIEW];
    }
}
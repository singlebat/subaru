public with sharing class ManagementPlan extends TriggerHandler {
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
        List<CustomObject1__c> proRepItemList = (List<CustomObject1__c>)newList;
    }

    /**
     * @description before update トリガーのハンドラ処理。
     * @param oldMap 更新前対象データ。
     * @param newMap 更新後対象データ。
     */
    public override void BeforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        List<CustomObject1__c> oldList = (List<CustomObject1__c>)oldMap.values();
        List<CustomObject1__c> newList = (List<CustomObject1__c>)newMap.values(); 
    }

    /**
     * @description before delete トリガーのハンドラ処理。
     * @param oldMap 対象データ。
     */
    public override void BeforeDelete(Map<Id, SObject> oldMap) {
        List<CustomObject1__c> oldList = (List<CustomObject1__c>)oldMap.values();
        
        for (CustomObject1__c oldObj : oldList) {             
            deletePlanList(oldObj);
        }
    }

    /**
     * @description after insert トリガーのハンドラ処理。
     * @param oldMap 新規作成前対象データ。
     */
    public override void AfterInsert(Map<Id, SObject> newMap) {
        List<CustomObject1__c> newList = (List<CustomObject1__c>)newMap.values();
        //*************************************
        //長期修繕計画の自動展開
        //*************************************
        {
            //修繕計画リスト
            List<CustomOpportunity2__c> planList = new List<CustomOpportunity2__c>(); 

            for (CustomObject1__c newObj : newList) {             
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
        List<CustomObject1__c> oldList = (List<CustomObject1__c>)oldMap.values();
        List<CustomObject1__c> newList = (List<CustomObject1__c>)newMap.values();
        
        // oldの過去データ削除
        /*for (CustomObject1__c oldObj : oldList) {             
            deletePlanList(oldObj);
        }
        
        // newの修繕計画リスト展開
        List<CustomOpportunity2__c> planList = new List<CustomOpportunity2__c>(); 
        
        for (CustomObject1__c newObj : newList) { 
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
        List<CustomObject1__c> oldList = (List<CustomObject1__c>)oldMap.values();
    }


    // 長期修繕計画挿入処理
    private void insertPlanList( List<CustomOpportunity2__c> planList,CustomObject1__c newObj){

        CustomObject1__c managementPlan = [SELECT Id, 
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
        										Manage_PlanNoTax__c, //予定費用（円）
        										Property_Name__r.Name, //物件名
        										Property_Name__r.Id, //物件ID
        										Property_Name__r.completionDay__c, //物件の 竣工年月日
             									Manage__r.Name //管理マスタ 管理名
             							FROM CustomObject1__c WHERE Id = :newObj.Id LIMIT 1];

        //計画修繕レコードタイプの指定
        RecordType recordTypes = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'CustomOpportunity2__c' AND Name = '計画'];
        //物件の 竣工年月日 後60年
        Integer completionYearAfter = managementPlan.Property_Name__r.completionDay__c.year() + 60;
        //計画年 数字
        Integer planYear = Integer.valueOf(managementPlan.Planned_Year__c);
        
        for(Integer i = 0; (planYear + i*managementPlan.Cycle_Year__c)  <= completionYearAfter; i++){
        	//物件別管理費用（予算と実績）件数判断　Map (key = 予定月, vaule = 予定年 )
	        Map<String,String> managementPlanNumMap = new Map<String,String>();
	        if(managementPlan.X4__c){
	        	managementPlanNumMap.put('04', String.valueOf(planYear + i*managementPlan.Cycle_Year__c));
	        }
	        if(managementPlan.X5__c){
	        	managementPlanNumMap.put('05', String.valueOf(planYear + i*managementPlan.Cycle_Year__c));
	        }
	        if(managementPlan.X6__c){
	        	managementPlanNumMap.put('06',String.valueOf(planYear + i*managementPlan.Cycle_Year__c));
	        }
	        if(managementPlan.X7__c){
	        	managementPlanNumMap.put('07', String.valueOf(planYear + i*managementPlan.Cycle_Year__c));
	        }
	        if(managementPlan.X8__c){
	        	managementPlanNumMap.put('08', String.valueOf(planYear + i*managementPlan.Cycle_Year__c));
	        }
	        if(managementPlan.X9__c){
	        	managementPlanNumMap.put('09', String.valueOf(planYear + i*managementPlan.Cycle_Year__c));
	        }
	        if(managementPlan.X10__c){
	        	managementPlanNumMap.put('10', String.valueOf(planYear + i*managementPlan.Cycle_Year__c));
	        }
	        if(managementPlan.X11__c){
	        	managementPlanNumMap.put('11', String.valueOf(planYear + i*managementPlan.Cycle_Year__c));
	        }
	        if(managementPlan.X12__c){
	        	managementPlanNumMap.put('12', String.valueOf(planYear + i*managementPlan.Cycle_Year__c));
	        }
	        if(managementPlan.X1__c){
	        	managementPlanNumMap.put('01', String.valueOf(planYear + i*managementPlan.Cycle_Year__c + 1));
	        }
	        if(managementPlan.X2__c){
	        	managementPlanNumMap.put('02', String.valueOf(planYear + i*managementPlan.Cycle_Year__c + 1));
	        }
	        if(managementPlan.X3__c){
	        	managementPlanNumMap.put('03', String.valueOf(planYear + i*managementPlan.Cycle_Year__c + 1));
	        }

	        
	        // 物件別管理費用（予算と実績）作成
	        if(managementPlanNumMap != null && !managementPlanNumMap.isEmpty()){
	        	for(String skey : managementPlanNumMap.keySet()){
			        planList.add(new CustomOpportunity2__c(
			                        Manage_PlanNO__c = managementPlan.Id,  //管理計画番号  
			                        RecordTypeId = recordTypes.Id,  // 計画修繕レコードタイプの指定
			                        Name = managementPlanNumMap.get(skey) + skey + '_' + managementPlan.Property_Name__r.Name + '_' + managementPlan.Manage__r.Name,// 物件別管理名
			                        Property_Name__c = managementPlan.Property_Name__r.Id, //物件名
			                        Planned_Year__c = managementPlanNumMap.get(skey), //予定年
			                        Manage_YosanNoTax__c = managementPlan.Manage_PlanNoTax__c, //予算（税抜）
			                        Planned_Month__c = String.valueOf(Integer.valueOf(skey)) ));//予定月
	        	}
	        }
        }
        
        
    }

    // 長期修繕計画削除処理(予定年>システム年は削除)
    private void deletePlanList( CustomObject1__c oldObj){

        // 今年以降は削除
        String thisYear = String.valueOf(system.today().year());       
        CustomOpportunity2__c[] delList = [SELECT Id, Name, Manage_PlanNO__c from CustomOpportunity2__c where Manage_PlanNO__c = :oldObj.Id]; // 全部削除（今年以降とかする必要あるか）

        delete delList;
    }

    // LastViewedDateの設定(最近参照したデータへの反映)
    private void setLastViewedDate( ) {
        CustomOpportunity2__c[] techContacts = [SELECT Id,Name FROM CustomOpportunity2__c FOR VIEW];
    }

}
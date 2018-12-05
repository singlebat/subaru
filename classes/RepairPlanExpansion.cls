public with sharing class RepairPlanExpansion extends TriggerHandler {
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
        /*List<Property_RepairItem__c> proRepItemList = (List<Property_RepairItem__c>)newList;

        for(Property_RepairItem__c proRepItem : proRepItemList){
        }*/
    }

    /**
     * @description before update トリガーのハンドラ処理。
     * @param oldMap 更新前対象データ。
     * @param newMap 更新後対象データ。
     */
    public override void BeforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        /*List<Property_RepairItem__c> oldList = (List<Property_RepairItem__c>)oldMap.values();
        List<Property_RepairItem__c> newList = (List<Property_RepairItem__c>)newMap.values(); */
    }

    /**
     * @description before delete トリガーのハンドラ処理。
     * @param oldMap 対象データ。
     */
    public override void BeforeDelete(Map<Id, SObject> oldMap) {

        //工事
        List<Property_RepairItem__c> oldRepairItemList = new List<Property_RepairItem__c>();
        //売上
        List<CustomObject3__c> oldProceedList = new List<CustomObject3__c>();
        //管理
        List<CustomObject1__c> oldManagementList = new List<CustomObject1__c>();

        for(String key : oldMap.keySet()){
            if(oldMap.get(key).getSobjectType() == Schema.Property_RepairItem__c.getSObjectType()){
                oldRepairItemList.add((Property_RepairItem__c)oldMap.get(key));
            }
            if(oldMap.get(key).getSobjectType() == Schema.CustomObject3__c.getSObjectType()){
                oldProceedList.add((CustomObject3__c)oldMap.get(key));
            }
            if(oldMap.get(key).getSobjectType() == Schema.CustomObject1__c.getSObjectType()){
                oldManagementList.add((CustomObject1__c)oldMap.get(key));
            }
        }
        if(oldRepairItemList != null && oldRepairItemList.size() > 0){
            for(Property_RepairItem__c oldObj : oldRepairItemList) {             
                deletePlanList(oldObj);
            }
        }
        if(oldProceedList != null && oldProceedList.size() > 0){
            for(CustomObject3__c oldObj : oldProceedList) {             
                deleteProceedPlanList(oldObj);
            }
        }
        if(oldManagementList != null && oldManagementList.size() > 0){
            for(CustomObject1__c oldObj : oldManagementList) {             
                deleteManagementPlanList(oldObj);
            }
        }
    }
    
     /**
     * @description after insert トリガーのハンドラ処理。
     * @param oldMap 新規作成前対象データ。
     */
    public override void AfterInsert(Map<Id, SObject> newMap) {

        //工事
        List<Property_RepairItem__c> newRepairItemList = new List<Property_RepairItem__c>();
        //売上
        List<CustomObject3__c> newProceedList = new List<CustomObject3__c>();
        //管理
        List<CustomObject1__c> newManagementList = new List<CustomObject1__c>();

        for(String key : newMap.keySet()){
            if(newMap.get(key).getSobjectType() == Schema.Property_RepairItem__c.getSObjectType()){
                newRepairItemList.add((Property_RepairItem__c)newMap.get(key));
            }
            if(newMap.get(key).getSobjectType() == Schema.CustomObject3__c.getSObjectType()){
                newProceedList.add((CustomObject3__c)newMap.get(key));
            }
            if(newMap.get(key).getSobjectType() == Schema.CustomObject1__c.getSObjectType()){
                newManagementList.add((CustomObject1__c)newMap.get(key));
            }
        }
        //*************************************
        //長期修繕計画の自動展開
        //*************************************
        
        //修繕計画リスト
        List<CustomOpportunity__c> planList = new List<CustomOpportunity__c>(); 

        //工事
        if(newRepairItemList != null && newRepairItemList.size() > 0){
            for (Property_RepairItem__c newObj : newRepairItemList) {             
                insertPlanList(planList,newObj);
            }
            //2018 前　List
            List<CustomOpportunity__c> beCustomOpportunityList = new List<CustomOpportunity__c>();
            //工事 2018 後のinsert
            for(CustomOpportunity__c customOpportunity : planList){
                if(Integer.valueOf(customOpportunity.PredYear__c) < 2018){
                    beCustomOpportunityList.add(customOpportunity);
                }
            }
            if(beCustomOpportunityList != null && beCustomOpportunityList.size() > 0){
                for(CustomOpportunity__c customOpportunitys : beCustomOpportunityList){
                    planList.remove(planList.indexOf(customOpportunitys));
                }
            }
        }
        //売上
        if(newProceedList != null && newProceedList.size() > 0){
            for (CustomObject3__c newObj : newProceedList) {             
                insertProceedPlanList(planList,newObj);
            }
        }
        //管理
        if(newManagementList != null && newManagementList.size() > 0){
            for (CustomObject1__c newObj : newManagementList) {             
                insertManagementPlanList(planList,newObj);
            }
        }
        

        // 長期計画挿入
        if (planList.size() > 0) {
            insert planList;
            
            setLastViewedDate();
        }

        //*************************************
        //長期修繕計画の自動展開
        //*************************************
    }

    /**
     * @description after update トリガーのハンドラ処理。
     * @param oldMap 更新前対象データ。
     * @param newMap 更新後対象データ。
     */
    public override void AfterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        /*List<Property_RepairItem__c> oldList = (List<Property_RepairItem__c>)oldMap.values();
        List<Property_RepairItem__c> newList = (List<Property_RepairItem__c>)newMap.values();*/
        
        // oldの過去データ削除
        /*for (Property_RepairItem__c oldObj : oldList) {             
            deletePlanList(oldObj);
        }
            
        // newの修繕計画リスト展開
        List<CustomOpportunity__c> planList = new List<CustomOpportunity__c>(); 
        
        for (Property_RepairItem__c newObj : newList) { 
            insertPlanList(planList,newObj);
        }
        
        // 長期計画挿入
        if (planList.size() > 0) {
            insert planList;
            
            setLastViewedDate();
        }   */    
    }

    /**
     * @description after delete トリガーのハンドラ処理。
     * @param oldMap 対象データ。
     */
    public override void AfterDelete(Map<Id, SObject> oldMap) {
        //List<Property_RepairItem__c> oldList = (List<Property_RepairItem__c>)oldMap.values();
    }
    
    // 長期修繕計画挿入処理　　「物件別工事計画（マスタから選択）」から作成
    private void insertPlanList( List<CustomOpportunity__c> planList,Property_RepairItem__c newObj){

        Property_RepairItem__c proRepItems = 
            [SELECT Id,Name,workPeriod__c,SuppliersSelect__c,PredictionExpense__c, PropertyName__r.Name,PropertyName__r.Id,PropertyName__r.RebuildingPredictionYear__c,
             PropertyName__r.completionDay__c, RepairItem__r.repairCycle__c, RepairItem__r.Name, RemovalPlan__c, RepairItem__r.Account_Number__c, 
             RepairItem__r.Account_Name__c, RepairItem__r.RemovedAccountCode__c, RepairItem__r.RemovedAccountName__c, koujiMemo__c, 
             RepairItem__r.FixedassetRepair__c, PropertyName__r.ManagingDepartment__c FROM Property_RepairItem__c WHERE Id = :newObj.Id LIMIT 1];

        //計画修繕レコードタイプの指定
        RecordType recordTypes = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'CustomOpportunity__c' AND Name = '計画工事'];
        // 修繕周期
        Integer repairCycle = proRepItems.RepairItem__r.repairCycle__c.intValue();
        if(repairCycle <= 0 ) return; //周期がゼロ or 未設定？
        // 竣工年月日
        Date completionDay = proRepItems.PropertyName__r.completionDay__c;
        // 建替予定年(過去日付はNG)
        Integer RebuildingPredictionYear = completionDay.addMonths(60 * 12).year();        
        // 業者選定開始見込日
        Date suppliersSelPreparationDay ;
        // 予定年
        String PredYear = '';
        // 建替年
        if(proRepItems.PropertyName__r.RebuildingPredictionYear__c != null){
            RebuildingPredictionYear = Integer.valueOf(proRepItems.PropertyName__r.RebuildingPredictionYear__c);     
        }
        // (建替年 - 竣工年)/周期 四捨五入
        Integer su = Math.round((RebuildingPredictionYear - completionDay.year())/repairCycle);
        Date tmpDay = Date.newInstance(9999, 12, 31);
        
        // システム日付～建替年まで展開
        for (Integer i = 1; i <= su; i++) {
            tmpDay = completionDay.addMonths(repairCycle * 12 * i);
            // 建替予定年を超えたらループ終了
            if(Integer.valueOf(tmpDay.year()) > RebuildingPredictionYear){
                break;
            }
            // 予定年
            PredYear = String.valueOf(tmpDay.year());
            // 業者選定開始見込日
            if(proRepItems.SuppliersSelect__c <> null){
               
//                suppliersSelPreparationDay= completionDay.addMonths(repairCycle * 12 * i-Integer.valueOf(proRepItems.workPeriod__c)-Integer.valueOf(proRepItems.SuppliersSelect__c));                
                  suppliersSelPreparationDay= completionDay.addMonths(repairCycle * 12 * i-Integer.valueOf(proRepItems.SuppliersSelect__c));                
            }

            // システム日付以降のみ展開
//            if (tmpDay >= System.today() ){ // 今後、年対比に変更 //PropertyName__c=proRepItems.PropertyName__r.Id,
                planList.add(new CustomOpportunity__c(
                                PropertyRepairItem__c=proRepItems.Id,    
                                RecordTypeId=recordTypes.Id,  // 計画修繕レコードタイプの指定
                                Name=String.valueOf(PredYear)+'_'+proRepItems.PropertyName__r.Name +'_'+proRepItems.RepairItem__r.Name,// 予定年_物件名_修繕項目
                                propertyName__c=proRepItems.PropertyName__r.Id,
                    			workPeriod__c=proRepItems.workPeriod__c,
                                PredYear__c=PredYear,
                                //suppliersSelPreparationDay__c=suppliersSelPreparationDay,
                                PredictionExpense__c=proRepItems.PredictionExpense__c,
                                RemoveBudgetNoTax__c=proRepItems.RemovalPlan__c,
                                ConstructionAccountCode__c=proRepItems.RepairItem__r.Account_Number__c,
                                ConstructionAccountName__c=proRepItems.RepairItem__r.Account_Name__c,
                                RemovedAccountCode__c=proRepItems.RepairItem__r.RemovedAccountCode__c,
                                RemovedAccountName__c=proRepItems.RepairItem__r.RemovedAccountName__c,
                                ConstructionDetails__c=proRepItems.koujiMemo__c,
                                FixedassetRepair__c=proRepItems.RepairItem__r.FixedassetRepair__c,
                                ManagingDepartment__c=proRepItems.PropertyName__r.ManagingDepartment__c
                                //PropertyElapsedYear__c = repairCycle * i 
                                ));
//            }
        }
    }
    
    // 長期修繕計画削除処理(予定年>システム年は削除)　　「物件別工事計画（マスタから選択）」から作成
    private void deletePlanList( Property_RepairItem__c oldObj){

        // 今年以降は削除
        String thisYear = String.valueOf(system.today().year());       
        CustomOpportunity__c[] delList = [SELECT Id,Name,PropertyRepairItem__c,PredYear__c from CustomOpportunity__c where PropertyRepairItem__c = :oldObj.Id]; // 全部削除（今年以降とかする必要あるか）

        delete delList;
    }    
    
    // LastViewedDateの設定(最近参照したデータへの反映)　　「物件別工事計画（マスタから選択）」から作成
    private void setLastViewedDate( ) {
        CustomOpportunity__c[] techContacts = [SELECT Id,Name FROM CustomOpportunity__c FOR VIEW];
    }



    // 長期修繕計画挿入処理　　物件別管理計画（マスタから選択）から
    private void insertManagementPlanList( List<CustomOpportunity__c> planList,CustomObject1__c newObj){

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
                                                Manage__r.AccountNo__c, //管理マスタ勘定科目コード
                                                Manage__r.AccountName__c, //管理マスタ勘定科目名称
                                                Property_Name__r.ManagingDepartment__c, //物件 社内管理部署
                                                Manage__r.Name //管理マスタ 管理名
                                        FROM CustomObject1__c WHERE Id = :newObj.Id LIMIT 1];

        //計画修繕レコードタイプの指定
        RecordType recordTypes = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'CustomOpportunity__c' AND Name = '計画管理'];
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
                    planList.add(new CustomOpportunity__c(
                                    PlanManagementNum__c = managementPlan.Id,  //計画管理番号  
                                    RecordTypeId = recordTypes.Id,  // 計画修繕レコードタイプの指定
                                    Name = managementPlanNumMap.get(skey) + skey + '_' + managementPlan.Property_Name__r.Name + '_' + managementPlan.Manage__r.Name,// 物件別管理名
                                    propertyName__c = managementPlan.Property_Name__r.Id, //物件名
                                    PredYear__c = managementPlanNumMap.get(skey), //予定年
                                    ManagementBudgetNoTax__c = managementPlan.Manage_PlanNoTax__c, //管理予算（税抜）
                                    ManagementAccountCode__c = managementPlan.Manage__r.AccountNo__c, //管理勘定科目コード
                                    ManagementAccountName__c = managementPlan.Manage__r.AccountName__c, //管理勘定科目名称
                                    ManagingDepartment__c = managementPlan.Property_Name__r.ManagingDepartment__c, //物件の社内管理部署
                                    PredMonth__c = String.valueOf(Integer.valueOf(skey)) ));//予定月
                }
            }
        }
        
        
    }

    // 長期修繕計画削除処理(予定年>システム年は削除)　物件別管理計画（マスタから選択）から
    private void deleteManagementPlanList( CustomObject1__c oldObj){

        // 今年以降は削除
        String thisYear = String.valueOf(system.today().year());       
        CustomOpportunity__c[] delList = [SELECT Id, Name from CustomOpportunity__c where PlanManagementNum__c = :oldObj.Id]; // 全部削除（今年以降とかする必要あるか）

        delete delList;
    }



    // 長期修繕計画挿入処理　物件別売上計画（マスタから選択）から
    private void insertProceedPlanList( List<CustomOpportunity__c> planList,CustomObject3__c newObj){

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
                                                Sales__r.Account_Number__c, //売上マスタ 勘定科目コード
                                                Sales__r.Account_Name__c, //売上マスタ 勘定科目名称
                                                Property_Name__r.ManagingDepartment__c, //物件 社内管理部署
                                                Sales__r.Name //売上マスタ 管理名
                                        FROM CustomObject3__c WHERE Id = :newObj.Id LIMIT 1];

        //計画修繕レコードタイプの指定
        RecordType recordTypes = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'CustomOpportunity__c' AND Name = '計画売上'];
        //物件の 竣工年月日 後60年
        Integer completionYearAfter = proceedsPlan.Property_Name__r.completionDay__c.year() + 60;
        //計画年 数字
        
        Integer planYear = Integer.valueOf(proceedsPlan.Planned_Year__c);
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
                    planList.add(new CustomOpportunity__c(
                                    PlanProceedNum__c = proceedsPlan.Id,  //計画売上番号  
                                    RecordTypeId = recordTypes.Id,  // 計画修繕レコードタイプの指定
                                    Name = proceedsPlanNumMap.get(skey) + skey + '_' + proceedsPlan.Property_Name__r.Name + '_' + proceedsPlan.Sales__r.Name,// 物件別管理名
                                    propertyName__c = proceedsPlan.Property_Name__r.Id, //物件名
                                    PredYear__c = proceedsPlanNumMap.get(skey), //予定年
                                    ProceedBudgetNoTax__c = proceedsPlan.SalesBudgetNoTax__c, //売上予算（税抜）
                                    SalesAccountCode__c = proceedsPlan.Sales__r.Account_Number__c, //売上勘定科目コード
                                    SalesAccountName__c = proceedsPlan.Sales__r.Account_Name__c, //売上勘定科目名称
                                    ManagingDepartment__c = proceedsPlan.Property_Name__r.ManagingDepartment__c, //物件の社内管理部署
                                    PredMonth__c = String.valueOf(Integer.valueOf(skey)) ));//予定月
                }
            }
        }
        
    }

    // 長期修繕計画削除処理(予定年>システム年は削除)　物件別売上計画（マスタから選択）から
    private void deleteProceedPlanList( CustomObject3__c oldObj){

        // 今年以降は削除
        String thisYear = String.valueOf(system.today().year());       
        CustomOpportunity__c[] delList = [SELECT Id, Name from CustomOpportunity__c where PlanProceedNum__c = :oldObj.Id]; // 全部削除（今年以降とかする必要あるか）

        delete delList;
    }
 }
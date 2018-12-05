@isTest
public class RepairPlanExpansionTest {
	static testMethod void test_RepairPlanExpansionTrigger() {
		Test.startTest();

		//取引先
		Account account = new Account(Name = 'testaccount');
        insert account;
        //物件管理
        PropertyObj__c propertyObj = new PropertyObj__c(Name = 'test', 
							PropertyDivision__c = '事務所', 
							propertyFrame__c = '鉄骨造', 
							TargetUnits__c = 5, 
							TotalUnits__c = 8,
							OwnerName__c = account.Id, 
							ManagingDepartment__c = 'ビル管理部', 
							completionDay__c = System.today()
							);
        insert propertyObj;
        //工事マスタ	
        RepairItemMaster__c repairItemMaster = new RepairItemMaster__c(
        					Name = 'test', 
        					Type__c = '屋根', 
        					FixedassetRepair__c = '固定資産工事	', 
        					Planned__c = true, 
        					repairCycle__c = 2);
        insert repairItemMaster;
        //工事計画
        Property_RepairItem__c propertyRepairItem = new Property_RepairItem__c(
        					PropertyName__c = propertyObj.Id, 
                  RepairItem__c = repairItemMaster.Id, 
        					RemovalPlan__c = 100000, 
        					PredictionExpense__c = 100000);
        insert propertyRepairItem;
        update propertyRepairItem;
        delete propertyRepairItem;
		Test.stopTest();
	}

        static testMethod void test_ManagementPlanTrigger() {
        Test.startTest();

        //取引先
        Account account = new Account(Name = 'testaccount');
        insert account;
        //物件管理
        PropertyObj__c propertyObj = new PropertyObj__c(Name = 'test', 
                                                        PropertyDivision__c = '事務所', 
                                                        propertyFrame__c = '鉄骨造', 
                                                        TargetUnits__c = 5, 
                                                        TotalUnits__c = 8,
                                                        OwnerName__c = account.Id, 
                                                        ManagingDepartment__c = 'ビル管理部', 
                                                        completionDay__c = System.today()
                                                        );
        insert propertyObj;
        //管理マスタ
        ManagementPlanMaster__c managementPlanMaster = new ManagementPlanMaster__c(Name = 'test', 
                                                                                        Type__c = '内装', 
                                                                                        Plan__c = true, 
                                                                                        RepairTimes__c = 1, 
                                                                                        X4__c = true, 
                                                                                        X2__c = true);
        insert managementPlanMaster;
        //物件別管理計画（マスタから選択）
        CustomObject1__c managementPlan = new CustomObject1__c(Property_Name__c = propertyObj.Id, 
                                                                Manage__c = managementPlanMaster.Id, 
                                                                Manage_PlanNoTax__c = 100000,
                                                                Planned_Year__c = '2018'
                                                                );
        insert managementPlan;
        managementPlan.Manage_PlanNoTax__c = 150000;
        update managementPlan;
        delete managementPlan;
        
        Test.stopTest();
        }

        static testMethod void test_ProceedsPlanTrigger() {
                Test.startTest();

                //取引先
                Account account = new Account(Name = 'testaccount');
        insert account;
        //物件管理
        PropertyObj__c propertyObj = new PropertyObj__c(Name = 'test', 
                                                        PropertyDivision__c = '事務所', 
                                                        propertyFrame__c = '鉄骨造', 
                                                        TargetUnits__c = 5, 
                                                        TotalUnits__c = 8,
                                                        OwnerName__c = account.Id, 
                                                        ManagingDepartment__c = 'ビル管理部', 
                                                        completionDay__c = System.today()
                                                        );
        insert propertyObj;
        //売上マスタ
        CustomObject2__c proceedsPlanMaster = new CustomObject2__c(Name = 'test', 
                                                                                                                Type__c = '業務委託料', 
                                                                                                                Plan__c = true, 
                                                                                                                Cycle_Year__c = 1, 
                                                                                                                X4__c = true, 
                                                                                                                X10__c = true);
        insert proceedsPlanMaster;
        //物件別売上計画（マスタから選択）
        CustomObject3__c proceedsPlan = new CustomObject3__c(Property_Name__c = propertyObj.Id, 
                                                                                                                Sales__c = proceedsPlanMaster.Id, 
                                                                                                                SalesBudgetNoTax__c = 150000,
                                                                                                                Planned_Year__c = '2018'
                                                                                                                );
        insert proceedsPlan;
        proceedsPlan.SalesBudgetNoTax__c = 200000;
        update proceedsPlan;
        delete proceedsPlan;
                Test.stopTest();
        }

        static testMethod void test_CustomOpportunityTrigger() {

                Test.startTest();
                //取引先
                Account account = new Account(Name = 'testaccount');
                insert account;
                //物件管理
                PropertyObj__c propertyObj = new PropertyObj__c(Name = 'test', 
                                                                PropertyDivision__c = '事務所', 
                                                                propertyFrame__c = '鉄骨造', 
                                                                TargetUnits__c = 5, 
                                                                TotalUnits__c = 8,
                                                                OwnerName__c = account.Id, 
                                                                ManagingDepartment__c = 'ビル管理部', 
                                                                completionDay__c = System.today()
                                                                );
                insert propertyObj;
                //工事マスタ 
                RepairItemMaster__c repairItemMaster = new RepairItemMaster__c(
                                                        Name = 'test', 
                                                        Type__c = '屋根', 
                                                        FixedassetRepair__c = '修繕工事     ', 
                                                        Planned__c = true, 
                                                        repairCycle__c = 2);
                insert repairItemMaster;
                //物件別予実
                CustomOpportunity__c customOpportunity = new CustomOpportunity__c(Name = 'test', 
                                                                                   propertyName__c =   propertyObj.Id,
                                                                                   ClassificationOutConstruction__c = '防水', 
                                                                                   RepairItem__c = repairItemMaster.Id, 
                                                                                   PredYear__c = '2018', 
                                                                                   PredMonth__c = '05', 
                                                                                   StageName__c = '01.発注前');
                insert customOpportunity;
                RecordType recordType = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'RecordType1' AND SobjectType = 'CustomOpportunity__c'];

                customOpportunity.RecordTypeId = recordType.Id;
                update customOpportunity;

                Test.stopTest();

        }

        static testMethod void executeHandlerTest() {

                CustomTesthandler chandler = new CustomTesthandler();
                chandler.IsDisabled();
                chandler.BeforeUpdate(new Map<Id, SObject>(),new Map<Id, SObject>());
                chandler.BeforeDelete(new Map<Id, SObject>());
                chandler.AfterInsert(new Map<Id, SObject>());
                chandler.AfterUpdate(new Map<Id, SObject>(),new Map<Id, SObject>());
                chandler.AfterDelete(new Map<Id, SObject>());
                chandler.AfterUndelete(new Map<Id, SObject>());
        }


        class CustomTesthandler extends TriggerHandler{

              public override Boolean IsDisabled(){
                 super.IsDisabled();
                 return false;
              }


              public override void BeforeInsert(List<SObject> newLis){
                 super.BeforeInsert(newLis);
              }

              public override void BeforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
                 super.BeforeUpdate(oldMap,newMap);
                 return;
              }

               /**
                * @description before delete トリガーのハンドラ処理。
                * @param oldMap 対象データ。
                */
               public override void BeforeDelete(Map<Id, SObject> oldMap) {
                  super.BeforeDelete(oldMap);
                  return;
               }

               /**
                * @description after insert トリガーのハンドラ処理。
                * @param oldMap 新規作成前対象データ。
                */
               public override void AfterInsert(Map<Id, SObject> newMap) {
                  super.AfterInsert(newMap);
                  return;
               }

               /**
                * @description after update トリガーのハンドラ処理。
                * @param oldMap 更新前対象データ。
                * @param newMap 更新後対象データ。
                */
               public override void AfterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
                  super.AfterUpdate(oldMap,newMap);
                  return;
               }

               /**
                * @description after delete トリガーのハンドラ処理。
                * @param oldMap 対象データ。
                */
               public override void AfterDelete(Map<Id, SObject> oldMap) {
                  super.AfterDelete(oldMap);
                  return;
               }

               /**
                * @description after undelete トリガーのハンドラ処理。
                * @param oldMap 対象データ。
                */
               public override void AfterUndelete(Map<Id, SObject> newMap) {
                  super.AfterUndelete(newMap);
                  return;
               }
        }
}
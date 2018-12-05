@isTest
public class ManagementPlanTriggerTest {
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
								Manage_PlanNoTax__c = 100000 ,
								Planned_Year__c = '2018'
								);
        insert managementPlan;
        managementPlan.Manage_PlanNoTax__c = 150000;
        update managementPlan;
        delete managementPlan;
        
	Test.stopTest();
	}

}
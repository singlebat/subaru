@isTest
public class ProceedsPlanTriggerTest {
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

}
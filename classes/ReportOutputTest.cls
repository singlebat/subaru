@isTest
public class ReportOutputTest {
    @isTest
	static void departmentOutTest() {
        
        // 0.コントローラを利用するvisualforceページをテスト実行時の画面として設定         
        ReportOutput controller = new ReportOutput();        
        
        // 1.コントローラを利用するvisualforceページをテスト実行時の画面として設定
        PageReference pageRef = Page.ReportOutput;
        Test.setCurrentPage(pageRef);
    
        // 2.画面で操作するオブジェクトを生成

    	// 取引先
        Account account = new Account();
        account.Name = 'test';
        insert account;
        
        // レコードタイプ
        RecordType recType = [Select Id From RecordType  Where SobjectType = 'PropertyObj__c' and DeveloperName = 'Property'];

        // 物件管理
        PropertyObj__c propertyObj = new PropertyObj__c();
        propertyObj.RecordTypeId = recType.id;
        propertyObj.OwnerName__c = account.id;
        propertyObj.ManagingDepartment__c = '施設営業部';
        // 竣工年月日
        propertyObj.completionDay__c = Date.newInstance(2018,7,16);
        propertyObj.Name = '物件管理';
        // 物件区分
        propertyObj.PropertyDivision__c = '社宅';
        insert propertyObj;

        // *********計画工事以外******** 
        // 工事マスタ  RepairItemMaster
        RepairItemMaster__c repairItemMaster1 = new RepairItemMaster__c();
        // Name
        repairItemMaster1.name = '給湯器（ガス）';
        // 分類① Type__c
        repairItemMaster1.Type__c = '給水設備';
        // 分類② Type2__c
        repairItemMaster1.Type2__c = '給湯器（ガス）';
        // 計画 Planned__c
        repairItemMaster1.Planned__c = true;
        // 計画外 Unplanned__c
        repairItemMaster1.Unplanned__c = true;
        // 周期年 repairCycle__c
        repairItemMaster1.repairCycle__c = 20; 
        // 固定資産/修繕 FixedassetRepair__c
        repairItemMaster1.FixedassetRepair__c = '固定資産工事';
        insert repairItemMaster1;
               
        // レコードタイプ
        RecordType recType1 = [Select Id From RecordType  Where SobjectType = 'CustomOpportunity__c' and DeveloperName = 'Unplan_Repair'];
        
        // 物件別工事 CustomOpportunity__c
        CustomOpportunity__c customOpportunityPlan = new CustomOpportunity__c();    
        // 物件別予実名 Name
        customOpportunityPlan.Name = 'test';
        // 物件名 propertyName__c PropatyDisplay__c
        customOpportunityPlan.propertyName__c = propertyObj.id;
        customOpportunityPlan.PropatyDisplay__c = propertyObj.id;  
        // 分類（計画外工事選択用） ClassificationOutConstruction__c　　給水設備
        customOpportunityPlan.ClassificationOutConstruction__c = '給水設備'; 
        // 計画外工事 RepairItem__c
        customOpportunityPlan.RepairItem__c = repairItemMaster1.id; 
        // レコードタイプ RecordTypeId
        customOpportunityPlan.RecordTypeId = recType1.id; 
        // 予定年 PredYear__c
        customOpportunityPlan.PredYear__c = '2019'; 
        // 工事予算（税抜） PredictionExpense__c
        customOpportunityPlan.PredictionExpense__c = 300; 
        // 工事実績（税抜） RepairCostActual__c
        customOpportunityPlan.RepairCostActual__c = 300;
        insert customOpportunityPlan;
    
        // 3.標準コントローラを生成
        //   オブジェクトを渡してインスタンス化する
        ApexPages.StandardController stdController = new ApexPages.StandardController(customOpportunityPlan);
    
        // 4.コントローラ拡張を生成
        //   標準コントローラを渡してインスタンス化する
        ReportOutput extController = new ReportOutput(stdController);
        CustomOpportunity__c cusopp=new CustomOpportunity__c();
        cusopp = extController.cusopp;
        system.debug('extController:cusopp  ' + cusopp.PropatyDisplay__c);
        List<SelectOption> getKinds = new List<SelectOption>();
        getKinds = extController.getKinds();
    
        // 5.コントローラ拡張の独自メソッドを実行
        PageReference nextPage = extController.departmentOut();
    }
    
    @isTest
	static void businessUnitOutTest() {
        
       PropertyObj__c propertyObj = new PropertyObj__c();
        // 竣工年月日
        propertyObj.completionDay__c = Date.newInstance(2018,7,16);
        // 社内管理部署
        propertyObj.ManagingDepartment__c = 'ビル管理部';
        insert propertyObj;
        
       CustomOpportunity__c customOpportunity = new CustomOpportunity__c();
       customOpportunity.propertyName__c = propertyObj.id;
       insert customOpportunity;
        
       ReportOutput reportOutput = new ReportOutput();
        reportOutput.businessUnitOut();
    }

}
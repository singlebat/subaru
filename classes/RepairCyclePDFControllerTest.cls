@IsTest
public class RepairCyclePDFControllerTest {
    
    // 計画外工事 一つデータだけ
    @IsTest 
    static void TestOtherPDFRepairCyclePDFController1(){

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
        // レコードタイプ
        RecordType recType1 = [Select Id From RecordType  Where SobjectType = 'CustomOpportunity__c' and DeveloperName = 'Unplan_Repair'];

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
        
        // 物件別工事 CustomOpportunity__c
        CustomOpportunity__c customOpportunityPlan = new CustomOpportunity__c();    
        // 物件別予実名 Name
        customOpportunityPlan.Name = 'test';
        // 物件名 propertyName__c
        customOpportunityPlan.propertyName__c = propertyObj.id;  
        // 分類（計画外工事選択用） ClassificationOutConstruction__c　　給水設備
        customOpportunityPlan.ClassificationOutConstruction__c = '給水設備'; 
        // 計画外工事 RepairItem__c
        customOpportunityPlan.RepairItem__c = repairItemMaster1.id; 
        // レコードタイプ RecordTypeId
        customOpportunityPlan.RecordTypeId = recType1.id; 
        // 予定年 PredYear__c
        customOpportunityPlan.PredYear__c = '2019'; 
        // 工事予算（税抜） PredictionExpense__c
       // customOpportunityPlan.PredictionExpense__c = 300; 
        // 開始日 StartDay__c
       // customOpportunityPlan.StartDay__c =  Date.newInstance(2018,7,16);; 
        // ステータス StageName__c.発注前
       // customOpportunityPlan.StageName__c = '発注前'; 
        // 工事実績（税抜） RepairCostActual__c
      //  customOpportunityPlan.RepairCostActual__c = 300;
        insert customOpportunityPlan;
        
       ApexPages.currentPage().getParameters().put('id',propertyObj.Id);        
       ApexPages.currentPage().getParameters().put('name',propertyObj.Name);        
       ApexPages.currentPage().getParameters().put('completionYear',string.valueOf(propertyObj.completionDay__c));
       new RepairCyclePDFController();
    }
    
    // 計画外工事 二つ（同じ分類①ー＞同じ工事ID）
    @IsTest 
    static void TestOtherPDFRepairCyclePDFController2(){

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
        // レコードタイプ
        RecordType recType1 = [Select Id From RecordType  Where SobjectType = 'CustomOpportunity__c' and DeveloperName = 'Unplan_Repair'];

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
        
        // 物件別工事 CustomOpportunity__c
        CustomOpportunity__c customOpportunityPlan = new CustomOpportunity__c();    
        // 物件別予実名 Name
        customOpportunityPlan.Name = 'test';
        // 物件名 propertyName__c
        customOpportunityPlan.propertyName__c = propertyObj.id;  
        // 分類（計画外工事選択用） ClassificationOutConstruction__c　　給水設備
        customOpportunityPlan.ClassificationOutConstruction__c = '給水設備'; 
        // 計画外工事 RepairItem__c
        customOpportunityPlan.RepairItem__c = repairItemMaster1.id; 
        // レコードタイプ RecordTypeId
        customOpportunityPlan.RecordTypeId = recType1.id; 
        // 予定年 PredYear__c
        customOpportunityPlan.PredYear__c = '2019'; 
        // 工事予算（税抜） PredictionExpense__c
       // customOpportunityPlan.PredictionExpense__c = 300; 
        // 開始日 StartDay__c
       // customOpportunityPlan.StartDay__c =  Date.newInstance(2018,7,16);; 
        // ステータス StageName__c.発注前
       // customOpportunityPlan.StageName__c = '発注前'; 
        // 工事実績（税抜） RepairCostActual__c
       // customOpportunityPlan.RepairCostActual__c = 300;
        insert customOpportunityPlan;
        
        // 物件別工事 CustomOpportunity__c
        CustomOpportunity__c customOpportunityPlan1 = new CustomOpportunity__c();    
        // 物件別予実名 Name
        customOpportunityPlan1.Name = 'test';
        // 物件名 propertyName__c
        customOpportunityPlan1.propertyName__c = propertyObj.id;  
        // 分類（計画外工事選択用） ClassificationOutConstruction__c　　給水設備
        customOpportunityPlan1.ClassificationOutConstruction__c = '給水設備'; 
        // 計画外工事 RepairItem__c
        customOpportunityPlan1.RepairItem__c = repairItemMaster1.id; 
        // レコードタイプ RecordTypeId
        customOpportunityPlan1.RecordTypeId = recType1.id; 
        // 予定年 PredYear__c
        customOpportunityPlan1.PredYear__c = '2020'; 
        // 工事予算（税抜） PredictionExpense__c
        customOpportunityPlan1.PredictionExpense__c = 300; 
        // 開始日 StartDay__c
       // customOpportunityPlan.StartDay__c =  Date.newInstance(2018,7,16);; 
        // ステータス StageName__c.発注前
       // customOpportunityPlan.StageName__c = '発注前'; 
        // 工事実績（税抜） RepairCostActual__c
        customOpportunityPlan1.RepairCostActual__c = 300;
        insert customOpportunityPlan1;
        
       ApexPages.currentPage().getParameters().put('id',propertyObj.Id);        
       ApexPages.currentPage().getParameters().put('name',propertyObj.Name);        
       ApexPages.currentPage().getParameters().put('completionYear',string.valueOf(propertyObj.completionDay__c));
       new RepairCyclePDFController();
    }
    
    // 計画外工事 三つ（同じ分類①ー＞工事２個）
    @IsTest 
    static void TestOtherPDFRepairCyclePDFController3(){

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
        // レコードタイプ
        RecordType recType1 = [Select Id From RecordType  Where SobjectType = 'CustomOpportunity__c' and DeveloperName = 'Unplan_Repair'];

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
        

        // 工事マスタ  RepairItemMaster
        RepairItemMaster__c repairItemMaster2 = new RepairItemMaster__c();
        // Name
        repairItemMaster2.name = '給湯器（ガス）';
        // 分類① Type__c
        repairItemMaster2.Type__c = '給水設備';
        // 分類② Type2__c
        repairItemMaster2.Type2__c = '給水管';
        // 計画 Planned__c
        repairItemMaster2.Planned__c = true;
        // 計画外 Unplanned__c
        repairItemMaster2.Unplanned__c = true;
        // 周期年 repairCycle__c
        repairItemMaster2.repairCycle__c = 20; 
        // 固定資産/修繕 FixedassetRepair__c
        repairItemMaster2.FixedassetRepair__c = '固定資産工事';
        insert repairItemMaster2;
        
        // 物件別工事 CustomOpportunity__c
        CustomOpportunity__c customOpportunityPlan = new CustomOpportunity__c();    
        // 物件別予実名 Name
        customOpportunityPlan.Name = 'test';
        // 物件名 propertyName__c
        customOpportunityPlan.propertyName__c = propertyObj.id;  
        // 分類（計画外工事選択用） ClassificationOutConstruction__c　　給水設備
        customOpportunityPlan.ClassificationOutConstruction__c = '給水設備'; 
        // 計画外工事 RepairItem__c
        customOpportunityPlan.RepairItem__c = repairItemMaster1.id; 
        // レコードタイプ RecordTypeId
        customOpportunityPlan.RecordTypeId = recType1.id; 
        // 予定年 PredYear__c
        customOpportunityPlan.PredYear__c = '2020'; 
        // 工事予算（税抜） PredictionExpense__c
        customOpportunityPlan.PredictionExpense__c = 300; 
        // 開始日 StartDay__c
       // customOpportunityPlan.StartDay__c =  Date.newInstance(2018,7,16);; 
        // ステータス StageName__c.発注前
       // customOpportunityPlan.StageName__c = '発注前'; 
        // 工事実績（税抜） RepairCostActual__c
        customOpportunityPlan.RepairCostActual__c = 300;
        insert customOpportunityPlan;
        
        // 物件別工事 CustomOpportunity__c
        CustomOpportunity__c customOpportunityPlan1 = new CustomOpportunity__c();    
        // 物件別予実名 Name
        customOpportunityPlan1.Name = 'test';
        // 物件名 propertyName__c
        customOpportunityPlan1.propertyName__c = propertyObj.id;  
        // 分類（計画外工事選択用） ClassificationOutConstruction__c　　給水設備
        customOpportunityPlan1.ClassificationOutConstruction__c = '給水設備'; 
        // 計画外工事 RepairItem__c
        customOpportunityPlan1.RepairItem__c = repairItemMaster2.id; 
        // レコードタイプ RecordTypeId
        customOpportunityPlan1.RecordTypeId = recType1.id; 
        // 予定年 PredYear__c
        customOpportunityPlan1.PredYear__c = '2020'; 
        // 工事予算（税抜） PredictionExpense__c
        //customOpportunityPlan1.PredictionExpense__c = 300; 
        // 開始日 StartDay__c
       // customOpportunityPlan.StartDay__c =  Date.newInstance(2018,7,16);; 
        // ステータス StageName__c.発注前
       // customOpportunityPlan.StageName__c = '発注前'; 
        // 工事実績（税抜） RepairCostActual__c
       // customOpportunityPlan1.RepairCostActual__c = 300;
        insert customOpportunityPlan1;
        
       ApexPages.currentPage().getParameters().put('id',propertyObj.Id);        
       ApexPages.currentPage().getParameters().put('name',propertyObj.Name);        
       ApexPages.currentPage().getParameters().put('completionYear',string.valueOf(propertyObj.completionDay__c));
       new RepairCyclePDFController();
    }
    
    // 計画外工事 三つ（同じ分類①ー＞工事２個）
    @IsTest 
    static void TestOtherPDFRepairCyclePDFController4(){

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
        // レコードタイプ
        RecordType recType1 = [Select Id From RecordType  Where SobjectType = 'CustomOpportunity__c' and DeveloperName = 'Unplan_Repair'];

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
        

        // 工事マスタ  RepairItemMaster
        RepairItemMaster__c repairItemMaster2 = new RepairItemMaster__c();
        // Name
        repairItemMaster2.name = '給湯器（ガス）';
        // 分類① Type__c
        repairItemMaster2.Type__c = '給水設備';
        // 分類② Type2__c
        repairItemMaster2.Type2__c = '給水管';
        // 計画 Planned__c
        repairItemMaster2.Planned__c = true;
        // 計画外 Unplanned__c
        repairItemMaster2.Unplanned__c = true;
        // 周期年 repairCycle__c
        repairItemMaster2.repairCycle__c = 20; 
        // 固定資産/修繕 FixedassetRepair__c
        repairItemMaster2.FixedassetRepair__c = '固定資産工事';
        insert repairItemMaster2;
        
        // 物件別工事 CustomOpportunity__c
        CustomOpportunity__c customOpportunityPlan = new CustomOpportunity__c();    
        // 物件別予実名 Name
        customOpportunityPlan.Name = 'test';
        // 物件名 propertyName__c
        customOpportunityPlan.propertyName__c = propertyObj.id;  
        // 分類（計画外工事選択用） ClassificationOutConstruction__c　　給水設備
        customOpportunityPlan.ClassificationOutConstruction__c = '給水設備'; 
        // 計画外工事 RepairItem__c
        customOpportunityPlan.RepairItem__c = repairItemMaster1.id; 
        // レコードタイプ RecordTypeId
        customOpportunityPlan.RecordTypeId = recType1.id; 
        // 予定年 PredYear__c
        customOpportunityPlan.PredYear__c = '2020'; 
        // 工事予算（税抜） PredictionExpense__c
        customOpportunityPlan.PredictionExpense__c = 300; 
        // 開始日 StartDay__c
       // customOpportunityPlan.StartDay__c =  Date.newInstance(2018,7,16);; 
        // ステータス StageName__c.発注前
       // customOpportunityPlan.StageName__c = '発注前'; 
        // 工事実績（税抜） RepairCostActual__c
        customOpportunityPlan.RepairCostActual__c = 300;
        insert customOpportunityPlan;
        
        // 物件別工事 CustomOpportunity__c
        CustomOpportunity__c customOpportunityPlan1 = new CustomOpportunity__c();    
        // 物件別予実名 Name
        customOpportunityPlan1.Name = 'test';
        // 物件名 propertyName__c
        customOpportunityPlan1.propertyName__c = propertyObj.id;  
        // 分類（計画外工事選択用） ClassificationOutConstruction__c　　給水設備
        customOpportunityPlan1.ClassificationOutConstruction__c = '給水設備'; 
        // 計画外工事 RepairItem__c
        customOpportunityPlan1.RepairItem__c = repairItemMaster2.id; 
        // レコードタイプ RecordTypeId
        customOpportunityPlan1.RecordTypeId = recType1.id; 
        // 予定年 PredYear__c
        customOpportunityPlan1.PredYear__c = '2020'; 
        // 工事予算（税抜） PredictionExpense__c
        //customOpportunityPlan1.PredictionExpense__c = 300; 
        // 開始日 StartDay__c
       // customOpportunityPlan.StartDay__c =  Date.newInstance(2018,7,16);; 
        // ステータス StageName__c.発注前
       // customOpportunityPlan.StageName__c = '発注前'; 
        // 工事実績（税抜） RepairCostActual__c
       // customOpportunityPlan1.RepairCostActual__c = 300;
        insert customOpportunityPlan1;
        
        // 物件別工事 CustomOpportunity__c  customOpportunityPlan1と同じ工事ID
        CustomOpportunity__c customOpportunityPlan2 = new CustomOpportunity__c();    
        // 物件別予実名 Name
        customOpportunityPlan2.Name = 'test';
        // 物件名 propertyName__c
        customOpportunityPlan2.propertyName__c = propertyObj.id;  
        // 分類（計画外工事選択用） ClassificationOutConstruction__c　　給水設備
        customOpportunityPlan2.ClassificationOutConstruction__c = '給水設備'; 
        // 計画外工事 RepairItem__c
        customOpportunityPlan2.RepairItem__c = repairItemMaster2.id; 
        // レコードタイプ RecordTypeId
        customOpportunityPlan2.RecordTypeId = recType1.id; 
        // 予定年 PredYear__c
        customOpportunityPlan2.PredYear__c = '2021'; 
        // 工事予算（税抜） PredictionExpense__c
        //customOpportunityPlan1.PredictionExpense__c = 300; 
        // 開始日 StartDay__c
       // customOpportunityPlan.StartDay__c =  Date.newInstance(2018,7,16);; 
        // ステータス StageName__c.発注前
       // customOpportunityPlan.StageName__c = '発注前'; 
        // 工事実績（税抜） RepairCostActual__c
       // customOpportunityPlan1.RepairCostActual__c = 300;
        insert customOpportunityPlan2;
        
       ApexPages.currentPage().getParameters().put('id',propertyObj.Id);        
       ApexPages.currentPage().getParameters().put('name',propertyObj.Name);        
       ApexPages.currentPage().getParameters().put('completionYear',string.valueOf(propertyObj.completionDay__c));
       new RepairCyclePDFController();
    }



    // 計画工事と計画外工事
    @IsTest
    static void TestRepairCyclePDFController(){

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

        // 工事マスタ  RepairItemMaster
        RepairItemMaster__c repairItemMaster1 = new RepairItemMaster__c();
        // Name
        repairItemMaster1.name = 'Test';
        // 分類① Type__c
        repairItemMaster1.Type__c = '防水';
        // 分類② Type2__c
        repairItemMaster1.Type2__c = 'FRP複合防水';
        // 計画 Planned__c
        repairItemMaster1.Planned__c = true;
        // 計画外 Unplanned__c
        repairItemMaster1.Unplanned__c = true;
        // 周期年 repairCycle__c
        repairItemMaster1.repairCycle__c = 20; 
        // 固定資産/修繕 FixedassetRepair__c
        repairItemMaster1.FixedassetRepair__c = 'Test';
        insert repairItemMaster1;

        // 工事マスタ  RepairItemMaster
        RepairItemMaster__c repairItemMaster2 = new RepairItemMaster__c();
        // Name
        repairItemMaster2.name = 'Test';
        // 分類① Type__c
        repairItemMaster2.Type__c = '給水設備';
        // 分類② Type2__c
        repairItemMaster2.Type2__c = '給湯器（ガス）';
        // 計画 Planned__c
        repairItemMaster2.Planned__c = true;
        // 計画外 Unplanned__c
        repairItemMaster2.Unplanned__c = true;
        // 周期年 repairCycle__c
        repairItemMaster2.repairCycle__c = 20; 
        // 固定資産/修繕 FixedassetRepair__c
        repairItemMaster2.FixedassetRepair__c = 'Test';
        insert repairItemMaster2;

        // 物件別工事計画（マスタから選択） Property_RepairItem__c
        Property_RepairItem__c pRepairItem = new Property_RepairItem__c();
        // 物件別計画工事番号 naem
       // pRepairItem.Name = 'Test';
        // 物件名 PropertyName__c
        pRepairItem.PropertyName__c = propertyObj.id;
        // 工事名 RepairItem__c
        pRepairItem.RepairItem__c = repairItemMaster1.id;
        // 工事計画（税抜） PredictionExpense__c
        pRepairItem.PredictionExpense__c = 200;
        insert pRepairItem;

        // 物件別工事計画（マスタから選択） Property_RepairItem__c
        Property_RepairItem__c pRepairItem2 = new Property_RepairItem__c();
        // 物件別計画工事番号 naem
       // pRepairItem.Name = 'Test';
        // 物件名 PropertyName__c
        pRepairItem2.PropertyName__c = propertyObj.id;
        // 工事名 RepairItem__c
        pRepairItem2.RepairItem__c = repairItemMaster2.id;
        // 工事計画（税抜） PredictionExpense__c
        pRepairItem2.PredictionExpense__c = 200;
        insert pRepairItem2;
        
        // レコードタイプ
        RecordType recType1 = [Select Id From RecordType  Where SobjectType = 'CustomOpportunity__c' and DeveloperName = 'repairFee'];

        // *********計画工事********
        // 物件別工事計画（マスタから選択） CustomOpportunity__c
        CustomOpportunity__c customOpportunity = new CustomOpportunity__c();  
        // 物件別予実名 Name
        customOpportunity.Name = 'aa'; 
        // 物件名 propertyName__c
        customOpportunity.propertyName__c = propertyObj.id;  
        // 計画番号（工事）PropertyRepairItem__c
        customOpportunity.PropertyRepairItem__c = pRepairItem.id; 
        // レコードタイプ RecordTypeId
        customOpportunity.RecordTypeId = recType1.id; 
        // 予定年 PredYear__c
        customOpportunity.PredYear__c = '2019'; 
        // 工事予算（税抜） PredictionExpense__c
        customOpportunity.PredictionExpense__c = 200; 
        // ステータス StageName__c.発注前
        customOpportunity.StageName__c = '発注前'; 
        // 工事実績（税抜） RepairCostActual__c
        customOpportunity.RepairCostActual__c = 300;
        insert customOpportunity;
        
        // 物件別工事計画（マスタから選択） CustomOpportunity__c
        CustomOpportunity__c customOpportunity1 = new CustomOpportunity__c();  
        // 物件別予実名 Name
        customOpportunity1.Name = 'aa'; 
        // 物件名 propertyName__c
        customOpportunity1.propertyName__c = propertyObj.id;  
        // 計画番号（工事）PropertyRepairItem__c
        customOpportunity1.PropertyRepairItem__c = pRepairItem.id; 
        // レコードタイプ RecordTypeId
        customOpportunity1.RecordTypeId = recType1.id; 
        // 予定年 PredYear__c
        customOpportunity1.PredYear__c = '2019'; 
        // 工事予算（税抜） PredictionExpense__c
        customOpportunity1.PredictionExpense__c = 200; 
        // ステータス StageName__c.発注前
        customOpportunity1.StageName__c = '発注前'; 
        // 工事実績（税抜） RepairCostActual__c
        customOpportunity1.RepairCostActual__c = 300;
        insert customOpportunity1;
        
        // 物件別工事計画（マスタから選択） CustomOpportunity__c-->分類①が上記と一致しない
        CustomOpportunity__c customOpportunity2 = new CustomOpportunity__c();  
        // 物件別予実名 Name
        customOpportunity2.Name = 'aa'; 
        // 物件名 propertyName__c
        customOpportunity2.propertyName__c = propertyObj.id;  
        // 計画番号（工事）PropertyRepairItem__c
        customOpportunity2.PropertyRepairItem__c = pRepairItem2.id; 
        // レコードタイプ RecordTypeId
        customOpportunity2.RecordTypeId = recType1.id; 
        // 予定年 PredYear__c
        customOpportunity2.PredYear__c = '2019'; 
        // 工事予算（税抜） PredictionExpense__c
        customOpportunity2.PredictionExpense__c = 200; 
        // ステータス StageName__c.発注前
        customOpportunity2.StageName__c = '発注前'; 
        // 工事実績（税抜） RepairCostActual__c
        customOpportunity2.RepairCostActual__c = 300; 
        insert customOpportunity2;

        // *********計画工事以外********        
        // レコードタイプ
        RecordType recType2 = [Select Id From RecordType  Where SobjectType = 'CustomOpportunity__c' and DeveloperName = 'Unplan_Repair'];

        // 工事マスタ  RepairItemMaster
        RepairItemMaster__c repairItemMaster3 = new RepairItemMaster__c();
        // Name
        repairItemMaster3.name = '給湯器（ガス）';
        // 分類① Type__c
        repairItemMaster3.Type__c = '給水設備';
        // 分類② Type2__c
        repairItemMaster3.Type2__c = '給湯器（ガス）';
        // 計画 Planned__c
        repairItemMaster3.Planned__c = true;
        // 計画外 Unplanned__c
        repairItemMaster3.Unplanned__c = true;
        // 周期年 repairCycle__c
        repairItemMaster3.repairCycle__c = 20; 
        // 固定資産/修繕 FixedassetRepair__c
        repairItemMaster3.FixedassetRepair__c = '固定資産工事';
        insert repairItemMaster3;
        

        // 工事マスタ  RepairItemMaster
        RepairItemMaster__c repairItemMaster4 = new RepairItemMaster__c();
        // Name
        repairItemMaster4.name = '給湯器（ガス）';
        // 分類① Type__c
        repairItemMaster4.Type__c = '給水設備';
        // 分類② Type2__c
        repairItemMaster4.Type2__c = '給水管';
        // 計画 Planned__c
        repairItemMaster4.Planned__c = true;
        // 計画外 Unplanned__c
        repairItemMaster4.Unplanned__c = true;
        // 周期年 repairCycle__c
        repairItemMaster4.repairCycle__c = 20; 
        // 固定資産/修繕 FixedassetRepair__c
        repairItemMaster4.FixedassetRepair__c = '固定資産工事';
        insert repairItemMaster4;
        
        // 物件別工事 CustomOpportunity__c
        CustomOpportunity__c customOpportunityPlan = new CustomOpportunity__c();    
        // 物件別予実名 Name
        customOpportunityPlan.Name = 'test';
        // 物件名 propertyName__c
        customOpportunityPlan.propertyName__c = propertyObj.id;  
        // 分類（計画外工事選択用） ClassificationOutConstruction__c　　給水設備
        customOpportunityPlan.ClassificationOutConstruction__c = '給水設備'; 
        // 計画外工事 RepairItem__c
        customOpportunityPlan.RepairItem__c = repairItemMaster3.id; 
        // レコードタイプ RecordTypeId
        customOpportunityPlan.RecordTypeId = recType2.id; 
        // 予定年 PredYear__c
        customOpportunityPlan.PredYear__c = '2020'; 
        // 工事予算（税抜） PredictionExpense__c
        customOpportunityPlan.PredictionExpense__c = 300; 
        // 開始日 StartDay__c
       // customOpportunityPlan.StartDay__c =  Date.newInstance(2018,7,16);; 
        // ステータス StageName__c.発注前
       // customOpportunityPlan.StageName__c = '発注前'; 
        // 工事実績（税抜） RepairCostActual__c
        customOpportunityPlan.RepairCostActual__c = 300;
        insert customOpportunityPlan;
        
        // 物件別工事 CustomOpportunity__c
        CustomOpportunity__c customOpportunityPlan1 = new CustomOpportunity__c();    
        // 物件別予実名 Name
        customOpportunityPlan1.Name = 'test';
        // 物件名 propertyName__c
        customOpportunityPlan1.propertyName__c = propertyObj.id;  
        // 分類（計画外工事選択用） ClassificationOutConstruction__c　　給水設備
        customOpportunityPlan1.ClassificationOutConstruction__c = '給水設備'; 
        // 計画外工事 RepairItem__c
        customOpportunityPlan1.RepairItem__c = repairItemMaster4.id; 
        // レコードタイプ RecordTypeId
        customOpportunityPlan1.RecordTypeId = recType2.id; 
        // 予定年 PredYear__c
        customOpportunityPlan1.PredYear__c = '2020'; 
        // 工事予算（税抜） PredictionExpense__c
        customOpportunityPlan1.PredictionExpense__c = 300; 
        // 開始日 StartDay__c
       // customOpportunityPlan.StartDay__c =  Date.newInstance(2018,7,16);; 
        // ステータス StageName__c.発注前
       // customOpportunityPlan.StageName__c = '発注前'; 
        // 工事実績（税抜） RepairCostActual__c
        customOpportunityPlan1.RepairCostActual__c = 300;
        insert customOpportunityPlan1;
        
       ApexPages.currentPage().getParameters().put('id',propertyObj.Id);        
       ApexPages.currentPage().getParameters().put('name',propertyObj.Name);        
       ApexPages.currentPage().getParameters().put('completionYear',string.valueOf(propertyObj.completionDay__c));
       new RepairCyclePDFController();
    }

}
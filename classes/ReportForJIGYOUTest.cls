@isTest
public class ReportForJIGYOUTest {
    static testMethod void reportForJIGYOUTest() {
        createData();
        Test.startTest();
        Map<Id, SObject> oldMap=new Map<Id, SObject> ();

        ApexPages.currentPage().getParameters().put('Jigyou', '施設営業部');
        ApexPages.currentPage().getParameters().put('Sdate','2018-01-01');
        ApexPages.currentPage().getParameters().put('Edate','2018-06-01');
        ReportForJIGYOU re= new ReportForJIGYOU();
        
        Test.stopTest();
    }
    public static void createData() {       
        
        
        //取引先
        Account account = new Account(Name = 'testaccount');
        insert account;
        //売上マスタ
        CustomObject2__c cusobj=new CustomObject2__c();
        cusobj.Type__c='分類１';
        insert cusobj;
        
        RepairItemMaster__c re=new RepairItemMaster__c();
        //計画外工事名
        re.Name='計画外工事名';
        re.Type__c='分類１';
        insert re;
        
        PropertyObj__c pj=new PropertyObj__c();
        pj.Name='工事名１';
        pj.PropertyDivision__c='工場';
        pj.ManagingDepartment__c='施設営業部';
        pj.completionDay__c=Date.valueOf('2016-01-01');
        insert pj;
        
        CustomOpportunity__c cus= new CustomOpportunity__c();
        cus.propertyName__c=pj.id;
        cus.RepairCostActual__c=1000;
        cus.PredYear__c='2018';
        cus.RepairItem__c=re.id;
        cus.Class_PG__c='大分類';
        //cus.NewYojituFeeFlg__c=true;
        cus.ConstructionPG__c='1123';
        cus.StageName__c = '20.検収済';
        cus.AcceptanceDate__c=Date.valueOf('2018-02-01');
        cus.OrderDate__c=Date.valueOf('2018-02-01');
        cus.RequestAcceptanceDate__c=Date.valueOf('2018-02-01');
        cus.StartDay__c=Date.valueOf('2018-02-01');
        cus.CloseDate__c=Date.valueOf('2018-02-01');
        cus.ConstructionSite__c='test';
        cus.RequestSuppliers__c = account.Id;
        cus.ManagementRealNoTax__c = 10000;
        cus.RemoveRealNoTax__c = 10000;
        cus.ProceedRealNoTax__c = 10000;
        cus.FixedassetRepair__c = '固定資産工事';
        insert cus;
        
        CustomOpportunity__c cu=[select RecordType.Name from CustomOpportunity__c];
        system.debug(cu);
    }
}
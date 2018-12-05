@isTest
public class YojituControllerTest {
	
	static testMethod void test_YojituController() {
		Test.startTest();
		//物件管理
		PropertyObj__c prop=new PropertyObj__c();
		insert prop;
		//工事マスタ
		RepairItemMaster__c ritm=new RepairItemMaster__c();
		ritm.Type__c='大分類１';
		ritm.Name='小分類１';
		insert ritm;
		//工事マスタ
		RepairItemMaster__c ritm2=new RepairItemMaster__c();
		ritm2.Type__c='大分類１';
		ritm2.Name='小分類2';
		insert ritm2;

		
	    List<RecordType> RecordTypeId= [select id,Name from RecordType where SobjectType ='CustomOpportunity__c' and Name='計画外工事'];
	    system.debug(RecordTypeId);
	    
	    CustomOpportunity__c coppo4=new CustomOpportunity__c();
		//開始日
		coppo4.StartDay__c=Date.newInstance(2018,1,1);
		//coppo.PredYearMonth__c=Date.newInstance(2018,1,1);
		coppo4.PredictionExpense__c=1000;
		coppo4.propertyName__c=prop.id;
		coppo4.AcceptanceDate__c=Date.newInstance(2018,1,1);
		coppo4.RecordTypeId=RecordTypeId[0].id;
		coppo4.RepairItem__c=ritm2.id;
		insert coppo4;
		system.debug(coppo4);
		
		
	    CustomOpportunity__c coppo3=new CustomOpportunity__c();
		//開始日
		coppo3.StartDay__c=Date.newInstance(2018,1,1);
		//coppo.PredYearMonth__c=Date.newInstance(2018,1,1);
		coppo3.PredictionExpense__c=1000;
		coppo3.propertyName__c=prop.id;
		coppo3.RecordTypeId=RecordTypeId[0].id;
		coppo3.RepairItem__c=ritm2.id;
		insert coppo3;
		system.debug(coppo3);

	    
	    CustomOpportunity__c coppo2=new CustomOpportunity__c();
		//開始日
		coppo2.StartDay__c=Date.newInstance(2018,1,1);
		coppo2.PredYear__c='2018';
		coppo2.PredMonth__c='01';
		//coppo.PredYearMonth__c=Date.newInstance(2018,1,1);
		coppo2.PredictionExpense__c=1000;
		coppo2.RepairCostActual__c=1000;
		coppo2.propertyName__c=prop.id;
		coppo2.RecordTypeId=RecordTypeId[0].id;
		coppo2.RepairItem__c=ritm.id;
		insert coppo2;
		system.debug(coppo2);
	    
		CustomOpportunity__c coppo=new CustomOpportunity__c();
		//開始日
		coppo.StartDay__c=Date.newInstance(2018,1,1);
		//coppo.PredYearMonth__c=Date.newInstance(2018,1,1);
		coppo.PredictionExpense__c=1000;
		coppo.RepairCostActual__c=1000;
		coppo.propertyName__c=prop.id;
		coppo.RecordTypeId=RecordTypeId[0].id;
		coppo.RepairItem__c=ritm.id;
		insert coppo;
		system.debug(coppo);
		
		//検索条件を用意する
		YojituController yllo=new YojituController();
		Date Sdate=Date.newInstance(2018,1,1);
		Date Edate=Date.newInstance(2018,12,1);
		Date Edate2=Date.newInstance(2017,12,1);
		String PropatyDisplay= '';
		yllo.forTest(Sdate,Edate,PropatyDisplay);
		YojituController.getKinds();
		yllo.forTest(Sdate,Edate2,PropatyDisplay);
		Test.stopTest();
	}
}
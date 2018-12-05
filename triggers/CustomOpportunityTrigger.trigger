trigger CustomOpportunityTrigger on CustomOpportunity__c (before insert, before update) { 
    for(Integer i=0;i<Trigger.new.size();i++){
        // レコードタイプ＝計画（新規）RecordType2 repairFee RecordType3 外：RecordType1　　Unplan_Repair　RecordType
        // PG用の各種マスタID
        Trigger.new[i].ConstructionPG__c = Trigger.new[i].RepairItemPG__c;
        // 分類①　Class_PG__c
        Trigger.new[i].Class_PG__c = Trigger.new[i].Class__c;
         //計画外売上かつ元のデータがない場合
         if(Trigger.new[i].recordtypekubun__c=='RecordType1'){
	         // 売上勘定科目コード
	         if(Trigger.new[i].SalesAccountCode__c==null){
	            Trigger.new[i].SalesAccountCode__c = Trigger.new[i].SalesAccountCode_PG__c;
	         }
	         // 売上勘定科目名称
	         if(Trigger.new[i].SalesAccountName__c==null){
	            Trigger.new[i].SalesAccountName__c = Trigger.new[i].SalesAccountName_PG__c;
	         }
         }
         //計画外管理かつ元のデータがない場合
         if(Trigger.new[i].recordtypekubun__c=='RecordType'){
	         // 管理勘定科目コード
	         if(Trigger.new[i].ManagementAccountCode__c==null){
	            Trigger.new[i].ManagementAccountCode__c = Trigger.new[i].ManagementAccountCode_PG__c;
	         }
	         // 管理勘定科目名称
	         if(Trigger.new[i].ManagementAccountName__c==null){
	            Trigger.new[i].ManagementAccountName__c = Trigger.new[i].ManagementAccountName_PG__c;
	         }
         }
         //計画外工事かつ元のデータがない場合
         if(Trigger.new[i].recordtypekubun__c=='Unplan_Repair'){
	         // 工事勘定科目コード
	         if(Trigger.new[i].ConstructionAccountCode__c==null){
	            Trigger.new[i].ConstructionAccountCode__c = Trigger.new[i].ConstructionAccountCode_PG__c;
	         }
	         //工事勘定科目名称
	         if(Trigger.new[i].ConstructionAccountName__c==null){
	            Trigger.new[i].ConstructionAccountName__c = Trigger.new[i].ConstructionAccountName_PG__c;
	         }
         	  //撤去勘定科目コード
	         if(Trigger.new[i].RemovedAccountCode__c==null){
	            Trigger.new[i].RemovedAccountCode__c = Trigger.new[i].RemovedAccountCode_PG__c;
	         }
	         //撤去勘定科目名称
	         if(Trigger.new[i].RemovedAccountName__c==null){
	            Trigger.new[i].RemovedAccountName__c = Trigger.new[i].RemovedAccountName_PG__c;
	         }
         
         }
         //工事メモ
         if(Trigger.new[i].ConstructionDetails__c==null){
	            Trigger.new[i].ConstructionDetails__c = Trigger.new[i].ConstructionDetails_PG__c;
	     }
         //物件の社内管理部署
         if(Trigger.new[i].ManagingDepartment__c==null){
	            Trigger.new[i].ManagingDepartment__c = Trigger.new[i].ManagingDepartment_PG__c;
	     }
         //固定資産/修繕
         if(Trigger.new[i].FixedassetRepair__c==null){
	            Trigger.new[i].FixedassetRepair__c = Trigger.new[i].FixedassetRepair_PG__c;
	     }
    }

}
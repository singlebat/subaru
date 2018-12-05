public class RepairCyclePDFController {
	//システム時間
    public String printTime {set;get;}  
    //ホームの明細
    public static List<SubRepeatInfo> repeatList {get;set;}
    //物件名
    public static String propertyName {set;get;}  
    // 竣工年月日(画面用)
    public static Integer completionYear {set;get;}
    // 経年(画面用)
    public static List<Integer> completionYearList {set;get;}
    public class ReapeatCustomOpportunityDetails{
        public List<String> koujiList {get;set;}
        // 分類①
        public String class1 {get;set;}
    }

    public class SubRepeatInfo{
        public List<ReapeatCustomOpportunityDetails> subRepeatList {get;set;}
    }

    public class CustomOpportunityInfo{
        // 実績／予算
        public Decimal YojituFee {get;set;}
        // スタータス
        public String StageName {get;set;}
        // 検収日
        public Date AcceptanceDate {get;set;}
    }

    public RepairCyclePDFController(){
        // 呼びだすシステム時間
        DateTime myDateTime1 = system.now();
        system.debug(myDateTime1.format('MM/dd/yyyy hh:mm:ss.SSSSSS'));
        printTime=String.valueOf(DateTime.now());
        // 前PAGEからもらったパラメータ
        String cid = ApexPages.currentPage().getParameters().get('id');
        propertyName = '(' + ApexPages.currentPage().getParameters().get('name') + ')';
        Date completionDay = DATE.valueOf(ApexPages.currentPage().getParameters().get('completionYear'));        
        completionYear = Integer.valueOf(string.valueOf(completionDay.year()));
        
        // 画面経年の実装
        completionYearList = new List<Integer>();
        for(Integer i=1; i<= 60; i++){
            completionYearList.add(i);
        }
        
        //計画工事と計画外工事の検索結果をゲットする
         List<AggregateResult> customOpportunityList = new List<AggregateResult>();
        customOpportunityList = GetTotalAmount(cid,completionDay);       
        system.debug('customOpportunityList:  ' + customOpportunityList);
        
        Map<String, List<List<String>>> customOpportunityMap = new Map<String, List<List<String>>>(); 
        // 計画工事と計画外工事の画面マピングする
        if (customOpportunityList.size() > 0){
            getYearMonthAmount(customOpportunityMap,customOpportunityList);      
            system.debug('customOpportunityMap:  ' + customOpportunityMap);
        }
        
        // PAGEのマピング
        pageMapping(customOpportunityMap);     
       
    }   
    /**
     * param   key  対象（画面項目）
     * param   completionDay   竣工年月日（画面項目）
     * 戻り値   物件別工事（予算と実績）の合計の値 
     */ 
    public  List<AggregateResult> GetTotalAmount(String key, Date completionDay) { 

        String sql='';
        sql+='SELECT  max(id) changeID,';
        sql+=' max(repairCycleFormulaPG__c) repairCycle,';//周期年
        sql+=' ConstructionPG__c RepairItem,';//工事マスタ 
        sql+=' max(StageName__c) StageName,';//スタータス  
        sql+=' max(AcceptanceDate__c) AcceptanceDate,';//検収日 
        sql+=' sum(NewYojituFee__c) YojituFee,';//実績／予算   
        sql+=' max(ConstructionName__c) ConstructionName,';//工事マスタ名 
        sql+=' max(RecordType.DeveloperName) DeveloperName,';//レコードタイプ  
        sql+=' RecordTypeId RecordTypeId,';//レコードタイプ   
        sql+=' max(Class__c) Class1,';//分類①
        sql+=' max(Class2__c) Class2,';//分類②
        sql+=' PredYear__c PredYear,';//予定年月  
        sql+=' max(propertyName__r.completionDay__c) completionDay,';//竣工年月日(画面用),      
        sql+=' sum(PredictionExpense__c) PredictionExpense,';//工事予算（税抜）
        sql+=' sum(RepairCostActual__c) RepairCostActual';//工事実績（税抜）
        sql+=' FROM CustomOpportunity__c';//物件別工事（予算と実績）
        sql+=' WHERE Class__c!=null';
        if(key!=null){
            sql+=' AND propertyName__c=\''+key+'\'';  
        }        
        // 竣工年月日(completionDay__c) 物件管理のcompletionDay__cの年から、60年分西暦で表示させる PredYear__c(text) <=竣工年+60
        Date newDate = completionDay.addYears(60);
        String strCompletionDay = String.valueOf(completionDay.year());
        String strCompletionDay60 = String.valueOf(newDate.year());
        //Datetime sdt = Datetime.newInstance(newDate.year(), newDate.month(), newDate.day());
        sql+=' AND(';
        sql+='  PredYear__c >=\''+strCompletionDay+'\''; // 竣工年月日
        sql+='  AND PredYear__c <=\''+strCompletionDay60+'\''; // 竣工年月日
        sql+=' )';
        
        // 画面項目「対象」より、レコードタイプのIDを取得 
        // 計画工事の場合
        list<ID> recordTypeId = GetIdOfRecordType();
        system.debug('recordTypeId:' +recordTypeId);
        if(recordTypeId.size() >0){
            sql+=' AND RecordTypeId  IN : recordTypeId';
        }                       
        sql+=' GROUP BY  Class_PG__c,ConstructionPG__c,RecordTypeId, PredYear__c';                        
        sql+=' ORDER BY  Class_PG__c,ConstructionPG__c,RecordTypeId, PredYear__c';
        system.debug(sql);   
        return Database.query(sql);                         
    }
    
    private  List<ID> GetIdOfRecordType() {
        list<String> developerNames = new list<String>(); 
        // 対象（画面項目）より、レコードタイプのDeveloperNameを取得
         String sql='';
        sql+='SELECT id,';
        sql+=' DeveloperName';  
        sql+=' FROM RecordType';//レコードタイプ
        sql+=' WHERE SobjectType = \'CustomOpportunity__c\''; // カスタムオブジェクト \'計画\'
        // repairFee　　計画工事、 Unplan_Repair　　計画外工事
        sql+=' AND DeveloperName  IN (\'repairFee\',\'Unplan_Repair\')';
        system.debug('sql: '+sql);
        // レコードタイプ(計画外工事,計画工事)のIDを取得
        list<RecordType> recordTypes =  Database.query(sql);
        
        list<ID> recordTypeId = new list<ID>();
        if (recordTypes.size() > 0){
            for(RecordType rt: recordTypes ){
                recordTypeId.add(rt.id);                
            }            
        } 
        return recordTypeId;
        // 張　20181003 end   
    }
    
    /**
     * param   repeatList  年単位で取得結果
     * 戻り値   レコードタイプのID 
     */ 
    private void getYearMonthAmount(Map<String, List<List<String>>> classAndKojiAmountMap, List<AggregateResult> customOpportunityList){
        //前回の分類１を保存する
        String preClass='';
        //RecordTypeIdを保存する
        String  preRecordTypeId='';
        //工事IDを保存する
        String  preRepairItemId='';
        //工事名を保存する
        String  preRepairItemName='';
        String  preYymm='',preRepairCycle='', strClass = '';
        Integer cnt=1,PreAmount=0,cOPlanListSize = customOpportunityList.size(); 
        Boolean preKojiListFlg = False,preYojituFeeFlg;
        Decimal temYojituFee = 0;
        Map<String,CustomOpportunityInfo> KojiYYMMMap = new Map<String,CustomOpportunityInfo>();
        list<String> subDetailList = new list<String>();
        list<list<String>> subKojiList =  new list<list<String>>();
        list<list<String>> existingClassList =  new list<list<String>>();
        CustomOpportunityInfo customOpportunity = null;
        for(AggregateResult result: customOpportunityList){
            customOpportunity =  new CustomOpportunityInfo();
            //分類①が一致しないと、新規分類①と工事リスト 
            if(preClass != String.valueOf(result.get('Class1'))){
                if (KojiYYMMMap.size() > 0 ){
                    // 最初の工事（一つデータがある）又は　同じ工事リストの最後工事データ
                    if (preKojiListFlg== false){
                        // 呼びだす、一つ行の工事金額を出力  
                        subDetailList =  getsubKojiList(preRepairItemName,preRepairCycle,KojiYYMMMap);
                        subKojiList.add(subDetailList); 
                    }
                    if (classAndKojiAmountMap.containsKey(preClass)){
                        existingClassList =  new list<list<String>>();
                        existingClassList.addAll(classAndKojiAmountMap.get(preClass));
                        existingClassList.addAll(subKojiList);
                        // GROUP BYの条件変更に伴い、下記のソースを通らない
                         system.debug('classAndKojiAmountMapーー1.1－－' + cnt );
                         system.debug('classAndKojiAmountMapーー1.1 classAndKojiAmountMap.get(preClass)－－' + classAndKojiAmountMap.get(preClass) );
                         system.debug('classAndKojiAmountMapーー1.1 existingClassList－－' + existingClassList );
                        classAndKojiAmountMap.put(preClass,existingClassList);
                    }else{
                         system.debug('classAndKojiAmountMapーー1.2－－' + cnt );
                         system.debug('classAndKojiAmountMapーー1.2 subKojiList－－' + subKojiList );
                        classAndKojiAmountMap.put(preClass,subKojiList);                        
                    }
                    subKojiList = new list<list<String>>();
                }
                
                // 初期化
                KojiYYMMMap = new Map<String,CustomOpportunityInfo>();                
                //実績又は予算  　20181106　追加
                temYojituFee = decimal.valueOf(String.valueOf(result.get('YojituFee')))/1000;
                customOpportunity.YojituFee = temYojituFee.round(System.RoundingMode.DOWN);
                // スタータス
                customOpportunity.StageName = String.valueOf(result.get('StageName'));
                // 検収日
                customOpportunity.AcceptanceDate = Date.valueOf(result.get('AcceptanceDate'));
                KojiYYMMMap.put(String.valueOf(result.get('PredYear')),customOpportunity);
                // 最後の工事（一つデータがある）
                if (cnt == cOPlanListSize) {
                    // 呼びだす、一つ行の工事金額を出力                      
                    system.debug('(preClass !=  subDetailList  最後の工事（一つデータがある）' );            
                    //分類①    
                    preClass = String.valueOf(result.get('Class1'));
                    // 工事名(PG)
                    preRepairItemName = String.valueOf(result.get('ConstructionName'));
                    // 周期年(PG) 
                    preRepairCycle = String.valueOf(result.get('repairCycle'));
                    subDetailList =  getsubKojiList(preRepairItemName,preRepairCycle,KojiYYMMMap); 
                    subKojiList.add(subDetailList);
                    if (classAndKojiAmountMap.containsKey(preClass)){
                        existingClassList =  new list<list<String>>();
                        existingClassList.addAll(classAndKojiAmountMap.get(preClass));
                        existingClassList.addAll(subKojiList);
                        // GROUP BYの条件変更に伴い、下記のソースを通らない
                         system.debug('classAndKojiAmountMapーー2.1－－' + cnt );
                         system.debug('classAndKojiAmountMapーー2.1 classAndKojiAmountMap.get(preClass)－－' + classAndKojiAmountMap.get(preClass) );
                         system.debug('classAndKojiAmountMapーー2.1 existingClassList－－' + existingClassList );
                        classAndKojiAmountMap.put(preClass,existingClassList);
                    }else{
                         system.debug('classAndKojiAmountMapーー2.2－－' + cnt );
                         system.debug('classAndKojiAmountMapーー2.2 subKojiList－－' + subKojiList );
                        classAndKojiAmountMap.put(preClass,subKojiList);                        
                    }
                     subKojiList = new list<list<String>>();
                } 
            } else {
                // 分類①が同じ場合、工事リストを追加
                // 工事ID== 前回の工事ID、金額合計 (※レコードタイの関わらず、同じ工事IDがあれば、一つ工事をとして、処理する)&& preYojituFeeFlg == Boolean.valueOf(result.get('YojituFeeFlg'))
                //if(preRepairItemId ==  String.valueOf(result.get('RepairItem')) && preRecordTypeId ==  String.valueOf(result.get('DeveloperName'))){ 
                if(preRepairItemId ==  String.valueOf(result.get('RepairItem')) && preRecordTypeId ==  String.valueOf(result.get('DeveloperName'))){
                    // 予定年 != 前回の予定年
                    if(preYymm != String.valueOf(result.get('PredYear'))){
                
                        //実績又は予算  　20181106　追加
                        temYojituFee = decimal.valueOf(String.valueOf(result.get('YojituFee')))/1000;
                        customOpportunity.YojituFee = temYojituFee.round(System.RoundingMode.DOWN);
                        // スタータス
                        customOpportunity.StageName = String.valueOf(result.get('StageName'));
                        // 検収日
                        customOpportunity.AcceptanceDate = Date.valueOf(result.get('AcceptanceDate'));
                        KojiYYMMMap.put(String.valueOf(result.get('PredYear')),customOpportunity);
                    }
                    // 最後の工事（複数データがある）
                    if (cnt == cOPlanListSize) {
                        // 呼びだす、一つ行の工事金額を出力  
                        subDetailList =  getsubKojiList(preRepairItemName,preRepairCycle,KojiYYMMMap);
                        subKojiList.add(subDetailList);
                        if (classAndKojiAmountMap.containsKey(preClass)){
                            existingClassList =  new list<list<String>>();
                            existingClassList.addAll(classAndKojiAmountMap.get(preClass));
                            existingClassList.addAll(subKojiList);
                            system.debug('classAndKojiAmountMapーー3.1－－' + cnt );
                            system.debug('classAndKojiAmountMapーー3.1 classAndKojiAmountMap.get(preClass)－－' + classAndKojiAmountMap.get(preClass) );
                            system.debug('classAndKojiAmountMapーー3.1 existingClassList－－' + existingClassList );
                            classAndKojiAmountMap.put(preClass,existingClassList);
                        }else{
                            system.debug('classAndKojiAmountMapーー3.2－－' + cnt );
                            system.debug('classAndKojiAmountMapーー3.2－－subKojiList' + subKojiList );
                            classAndKojiAmountMap.put(preClass,subKojiList);                     
                        }
                        
                         subKojiList = new list<list<String>>();
                    }  
                } else {
                // 工事ID＜＞ 前回の工事ID、金額合計   
                    // 前回の工事リストを一つ行目のリストに変更する
                    preKojiListFlg = true;
                    if (KojiYYMMMap.size() > 0){           
                        subDetailList =  getsubKojiList(preRepairItemName,preRepairCycle,KojiYYMMMap);
                        subKojiList.add(subDetailList);
                        if (classAndKojiAmountMap.containsKey(preClass)){
                            existingClassList =  new list<list<String>>();
                            existingClassList.addAll(classAndKojiAmountMap.get(preClass));
                            existingClassList.addAll(subKojiList);
                            system.debug('classAndKojiAmountMapーー4.1－－' + cnt );
                            system.debug('classAndKojiAmountMapーー4.1 classAndKojiAmountMap.get(preClass)－－' + classAndKojiAmountMap.get(preClass) );
                            system.debug('classAndKojiAmountMapーー4.1 existingClassList－－' + existingClassList );
                            classAndKojiAmountMap.put(preClass,existingClassList);
                        }else{
                            system.debug('classAndKojiAmountMapーー4.2－－' + cnt );
                            system.debug('classAndKojiAmountMapーー4.2－－subKojiList' + subKojiList );
                            classAndKojiAmountMap.put(preClass,subKojiList);                     
                        }
                        subKojiList = new list<list<String>>();                     
                        preKojiListFlg = false;
                    }
                    
                    // 同じ分類の場合、工事が一致しないと、新規作成 
                    KojiYYMMMap = new Map<String,CustomOpportunityInfo>();                
                    //実績又は予算  　20181106　追加  
                    temYojituFee = decimal.valueOf(String.valueOf(result.get('YojituFee')))/1000;
                    customOpportunity.YojituFee = temYojituFee.round(System.RoundingMode.DOWN);
                    // スタータス
                    customOpportunity.StageName = String.valueOf(result.get('StageName'));
                    // 検収日
                    customOpportunity.AcceptanceDate = Date.valueOf(result.get('AcceptanceDate'));
                    KojiYYMMMap.put(String.valueOf(result.get('PredYear')),customOpportunity); 
                    // 最後の工事（複数データがある）
                    if (cnt == cOPlanListSize) {
                        // 呼びだす、一つ行の工事金額を出力               
                        system.debug('subDetailList--- 2' );            
                        //分類①    
                        preClass = String.valueOf(result.get('Class1'));
                        // 工事名(PG)
                        preRepairItemName = String.valueOf(result.get('ConstructionName'));
                        // 周期年(PG) 
                        preRepairCycle = String.valueOf(result.get('repairCycle'));
                        subDetailList =  getsubKojiList(preRepairItemName,preRepairCycle,KojiYYMMMap);
                        system.debug('subDetailList' + subDetailList);
                        subKojiList.add(subDetailList);
                        if (classAndKojiAmountMap.containsKey(preClass)){
                            existingClassList =  new list<list<String>>();
                            existingClassList.addAll(classAndKojiAmountMap.get(preClass));
                            existingClassList.addAll(subKojiList);    
                            system.debug('classAndKojiAmountMapーー5.１－－' + cnt );
                            system.debug('classAndKojiAmountMapーー5.１classAndKojiAmountMap.get(preClass)－－' + classAndKojiAmountMap.get(preClass));
                            system.debug('classAndKojiAmountMapーー5.１existingClassList－－' + existingClassList );
                            classAndKojiAmountMap.put(preClass,existingClassList);
                        }else{
                            // GROUP BYの条件変更に伴い、下記のソースを通らない
                            system.debug('classAndKojiAmountMapーー5.2－－' + cnt );
                            system.debug('classAndKojiAmountMapーー5.2--subKojiList－－' + subKojiList );
                            classAndKojiAmountMap.put(preClass,subKojiList);                        
                        }
                        subKojiList = new list<list<String>>();
                    }                 
                }
            }
            
            //分類①    
            preClass = String.valueOf(result.get('Class1'));
            //工事マスタID    
            preRepairItemId =  String.valueOf(result.get('RepairItem'));
            //レコードタイプ名   
            preRecordTypeId = String.valueOf(result.get('DeveloperName'));
            // 工事名(PG)
            preRepairItemName = String.valueOf(result.get('ConstructionName'));
            // 周期年(PG) 
            preRepairCycle = String.valueOf(result.get('repairCycle'));
            // 予定年
            preYymm = String.valueOf(result.get('PredYear'));
            // 実績又は予算合計フラグ
            //preYojituFeeFlg = Boolean.valueOf(result.get('YojituFeeFlg'));
            cnt++;            
        }       
    }
    
    /**
     * param   subDetailList  一つ工事情報
     * 戻り値   レコードタイプのID 
     */ 
    private list<String> getsubKojiList(String preRepairItemName, String preRepairCycle, Map<String,CustomOpportunityInfo> KojiYYMMMap) {
        system.debug('getsubKojiList 開始: preRepairItemName  preRepairCycle '+ preRepairItemName + 'preRepairCycle:  '+preRepairCycle );
        list<String> subDetailList = new list<String>();
        //style1 工事名
        String preRepairItemNameFontSize=fontSizeAutoSet(preRepairItemName,50, '', 60);
        //preRepairItemNameFontSize='';
        String strKojiTD = '';
        system.debug(preRepairItemName+':'+preRepairItemNameFontSize);
        strKojiTD = '<tr><td style="width:11%;height:80px;border-top: black solid 2px;border-left: black solid 2px;border-right: black solid 2px;border-bottom: black solid 2px;font-size: 60px;'+preRepairItemNameFontSize+'" >&nbsp;&nbsp;&nbsp;&nbsp;' + preRepairItemName + '</td>';
        subDetailList.add(strKojiTD);
        // 周期
        if (String.isBlank(preRepairCycle)) {
            strKojiTD = '<td style="width: 1%;text-align:center;border-top: black solid 2px;border-left: black solid 2px;border-right: black solid 2px;border-bottom: black solid 2px;font-size: 50px;">' + '</td>';
            subDetailList.add(strKojiTD);
        } else {
            strKojiTD = '<td style="width: 1%;text-align:center;border-top: black solid 2px;border-left: black solid 2px;border-right: black solid 2px;border-bottom: black solid 2px;font-size: 70px;">' + preRepairCycle + '</td>';
            subDetailList.add(strKojiTD);
        }
        //subDetailList.add('<td style="width: 1%;text-align:center;border-top: black solid 2px;border-left: black solid 2px;border-right: black solid 2px;border-bottom: black solid 2px;font-size: 50px;"></td>');
        Integer cnt = completionYear+1;
        decimal total = 0;
        String comoni= '';
        try{
            for(Integer i= cnt; i <= cnt + 59; i++){
                String strKey = string.valueOf(i);
                if (KojiYYMMMap.containsKey(strKey)) {  
                    CustomOpportunityInfo customOpportunity = KojiYYMMMap.get(strKey);            
                    if(customOpportunity !=null){
                        if (customOpportunity.StageName == '20.検収済' && customOpportunity.AcceptanceDate != null ){
                            //工事実績（税抜）
                            comoni=String.valueOf((customOpportunity.YojituFee).format());
                            String comoniSize=fontSizeAutoSet(comoni,6, '', 70);
                            strKojiTD = '<td style="width: 1%;text-align:right;border-top: black solid 2px;border-left: black solid 2px;border-right: black solid 2px;border-bottom: black solid 2px;'+comoniSize+'"><span style="">'+comoni+'</span></td>';
                            subDetailList.add(strKojiTD);
                            total += customOpportunity.YojituFee;                            
                        } else {
                            //工事予算（税抜）
                            if (customOpportunity.YojituFee != 0){                                
                                total += customOpportunity.YojituFee;
                                comoni=String.valueOf((customOpportunity.YojituFee).format());
                                String comoniSize=fontSizeAutoSet(comoni,6, '', 70);
                                strKojiTD = '<td style="width: 1%;text-align:right;border-top: black solid 2px;border-left: black solid 2px;border-right: black solid 2px;border-bottom: black solid 2px;'+comoniSize+'"><span style="color:red;">'+comoni+'</span></td>';
                            } else {
                                strKojiTD = '<td style="width: 1%;text-align:right;border-top: black solid 2px;border-left: black solid 2px;border-right: black solid 2px;border-bottom: black solid 2px;font-size: 70px;"></td>';
                            }
                            subDetailList.add(strKojiTD);
                        } 
                    } 
                    
                } else {    
                    //予定年がないと、空TDを出力
                    strKojiTD = '<td style="width: 1%;text-align:right;border-top: black solid 2px;border-left: black solid 2px;border-right: black solid 2px;border-bottom: black solid 2px;font-size: 70px;"></td>';
                    subDetailList.add(strKojiTD);
                }
                system.debug('strKojiTD:  ' + strKojiTD);
            }
            //合計の列
            comoni=String.valueOf(total.format());
            String comoniSize=fontSizeAutoSet(comoni,6, '', 70);
            strKojiTD = '<td style="width: 2%;text-align:right;border-top: black solid 2px;border-left: black solid 2px;border-right: black solid 2px;border-bottom: black solid 2px;'+comoniSize+'"><span style="">'+comoni+'</span></td></tr>';
            subDetailList.add(strKojiTD);
            
        }catch (Exception e){
            system.debug('getMessage: ' + e.getMessage());
            system.debug('getStackTraceString: ' + e.getStackTraceString());           
        }
        system.debug('getsubKojiList 修了:  ' );
        return subDetailList; 
    }


    
    /**
     * param   customOpportunityPlanMap  年単位で取得結果
     */ 
    private void pageMapping(Map<String, List<List<String>>> customOpportunityMap){
        //style2　分類
        String style2='<td style="background-color:#ccffcc;border-right: solid 0.78px #cccccc;">';
        Integer cnt = 1;
        List<ReapeatCustomOpportunityDetails> subDetailList = new List<ReapeatCustomOpportunityDetails>();
        ReapeatCustomOpportunityDetails details = new ReapeatCustomOpportunityDetails();
        for(String sKey: customOpportunityMap.keySet()){
            details = new ReapeatCustomOpportunityDetails();
            // 分類①をTDに追加する
            details.class1 = cnt+'.'+ sKey ;
            subDetailList.add(details);
            List<List<String>> koujiListP = customOpportunityMap.get(sKey);
            // 工事行リストのループ
            for(Integer j = 0;j < koujiListP.size();j++){
                details = new ReapeatCustomOpportunityDetails();                
                // 人る工事リスト金額をー行として追加する
                details.koujiList = koujiListP.get(j);
                subDetailList.add(details);
            }
            cnt++;
        }
        
        //ページ数の計算
        Integer pageCount = 1;
        Integer page1Rows = 90;
        Integer RowCount = subDetailList.size()-page1Rows;
        Integer page2Rows = 90;
        if(RowCount > 0){
            if(Math.mod(subDetailList.size()-page1Rows,page2Rows)>0){
                pageCount= 1+Integer.valueOf((subDetailList.size()-page1Rows)/page2Rows)+1;
            }else{
                pageCount= 1+Integer.valueOf((subDetailList.size()-page1Rows)/page2Rows);
            }
        }
        System.debug('pageCount: '+pageCount); 
        
        repeatList = new  List<SubRepeatInfo>();
        SubRepeatInfo subRepeatInfo = null;
        for(Integer i=0;i<pageCount;i++){                          
            List<ReapeatCustomOpportunityDetails> pageDetailList = new List<ReapeatCustomOpportunityDetails>();
            if(i==0){
                //第一ページ
                for(Integer j=0;j<page1Rows;j++){
                    if(j<subDetailList.size()){
                        pageDetailList.add(subDetailList.get(j));
                    }
                }
            }else{
                //二ページから末ページまで
                for(Integer j=page1Rows+page2Rows*(i-1);j<page1Rows+page2Rows*i ;j++){
                    if(j<subDetailList.size()){
                        pageDetailList.add(subDetailList.get(j));
                    }else{
                    	ReapeatCustomOpportunityDetails re=new ReapeatCustomOpportunityDetails();
                    	re.class1=null;
                    	re.koujiList=new List<String>();
                    	String row='<tr>';
                    	for(Integer g=0;g<63;g++){
                    		row=row+'<td style="height:100px;border-top: black solid 2px;border-left: black solid 2px;border-right: black solid 2px;border-bottom: black solid 2px;"></td>';
                    	}
                    	row=row+'</tr>';
                    	re.koujiList.add(row);
                    	pageDetailList.add(re);
                    }
                }
            }
            // 初期化
            subRepeatInfo = new subRepeatInfo();
            subRepeatInfo.subRepeatList = pageDetailList; 
            repeatList.add(subRepeatInfo); 
        }
    }


    /**
     * フォントサイズの自動設定
     * 
     * @param  motoStr       元文字
     * @param  maxByteLength 最大byte数
     * @param  defaultStyle  デフォルト
     * @param  fontSize      文字サイズ
     * @return               スタイル
     */
    public String fontSizeAutoSet(String motoStr, Decimal maxByteLength, String defaultStyle, Integer fontSize) {
        // byte数
        system.debug(motoStr);
        Decimal bytes = getBytes(motoStr);
        String retValue = defaultStyle;
        // 最大byte数超える場合
        if (bytes > maxByteLength) {
            Decimal rate = maxByteLength / bytes;
            system.debug(rate);
            retValue += 'font-size:' + (rate * fontSize) + 'px;';
            system.debug(retValue);
        }else{
            retValue += 'font-size:' + fontSize + 'px;';
        }
        return retValue;
    }

    /**
     * byte数を取得する
     * 
     * @param  motoStr 元文字
     * @return         byte数
     */
    public Decimal getBytes(String motoStr) {
        if (String.isEmpty(motoStr)) {
            return 0;
        }
        Integer length = motoStr.length();
        Decimal retBytes = 0;
        for (Integer i = 0; i < length; i++) {
            Decimal tempBytes = Blob.valueOf(motoStr.substring(i, (i+1))).size();
            if (tempBytes > 2) {
                tempBytes = 1.8;
            } else {
                tempBytes = 1.01;
            }
            retBytes += tempBytes;
        }
        return retBytes;
    }
    
}
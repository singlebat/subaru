public with sharing class YojituController extends PaginationForYojitu {
	//検索条件
	public static String taisyous {get;set;}
	public static String errorMsg {get;set;}
	public static String PropatyDisplay{get;set;}
	public static Date Sdate {get;set;}
	public static Date Edate {get;set;}
	
	public static List<CustomOpportunity__c> CustomOpportunityList {get;set;}
	public static List<leftTable> lefts {get;set;}
	public static List<List<leftTable>> Pages {get;set;}
	public static List<leftTable> TruePage {get;set;}
	public static String tableYear {get;set;}
	public static String tableMonth {get;set;}
	public static List<Integer> yearList {get;set;}
	public static List<Integer> monthList {get;set;}
	//初期化のキー
	public static String firstKey {get;set;}
	public  CustomOpportunity__c cusOpportunity{get;set;} 
	//何ページ目を示す
	public  Integer pageIndex{get;set;}
	//Selectの中身を入れる
	public static List<SelectOption> getKinds() {
	 	List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('all','全て'));
        options.add(new SelectOption('sells','売上'));
        options.add(new SelectOption('works','工事'));
        options.add(new SelectOption('manages','管理'));
	 	return options;
	}
	public  YojituController() {
		pageIndex=0;
		cusOpportunity=new CustomOpportunity__c();
	}
	//デフォルトコントロール
	public  YojituController(ApexPages.StandardController stdController) {
		pageIndex=0;
		cusOpportunity=(CustomOpportunity__c)stdController.getRecord();
		system.debug(cusOpportunity);
		CustomOpportunityList=null;
	}
	public  void forTest(Date Sdate,Date Edate,String PDisplay) {
		cusOpportunity.Sdate__c=Sdate;
		cusOpportunity.Edate__c=Edate;
		PropatyDisplay=PDisplay;
		doSearch();
	}
	public  pagereference doSearch() {
		system.debug('1');
		CustomOpportunityList=new List<CustomOpportunity__c>();
		//ここで検索
		CustomOpportunityList=doTrueSearch(CustomOpportunityList);
		
		system.debug(CustomOpportunityList);
		if(CustomOpportunityList==null||CustomOpportunityList.size()==0){
			//if(firstKey!='初期化'){
				errorMsg='該当するデータがありませんでした。';
				TruePage=null;
			//}
			return null;
		}
		//右側テーブルの予定年月をゲットする
		GetYearMonth();
		//費用明細を検索する
		GetSearchDetail(CustomOpportunityList);
		return null;
	}
	//三回ループして、順番を立てましょう
	 public   List<CustomOpportunity__c> doTrueSearch(List<CustomOpportunity__c> CustomOpportunityList){
	 	List<CustomOpportunity__c> CustomOpportunityList1=new List<CustomOpportunity__c>();
		List<CustomOpportunity__c> CustomOpportunityList2=new List<CustomOpportunity__c>();
		List<CustomOpportunity__c> CustomOpportunityList3=new List<CustomOpportunity__c>();
		//検索結果をゲットする
	    CustomOpportunityList1=GetSearch(firstKey,'売上');
	    CustomOpportunityList2=GetSearch(firstKey,'工事');
	    CustomOpportunityList3=GetSearch(firstKey,'管理');
	    if(CustomOpportunityList1!=null&&CustomOpportunityList1.size()!=0){
	    	for(CustomOpportunity__c cus:CustomOpportunityList1){
	    		CustomOpportunityList.add(cus);
	    	}
	    }
	    if(CustomOpportunityList2!=null&&CustomOpportunityList2.size()!=0){
	    	for(CustomOpportunity__c cus:CustomOpportunityList2){
	    		CustomOpportunityList.add(cus);
	    	}
	    }
	    if(CustomOpportunityList3!=null&&CustomOpportunityList3.size()!=0){
	    	for(CustomOpportunity__c cus:CustomOpportunityList3){
	    		CustomOpportunityList.add(cus);
	    	}
	    }
	 	return CustomOpportunityList;
	 }
	 
    public   List<CustomOpportunity__c> GetSearch(String key,String kubun) {

		Sdate=cusOpportunity.Sdate__c;
		Edate=cusOpportunity.Edate__c;
		PropatyDisplay=cusOpportunity.PropatyDisplay__c;
    	
    	//検索条件が全部ヌールの場合、戻す
    	if(Sdate==null&&Edate==null&&PropatyDisplay==null){
    		return null;
    	}
    	String sql='';
		sql+='SELECT id,';
		sql+=' repairCycleFormulaPG__c,';//周期年	
		sql+=' RecordType.DeveloperName,';//レコードタイプ	
		sql+=' Class__c,';//分類①
		//sql+=' Class2__c,';//分類②
		sql+=' ConstructionName__c,';//工事名
		sql+=' ProceedName__c,';//売上名
		sql+=' ManageName__c,';//管理名
		sql+=' PredYearMonth__c ,';//予定年月
		sql+=' CloseDate__c ,';//開始日
		//sql+=' PredictionExpense__c,';//工事予算（税抜）
		//sql+=' RepairCostActual__c';//工事実績（税抜）
		sql+=' NewYojituFee__c,';//物件別予実費用(PG)
		sql+=' NewYojituFeeFlg__c ';//物件別予実費用フラグ(PG)
		sql+=' FROM CustomOpportunity__c';//物件別工事（予算と実績）
		sql+=' WHERE Class__c!=null';
		//tian 要確認
		if(kubun=='工事'){
			sql+=' AND ConstructionName__c!=null ';
		}
		if(kubun=='売上'){
			sql+=' AND  ProceedName__c!=null ';
		}
		if(kubun=='管理'){
			sql+=' AND  ManageName__c!=null';
		}
		
		
		if(cusOpportunity.PropatyDisplay__c!=null){
			sql+=' AND propertyName__c=\''+PropatyDisplay+'\'';
		}
		if(Sdate!=null){
			Datetime sdt = Datetime.newInstance(Sdate.year(), Sdate.month(), Sdate.day());
			sql+=' AND(';
			sql+='  PredYearMonth__c>='+sdt.format('yyyy-MM-dd'); // 予定年月
			sql+=' )';
		}
		if(Edate!=null){
			Datetime edt = Datetime.newInstance(Edate.year(), Edate.month(), Edate.day());
			sql+=' AND(';
			sql+='  PredYearMonth__c<=' + edt.format('yyyy-MM-dd'); // 予定年月
			sql+=' )';
		}        
		 // 画面項目「対象」より、レコードタイプのIDを取得        
        system.debug(taisyous);
        list<ID> recordTypeId = GetIdOfRecordType(taisyous);								
		system.debug('recordTypeId : ' + recordTypeId  );
        if(recordTypeId.size() >0){
			sql+=' AND RecordTypeId  IN: recordTypeId';
        }
        if(kubun=='工事'){
			sql+=' ORDER BY Class__c,ConstructionName__c,NewYojituFeeFlg__c,PredYearMonth__c desc';	
        }
        if(kubun=='売上'){
			sql+=' ORDER BY Class__c,ProceedName__c,NewYojituFeeFlg__c,PredYearMonth__c desc';	
        }
        if(kubun=='管理'){
			sql+=' ORDER BY Class__c,ManageName__c,NewYojituFeeFlg__c,PredYearMonth__c desc';	
        }							
		system.debug(sql);		
		return Database.query(sql);							
    }
    
    /*
    	右側テーブルの予定年月をゲットする
    */
    @AuraEnabled
    public  void GetYearMonth() {
    	yearList=new List<Integer>();
		monthList=new List<Integer>();
		Date compareDate=Sdate;
		for(;compareDate<=Edate;compareDate=compareDate.addMonths(1)){
			yearList.add(compareDate.year());
			monthList.add(compareDate.month());
		}
		system.debug(yearList);
		system.debug(monthList);
		tableYear='';
		Map<Integer,Integer> yearMap=new Map<Integer,Integer>();
		tableMonth='';
		//予定年と予定月をゲットする
		Integer index=1;
		Integer preyear=0;
		Integer monthIndex=0;
		for(Integer year:yearList){
			if(monthList[monthIndex]<=3){
				year=year-1;
			}
			if(preyear!=year||preyear==0){
				yearMap.put(year,index);
				index=1;
			}else if(preyear==year){
				index=index+1;
				yearMap.put(preyear,index);
			}
			preyear=year;
			monthIndex=monthIndex+1;
		}
		system.debug(yearMap);
		tableYear=tableYear+'<td scope="col" rowspan="2" style="width:200px;border-right: solid 0.78px #cccccc;text-align:center;vertical-align:middle;z-index:15;">'+
                                        '<div class="slds-truncate"  style="width:100%;height:100%;font-size:20px;color: white;text-align:center;vertical-align:middle;z-index:15;">項目</div>'+
                                     '</td>'+
                                    '<td  scope="col" rowspan="2" style="width:80px;border-right: solid 0.78px #cccccc;text-align:center;vertical-align:middle;z-index:15;">'+
                                       ' <div class="slds-truncate"  style="font-size:20px;height:100%;color: white;text-align:center;vertical-align:middle;z-index:15;">周期年</div>'+
                                    ' </td>';
		for (Integer Key : yearMap.keySet()) {
    		tableYear=tableYear+'<td scope="col"  colspan="'+yearMap.get(Key)
    					+'" style="border-right: solid 0.78px #cccccc;text-align:center;z-index:10;"><div class="slds-truncate" style="color: white;">'
    					+Key+'</div></td>';
		}
		system.debug(tableYear);

		for(Integer month:monthList){
			tableMonth=tableMonth+'<td scope="col"  style="width:100px;'
									+'border-top: solid 0.78px #cccccc;border-right: solid 0.78px #cccccc;text-align:center;z-index:10;"><div class="slds-truncate" style="color: white;">'
									+month+'</div></td>';
		}
    }
    
   	/*
    	費用明細を検索する
    */
    
    public  void GetSearchDetail(List<CustomOpportunity__c> CustomOpportunityListCopy) {
    	//元画面の検索条件を保存する
    	//SetsaveConditions();
    	lefts=new List<leftTable>();
		//style1
		String style1='<td style="word-wrap:break-word;vertical-align:middle;height:17px;border-right: solid 0.78px #cccccc;z-index:0;">';
		//style2
		String style2='<td style="background-color:#ccffcc;border-right: solid 0.78px #cccccc;z-index:0;"><div class="slds-truncate">';
		//style3
		String style3='<td style="vertical-align:middle;height:17px;text-align:right;border-right: solid 0.78px #cccccc;z-index:0;"><a href="/';
		//前回の分類１を保存する
		String preclass='';
		//前回の工事名を保存する
		String preclass2='';
		//大分類の数
		Integer index=1;
		//loopの数
		Integer loopIndex=0;
		//周期
		String cycle='';
		for(CustomOpportunity__c cusopp:CustomOpportunityListCopy){
			String Class2Name='';
			//工事名
			if(cusopp.ConstructionName__c!=null){
				Class2Name=String.valueOf(cusopp.ConstructionName__c);
			}else if(cusopp.ProceedName__c!=null){
			//売上名
				Class2Name=String.valueOf(cusopp.ProceedName__c);
			}else if(cusopp.ManageName__c!=null){
			//管理名
				Class2Name=String.valueOf(cusopp.ManageName__c);
			}
			Decimal costmoney=cusopp.NewYojituFee__c;
			if(costmoney==null){
				costmoney=0;
			}
			if(Class2Name=='業務受託料'){
				system.debug('***'+cusopp);
			}
			List<String> lemoneyList=new List<String>();
			leftTable le=new leftTable();
			//削除フラグ、最初は削除しない
			le.delflag=false;
			//大分類
			if(preclass!=cusopp.Class__c){
				leftTable nle=new leftTable();
				nle.Koujikoumoku='<td style="background-color:#ccffcc;border-right: solid 0.78px #cccccc;z-index:10;"><div class="slds-truncate" style="z-index:10;">'+index+'.'+cusopp.Class__c+'</div></td>';
				nle.syuuki='<td style="background-color:#ccffcc;border-right: solid 0.78px #cccccc;z-index:10;"><div class="slds-truncate" style="z-index:10;"></div></td>';
				index+=1;
				//色ありのセルを補充
				List<String> nleList=new List<String>();
				for(Integer year:yearList){
						nleList.add(style2+'</div></td>');
				}
				nle.moneyList=nleList;
				nle.delflag=false;
				lefts.add(nle);
			}
			//工事名
			le.Koujikoumoku='<td style="word-wrap:break-word;vertical-align:middle;height:17px;border-right: solid 0.78px #cccccc;z-index:10;">'+Class2Name+'</td>';
			//工事名が変更する場合、周期年を初期化
			if(preclass2!=Class2Name){
				cycle='';
			}
			if(cusopp.repairCycleFormulaPG__c!=null){
				cycle=String.valueOf(cusopp.repairCycleFormulaPG__c);
			}
			le.syuuki='<td style="border-right: solid 0.78px #cccccc;z-index:10;">'+cycle+'</td>';
			
			//予定年月の数（lemoneyListの数でもあり）
			Integer innerIndex=0;
			//予定年月
			Date predYearMonth=cusopp.PredYearMonth__c;
			//完了日
			Date closeDate=cusopp.CloseDate__c;
			Integer preyear=0;
			Integer premonth=0;
			//費用の整理です
			for(Integer year:yearList){
				//お金がある場合（この年月に対応する費用があること）
				Boolean flag=false;
				/*//検収日がある場合、検収日を優先に判断する
				if(acceptanceDate!=null&&acceptanceDate.year()==year&&acceptanceDate.month()==monthList[innerIndex]){
					flag=true;
					closeDate=null;
					predYearMonth=null;
				}*/
				//予定年月
				if(predYearMonth!=null&&predYearMonth.year()==year&&predYearMonth.month()==monthList[innerIndex]){
					flag=true;
					closeDate=null;
                //完了日
				}else if(closeDate!=null&&closeDate.year()==year&&closeDate.month()==monthList[innerIndex]&&cusopp.NewYojituFeeFlg__c==false){
					flag=true;
				}
				if(flag){
					system.debug('0');
					//0~yearList.size()-1でループする、要注意
					if(preclass==cusopp.Class__c&&preclass2==Class2Name&&innerIndex!=(yearList.size())){
							system.debug('1');
							//同じ工事かつ同じ年月の場合
							if(preyear==year &&	premonth==monthList[innerIndex]){
									//実績がある場合
									String comoni=String.valueOf((costmoney+CustomOpportunityListCopy[loopIndex-1].NewYojituFee__c).format());
									if(cusopp.NewYojituFeeFlg__c==true && CustomOpportunityListCopy[loopIndex-1].NewYojituFeeFlg__c==true){
										system.debug('2>￥'+comoni);
										lemoneyList.add(style3+ cusopp.Id +'" ><span style="color:black;">￥'
															+comoni+'</span></a></td>');
									//実績がない、予算がある場合
									}else if(cusopp.NewYojituFeeFlg__c==false && CustomOpportunityListCopy[loopIndex-1].NewYojituFeeFlg__c==false){
										system.debug('3');
										lemoneyList.add(style3+ cusopp.Id +'" ><span style="color:red;">￥'
															+comoni+'</span></a></td>');	
									}
							}else{
							//同じ工事かつ違う年月の場合
									system.debug('4');
									if(cusopp.NewYojituFeeFlg__c==true){
										system.debug('5>￥'+costmoney.format());
									lemoneyList.add(style3+ cusopp.Id +'" ><span style="color:black;">￥'
														+String.valueOf(costmoney.format())+'</span></a></td>');
									}else if(cusopp.NewYojituFeeFlg__c==false){
										system.debug('6');
										lemoneyList.add(style3+ cusopp.Id +'" ><span style="color:red;">￥'
															+String.valueOf(costmoney.format())+'</span></a></td>');	
									}else if((cusopp.RecordType.DeveloperName =='RecordType1'||cusopp.RecordType.DeveloperName =='Unplan_Repair'||cusopp.RecordType.DeveloperName =='RecordType')
												&&costmoney==0){
										//ここに出力するものは、
										//該当する年月日があるけど、費用がないデータ
										//そのデータは、－で表示する
										system.debug('7');
										lemoneyList.add('<td style="vertical-align:middle;height:17px;border-right: solid 0.78px #cccccc;z-index:0;"><a href="/'+ cusopp.Id +'" ><span style="color:black;">-</span></a></td>');	
										
									}else{
										system.debug('8');
										lemoneyList.add(style1+'</td>');	
									}	
							}
							//前回の列を削除する
							lefts[lefts.size()-1].delflag=true;
							system.debug('9');
					}else{
						if(cusopp.NewYojituFeeFlg__c==true){
							system.debug('10>￥'+costmoney.format());
							lemoneyList.add(style3+ cusopp.Id +'" ><span style="color:black;">￥'
												+String.valueOf(costmoney.format())+'</span></a></td>');
						}else if(cusopp.NewYojituFeeFlg__c==false){
							system.debug('11');
							lemoneyList.add(style3+ cusopp.Id +'" ><span style="color:red;">￥'
												+String.valueOf(costmoney.format())+'</span></a></td>');	
						}else{
							system.debug('12');
							lemoneyList.add(style1+'</td>');	
						}
					}
				//	if flag=false
				}else{
					//0~yearList.size()-1でループする、要注意
					if(preclass==cusopp.Class__c&&preclass2==Class2Name&&innerIndex!=(yearList.size())){
						system.debug('13');
							//前回のこの年月の費用
							system.debug(lefts);
							system.debug(lefts[lefts.size()-1].moneyList);
							//周期以後からやる
							//前回の費用を取得
							String premoney=lefts[lefts.size()-1].moneyList[innerIndex];
							//前回の費用がＮＵＬＬではない場合
							if(premoney!=(style1+'</td>')){
								system.debug('14');
								
								//前回の費用を今回のリストに入れる
								lemoneyList.add(premoney);
								
							}else{
								system.debug('15');
								lemoneyList.add(style1+'</td>');
							}
						//前回の列を削除する
						lefts[lefts.size()-1].delflag=true;
					}else{
						system.debug('16');
						//お金がない場合
						lemoneyList.add(style1+'</td>');
					}
				}
				preyear=year;
				premonth=monthList[innerIndex];
				innerIndex=innerIndex+1;
			}
			le.moneyList=lemoneyList;
			lefts.add(le);
			
			preclass=cusopp.Class__c;
			preclass2=Class2Name;
			loopIndex=loopIndex+1;
			
		}
		//不要な行を削除する（小分類が重複する奴を全部削除）
		for(Integer i=lefts.size()-1;i>0;i--){
			//ここで削除操作をやる
			if(lefts[i].delflag==true){
				lefts.remove(i);
			}
		}
		system.debug(lefts);
       	//改ページ 
    	//Pages=paginationForYojitu(lefts);
    	system.debug(Pages);
    	system.debug(pageIndex);
    	//if(Pages!=null){
    	//	sessionPart.put('Pages', Pages);
    	//}
    	//TruePage=Pages[pageIndex];
    	TruePage=lefts;
    	system.debug(TruePage);
    }
	/**
	 * param   key  対象（画面項目）
	 * param   DeveloperName1
	 * param   DeveloperName2 
	 * 戻り値   レコードタイプのID 
	 */	
    private  List<ID> GetIdOfRecordType(String key) {
        list<String> developerNames = new list<String>(); 
		// 対象（画面項目）より、レコードタイプのDeveloperNameを取得
		 String sql='';
		sql+='SELECT id,';
		sql+=' DeveloperName';	
		sql+=' FROM RecordType';//レコードタイプ
		sql+=' WHERE SobjectType = \'CustomOpportunity__c\''; // カスタムオブジェクト \'計画\'
        if(key == 'sells'){
            // RecordType2　　計画売上
            // RecordType1　　計画外売上
			sql+=' AND DeveloperName  IN (\'RecordType2\',\'RecordType1\')';
        } else if(key == 'works'){
            // repairFee　　計画工事
            // Unplan_Repair　　計画外工事
			sql+=' AND DeveloperName  IN (\'repairFee\',\'Unplan_Repair\')';     
        } else if(key == 'manages'){
            // RecordType3　　計画管理
            // RecordType　　計画外管理
			sql+=' AND DeveloperName  IN (\'RecordType3\',\'RecordType\')';
        }  
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
}
public class ReportForJIGYOU {
    //印刷時間
    public string printTime {get; set;}
	//検索条件
    public string Jigyou {get; set;}
    //物件区分
    public string bukenKubun {get; set;}
    //実績年月(From)
    public string date1 {get; set;}
    //実績年月(To)
    public string date2 {get; set;}
    //明細内容
    public Table table {get; set;}
    public List<rowList> row {get; set;}
    //粗利列
    public List<String> sorirow{get; set;}
    public List<List<Col>> pages{get; set;}
    //粗利
    public	Map<Integer,Integer> SORIMap;
    public List<Header> headerlist{get; set;}
	public class Table {
		//ヘッダ列名(html用)
		@AuraEnabled
		public  List<String> headerList1 {get;set;}
        //ヘッダ列名(html用)
		@AuraEnabled
		public  List<String> headerList2 {get;set;}
        //ヘッダ列名(html用)
		@AuraEnabled
		public  List<String> headerList3 {get;set;}
	}
	//行名(html用) 
	public class rowList{
			@AuraEnabled
			public  String LeftrowList {get;set;}
			@AuraEnabled
			public  String RightrowList {get;set;}
	}
	
	public class Header{
		//ヘッダ列名(html用)
		@AuraEnabled
		public  List<String> TheaderList1 {get;set;}
        //ヘッダ列名(html用)
		@AuraEnabled
		public  List<String> TheaderList2 {get;set;}
		@AuraEnabled
		public  List<String> TheaderList3 {get;set;}
		@AuraEnabled
		public  List<String> soriList {get;set;}
	}
	
	public class Col {
        //ヘッダ列名(html用)
		@AuraEnabled
		public  String TLeftrowList {get;set;}
		@AuraEnabled
		public  String TRightrowList {get;set;}
	}
	//改ページ用ヘッダ名
	public List<String> HeaderForPagenate;
 	/*
     * 事業収支表出力
     */     
    public  ReportForJIGYOU(){
    	system.debug('456');
    	HeaderForPagenate= new List<String>();
        //検索条件をゲット
        //印刷時間
        printTime=String.valueOf(DateTime.now());
        //事業部
    	Jigyou=ApexPages.currentPage().getParameters().get('Jigyou');
    	//物件区分
    	bukenKubun=ApexPages.currentPage().getParameters().get('bukenKubun');
    	//実績年月(From)
    	date1=ApexPages.currentPage().getParameters().get('Sdate');
    	//実績年月(To)
    	date2=ApexPages.currentPage().getParameters().get('Edate');
    	Date Sdate=null;
    	Date Edate=null;
    	if(date1!=null&&date1!=''){
    	   Sdate=Date.valueOf(date1);
    	}
    	if(date1!=null&&date2!=''){
    	   Edate=Date.valueOf(date2);
    	}
    	system.debug(Jigyou);
    	//検索する
    	list<AggregateResult> customOpportunitys =searchJigyou(Jigyou,bukenKubun,Sdate,Edate,'');
    	if(customOpportunitys==null||customOpportunitys.size()==0){
    		return;
    	}
    	//検索する（左側の列名を求めるため）
    	list<AggregateResult> customOpportunitysOrder =searchJigyou(Jigyou,bukenKubun,Sdate,Edate,'Class');
    	//検索する（大分類毎に集計を求めて）
    	list<AggregateResult> customGroupByClass =searchJigyouGroupByClass(Jigyou,bukenKubun,Sdate,Edate);
    	//検索結果を整理する
    	makeUpDetail(customOpportunitys,customOpportunitysOrder,customGroupByClass,Edate);
    }
	/*
     *基本な考えは：
     	まずは左側の名前を整理
    	 または金の累計をゲット、さらにそれぞれの合計を計算
     */    
     public void  makeUpDetail(list<AggregateResult> customOpportunitys,list<AggregateResult> customOpportunitysOrder,list<AggregateResult> customGroupByClass,Date Edate){
     	System.debug(customOpportunitys.size());
        table =new Table();
        
        List<String> TrueDescription=new List<String>();
        List<String> TruePropertyDivision=new List<String>();
        //Map<工事名,大分類名>
        Map<String,String> Class1ANDConstructionName=new Map<String,String>();
        
        //Map
        //String:工事区分+大分類+工事ＩＤ
     	//Ｉｎｔｅｇｅｒ:金
        List<Map<String,Integer>> zahyou=new List<Map<String,Integer>>();
        //String: 物件区分+物件ＩＤ
		List<String> Xzahyou=new List<String>();
		
		row =new List<rowList>();
        AggregateResult precuop=null;
        //列名をゲットする
     	zahyou=doRowsList(customOpportunitysOrder,table,Class1ANDConstructionName,TrueDescription);
     	//ヘッダ名をゲットする
     	Xzahyou=doHeaderList(customOpportunitys,precuop,table,TruePropertyDivision,Edate);
		
		//お金を整理する
		domoney(zahyou,Xzahyou,customGroupByClass);
		
		//改ページ
		dopagenate();
     }
     //改ページ
     public void dopagenate(){
     	//一行に列数（改ページ用）
     	Integer colsNum=22;
     	system.debug('HeaderForPagenate'+HeaderForPagenate);
     	List<Integer> indexlist=new List<Integer>();
     	Integer index=1;
     	for(String he:HeaderForPagenate){
     		if(he.contains('合計')){
     			indexlist.add(index);
     		}
     		system.debug(he);
     		index=index+1;
	    }
	    List<Integer> orderList=new List<Integer>();
	    Integer kaisu=1;
	    for(Integer k=0;k<indexlist.size();k++){
	    	system.debug(indexlist[k]);
	    	if(isDivisibility(indexlist[k],colsNum,kaisu)){
	    		if(kaisu==1){
	    			//初回目の場合、初改行の位置を二回記録する
	    			orderList.add(indexlist[k-1]);
	    			orderList.add(indexlist[k-1]);
	    		}else{
	    			orderList.add(indexlist[k-1]);
	    		}
	    		kaisu=kaisu+1;
	    	}
	    	if(k==indexlist.size()-1&&orderList.size()==0){
	    		orderList.add(indexlist[k-1]);
	    	}
	    }
		//截取到index的长度
		
    	system.debug(orderList);
    	//粗利の行を追加する
    	sorirow=new List<String>();
		for(Integer key:SORIMap.keySet()){
			sorirow.add('<td style="width: 80px;text-align:right;border-top: black solid 1px;border-left: black solid 0.5px;border-right: black solid 0.5px;border-bottom: black solid 0.5px;background-color:#B4C6E7">'+SORIMap.get(key).format()+'</td>');
		}
		
		//headの整理、ヘッダを分割する
    	headerlist=new List<Header>();
    	pages=new List<List<Col>>();
    	//ここのループは改ページの回数です
    	for(Integer Torder=0;Torder<orderList.size();Torder++){
    		Header header=new Header();
    		Integer tempIndex=orderList[Torder];
    		Integer tempIndex2=0;
    		//最後ではない
    		if(Torder!=orderList.size()-1&&Torder!=0){
    			tempIndex2=orderList[Torder+1];
    		}
	    	header.TheaderList1=new List<String>();
	    	header.TheaderList2=new List<String>();
	    	header.TheaderList3=new List<String>();
	    	header.soriList=new List<String>();
	    	
	    	String flag='1';
	    	//ヘッダ部の一行目の分割
	    	for(String nt1:table.headerList1){
	    		if(Torder==0){
	    			//初回目
	    			header.TheaderList1.add(nt1);
	    			if(nt1.contains(HeaderForPagenate[tempIndex-1])){
	    	 			break;
	    	 		}
	    		}else{
	    			//二回以後
		    	 	if(nt1.contains(HeaderForPagenate[tempIndex-1])){
		    	 		flag='2';
		    	 	}
		    	 	if(flag=='2'&&nt1.contains(HeaderForPagenate[tempIndex-1])==false){
		    	 		header.TheaderList1.add(nt1);
						if(tempIndex2!=0&&nt1.contains(HeaderForPagenate[tempIndex2-1])){
							break;
						}
		    	 	}
	    		}
	    	}
	    	//ヘッダ部の２行目の分割
	        for(String nt2:table.headerList2){
	        	if(Torder==0){
	        		//初回目
	    			header.TheaderList2.add(nt2);
	    			if(nt2.contains(HeaderForPagenate[tempIndex-2])){
	    	 			break;
	    	 		}
	        	}else{
		    	    if(nt2.contains(HeaderForPagenate[tempIndex-2])){
		    	 		flag='3';
		    	 	}
		    	 	if(flag=='3'&&nt2.contains(HeaderForPagenate[tempIndex-2])==false){
		    	 		header.TheaderList2.add(nt2);
		    	 		if(tempIndex2!=0&&nt2.contains(HeaderForPagenate[tempIndex2-2])){
							break;
						}
		    	 	}
	        	}
	    	}
	    	//差額行の分割
	    	if(Torder==0){
	    		//1ページ目
		    	for(Integer key1=0;key1<tempIndex;key1++){
		        	header.soriList.add(sorirow[key1]);
		        	header.TheaderList3.add(table.headerList3[key1]);
		    	}
	    	}else if(Torder!=orderList.size()-1){
	    		for(Integer key1=tempIndex;key1<tempIndex2;key1++){
		        	header.soriList.add(sorirow[key1]);
		        	header.TheaderList3.add(table.headerList3[key1]);
		    	}
	    	}else{
	    		//最後のページ
	    		for(Integer key1=tempIndex;key1<HeaderForPagenate.size();key1++){
		        	header.soriList.add(sorirow[key1]);
		        	header.TheaderList3.add(table.headerList3[key1]);
		    	}
	    	}
	    	headerlist.add(header);
	    	system.debug(headerlist.size());
	    	
	    	List<Col> page=new List<Col>();
	    	for(rowList rlist:row){
	    		Col col=new Col();
	    		col.TLeftrowList=rlist.LeftrowList;
	    		system.debug(tempIndex);
	    		Integer iu=-1;
	    		for(Integer r=0;r<tempIndex;r++){
	    			iu=rlist.RightrowList.indexOf('</td>',iu+1);
	    		}
	    		Integer iu2=-1;
	    		if(tempIndex2!=0){
		    		for(Integer r=0;r<tempIndex2;r++){
		    			iu2=rlist.RightrowList.indexOf('</td>',iu2+1);
		    		}
	    		}
	    		if(Torder==0){
	    			//1page
	    			col.TRightrowList=rlist.RightrowList.subString(0,iu+5)+'</tr>';
	    		}else if(Torder!=orderList.size()-1){
	    			//最後のページではない
	    			col.TRightrowList=rlist.RightrowList.subString(iu+5,iu2+5)+'</tr>';
	    		}else{
	    			//最後のページです
	    			col.TRightrowList=rlist.RightrowList.subString(iu+5);
	    		}
	    		system.debug(col.TRightrowList);
	    		page.add(col);
	    	}
	    	pages.add(page);
	    	system.debug(pages.size());
    	}
     }
     //X,Y座標でお金を埋める
     public void domoney(List<Map<String,Integer>> zahyou,List<String> Xzahyou,list<AggregateResult> customGroupByClass){
		system.debug(customGroupByClass);
		String style2='<td style="width: 80px;text-align:right;border-top: black solid 1px;border-left: black solid 0.5px;border-right: black solid 0.5px;border-bottom: black solid 0.5px;';
		//------------ここには大分類の合計行と工事区分合計行を求めるため、前提準備のＭＡＰを用意---------------------------------------------------------------------------------------------------------------
		//Map<大分類+物件名,金>
		Map<String,Integer> Forloop=new Map<String,Integer>();
		//Map<工事区分+物件名,金>
		Map<String,Integer> ForKoujiKUbun=new Map<String,Integer>();

     	for(AggregateResult cuop:customGroupByClass){
     		//工事区分+大分類+物件名
     		String key=String.valueof(cuop.get('Description'))+String.valueof(cuop.get('Class_PG__c'))+String.valueof(cuop.get('propertyName'));
     		Integer kane=Integer.valueof(cuop.get('RepairCostActual'));
     		kane=kane==null?0:kane;
     		//工事区分+物件名
     		String key2=String.valueof(cuop.get('Description'))+String.valueof(cuop.get('propertyName'));
     		if(!ForKoujiKUbun.containsKey(key2)){
     			ForKoujiKUbun.put(key2,kane);
     		}else{
     			Integer tempmon=ForKoujiKUbun.get(key2);
     			tempmon=tempmon+kane;
     			ForKoujiKUbun.put(key2,tempmon);
     		}
     		
     		Forloop.put(key,kane);
     	}
     	//---------------------------------------------------------------------------------------------------------------------------
     	//各工事区分に対応するお金ＭＡＰ
     	//売上
     	Map<Integer,Integer> SumUriageMap=new Map<Integer,Integer>();
     	//工事
     	Map<Integer,Integer> SumKoujiMap=new Map<Integer,Integer>();
     	//管理
     	Map<Integer,Integer> SumKanriMap=new Map<Integer,Integer>();
     	SORIMap=new Map<Integer,Integer>();
     	Integer index=0;
     	//初期化、まずは全部を０に入れる
     	for(String key:table.headerList3){
     		SumUriageMap.put(index,0);
     		SumKoujiMap.put(index,0);
     		SumKanriMap.put(index,0);
     		SORIMap.put(index,0);
     		index=index+1;
     	}
     	Integer SumUriageMapIndex=0;
		Integer SumKoujiMapIndex=0;
		Integer SumKanriMapIndex=0;
     	//---------------------------------------------------------------------------------------------------------------------------
     	//Y座標のＭＡＰをゲットする
     	//String:工事区分+大分類+工事ＩＤ
     	//Ｉｎｔｅｇｅｒ:金
        Map<String,Integer> OldYzahyou=zahyou.get(0);
        //全ての金のＭＡＰをゲットする
     	//String:工事区分+大分類+工事ＩＤ+ 物件区分+物件ＩＤ
		//Ｉｎｔｅｇｅｒ:金
		Map<String,Integer> FeeList=zahyou.get(1);
		
		
		//一時保存して、Copyrowは右側の金を保存する。あとで、左側の項目名と合併する
		List<rowList> Copyrow =new List<rowList>();
		//前工事区分
		String preCon1='';
		//前大分類
		String preCon2='';
		//物件区分毎の合計（大分類）
		Integer smallcrowbukenn=0;
		//物件区分毎の合計（工事区分）
		Integer smalldrowbukenn=0;
		//最後列の合計（大分類）
		Integer bigcrowbukenn=0;
		//最後列の合計（工事区分）
		Integer bigdrowbukenn=0;
		
		//Map<物件名,金>
		Map<String,Integer> bigcon2=new Map<String,Integer>();
		//content:物件名
		for(String content:Xzahyou){
			bigcon2.put(content,0);
		}
		//Y座標の順番を再整理
		Map<String,Integer> Yzahyou= new Map<String,Integer>();
		for(String key:OldYzahyou.keySet()){
			system.debug(key);
			if(key.contains('売上/')){
				Yzahyou.put(key,OldYzahyou.get(key));
			}
		}
		for(String key:OldYzahyou.keySet()){
			system.debug(key);
			if(key.contains('工事/')){
				Yzahyou.put(key,OldYzahyou.get(key));
			}
		}
		for(String key:OldYzahyou.keySet()){
			system.debug(key);
			if(key.contains('管理/')){
				Yzahyou.put(key,OldYzahyou.get(key));
			}
		}
		for(String key:Yzahyou.keySet()){
			String[] conditions=key.split('/');
			//工事区分
			String condition1=conditions[0];
			//大分類
			String condition2=conditions[1];
			Integer value=Yzahyou.get(key);
			value=(value==null?0:value);
			//新規行
			rowList brow=new rowList();
			//最後列の合計（大分類）
			bigcrowbukenn=0;
			//最後列の合計（工事区分）
			bigdrowbukenn=0;
			//小物件合計
			Integer smallbukenn=0;
			//大物件合計
			Integer bigbukenn=0;
			//普通行
			String arow='';
			//大分類の合計行
			String crow='';
			//工事区分の合計行
			String drow='';
			String pre='';
			//Ｘ座標を数える
			Integer size=1;
			//content:物件名
			for(String content:Xzahyou){
				system.debug(key+content);
				Integer kane=FeeList.get(key+content);
				kane=(kane==null?0:kane);
				String[] scon=content.split('/');
				//工事区分が変わった場合
				if(condition1!=preCon1||preCon1==''){
					Integer classMoney=ForKoujiKUbun.get(condition1+scon[1]);
					classMoney=classMoney==null?0:classMoney;
					bigdrowbukenn=bigdrowbukenn+classMoney;
					//もし物件区分が変わった場合
					if((pre!=''&&pre!=scon[0])){
						if(condition1=='売上'){
							//売上
		     				SumUriageMap.put(SumUriageMapIndex,smalldrowbukenn);
		     				SumUriageMapIndex=SumUriageMapIndex+1;
						}else if(condition1=='管理'){
							//管理
					     	SumKanriMap.put(SumKoujiMapIndex,smalldrowbukenn);
					     	SumKoujiMapIndex=SumKoujiMapIndex+1;
						}else if(condition1=='工事'){
							//工事
		     				SumKoujiMap.put(SumKanriMapIndex,smalldrowbukenn);
		     				SumKanriMapIndex=SumKanriMapIndex+1;
						}
						drow=drow+style2+'background-color:#B4C6E7">'+smalldrowbukenn.format()+'</td>';
						smalldrowbukenn=0;
					}
					if(condition1=='売上'){
						//売上
	     				SumUriageMap.put(SumUriageMapIndex,classMoney);
	     				SumUriageMapIndex=SumUriageMapIndex+1;
					}else if(condition1=='管理'){
						//管理
				     	SumKanriMap.put(SumKoujiMapIndex,classMoney);
				     	SumKoujiMapIndex=SumKoujiMapIndex+1;
					}else if(condition1=='工事'){
						//工事
	     				SumKoujiMap.put(SumKanriMapIndex,classMoney);
	     				SumKanriMapIndex=SumKanriMapIndex+1;
					}
					smalldrowbukenn=smalldrowbukenn+classMoney;
					drow=drow+style2+'background-color:#B4C6E7">'+classMoney.format()+'</td>';
					//最後の一区分
					if(Xzahyou.size()==size){
						if(condition1=='売上'){
							//売上
		     				SumUriageMap.put(SumUriageMapIndex,smalldrowbukenn);
		     				SumUriageMapIndex=SumUriageMapIndex+1;
						}else if(condition1=='管理'){
							//管理
					     	SumKanriMap.put(SumKoujiMapIndex,smalldrowbukenn);
					     	SumKoujiMapIndex=SumKoujiMapIndex+1;
						}else if(condition1=='工事'){
							//工事
		     				SumKoujiMap.put(SumKanriMapIndex,smalldrowbukenn);
		     				SumKanriMapIndex=SumKanriMapIndex+1;
						}
						drow=drow+style2+'background-color:#B4C6E7">'+smalldrowbukenn.format()+'</td>';
						smalldrowbukenn=0;
					}
				}
				//大分類が変わった場合
				if(preCon2==''||(condition1+condition2)!=preCon2){
					Integer classMoney=Forloop.get(condition1+condition2+scon[1]);
					classMoney=classMoney==null?0:classMoney;
					bigcrowbukenn=bigcrowbukenn+classMoney;
					//もし物件区分が変わった場合
					if((pre!=''&&pre!=scon[0])){
						crow=crow+style2+'background-color:#CCFFFF">'+smallcrowbukenn.format()+'</td>';
						smallcrowbukenn=0;
					}
					smallcrowbukenn=smallcrowbukenn+classMoney;
					crow=crow+style2+'background-color:#CCFFFF">'+classMoney.format()+'</td>';
					//最後の一区分
					if(Xzahyou.size()==size){
						crow=crow+style2+'background-color:#CCFFFF">'+smallcrowbukenn.format()+'</td>';
						smallcrowbukenn=0;
					}
				}
				//もし物件区分が変わった場合
				if((pre!=''&&pre!=scon[0])){
					arow=arow+style2+'background-color:#">'+smallbukenn.format()+'</td>';
					smallbukenn=0;
				}
				arow=arow+style2+'background-color:#">'+kane.format()+'</td>';
				smallbukenn=smallbukenn+kane;
				//最後の一区分
				if(Xzahyou.size()==size){
					arow=arow+style2+'background-color:#">'+smallbukenn.format()+'</td>';
					smallbukenn=0;
				}
				bigbukenn=bigbukenn+kane;
				pre=scon[0];
				size=size+1;
			}
			//今の工事区分の合計行は空白ではない場合、追加する
			if(drow!=''){
				//一行を追加する
				rowList ddrow=new rowList();
				drow=drow+style2+'background-color:#B4C6E7">'+bigdrowbukenn.format()+'</td>';
				ddrow.RightrowList=drow;
				Copyrow.add(ddrow);
				drow='';
				if(condition1=='売上'){
					//売上
     				SumUriageMap.put(SumUriageMapIndex,bigdrowbukenn);
     				SumUriageMapIndex=SumUriageMapIndex+1;
				}else if(condition1=='管理'){
					//管理
			     	SumKanriMap.put(SumKoujiMapIndex,bigdrowbukenn);
			     	SumKoujiMapIndex=SumKoujiMapIndex+1;
				}else if(condition1=='工事'){
					//工事
     				SumKoujiMap.put(SumKanriMapIndex,bigdrowbukenn);
     				SumKanriMapIndex=SumKanriMapIndex+1;
				}
			}
			//今の大分類の合計行は空白ではない場合、追加する
			if(crow!=''){
				//一行を追加する
				rowList cdrow=new rowList();
				crow=crow+style2+'background-color:#CCFFFF">'+bigcrowbukenn.format()+'</td>';
				cdrow.RightrowList=crow;
				Copyrow.add(cdrow);
				crow='';
			}
			//普通の行を追加する
			arow=arow+style2+'background-color:#">'+bigbukenn.format()+'</td>';
			brow.RightrowList=arow;
			Copyrow.add(brow);
			
			preCon1=condition1;
			preCon2=condition1+condition2;
		}
		//ここは合併操作。
		//右側のお金を左側の工事名を合併
		
		for(rowList r:Copyrow){
			system.debug(r.RightrowList);
		}
		for(rowList r:row){
			system.debug(r.LeftrowList);
		}
		Integer i=0;
		for(rowList r:Copyrow){
			row[i].RightrowList=r.RightrowList;
			i=i+1;
		}
		
		system.debug(Copyrow);
		//粗利を整理する
		dosori(SumUriageMap,SumKoujiMap,SumKanriMap,SORIMap);
     }
     
     //粗利を整理する
      public Map<Integer,Integer> dosori(Map<Integer,Integer> SumUriageMap,Map<Integer,Integer> SumKoujiMap,Map<Integer,Integer> SumKanriMap,Map<Integer,Integer> SORIMap){
      	system.debug(SumUriageMap);
		system.debug(SumKanriMap);
		system.debug(SumKoujiMap);
		for(Integer n=0;n<SumUriageMap.size();n++){
			Integer value=SumUriageMap.get(n)-SumKanriMap.get(n)-SumKoujiMap.get(n);
			SORIMap.put(n,value);
		}
		system.debug(SORIMap);
		return SORIMap;
      }
 
     /*
     y座標をゲットする
     */
     public List<Map<String,Integer>> doRowsList(list<AggregateResult> customOpportunitysOldOrder,Table table, Map<String,String> Class1ANDConstructionName,List<String> TrueDescription){ 
     	List<Map<String,Integer>> zahyou=new List<Map<String,Integer>>();
     	//String:工事区分+大分類+工事ＩＤ
     	//Ｉｎｔｅｇｅｒ:金
     	Map<String,Integer> Yzahyou=new Map<String,Integer>();
     	//String:工事区分+大分類+工事ＩＤ+ 物件区分+物件ＩＤ
		//Ｉｎｔｅｇｅｒ:金
		Map<String,Integer> FeeList=new Map<String,Integer>();
     	String style2='<td style="width: 80px;text-align:left;border-top: black solid 1px;border-left: black solid 0.5px;border-right: black solid 0.5px;border-bottom: black solid 0.5px;';
        //Map<大分類名,Map<工事名,工事行数>>
        Map<String,Map<String,Integer>> Class1Map=new Map<String,Map<String,Integer>>();
        Map<String,Integer> ConstructionNameMap= new  Map<String,Integer>();
        //Map<大分類名,行数> 
        Map<String,Integer> tempNameMap=new Map<String,Integer>();
     	//大分類数
        Integer cols=1;
        //大分類下の工事数
        Integer cols2=1;
     	
     	//Map<工事区分,数> 
        Map<String,Integer> DescriptionMap=new Map<String,Integer>();
        //縦
        //表示順を整理する
        List<AggregateResult> customOpportunitysOrder= new list<AggregateResult>();
        for(AggregateResult cuop:customOpportunitysOldOrder){
        	if(String.valueof(cuop.get('Description'))=='売上'){
        		customOpportunitysOrder.add(cuop);
        	}
        }
        for(AggregateResult cuop:customOpportunitysOldOrder){
        	if(String.valueof(cuop.get('Description'))=='工事'){
        		customOpportunitysOrder.add(cuop);
        	}
        }
        for(AggregateResult cuop:customOpportunitysOldOrder){
        	if(String.valueof(cuop.get('Description'))=='管理'){
        		customOpportunitysOrder.add(cuop);
        	}
        }
        //ここには、ヘッダと列名を整理します
 		for(AggregateResult cuop:customOpportunitysOrder){
 			Integer money=Integer.valueof(cuop.get('RepairCostActual')==null?0:cuop.get('RepairCostActual'));
 			//String:工事区分+大分類+工事ＩＤ
 			String key=String.valueof(cuop.get('Description'))+'/'
 							+String.valueof(cuop.get('Class_PG__c'))+'/'
 							+String.valueof(cuop.get('ConstructionPG__c'));
 			//String:工事区分+大分類+工事ＩＤ
 			String key2=String.valueof(cuop.get('Description'))+'/'
 							+String.valueof(cuop.get('Class_PG__c'))+'/'
 							+String.valueof(cuop.get('ConstructionPG__c'))
 							+String.valueof(cuop.get('PropertyDivision'))+'/'
 							+String.valueof(cuop.get('propertyName')); 							
 			Yzahyou.put(key,money);
 			FeeList.put(key2,money);
 			
        	//売上、工事、管理.レコードタイプが変わったら、区別する
        	if(DescriptionMap.containsKey(String.valueof(cuop.get('Description')))==false){
        		rowList smallrow=new rowList();
        		if(cuop.get('Description')==null){
        			smallrow.LeftrowList=style2+'"></td>';
        		}else{
        			smallrow.LeftrowList=style2+'background-color:#B4C6E7">'+cuop.get('Description')+'</td>';
        		}
        		row.add(smallrow);
        		DescriptionMap.put(String.valueof(cuop.get('Description')),1);
        		TrueDescription.add(String.valueof(cuop.get('Description')));
        		
        		//初期化　大分類数
		        cols=1;
		        //大分類下の工事数
		        cols2=1;
        	}
        	//初回目
 			if(Class1Map.containsKey(String.valueof(cuop.get('Description'))+String.valueof(cuop.get('Class_PG__c')))==false){
    			cols2=1;
    			tempNameMap.put(String.valueof(cuop.get('Class_PG__c')),cols);
    			Map<String,Integer> NewConstructionNameMap= new  Map<String,Integer>();
    			Class1Map.put(String.valueof(cuop.get('Description'))+String.valueof(cuop.get('Class_PG__c')),NewConstructionNameMap);
    			
            	rowList smallrow=new rowList();
    			smallrow.LeftrowList=(style2+'background-color:#CCFFFF">'+cols+'.'+cuop.get('Class_PG__c')+'</td>');
    			row.add(smallrow);
    			Class1ANDConstructionName.put(String.valueof(cuop.get('Class2PGName')),String.valueof(cuop.get('Class_PG__c')));
    			//行数をプラス
    			cols=cols+1;
    		}
    		system.debug(cuop.get('Class2PGName'));
    		
    		Map<String,Integer> ConstructionNameMap2=Class1Map.get(String.valueof(cuop.get('Description'))+String.valueof(cuop.get('Class_PG__c')));
    		system.debug(ConstructionNameMap2);
    		system.debug(Class1Map);
    		//初回目
			if(ConstructionNameMap2.containsKey(String.valueof(cuop.get('Class2PGName')))==false){
        		Integer cols3=0;
        		//大分類が既存
        		if(Class1Map.containsKey(String.valueof(cuop.get('Description'))+String.valueof(cuop.get('Class_PG__c')))){
        			cols3=ConstructionNameMap2.size()+1;
        		}else{
        			//大分類がない
        			//行数を1
            		cols3=1;
        		}
            	ConstructionNameMap2.put(String.valueof(cuop.get('Class2PGName')),cols3);
            	rowList smallrow=new rowList();
        		smallrow.LeftrowList=(style2+'background-color:">　　'+tempNameMap.get(String.valueof(cuop.get('Class_PG__c')))+'-'
        							+cols3+'.'
        							+cuop.get('Class2PGName')+'</td>');
        		row.add(smallrow);					
    			Class1ANDConstructionName.put(String.valueof(cuop.get('Class2PGName')),String.valueof(cuop.get('Class_PG__c')));
        	}
        	system.debug(cuop);
     	}
     	zahyou.add(Yzahyou);
     	zahyou.add(FeeList);
     	system.debug(Yzahyou);
     	return zahyou;
     }

     public List<String> doHeaderList(list<AggregateResult> customOpportunitys,AggregateResult precuop,Table table,List<String> TruePropertyDivision,Date Edate){  
     	//竣工年
     	Integer SyunkoNen=Edate==null?Date.today().year():Edate.year();
    	
     	//String: 物件区分+物件ＩＤ
     	List<String> Xzahyou=new List<String>();
     	Integer tempcols=0; 
     	table.headerList1 =new  List<String>();
        table.headerList2 =new  List<String>();
        table.headerList3 =new  List<String>();
     	Integer loopIndex=0;
     	String style1='<td style="background-color:#DCDCDC;width: 80px;text-align:center;border-top: black solid 1px;border-left: black solid 0.5px;border-right: black solid 0.5px;border-bottom: black solid 0.5px;"';
     	//横
     	//ヘッダ部の処理
      	for(AggregateResult cuop:customOpportunitys){
      		String temp=String.valueof(cuop.get('PropertyDivision'))+'/'+String.valueof(cuop.get('propertyName'));
      		if(Xzahyou.contains(temp)==false){
      			Xzahyou.add(temp);
      		}
        	//ここは、物件区分の比較
        	//precuopとcuopを比較の理由は、soqlのorder順です
			if(precuop!=null&&precuop.get('PropertyDivision')!=cuop.get('PropertyDivision')){
                system.debug(cuop.get('PropertyDivision'));
				table.headerList1.add(style1+' colspan="'+tempcols+'">'+precuop.get('PropertyDivision')+'</td>');
				table.headerList1.add(style1+' rowspan="2">'+precuop.get('PropertyDivision')+'合計</td>');
				HeaderForPagenate.add(precuop.get('PropertyDivision')+'合計');
				table.headerList3.add(style1+'></td>');
                tempcols=0;
                TruePropertyDivision.add(String.valueof(precuop.get('PropertyDivision')));
			}
			//ここは、物件名の比較
			if(precuop==null||precuop.get('propertyName')!=cuop.get('propertyName')){
				String tempString=String.valueOf(cuop.get('propertyName'));
				String header='';
				if(tempString.length()/6>=1&&tempString.length()!=6){
					for(Integer i=0;i<=tempString.length()/6;i++){
						if(i==tempString.length()/6){
							header=header+tempString.subString(i*6);
						}else{
				    		header=header+tempString.subString(6*i,6+6*i)+'<br/>';
						}
					}
				}else{
				 	header=tempString;
				}
				
				system.debug(header);
				table.headerList2.add(style1+'>'+header+'</td>');
				HeaderForPagenate.add(header);
				Integer year=Integer.valueOf(cuop.get('CompletionYear'));
				if(year==null){
					table.headerList3.add(style1+'></td>');
				}else{
					//選択された年数-竣工年＝欲しいそれまでの築年数
					table.headerList3.add(style1+'>'+(SyunkoNen-year+1)+'</td>');
				}
                tempcols=tempcols+1;
			}
            //最後のループ
            if(loopIndex==customOpportunitys.size()-1){
                system.debug(cuop.get('PropertyDivision'));
				table.headerList1.add(style1+' colspan="'+tempcols+'">'+cuop.get('PropertyDivision')+'</td>');
				table.headerList1.add(style1+' rowspan="2">'+cuop.get('PropertyDivision')+'合計</td>');
				HeaderForPagenate.add(cuop.get('PropertyDivision')+'合計');
				table.headerList3.add(style1+'></td>');
				table.headerList1.add(style1+' rowspan="2">合計</td>');
				HeaderForPagenate.add(style1+' rowspan="2">合計</td>');
				table.headerList3.add(style1+'></td>');
                tempcols=1;
                TruePropertyDivision.add(String.valueof(cuop.get('PropertyDivision')));
            }
        	precuop=cuop;
        	loopIndex=loopIndex+1;
        }
        system.debug(Xzahyou);
        return Xzahyou;
	 }
	
     public list<AggregateResult>  searchJigyou(String Jigyou,String bukenKubun,Date Sdate,Date Edate,String OrderByClass){  
     	system.debug('Sdate:   '+ Sdate);
        String strSql = 'SELECT ';
        strSql += ' propertyName__r.PropertyDivision__c PropertyDivision,';//物件区分
        strSql += ' max(propertyName__r.Name) propertyName,';//物件名
        strSql += ' RecordType.Description Description,';//売上、工事、管理を区別するためのキー
        strSql += ' Class_PG__c,';//分類①
        strSql += ' ConstructionPG__c,';//工事ID
        strSql += ' max(Class2PG__c ) Class2PGName,';//小分類名（PG）
        strSql += ' max(CompletionYear__c) CompletionYear,';//竣工年
        strSql += ' sum(NewYojituFee__c) RepairCostActual ';//物件別予実費用(PG)

		//YojituFeeFlg__c=true 実績
        strSql += ' FROM   CustomOpportunity__c ';
        strSql += ' WHERE  Class2PG__c != null and Class__c!=null and Class_PG__c!=null and NewYojituFeeFlg__c=true ';
        if (Jigyou != null) { 
        	strSql += ' AND propertyName__r.ManagingDepartment__c = :Jigyou ';//事業部
        }
         if (bukenKubun != null&&bukenKubun !='') { 
        	strSql += ' AND propertyName__r.PropertyDivision__c = :bukenKubun ';//物件区分
        }
        if (Sdate != null) { 
			Datetime sdt = Datetime.newInstance(Sdate.year(), Sdate.month(), Sdate.day());
			strSql+=' AND(';
			strSql+='  KensyuOrkanryouPG__c>='+sdt.format('yyyy-MM-dd'); // 予定年月
			strSql+=' )';
        }
        if (Edate != null) {
			Datetime edt = Datetime.newInstance(Edate.year(), Edate.month(), Edate.day());
			strSql+=' AND(';
			strSql+='  KensyuOrkanryouPG__c<=' + edt.format('yyyy-MM-dd'); // 予定年月
			strSql+=' )';
        }
        
        strSql += ' GROUP BY ';
        strSql += ' propertyName__r.PropertyDivision__c,';//物件区分
 		strSql += ' propertyName__c,';//物件ＩＤ
        strSql += ' RecordType.Description,';//売上、工事、管理を区別するためのキー
 		strSql += ' Class_PG__c,';//分類①
 		strSql += ' ConstructionPG__c';//工事名

 		if(OrderByClass=='Class'){
 			strSql += ' ORDER BY Class_PG__c,ConstructionPG__c,propertyName__r.PropertyDivision__c,propertyName__c,RecordType.Description';
 		}else{
 			strSql += ' ORDER BY propertyName__r.PropertyDivision__c,propertyName__c,RecordType.Description,Class_PG__c,ConstructionPG__c';
 		}
 		System.debug(Sdate);
 		System.debug(Edate);
 		System.debug(Jigyou);
        System.debug(strSql);

        return Database.query(strSql); 
    }

     public list<AggregateResult>  searchJigyouGroupByClass(String Jigyou,String bukenKubun,Date Sdate,Date Edate){  
     	system.debug('Sdate:   '+ Sdate);
        String strSql = 'SELECT ';
        strSql += ' propertyName__r.PropertyDivision__c PropertyDivision,';//物件区分
        strSql += ' max(propertyName__r.Name) propertyName,';//物件名
        strSql += ' RecordType.Description Description,';//売上、工事、管理を区別するためのキー
        strSql += ' Class_PG__c,';//分類①
        strSql += ' max(Class2PG__c ) Class2PGName,';//小分類名（PG）
        strSql += ' sum(NewYojituFee__c) RepairCostActual ';//物件別予実費用(PG)

        strSql += ' FROM   CustomOpportunity__c ';
        strSql += ' WHERE  Class2PG__c !=null and Class__c!=null and Class_PG__c!=null  and NewYojituFeeFlg__c=true ';
        if (Jigyou != null) { 
        	strSql += ' AND propertyName__r.ManagingDepartment__c = :Jigyou ';//事業部
        }
        if (bukenKubun != null) { 
        	strSql += ' AND propertyName__r.PropertyDivision__c = :bukenKubun ';//物件区分
        }
        if (Sdate != null) { 
			Datetime sdt = Datetime.newInstance(Sdate.year(), Sdate.month(), Sdate.day());
			strSql+=' AND(';
			strSql+='  KensyuOrkanryouPG__c>='+sdt.format('yyyy-MM-dd'); // 予定年月
			strSql+=' )';
        }
        if (Edate != null) {
			Datetime edt = Datetime.newInstance(Edate.year(), Edate.month(), Edate.day());
			strSql+=' AND(';
			strSql+='  KensyuOrkanryouPG__c<=' + edt.format('yyyy-MM-dd'); // 予定年月
			strSql+=' )';
        }
        
        strSql += ' GROUP BY ';
        strSql += ' propertyName__r.PropertyDivision__c,';//物件区分
 		strSql += ' propertyName__c,';//物件ＩＤ
        strSql += ' RecordType.Description,';//売上、工事、管理を区別するためのキー
 		strSql += ' Class_PG__c';//分類①

 		strSql += ' ORDER BY Class_PG__c,propertyName__r.PropertyDivision__c,propertyName__c,RecordType.Description';
        System.debug(strSql);

        return Database.query(strSql); 
    }
    /*
        是否整除
        @param dividend 被除数
        @param divider  除数
        @return 整除返回true，不整除返回false
    */
    public static Boolean isDivisibility(Integer dividend,Integer divider,Integer kaisu) {
        /* //先将被除数转换成Decimal，否则先计算整数除法结果为Integer类型，然后将整数转换成Decimal
        Decimal resultDecimal = Decimal.valueOf(dividend) / divider;
        //获取结果上线
        Integer resultSeiling = Integer.valueOf(resultDecimal.round(System.RoundingMode.CEILING));
        Integer resultDown = Integer.valueOf(resultDecimal.round(System.RoundingMode.DOWN));
        
        return resultSeiling == resultDown; */
        return dividend>divider*kaisu;
        
        
    }
}
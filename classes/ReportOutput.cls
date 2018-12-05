global class ReportOutput {
	
	public static String taisyous {get;set;}	
	public static String bukenKubun {get;set;}	
	public static String resultMessage1 {get;set;}	
    //public static String ManagingDepartment { get; set; }
   // public static String PropatyDisplay { get; set; }
    public Boolean allChecked { get; set; }
    public Boolean checked1 { get; set; }
	//public static Date Sdate {get;set;}
	//public static Date Edate {get;set;}
    public  CustomOpportunity__c cusopp { get; set; }
   // public static PropertyObj__c proObj { get; set; }
    
    /*
     * コンストラクタ
     * @param    : なし
     * @return   : なし
     */
    public ReportOutput() {
        
        DateTime myDateTime1 = system.now();
		system.debug('コンストラクタ' + myDateTime1.format('MM/dd/yyyy hh:mm:ss.SSSSSS'));
        this.allChecked = true;
		cusopp=new CustomOpportunity__c();         
        ApexPages.getMessages().clear();
    }
	//デフォルトコントロール
	public  ReportOutput(ApexPages.StandardController stdController) {
        
        DateTime myDateTime1 = system.now();
		system.debug('デフォルトコントロール' + myDateTime1.format('MM/dd/yyyy hh:mm:ss.SSSSSS'));
        this.allChecked = true;
		cusopp=(CustomOpportunity__c)stdController.getRecord();
		//system.debug(cusopp.PropatyDisplay__c);        
        ApexPages.getMessages().clear();
	}
    
	//Selectの中身を入れる
	public  List<SelectOption> getKinds() {
	 	List<SelectOption> options = new List<SelectOption>();
        // 対象のオブジェクトに存在する選択リストを取得し、登録済みの選択値を取得します
        Schema.DescribeFieldResult fieldResult = PropertyObj__c.ManagingDepartment__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
        // 選択リストの一番上にデフォルトの選択値を設定
       // options.add(new SelectOption(INITIAL_VALUE, ''));
        options.add(new SelectOption('all', ''));
        
        for( Schema.PicklistEntry e : picklistEntries ){
                options.add(new SelectOption(e.getValue(), e.getLabel()));
        }
	 	return options;
	}
    public  List<SelectOption> getBukens() {
	 	List<SelectOption> options = new List<SelectOption>();
        // 対象のオブジェクトに存在する選択リストを取得し、登録済みの選択値を取得します
        Schema.DescribeFieldResult fieldResult = PropertyObj__c.PropertyDivision__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
        // 選択リストの一番上にデフォルトの選択値を設定
       // options.add(new SelectOption(INITIAL_VALUE, ''));
        options.add(new SelectOption('all', ''));
        
        for( Schema.PicklistEntry e : picklistEntries ){
                options.add(new SelectOption(e.getValue(), e.getLabel()));
        }
	 	return options;
	}
    /*
     * 修繕周期表出力
     */    
    public PageReference departmentOut(){
        
        this.allChecked = true;
        String propatyDisplay = cusopp.PropatyDisplay__c;
        Date myDate1 = cusopp.PropatyDisplay__r.completionDay__c;
        PropertyObj__c  propertyObj = [SELECT Id,completionDay__c FROM   PropertyObj__c  WHERE  Id = :cusopp.PropatyDisplay__c];
        System.debug('propertyObj.completionDay__c:'+propertyObj.completionDay__c);
        Date completionDay = propertyObj.completionDay__c.addYears(60);
        System.debug('propertyObj.completionDay__c:'+completionDay);
       	String completionDay60 = String.valueOf(completionDay.year());
        System.debug('completionDay60:'+completionDay60);
        list<CustomOpportunity__c> customOpportunitys = [SELECT Id,propertyName__c,propertyName__r.completionDay__c,propertyName__r.name
                                                         FROM   CustomOpportunity__c
                                                         WHERE  propertyName__c = :cusopp.PropatyDisplay__c 
                                                         AND    PredYear__c <= :completionDay60];
        System.debug(customOpportunitys.size());
        //resultMessage1 = '修繕周期表のデータが' + customOpportunitys.size() + '件取得されます。' ;
       // System.debug(resultMessage1);
        
        PageReference pageRef = null;
        if(customOpportunitys.size()>0){ 
             System.debug('PDFのVFを指定:id  ' + propatyDisplay);
           	pageRef = Page.RepairCyclePDF;
           // pageRef = Page.RepairCycleExcle;
            pageRef.getParameters().put('id', propatyDisplay);
         	pageRef.setRedirect(true);
            pageRef.getParameters().put('name', customOpportunitys[0].propertyName__r.name);
            pageRef.getParameters().put('completionYear', string.valueOf(customOpportunitys[0].propertyName__r.completionDay__c));
        }
        return pageRef;
    }
    
    /*
     * 修繕周期表出力
     */    
     /*
    public PageReference departmentOutExcle(){
        
        this.allChecked = true;
        String propatyDisplay = cusopp.PropatyDisplay__c;
        Date myDate1 = cusopp.PropatyDisplay__r.completionDay__c;
        PropertyObj__c  propertyObj = [SELECT Id,completionDay__c FROM   PropertyObj__c  WHERE  Id = :cusopp.PropatyDisplay__c];
        System.debug('propertyObj.completionDay__c:'+propertyObj.completionDay__c);
        Date completionDay = propertyObj.completionDay__c.addYears(60);
        System.debug('propertyObj.completionDay__c:'+completionDay);
       	String completionDay60 = String.valueOf(completionDay.year());
        System.debug('completionDay60:'+completionDay60);
        list<CustomOpportunity__c> customOpportunitys = [SELECT Id,propertyName__c,propertyName__r.completionDay__c,propertyName__r.name
                                                         FROM   CustomOpportunity__c
                                                         WHERE  propertyName__c = :cusopp.PropatyDisplay__c 
                                                         AND    PredYear__c <= :completionDay60];
        System.debug(customOpportunitys.size());
        //resultMessage1 = '修繕周期表のデータが' + customOpportunitys.size() + '件取得されます。' ;
       // System.debug(resultMessage1);
        
        PageReference pageRef = null;
        if(customOpportunitys.size()>0){ 
             System.debug('PDFのVFを指定:id  ' + propatyDisplay);
            pageRef = Page.RepairCycleExcle;
            pageRef.getParameters().put('id', propatyDisplay);
         	pageRef.setRedirect(true);
            pageRef.getParameters().put('name', customOpportunitys[0].propertyName__r.name);
            pageRef.getParameters().put('completionYear', string.valueOf(customOpportunitys[0].propertyName__r.completionDay__c));
        }
        return pageRef;
    } 
     */ 
    //事業収支表
    public PageReference  businessUnitOut(){
    	system.debug('123');
    	PageReference pageRef = null;
    	//----データが存在しない場合、印刷しない
    	Date  Sdate=cusopp.Sdate__c;
    	Date  Edate=cusopp.Edate__c;
    	if(bukenKubun=='all'){
    		bukenKubun=null;
    	}
    	system.debug(bukenKubun);
    	ApexPages.currentPage().getParameters().put('Jigyou', taisyous);
    	ApexPages.currentPage().getParameters().put('bukenKubun', bukenKubun);
    	ApexPages.currentPage().getParameters().put('Sdate', String.valueOf(cusopp.Sdate__c));
    	ApexPages.currentPage().getParameters().put('Edate', String.valueOf(cusopp.Edate__c));
    	ReportForJIGYOU re=new ReportForJIGYOU();
    	list<AggregateResult> customOpportunitys =re.searchJigyou(taisyous,bukenKubun,Sdate,Edate,'');
    	if(customOpportunitys==null||customOpportunitys.size()==0){
    		system.debug('333');
    		resultMessage1='該当するデータがありません。';
    		return pageRef;
    	}else{
	        system.debug('123');
	    	pageRef = Page.JigyousyushiPDF;
	        system.debug('222');
	        pageRef.getParameters().put('Jigyou', taisyous);
	        pageRef.getParameters().put('bukenKubun', bukenKubun);
	        system.debug(taisyous);
	        if(cusopp.Sdate__c!=null){
	        	pageRef.getParameters().put('Sdate', String.valueOf(cusopp.Sdate__c));
	        	system.debug('4');
	        }
	        if(cusopp.Edate__c!=null){
	        	pageRef.getParameters().put('Edate', String.valueOf(cusopp.Edate__c));
	        	system.debug('5');
	        }
			system.debug('6');
	       // pageRef.setRedirect(true);
	        return pageRef;
    	}
    }  
}
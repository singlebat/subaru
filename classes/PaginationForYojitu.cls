public abstract class PaginationForYojitu {
	public class leftTable {
		//工事項目
		@AuraEnabled
		public  String Koujikoumoku{ set; get; }
		//周期
		@AuraEnabled
		public  String syuuki{ set; get; }
		//金(html用)
		@AuraEnabled
		public  List<String> moneyList {get;set;}
		//削除フラグ
		@AuraEnabled
		public  Boolean delflag {get;set;}
	}
	//毎ページには20行あります
	public Integer rowsIndex=20;
 
    
}
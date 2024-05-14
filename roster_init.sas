libname catalldb 'L:\IR\consult\OIT\OrgRoster';

%let status = DRAFT ; * DRAFT or FINAL ;
%let snapdate = 01MAY2024 ;

* assign snap and FY SAS macro vars ;
%let snapyear = %sysfunc(year("&snapdate"d)) ;
%let FY=%eval(&snapyear+1) ;
%put &snapyear &FY;

*  set draft or final data ;
%let dsstatus = %sysfunc( ifc(%upcase(&status)=DRAFT,.DEF,%str()) ) ;  * If status=DRAFT, set dsstatus=.DEfund. If NOT DRAFT (i.e., FINAL), set dsstatus= ;
%let lib = E&dsstatus. ;
%let ln = %sysfunc(compress(&lib.,'.')) ;
%put &dsstatus &lib &ln;

proc sql; 
	create table ucb_uuid as
	select * from 
	latestdb.ucb_uuid;
quit;

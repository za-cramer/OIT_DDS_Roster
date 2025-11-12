libname catalldb 'L:\IR\consult\OIT\OrgRoster';

%let status = DRAFT ; * DRAFT or FINAL ;
%let snapdate = 01NOV2025 ;

* assign snap and FY SAS macro vars ;
%let snapyear = %sysfunc(year("&snapdate"d)) ;
%let FY=%eval(&snapyear+1) ;
%let month = %sysfunc(ifc(%index(&snapdate.,NOV), , %substr(&snapdate.,1,5)));
%put &snapyear. &FY. &month.;

*  set draft or final data ;
%let dsstatus = %sysfunc( ifc(%upcase(&status)=DRAFT,.DEF,%str()) ) ;  * If status=DRAFT, set dsstatus=.DEfund. If NOT DRAFT (i.e., FINAL), set dsstatus= ;
%let lib = E&dsstatus. ;
%let ln = %sysfunc(compress(&lib.,'.')) ;
%put &dsstatus &lib &ln ;

/* CIW_BLD_ITS.UCB_UUID */
libname dir oracle user=&ciwuid pw="&ciwpwd" path=CIW 
	schema=CIW_BLD_ITS sql_functions=all multi_datasrc_opt=IN_CLAUSE;

%ciwdb;

proc sql; 
	create table ucb_uuid as
	select distinct
		identikey,
		HREMPLID
	from 
	dir.ucb_uuid
	where HREMPLID IN 
		(SELECT DISTINCT 
			EMPLOYEE_ID 
			FROM CIWDB.HRMS_JOB_TBL
			        where 
   						JOB_EFFECTIVE_DATE <= "&snapdate.:00:00:00"dt     
   					and	JOB_EXPIRATION_DATE > "&snapdate.:00:00:00"dt 
                    and JOB_EMPLMNT_STATUS_CODE IN ('A','P','L')
                    and JOB_DEPT_ID like ('1%'));
quit;

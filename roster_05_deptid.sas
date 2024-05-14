%include 'L:\IR\consult\OIT\OrgRoster\roster_gen.sas';

proc SQL ;
create table ApptFunding1 as 
select distinct
    appt.eid ,
	b.identikey , 
    appt.name,
    appt.posnum ,
    appt.jobcode,
    appt.jobtitle ,
	c.FR_FISCAL_ROLE,
	c.FR_EMPLOYEE_NAME ,
    appt.deptid ,
    appt.deptname ,
    appt.jb_group_code ,
    appt.payfreq   ,
    appt.time      ,
    appt.apptpaytype ,
    fund.fndspdkeycode,
    fund.fndcode,
    fund.fnddeptid,
	fund.fndprojid,
	fund.fndpgmcode
/*    fund.fnddeptname,
    fund.fndpgmcode,
   fund.fndpgmdesc,
    fund.fndprojid,
	fund.fndsubcode,
    fund.fndprojdesc,
	case
		when fund.FndProjSubCode then
            fund.FndProjSubCode
	        when fund.FndPgmSubCode then
            fund.FndPgmSubCode
    end as fndsubcode,
    fund.fndpct,
    appt.InstDir,
    appt.DeanSub,
    appt.Officer,
    appt.Student,
    appt.Big3,
    appt.Big5,
    appt.Instruct,
    appt.Academic,
    appt.Research,
    appt.ClassStaff,
    appt.Exempt*/
from
    &ln.db.appts&snapyear.01MAY appt
    LEFT JOIN &ln.db.gather&snapyear.01MAY  fund
    on appt.posnum = fund.posnum
	LEFT JOIN ucb_uuid b
		on appt.EID = b.HREMPLID
	LEFT JOIN ciwdb.GL_FISCAL_ROLES_TBL c
		on appt.DeptID = c.FR_DEPT_ID
where c.FR_FISCAL_ROLE = 'ORG OFFICER'
order by appt.eid,
	     appt.posnum;
quit ;

* add dept desc ;
proc SQL;
	create table ApptFunding2 as
	select appt.*, 
		   org.DEPT_DESC as FndDeptName
	from ApptFunding1 as appt 
		left join ciwdb.gl_org_tbl as org 
		on appt.FndDeptID = org.Dept_ID
	where org.DEPT_EFFECTIVE_DATE le "&snapdate.:00:00:00"dt
		and org.DEPT_EXPIRATION_DATE gt "&snapdate.:00:00:00"dt ; 
quit ;

* add pgm desc ;
proc SQL;
	create table ApptFunding3 as
	select appt.*, 
		   pgm.PGM_DESC as FndPgmDesc
	from ApptFunding2 as appt 
		left join ciwdb.gl_program_tbl as pgm 
		on appt.FndPgmCode = pgm.PGM_CODE
	where pgm.PGM_EFFECTIVE_DATE le "&snapdate.:00:00:00"dt
		and pgm.PGM_EXPIRATION_DATE gt "&snapdate.:00:00:00"dt ; 
quit ;

* add proj desc ;
proc SQL;
	create table ApptFunding4 as
	select appt.*, 
		   proj.PROJ_DESC as FndProjDesc
	from ApptFunding3 as appt 
		left join ciwdb.gl_project_tbl as proj
		on appt.FndProjID = proj.Proj_ID
	order by appt.eid, appt.posnum
	; 
quit;

* # of positions / person *;
proc SQL ;
	create table PersonNPositions2 as 
	select distinct 
		eid
		, name 
		, count(distinct posnum)    as NPositions        length=3 format=4. label='N positions per employee'
		, 1 / calculated NPositions as PersonPositionPct format=3.2 label='Calculated as 1 over the sum of positions' 
	from ApptFunding4
	group by eid
	order by eid
	;
quit ;
 

proc SQL ;
 create table PositionFndPct&FY. as select
   appt.* ,
   pnp.PersonPositionPct
   from ApptFunding4 as appt
   left join PersonNPositions2 as pnp
    on appt.eid = pnp.eid ;
quit ;


* 25-Feb-2013 (gc): Add dept levels.  Only 3-10 are useful. ;
* 15-Dec-2020 (fff): added DeptLevel11 (eleven) ;
proc SQL;
create table BudgetPosFndPct&FY._deptid as
select
    p.*,
    o.depttree_level03_desc as DeptLevel03,
    o.depttree_level04_desc as DeptLevel04,
    o.depttree_level05_desc as DeptLevel05,
    o.depttree_level06_desc as DeptLevel06,
    o.depttree_level07_desc as DeptLevel07,
    o.depttree_level08_desc as DeptLevel08,
    o.depttree_level09_desc as DeptLevel09,
    o.depttree_level10_desc as DeptLevel10,
    o.depttree_level11_desc as DeptLevel11
from
    PositionFndPct&FY. p left join
    	ciwdb.gl_org_rollup_tree o on
   	 		p.DeptId = o.dept_id and
    o.depttree_effective_date lt "&snapdate.:00:00:00"DT and
    o.depttree_expiration_date ge "&snapdate:00:00:00"DT 
	;
quit;

proc SORT data=BudgetPosFndPct&FY._deptid ;
	by FndSpdKeyCode descending EID ;
run ;

**all fndcode values;
%xlsexport(
    L:\IR\consult\OIT\OrgRoster\BudgetPosFndPct&snapdate._1Row=1PosnumFndSrc_full.xlsx,
    BudgetPosFndPct&FY._deptid ,
    BudgetPosFndPct&FY._deptid
    );

# OIT_DDS_Roster
UCB Org Chart for DDS Reporting

L Drive File Location: L:\IR\consult\OIT\OrgRoster

init file (update dates / working file etc): roster_init.sas

Two different roster templates:
1. DeptID
2. Fnd_Dept

DeptID (1) matches org officer based on employee position location. For example, If employee position is 
located in Department 10769, then org officer (sourced from ARTEMIS.GL_FISCAL_ROLES_TBL) is matched based on job location.

Fnd_Dept (2) matches org officer based on employee funding department (sourced from IR gather file). For example, if employee position is funded from 11146, then org officer is matched based on funding department ID. Several FndDeptIDs can exist within the same unit. For example, Department 10769 (LEEDS BUSINESS SALARIES) contains several Org Officers. 

Because of the different method, DeptID (1) has 33 unique OrgOfficers across all employees. Whereas the Fnd_Dept(2) method has 42. 

A good example is EID 100527 (TIN TIN SU). 

If opting to go with DeptID, duplicates will occur but can be removed.

insert into stn.project ( project_id , project_name , folder_id , project_type_id ) values ( 1 , 'StandardiseReferenceData'       , ( select folder_id from stn.execution_folder where folder_name = 'custom' ) , ( select project_type_id from stn.project_type where project_type_cd = 'STD' ) );
insert into stn.project ( project_id , project_name , folder_id , project_type_id ) values ( 2 , 'mah_common'                     , ( select folder_id from stn.execution_folder where folder_name = 'core' )   , ( select project_type_id from stn.project_type where project_type_cd = 'CR' ) );
insert into stn.project ( project_id , project_name , folder_id , project_type_id ) values ( 3 , 'mah_fdr_trans'                  , ( select folder_id from stn.execution_folder where folder_name = 'core' )   , ( select project_type_id from stn.project_type where project_type_cd = 'CR' ) );
insert into stn.project ( project_id , project_name , folder_id , project_type_id ) values ( 4 , 'DSRReferenceData'               , ( select folder_id from stn.execution_folder where folder_name = 'custom' ) , ( select project_type_id from stn.project_type where project_type_cd = 'CU' ) );
insert into stn.project ( project_id , project_name , folder_id , project_type_id ) values ( 5 , 'StandardiseInsurancePolicyData' , ( select folder_id from stn.execution_folder where folder_name = 'custom' ) , ( select project_type_id from stn.project_type where project_type_cd = 'STD' ) );
commit;
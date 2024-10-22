-- create parameter reference data
delete from stn.param_set_item where param_set_id in (11);
delete from stn.step_run_param where step_run_sid in (select step_run_sid from stn.step_run where step_id in (56));
delete from stn.step_run_state where step_run_sid in (select step_run_sid from stn.step_run where step_id in (56));
delete from stn.step_run where step_id in (56);
delete from stn.step where step_cd like 'parchiveSLR%';
delete from stn.param_set where param_set_id in (11);
delete from stn.step_run where step_id in (56);
insert into stn.param_set ( param_set_id , param_set_cd ) values ( 11 , 'utilities-slr1' );
insert into stn.param_set_item ( param_set_id , param_set_item_cd , param_set_item_val ) values ( ( select param_set_id from stn.param_set where param_set_cd = 'utilities-slr1' )                    , 'lpg_id'             , '2' );
insert into stn.param_set_item ( param_set_id , param_set_item_cd , param_set_item_val ) values ( ( select param_set_id from stn.param_set where param_set_cd = 'utilities-slr1' )                    , 'archive_group'      , '3' );
insert into stn.step ( step_id , step_cd , process_id , param_set_id ) values ( 56 , 'parchiveSLR1', ( select process_id from stn.process where project_id = ( select project_id from stn.project where project_name = 'Utilities'                      and folder_id = ( select folder_id from stn.execution_folder where folder_name = 'custom' ) ) and process_name = 'parchive'                                 and process_type_id = ( select process_type_id from stn.process_type where process_type_cd = 'Microflow' ) ) , ( select param_set_id from stn.param_set where param_set_cd = 'utilities-slr1' ) );
commit;

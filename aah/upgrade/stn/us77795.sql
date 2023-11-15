delete from stn.step_run_state where step_run_sid in (
select step_run_sid from stn.step_run where step_id = 57);
delete from stn.step_run_status where step_run_status_id in (
select step_run_status_id from stn.step_run_state where step_run_sid in (
select step_run_sid from stn.step_run where step_id = 57));
delete from stn.step_run_param where step_run_sid in (
select step_run_sid from stn.step_run where step_id = 57);
delete from stn.step_run where step_id = 57;
delete from stn.step where step_id=57;
delete from stn.process where process_id=53;

Insert into stn.PROCESS
   (PROCESS_ID, PROJECT_ID, PROCESS_NAME, PROCESS_TYPE_ID, INPUT_NODE_NAME)
 Values
   (53, 6, 'pDeleteSLRPartitions', 1, 'Source');

Insert into stn.STEP
   (STEP_ID, STEP_CD, PROCESS_ID, PARAM_SET_ID)
 Values
   (57, 'pDeleteSLRPartitions', 53, 6);
commit;
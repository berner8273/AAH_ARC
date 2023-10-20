delete from stn.step where step_id=56;
delete from stn.process where process_id=53;


Insert into stn.PROCESS
   (PROCESS_ID, PROJECT_ID, PROCESS_NAME, PROCESS_TYPE_ID, INPUT_NODE_NAME)
 Values
   (53, 6, 'pDeleteSLRPartitions', 1, 'Source');

Insert into stn.STEP
   (STEP_ID, STEP_CD, PROCESS_ID, PARAM_SET_ID)
 Values
   (56, 'pDeleteSLRPartitions', 53, 6);
   commit;
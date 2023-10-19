@@../aahCustom/aahStandardisation/src/main/db/procedures/fdr/pr_delete_slr_partitions.prc;

delete from fdr.fr_batch_schedule where bs_object_name ='pDeleteSLRPartitions';
Insert into fdr.FR_BATCH_SCHEDULE
   (BS_OBJECT_NAME, BS_STAGE, BS_ORDER_IN_STAGE, BS_STAGE_OWNER, BS_STATUS, 
    BS_OBJECT_TYPE, LPG_ID, BS_STEP_ID, BS_CREATED_BY, BS_UPDATED_BY, 
    BS_PROCESSED_BY, BS_THRESHOLD_IS_PERCENT)
 Values
   ('pDeleteSLRPartitions', 'SLR', 1, 'SLR', 'C', 
    'R', 2, 162, 'APTITUDE', 'APTITUDE', 
    'APTITUDE', 'N');

commit;
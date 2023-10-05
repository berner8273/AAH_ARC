delete from SLR.SLR_PROCESS_SOURCE where SPS_SOURCE_NAME ='BMRETAINEDEARNINGSEBA04';
delete from SLR.SLR_PROCESS_CONFIG_DETAIL where pcd_pc_config='PLRETEARNINGS04';
delete from SLR.SLR_PROCESS_CONFIG where pc_config='PLRETEARNINGS04';

Insert into SLR.SLR_PROCESS_CONFIG
   (PC_CONFIG, PC_P_PROCESS, PC_JT_TYPE, PC_FAK_EBA_FLAG, PC_AGGREGATION, 
    PC_METHOD)
 Values
   ('PLRETEARNINGS04', 'PLRETEARNINGS', 'PLRETEARNINGS', 'E', 'L', 
    'DEFAULT');
Insert into SLR.SLR_PROCESS_CONFIG_DETAIL
   (PCD_PC_CONFIG, PCD_PC_P_PROCESS, PCD_CONFIG_TYPE, PCD_DESCRIPTION, PCD_ENTITY, 
    PCD_ACCOUNT, PCD_SEGMENT_1, PCD_SEGMENT_2, PCD_SEGMENT_3, PCD_SEGMENT_4, 
    PCD_SEGMENT_5, PCD_SEGMENT_6, PCD_SEGMENT_7, PCD_SEGMENT_8, PCD_SEGMENT_9, 
    PCD_SEGMENT_10, PCD_ATTRIBUTE_1, PCD_ATTRIBUTE_2, PCD_ATTRIBUTE_3, PCD_ATTRIBUTE_4, 
    PCD_ATTRIBUTE_5)
 Values
   ('PLRETEARNINGS04', 'PLRETEARNINGS', 'Adjust', 'P&L Retained Earnings (Adjust)', '**SOURCE**', 
    '**SOURCE**', '**SOURCE**', '**SOURCE**', '**SOURCE**', '**SOURCE**', 
    '**SOURCE**', '**SOURCE**', '**SOURCE**', '**SOURCE**', '**SOURCE**', 
    '**SOURCE**', '**SOURCE**', '**SOURCE**', '**SOURCE**', '**SOURCE**', 
    '**SOURCE**');
Insert into SLR.SLR_PROCESS_CONFIG_DETAIL
   (PCD_PC_CONFIG, PCD_PC_P_PROCESS, PCD_CONFIG_TYPE, PCD_DESCRIPTION, PCD_ENTITY, 
    PCD_ACCOUNT, PCD_SEGMENT_1, PCD_SEGMENT_2, PCD_SEGMENT_3, PCD_SEGMENT_4, 
    PCD_SEGMENT_5, PCD_SEGMENT_6, PCD_SEGMENT_7, PCD_SEGMENT_8, PCD_SEGMENT_9, 
    PCD_SEGMENT_10, PCD_ATTRIBUTE_1, PCD_ATTRIBUTE_2, PCD_ATTRIBUTE_3, PCD_ATTRIBUTE_4, 
    PCD_ATTRIBUTE_5)
 Values
   ('PLRETEARNINGS04', 'PLRETEARNINGS', 'Offset', 'P&L Retained Earnings (Offset)', '**SOURCE**', 
    '31580012-01', '**SOURCE**', '**SOURCE**', '**SOURCE**', '**SOURCE**', 
    '**SOURCE**', '**SOURCE**', '**SOURCE**', '**SOURCE**', '**SOURCE**', 
    '**SOURCE**', '**SOURCE**', '**SOURCE**', '**SOURCE**', '**SOURCE**', 
    '**SOURCE**');
COMMIT;

Insert into SLR.SLR_PROCESS_SOURCE
   (SPS_SOURCE_NAME, SPS_FAK_EBA_FLAG, SPS_DB_OBJECT_NAME, SPS_DB_OBJECT_NAME2, SPS_ACTIVE, 
    SPS_INPUT_BY, SPS_INPUT_TIME)
 Values
   ('BMRETAINEDEARNINGSEBA04', 'E', 'vBM_AG_RetainedEarningsEBA04', 'vBMRetainedEarnings', 'A', 
    'SLR', TO_DATE('03/20/2018 00:00:00', 'MM/DD/YYYY HH24:MI:SS'));

COMMIT;
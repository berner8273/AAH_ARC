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

commit;

CREATE OR REPLACE FORCE VIEW SLR.VBM_AG_RETAINEDEARNINGSEBA04
(
   KEY_ID,
   FAK_ID,
   BALANCE_TYPE,
   ENTITY,
   BALANCE_DATE,
   EPG_ID,
   TRAN_LTD_BALANCE,
   BASE_LTD_BALANCE,
   LOCAL_LTD_BALANCE,
   TRAN_YTD_BALANCE,
   BASE_YTD_BALANCE,
   LOCAL_YTD_BALANCE,
   TRAN_MTD_BALANCE,
   BASE_MTD_BALANCE,
   LOCAL_MTD_BALANCE,
   PERIOD_MONTH,
   PERIOD_YEAR,
   PERIOD_LTD
)
   BEQUEATH DEFINER
AS
   SELECT /*+ parallel(slr_eba_daily_balances )*/
         edb_eba_id AS key_id,
          edb_fak_id AS fak_id,
          edb_balance_type AS balance_type,
          edb_entity AS entity,
          edb_balance_date AS balance_date,
          edb_epg_id AS epg_id,
          edb_tran_ltd_balance AS tran_ltd_balance,
          edb_base_ltd_balance AS base_ltd_balance,
          edb_local_ltd_balance AS local_ltd_balance,
          edb_tran_ytd_balance AS tran_ytd_balance,
          edb_base_ytd_balance AS base_ytd_balance,
          edb_local_ytd_balance AS local_ytd_balance,
          edb_tran_mtd_balance AS tran_mtd_balance,
          edb_base_mtd_balance AS base_mtd_balance,
          edb_local_mtd_balance AS local_mtd_balance,
          edb_period_month AS period_month,
          edb_period_year AS period_year,
          edb_period_ltd AS period_ltd
     FROM slr_eba_daily_balances edb
          INNER JOIN slr_fak_combinations fc
             ON (    edb.edb_epg_id = fc.fc_epg_id
                 AND edb.edb_fak_id = fc.fc_fak_id)
          INNER JOIN slr_entities ent ON (edb.edb_entity = ent.ent_entity)
          INNER JOIN slr_entity_accounts ea
             ON (    ea.ea_entity_set = ent.ent_accounts_set
                 AND ea.ea_account = fc.fc_account)
    WHERE     ea.ea_account_type_flag = 'P'
          AND edb.edb_balance_type = 50
          AND ea_account LIKE '31580017%';


GRANT SELECT ON SLR.VBM_AG_RETAINEDEARNINGSEBA04 TO AAH_READ_ONLY;

commit;
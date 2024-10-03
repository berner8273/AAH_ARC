DROP VIEW RDR.RRV_AG_SLR_EBA_DAILY_BALANCES;

/* Formatted on 10/02/2024 4:46:34 PM (QP5 v5.252.13127.32847) */
CREATE OR REPLACE FORCE VIEW RDR.RRV_AG_SLR_EBA_DAILY_BALANCES
(
   EDB_FAK_ID,
   EDB_EBA_ID,
   EDB_BALANCE_DATE,
   EDB_BALANCE_TYPE,
   FC_ENTITY,
   FC_ACCOUNT,
   TRAN_CCY,
   RPT_CCY,
   FUNC_CCY,
   LEDGER_CD,
   BASIS_CD,
   DEPT_CD,
   AFFILIATE_LE_ID,
   EXECUTION_TYPE,
   BUSINESS_TYPE,
   CHARTFIELD_1,
   POLICY_ID,
   STREAM_ID,
   TAX_JURISDICTION_CD,
   PREMIUM_TYPE,
   EVENT_TYPE,
   GROSS_STREAM_OWNER,
   OWNER_ENTITY,
   INT_EXT_COUNTERPARTY,
   EDB_TRAN_DAILY_MOVEMENT,
   EDB_TRAN_MTD_ACTIVITY,
   EDB_TRAN_QTD_ACTIVITY,
   EDB_TRAN_YTD_ACTIVITY,
   EDB_TRAN_ITD_BALANCE,
   EDB_RPT_DAILY_MOVEMENT,
   EDB_RPT_MTD_ACTIVITY,
   EDB_RPT_QTD_ACTIVITY,
   EDB_RPT_YTD_ACTIVITY,
   EDB_RPT_ITD_BALANCE,
   EDB_FUNC_DAILY_MOVEMENT,
   EDB_FUNC_MTD_ACTIVITY,
   EDB_FUNC_QTD_ACTIVITY,
   EDB_FUNC_YTD_ACTIVITY,
   EDB_FUNC_ITD_BALANCE,
   EDB_TRAN_BOP_MTD_BALANCE,
   EDB_TRAN_BOP_QTD_BALANCE,
   EDB_TRAN_BOP_YTD_BALANCE,
   EDB_RPT_BOP_MTD_BALANCE,
   EDB_RPT_BOP_QTD_BALANCE,
   EDB_RPT_BOP_YTD_BALANCE,
   EDB_FUNC_BOP_MTD_BALANCE,
   EDB_FUNC_BOP_QTD_BALANCE,
   EDB_FUNC_BOP_YTD_BALANCE,
   EDB_EPG_ID,
   EDB_PERIOD_MONTH,
   EDB_PERIOD_YEAR,
   EDB_PERIOD_ITD,
   EDB_PROCESS_ID,
   EDB_AMENDED_ON
)
   BEQUEATH DEFINER
AS
   SELECT db.edb_fak_id,
          db.edb_eba_id,
          db.edb_balance_date,
          db.edb_balance_type,
          fc.fc_entity,
          fc.fc_account,
          fc.fc_ccy tran_ccy,
          ent.ent_base_ccy rpt_ccy,
          ent.ent_local_ccy func_ccy,
          fc.ledger_cd,
          fc.basis_cd,
          fc.dept_cd,
          fc.affiliate_le_id,
          fc.execution_typ execution_type,
          fc.business_typ business_type,
          fc.chartfield_1,
          fc.policy_id,
          ec.stream_id,
          ec.tax_jurisdiction_cd,
          ec.premium_typ premium_type,
          ec.event_type,
          NULL gross_stream_owner,
          NULL owner_entity,
          NULL int_ext_counterparty,
          db.edb_tran_daily_movement,
          db.edb_tran_mtd_balance edb_tran_mtd_activity,
          db.edb_tran_qtd_balance edb_tran_qtd_activity,
          db.edb_tran_ytd_balance edb_tran_ytd_activity,
          db.edb_tran_ltd_balance edb_tran_itd_balance,
          db.edb_base_daily_movement edb_rpt_daily_movement,
          db.edb_base_mtd_balance edb_rpt_mtd_activity,
          db.edb_base_qtd_balance edb_rpt_qtd_activity,
          db.edb_base_ytd_balance edb_rpt_ytd_activity,
          db.edb_base_ltd_balance edb_rpt_itd_balance,
          db.edb_local_daily_movement edb_func_daily_movement,
          db.edb_local_mtd_balance edb_func_mtd_activity,
          db.edb_local_qtd_balance edb_func_qtd_activity,
          db.edb_local_ytd_balance edb_func_ytd_activity,
          db.edb_local_ltd_balance edb_func_itd_balance,
          eba_bop.edb_tran_bop_mtd_balance edb_tran_bop_mtd_balance,
          eba_bop.edb_tran_bop_qtd_balance edb_tran_bop_qtd_balance,
          eba_bop.edb_tran_bop_ytd_balance edb_tran_bop_ytd_balance,
          eba_bop.edb_base_bop_mtd_balance edb_rpt_bop_mtd_balance,
          eba_bop.edb_base_bop_qtd_balance edb_rpt_bop_qtd_balance,
          eba_bop.edb_base_bop_ytd_balance edb_rpt_bop_ytd_balance,
          eba_bop.edb_local_bop_mtd_balance edb_func_bop_mtd_balance,
          eba_bop.edb_local_bop_qtd_balance edb_func_bop_qtd_balance,
          eba_bop.edb_local_bop_ytd_balance edb_func_bop_ytd_balance,
          db.edb_epg_id,
          db.edb_period_month,
          db.edb_period_year,
          db.edb_period_ltd edb_period_itd,
          db.edb_process_id,
          db.edb_amended_on
     FROM slr.slr_eba_daily_balances db
          JOIN rdr.rrv_ag_slr_eba_combinations ec
             ON db.edb_eba_id = ec.ec_eba_id AND db.edb_epg_id = ec.ec_epg_id
          JOIN rdr.rrv_ag_slr_fak_combinations fc
             ON ec.ec_fak_id = fc.fc_fak_id AND ec.ec_epg_id = fc.fc_epg_id
          LEFT JOIN slr.slr_eba_bop_amounts eba_bop
             ON     db.edb_fak_id = eba_bop.edb_fak_id
                AND db.edb_eba_id = eba_bop.edb_eba_id
                AND db.edb_balance_date = eba_bop.edb_balance_date
                AND db.edb_balance_type = eba_bop.edb_balance_type
          JOIN slr.slr_entities ent ON fc.fc_entity = ent.ent_entity;


GRANT SELECT ON RDR.RRV_AG_SLR_EBA_DAILY_BALANCES TO AAH_RDR;

GRANT SELECT ON RDR.RRV_AG_SLR_EBA_DAILY_BALANCES TO AAH_READ_ONLY;

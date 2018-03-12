create or replace view rdr.rrv_ag_slr_fak_daily_balances
as
   select
          db.fdb_fak_id
        , db.fdb_balance_date
        , db.fdb_balance_type
        , fc.fc_entity
        , fc.fc_account
        , fc.fc_ccy                           tran_ccy
        , ent.ent_base_ccy                    rpt_ccy
        , ent.ent_local_ccy                   func_ccy
        , fc.ledger_cd
        , fc.basis_cd
        , fc.dept_cd
        , fc.affiliate_le_id
        , fc.execution_typ                    execution_type
        , fc.business_typ                     business_type
        , fc.chartfield_1
        , fc.policy_id
        , db.fdb_tran_daily_movement
        , db.fdb_tran_mtd_balance             fdb_tran_mtd_activity
        , db.fdb_tran_qtd_balance             fdb_tran_qtd_activity
        , db.fdb_tran_ytd_balance             fdb_tran_ytd_activity
        , db.fdb_tran_ltd_balance             fdb_tran_itd_balance
        , db.fdb_base_daily_movement          fdb_rpt_daily_movement
        , db.fdb_base_mtd_balance             fdb_rpt_mtd_activity
        , db.fdb_base_qtd_balance             fdb_rpt_qtd_activity
        , db.fdb_base_ytd_balance             fdb_rpt_ytd_activity
        , db.fdb_base_ltd_balance             fdb_rpt_itd_balance
        , db.fdb_local_daily_movement         fdb_func_daily_movement
        , db.fdb_local_mtd_balance            fdb_func_mtd_activity
        , db.fdb_local_qtd_balance            fdb_func_qtd_activity
        , db.fdb_local_ytd_balance            fdb_func_ytd_activity
        , db.fdb_local_ltd_balance            fdb_func_itd_balance
        , fak_bop.fdb_tran_bop_mtd_balance    fdb_tran_bop_mtd_balance
        , fak_bop.fdb_tran_bop_qtd_balance    fdb_tran_bop_qtd_balance
        , fak_bop.fdb_tran_bop_ytd_balance    fdb_tran_bop_ytd_balance
        , fak_bop.fdb_base_bop_mtd_balance    fdb_rpt_bop_mtd_balance
        , fak_bop.fdb_base_bop_qtd_balance    fdb_rpt_bop_qtd_balance
        , fak_bop.fdb_base_bop_ytd_balance    fdb_rpt_bop_ytd_balance
        , fak_bop.fdb_local_bop_mtd_balance   fdb_func_bop_mtd_balance
        , fak_bop.fdb_local_bop_qtd_balance   fdb_func_bop_qtd_balance
        , fak_bop.fdb_local_bop_ytd_balance   fdb_func_bop_ytd_balance
        , db.fdb_epg_id
        , db.fdb_period_month
        , db.fdb_period_year
        , db.fdb_period_ltd                   fdb_period_itd
        , db.fdb_process_id
        , db.fdb_amended_on
     from
          slr.slr_fak_daily_balances           db
     join rdr.rrv_ag_slr_fak_combinations      fc
          on db.fdb_fak_id = fc.fc_fak_id 
         and db.fdb_epg_id = fc.fc_epg_id
left join slr.slr_fak_bop_amounts              fak_bop
          on db.fdb_fak_id       = fak_bop.fdb_fak_id
         and db.fdb_balance_date = fak_bop.fdb_balance_date
         and db.fdb_balance_type = fak_bop.fdb_balance_type
     join slr.slr_entities                     ent
          on fc.fc_entity = ent.ent_entity
;
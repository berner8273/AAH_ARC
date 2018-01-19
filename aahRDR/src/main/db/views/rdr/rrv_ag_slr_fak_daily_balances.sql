create or replace view rdr.rrv_ag_slr_fak_daily_balances
as
   select
          db.fdb_fak_id
        , db.fdb_balance_date
        , db.fdb_balance_type
        , fc.ledger_cd
        , fc.basis_cd
        , fc.dept_cd
        , fc.affiliate_le_id
        , fc.execution_typ
        , fc.business_typ
        , fc.chartfield_1
        , db.fdb_tran_daily_movement
        , db.fdb_tran_mtd_balance
        , db.fdb_tran_qtd_balance
        , db.fdb_tran_ytd_balance
        , db.fdb_tran_ltd_balance
        , db.fdb_base_daily_movement          fdb_rpt_daily_movement
        , db.fdb_base_mtd_balance             fdb_rpt_mtd_balance
        , db.fdb_base_qtd_balance             fdb_rpt_qtd_balance
        , db.fdb_base_ytd_balance             fdb_rpt_ytd_balance
        , db.fdb_base_ltd_balance             fdb_rpt_ltd_balance
        , db.fdb_local_daily_movement         fdb_func_daily_movement
        , db.fdb_local_mtd_balance            fdb_func_mtd_balance
        , db.fdb_local_qtd_balance            fdb_func_qtd_balance
        , db.fdb_local_ytd_balance            fdb_func_ytd_balance
        , db.fdb_local_ltd_balance            fdb_func_ltd_balance
        , fak_bop.fdb_tran_bop_mtd_balance    fdb_tran_bop_mtd_balance
        , fak_bop.fdb_tran_bop_qtd_balance    fdb_tran_bop_qtd_balance
        , fak_bop.fdb_tran_bop_ytd_balance    fdb_tran_bop_ytd_balance
        , fak_bop.fdb_base_bop_mtd_balance    fdb_rpt_bop_mtd_balance
        , fak_bop.fdb_base_bop_qtd_balance    fdb_rpt_bop_qtd_balance
        , fak_bop.fdb_base_bop_ytd_balance    fdb_rpt_bop_ytd_balance
        , fak_bop.fdb_local_bop_mtd_balance   fdb_func_bop_mtd_balance
        , fak_bop.fdb_local_bop_qtd_balance   fdb_func_bop_qtd_balance
        , fak_bop.fdb_local_bop_ytd_balance   fdb_func_bop_ytd_balance
        , db.fdb_entity
        , db.fdb_epg_id
        , db.fdb_period_month
        , db.fdb_period_year
        , db.fdb_period_ltd
        , db.fdb_process_id
        , db.fdb_amended_on
     from slr.slr_fak_daily_balances db
          join rdr.rrv_ag_slr_fak_combinations fc
             on db.fdb_fak_id = fc.fc_fak_id 
     left join slr.slr_fak_bop_amounts fak_bop
             on db.fdb_fak_id = fak_bop.fdb_fak_id
            and db.fdb_balance_date = fak_bop.fdb_balance_date
            and db.fdb_balance_type = fak_bop.fdb_balance_type
;

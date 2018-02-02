create or replace view rdr.rrv_ag_slr_fak_daily_balances
as
   select
          fdb_fak_id
        , fdb_balance_date
        , fdb_balance_type
        , fc.ledger_cd
        , fc.basis_cd
        , fc.dept_cd
        , fc.affiliate_le_id
        , fc.execution_typ
        , fc.business_typ
        , fc.chartfield_1
        , fdb_tran_daily_movement
        , fdb_tran_mtd_balance
        , fdb_tran_qtd_balance
        , fdb_tran_ytd_balance
        , fdb_tran_ltd_balance
        , fdb_base_daily_movement       fdb_rpt_daily_movement
        , fdb_base_mtd_balance          fdb_rpt_mtd_balance
        , fdb_base_qtd_balance          fdb_rpt_qtd_balance
        , fdb_base_ytd_balance          fdb_rpt_ytd_balance
        , fdb_base_ltd_balance          fdb_rpt_ltd_balance
        , fdb_local_daily_movement      fdb_func_daily_movement
        , fdb_local_mtd_balance         fdb_func_mtd_balance
        , fdb_local_qtd_balance         fdb_func_qtd_balance
        , fdb_local_ytd_balance         fdb_func_ytd_balance
        , fdb_local_ltd_balance         fdb_func_ltd_balance
        , cast (null as number(38,3))   fdb_tran_bop_mtd_balance
        , cast (null as number(38,3))   fdb_tran_bop_qtd_balance
        , cast (null as number(38,3))   fdb_tran_bop_ytd_balance
        , cast (null as number(38,3))   fdb_rpt_bop_mtd_balance
        , cast (null as number(38,3))   fdb_rpt_bop_qtd_balance
        , cast (null as number(38,3))   fdb_rpt_bop_ytd_balance
        , cast (null as number(38,3))   fdb_func_bop_mtd_balance
        , cast (null as number(38,3))   fdb_func_bop_qtd_balance
        , cast (null as number(38,3))   fdb_func_bop_ytd_balance
        , fdb_entity
        , fdb_epg_id
        , fdb_period_month
        , fdb_period_year
        , fdb_period_ltd
        , fdb_process_id
        , fdb_amended_on
     from slr.slr_fak_daily_balances db
          join rdr.rrv_ag_slr_fak_combinations fc
             on db.fdb_fak_id = fc.fc_fak_id  and db.fdb_epg_id = fc.fc_epg_id
;

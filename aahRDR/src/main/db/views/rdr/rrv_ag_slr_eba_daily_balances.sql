create or replace view rdr.rrv_ag_slr_eba_daily_balances
as
   select
          db.edb_fak_id
        , db.edb_eba_id
        , fc.ledger_cd
        , fc.policy_id
        , ec.stream_id
        , fc.affiliate_le_id
        , ec.tax_jurisdiction_cd
        , db.edb_balance_date
        , db.edb_balance_type
        , db.edb_tran_daily_movement
        , db.edb_tran_mtd_balance
        , db.edb_tran_qtd_balance
        , db.edb_tran_ytd_balance
        , db.edb_tran_ltd_balance
        , db.edb_base_daily_movement          edb_rpt_daily_movement
        , db.edb_base_mtd_balance             edb_rpt_mtd_balance
        , db.edb_base_qtd_balance             edb_rpt_qtd_balance
        , db.edb_base_ytd_balance             edb_rpt_ytd_balance
        , db.edb_base_ltd_balance             edb_rpt_ltd_balance
        , db.edb_local_daily_movement         edb_func_daily_movement
        , db.edb_local_mtd_balance            edb_func_mtd_balance
        , db.edb_local_qtd_balance            edb_func_qtd_balance
        , db.edb_local_ytd_balance            edb_func_ytd_balance
        , db.edb_local_ltd_balance            edb_func_ltd_balance
        , eba_bop.edb_tran_bop_mtd_balance    edb_tran_bop_mtd_balance
        , eba_bop.edb_tran_bop_qtd_balance    edb_tran_bop_qtd_balance
        , eba_bop.edb_tran_bop_ytd_balance    edb_tran_bop_ytd_balance
        , eba_bop.edb_base_bop_mtd_balance    edb_rpt_bop_mtd_balance
        , eba_bop.edb_base_bop_qtd_balance    edb_rpt_bop_qtd_balance
        , eba_bop.edb_base_bop_ytd_balance    edb_rpt_bop_ytd_balance
        , eba_bop.edb_local_bop_mtd_balance   edb_func_bop_mtd_balance
        , eba_bop.edb_local_bop_qtd_balance   edb_func_bop_qtd_balance
        , eba_bop.edb_local_bop_ytd_balance   edb_func_bop_ytd_balance
        , db.edb_entity
        , db.edb_epg_id
        , db.edb_period_month
        , db.edb_period_year
        , db.edb_period_ltd
        , db.edb_process_id
        , db.edb_amended_on
     from
          slr.slr_eba_daily_balances         db
     join rdr.rrv_ag_slr_eba_combinations    ec
          on db.edb_eba_id = ec.ec_eba_id
         and db.edb_epg_id = ec.ec_epg_id
     join rdr.rrv_ag_slr_fak_combinations    fc
          on ec.ec_fak_id = fc.fc_fak_id
         and ec.ec_epg_id = fc.fc_epg_id
left join slr.slr_eba_bop_amounts            eba_bop
          on db.edb_fak_id       = eba_bop.edb_fak_id
         and db.edb_eba_id       = eba_bop.edb_eba_id
         and db.edb_balance_date = eba_bop.edb_balance_date
         and db.edb_balance_type = eba_bop.edb_balance_type
;
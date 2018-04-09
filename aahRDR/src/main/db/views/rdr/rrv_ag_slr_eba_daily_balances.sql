create or replace view rdr.rrv_ag_slr_eba_daily_balances
as
   select
          db.edb_fak_id
        , db.edb_eba_id
        , db.edb_balance_date
        , db.edb_balance_type
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
        , ec.stream_id
        , ec.tax_jurisdiction_cd
        , ec.premium_typ                      premium_type
        , ec.event_type
        , jl_reference.gross_stream_owner
        , jl_reference.owner_entity
        , jl_reference.int_ext_counterparty
        , db.edb_tran_daily_movement
        , db.edb_tran_mtd_balance             edb_tran_mtd_activity
        , db.edb_tran_qtd_balance             edb_tran_qtd_activity
        , db.edb_tran_ytd_balance             edb_tran_ytd_activity
        , db.edb_tran_ltd_balance             edb_tran_itd_balance
        , db.edb_base_daily_movement          edb_rpt_daily_movement
        , db.edb_base_mtd_balance             edb_rpt_mtd_activity
        , db.edb_base_qtd_balance             edb_rpt_qtd_activity
        , db.edb_base_ytd_balance             edb_rpt_ytd_activity
        , db.edb_base_ltd_balance             edb_rpt_itd_balance
        , db.edb_local_daily_movement         edb_func_daily_movement
        , db.edb_local_mtd_balance            edb_func_mtd_activity
        , db.edb_local_qtd_balance            edb_func_qtd_activity
        , db.edb_local_ytd_balance            edb_func_ytd_activity
        , db.edb_local_ltd_balance            edb_func_itd_balance
        , eba_bop.edb_tran_bop_mtd_balance    edb_tran_bop_mtd_balance
        , eba_bop.edb_tran_bop_qtd_balance    edb_tran_bop_qtd_balance
        , eba_bop.edb_tran_bop_ytd_balance    edb_tran_bop_ytd_balance
        , eba_bop.edb_base_bop_mtd_balance    edb_rpt_bop_mtd_balance
        , eba_bop.edb_base_bop_qtd_balance    edb_rpt_bop_qtd_balance
        , eba_bop.edb_base_bop_ytd_balance    edb_rpt_bop_ytd_balance
        , eba_bop.edb_local_bop_mtd_balance   edb_func_bop_mtd_balance
        , eba_bop.edb_local_bop_qtd_balance   edb_func_bop_qtd_balance
        , eba_bop.edb_local_bop_ytd_balance   edb_func_bop_ytd_balance
        , db.edb_epg_id
        , db.edb_period_month
        , db.edb_period_year
        , db.edb_period_ltd                   edb_period_itd
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
     join slr.slr_entities                     ent
          on fc.fc_entity = ent.ent_entity
     join (
            select jl.jl_eba_id
                 , jl.jl_epg_id
                 , min(jl.jl_reference_2) gross_stream_owner
                 , min(jl.jl_reference_4) owner_entity
                 , min(jl.jl_reference_7) int_ext_counterparty
              from slr.slr_jrnl_lines jl
          group by jl.jl_eba_id
                 , jl.jl_epg_id
          ) jl_reference
          on db.edb_eba_id = jl_reference.jl_eba_id
         and db.edb_epg_id = jl_reference.jl_epg_id
;
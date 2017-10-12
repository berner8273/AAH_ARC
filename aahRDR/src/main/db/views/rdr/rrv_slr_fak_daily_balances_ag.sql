create or replace force view rdr.rrv_slr_fak_daily_balances_ag
as
   select fdb_fak_id,
          fdb_balance_date,
          fdb_balance_type,
          fc.ledger_cd,
          fc.basis_cd,
          fc.dept_cd,
          fc.affiliate_le_id,
          fc.execution_typ,
          fc.business_typ,
          fc.chartfield_1,
          jl.jl_reference_2 accident_yr,
          jl.jl_reference_1 underwiting_yr,
          fdb_tran_daily_movement,
          fdb_tran_mtd_balance,
          fdb_tran_ytd_balance,
          fdb_tran_ltd_balance,
          fdb_base_daily_movement,
          fdb_base_mtd_balance,
          fdb_base_ytd_balance,
          fdb_base_ltd_balance,
          fdb_local_daily_movement,
          fdb_local_mtd_balance,
          fdb_local_ytd_balance,
          fdb_local_ltd_balance,
          fdb_entity,
          fdb_epg_id,
          fdb_period_month,
          fdb_period_year,
          fdb_period_ltd,
          fdb_process_id,
          fdb_amended_on
     from slr.slr_fak_daily_balances db
          join rdr.rrv_slr_fak_combinations_ag fc
             on db.fdb_fak_id = fc.fc_fak_id 
          join slr.slr_jrnl_lines jl on fc.fc_fak_id = jl.jl_fak_id
;

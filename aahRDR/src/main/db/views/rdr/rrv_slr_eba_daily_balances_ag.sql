create or replace force view rdr.rrv_slr_eba_daily_balances_ag
as
   select edb_fak_id,
          edb_eba_id,
          fc.ledger_cd,
          fc.policy_id,
          ec.stream_id,
          fc.affiliate_le_id,
          ec.tax_jurisdiction_cd,
          edb_balance_date,
          edb_balance_type,
          edb_tran_daily_movement,
          edb_tran_mtd_balance,
          edb_tran_ytd_balance,
          edb_tran_ltd_balance,
          edb_base_daily_movement,
          edb_base_mtd_balance,
          edb_base_ytd_balance,
          edb_base_ltd_balance,
          edb_local_daily_movement,
          edb_local_mtd_balance,
          edb_local_ytd_balance,
          edb_local_ltd_balance,
          edb_entity,
          edb_epg_id,
          edb_period_month,
          edb_period_year,
          edb_period_ltd,
          edb_process_id,
          edb_amended_on
     from slr.slr_eba_daily_balances db
          join rdr.rrv_slr_eba_combinations_ag ec
             on db.edb_eba_id = ec.ec_eba_id 
          join rdr.rrv_slr_fak_combinations_ag fc
             on ec.ec_fak_id = fc.fc_fak_id
;

select
       fc.fc_epg_id
     , fc.fc_account
     , fc.fc_ccy
     , fc.fc_segment_1
     , fc.fc_segment_2
     , fc.fc_segment_3
     , fc.fc_segment_4
     , fc.fc_segment_5
     , fc.fc_segment_6
     , fc.fc_segment_7
     , fc.fc_segment_8
     , fc.fc_segment_9
     , fc.fc_segment_10 
     , fdb.fdb_balance_date
     , fdb.fdb_balance_type
     , fdb.fdb_tran_daily_movement
     , fdb.fdb_tran_mtd_balance
     , fdb.fdb_tran_ytd_balance
     , fdb.fdb_tran_ltd_balance
     , fdb.fdb_base_daily_movement
     , fdb.fdb_base_mtd_balance
     , fdb.fdb_base_ytd_balance
     , fdb.fdb_base_ltd_balance
     , fdb.fdb_local_daily_movement
     , fdb.fdb_local_mtd_balance
     , fdb.fdb_local_ytd_balance
     , fdb.fdb_local_ltd_balance
     , fdb.fdb_entity
     , fdb.fdb_period_month
     , fdb.fdb_period_year
     , fdb.fdb_period_ltd
  from
            slr.slr_fak_daily_balances fdb
       join slr.slr_fak_combinations   fc  on fdb.fdb_fak_id = fc.fc_fak_id
select
       fc_epg_id
     , fc_account
     , fc_ccy
     , fc_segment_1
     , fc_segment_2
     , fc_segment_3
     , fc_segment_4
     , fc_segment_5
     , fc_segment_6
     , fc_segment_7
     , fc_segment_8
     , fc_segment_9
     , fc_segment_10 
     , fdb_balance_date
     , fdb_balance_type
     , fdb_tran_daily_movement
     , fdb_tran_mtd_balance
     , fdb_tran_ytd_balance
     , fdb_tran_ltd_balance
     , fdb_base_daily_movement
     , fdb_base_mtd_balance
     , fdb_base_ytd_balance
     , fdb_base_ltd_balance
     , fdb_local_daily_movement
     , fdb_local_mtd_balance
     , fdb_local_ytd_balance
     , fdb_local_ltd_balance
     , fdb_entity
     , fdb_period_month
     , fdb_period_year
     , fdb_period_ltd
  from
       er_slr_fak_daily_balances
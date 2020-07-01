select
       ec_epg_id
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
     , ec_attribute_1
     , ec_attribute_2
     , ec_attribute_3
     , ec_attribute_4
     , ec_attribute_5
     , edb_balance_date
     , edb_balance_type
     , edb_tran_daily_movement
     , edb_tran_mtd_balance
     , edb_tran_ytd_balance
     , edb_tran_ltd_balance
     , edb_base_daily_movement
     , edb_base_mtd_balance
     , edb_base_ytd_balance
     , edb_base_ltd_balance
     , edb_local_daily_movement
     , edb_local_mtd_balance
     , edb_local_ytd_balance
     , edb_local_ltd_balance
     , edb_entity
     , edb_period_month
     , edb_period_year
     , edb_period_ltd
  from
       er_slr_eba_daily_balances
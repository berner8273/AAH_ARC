select
       ec.ec_epg_id
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
     , ec.ec_attribute_1
     , ec.ec_attribute_2
     , ec.ec_attribute_3
     , ec.ec_attribute_4
     , ec.ec_attribute_5
     , edb.edb_balance_date
     , edb.edb_balance_type
     , edb.edb_tran_daily_movement
     , edb.edb_tran_mtd_balance
     , edb.edb_tran_ytd_balance
     , edb.edb_tran_ltd_balance
     , edb.edb_base_daily_movement
     , edb.edb_base_mtd_balance
     , edb.edb_base_ytd_balance
     , edb.edb_base_ltd_balance
     , edb.edb_local_daily_movement
     , edb.edb_local_mtd_balance
     , edb.edb_local_ytd_balance
     , edb.edb_local_ltd_balance
     , edb.edb_entity
     , edb.edb_period_month
     , edb.edb_period_year
     , edb.edb_period_ltd
  from
            slr.slr_eba_daily_balances edb
       join slr.slr_eba_combinations   ec  on edb_eba_id     = ec.ec_eba_id
       join slr.slr_fak_combinations   fc  on edb.edb_fak_id = fc.fc_fak_id
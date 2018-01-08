create or replace view stn.cev_period_balances
with period_detail
  as (
         select
                sedb.edb_balance_date         balance_date
              , sec.ec_attribute_1            stream_id
              , sfc.fc_entity                 business_unit
              , sfc.fc_account                sub_account
              , sfc.fc_ccy                    currency
              , sec.ec_attribute_3            premium_typ
              , sfc.fc_segment_2              basis_cd
              , sedb.edb_tran_ltd_balance     transaction_balance
              , sedb.edb_base_ltd_balance     reporting_balance
              , sedb.edb_local_ltd_balance    functional_balance
              , sedb.edb_period_month         period_month
              , sedb.edb_period_year          period_year
           from
                     slr.slr_eba_daily_balances sedb
                join slr.slr_fak_combinations   sfc   on sedb.edb_fak_id = sfc.fc_fak_id
                join slr.slr_eba_combinations   sec   on sedb.edb_eba_id = sec.ec_eba_id
          where (
                    select
                           max(sedb2.edb_balance_date) max_period_date
                      from
                                slr.slr_eba_daily_balances   sedb2
                           join slr.slr_fak_combinations     sfc2   on sedb2.edb_fak_id = sfc2.fc_fak_id
                           join slr.slr_eba_combinations     sec2   on sedb2.edb_eba_id = sec2.ec_eba_id
                     where sec2.ec_attribute_1          = sec.ec_attribute_1
                       and sfc2.fc_entity               = sfc.fc_entity
                       and sfc2.fc_account              = sfc.fc_account
                       and sfc2.fc_ccy                  = sfc.fc_ccy
                       and sec2.ec_attribute_3          = sec.ec_attribute_3
                       and sfc2.fc_segment_2            = sfc.fc_segment_2
                       and sedb2.edb_period_month       = sedb.edb_period_month
                       and sedb2.edb_period_year        = sedb.edb_period_year
                ) = sedb.edb_balance_date
    )
         select
                sum(pd.transaction_balance) transaction_balance
              , sum(pd.reporting_balance)   reporting_balance
              , sum(pd.functional_balance)  functional_balance
              , stream_id
              , business_unit
              , sub_account
              , currency
              , premium_typ
              , basis_cd
              , period_month
              , period_year
              , last_day(balance_date) end_of_period
           from
                period_detail pd
          group by
                stream_id
              , business_unit
              , sub_account
              , currency
              , premium_typ
              , basis_cd
              , period_month
              , period_year
              , last_day(balance_date)
;
select
       policy_id
     , policy_nm
     , policy_abbr_nm
     , original_policy_id
     , underwriting_le_id
     , external_le_id
     , close_dt
     , expected_maturity_dt
     , policy_underwriting_yr
     , policy_accident_yr
     , policy_typ
     , policy_premium_typ
     , is_credit_default_swap
     , is_mark_to_market
     , execution_typ
     , transaction_ccy
     , is_uncollectible
     , earnings_calc_method
     , feed_uuid
     , event_status
  from
       er_insurance_policy
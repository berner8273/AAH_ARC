select
       ent.ent_entity
     , ent.ent_entity_short_code
     , ent.ent_post_eff_date
     , ent.ent_post_val_date
     , ent.ent_post_fak_balances
     , ent.ent_post_daily_balances
     , ent.ent_post_period_balances
     , ent.ent_description
     , ent.ent_status
     , ent.ent_business_date
     , ent.ent_base_ccy
     , ent.ent_local_ccy
     , ent.ent_accounts_set
     , ent.ent_currency_set
     , ent.ent_rate_set
     , ent.ent_periods_and_days_set
     , ent.ent_segment_1_set
     , ent.ent_segment_2_set
     , ent.ent_segment_3_set
     , ent.ent_segment_4_set
     , ent.ent_segment_5_set
     , ent.ent_segment_6_set
     , ent.ent_segment_7_set
     , ent.ent_segment_8_set
     , ent.ent_segment_9_set
     , ent.ent_segment_10_set
     , ent.ent_sl_ledger_name
     , ent.ent_apply_fx_translation
     , ent.ent_adjustment_flag
  from
       slr.slr_entities ent
select
       cs.feed_uuid                                 feed_uuid
     , fsrip.srin_cover_signing_party               policy_id
     , fsrip.srin_cover_note_description            policy_nm
     , fsrip.srin_t_client_text6                    policy_abbr_nm
     , fsrip.srin_cost_centre_code                  original_policy_id
     , fsrip.srin_party_id1                         underwriting_le_cd
     , fsrip.srin_party_id2                         external_le_cd
     , fsrip.srin_trade_date                        close_dt
     , fsrip.srin_date1                             expected_maturity_dt
     , fsrip.srin_fee                               policy_underwriting_yr
     , to_number(fsrip.srin_t_client_text10)        policy_accident_yr
     , fsrip.srin_t_client_text4                    policy_typ
     , fsrip.srin_t_client_text3                    policy_premium_typ
     , fsrip.srin_amount_type2                      is_credit_default_swap
     , fsrip.srin_amount_type1                      is_mark_to_market
     , fsrip.srin_t_client_text7                    execution_typ
     , fsrip.srin_trans_currency_code               transaction_ccy
     , fsrip.srin_t_client_text9                    is_uncollectible
     , fsrip.srin_t_client_text8                    earnings_calc_method
     , fsrip.srin_source_system_tran_id             stream_id
     , fsrip.srin_t_client_text1                    ultimate_parent_stream_id
     , fsrip.srin_t_client_text2                    parent_stream_id
     , fsrip.srin_legal_entity_code                 le_cd
     , fsrip.srin_amount_type4                      cession_typ
     , fsrip.srin_amount1                           gross_par_pct
     , fsrip.srin_amount2                           net_par_pct
     , fsrip.srin_amount3                           gross_premium_pct
     , fsrip.srin_amount4                           ceding_commission_pct
     , fsrip.srin_amount5                           net_premium_pct
     , fsrip.srin_cover_start_date                  start_dt
     , fsrip.srin_cover_signature_date              effective_dt
     , fsrip.srin_cover_end_date                    stop_dt
     , fsrip.srin_accounting_date                   termination_dt
     , fsrip.srin_cover_signed                      loss_pos
     , fsrip.srin_jurisdiction                      vie_status
     , fsrip.srin_cover_note_create_date            vie_effective_dt
     , fsrip.srin_signature_date                    vie_acct_dt
     , fsrip.srin_indemnity                         accident_yr
     , fsrip.srin_benefit_limit                     underwriting_yr
     , fsrip.srin_description                       policy_name_stream_id
     , fsrip.srin_policy_holder_addrss_cde          policy_holder_address
     , fsrip.srin_portfolio                         portfolio_cd
     , fsrip.srin_buy_or_sell                       buy_or_sell
     , fsrip.srin_source_system_code                system_cd
     , fsrip.srin_policy_holder_code                policy_holder_le_cd
     , fsrip.srinx_product_code                     instrument_type
     , fsrip.srin_event_code                        event_code
     , fsrip.srin_t_client_text5                    financial_instrument_id
     , fsrip.srin_t_source_ver_no                   policy_version
     , fsrip.event_status                           event_status
     , fsrip.lpg_id                                 lpg_id
  from
       fdr.fr_stan_raw_insurance_policy fsrip
       join stn.cession             cs     on to_number ( fsrip.message_id ) = cs.row_sid
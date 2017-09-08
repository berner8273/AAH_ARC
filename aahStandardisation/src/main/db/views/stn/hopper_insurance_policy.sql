create or replace view stn.hopper_insurance_policy
as
select
       fsrip.srin_reference4                        policy_id
     , fsrip.srin_contract_number                   original_policy_id
     , fsrip.srin_reference1                        underwriting_le_cd
     , fsrip.srin_reference2                        external_reinsurer_le_cd
     , fsrip.srin_reference3                        accident_yr
     , fsrip.srin_trade_date                        close_dt
     , fsrip.srin_date1                             expected_maturity_dt
     , fsrip.srinx_accounting_year                  underwriting_yr
     , fsrip.srin_portfolio                         portfolio_cd
     , fsrip.srin_t_client_text3                    premium_typ
     , fsrip.srin_amount_type1                      is_mark_to_market
     , fsrip.srin_amount_type2                      is_credit_default_swap
     , fsrip.srinx_dimension1                       line_of_business_cd
     , fsrip.srinx_dimension2                       line_of_business_descr
     , fsrip.srinx_dimension3                       line_of_business_long_descr
     , fsrip.srinx_dimension4                       transaction_ccy
     , fsrip.srin_source_system_tran_id             stream_id
     , fsrip.srin_t_client_text1                    ultimate_parent_stream_id
     , fsrip.srin_t_client_text2                    parent_stream_id
     , fsrip.srin_legal_entity_code                 le_cd
     , fsrip.srin_amount_type3                      has_profit_commissions
     , fsrip.srin_amount_type4                      cession_typ
     , fsrip.srin_amount1                           gross_par_pct
     , fsrip.srin_amount2                           net_par_pct
     , fsrip.srin_amount3                           gross_premium_pct
     , fsrip.srin_amount4                           ceding_commission_pct
     , fsrip.srin_amount5                           net_premium_pct
     , fsrip.srin_amount6                           pooling_pct
     , fsrip.srin_cover_start_date                  start_dt
     , fsrip.srin_cover_signature_date              effective_dt
     , fsrip.srin_cover_end_date                    stop_dt
     , fsrip.srin_accounting_date                   termination_dt
     , fsrip.srin_premium_amount                    loss_layer_pct
     , fsrip.srin_description                       cession_descr
     , fsrip.srin_policy_holder_addrss_cde          policy_holder_address
     , fsrip.srin_t_client_text4                    vie_cd
     , fsrip.srin_file_date                         vie_effective_dt
     , fsrip.srin_buy_or_sell                       buy_or_sell
     , fsrip.srin_source_system_code                system_cd
     , fsrip.srin_policy_holder_code                policy_holder_le_cd
     , fsrip.srinx_product_code                     instrument_type
     , fsrip.srin_event_code                        event_code
     , fsrip.srin_t_client_text5                    financial_instrument_id
     , fsrip.event_status                           event_status
     , fsrip.message_id                             message_id
     , fsrip.process_id                             process_id
     , fsrip.lpg_id                                 lpg_id
  from
       fdr.fr_stan_raw_insurance_policy fsrip
     ;
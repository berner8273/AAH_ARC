create or replace view rdr.rrv_ag_insurance_policy
as
select
       fiie.iie_cover_signing_party                 policy_id
     , fiie.iie_cover_note_description              policy_nm
     , ft.t_client_text6                            policy_abbr_nm
     , fiie.iie_cost_centre                         original_policy_id
     , fiie.iie_pbu_party1                          underwriting_le_cd
     , fiie.iie_pbu_party2                          external_le_cd
     , ft.t_trade_date                              close_dt
     , ft.t_client_date1                            expected_maturity_dt
     , ft.t_fee                                     policy_underwriting_yr
     , ft.t_client_text10                           policy_accident_yr
     , ft.t_client_text4                            policy_typ
     , ft.t_client_text3                            policy_premium_typ
     , ft.t_ct_charge_type_id2                      is_credit_default_swap
     , ft.t_ct_charge_type_id1                      is_mark_to_market
     , ft.t_client_text7                            execution_typ
     , fi.i_cu_currency_id                          transaction_ccy
     , ft.t_client_text9                            is_uncollectible
     , ft.t_client_text8                            earnings_calc_method
     , ft.t_source_tran_no                          stream_id
     , ft.t_client_text1                            ultimate_parent_stream_id
     , ft.t_client_text2                            parent_stream_id
     , ft.t_bo_book_id                              le_cd
     , ft.t_ct_charge_type_id4                      cession_typ
     , ft.t_total_consid                            gross_par_pct
     , ft.t_clean_consid                            net_par_pct
     , ft.t_charge_amount1                          gross_premium_pct
     , ft.t_charge_amount2                          ceding_commission_pct
     , ft.t_charge_amount3                          net_premium_pct
     , fiie.iie_cover_start_date                    start_dt
     , fiie.iie_cover_signature_date                effective_dt
     , fiie.iie_cover_end_date                      stop_dt
     , ft.t_accounting_date                         termination_dt
     , fiie.iie_cover_signed                        loss_pos
     , fiie.iie_jurisdiction                        vie_status
     , fiie.iie_cover_note_create_date              vie_effective_dt
     , fiie.iie_sign_date                           vie_acct_dt
     , fiie.iie_indemnity                           accident_yr
     , fiie.iie_benefit_limit                       underwriting_yr
     , fi.i_instr_desc_line1                        policy_name_stream_id
     , ft.t_ad_address_id                           policy_holder_address
     , ft.t_bo_book_id                              portfolio_cd
     , ft.t_buy_or_sell                             buy_or_sell
     , ft.t_si_source_sys_inst_id                   system_cd
     , ft.t_bo_book_id                              policy_holder_le_cd
     , fi.i_it_instr_type_id                        instrument_type
     , ft.t_acc_event_type_code                     event_code
     , ft.t_client_text5                            financial_instrument_id
     , ft.t_fdr_ver_no                              policy_version
     , ft.t_input_time                              input_date
     , to_char(ft.t_input_time, 'HH24:MI:SS')       input_time
  from
       fdr.fr_instrument fi
  join
       fdr.fr_instr_insure_extend fiie on fiie.iie_instrument_id = fi.i_instrument_id
  join
       fdr.fr_trade               ft   on ft.t_i_instrument_id   = fi.i_instrument_id
     ;
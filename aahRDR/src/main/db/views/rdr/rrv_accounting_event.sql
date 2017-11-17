create or replace view rdr.rrv_accounting_event
as
select
       ae_accevent_id
     , ae_gl_account                as sub_acccount
     , ae_acc_event_id
     , ae_aet_acc_event_type_id
     , ae_in_repository_ind
     , ae_posting_date              as effective_date
     , ae_accevent_date
     , ae_amount                    as transaction_amt
     , ae_iso_currency_code         as currency
     , ae_ledger_period
     , ae_local_amount
     , ae_gl_account_alias
     , ae_local_currency_code
     , ae_gl_entity                 as business_unit
     , ae_epg_id
     , ae_gl_book                   as department
     , ae_gl_profit_centre
     , ae_input_time
     , ae_gl_instr_super_class
     , ae_ledger_rec_status
     , ae_value_date  		        as posting_period
     , ae_gl_instrument_id
     , ae_gl_party_business_id
     , ae_gl_person_id
     , ae_client_spare_id1          as event_type
     , ae_client_spare_id2          as affiliate
     , ae_client_spare_id3          as rule_id
     , ae_client_spare_id4
     , ae_client_spare_id5          as functionl_ccy
     , ae_client_spare_id6          as functional_amt
     , ae_client_spare_id7          as reporting_ccy
     , ae_client_spare_id8          as reporting_amt
     , ae_client_spare_id9
     , ae_source_tran_no
     , ae_gl_narrative
     , ae_ledger_rec_status2
     , ae_rep_schema_upd
     , ae_transaction_no
     , ae_rule_id
     , ae_rules_amount_ref_id
     , ae_sub_ledger_upd
     , ae_i_instrument_id
     , ae_fdr_tran_no
     , ae_il_instr_leg_id
     , ae_source_system
     , ae_journal_type
     , ae_gl_ledger_id
     , ae_base_currency_code
     , lpg_id
     , ae_source_jrnl_id
     , ae_sub_event_id
     , ae_posting_schema            as ledger
     , ae_gaap                      as accounting_basis
     , ae_posting_code
     , ae_reverse_date
     , ae_dr_cr
     , ae_base_rate
     , ae_local_rate
     , ae_dimension_1               as affiliate
     , ae_dimension_2               as chartfield1
     , ae_dimension_3               as execution_type
     , ae_dimension_4               as business_type
     , ae_dimension_5               as policy_id
     , ae_dimension_7               as tax_jurisdiction
     , ae_dimension_8               as premium_type
     , ae_dimension_10              as stream
     , ae_dimension_12              as gross_stream_owner
     , ae_dimension_13              as underwriting_year
     , ae_dimension_14              as owner_entity
     , ae_dimension_15              as accounting_event_type
     , ae_gl_cost_centre
     , ae_ret_amort_flag
     , ae_gl_client1_org_unit_id
     , ae_gl_client2_org_unit_id
     , ae_gl_client3_org_unit_id
     , ae_gl_plant_id
     , ae_gl_ship_to_country_id
     , ae_gl_product_part_id
     , ae_client_date1
     , ae_gl_cash_flow_type
     , ae_gl_tax_code_id
     , ae_gl_contract_id
     , ae_gl_rights_categ_id
     , ae_gl_rights_subcateg_id
     , ae_translation_date
     , ae_ret_recog_type_id
     , ae_base_amount
     , ae_number_of_periods
     , ae_calc_period
     , ae_ret_agv_or_arrears
     , ae_ret_ca_calendar_name
     , ae_ret_post_period
     , ae_client_date2
     , ae_client_date3
     , ae_client_date4
     , ae_client_date5
  from
       fdr.fr_accounting_event
     ;
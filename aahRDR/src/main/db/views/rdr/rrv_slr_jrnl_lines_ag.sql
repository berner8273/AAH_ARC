create or replace view rdr.rrv_slr_jrnl_lines_ag
as
select
       jl_jrnl_hdr_id
     , jl_jrnl_line_number
     , jl_fak_id
     , jl_eba_id
     , jl_jrnl_status
     , jl_jrnl_status_text
     , jl_jrnl_process_id
     , jl_description
     , jl_source_jrnl_id
     , jl_effective_date
     , jl_value_date
     , jl_entity               business_unit
     , jl_epg_id
     , jl_account              sub_account
     , jl_segment_1            ledger
     , jl_segment_2            accounting_basis
     , jl_segment_3            department
     , jl_segment_4            execution_type
     , jl_segment_5            premium_type
     , jl_segment_6            program
     , jl_segment_7            chartfield1
     , jl_segment_8            business_type
     , jl_segment_9            policy_policysub
     , jl_segment_10           line_of_business
     , jl_attribute_1          int_counterparty
     , jl_attribute_2          ext_counterparty
     , jl_attribute_3          stream
     , jl_attribute_4          issue_type
     , jl_attribute_5          tax_jurisdiction
     , jl_reference_1          underwriting_yr
     , jl_reference_2          accident_yr
     , jl_reference_3          policy_name
     , jl_reference_4          ultimate_parent
     , jl_reference_5          event_type
     , jl_reference_6          affiliate
     , jl_reference_7          rule_id
     , jl_reference_8
     , jl_reference_9
     , jl_reference_10
     , jl_tran_ccy
     , jl_tran_amount
     , jl_base_rate
     , jl_base_ccy
     , jl_base_amount
     , jl_local_rate
     , jl_local_ccy
     , jl_local_amount
     , jl_created_by
     , jl_created_on
     , jl_amended_by
     , jl_amended_on
     , jl_recon_status
     , jl_translation_date
     , jl_bus_posting_date
     , jl_period_month
     , jl_period_year
     , jl_period_ltd
     , jl_type
  from
       slr.slr_jrnl_lines
;

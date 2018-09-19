create or replace view rdr.rrv_ag_slr_jrnl_lines
as
select 
       jl.jl_jrnl_hdr_id
     , jl.jl_jrnl_line_number
     , jl.jl_fak_id
     , jl.jl_eba_id
     , jl.jl_jrnl_status
     , jl.jl_jrnl_status_text
     , jl.jl_jrnl_process_id
     , jl.jl_description
     , jl.jl_source_jrnl_id
     , jl.jl_effective_date          effective_date
     , jl.jl_value_date              posting_period
     , jl.jl_entity                  business_unit
     , jl.jl_epg_id
     , jl.jl_account                 sub_account
     , jl.jl_segment_1               ledger
     , jl.jl_segment_2               accounting_basis
     , jl.jl_segment_3               department
     , jl.jl_segment_4               affiliate
     , jl.jl_segment_5               chartfield1
     , jl.jl_segment_6               execution_type
     , jl.jl_segment_7               business_type
     , jl.jl_segment_8               policy_id
     , jl.jl_attribute_1             stream
     , jl.jl_attribute_2             tax_jurisdiction
     , jl.jl_attribute_3             premium_type
     , jl.jl_attribute_4             accounting_event_type
     , jl.jl_reference_1             journal_descr
     , nvl(jl.jl_reference_2, jl_reference.gross_stream_owner) gross_stream_owner
     , jl.jl_reference_3             underwriting_year
     , nvl(jl.jl_reference_4, jl_reference.owner_entity) owner_entity
     , jl.jl_reference_5             business_event_type
     , jl.jl_reference_6             accident_year
     , nvl(jl.jl_reference_7, jl_reference.int_ext_counterparty) int_ext_counterparty
     , jl.jl_tran_ccy                currency
     , jl.jl_tran_amount             transaction_amt
     , jl.jl_base_rate               reporting_rate
     , jl.jl_base_ccy                reporting_currency
     , jl.jl_base_amount             reporting_amt
     , jl.jl_local_rate              functional_rate
     , jl.jl_local_ccy               functional_currency
     , jl.jl_local_amount            functional_amt
     , jl.jl_created_by
     , jl.jl_created_on
     , jl.jl_amended_by
     , jl.jl_amended_on
     , jl.jl_recon_status
     , jl_translation_date
     , jl_bus_posting_date
     , jl.jl_period_month
     , jl.jl_period_year
     , jl.jl_period_ltd
     , jl.jl_type
     , faei.ae_client_spare_id14  correlation_uuid
     , faei.ae_client_spare_id12  event_seq_id
     , faei.ae_client_spare_id16  posting_indicator,
NULL as jlu_jrnl_date,
NULL as jlu_jrnl_description,
NULL as jlu_jrnl_source,
NULL as jlu_jrnl_source_jrnl_id,
NULL as jlu_jrnl_authorised_by,
NULL as jlu_jrnl_authorised_on,
NULL as jlu_jrnl_validated_by,
NULL as jlu_jrnl_validated_on,
NULL as jlu_jrnl_posted_by,
NULL as jlu_jrnl_posted_on,
NULL as jlu_jrnl_total_hash_debit,
NULL as jlu_jrnl_total_hash_credit,
NULL as jlu_jrnl_pref_static_src,
NULL as jlu_jrnl_ref_id,
NULL as jlu_jrnl_rev_date,
NULL as jlu_translation_date,
NULL as jlu_period_month,
NULL as jlu_period_year,
NULL as jlu_period_ltd,
NULL as jlu_jrnl_internal_period_flag,
NULL as jlu_jrnl_ent_rate_set
  from
       slr.slr_jrnl_lines jl
left join (
            select jl2.jl_eba_id
                 , jl2.jl_epg_id
                 , min(jl2.jl_reference_2) gross_stream_owner
                 , min(jl2.jl_reference_4) owner_entity
                 , min(jl2.jl_reference_7) int_ext_counterparty
              from slr.slr_jrnl_lines jl2
          group by jl2.jl_eba_id
                 , jl2.jl_epg_id
          ) jl_reference
          on jl.jl_eba_id = jl_reference.jl_eba_id
         and jl.jl_epg_id = jl_reference.jl_epg_id

 left join
  (
    select faei2.ae_client_spare_id14  
     , faei2.ae_client_spare_id12  
     , faei2.ae_client_spare_id16  
     , max(faei2.ae_acc_event_id) ae_acc_event_id
    from fdr.fr_accounting_event_imp faei2
     group by faei2.ae_client_spare_id14
     , faei2.ae_client_spare_id12  
     , faei2.ae_client_spare_id16) faei
   on jl.jl_source_jrnl_id = faei.ae_acc_event_id 
 
 union all
 
select 
jlu_jrnl_hdr_id,
jlu_jrnl_line_number,
jlu_fak_id,
jlu_eba_id,
jlu_jrnl_status,
jlu_jrnl_status_text,
jlu_jrnl_process_id,
jlu_description,
jlu_source_jrnl_id,
jlu_effective_date,
jlu_value_date,
jlu_entity,
jlu_epg_id,
jlu_account,
jlu_segment_1,
jlu_segment_2,
jlu_segment_3,
jlu_segment_4,
jlu_segment_5,
jlu_segment_6,
jlu_segment_7,
jlu_segment_8,
jlu_attribute_1,
jlu_attribute_2,
jlu_attribute_3,
jlu_attribute_4,
jlu_reference_1,
jlu_reference_2,
jlu_reference_3,
jlu_reference_4,
jlu_reference_5,
jlu_reference_6,
jlu_reference_7,
jlu_tran_ccy,
jlu_tran_amount,
jlu_base_rate,
jlu_base_ccy,
jlu_base_amount,
jlu_local_rate,
jlu_local_ccy,
jlu_local_amount,
jlu_created_by,
jlu_created_on,
jlu_amended_by,
jlu_amended_on,
NULL as jl_recon_status,
NULL as jl_translation_date,
NULL as jl_bus_posting_date,
NULL as jl_period_month,
NULL as jl_period_year,
NULL as jl_period_ltd,
jlu_type,
NULL as correlation_uuid,
NULL as event_seq_id,
jlu_jrnl_type,
jlu_jrnl_date,
jlu_jrnl_description,
jlu_jrnl_source,
jlu_jrnl_source_jrnl_id,
jlu_jrnl_authorised_by,
jlu_jrnl_authorised_on,
jlu_jrnl_validated_by,
jlu_jrnl_validated_on,
jlu_jrnl_posted_by,
jlu_jrnl_posted_on,
jlu_jrnl_total_hash_debit,
jlu_jrnl_total_hash_credit,
jlu_jrnl_pref_static_src,
jlu_jrnl_ref_id,
jlu_jrnl_rev_date,
jlu_translation_date,
jlu_period_month,
jlu_period_year,
jlu_period_ltd,
jlu_jrnl_internal_period_flag,
jlu_jrnl_ent_rate_set
from slr.slr_jrnl_lines_unposted

 union all
        
select jlu_jrnl_hdr_id
,jlu_jrnl_line_number
,jlu_fak_id
,jlu_eba_id
 ,nvl(jle1.jle_error_code, jlu_jrnl_status) jlu_jrnl_status
 ,nvl(jle1.jle_error_string, jlu_jrnl_status_text) jlu_jrnl_status_text
,jlu_jrnl_process_id
,jlu_description
,jlu_source_jrnl_id
,jlu_effective_date
,jlu_value_date
,jlu_entity
,jlu_epg_id
,jlu_account
,jlu_segment_1
,jlu_segment_2
,jlu_segment_3
,jlu_segment_4
,jlu_segment_5
,jlu_segment_6
,jlu_segment_7
,jlu_segment_8
,jlu_attribute_1
,jlu_attribute_2
,jlu_attribute_3
,jlu_attribute_4
,jlu_reference_1
,jlu_reference_2
,jlu_reference_3
,jlu_reference_4
,jlu_reference_5
,jlu_reference_6
,jlu_reference_7
,jlu_tran_ccy
,jlu_tran_amount
,jlu_base_rate
,jlu_base_ccy
,jlu_base_amount
,jlu_local_rate
,jlu_local_ccy
,jlu_local_amount
,jlu_created_by
,jlu_created_on
,jlu_amended_by
,jlu_amended_on
,NULL as jl_recon_status
,NULL as jl_translation_date
,NULL as jl_bus_posting_date
,NULL as jl_period_month
,NULL as jl_period_year
,NULL as jl_period_ltd
,NULL as jlu_type
,NULL as correlation_uuid
,NULL as event_seq_id
,jlu_jrnl_type
,jlu_jrnl_date
,jlu_jrnl_description
,jlu_jrnl_source
,jlu_jrnl_source_jrnl_id
,jlu_jrnl_authorised_by
,jlu_jrnl_authorised_on
,jlu_jrnl_validated_by
,jlu_jrnl_validated_on
,jlu_jrnl_posted_by
,jlu_jrnl_posted_on
,jlu_jrnl_total_hash_debit
,jlu_jrnl_total_hash_credit
,jlu_jrnl_pref_static_src
,jlu_jrnl_ref_id
,jlu_jrnl_rev_date
,jlu_translation_date
,jlu_period_month
,jlu_period_year
,jlu_period_ltd
,NULL as jlu_jrnl_internal_period_flag
,NULL as jlu_jrnl_ent_rate_set
from gui.gui_jrnl_lines_unposted gjlu
   left join (
        select jle.jle_jrnl_hdr_id
            ,min(jle_error_code) jle_error_code
            ,min(jle_error_string) jle_error_string
            from gui.gui_jrnl_line_errors jle
            group by jle.jle_jrnl_hdr_id
            ) jle1
            on gjlu.jlu_jrnl_hdr_id = jle1.jle_jrnl_hdr_id
  ;
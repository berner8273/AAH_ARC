create or replace view rdr.rrv_ag_slr_jrnl_lines
as
select jl.jl_jrnl_hdr_id
     , jl.jl_jrnl_line_number
     , jl.jl_fak_id
     , jl.jl_eba_id
     , jl.jl_jrnl_status
     , jl.jl_jrnl_status_text
     , jl.jl_jrnl_process_id
     , jl.jl_description
     , jl.jl_source_jrnl_id
     , jl.jl_effective_date                                          effective_date
     , jl.jl_value_date                                              posting_period
     , jl.jl_entity                                                  business_unit
     , jl.jl_epg_id
     , jl.jl_account                                                 sub_account
     , jl.jl_segment_1                                               ledger
     , jl.jl_segment_2                                               accounting_basis
     , jl.jl_segment_3                                               department
     , jl.jl_segment_4                                               affiliate
     , jl.jl_segment_5                                               chartfield1
     , jl.jl_segment_6                                               execution_type
     , jl.jl_segment_7                                               business_type
     , jl.jl_segment_8                                               policy_id
     , jl.jl_attribute_1                                             stream
     , jl.jl_attribute_2                                             tax_jurisdiction
     , jl.jl_attribute_3                                             premium_type
     , jl.jl_attribute_4                                             accounting_event_type
     , jl.jl_reference_1                                             journal_descr
     , nvl( jl.jl_reference_2 , jl_reference.gross_stream_owner )    gross_stream_owner
     , jl.jl_reference_3                                             underwriting_year
     , nvl( jl.jl_reference_4 , jl_reference.owner_entity )          owner_entity
     , jl.jl_reference_5                                             business_event_type
     , jl.jl_reference_6                                             accident_year
     , nvl( jl.jl_reference_7 , jl_reference.int_ext_counterparty )  int_ext_counterparty
     , jl.jl_tran_ccy                                                currency
     , jl.jl_tran_amount                                             transaction_amt
     , jl.jl_base_rate                                               reporting_rate
     , jl.jl_base_ccy                                                reporting_currency
     , jl.jl_base_amount                                             reporting_amt
     , jl.jl_local_rate                                              functional_rate
     , jl.jl_local_ccy                                               functional_currency
     , jl.jl_local_amount                                            functional_amt
     , jl.jl_created_by
     , jl.jl_created_on
     , jl.jl_amended_by
     , jl.jl_amended_on
     , jl.jl_recon_status
     , jl.jl_translation_date
     , jl.jl_bus_posting_date
     , jl.jl_period_month
     , jl.jl_period_year
     , jl.jl_period_ltd
     , jl.jl_type
     , faei.correlation_uuid
     , faei.event_seq_id
     , faei.posting_indicator
     , null                                                          jlu_jrnl_type
     , null                                                          jlu_jrnl_date
     , null                                                          jlu_jrnl_description
     , null                                                          jlu_jrnl_source
     , null                                                          jlu_jrnl_source_jrnl_id
     , null                                                          jlu_jrnl_authorised_by
     , null                                                          jlu_jrnl_authorised_on
     , null                                                          jlu_jrnl_validated_by
     , null                                                          jlu_jrnl_validated_on
     , null                                                          jlu_jrnl_posted_by
     , null                                                          jlu_jrnl_posted_on
     , null                                                          jlu_jrnl_total_hash_debit
     , null                                                          jlu_jrnl_total_hash_credit
     , null                                                          jlu_jrnl_pref_static_src
     , null                                                          jlu_jrnl_ref_id
     , null                                                          jlu_jrnl_rev_date
     , null                                                          jlu_translation_date
     , null                                                          jlu_period_month
     , null                                                          jlu_period_year
     , null                                                          jlu_period_ltd
     , null                                                          jlu_jrnl_internal_period_flag
     , null                                                          jlu_jrnl_ent_rate_set
from slr.slr_jrnl_lines jl
left join (select jl2.jl_eba_id
                , jl2.jl_epg_id
                , min( jl2.jl_reference_2 ) gross_stream_owner
                , min( jl2.jl_reference_4 ) owner_entity
                , min( jl2.jl_reference_7 ) int_ext_counterparty
           from slr.slr_jrnl_lines jl2
           group by jl2.jl_eba_id
                  , jl2.jl_epg_id ) jl_reference
       on jl.jl_eba_id = jl_reference.jl_eba_id
      and jl.jl_epg_id = jl_reference.jl_epg_id
left join (select min( faei2.ae_client_spare_id14 )  correlation_uuid
                , min( faei2.ae_client_spare_id12 )  event_seq_id
                , min( faei2.ae_client_spare_id16 )  posting_indicator
                , ae_acc_event_id
           from fdr.fr_accounting_event_imp faei2
           group by faei2.ae_acc_event_id) faei
       on jl.jl_source_jrnl_id = faei.ae_acc_event_id
union all
select jlu.jlu_jrnl_hdr_id
     , jlu.jlu_jrnl_line_number
     , jlu.jlu_fak_id
     , jlu.jlu_eba_id
     , jlu.jlu_jrnl_status
     , jlu.jlu_jrnl_status_text
     , jlu.jlu_jrnl_process_id
     , jlu.jlu_description
     , jlu.jlu_source_jrnl_id
     , jlu.jlu_effective_date
     , jlu.jlu_value_date
     , jlu.jlu_entity
     , jlu.jlu_epg_id
     , jlu.jlu_account
     , jlu.jlu_segment_1
     , jlu.jlu_segment_2
     , jlu.jlu_segment_3
     , jlu.jlu_segment_4
     , jlu.jlu_segment_5
     , jlu.jlu_segment_6
     , jlu.jlu_segment_7
     , jlu.jlu_segment_8
     , jlu.jlu_attribute_1
     , jlu.jlu_attribute_2
     , jlu.jlu_attribute_3
     , jlu.jlu_attribute_4
     , jlu.jlu_reference_1
     , jlu.jlu_reference_2
     , jlu.jlu_reference_3
     , jlu.jlu_reference_4
     , jlu.jlu_reference_5
     , jlu.jlu_reference_6
     , jlu.jlu_reference_7
     , jlu.jlu_tran_ccy
     , jlu.jlu_tran_amount
     , jlu.jlu_base_rate
     , jlu.jlu_base_ccy
     , jlu.jlu_base_amount
     , jlu.jlu_local_rate
     , jlu.jlu_local_ccy
     , jlu.jlu_local_amount
     , jlu.jlu_created_by
     , jlu.jlu_created_on
     , jlu.jlu_amended_by
     , jlu.jlu_amended_on
     , null jl_recon_status
     , null jl_translation_date
     , null jl_bus_posting_date
     , null jl_period_month
     , null jl_period_year
     , null jl_period_ltd
     , jlu.jlu_type
     , faei.correlation_uuid
     , faei.event_seq_id
     , faei.posting_indicator
     , jlu.jlu_jrnl_type
     , jlu.jlu_jrnl_date
     , jlu.jlu_jrnl_description
     , jlu.jlu_jrnl_source
     , jlu.jlu_jrnl_source_jrnl_id
     , jlu.jlu_jrnl_authorised_by
     , jlu.jlu_jrnl_authorised_on
     , jlu.jlu_jrnl_validated_by
     , jlu.jlu_jrnl_validated_on
     , jlu.jlu_jrnl_posted_by
     , jlu.jlu_jrnl_posted_on
     , jlu.jlu_jrnl_total_hash_debit
     , jlu.jlu_jrnl_total_hash_credit
     , jlu.jlu_jrnl_pref_static_src
     , jlu.jlu_jrnl_ref_id
     , jlu.jlu_jrnl_rev_date
     , jlu.jlu_translation_date
     , jlu.jlu_period_month
     , jlu.jlu_period_year
     , jlu.jlu_period_ltd
     , jlu.jlu_jrnl_internal_period_flag
     , jlu.jlu_jrnl_ent_rate_set
from slr.slr_jrnl_lines_unposted jlu
left join (select min( faei2.ae_client_spare_id14 )  correlation_uuid
                , min( faei2.ae_client_spare_id12 )  event_seq_id
                , min( faei2.ae_client_spare_id16 )  posting_indicator
                , ae_acc_event_id
           from fdr.fr_accounting_event_imp faei2
           group by faei2.ae_acc_event_id) faei
       on jlu.jlu_source_jrnl_id = faei.ae_acc_event_id
union all
select CAST(STANDARD_HASH(gjlu.jlu_jrnl_hdr_id, 'MD5') AS VARCHAR2(32))
     , gjlu.jlu_jrnl_line_number
     , CAST(gjlu.jlu_fak_id AS VARCHAR2(32))
     , CAST(gjlu.jlu_eba_id AS VARCHAR2(32))
     , decode (jle.jle_error_code, null, gjlu.jlu_jrnl_status, 'E')               jlu_jrnl_status
     , nvl( substr( jle.jle_error_string , 1 , 20 ) , gjlu.jlu_jrnl_status_text ) jlu_jrnl_status_text
     , jlu_jrnl_process_id
     , jlu_description
     , jlu_source_jrnl_id
     , jlu_effective_date
     , jlu_value_date
     , jlu_entity
     , jlu_epg_id
     , jlu_account
     , jlu_segment_1
     , jlu_segment_2
     , jlu_segment_3
     , jlu_segment_4
     , jlu_segment_5
     , jlu_segment_6
     , jlu_segment_7
     , jlu_segment_8
     , jlu_attribute_1
     , jlu_attribute_2
     , jlu_attribute_3
     , jlu_attribute_4
     , jlu_reference_1
     , jlu_reference_2
     , jlu_reference_3
     , jlu_reference_4
     , jlu_reference_5
     , jlu_reference_6
     , jlu_reference_7
     , jlu_tran_ccy
     , jlu_tran_amount
     , jlu_base_rate
     , jlu_base_ccy
     , jlu_base_amount
     , jlu_local_rate
     , jlu_local_ccy
     , jlu_local_amount
     , jlu_created_by
     , jlu_created_on
     , jlu_amended_by
     , jlu_amended_on
     , null jl_recon_status
     , null jl_translation_date
     , null jl_bus_posting_date
     , null jl_period_month
     , null jl_period_year
     , null jl_period_ltd
     , null jl_type
     , null correlation_uuid
     , null event_seq_id
     , null posting_indicator
     , jlu_jrnl_type
     , jlu_jrnl_date
     , jlu_jrnl_description
     , jlu_jrnl_source
     , jlu_jrnl_source_jrnl_id
     , jlu_jrnl_authorised_by
     , jlu_jrnl_authorised_on
     , jlu_jrnl_validated_by
     , jlu_jrnl_validated_on
     , jlu_jrnl_posted_by
     , jlu_jrnl_posted_on
     , jlu_jrnl_total_hash_debit
     , jlu_jrnl_total_hash_credit
     , jlu_jrnl_pref_static_src
     , CAST(DECODE(jlu_jrnl_ref_id, NULL, NULL, STANDARD_HASH(jlu_jrnl_ref_id, 'MD5')) AS VARCHAR2(32)) jlu_jrnl_ref_id
     , jlu_jrnl_rev_date
     , jlu_translation_date
     , jlu_period_month
     , jlu_period_year
     , jlu_period_ltd
     , null jlu_jrnl_internal_period_flag
     , null jlu_jrnl_ent_rate_set
from gui.gui_jrnl_lines_unposted gjlu
left join (select jle1.jle_jrnl_hdr_id
                , min( jle1.jle_error_code )   jle_error_code
                , min( jle1.jle_error_string ) jle_error_string
           from gui.gui_jrnl_line_errors jle1
           group by jle1.jle_jrnl_hdr_id ) jle
       on gjlu.jlu_jrnl_hdr_id = jle.jle_jrnl_hdr_id;
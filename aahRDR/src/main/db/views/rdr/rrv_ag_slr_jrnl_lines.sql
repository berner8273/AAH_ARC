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
     , faei.ae_client_spare_id16  posting_indicator
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
 ;
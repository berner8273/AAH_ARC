create or replace view rdr.rrv_ag_slr_jrnl_lines
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
     , jl_effective_date   effective_date
     , jl_value_date			 posting_period
     , jl_entity           business_unit
     , jl_epg_id
     , jl_account          sub_account
     , jl_segment_1        ledger                  
     , jl_segment_2        accounting_basis        
     , jl_segment_3        department              
     , jl_segment_4        affiliate               
     , jl_segment_5        chartfield1             
     , jl_segment_6        execution_type          
     , jl_segment_7        business_type           
     , jl_segment_8        policy_id               
     , jl_attribute_1      stream                  
     , jl_attribute_2      tax_jurisdiction        
     , jl_attribute_3      premium_type            
     , jl_attribute_4      accounting_event_type
     , jl_reference_1      journal_descr           
     , jl_reference_2      gross_stream_owner      
     , jl_reference_3      underwriting_year       
     , jl_reference_4      owner_entity            
     , jl_reference_5      business_event_type     
     , jl_reference_6      accident_year           
     , jl_reference_7      int_ext_counterparty    
     , jl_tran_ccy	       currency
     , jl_tran_amount	     transaction_amt   	
     , jl_base_rate        reporting_rate
     , jl_base_ccy	       reporting_currency	
     , jl_base_amount      reporting_amt
     , jl_local_rate		   functional_rate
     , jl_local_ccy				 functional_currency
     , jl_local_amount		 functional_amt
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

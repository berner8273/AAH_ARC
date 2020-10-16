create or replace view rdr.rrv_ag_slr_jrnl_headers
as
select
       jh_jrnl_id
     , jh_jrnl_type
     , jh_jrnl_date
     , jh_jrnl_entity
     , jh_jrnl_status
     , jh_jrnl_status_text
     , jh_jrnl_process_id
     , jh_jrnl_description
     , jh_jrnl_source
     , jh_jrnl_source_jrnl_id
     , jh_jrnl_authorised_by
     , jh_jrnl_authorised_on
     , jh_jrnl_validated_by
     , jh_jrnl_validated_on
     , jh_jrnl_posted_by
     , jh_jrnl_posted_on
     , jh_jrnl_total_hash_debit
     , jh_jrnl_total_hash_credit
     , jh_jrnl_total_lines
     , jh_created_by
     , jh_created_on
     , jh_amended_by
     , jh_amended_on
     , jh_bus_posting_date
     , jh_jrnl_internal_period_flag
     , jh_jrnl_ref_id
     , jh_jrnl_rev_date
  from
       slr.slr_jrnl_headers
union all
select
       jhu_jrnl_id                jh_jrnl_id
     , jhu_jrnl_type              jh_jrnl_type
     , jhu_jrnl_date              jh_jrnl_date
     , jhu_jrnl_entity            jh_jrnl_entity
     , jhu_jrnl_status            jh_jrnl_status
     , jhu_jrnl_status_text       jh_jrnl_status_text
     , jhu_jrnl_process_id        jh_jrnl_process_id
     , jhu_jrnl_description       jh_jrnl_description
     , jhu_jrnl_source            jh_jrnl_source
     , jhu_jrnl_source_jrnl_id    jh_jrnl_source_jrnl_id
     , jhu_jrnl_authorised_by     jh_jrnl_authorised_by
     , jhu_jrnl_authorised_on     jh_jrnl_authorised_on
     , jhu_jrnl_validated_by      jh_jrnl_validated_by
     , jhu_jrnl_validated_on      jh_jrnl_validated_on
     , jhu_jrnl_posted_by         jh_jrnl_posted_by
     , jhu_jrnl_posted_on         jh_jrnl_posted_on
     , jhu_jrnl_total_hash_debit  jh_jrnl_total_hash_debit
     , jhu_jrnl_total_hash_credit jh_jrnl_total_hash_credit
     , jhu_jrnl_total_lines       jh_jrnl_total_lines
     , jhu_created_by             jh_created_by
     , jhu_created_on             jh_created_on
     , jhu_amended_by             jh_amended_by
     , jhu_amended_on             jh_amended_on
     , null                       jh_bus_posting_date
     , null                       jh_jrnl_internal_period_flag
     , jhu_jrnl_ref_id
     , jhu_jrnl_rev_date
  from
       slr.slr_jrnl_headers_unposted
union all
select
       jhu_jrnl_id
     , jhu_jrnl_type
     , jhu_jrnl_date 
     , jhu_jrnl_entity 
     , decode( jle1.jle_error_code , null , jhu_jrnl_status , 'E' ) jhu_jrnl_status
     ,nvl (substr (jle1.jle_error_string, 1, 20), jhu_jrnl_status_text) jhu_jrnl_status_text
     , jhu_jrnl_process_id
     , jhu_jrnl_description
     , jhu_jrnl_source
     , jhu_jrnl_source_jrnl_id
     , jhu_jrnl_authorised_by
     , jhu_jrnl_authorised_on
     , jhu_jrnl_validated_by 
     , jhu_jrnl_validated_on 
     , jhu_jrnl_posted_by
     , jhu_jrnl_posted_on
     , jhu_jrnl_total_hash_debit
     , jhu_jrnl_total_hash_credit
     , jhu_jrnl_total_lines
     , jhu_created_by
     , jhu_created_on
     , jhu_amended_by
     , jhu_amended_on
     , null as jh_bus_posting_date
     , null as jh_jrnl_internal_period_flag
     , jhu_jrnl_ref_id
     , jhu_jrnl_rev_date 
  from
       gui.gui_jrnl_headers_unposted jhu
  left join ( select
                     jle.jle_jrnl_hdr_id
                   , min(jle_error_code) jle_error_code
                   , min(jle_error_string) jle_error_string
                from
                     gui.gui_jrnl_line_errors jle
            group by
                     jle.jle_jrnl_hdr_id ) jle1   on jhu.jhu_jrnl_id = jle1.jle_jrnl_hdr_id
;
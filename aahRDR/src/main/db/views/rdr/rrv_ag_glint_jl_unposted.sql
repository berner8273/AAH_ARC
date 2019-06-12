create or replace view rdr.rrv_ag_glint_jl_unposted
as
select --Posted SLR journals not yet GLINT processed
       null                       rgjl_id
     , null                       rgjl_rgj_id
     , gjl.jl_entity              business_unit_gl
     , null                       journal_id
     , null                       journal_date
     , null                       journal_line
     , null                       rgjl_rgj_rgbc_id
     , null                       rgjl_aah_journal
     , null                       rgjl_aah_journal_line
     , null                       input_time
     , null                       input_user
     , null                       modified_time
     , null                       modified_user
     , null                       gl_distrib_status
     , null                       appl_jrnl_id
     , gjl.jl_segment_1           ledger_group
     , null                       ledger
     , gjl.jl_effective_date      accounting_dt
     , null                       fiscal_year
     , null                       accounting_period
     , gjl.jl_tran_ccy            foreign_currency
     , sum(gjl.jl_tran_amount)    foreign_amount
     , gjl.jl_base_ccy            currency_cd
     , sum(gjl.jl_base_amount)    monetary_amount
     , gjl.jl_account             account
     , gjl.jl_segment_3           deptid
     , null                       product
     , gjl.jl_segment_4           affiliate
     , gjl.program_code           program_code
     , gjl.jl_segment_5           chartfield1
     , null                       line_descr
     , null                       jrnl_ln_ref
     , null                       process_instance
     , null                       notes_254
     , null                       dttm_stamp
     , gjl.event_class            event_class
     , gjl.jl_jrnl_hdr_id         aah_jrnl_hdr_nbr
     , sum(gjl.credit_amt)        credit_amt
     , sum(gjl.debit_amt)         debit_amt
     , gjl.event_status           event_status
     , null                       slr_process_id
     , gjl.ejt_madj_flag          manual_je
     , null                       ps_filter
     , gjl.jl_created_by          created_by
     , gjl.jh_jrnl_authorised_by  approved_by
     , gjl.jh_jrnl_type
     , gjl.jh_jrnl_description      
  from ( select
                jl_jrnl_hdr_id
              , case when jt.ejt_madj_flag = 'Y' then jl_jrnl_hdr_id else 0 end                            jl_jrnl_hdr_id2
              , cast( jl_jrnl_line_number as number(5,0) )                                                 jl_jrnl_line_number
              , jl_fak_id
              , jl_eba_id
              , jl_jrnl_status
              , jl_jrnl_status_text
              , cast( jl_jrnl_process_id as number(8,0) )                                                  jl_jrnl_process_id
              , cast( nvl( jl_description , ' ' ) as varchar2(30) )                                        jl_description
              , cast( jl_source_jrnl_id as varchar2(10) )                                                  jl_source_jrnl_id
              , jl_effective_date
              , jl_value_date
              , cast( jl_entity as varchar2(5) )                                                           jl_entity
              , jl_epg_id
              , cast( gl.ga_client_text4 as varchar2(10) )                                                 jl_account
              , jl_account                                                                                 jl_sub_account
              , cast ( case when jl_segment_1 = 'NVS' then ' ' else jl_segment_1 end as varchar2(10) )     jl_segment_1
              , case when jl_segment_2 = 'NVS' then ' ' else jl_segment_2 end                              jl_segment_2
              , cast ( case when jl_segment_3 = 'NVS' then ' ' else jl_segment_3 end as varchar2(10) )     jl_segment_3
              , cast ( case when jl_segment_4 = 'NVS' then ' ' else jl_segment_4 end as varchar2(5) )      jl_segment_4
              , cast ( case when jl_segment_5 = 'NVS' then ' ' else jl_segment_5 end as varchar2(10) )     jl_segment_5
              , case when jl_entity LIKE 'E%' then 'MNCON' else ' ' end                                    program_code
              , case when jl_segment_7 = 'NVS' then ' ' else jl_segment_7 end                              jl_segment_7
              , case when jl_segment_8 = 'NVS' then ' ' else jl_segment_8 end                              jl_segment_8
              , case when jl_segment_9 = 'NVS' then ' ' else jl_segment_9 end                              jl_segment_9
              , case when jl_segment_10 = 'NVS' then ' ' else jl_segment_10 end                            jl_segment_10
              , case when jl_attribute_1 = 'NVS' then ' ' else jl_attribute_1 end                          jl_attribute_1
              , case when jl_attribute_2 = 'NVS' then ' ' else jl_attribute_2 end                          jl_attribute_2
              , case when jl_attribute_3 = 'NVS' then ' ' else jl_attribute_3 end                          jl_attribute_3
              , case when jl_attribute_4 = 'NVS' then ' ' else jl_attribute_4 end                          jl_attribute_4
              , case when jl_attribute_5 = 'NVS' then ' ' else jl_attribute_5 end                          jl_attribute_5
              , case when jl_reference_1 = 'NVS' then ' ' else jl_reference_1 end                          jl_reference_1
              , case when jl_reference_2 = 'NVS' then ' ' else jl_reference_2 end                          jl_reference_2
              , case when jl_reference_3 = 'NVS' then ' ' else jl_reference_3 end                          jl_reference_3
              , case when jl_reference_4 = 'NVS' then ' ' else jl_reference_4 end                          jl_reference_4
              , case when jl_reference_5 = 'NVS' then ' ' else jl_reference_5 end                          jl_reference_5
              , case when jl_reference_6 = 'NVS' then ' ' else jl_reference_6 end                          jl_reference_6
              , case when jl_reference_7 = 'NVS' then ' ' else jl_reference_7 end                          jl_reference_7
              , case when jl_reference_8 = 'NVS' then ' ' else jl_reference_8 end                          jl_reference_8
              , case when jl_reference_9 = 'NVS' then ' ' else jl_reference_9 end                          jl_reference_9
              , case when jl_reference_10 = 'NVS' then ' ' else jl_reference_10 end                        jl_reference_10
              , cast( jl_tran_ccy as varchar2(3) )                                                         jl_tran_ccy
              , round( jl_tran_amount , 2 )                                                                jl_tran_amount
              , jl_base_rate
              , case
                  when jl_segment_1 = 'UKGAAP_ADJ' 
                  then cast( jl_local_ccy as varchar2(3) )
                  else cast( jl_base_ccy as varchar2(3) )
                end                                                                                        jl_base_ccy
              , case
                  when jl_segment_1 = 'UKGAAP_ADJ'
                  then round( jl_local_amount , 2 )
                  else round( jl_base_amount , 2 )
                end                                                                                        jl_base_amount
              , jl_local_rate
              , jl_local_ccy
              , round( jl_local_amount , 2 )                                                               jl_local_amount
              , jl_created_by
              , jl_created_on
              , jl_amended_by
              , jl_amended_on
              , jh.jh_jrnl_authorised_by
              , nvl( fgl.lk_lookup_value3 , ' ' )                                                          event_class
              , case when jl_tran_amount < 0 then round( jl_tran_amount , 2 ) else null end                credit_amt
              , case when jl_tran_amount >= 0 then round( jl_tran_amount , 2 ) else null end               debit_amt
              , null                                                                                       event_status
              , jl.jl_jrnl_process_id
              , jt.ejt_madj_flag
              , jh.jh_jrnl_type
              , jh.jh_jrnl_description              
           from
                slr.slr_jrnl_lines            jl
           join slr.slr_jrnl_headers          jh    on jl.jl_jrnl_hdr_id           = jh.jh_jrnl_id
      left join fdr.fr_general_lookup         fgl   on jl.jl_attribute_4           = fgl.lk_match_key1
                                                   and fgl.lk_lkt_lookup_type_code = 'EVENT_HIERARCHY'
      left join fdr.fr_gl_account             gl    on jl.jl_account               = gl.ga_account_code
      left join slr.slr_ext_jrnl_types        jt    on jt.ejt_type                 = jh.jh_jrnl_type
          where
                jl.jl_jrnl_hdr_id              not in ( select gjh.jl_jrnl_hdr_id
                                                          from rdr.rr_glint_to_slr_ag  gjh )
            and jh.jh_jrnl_internal_period_flag = 'N'              
            and ((jl.jl_segment_1 = 'UKGAAP_ADJ' and fgl.lk_lookup_value5 = 'N')
                 or jl.jl_segment_1 <> 'UKGAAP_ADJ') ) gjl
 group by
       gjl.jl_entity
     , gjl.jl_segment_1
     , gjl.jl_effective_date
     , gjl.jl_tran_ccy
     , gjl.jl_base_ccy
     , gjl.jl_account
     , gjl.jl_segment_3
     , gjl.jl_segment_4
     , gjl.program_code
     , gjl.jl_segment_5
     , gjl.event_class
     , gjl.jl_jrnl_hdr_id
     , gjl.event_status
     , gjl.ejt_madj_flag
     , gjl.jl_created_by
     , gjl.jh_jrnl_authorised_by
     , gjl.jh_jrnl_type
     , gjl.jh_jrnl_description       
;
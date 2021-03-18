create or replace view rdr.rrv_ag_glint_jl_manual
as
select --In progress manual journals
       null				          rgjl_id
     , null                       rgjl_rgj_id
     , gjlu.jlu_entity            business_unit_gl
     , null                       journal_id
     , null                       journal_date
     , null                       journal_line
     , null                       rgjl_rgj_rgbc_id
     , gjlu.jlu_jrnl_hdr_id       rgjl_aah_journal
     , gjlu.jlu_jrnl_line_number  rgjl_aah_journal_line
     , null                       input_time
     , null                       input_user
     , gjlu.jlu_amended_on        modified_time
     , gjlu.jlu_amended_by        modified_user
     , null                       gl_distrib_status
     , null                       appl_jrnl_id
     , gjlu.jlu_segment_1         ledger_group
     , null                       ledger
     , gjlu.jlu_effective_date    accounting_dt
     , null                       fiscal_year
     , null                       accounting_period
     , gjlu.jlu_tran_ccy          foreign_currency
     , sum(gjlu.jlu_tran_amount)  foreign_amount
     , gjlu.jlu_base_ccy          currency_cd
     , sum(gjlu.jlu_base_amount)  monetary_amount
     , gjlu.jlu_account           account
     , gjlu.jlu_segment_3         deptid
     , null                       product
     , gjlu.jlu_segment_4         affiliate
     , gjlu.program_code          program_code
     , gjlu.jlu_segment_5         chartfield1
     , null                       line_descr
     , null                       jrnl_ln_ref
     , null                       process_instance
     , null                       notes_254
     , null                       dttm_stamp
     , gjlu.event_class           event_class
     , null                       aah_jrnl_hdr_nbr
     , sum(gjlu.credit_amt)       credit_amt
     , sum(gjlu.debit_amt)        debit_amt
     , gjlu.event_status          event_status
     , null                       slr_process_id
     , gjlu.ejt_madj_flag         manual_je
     , null                       ps_filter
     , gjlu.jlu_created_by        created_by
     , null                       approved_by
     , gjlu.jhu_jrnl_type         jh_jrnl_type
     , gjlu.jhu_jrnl_description  jh_jrnl_description
	 , gjlu.jhu_jrnl_source         jhu_jrnl_source
	 , gjlu.jhu_jrnl_authorised_by authorized_by
     , gjlu.jhu_jrnl_authorised_on authorized_on
  from ( select
                jlu_jrnl_hdr_id
              , case when jt.ejt_madj_flag = 'Y' then jlu_jrnl_hdr_id else 0 end                           jlu_jrnl_hdr_id2
              , cast( jlu_jrnl_line_number as number(5,0) )                                                jlu_jrnl_line_number
              , jlu_fak_id
              , jlu_eba_id
              , jlu_jrnl_status
              , jlu_jrnl_status_text
              , cast( jlu_jrnl_process_id as number(8,0) )                                                 jlu_jrnl_process_id
              , cast( nvl( jlu_description , ' ' ) as varchar2(30) )                                       jlu_description
              , cast( jlu_source_jrnl_id as varchar2(10) )                                                 jlu_source_jrnl_id
              , jlu_effective_date
              , jlu_value_date
              , cast( jlu_entity as varchar2(5) )                                                          jlu_entity
              , jlu_epg_id
              , cast( gl.ga_client_text4 as varchar2(10) )                                                 jlu_account
              , jlu_account                                                                                jlu_sub_account
              , cast ( case when jlu_segment_1 = 'NVS' then ' ' else jlu_segment_1 end as varchar2(10) )   jlu_segment_1
              , case when jlu_segment_2 = 'NVS' then ' ' else jlu_segment_2 end                            jlu_segment_2
              , cast ( case when jlu_segment_3 = 'NVS' then ' ' else jlu_segment_3 end as varchar2(10) )   jlu_segment_3
              , cast ( case when jlu_segment_4 = 'NVS' then ' ' else jlu_segment_4 end as varchar2(5) )    jlu_segment_4
              , cast ( case when jlu_segment_5 = 'NVS' then ' ' else jlu_segment_5 end as varchar2(10) )   jlu_segment_5
              , case when jlu_entity LIKE 'E%' then 'MNCON' else ' ' end                                   program_code
              , case when jlu_segment_7 = 'NVS' then ' ' else jlu_segment_7 end                            jlu_segment_7
              , case when jlu_segment_8 = 'NVS' then ' ' else jlu_segment_8 end                            jlu_segment_8
              , case when jlu_segment_9 = 'NVS' then ' ' else jlu_segment_9 end                            jlu_segment_9
              , case when jlu_segment_10 = 'NVS' then ' ' else jlu_segment_10 end                          jlu_segment_10
              , case when jlu_attribute_1 = 'NVS' then ' ' else jlu_attribute_1 end                        jlu_attribute_1
              , case when jlu_attribute_2 = 'NVS' then ' ' else jlu_attribute_2 end                        jlu_attribute_2
              , case when jlu_attribute_3 = 'NVS' then ' ' else jlu_attribute_3 end                        jlu_attribute_3
              , case when jlu_attribute_4 = 'NVS' then ' ' else jlu_attribute_4 end                        jlu_attribute_4
              , case when jlu_attribute_5 = 'NVS' then ' ' else jlu_attribute_5 end                        jlu_attribute_5
              , case when jlu_reference_1 = 'NVS' then ' ' else jlu_reference_1 end                        jlu_reference_1
              , case when jlu_reference_2 = 'NVS' then ' ' else jlu_reference_2 end                        jlu_reference_2
              , case when jlu_reference_3 = 'NVS' then ' ' else jlu_reference_3 end                        jlu_reference_3
              , case when jlu_reference_4 = 'NVS' then ' ' else jlu_reference_4 end                        jlu_reference_4
              , case when jlu_reference_5 = 'NVS' then ' ' else jlu_reference_5 end                        jlu_reference_5
              , case when jlu_reference_6 = 'NVS' then ' ' else jlu_reference_6 end                        jlu_reference_6
              , case when jlu_reference_7 = 'NVS' then ' ' else jlu_reference_7 end                        jlu_reference_7
              , case when jlu_reference_8 = 'NVS' then ' ' else jlu_reference_8 end                        jlu_reference_8
              , case when jlu_reference_9 = 'NVS' then ' ' else jlu_reference_9 end                        jlu_reference_9
              , case when jlu_reference_10 = 'NVS' then ' ' else jlu_reference_10 end                      jlu_reference_10
              ---- replace tran_ccy with local_ccy
              ,CASE
                 WHEN JLU_SEGMENT_1 IN ('UKGAAP_ADJ', 'EURGAAPADJ') AND JLU_ATTRIBUTE_4 in ('FV_UPR_INITIAL','FV_UPR_WRITTEN','FV_UPR_CHANGE')
                 THEN
                     CAST (jlu_local_ccy AS VARCHAR2 (3))
                 ELSE
                     CAST (jlU_tran_ccy AS VARCHAR2 (3))
              END as jlu_tran_ccy
              --- repalce tran_amount with local_amount
              ,CASE
                 WHEN JLU_SEGMENT_1 IN ('UKGAAP_ADJ', 'EURGAAPADJ') AND JLU_ATTRIBUTE_4 in ('FV_UPR_INITIAL','FV_UPR_WRITTEN','FV_UPR_CHANGE')
                 THEN
                     ROUND (jlu_local_amount, 2)
                 ELSE
                     ROUND (jlu_tran_amount, 2)
              END AS jlu_tran_amount
              ----        

              , case
                  when jlu_segment_1 in ('UKGAAP_ADJ','EURGAAPADJ')
                  then jlu_local_rate
                  else jlu_base_rate
                end                                                                                        jlu_base_rate
              , case
                  when jlu_segment_1 in ('UKGAAP_ADJ','EURGAAPADJ')
                  then cast( jlu_local_ccy as varchar2(3) )
                  else cast( jlu_base_ccy as varchar2(3) )
                end                                                                                        jlu_base_ccy
              , case
                  when jlu_segment_1 in ('UKGAAP_ADJ','EURGAAPADJ')
                  then round( jlu_local_amount , 2 )
                  else round( jlu_base_amount , 2 )
                end                                                                                        jlu_base_amount
              , jlu_local_rate
              , jlu_local_ccy
              , round( jlu_local_amount , 2 )                                                              jlu_local_amount
              , jlu_created_by
              , jlu_created_on
              , jlu_amended_by
              , jlu_amended_on
              , nvl( substr( fgl.lk_lookup_value3 , 1 , 50 ) , ' ' )                                       event_class
              ---Adapt the credit and debit accordingly: based on local amount instead of transaction amount for the ledger / event type combinations
              ,CASE
                 WHEN JLU_SEGMENT_1 IN ('UKGAAP_ADJ', 'EURGAAPADJ') AND JLU_ATTRIBUTE_4 in ('FV_UPR_INITIAL','FV_UPR_WRITTEN','FV_UPR_CHANGE') 
                         AND jlu_local_amount < 0 THEN ROUND (jlu_local_amount, 2)
                 WHEN jlu_tran_amount < 0 THEN ROUND (jlu_tran_amount, 2)
                 ELSE 0
              END
                 AS credit_amt
              ,CASE
                  WHEN JLU_SEGMENT_1 IN ('UKGAAP_ADJ', 'EURGAAPADJ') AND JLU_ATTRIBUTE_4 in ('FV_UPR_INITIAL','FV_UPR_WRITTEN','FV_UPR_CHANGE') 
                         AND jlu_local_amount >= 0 THEN ROUND (jlu_local_amount, 2)
                 WHEN jlu_tran_amount >= 0 THEN ROUND (jlu_tran_amount, 2)
                 ELSE 0
              END
                 AS debit_amt
              , jl.jlu_jrnl_status   event_status
              , jl.jlu_jrnl_process_id
              , jt.ejt_madj_flag
              , jh.jhu_jrnl_type            
              , jh.jhu_jrnl_description
			  , jh.jhu_jrnl_source
			  , gjhu.jhu_jrnl_authorised_by 
              , gjhu.jhu_jrnl_authorised_on 
           from
                gui.gui_jrnl_lines_unposted   jl
      left join fdr.fr_general_lookup         fgl   on jl.jlu_attribute_4          = fgl.lk_match_key1
                                                   and fgl.lk_lkt_lookup_type_code = 'EVENT_HIERARCHY'
      left join fdr.fr_gl_account             gl    on jl.jlu_account              = gl.ga_account_code
      left join gui.gui_jrnl_headers_unposted jh    on jh.jhu_jrnl_id              = jl.jlu_jrnl_hdr_id
      left join gui.gui_jrnl_line_errors      jle   on jl.jlu_jrnl_hdr_id          = jle.jle_jrnl_hdr_id
												   and jl.jlu_jrnl_line_number     = jle.jle_jrnl_line_number
      left join slr.slr_ext_jrnl_types        jt    on jt.ejt_type                 = jh.jhu_jrnl_type
      left join gui.gui_jrnl_headers_unposted gjhu  on jl.jlu_jrnl_hdr_id          = gjhu.jhu_jrnl_id        ) gjlu
 group by
 	   gjlu.jlu_jrnl_hdr_id
     , gjlu.jlu_jrnl_line_number
	 , gjlu.jlu_entity
     , gjlu.jlu_segment_1
     , gjlu.jlu_effective_date
     , gjlu.jlu_tran_ccy
     , gjlu.jlu_base_ccy
     , gjlu.jlu_account
     , gjlu.jlu_segment_3
     , gjlu.jlu_segment_4
     , gjlu.program_code
     , gjlu.jlu_segment_5
     , gjlu.event_class
     , gjlu.event_status
     , gjlu.ejt_madj_flag
     , gjlu.jlu_created_by
     , gjlu.jhu_jrnl_type            
     , gjlu.jhu_jrnl_description
	 , gjlu.jhu_jrnl_source
	 , gjlu.jlu_amended_on
     , gjlu.jlu_amended_by
     , gjlu.jhu_jrnl_authorised_by 
     , gjlu.jhu_jrnl_authorised_on;
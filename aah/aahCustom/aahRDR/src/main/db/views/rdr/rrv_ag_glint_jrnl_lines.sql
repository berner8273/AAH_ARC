create or replace view rdr.rrv_ag_glint_jrnl_lines
(
   rgjl_id,
   rgjl_rgj_id,
   business_unit_gl,
   journal_id,
   journal_date,
   journal_line,
   rgjl_rgj_rgbc_id,
   rgjl_aah_journal,
   rgjl_aah_journal_line,
   input_time,
   input_user,
   modified_time,
   modified_user,
   gl_distrib_status,
   appl_jrnl_id,
   ledger_group,
   ledger,
   accounting_dt,
   fiscal_year,
   accounting_period,
   foreign_currency,
   foreign_amount,
   currency_cd,
   monetary_amount,
   account,
   deptid,
   product,
   affiliate,
   program_code,
   chartfield1,
   line_descr,
   jrnl_ln_ref,
   process_instance,
   notes_254,
   dttm_stamp,
   event_class,
   aah_jrnl_hdr_nbr,
   credit_amt,
   debit_amt,
   event_status,
   slr_process_id,
   manual_je,
   ps_filter,
   created_by,
   approved_by, 
   jh_jrnl_type, 
   jh_jrnl_description 
)
as
   select gjl.rgjl_id,
          gjl.rgjl_rgj_id,
          gjl.business_unit_gl,
          gjl.journal_id,
          gjl.journal_date,
          gjl.journal_line,
          gjl.rgjl_rgj_rgbc_id,
          gjl.rgjl_aah_journal,
          gjl.rgjl_aah_journal_line,
          gjl.input_time,
          gjl.input_user,
          gjl.modified_time,
          gjl.modified_user,
          gjl.gl_distrib_status,
          gjl.appl_jrnl_id,
          gjl.ledger_group,
          gjl.ledger,
          gjl.accounting_dt,
          gjl.fiscal_year,
          gjl.accounting_period,
          gjl.foreign_currency,
          gjl.foreign_amount,
          gjl.currency_cd,
          gjl.monetary_amount,
          gjl.account,
          gjl.deptid,
          gjl.product,
          gjl.affiliate,
          gjl.program_code,
          gjl.chartfield1,
          gjl.line_descr,
          gjl.jrnl_ln_ref,
          gjl.process_instance,
          gjl.notes_254,
          gjl.dttm_stamp,
          gjl.event_class,
          gjl.aah_jrnl_hdr_nbr,
          gjl.credit_amt,
          gjl.debit_amt,
          gjl.event_status,
          gjl.slr_process_id,
          gjl.manual_je,
          gjl.ps_filter,
          null created_by,
          null approved_by, 
          gjl.jh_jrnl_type, 
          gjl.jh_jrnl_description  
     from rdr.rr_glint_journal_line gjl
   union all
     select                                      --in progress manual journals
           null rgjl_id,
            null rgjl_rgj_id,
            gjlu.jlu_entity business_unit_gl,
            null journal_id,
            null journal_date,
            null journal_line,
            null rgjl_rgj_rgbc_id,
            null rgjl_aah_journal,
            null rgjl_aah_journal_line,
            null input_time,
            null input_user,
            null modified_time,
            null modified_user,
            null gl_distrib_status,
            null appl_jrnl_id,
            gjlu.jlu_segment_1 ledger_group,
            null ledger,
            gjlu.jlu_effective_date accounting_dt,
            null fiscal_year,
            null accounting_period,
            gjlu.jlu_tran_ccy foreign_currency,
            sum (gjlu.jlu_tran_amount) foreign_amount,
            gjlu.jlu_base_ccy currency_cd,
            sum (gjlu.jlu_base_amount) monetary_amount,
            gjlu.jlu_account account,
            gjlu.jlu_segment_3 deptid,
            null product,
            gjlu.jlu_segment_4 affiliate,
            gjlu.program_code program_code,
            gjlu.jlu_segment_5 chartfield1,
            null line_descr,
            null jrnl_ln_ref,
            null process_instance,
            null notes_254,
            null dttm_stamp,
            gjlu.event_class event_class,
            null aah_jrnl_hdr_nbr,
            sum (gjlu.credit_amt) credit_amt,
            sum (gjlu.debit_amt) debit_amt,
            gjlu.event_status event_status,
            null slr_process_id,
            gjlu.ejt_madj_flag manual_je,
            null ps_filter,
            gjlu.jlu_created_by created_by,
            null approved_by, 
            gjlu.jhu_jrnl_type  jh_jrnl_type, 
            gjlu.jhu_jrnl_description  jh_jrnl_description  
       from (select jlu_jrnl_hdr_id,
                    case
                       when jt.ejt_madj_flag = 'Y' then jlu_jrnl_hdr_id
                       else 0
                    end
                       jlu_jrnl_hdr_id2,
                    cast (jlu_jrnl_line_number as number (5, 0))
                       jlu_jrnl_line_number,
                    jlu_fak_id,
                    jlu_eba_id,
                    jlu_jrnl_status,
                    jlu_jrnl_status_text,
                    cast (jlu_jrnl_process_id as number (8, 0))
                       jlu_jrnl_process_id,
                    cast (nvl (jlu_description, ' ') as varchar2 (30))
                       jlu_description,
                    cast (jlu_source_jrnl_id as varchar2 (10))
                       jlu_source_jrnl_id,
                    jlu_effective_date,
                    jlu_value_date,
                    cast (jlu_entity as varchar2 (5)) jlu_entity,
                    jlu_epg_id,
                    cast (gl.ga_client_text4 as varchar2 (10)) jlu_account,
                    jlu_account jlu_sub_account,
                    cast (
                       case
                          when jlu_segment_1 = 'NVS' then ' '
                          else jlu_segment_1
                       end as varchar2 (10))
                       jlu_segment_1,
                    case
                       when jlu_segment_2 = 'NVS' then ' '
                       else jlu_segment_2
                    end
                       jlu_segment_2,
                    cast (
                       case
                          when jlu_segment_3 = 'NVS' then ' '
                          else jlu_segment_3
                       end as varchar2 (10))
                       jlu_segment_3,
                    cast (
                       case
                          when jlu_segment_4 = 'NVS' then ' '
                          else jlu_segment_4
                       end as varchar2 (5))
                       jlu_segment_4,
                    cast (
                       case
                          when jlu_segment_5 = 'NVS' then ' '
                          else jlu_segment_5
                       end as varchar2 (10))
                       jlu_segment_5,
                    case when jlu_entity like 'E%' then 'MNCON' else ' ' end
                       program_code,
                    case
                       when jlu_segment_7 = 'NVS' then ' '
                       else jlu_segment_7
                    end
                       jlu_segment_7,
                    case
                       when jlu_segment_8 = 'NVS' then ' '
                       else jlu_segment_8
                    end
                       jlu_segment_8,
                    case
                       when jlu_segment_9 = 'NVS' then ' '
                       else jlu_segment_9
                    end
                       jlu_segment_9,
                    case
                       when jlu_segment_10 = 'NVS' then ' '
                       else jlu_segment_10
                    end
                       jlu_segment_10,
                    case
                       when jlu_attribute_1 = 'NVS' then ' '
                       else jlu_attribute_1
                    end
                       jlu_attribute_1,
                    case
                       when jlu_attribute_2 = 'NVS' then ' '
                       else jlu_attribute_2
                    end
                       jlu_attribute_2,
                    case
                       when jlu_attribute_3 = 'NVS' then ' '
                       else jlu_attribute_3
                    end
                       jlu_attribute_3,
                    case
                       when jlu_attribute_4 = 'NVS' then ' '
                       else jlu_attribute_4
                    end
                       jlu_attribute_4,
                    case
                       when jlu_attribute_5 = 'NVS' then ' '
                       else jlu_attribute_5
                    end
                       jlu_attribute_5,
                    case
                       when jlu_reference_1 = 'NVS' then ' '
                       else jlu_reference_1
                    end
                       jlu_reference_1,
                    case
                       when jlu_reference_2 = 'NVS' then ' '
                       else jlu_reference_2
                    end
                       jlu_reference_2,
                    case
                       when jlu_reference_3 = 'NVS' then ' '
                       else jlu_reference_3
                    end
                       jlu_reference_3,
                    case
                       when jlu_reference_4 = 'NVS' then ' '
                       else jlu_reference_4
                    end
                       jlu_reference_4,
                    case
                       when jlu_reference_5 = 'NVS' then ' '
                       else jlu_reference_5
                    end
                       jlu_reference_5,
                    case
                       when jlu_reference_6 = 'NVS' then ' '
                       else jlu_reference_6
                    end
                       jlu_reference_6,
                    case
                       when jlu_reference_7 = 'NVS' then ' '
                       else jlu_reference_7
                    end
                       jlu_reference_7,
                    case
                       when jlu_reference_8 = 'NVS' then ' '
                       else jlu_reference_8
                    end
                       jlu_reference_8,
                    case
                       when jlu_reference_9 = 'NVS' then ' '
                       else jlu_reference_9
                    end
                       jlu_reference_9,
                    case
                       when jlu_reference_10 = 'NVS' then ' '
                       else jlu_reference_10
                    end
                       jlu_reference_10,
                    cast (jlu_tran_ccy as varchar2 (3)) jlu_tran_ccy,
                    round (jlu_tran_amount, 2) jlu_tran_amount,                   
                    case
                       when jlu_segment_1 in ('UKGAAP_ADJ','EURGAAPADJ')
                       then
                          jlu_local_rate
                       else
                          jlu_base_rate
                    end
                       jlu_base_rate,
                    case
                       when jlu_segment_1 in ('UKGAAP_ADJ','EURGAAPADJ')
                       then
                          cast (jlu_local_ccy as varchar2 (3))
                       else
                          cast (jlu_base_ccy as varchar2 (3))
                    end
                       jlu_base_ccy,
                    case
                       when jlu_segment_1 in ('UKGAAP_ADJ','EURGAAPADJ')
                       then
                          round (jlu_local_amount, 2)
                       else
                          round (jlu_base_amount, 2)
                    end
                       jlu_base_amount,
                    jlu_local_rate,
                    jlu_local_ccy,
                    round (jlu_local_amount, 2) jlu_local_amount,
                    jlu_created_by,
                    jlu_created_on,
                    jlu_amended_by,
                    jlu_amended_on,
                    (nvl (substr(fgl.lk_lookup_value3,1,50), ' ')) event_class,
                    case
                       when jlu_tran_amount < 0 then round (jlu_tran_amount, 2)
                       else null
                    end
                       credit_amt,
                    case
                       when jlu_tran_amount >= 0
                       then
                          round (jlu_tran_amount, 2)
                       else
                          null
                    end
                       debit_amt,
                    case
                       when jle.jle_jrnl_hdr_id is not null then 'E'
                       else jl.jlu_jrnl_status
                    end
                       event_status,
                    jl.jlu_jrnl_process_id,
                    jt.ejt_madj_flag, 
                    jh.jhu_jrnl_type, 
                    jh.jhu_jrnl_description 
               from gui.gui_jrnl_lines_unposted jl
                    left join fdr.fr_general_lookup fgl
                       on     jl.jlu_attribute_4 = fgl.lk_match_key1
                          and fgl.lk_lkt_lookup_type_code = 'EVENT_HIERARCHY'
                    left join fdr.fr_gl_account gl
                       on jl.jlu_account = gl.ga_account_code
                    left join gui.gui_jrnl_headers_unposted jh
                       on jh.jhu_jrnl_id = jl.jlu_jrnl_hdr_id
                    left join gui.gui_jrnl_line_errors jle
                       on jl.jlu_jrnl_hdr_id = jle.jle_jrnl_hdr_id
                    left join slr.slr_ext_jrnl_types jt
                       on jt.ejt_type = jh.jhu_jrnl_type) gjlu
   group by gjlu.jlu_entity,
            gjlu.jlu_segment_1,
            gjlu.jlu_effective_date,
            gjlu.jlu_tran_ccy,
            gjlu.jlu_base_ccy,
            gjlu.jlu_account,
            gjlu.jlu_segment_3,
            gjlu.jlu_segment_4,
            gjlu.program_code,
            gjlu.jlu_segment_5,
            gjlu.event_class,
            gjlu.event_status,
            gjlu.ejt_madj_flag,
            gjlu.jlu_created_by,
            gjlu.jhu_jrnl_type,
            gjlu.jhu_jrnl_description
   union all
     select                        --unposted slr journals not glint processed
           null rgjl_id,
            null rgjl_rgj_id,
            sjlu.jlu_entity business_unit_gl,
            null journal_id,
            null journal_date,
            null journal_line,
            null rgjl_rgj_rgbc_id,
            null rgjl_aah_journal,
            null rgjl_aah_journal_line,
            null input_time,
            null input_user,
            null modified_time,
            null modified_user,
            null gl_distrib_status,
            null appl_jrnl_id,
            sjlu.jlu_segment_1 ledger_group,
            null ledger,
            sjlu.jlu_effective_date accounting_dt,
            null fiscal_year,
            null accounting_period,
            sjlu.jlu_tran_ccy foreign_currency,
            sum (sjlu.jlu_tran_amount) foreign_amount,
            sjlu.jlu_base_ccy currency_cd,
            sum (sjlu.jlu_base_amount) monetary_amount,
            sjlu.jlu_account account,
            sjlu.jlu_segment_3 deptid,
            null product,
            sjlu.jlu_segment_4 affiliate,
            sjlu.program_code program_code,
            sjlu.jlu_segment_5 chartfield1,
            null line_descr,
            null jrnl_ln_ref,
            null process_instance,
            null notes_254,
            null dttm_stamp,
            sjlu.event_class event_class,
            null aah_jrnl_hdr_nbr,
            sum (sjlu.credit_amt) credit_amt,
            sum (sjlu.debit_amt) debit_amt,
            sjlu.event_status event_status,
            null slr_process_id,
            sjlu.ejt_madj_flag manual_je,
            null ps_filter,
            sjlu.jlu_created_by created_by,
            sjlu.jhu_jrnl_authorised_by approved_by,
            sjlu.jhu_jrnl_type jh_jrnl_type,
            sjlu.jhu_jrnl_description  jh_jrnl_description  
       from (select jlu_jrnl_hdr_id,
                    case
                       when jt.ejt_madj_flag = 'Y' then jlu_jrnl_hdr_id
                       else 0
                    end
                       jlu_jrnl_hdr_id2,
                    cast (jlu_jrnl_line_number as number (5, 0))
                       jlu_jrnl_line_number,
                    jlu_fak_id,
                    jlu_eba_id,
                    jlu_jrnl_status,
                    jlu_jrnl_status_text,
                    cast (jlu_jrnl_process_id as number (8, 0))
                       jlu_jrnl_process_id,
                    cast (nvl (jlu_description, ' ') as varchar2 (30))
                       jlu_description,
                    cast (jlu_source_jrnl_id as varchar2 (10))
                       jlu_source_jrnl_id,
                    jlu_effective_date,
                    jlu_value_date,
                    cast (jlu_entity as varchar2 (5)) jlu_entity,
                    jlu_epg_id,
                    cast (gl.ga_client_text4 as varchar2 (10)) jlu_account,
                    jlu_account jlu_sub_account,
                    cast (
                       case
                          when jlu_segment_1 = 'NVS' then ' '
                          else jlu_segment_1
                       end as varchar2 (10))
                       jlu_segment_1,
                    case
                       when jlu_segment_2 = 'NVS' then ' '
                       else jlu_segment_2
                    end
                       jlu_segment_2,
                    cast (
                       case
                          when jlu_segment_3 = 'NVS' then ' '
                          else jlu_segment_3
                       end as varchar2 (10))
                       jlu_segment_3,
                    cast (
                       case
                          when jlu_segment_4 = 'NVS' then ' '
                          else jlu_segment_4
                       end as varchar2 (5))
                       jlu_segment_4,
                    cast (
                       case
                          when jlu_segment_5 = 'NVS' then ' '
                          else jlu_segment_5
                       end as varchar2 (10))
                       jlu_segment_5,
                    case when jlu_entity like 'E%' then 'MNCON' else ' ' end
                       program_code,
                    case
                       when jlu_segment_7 = 'NVS' then ' '
                       else jlu_segment_7
                    end
                       jlu_segment_7,
                    case
                       when jlu_segment_8 = 'NVS' then ' '
                       else jlu_segment_8
                    end
                       jlu_segment_8,
                    case
                       when jlu_segment_9 = 'NVS' then ' '
                       else jlu_segment_9
                    end
                       jlu_segment_9,
                    case
                       when jlu_segment_10 = 'NVS' then ' '
                       else jlu_segment_10
                    end
                       jlu_segment_10,
                    case
                       when jlu_attribute_1 = 'NVS' then ' '
                       else jlu_attribute_1
                    end
                       jlu_attribute_1,
                    case
                       when jlu_attribute_2 = 'NVS' then ' '
                       else jlu_attribute_2
                    end
                       jlu_attribute_2,
                    case
                       when jlu_attribute_3 = 'NVS' then ' '
                       else jlu_attribute_3
                    end
                       jlu_attribute_3,
                    case
                       when jlu_attribute_4 = 'NVS' then ' '
                       else jlu_attribute_4
                    end
                       jlu_attribute_4,
                    case
                       when jlu_attribute_5 = 'NVS' then ' '
                       else jlu_attribute_5
                    end
                       jlu_attribute_5,
                    case
                       when jlu_reference_1 = 'NVS' then ' '
                       else jlu_reference_1
                    end
                       jlu_reference_1,
                    case
                       when jlu_reference_2 = 'NVS' then ' '
                       else jlu_reference_2
                    end
                       jlu_reference_2,
                    case
                       when jlu_reference_3 = 'NVS' then ' '
                       else jlu_reference_3
                    end
                       jlu_reference_3,
                    case
                       when jlu_reference_4 = 'NVS' then ' '
                       else jlu_reference_4
                    end
                       jlu_reference_4,
                    case
                       when jlu_reference_5 = 'NVS' then ' '
                       else jlu_reference_5
                    end
                       jlu_reference_5,
                    case
                       when jlu_reference_6 = 'NVS' then ' '
                       else jlu_reference_6
                    end
                       jlu_reference_6,
                    case
                       when jlu_reference_7 = 'NVS' then ' '
                       else jlu_reference_7
                    end
                       jlu_reference_7,
                    case
                       when jlu_reference_8 = 'NVS' then ' '
                       else jlu_reference_8
                    end
                       jlu_reference_8,
                    case
                       when jlu_reference_9 = 'NVS' then ' '
                       else jlu_reference_9
                    end
                       jlu_reference_9,
                    case
                       when jlu_reference_10 = 'NVS' then ' '
                       else jlu_reference_10
                    end
                       jlu_reference_10,
                    cast (jlu_tran_ccy as varchar2 (3)) jlu_tran_ccy,
                    round (jlu_tran_amount, 2) jlu_tran_amount,
                    case
                       when jlu_segment_1 in ('UKGAAP_ADJ','EURGAAPADJ')
                       then
                          jlu_local_rate
                       else
                          jlu_base_rate
                    end                    
                       jlu_base_rate,
                    case
                       when jlu_segment_1 in ('UKGAAP_ADJ','EURGAAPADJ')
                       then
                          cast (jlu_local_ccy as varchar2 (3))
                       else
                          cast (jlu_base_ccy as varchar2 (3))
                    end
                       jlu_base_ccy,
                    case
                       when jlu_segment_1 in ('UKGAAP_ADJ','EURGAAPADJ')
                       then
                          round (jlu_local_amount, 2)
                       else
                          round (jlu_base_amount, 2)
                    end
                       jlu_base_amount,
                    jlu_local_rate,
                    jlu_local_ccy,
                    round (jlu_local_amount, 2) jlu_local_amount,
                    jlu_created_by,
                    jlu_created_on,
                    jlu_amended_by,
                    jlu_amended_on,
                    jhu_jrnl_authorised_by,
                    nvl (fgl.lk_lookup_value3, ' ') event_class,
                    case
                       when jlu_tran_amount < 0 then round (jlu_tran_amount, 2)
                       else null
                    end
                       credit_amt,
                    case
                       when jlu_tran_amount >= 0
                       then
                          round (jlu_tran_amount, 2)
                       else
                          null
                    end
                       debit_amt,
                    sjl.jlu_jrnl_status event_status,
                    sjl.jlu_jrnl_process_id,
                    jt.ejt_madj_flag,
                    jh.jhu_jrnl_type,
                    jh.jhu_jrnl_description 
               from slr.slr_jrnl_lines_unposted sjl
                    left join fdr.fr_general_lookup fgl
                       on     sjl.jlu_attribute_4 = fgl.lk_match_key1
                          and fgl.lk_lkt_lookup_type_code = 'EVENT_HIERARCHY'
                    left join fdr.fr_gl_account gl
                       on sjl.jlu_account = gl.ga_account_code
                    left join slr.slr_jrnl_headers_unposted jh
                       on jh.jhu_jrnl_id = sjl.jlu_jrnl_hdr_id
                    left join slr.slr_ext_jrnl_types jt
                       on jt.ejt_type = jh.jhu_jrnl_type) sjlu
   group by sjlu.jlu_entity,
            sjlu.jlu_segment_1,
            sjlu.jlu_effective_date,
            sjlu.jlu_tran_ccy,
            sjlu.jlu_base_ccy,
            sjlu.jlu_account,
            sjlu.jlu_segment_3,
            sjlu.jlu_segment_4,
            sjlu.program_code,
            sjlu.jlu_segment_5,
            sjlu.event_class,
            sjlu.event_status,
            sjlu.ejt_madj_flag,
            sjlu.jlu_created_by,
            sjlu.jhu_jrnl_authorised_by, 
            sjlu.jhu_jrnl_type,
            sjlu.jhu_jrnl_description
   union all
     select                      --posted slr journals not yet glint processed
           null rgjl_id,
            null rgjl_rgj_id,
            gjl.jl_entity business_unit_gl,
            null journal_id,
            null journal_date,
            null journal_line,
            null rgjl_rgj_rgbc_id,
            null rgjl_aah_journal,
            null rgjl_aah_journal_line,
            null input_time,
            null input_user,
            null modified_time,
            null modified_user,
            null gl_distrib_status,
            null appl_jrnl_id,
            gjl.jl_segment_1 ledger_group,
            null ledger,
            gjl.jl_effective_date accounting_dt,
            null fiscal_year,
            null accounting_period,
            gjl.jl_tran_ccy foreign_currency,
            sum (gjl.jl_tran_amount) foreign_amount,
            gjl.jl_base_ccy currency_cd,
            sum (gjl.jl_base_amount) monetary_amount,
            gjl.jl_account account,
            gjl.jl_segment_3 deptid,
            null product,
            gjl.jl_segment_4 affiliate,
            gjl.program_code program_code,
            gjl.jl_segment_5 chartfield1,
            null line_descr,
            null jrnl_ln_ref,
            null process_instance,
            null notes_254,
            null dttm_stamp,
            gjl.event_class event_class,
            gjl.jl_jrnl_hdr_id aah_jrnl_hdr_nbr,
            sum (gjl.credit_amt) credit_amt,
            sum (gjl.debit_amt) debit_amt,
            gjl.event_status event_status,
            null slr_process_id,
            gjl.ejt_madj_flag manual_je,
            null ps_filter,
            gjl.jl_created_by created_by,
            gjl.jh_jrnl_authorised_by approved_by, 
            gjl.jh_jrnl_type,
            gjl.jh_jrnl_description 
       from (select jl_jrnl_hdr_id,
                    case
                       when jt.ejt_madj_flag = 'Y' then jl_jrnl_hdr_id
                       else 0
                    end
                       jl_jrnl_hdr_id2,
                    cast (jl_jrnl_line_number as number (5, 0))
                       jl_jrnl_line_number,
                    jl_fak_id,
                    jl_eba_id,
                    jl_jrnl_status,
                    jl_jrnl_status_text,
                    cast (jl_jrnl_process_id as number (8, 0))
                       jl_jrnl_process_id,
                    cast (nvl (jl_description, ' ') as varchar2 (30))
                       jl_description,
                    cast (jl_source_jrnl_id as varchar2 (10)) jl_source_jrnl_id,
                    jl_effective_date,
                    jl_value_date,
                    cast (jl_entity as varchar2 (5)) jl_entity,
                    jl_epg_id,
                    cast (gl.ga_client_text4 as varchar2 (10)) jl_account,
                    jl_account jl_sub_account,
                    cast (
                       case
                          when jl_segment_1 = 'NVS' then ' '
                          else jl_segment_1
                       end as varchar2 (10))
                       jl_segment_1,
                    case
                       when jl_segment_2 = 'NVS' then ' '
                       else jl_segment_2
                    end
                       jl_segment_2,
                    cast (
                       case
                          when jl_segment_3 = 'NVS' then ' '
                          else jl_segment_3
                       end as varchar2 (10))
                       jl_segment_3,
                    cast (
                       case
                          when jl_segment_4 = 'NVS' then ' '
                          else jl_segment_4
                       end as varchar2 (5))
                       jl_segment_4,
                    cast (
                       case
                          when jl_segment_5 = 'NVS' then ' '
                          else jl_segment_5
                       end as varchar2 (10))
                       jl_segment_5,
                    case when jl_entity like 'E%' then 'MNCON' else ' ' end
                       program_code,
                    case
                       when jl_segment_7 = 'NVS' then ' '
                       else jl_segment_7
                    end
                       jl_segment_7,
                    case
                       when jl_segment_8 = 'NVS' then ' '
                       else jl_segment_8
                    end
                       jl_segment_8,
                    case
                       when jl_segment_9 = 'NVS' then ' '
                       else jl_segment_9
                    end
                       jl_segment_9,
                    case
                       when jl_segment_10 = 'NVS' then ' '
                       else jl_segment_10
                    end
                       jl_segment_10,
                    case
                       when jl_attribute_1 = 'NVS' then ' '
                       else jl_attribute_1
                    end
                       jl_attribute_1,
                    case
                       when jl_attribute_2 = 'NVS' then ' '
                       else jl_attribute_2
                    end
                       jl_attribute_2,
                    case
                       when jl_attribute_3 = 'NVS' then ' '
                       else jl_attribute_3
                    end
                       jl_attribute_3,
                    case
                       when jl_attribute_4 = 'NVS' then ' '
                       else jl_attribute_4
                    end
                       jl_attribute_4,
                    case
                       when jl_attribute_5 = 'NVS' then ' '
                       else jl_attribute_5
                    end
                       jl_attribute_5,
                    case
                       when jl_reference_1 = 'NVS' then ' '
                       else jl_reference_1
                    end
                       jl_reference_1,
                    case
                       when jl_reference_2 = 'NVS' then ' '
                       else jl_reference_2
                    end
                       jl_reference_2,
                    case
                       when jl_reference_3 = 'NVS' then ' '
                       else jl_reference_3
                    end
                       jl_reference_3,
                    case
                       when jl_reference_4 = 'NVS' then ' '
                       else jl_reference_4
                    end
                       jl_reference_4,
                    case
                       when jl_reference_5 = 'NVS' then ' '
                       else jl_reference_5
                    end
                       jl_reference_5,
                    case
                       when jl_reference_6 = 'NVS' then ' '
                       else jl_reference_6
                    end
                       jl_reference_6,
                    case
                       when jl_reference_7 = 'NVS' then ' '
                       else jl_reference_7
                    end
                       jl_reference_7,
                    case
                       when jl_reference_8 = 'NVS' then ' '
                       else jl_reference_8
                    end
                       jl_reference_8,
                    case
                       when jl_reference_9 = 'NVS' then ' '
                       else jl_reference_9
                    end
                       jl_reference_9,
                    case
                       when jl_reference_10 = 'NVS' then ' '
                       else jl_reference_10
                    end
                       jl_reference_10,
                    cast (jl_tran_ccy as varchar2 (3)) jl_tran_ccy,
                    round (jl_tran_amount, 2) jl_tran_amount,
                    jl_base_rate,
                    case
                       when jl_segment_1 = 'UKGAAP_ADJ'
                       then
                          cast (jl_local_ccy as varchar2 (3))
                       else
                          cast (jl_base_ccy as varchar2 (3))
                    end
                       jl_base_ccy,
                    case
                       when jl_segment_1 = 'UKGAAP_ADJ'
                       then
                          round (jl_local_amount, 2)
                       else
                          round (jl_base_amount, 2)
                    end
                       jl_base_amount,
                    jl_local_rate,
                    jl_local_ccy,
                    round (jl_local_amount, 2) jl_local_amount,
                    jl_created_by,
                    jl_created_on,
                    jl_amended_by,
                    jl_amended_on,
                    jh.jh_jrnl_authorised_by,
                    nvl (fgl.lk_lookup_value3, ' ') event_class,
                    case
                       when jl_tran_amount < 0 then round (jl_tran_amount, 2)
                       else null
                    end
                       credit_amt,
                    case
                       when jl_tran_amount >= 0 then round (jl_tran_amount, 2)
                       else null
                    end
                       debit_amt,
                    null event_status,
                    jl.jl_jrnl_process_id,
                    jt.ejt_madj_flag, 
                    jh.jh_jrnl_type,
                    jh.jh_jrnl_description
               from slr.slr_jrnl_lines jl
                    join slr.slr_jrnl_headers jh
                       on jl.jl_jrnl_hdr_id = jh.jh_jrnl_id
                    left join fdr.fr_general_lookup fgl
                       on     jl.jl_attribute_4 = fgl.lk_match_key1
                          and fgl.lk_lkt_lookup_type_code = 'EVENT_HIERARCHY'
                    left join fdr.fr_gl_account gl
                       on jl.jl_account = gl.ga_account_code
                    left join slr.slr_ext_jrnl_types jt
                       on jt.ejt_type = jh.jh_jrnl_type
              where     jl.jl_jrnl_hdr_id not in (select gjh.jl_jrnl_hdr_id
                                                    from rdr.rr_glint_to_slr_ag gjh)
                    and jh.jh_jrnl_internal_period_flag = 'N') gjl
   group by gjl.jl_entity,
            gjl.jl_segment_1,
            gjl.jl_effective_date,
            gjl.jl_tran_ccy,
            gjl.jl_base_ccy,
            gjl.jl_account,
            gjl.jl_segment_3,
            gjl.jl_segment_4,
            gjl.program_code,
            gjl.jl_segment_5,
            gjl.event_class,
            gjl.jl_jrnl_hdr_id,
            gjl.event_status,
            gjl.ejt_madj_flag,
            gjl.jl_created_by,
            gjl.jh_jrnl_authorised_by,
            gjl.jh_jrnl_type,
            gjl.jh_jrnl_description;
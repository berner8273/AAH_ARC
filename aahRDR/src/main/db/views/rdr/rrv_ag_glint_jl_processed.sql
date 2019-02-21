create or replace view rdr.rrv_ag_glint_jl_processed
as
select
       gjl.rgjl_id
     , gjl.rgjl_rgj_id
     , gjl.business_unit_gl
     , gjl.journal_id
     , gjl.journal_date
     , gjl.journal_line
     , gjl.rgjl_rgj_rgbc_id
     , gjl.rgjl_aah_journal
     , gjl.rgjl_aah_journal_line
     , gjl.input_time
     , gjl.input_user
     , gjl.modified_time
     , gjl.modified_user
     , gjl.gl_distrib_status
     , gjl.appl_jrnl_id
     , gjl.ledger_group
     , gjl.ledger
     , gjl.accounting_dt
     , gjl.fiscal_year
     , gjl.accounting_period
     , gjl.foreign_currency
     , gjl.foreign_amount
     , gjl.currency_cd
     , gjl.monetary_amount
     , gjl.account
     , gjl.deptid
     , gjl.product
     , gjl.affiliate
     , gjl.program_code
     , gjl.chartfield1
     , gjl.line_descr
     , gjl.jrnl_ln_ref
     , gjl.process_instance
     , gjl.notes_254
     , gjl.dttm_stamp
     , gjl.event_class
     , gjl.aah_jrnl_hdr_nbr
     , gjl.credit_amt
     , gjl.debit_amt
     , gjl.event_status
     , gjl.slr_process_id
     , gjl.manual_je
     , gjl.ps_filter
     , null                       created_by
     , null                       approved_by
     , gjl.jh_jrnl_type
     , gjl.jh_jrnl_description     
  from
       rdr.rr_glint_journal_line gjl;
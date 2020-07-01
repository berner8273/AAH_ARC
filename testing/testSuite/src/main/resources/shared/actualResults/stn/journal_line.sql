select
       jl.correlation_id
     , jl.accounting_dt
     , jl.le_id
     , jl.acct_cd
     , jl.basis_cd
     , jl.ledger_cd
     , jl.policy_id
     , jl.stream_id
     , jl.affiliate_le_id
     , jl.counterparty_le_id
     , jl.dept_cd
     , jl.business_event_typ
     , jl.journal_descr
     , jl.chartfield_1
     , jl.accident_yr
     , jl.underwriting_yr
     , jl.tax_jurisdiction_cd
     , jl.event_seq_id
     , jl.business_typ
     , jl.premium_typ
     , jl.owner_le_id
     , jl.ultimate_parent_le_id
     , jl.event_typ
     , jl.transaction_ccy
     , jl.transaction_amt
     , jl.functional_ccy
     , jl.functional_amt
     , jl.reporting_ccy
     , jl.reporting_amt
     , jl.execution_typ
     , jl.lpg_id
     , jl.event_status
     , jl.feed_uuid
  from
       stn.journal_line jl

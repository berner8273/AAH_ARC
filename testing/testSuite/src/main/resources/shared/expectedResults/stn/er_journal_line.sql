select
       correlation_id
     , accounting_dt
     , le_id
     , acct_cd
     , basis_cd
     , ledger_cd
     , policy_id
     , stream_id
     , affiliate_le_id
     , counterparty_le_id
     , dept_cd
     , business_event_typ
     , journal_descr
     , chartfield_1
     , accident_yr
     , underwriting_yr
     , tax_jurisdiction_cd
     , event_seq_id
     , business_typ
     , premium_typ
     , owner_le_id
     , ultimate_parent_le_id
     , event_typ
     , transaction_ccy
     , transaction_amt
     , functional_ccy
     , functional_amt
     , reporting_ccy
     , reporting_amt
     , execution_typ
     , lpg_id
     , event_status
     , feed_uuid
  from
       er_journal_line
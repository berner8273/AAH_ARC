create or replace view stn.cession_event_posting
as
select
    'ORIGINAL' posting_type
  , correlation_uuid
  , event_seq_id
  , row_sid
  , sub_event
  , accounting_dt
  , policy_id
  , substrb(policy_abbr_nm,1,50) policy_abbr_nm
  , stream_id
  , basis_cd
  , business_typ
  , premium_typ
  , policy_premium_typ
  , policy_accident_yr
  , policy_underwriting_yr
  , ultimate_parent_stream_id
  , ultimate_parent_le_cd
  , execution_typ
  , policy_typ
  , event_typ
  , business_event_typ
  , business_unit
  , account_cd
  , bu_lookup
  , affiliate
  , owner_le_cd
  , counterparty_le_cd
  , ledger_cd
  , vie_cd
  , is_mark_to_market
  , tax_jurisdiction_cd
  , chartfield_cd
  , jl_description
  , transaction_ccy
  , transaction_amt
  , functional_ccy
  , functional_amt
  , reporting_ccy
  , reporting_amt
  , lpg_id
 from
    stn.cev_non_intercompany_data
union all
select
    'ORIGINAL' posting_type
  , correlation_uuid
  , event_seq_id
  , row_sid
  , sub_event
  , accounting_dt
  , policy_id
  , substrb(policy_abbr_nm,1,50) policy_abbr_nm
  , stream_id
  , basis_cd
  , business_typ
  , premium_typ
  , policy_premium_typ
  , policy_accident_yr
  , policy_underwriting_yr
  , ultimate_parent_stream_id
  , ultimate_parent_le_cd
  , execution_typ
  , policy_typ
  , event_typ
  , business_event_typ
  , business_unit
  , account_cd
  , bu_lookup
  , affiliate
  , owner_le_cd
  , counterparty_le_cd
  , ledger_cd
  , vie_cd
  , is_mark_to_market
  , tax_jurisdiction_cd
  , chartfield_cd
  , jl_description  
  , transaction_ccy
  , transaction_amt
  , functional_ccy
  , functional_amt
  , reporting_ccy
  , reporting_amt
  , lpg_id
from
    stn.cev_intercompany_data
union all
select
    posting_type
  , correlation_uuid
  , event_seq_id
  , row_sid
  , sub_event
  , accounting_dt
  , policy_id
  , substrb(policy_abbr_nm,1,50) policy_abbr_nm
  , stream_id
  , basis_cd
  , business_typ
  , premium_typ
  , policy_premium_typ
  , policy_accident_yr
  , policy_underwriting_yr
  , ultimate_parent_stream_id
  , ultimate_parent_le_cd
  , execution_typ
  , policy_typ
  , event_typ
  , business_event_typ
  , business_unit
  , account_cd
  , bu_lookup
  , affiliate
  , owner_le_cd
  , counterparty_le_cd
  , ledger_cd
  , vie_cd
  , is_mark_to_market
  , tax_jurisdiction_cd
  , chartfield_cd
  , jl_description  
  , transaction_ccy
  , transaction_amt
  , functional_ccy
  , functional_amt
  , reporting_ccy
  , reporting_amt
  , lpg_id
from
    stn.cev_vie_data
;
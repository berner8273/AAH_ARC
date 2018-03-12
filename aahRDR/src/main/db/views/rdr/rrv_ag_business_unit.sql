create or replace view rdr.rrv_ag_business_unit
as
select
      fpl.pl_party_legal_id
    , fpl.pl_cu_base_currency_id
    , fpl.pl_si_sys_inst_id
    , fpl.pl_ci_city_id
    , fpl.pl_co_country_incorp_id
    , fpl.pl_dty_netting_doc_type_id
    , fpl.pl_tx_tax_category_type_id
    , fpl.pl_co_country_resid_id
    , fpl.pl_full_legal_name
    , fpl.pl_pt_party_type_id
    , fpt.pt_party_type_name
    , fpl.pl_party_legal_clicode
    , fpl.pl_human_short_name
    , fpl.pl_guarantor_legal_id
    , fpl.pl_market_sector
    , fpl.pl_ledger_code
    , case
           when fpt.pt_party_type_name in ( 'Ledger Entity' , 'Internal' )
           then 'I'
           else 'E'
      end pl_int_ext_flag
    , case
           when fpt.pt_party_type_name in ( 'Ledger Entity' )
           then 'Y'
           else 'N'
      end                              is_ledger_entity
    , fpl.pl_finance_classification1
    , fpl.pl_finance_classification2
    , fpl.pl_group_classification
    , fpl.pl_group_sector
    , fpl.pl_collateralised
    , fpl.pl_nettable
    , fpl.pl_resident_flag
    , fpl.pl_equity_stock_code
    , fpl.pl_depot_position
    , fpl.pl_stock_market_cap
    , fpl.pl_active
    , fpl.pl_input_by
    , fpl.pl_address_line1
    , fpl.pl_auth_by
    , fpl.pl_address_line2
    , fpl.pl_address_line3
    , fpl.pl_auth_status
    , fpl.pl_input_time
    , fpl.pl_client_text1
    , fpl.pl_address_line4
    , fpl.pl_client_text2
    , fpl.pl_valid_from
    , fpl.pl_client_text3
    , fpl.pl_address_line5
    , fpl.pl_client_text4
    , fpl.pl_valid_to
    , fpl.pl_client_text5              is_interco_elim_entity
    , fpl.pl_client_text6              is_vie_consol_entity
    , fpl.pl_main_phone
    , fpl.pl_delete_time
    , fpl.pl_client_text7
    , fpl.pl_main_fax
    , fpl.pl_client_text8
    , fpl.pl_client_text9
    , fpl.pl_client_text10
    , fpl.pl_cred_rate_clicode
    , fpl.pl_co_country_of_risk_id
    , fpl.pl_global_id
    , fpl.pl_cu_local_currency_id
    , fpl.pl_primary_account_man
    , fpl.pl_local_account_man
    , fpl.pl_local_account_man_backup
    , fpl.pl_trax_location
    , fpl.pl_predef_type
from fdr.fr_party_legal fpl
join fdr.fr_party_type  fpt
  on fpl.pl_pt_party_type_id = fpt.pt_party_type_id
;

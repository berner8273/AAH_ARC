create table stn.cev_vie_data
(
   posting_type                   varchar2 ( 20 char )
,  business_type_association_id   number
,  intercompany_association_id    number
,  correlation_uuid               raw ( 16 )
,  event_seq_id                   number
,  row_sid                        number
,  sub_event                      varchar2 ( 100 char )
,  accounting_dt                  date
,  account_cd											varchar2 ( 20 char )
,  policy_id                      varchar2 ( 40 char )
,  policy_abbr_nm                 varchar2 ( 80 char )
,  stream_id                      number ( 38 )
,  parent_stream_id               number ( 38 )
,  basis_typ                      varchar2 ( 20 char )
,  basis_cd                       varchar2 ( 20 char )
,  business_typ                   varchar2 ( 2 char )
,  generate_interco_accounting    varchar2 ( 1 char )
,  premium_typ                    varchar2 ( 1 char )
,  policy_premium_typ             varchar2 ( 80 char )
,  policy_accident_yr             varchar2 ( 80 char )
,  policy_underwriting_yr         number ( 28 , 8 )
,  ultimate_parent_stream_id      varchar2 ( 80 char )
,  ultimate_parent_le_cd          varchar2 ( 80 char )
,  execution_typ                  varchar2 ( 80 char )
,  policy_typ                     varchar2 ( 80 char )
,  event_typ                      varchar2 ( 30 char )
,  business_event_typ             varchar2 ( 50 char )
,  business_unit                  varchar2 ( 20 char )
,  bu_lookup                      varchar2 ( 20 char )
,  affiliate                      varchar2 ( 20 char )
,  owner_le_cd                    varchar2 ( 20 char )
,  counterparty_le_cd             varchar2 ( 20 char )
,  ledger_cd                      varchar2 ( 20 char )
,  vie_cd                         number ( 1 )
,  vie_status                     varchar2 ( 80 char )
,  vie_effective_dt               date
,  vie_acct_dt                    date
,  is_mark_to_market              varchar2 ( 20 char )
,  tax_jurisdiction_cd            varchar2 ( 80 char )
,  chartfield_cd                  varchar2 ( 50 char )
,  transaction_ccy                varchar2 ( 3 char )
,  transaction_amt                number
,  functional_ccy                 varchar2 ( 3 char )
,  functional_amt                 number
,  reporting_ccy                  varchar2 ( 3 char )
,  reporting_amt                  number
,  jl_description                 varchar2 ( 100 byte )
,  lpg_id                         number ( 38 )
);

  GRANT SELECT ON "STN"."CEV_VIE_DATA" TO "AAH_READ_ONLY";
create table stn.cev_gaap_fut_accts_data
(
   psm_cd                         varchar2 ( 20 char )
,  business_type_association_id   number
,  intercompany_association_id    number
,  gaap_fut_accts_association_id  number
,  correlation_uuid               raw ( 16 )
,  event_seq_id                   number
,  row_sid                        number
,  sub_event                      varchar2 ( 100 char )
,  accounting_dt                  date
,  account_cd											varchar2 ( 20 char )
,  policy_id                      varchar2 ( 40 char )
,  policy_abbr_nm                 varchar2 ( 80 char )
,  stream_id                      number ( 38 )
,  parent_stream_id               varchar2 ( 80 char )
,  basis_typ                      varchar2 ( 20 char )
,  basis_cd                       varchar2 ( 20 char )
,  ledger_cd                      varchar2 ( 20 char )
,  event_typ                      varchar2 ( 30 char )
,  business_event_typ             varchar2 ( 50 char )
,  is_mark_to_market              varchar2 ( 20 char )
,  vie_cd                         number ( 1 )
,  vie_status                     varchar2 ( 80 char )
,  vie_effective_dt               date
,  vie_acct_dt                    date
,  premium_typ                    varchar2 ( 1 char )
,  policy_premium_typ             varchar2 ( 80 char )
,  policy_accident_yr             varchar2 ( 80 char )
,  policy_underwriting_yr         number ( 28 , 8 )
,  ultimate_parent_stream_id      varchar2 ( 80 char )
,  ultimate_parent_le_cd          varchar2 ( 80 char )
,  execution_typ                  varchar2 ( 80 char )
,  policy_typ                     varchar2 ( 80 char )
,  business_typ                   varchar2 ( 2 char )
,  generate_interco_accounting    varchar2 ( 1 char )
,  business_unit                  varchar2 ( 20 char )
,  affiliate                      varchar2 ( 20 char )
,  owner_le_cd                    varchar2 ( 20 char )
,  counterparty_le_cd             varchar2 ( 20 char )
,  fin_calc_cd                    varchar2 ( 20 char )
,  transaction_ccy                varchar2 ( 3 char )
,  input_transaction_amt          number
,  partner_transaction_amt        number
,  functional_ccy                 varchar2 ( 3 char )
,  input_functional_amt           number
,  partner_functional_amt         number
,  reporting_ccy                  varchar2 ( 3 char )
,  input_reporting_amt            number
,  partner_reporting_amt          number
,  chartfield_1                   varchar2 ( 50 char)
,  lpg_id                         number ( 38 )
)
;

  GRANT SELECT ON "STN"."CEV_GAAP_FUT_ACCTS_DATA" TO "AAH_READ_ONLY";
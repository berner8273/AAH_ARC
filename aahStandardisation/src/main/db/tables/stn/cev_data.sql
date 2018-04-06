create global temporary table stn.cev_data
(
   gaap_fut_accts_flag            varchar2 ( 1 char )
,  derived_plus_flag              varchar2 ( 1 char )
,  le_flag                        varchar2 ( 1 char )
,  business_type_association_id   number
,  intercompany_association_id    number
,  derived_plus_association_id    number
,  gaap_fut_accts_association_id  number
,  basis_association_id           number
,  correlation_uuid               raw ( 16 )
,  event_seq_id                   number ( 38 )
,  row_sid                        number ( 38 )
,  input_basis_id                 number ( 38 )
,  input_basis_cd                 varchar2 ( 20 char )
,  partner_basis_cd               varchar2 ( 7 char )
,  accounting_dt                  date
,  event_typ                      varchar2 ( 30 char )
,  event_typ_id                   number
,  business_event_typ             varchar2 ( 50 char )
,  policy_id                      varchar2 ( 40 char )
,  policy_abbr_nm                 varchar2 ( 80 char )
,  stream_id                      number ( 38 )
,  parent_stream_id               varchar2 ( 80 char )
,  vie_id                         number ( 38 )
,  vie_cd                         number ( 1 )
,  vie_effective_dt               date
,  vie_acct_dt                    date
,  is_mark_to_market              varchar2 ( 20 char )
,  premium_typ                    varchar2 ( 1 char )
,  policy_premium_typ             varchar2 ( 80 char )
,  policy_accident_yr             varchar2 ( 80 char )
,  policy_underwriting_yr         number ( 28,8 )
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
,  input_transaction_amt          number ( 38 , 9 )
,  partner_transaction_amt        number
,  dp_partner_transaction_amt     number
,  transaction_ccy                varchar2 ( 3 char )
,  input_functional_amt           number ( 38 , 9 )
,  partner_functional_amt         number
,  dp_partner_functional_amt      number
,  functional_ccy                 varchar2 ( 3 char )
,  input_reporting_amt            number ( 38 , 9 )
,  partner_reporting_amt          number
,  dp_partner_reporting_amt       number
,  reporting_ccy                  varchar2 ( 3 char )
,  lpg_id                         number ( 38 )
)
on commit delete rows
;
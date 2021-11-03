create table stn.cev_data
(
   gaap_fut_accts_flag            varchar2 ( 1 char )
,  le_flag                        varchar2 ( 1 char )
,  business_type_association_id   number
,  intercompany_association_id    number
,  gaap_fut_accts_association_id  number
,  basis_association_id           number
,  correlation_uuid               raw ( 16 )
,  event_seq_id                   number ( 38 )
,  row_sid                        number ( 38 )
,  input_basis_id                 number ( 38 )
,  input_basis_cd                 varchar2 ( 20 char )
,  partner_basis_cd               varchar2 ( 7 char )
,  accounting_dt                  date
,  account_cd											varchar2 ( 20 char )
,  event_typ                      varchar2 ( 30 char )
,  event_typ_id                   number
,  business_event_typ             varchar2 ( 50 char )
,  policy_id                      varchar2 ( 40 char )
,  policy_abbr_nm                 varchar2 ( 80 char )
,  stream_id                      number ( 38 )
,  parent_stream_id               varchar2 ( 80 char )
,  vie_id                         number ( 38 )
,  vie_cd                         number ( 1 )
,  vie_status                     varchar2 ( 80 char )
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
,  reclass_entity			            varchar2 ( 20 char )
,  input_transaction_amt          number ( 38 , 9 )
,  partner_transaction_amt        number
,  transaction_ccy                varchar2 ( 3 char )
,  input_functional_amt           number ( 38 , 9 )
,  partner_functional_amt         number
,  functional_ccy                 varchar2 ( 3 char )
,  input_reporting_amt            number ( 38 , 9 )
,  partner_reporting_amt          number
,  reporting_ccy                  varchar2 ( 3 char )
,  chartfield_1                   varchar( 50 char )
,  jl_description                 varchar( 40 char )
,  lpg_id                         number ( 38 )
)
;


  GRANT SELECT ON "STN"."CEV_DATA" TO "AAH_READ_ONLY";
--------------------------------------------------------

  CREATE INDEX "STN"."IDX_CEV_DATA_COMP2" ON "STN"."CEV_DATA" ("GAAP_FUT_ACCTS_FLAG", "PREMIUM_TYP") ;
--------------------------------------------------------
--  DDL for Index IDX_CEV_DATA_COMP1
--------------------------------------------------------

  CREATE INDEX "STN"."IDX_CEV_DATA_COMP1" ON "STN"."CEV_DATA" ("PREMIUM_TYP", "CORRELATION_UUID", "EVENT_TYP") ;
--------------------------------------------------------
--  DDL for Index I_CEV_DATA
--------------------------------------------------------

  CREATE INDEX "STN"."I_CEV_DATA" ON "STN"."CEV_DATA" ("CORRELATION_UUID") ;
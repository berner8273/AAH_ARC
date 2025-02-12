create table stn.insurance_policy
(
    row_sid                  number ( 38 , 0 )     generated by default as identity not null
,   policy_id                varchar2 ( 30 char )                                   not null
,   policy_nm                varchar2 ( 140 char )                                  not null
,   policy_abbr_nm           varchar2 ( 50 char )                                   not null
,   original_policy_id       varchar2 ( 30 char )
,   underwriting_le_id       number ( 38 , 0 )                                      not null
,   external_le_id           number ( 38 , 0 )
,   close_dt                 date                                                   not null
,   expected_maturity_dt     date                                                   not null
,   policy_underwriting_yr   number ( 4 , 0 )                                       not null
,   policy_accident_yr       number ( 4 , 0 )
,   policy_typ               varchar2 ( 20 char )                                   not null
,   policy_premium_typ       varchar2 ( 1 char )                                    not null
,   is_credit_default_swap   varchar2 ( 1 char )                                    not null
,   is_mark_to_market        varchar2 ( 1 char )                                    not null
,   execution_typ            varchar2 ( 20 char )                                   not null
,   transaction_ccy          varchar2 ( 3 char )                                    not null
,   is_uncollectible         varchar2 ( 1 char )                                    not null
,   earnings_calc_method     varchar2 ( 1 char )                                    not null
,   lpg_id                   number   ( 38 , 0 ) default 1                          not null
,   event_status             varchar2 ( 1 char ) default 'U'                        not null
,   feed_uuid                raw ( 16 )                                             not null
,   no_retries               number ( 38 , 0 )   default 0                          not null
,   step_run_sid             number ( 38 , 0 )   default 0                          not null
,   constraint pk_ip                     primary key ( row_sid )
,   constraint uk_ip                     unique      ( policy_id , feed_uuid )
,   constraint ck_is_mark_to_market      check       ( is_mark_to_market      in ( 'Y' , 'N' ) )
,   constraint ck_is_credit_default_swap check       ( is_credit_default_swap in ( 'Y' , 'N' ) )
,   constraint ck_is_uncollectible       check       ( is_uncollectible       in ( 'Y' , 'N' ) )
,   constraint ck_policy_typ             check       ( policy_typ             in ( 'DIRECT' , 'ASSUMED' ) )
,   constraint ck_policy_accident_yr     check       ( policy_accident_yr     >= 0 )
,   constraint ck_policy_underwriting_yr check       ( policy_underwriting_yr >= 0 )
);
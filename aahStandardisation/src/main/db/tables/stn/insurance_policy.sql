create table stn.insurance_policy
(
    row_sid                  number ( 38 , 0 )     generated by default as identity not null
,   policy_id                varchar2 ( 30 char )                                   not null
,   original_policy_id       varchar2 ( 30 char )
,   underwriting_le_id       number ( 38 , 0 )                                      not null
,   external_reinsurer_le_id number ( 38 , 0 )
,   accident_yr              number ( 4 , 0 )
,   close_dt                 date                                                   not null
,   expected_maturity_dt     date                                                   not null
,   actual_maturity_dt       date                                                   not null
,   underwriting_yr          number ( 4 , 0 )                                       not null
,   policy_typ               varchar2 ( 20 char )                                   not null
,   premium_typ              varchar2 ( 1 char )                                    not null
,   is_mark_to_market        varchar2 ( 1 char )                                    not null
,   is_credit_default_swap   varchar2 ( 1 char )                                    not null
,   transaction_ccy          varchar2 ( 3 char )                                    not null
,   line_of_business_cd      varchar2 ( 5 char )                                    not null
,   is_uncollectable         varchar2 ( 1 char )                                    not null
,   lpg_id                   number   ( 38 , 0 ) default 1                          not null
,   event_status             varchar2 ( 1 char ) default 'U'                        not null
,   feed_uuid                raw ( 16 )                                             not null
,   no_retries               number ( 38 , 0 )   default 0                          not null
,   step_run_sid             number ( 38 , 0 )   default 0                          not null
,   constraint pk_ip                     primary key ( row_sid )
,   constraint uk_ip                     unique      ( policy_id , feed_uuid )
,   constraint ck_is_mark_to_market      check       ( is_mark_to_market      in ( 'Y' , 'N' ) )
,   constraint ck_is_credit_default_swap check       ( is_credit_default_swap in ( 'Y' , 'N' ) )
,   constraint ck_is_uncollectable       check       ( is_uncollectable       in ( 'Y' , 'N' ) )
,   constraint ck_policy_typ             check       ( policy_typ             in ( 'DIRECT' , 'ASSUMED' ) )
,   constraint ck_close_dt               check       ( close_dt        <= expected_maturity_dt )
,   constraint ck_accident_yr            check       ( accident_yr     >= 0 )
,   constraint ck_underwriting_yr        check       ( underwriting_yr >= 0 )
);
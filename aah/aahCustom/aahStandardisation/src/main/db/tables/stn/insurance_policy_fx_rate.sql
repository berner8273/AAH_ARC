create table stn.insurance_policy_fx_rate
(
    row_sid                  number ( 38 , 0 )     generated by default as identity not null
,   policy_id                varchar2 ( 30 char )                                   not null
,   from_ccy                 varchar2 ( 3 char )                                    not null
,   to_ccy                   varchar2 ( 3 char )                                    not null
,   rate                     number   ( 38 , 9 )                                    not null
,   lpg_id                   number   ( 38 , 0 ) default 1                          not null
,   event_status             varchar2 ( 1 char ) default 'U'                        not null
,   feed_uuid                raw ( 16 )                                             not null
,   no_retries               number ( 38 , 0 )   default 0                          not null
,   step_run_sid             number ( 38 , 0 )   default 0                          not null
,   constraint pk_ipfr        primary key ( row_sid )
,   constraint uk_ipfr        unique      ( policy_id , feed_uuid , from_ccy , to_ccy )
,   constraint ck_from_to_ccy check       ( from_ccy != to_ccy )
);
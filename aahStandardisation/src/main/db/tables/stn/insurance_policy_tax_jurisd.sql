create table stn.insurance_policy_tax_jurisd
(
    row_sid                  number ( 38 , 0 )     generated by default as identity not null
,   policy_id                varchar2 ( 30 char )                                   not null
,   tax_jurisdiction_cd      varchar2 ( 2 char )                                    not null
,   tax_jurisdiction_pct     number ( 5 , 2 )                                       not null
,   lpg_id                   number   ( 38 , 0 ) default 1                          not null
,   event_status             varchar2 ( 1 char ) default 'U'                        not null
,   feed_uuid                raw ( 16 )                                             not null
,   no_retries               number ( 38 , 0 )   default 0                          not null
,   step_run_sid             number ( 38 , 0 )   default 0                          not null
,   constraint pk_iptj primary key ( row_sid )
,   constraint uk_iptj unique      ( policy_id , tax_jurisdiction_cd , feed_uuid )
);
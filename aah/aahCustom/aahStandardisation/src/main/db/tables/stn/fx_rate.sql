create table stn.fx_rate
(
    row_sid      number   ( 38 , 0 )             generated by default as identity not null
,   rate_dt      date                                                             not null
,   from_ccy     varchar2 ( 3 char )                                              not null
,   to_ccy       varchar2 ( 3 char )                                              not null
,   rate_typ     varchar2 ( 4 char )                                              not null
,   rate         number   ( 38 , 9 )                                              not null
,   lpg_id       number   ( 38 , 0 ) default 1                                    not null
,   event_status varchar2 ( 1 char ) default 'U'                                  not null
,   feed_uuid    raw ( 16 )                                                       not null
,   no_retries   number ( 38 , 0 )   default 0                                    not null
,   step_run_sid number ( 38 , 0 )   default 0                                    not null
,   constraint pk_fxr primary key ( row_sid )
,   constraint uk_fxr unique      ( rate_dt , from_ccy , to_ccy , rate_typ , feed_uuid )
,   constraint ck_fxr check       ( from_ccy <> to_ccy )
);
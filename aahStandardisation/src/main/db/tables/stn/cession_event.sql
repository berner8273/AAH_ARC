create table stn.cession_event
(
    row_sid             number ( 38 , 0 ) generated by default as identity not null
,   correlation_uuid    raw ( 16 )                                         not null
,   event_id            number ( 38 , 0 )                                  not null
,   accounting_dt       date                                               not null
,   stream_id           number ( 38 , 0 )                                  not null
,   basis_cd            varchar2 ( 20 char )                               not null
,   premium_typ         varchar2 ( 1 char )
,   business_typ        varchar2 ( 2 char )                                not null
,   event_typ           varchar2 ( 30 char )                               not null
,   business_event_typ  varchar2 ( 50 char )                               not null
,   source_event_ts     timestamp                                          not null
,   transaction_ccy     varchar2 ( 3 char )                                not null
,   transaction_amt     number ( 38 , 9 )                                  not null
,   functional_ccy      varchar2 ( 3 char )                                not null
,   functional_amt      number ( 38 , 9 )                                  not null
,   reporting_ccy       varchar2 ( 3 char )                                not null
,   reporting_amt       number ( 38 , 9 )                                  not null
,   lpg_id              number   ( 38 , 0 ) default 2                      not null
,   event_status        varchar2 ( 1 char ) default 'U'                    not null
, 	reclass_entity   	  varchar2 ( 20 char )                               
, 	account_cd         	varchar2 ( 20 char )                               
,   feed_uuid           raw ( 16 )                                         not null
,   no_retries          number ( 38 , 0 )   default 0                      not null
,   step_run_sid        number ( 38 , 0 )   default 0                      not null
,   constraint pk_cev primary key ( row_sid )
,   constraint uk_cev unique      ( correlation_uuid , accounting_dt , stream_id , basis_cd , premium_typ , business_typ , event_typ )
);
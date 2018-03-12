create table stn.cev_valid
(
    row_sid             number ( 38 , 0 )
,   correlation_uuid    raw ( 16 )
,   event_id            number ( 38 , 0 )
,   accounting_dt       date
,   stream_id           number ( 38 , 0 )
,   basis_cd            varchar2 ( 20 char )
,   premium_typ         varchar2 ( 1 char )
,   business_typ        varchar2 ( 2 char )
,   event_typ           varchar2 ( 30 char )
,   business_event_typ  varchar2 ( 50 char )
,   source_event_ts     timestamp
,   transaction_ccy     varchar2 ( 3 char )
,   transaction_amt     number ( 38 , 9 )
,   functional_ccy      varchar2 ( 3 char )
,   functional_amt      number ( 38 , 9 )
,   reporting_ccy       varchar2 ( 3 char )
,   reporting_amt       number ( 38 , 9 )
,   lpg_id              number   ( 38 , 0 )
,   event_status        varchar2 ( 1 char )
,   feed_uuid           raw ( 16 )
,   no_retries          number ( 38 , 0 )
,   step_run_sid        number ( 38 , 0 )
,   constraint pk_cev_v primary key ( row_sid )
,   constraint uk_cev_v unique      ( feed_uuid , correlation_uuid , accounting_dt , stream_id , basis_cd , premium_typ , business_typ , event_typ )
)
;
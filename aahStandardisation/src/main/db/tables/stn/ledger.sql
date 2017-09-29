create table stn.ledger
(
    row_sid                 number   ( 38 , 0 )              generated by default as identity not null
,   ledger_cd               varchar2 ( 20 char )                                              not null
,   cldr_cd                 varchar2 ( 40 char ) default 'AG_DEFAULT'                         not null
,   lpg_id                  number   ( 38 , 0 )  default 1                                    not null
,   event_status            varchar2 ( 1 char )  default 'U'                                  not null
,   feed_uuid               raw ( 16 )                                                        not null
,   no_retries              number ( 38 , 0 )    default 0                                    not null
,   step_run_sid            number ( 38 , 0 )    default 0                                    not null
,   constraint pk_ledger primary key ( row_sid )
,   constraint uk_ledger unique      ( ledger_cd, feed_uuid )
);
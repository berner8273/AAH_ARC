create table stn.gl_combo_edit_assignment
(
    row_sid          number   ( 38 , 0 )  generated by default as identity not null
,   prc_cd           varchar2 ( 20 char )                                  not null
,   le_id            number   ( 38 , 0 )                                   not null
,   ledger_cd        varchar2 ( 20 char )                                  not null
,   lpg_id           number   ( 38 , 0 )   default 1                       not null
,   event_status     varchar2 ( 1 char )   default 'U'                     not null
,   feed_uuid        raw      ( 16 )                                       not null
,   no_retries       number   ( 38 , 0 )   default 0                       not null
,   step_run_sid     number   ( 38 , 0 )   default 0                       not null
,   constraint pk_cea               primary key ( row_sid )
,   constraint uk_cea               unique      ( prc_cd , le_id , ledger_cd , feed_uuid )
);
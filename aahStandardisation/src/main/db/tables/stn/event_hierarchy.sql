create table stn.event_hierarchy
(
    row_sid                   number   ( 38 , 0 )              generated by default as identity not null
,   event_typ                 varchar2 ( 20 char )                                              not null
,   event_typ_descr           varchar2 ( 80 char )                                              not null
,   event_subgrp              varchar2 ( 20 char )                                              not null
,   event_subgrp_descr        varchar2 ( 80 char )                                              not null
,   event_grp                 varchar2 ( 20 char )                                              not null
,   event_grp_descr           varchar2 ( 80 char )                                              not null
,   event_class               varchar2 ( 20 char )                                              not null
,   event_class_descr         varchar2 ( 80 char )                                              not null
,   event_category_cd         varchar2 ( 20 char )
,   event_category_descr      varchar2 ( 80 char )
,   is_cash_event             varchar2 ( 1 char )
,   is_core_earning_event     varchar2 ( 1 char )
,   lpg_id                    number   ( 38 , 0 )  default 1                                    not null
,   event_status              varchar2 ( 1 char )  default 'U'                                  not null
,   feed_uuid                 raw ( 16 )                                                        not null
,   no_retries                number ( 38 , 0 )    default 0                                    not null
,   step_run_sid              number ( 38 , 0 )    default 0                                    not null
,   constraint pk_eh                       primary key ( row_sid )
,   constraint uk_eh                       unique      ( event_typ , feed_uuid )
,   constraint ck_eh_is_cash_event         check       ( is_cash_event         in ( 'Y' , 'N' ) )
,   constraint ck_eh_is_core_earning_event check       ( is_core_earning_event in ( 'Y' , 'N' ) )
);
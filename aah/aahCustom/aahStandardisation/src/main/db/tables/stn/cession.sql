create table stn.cession
(
    row_sid                  number ( 38 , 0 )                generated by default as identity not null
,   policy_id                varchar2 ( 30 char )                                              not null
,   stream_id                number ( 38 , 0 )                                                 not null
,   le_id                    number ( 38 , 0 )                                                 not null
,   cession_typ              varchar2 ( 2 char )                                               not null
,   gross_par_pct            number ( 5 , 2 )                                                  not null
,   net_par_pct              number ( 5 , 2 )                                                  not null
,   gross_premium_pct        number ( 5 , 2 )                                                  not null
,   ceding_commission_pct    number ( 5 , 2 )                                                  not null
,   net_premium_pct          number ( 5 , 2 )                                                  not null
,   start_dt                 date                                                              not null
,   effective_dt             date                                                              not null
,   stop_dt                  date
,   termination_dt           date
,   loss_pos                 varchar2 ( 1 char )
,   vie_status               varchar2 ( 10 char )
,   vie_effective_dt         date
,   vie_acct_dt              date
,   accident_yr              number ( 4 , 0 )
,   underwriting_yr          number ( 4 , 0 )                                                  not null
,   lpg_id                   number   ( 38 , 0 )   default 1                                   not null
,   event_status             varchar2 ( 1 char )   default 'U'                                 not null
,   feed_uuid                raw ( 16 )                                                        not null
,   no_retries               number ( 38 , 0 )     default 0                                   not null
,   step_run_sid             number ( 38 , 0 )     default 0                                   not null
,   constraint pk_c                      primary key ( row_sid )
,   constraint uk_c                      unique      ( stream_id , feed_uuid )
,   constraint ck_ceding_commission_pct  check       ( ceding_commission_pct between 0 and 100 )
,   constraint ck_start_dt               check       ( start_dt <= stop_dt )
);
create table stn.step_run_log
(
    step_run_sid   number                                                not null
,   ts             timestamp                   default current_timestamp not null
,   code_module_nm varchar2 ( 50 char )                                  not null
,   code_module_ln number   ( 38 , 0 )                                   not null
,   msg            varchar2 ( 1000 char )                                not null
,   var_nm         varchar2 ( 128 char )
,   var_val_dt     date
,   var_val_num    number   ( 38 , 9 )
,   var_val_str    varchar2 ( 1000 char )
,   constraint pk_srl primary key ( step_run_sid , ts )
);
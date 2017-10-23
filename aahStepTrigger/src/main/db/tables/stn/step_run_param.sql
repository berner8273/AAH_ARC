create table stn.step_run_param
(
    step_run_sid       number                not null
,   param_set_item_cd  varchar2 ( 50 char )  not null
,   param_set_item_val varchar2 ( 150 char ) not null
,   constraint pk_step_run_param primary key ( step_run_sid , param_set_item_cd )
);
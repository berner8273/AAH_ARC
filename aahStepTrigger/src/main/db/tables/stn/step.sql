create table stn.step
(
    step_id      number               not null
,   step_cd      varchar2 ( 50 char ) not null
,   process_id   number               not null
,   param_set_id number               not null
,   constraint pk_step     primary key ( step_id )
,   constraint uk_step     unique      ( step_cd )
,   constraint uk_step_prc unique      ( process_id , param_set_id )
);
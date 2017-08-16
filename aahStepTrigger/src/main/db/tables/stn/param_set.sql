create table stn.param_set
(
    param_set_id number               not null
,   param_set_cd varchar2 ( 50 char ) not null
,   constraint pk_param_set primary key ( param_set_id )
,   constraint uk_param_set unique      ( param_set_cd )
);
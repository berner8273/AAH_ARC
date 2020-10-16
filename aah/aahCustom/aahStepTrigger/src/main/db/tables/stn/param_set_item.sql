create table stn.param_set_item
(
    param_set_id       number                not null
,   param_set_item_cd  varchar2 ( 50 char )  not null
,   param_set_item_val varchar2 ( 150 char ) not null
,   constraint pk_param_set_item primary key ( param_set_id , param_set_item_cd )
);
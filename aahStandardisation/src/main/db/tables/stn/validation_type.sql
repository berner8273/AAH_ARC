create table stn.validation_type
(
    validation_typ_id      number                not null
,   validation_typ_cd      varchar2 ( 10 char )  not null
,   validation_typ_descr   varchar2 ( 100 char ) not null
,   validation_typ_err_msg varchar2 ( 240 char ) not null
,   constraint pk_vt primary key ( validation_typ_id )
,   constraint uk_vt unique      ( validation_typ_cd )
);
create table stn.validation
(
    validation_id       number               not null
,   validation_cd       varchar2 ( 50 char ) not null
,   code_module_id      number               not null
,   validation_typ_id   number               not null
,   validation_level_id number               not null
,   constraint pk_v primary key ( validation_id )
,   constraint uk_v unique      ( validation_cd )
);
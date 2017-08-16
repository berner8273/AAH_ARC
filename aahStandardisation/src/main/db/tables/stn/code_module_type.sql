create table stn.code_module_type
(
    code_module_typ_id    number                not null
,   code_module_typ_cd    varchar2 ( 10  char ) not null
,   code_module_typ_descr varchar2 ( 100 char ) not null
,   constraint pk_cmt primary key ( code_module_typ_id )
,   constraint uk_cmt unique      ( code_module_typ_cd )
);
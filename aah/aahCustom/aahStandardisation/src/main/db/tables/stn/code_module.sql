create table stn.code_module
(
    code_module_id     number               not null
,   code_module_nm     varchar2 ( 50 char ) not null
,   code_module_typ_id number               not null
,   constraint pk_cm primary key ( code_module_id )
,   constraint uk_cm unique      ( code_module_nm )
);
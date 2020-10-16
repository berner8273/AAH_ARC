create table stn.execution_type
(
    execution_typ       varchar2 ( 20 char )  not null
,   execution_typ_descr varchar2 ( 100 char ) not null
,   constraint pk_ext primary key ( execution_typ )
);
create table stn.cession_type
(
    cession_typ       varchar2 ( 2 char )   not null
,   cession_typ_descr varchar2 ( 100 char ) not null
,   constraint pk_ct primary key ( cession_typ )
);
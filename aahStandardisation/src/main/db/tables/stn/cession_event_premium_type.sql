create table stn.cession_event_premium_type
(
    premium_typ       varchar2 ( 1 char ) not null
,   premium_typ_descr varchar2 ( 100 char ) not null
,   constraint pk_ceptyp primary key ( premium_typ )
);
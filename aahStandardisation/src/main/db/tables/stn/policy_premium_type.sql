create table stn.policy_premium_type
(
    premium_typ               varchar2 ( 1 char )   not null
,   premium_typ_descr         varchar2 ( 100 char ) not null
,   cession_event_premium_typ varchar2 ( 1 char )   not null
,   constraint pk_pptyp primary key ( premium_typ )
);
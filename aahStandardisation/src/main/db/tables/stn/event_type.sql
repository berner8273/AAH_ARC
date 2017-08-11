create table stn.event_type
(
    event_typ_id number ( 38 , 0 ) generated by default as identity not null
,   event_typ    varchar2 ( 20 char )                               not null
,   constraint pk_et primary key ( event_typ_id )
,   constraint uk_et unique      ( event_typ )
);
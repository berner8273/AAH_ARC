create table stn.feed_type_payload
(
    feed_typ               varchar2 ( 50 char ) not null
,   dbt_id                 number               not null
,   constraint pk_ftp primary key ( feed_typ , dbt_id )
);
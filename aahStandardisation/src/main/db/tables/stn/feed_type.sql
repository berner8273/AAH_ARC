create table stn.feed_type
(
    feed_typ      varchar2 ( 50 char )       not null
,   process_id    number                     not null
,   supersession_method_id number ( 38 , 0 ) not null
,   constraint pk_ft primary key ( feed_typ )
,   constraint uk_ft unique      ( process_id )
);
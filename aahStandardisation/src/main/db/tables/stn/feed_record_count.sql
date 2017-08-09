create table stn.feed_record_count
(
    feed_uuid         raw ( 16 )                      not null
,   db_nm             varchar2 ( 128 char )           not null
,   table_nm          varchar2 ( 128 char )           not null
,   stated_record_cnt number ( 38 , 0 )     default 0 not null
,   actual_record_cnt number ( 38 , 0 )
,   constraint pk_frc            primary key ( feed_uuid , table_nm )
,   constraint ck_frc_record_cnt check       ( stated_record_cnt >= 0 )
);
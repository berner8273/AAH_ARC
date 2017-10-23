create table stn.process_type
(
    process_type_id number               not null
,   process_type_cd varchar2 ( 50 char ) not null
,   constraint pk_process_type primary key ( process_type_id )
,   constraint uk_process_type unique      ( process_type_cd )
);
create table stn.validation_level
(
    validation_level_id number               not null
,   validation_level_cd varchar2 ( 50 char ) not null
,   constraint pk_vl primary key ( validation_level_id )
,   constraint uk_vl unique      ( validation_level_cd )
);
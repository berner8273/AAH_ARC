create table stn.validation_column
(
    validation_id number not null
,   dtc_id        number not null
,   constraint pk_vc primary key ( validation_id , dtc_id )
);
create table stn.supersession_method
(
    supersession_method_id    number   ( 38 , 0 )   not null
,   supersession_method_cd    varchar2 ( 20 char )  not null
,   supersession_method_descr varchar2 ( 150 char ) not null
,   constraint pk_sm primary key ( supersession_method_id )
,   constraint uk_sm unique      ( supersession_method_cd )
);
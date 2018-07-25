create table stn.posting_method
(
    psm_id    number ( 38, 0 )     generated by default as identity not null
,   psm_cd    varchar2 ( 20 char )                                  not null
,   psm_descr varchar2 ( 100 char )                                 not null
,   constraint pk_psm primary key ( psm_id )
,   constraint uk_psm unique      ( psm_cd )
);
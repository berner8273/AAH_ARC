create table stn.posting_method_derivation_le
(
    le_cd  varchar2 ( 20 char ) not null
,   psm_id number ( 38 , 0 )    not null
,   constraint pk_psmdl primary key ( le_cd , psm_id )
);
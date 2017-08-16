create table stn.posting_method_derivation_mtm
(
    event_typ_id      number ( 38 , 0 )    not null
,   is_mark_to_market varchar2 ( 1  char ) not null
,   psm_id            number ( 38 , 0 )    not null
,   constraint pk_psmdm                   primary key ( event_typ_id , is_mark_to_market )
,   constraint ck_psmdm_is_mark_to_market check       ( is_mark_to_market in ( 'Y' , 'N' ) )
);
create table stn.posting_method_derivation_et
(
    input_event_typ_id            number ( 38 , 0 )    not null
,   output_event_typ_id           number ( 38 , 0 )    not null
,   psm_id                        number ( 38 , 0 )    not null
,   constraint pk_psmet           primary key ( input_event_typ_id , psm_id )
,   constraint ck_event_typ       check       ( input_event_typ_id <> output_event_typ_id )
);
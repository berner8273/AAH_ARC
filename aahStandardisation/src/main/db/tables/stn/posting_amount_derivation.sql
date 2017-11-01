create table stn.posting_amount_derivation
(
    event_typ_id     number ( 38 , 0 )                                  not null
,   amount_typ_id    number ( 38 , 0 )                                  not null
,   constraint pk_pad   primary key   ( event_typ_id )
);
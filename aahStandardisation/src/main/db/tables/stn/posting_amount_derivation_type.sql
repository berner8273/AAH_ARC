create table stn.posting_amount_derivation_type
(
    amount_typ_id       number ( 38 , 0 )                                  not null
,   amount_typ_descr    varchar2 ( 100 char )                               not null
,   constraint pk_padt  primary key   ( amount_typ_id )
);
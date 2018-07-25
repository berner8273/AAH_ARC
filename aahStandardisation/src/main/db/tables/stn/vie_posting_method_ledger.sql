create table stn.vie_posting_method_ledger
(
    input_basis_id   number ( 38 , 0 ) not null
,   event_typ_id     number ( 38 , 0 ) not null
,   vie_id           number ( 38 , 0 ) not null
,   vie_event_typ_id number ( 38 , 0 ) not null
,   output_basis_id  number ( 38 , 0 ) not null
,   ledger_id        number ( 38 , 0 ) not null
,   fin_calc_id      number ( 38 , 0 ) not null
,   negate_flag      number ( 1 , 0 ) not null
,   sub_event        varchar2 ( 100 char )
,   constraint pk_vpml primary key ( input_basis_id , event_typ_id , vie_id , vie_event_typ_id )
);
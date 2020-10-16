create table stn.posting_amount_negate_flag
(
    amount_typ_id      number ( 38 , 0 )    not null
  , business_typ       varchar2 ( 2  char ) not null
  , negate_flag_in     number ( 1 , 0 )     not null
  , negate_flag_out    number ( 1 , 0 )     not null
  , constraint ck_panf_flag_in  check   ( negate_flag_in  in ( 1 , -1 ) )
  , constraint ck_panf_flag_out check   ( negate_flag_out in ( 1 , -1 ) )
  , constraint uk_panf          unique  ( amount_typ_id , business_typ )
);
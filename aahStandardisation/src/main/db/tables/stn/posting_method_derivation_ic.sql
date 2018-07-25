create table stn.posting_method_derivation_ic
(
    basis_id number ( 38 , 0 )  not null
,   psm_id   number ( 38 , 0 )  not null
,   constraint pk_psmic primary key ( basis_id )
);
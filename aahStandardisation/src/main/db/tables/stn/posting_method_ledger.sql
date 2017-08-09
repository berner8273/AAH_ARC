create table stn.posting_method_ledger
(
    psm_id           number ( 38 , 0 )                                  not null
,   input_basis_id   number ( 38 , 0 )                                  not null
,   output_basis_id  number ( 38 , 0 )                                  not null
,   ledger_id        number ( 38 , 0 )                                  not null
,   fin_calc_id      number ( 38 , 0 )                                  not null
,   sub_event        varchar2 ( 100 char )
,   constraint uk_pml unique      ( psm_id , input_basis_id , output_basis_id , ledger_id , fin_calc_id )
);
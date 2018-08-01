create table stn.posting_method_derivation_ic
(
    input_ledger_id         number ( 38 , 0 )      not null
  , output_ledger_id        number ( 38 , 0 )      not null
  , legal_entity_link_typ   varchar2 ( 20 char )   not null
  , negate_flag             number ( 1 , 0 )       not null
  , psm_id                  number ( 38 , 0 )      not null
  , constraint pk_psmic   primary key ( input_ledger_id , output_ledger_id )
  , constraint ck_psmicnf check       ( negate_flag in ( 1 , -1 ) )
);
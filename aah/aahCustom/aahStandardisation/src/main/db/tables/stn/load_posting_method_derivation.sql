create table stn.load_posting_method_derivation
(
    event_typ                   varchar2 ( 20 char )  not null
  , is_mark_to_market           varchar2 ( 1 char )   not null
  , premium_typ                 varchar2 ( 3 char )   not null
  , basis_cd                    varchar2 ( 20 char )  not null
  , psm_cd                      varchar2 ( 20 char )  not null
);
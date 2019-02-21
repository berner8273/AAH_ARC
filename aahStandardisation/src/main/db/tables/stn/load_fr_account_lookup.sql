create table stn.load_fr_account_lookup
(
    al_posting_code             varchar2 ( 40 char )  not null
  , al_lookup_1                 varchar2 ( 50 char )  not null
  , al_lookup_2                 varchar2 ( 50 char )  not null
  , al_lookup_3                 varchar2 ( 50 char )  not null
  , al_lookup_4                 varchar2 ( 50 char )  not null
  , al_account                  varchar2 ( 20 char )  not null
  , al_valid_from               date                  not null
  , al_valid_to                 date                  not null
);

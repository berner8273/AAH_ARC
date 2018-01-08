create table stn.posting_method_derivation_gfa
(
    event_typ_qualifier  number ( 38 , 0 )    not null
  , event_typ_in         number ( 38 , 0 )    not null
  , event_typ_out        number ( 38 , 0 )    not null
  , gaap_fut_accts_flag  varchar2( 1 char )   not null
  , constraint uk_psmdgfa unique ( event_typ_qualifier , event_typ_in , event_typ_out )
);
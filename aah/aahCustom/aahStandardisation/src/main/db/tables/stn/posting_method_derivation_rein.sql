create table stn.posting_method_derivation_rein
(
    le_1_cd         varchar2 ( 20 char )  not null
,   le_2_cd         varchar2 ( 20 char )  not null
,   chartfield_cd   varchar2 ( 20 char )  
,   reins_le_cd     varchar2 ( 20 char )  not null
,   constraint uk_psmrein unique ( le_1_cd , le_2_cd )
);
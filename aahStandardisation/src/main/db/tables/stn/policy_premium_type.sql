create table stn.policy_premium_type
(
    policy_premium_typ       varchar2 ( 1 char )   not null
,   policy_premium_typ_descr varchar2 ( 100 char ) not null
,   constraint pk_ppt primary key ( policy_premium_typ )
);
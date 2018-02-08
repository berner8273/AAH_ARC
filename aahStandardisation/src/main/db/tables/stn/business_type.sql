create table stn.business_type
(
    business_typ                varchar2 ( 2  char )  not null
,   business_typ_descr          varchar2 ( 100 char ) not null
,   generate_interco_accounting varchar2 ( 1  char )  not null
,   bu_derivation_method        varchar2 ( 20 char )  not null
,   afflte_derivation_method    varchar2 ( 20 char )  not null
,   constraint pk_bt                          primary key ( business_typ )
,   constraint ck_generate_interco_accounting check       ( generate_interco_accounting in ( 'Y' , 'N' ) )
,   constraint ck_bu_derivation_method        check       ( bu_derivation_method        in ( 'CESSION' , 'PARENT_CESSION' , 'N/A' ) )
,   constraint ck_afflte_derivation_method    check       ( afflte_derivation_method    in ( 'CESSION' , 'PARENT_CESSION' , 'N/A' ) )
);
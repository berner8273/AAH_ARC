create table stn.cev_period_balances
(
    transaction_balance number ( 38 , 9 )       not null
,   reporting_balance   number ( 38 , 9 )       not null
,   functional_balance  number ( 38 , 9 )       not null
,   stream_id           varchar2 ( 100 char )   not null
,   business_unit       varchar2 ( 20 char )    not null
,   sub_account         varchar2 ( 20 char )    not null
,   currency            varchar2 ( 3 char )     not null
,   premium_typ         varchar2 ( 100 char )   not null
,   basis_cd            varchar2 ( 100 char )   not null
,   period_month        number ( 2 , 0 )        not null
,   period_year         number ( 4 , 0 )        not null
,   end_of_period       date                    not null
,   constraint pk_cevpb primary key ( stream_id , business_unit , sub_account , currency , premium_typ , basis_cd , period_month , period_year )
);
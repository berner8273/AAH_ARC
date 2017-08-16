create table stn.gl_account_category
(
    acct_cat       varchar2 ( 1 char )   not null
,   acct_cat_descr varchar2 ( 200 char ) not null
,   constraint pk_gac primary key ( acct_cat )
);
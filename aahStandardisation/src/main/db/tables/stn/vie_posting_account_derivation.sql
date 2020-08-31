create global temporary table stn.vie_posting_account_derivation
(
   posting_schema     varchar2 ( 20 char )
,  event_typ          varchar2 ( 20 char )
,  sub_event          varchar2 ( 40 char )
,  business_typ       varchar2 ( 50 char )
,  is_mark_to_market  varchar2 ( 50 char )
,  business_unit      varchar2 ( 50 char )
,  vie_business_unit  varchar2 ( 50 char )
,  account_cd      		varchar2 ( 50 char )
,  currency           varchar2 ( 3 char )
,  sub_account        varchar2 ( 20 char )
)
on commit delete rows
;
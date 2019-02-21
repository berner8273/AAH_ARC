create table stn.business_event_category
(
    business_event_category_cd     varchar2 ( 50 char )   not null
  , business_event_category_descr  varchar2 ( 100 char )  not null
  , constraint pk_bec              primary key ( business_event_category_cd )
);
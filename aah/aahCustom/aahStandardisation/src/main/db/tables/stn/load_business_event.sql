create table stn.load_business_event
(
    business_event_seq_id          number   ( 12,0 )     not null
  , business_event_cd              varchar2 ( 200 char ) not null
  , business_event_descr           varchar2 ( 200 char ) not null
  , business_event_category_descr  varchar2 ( 200 char ) not null
);
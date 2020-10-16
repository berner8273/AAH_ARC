create table stn.business_event
(
    business_event_cd           varchar2 ( 50 char )   not null
  , business_event_descr        varchar2 ( 100 char )  not null
  , business_event_category_cd  varchar2 ( 50 char )   not null
  , business_event_seq_id       number ( 38 , 0 )      not null
  , constraint pk_be            primary key ( business_event_cd )
);
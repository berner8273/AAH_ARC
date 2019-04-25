create table stn.load_event_hierarchy
(
    event_class                 varchar2 ( 20 char )  not null
  , event_class_descr           varchar2 ( 80 char )  not null
  , event_class_period_freq     varchar2 ( 1 char )   not null
  , event_class_order           number   ( 12,0 )     not null
  , event_grp                   varchar2 ( 20 char )  not null
  , event_grp_descr             varchar2 ( 80 char )  not null
  , event_grp_order             number   ( 12,0 )     not null
  , event_subgrp                varchar2 ( 20 char )  not null
  , event_subgrp_descr          varchar2 ( 80 char )  not null
  , event_subgrp_order          number   ( 12,0 )     not null
  , event_typ                   varchar2 ( 20 char )  not null
  , event_typ_descr             varchar2 ( 80 char )  not null
  , event_typ_seq_id            number   ( 12,0 )     not null
  , is_cash_event               varchar2 ( 1 char )
  , is_core_earning_event       varchar2 ( 1 char )
  , event_category              varchar2 ( 20 char )
  , event_category_descr        varchar2 ( 80 char )
);
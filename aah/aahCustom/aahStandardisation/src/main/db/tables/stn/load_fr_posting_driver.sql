create table stn.load_fr_posting_driver
(
    pd_posting_driver_id        number   ( 12,0 )     not null
  , pd_posting_schema           varchar2 ( 20 char )  not null
  , pd_aet_event_type           varchar2 ( 20 char )  not null
  , pd_sub_event                varchar2 ( 40 char )  not null
  , pd_amount_type              varchar2 ( 20 char )  not null
  , pd_posting_code             varchar2 ( 80 char )  not null
  , pd_dr_or_cr                 varchar2 ( 2 char )   not null
  , pd_transaction_no           number   ( 12,0 )     not null
  , pd_negate_flag1             number   ( 12,0 )     not null
  , pd_journal_type             varchar2 ( 40 char )  not null
  , pd_valid_from               date                  not null
  , pd_valid_to                 date                  not null
);
create table stn.load_vie_posting_method
(
    event_typ                   varchar2 ( 20 char )  not null
  , vie_event_typ               varchar2 ( 20 char )  not null
  , vie_typ                     varchar2 ( 20 char )  not null
  , is_gaap_stat				char	 ( 1 byte  )  not null
);
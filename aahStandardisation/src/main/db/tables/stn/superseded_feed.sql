create table stn.superseded_feed
(
    superseding_feed_sid number ( 38 , 0 ) not null
,   superseded_feed_sid  number ( 38 , 0 ) not null
,   step_run_sid         number ( 38 , 0 ) not null
,   constraint pk_sfd primary key ( superseding_feed_sid , superseded_feed_sid )
,   constraint ck_sfd check       ( superseding_feed_sid <> superseded_feed_sid )
)
organization index;
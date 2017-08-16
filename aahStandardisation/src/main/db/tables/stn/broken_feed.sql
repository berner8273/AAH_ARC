create table stn.broken_feed
(
    feed_sid     number not null
,   step_run_sid number not null
,   constraint pk_bf primary key ( feed_sid )
)
organization index;
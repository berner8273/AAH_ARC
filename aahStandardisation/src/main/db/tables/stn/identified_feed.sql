create global temporary table stn.identified_feed
(
    feed_sid number ( 38 , 0 ) not null
,   constraint pk_if primary key ( feed_sid )
)
on commit delete rows
;
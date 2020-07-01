select
       superseding.feed_uuid superseding_feed_uuid
     , superseded.feed_uuid  superseded_feed_uuid
  from
            stn.superseded_feed sf
       join stn.feed            superseding on sf.superseding_feed_sid = superseding.feed_sid
       join stn.feed            superseded  on sf.superseded_feed_sid  = superseded.feed_sid
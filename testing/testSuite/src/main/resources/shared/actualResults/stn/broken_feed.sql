select
       fd.feed_uuid
  from
            stn.broken_feed bf
       join stn.feed        fd on bf.feed_sid = fd.feed_sid
create or replace view stn.insurance_policy_hierarchy
as
with
     insurance_policy_base
  as (
           select
                  ip.row_sid   insurance_policy_row_sid
                , ip.feed_uuid feed_uuid
                , ip.policy_id policy_id
                , cs.stream_id stream_id
                , null         parent_stream_id
             from
                       stn.insurance_policy  ip
                  join stn.cession           cs  on (
                                                            ip.policy_id = cs.policy_id
                                                        and ip.feed_uuid = cs.feed_uuid
                                                    )
            where
                  not exists (
                                 select
                                        null
                                   from
                                        stn.cession_link cl
                                  where
                                        cl.child_stream_id = cs.stream_id
                                    and cl.feed_uuid       = cs.feed_uuid
                             )
        union all
           select
                  ip.row_sid          insurance_policy_row_sid
                , ip.feed_uuid        feed_uuid
                , ip.policy_id        policy_id
                , cs.stream_id        stream_id
                , cl.parent_stream_id parent_stream_id
             from
                       stn.insurance_policy  ip
                  join stn.cession           cs on (
                                                           ip.policy_id = cs.policy_id
                                                       and ip.feed_uuid = cs.feed_uuid
                                                   )
                  join stn.cession_link      cl on (
                                                           cs.stream_id = cl.child_stream_id
                                                       and cs.feed_uuid = cl.feed_uuid
                                                   )
     )
    select
           ipb.insurance_policy_row_sid
         , ipb.feed_uuid
         , ipb.policy_id
         , ipb.stream_id
         , ipb.parent_stream_id
         , connect_by_root ( ipb.stream_id )           ultimate_parent_stream_id
         , sys_connect_by_path ( ipb.stream_id , '/' ) path_to_stream
      from
           insurance_policy_base ipb
start with 
           ipb.parent_stream_id is null
connect by
           prior ipb.stream_id = ipb.parent_stream_id
       and prior ipb.feed_uuid = ipb.feed_uuid
         ;
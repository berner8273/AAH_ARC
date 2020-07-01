select
       ple.le_cd parent_le_cd
     , cle.le_cd child_le_cd
     , lel.legal_entity_link_typ
     , lel.lpg_id
     , lel.event_status
     , lel.feed_uuid
  from
           stn.legal_entity_link lel
      join stn.legal_entity      ple on lel.parent_le_id = ple.le_id and lel.feed_uuid = ple.feed_uuid
      join stn.legal_entity      cle on lel.child_le_id  = cle.le_id and lel.feed_uuid = cle.feed_uuid
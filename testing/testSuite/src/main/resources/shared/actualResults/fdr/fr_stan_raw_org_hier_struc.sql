 select
       coalesce ( lel.feed_uuid , 
        ( select distinct lel2.feed_uuid
                from stn.legal_entity_link lel2  
               where fsrohs.PROCESS_ID = lel2.STEP_RUN_SID
        )
       ) feed_uuid
     , fsrohs.srhs_ons_child_org_node_code
     , fsrohs.srhs_ons_parent_org_node_code
     , fsrohs.srhs_ons_org_hier_type_code
     , fsrohs.srhs_active
     , fsrohs.event_status
     , fsrohs.lpg_id
  from
            fdr.fr_stan_raw_org_hier_struc fsrohs
  left join stn.legal_entity_link          lel    on trunc ( to_number ( fsrohs.message_id ) ) = lel.row_sid
select
       le.feed_uuid
     , fsrohn.srhn_on_org_node_code
     , fsrohn.srhn_ont_org_node_type_code
     , fsrohn.srhn_on_pl_party_legal_code
     , fsrohn.srhn_active
     , fsrohn.event_status
     , fsrohn.lpg_id
  from
            fdr.fr_stan_raw_org_hier_node fsrohn
       join stn.legal_entity              le    on to_number ( fsrohn.message_id ) = le.row_sid
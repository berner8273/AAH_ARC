select
       le.feed_uuid
     , fpt.pt_party_type_name
     , fsrpb.srpb_pbu_party_legal_code
     , fsrpb.srpb_pbu_name
     , fsrpb.srpb_pbu_party_bus_client_code
     , fsrpb.event_status
     , fsrpb.lpg_id
     , fsrpb.srpb_pbu_active
     , fsrpb.srpb_pbu_global_sa_id
  from
            fdr.fr_stan_raw_party_business fsrpb
       join fdr.fr_party_type              fpt   on fsrpb.srpb_pbu_pt_party_type_code = fpt.pt_party_type_id
       join stn.legal_entity               le    on to_number ( fsrpb.message_id )    = le.row_sid
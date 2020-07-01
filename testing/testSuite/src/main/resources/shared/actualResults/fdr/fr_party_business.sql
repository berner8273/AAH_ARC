select
       fpt.pt_party_type_name
     , fpb.pbu_pl_party_legal_id
     , fpb.pbu_name
     , fpb.pbu_party_bus_client_code
     , fpb.pbu_active
     , fpb.pbu_global_sa_id
  from
            fdr.fr_party_business fpb
       join fdr.fr_party_type     fpt   on fpb.pbu_pt_party_type_id = fpt.pt_party_type_id
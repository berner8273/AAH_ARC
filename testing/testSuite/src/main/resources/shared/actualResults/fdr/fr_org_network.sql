select
       fon.on_org_node_client_code
     , font.ont_org_node_type_name
     , fon.on_pl_party_legal_id
     , fon.on_active
  from
            fdr.fr_org_network   fon
       join fdr.fr_org_node_type font on fon.on_ont_org_node_type_id = font.ont_org_node_type_id
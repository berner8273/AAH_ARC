select
       fonp.on_org_node_client_code    parent_org_node_client_code
     , fonc.on_org_node_client_code    child_org_node_client_code
     , foht.oht_org_hier_type_name
     , fons.ons_active
  from
            fdr.fr_org_node_structure fons
       join fdr.fr_org_network        fonp on fons.ons_on_parent_org_node_id = fonp.on_org_node_id
       join fdr.fr_org_network        fonc on fons.ons_on_child_org_node_id  = fonc.on_org_node_id
       join fdr.fr_org_hierarchy_type foht on fons.ons_oht_org_hier_type_id  = foht.oht_org_hier_type_id
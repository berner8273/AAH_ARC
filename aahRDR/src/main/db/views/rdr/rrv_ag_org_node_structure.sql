create or replace view rdr.rrv_ag_org_node_structure
as
select
  ons_on_child_org_node_id  
  ,ons_on_parent_org_node_id 
  ,ons_oht_org_hier_type_id  
  ,ons_ownership_percent     
from fdr.fr_org_node_structure
;

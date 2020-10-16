create or replace view rdr.rrv_ag_org_hierarchy_type
as
select
  oht_org_hier_type_id      
  ,oht_org_hier_type_name    
  ,oht_org_hier_client_code  
  ,oht_org_hier_class        
from fdr.fr_org_hierarchy_type
;

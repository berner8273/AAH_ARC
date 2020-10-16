create or replace view rdr.rrv_ag_org_network
as
select
  on_org_node_id            
  ,on_si_sys_inst_id         
  ,on_org_node_client_code   
  ,on_ipe_internal_entity_id 
  ,on_ont_org_node_type_id   
  ,on_pl_party_legal_id      
  ,on_bo_book_id             
from fdr.fr_org_network
;

create or replace view rdr.rrv_ag_org_hier_levels
as
select
  ohl_oht_org_hier_type_id  
  ,ohl_root_type             
  ,ohl_root_max_depth        
  ,ohl_body1_type            
  ,ohl_body1_max_depth       
  ,ohl_body2_type            
  ,ohl_body2_max_depth       
  ,ohl_leaf_type             
  ,ohl_leaf_max_depth        
  ,ohl_body3_type            
  ,ohl_body3_max_depth       
  ,ohl_body4_type            
  ,ohl_body4_max_depth       
  ,ohl_body5_type            
  ,ohl_body5_max_depth       
  ,ohl_body6_type            
  ,ohl_body6_max_depth       
  ,ohl_body7_type            
  ,ohl_body7_max_depth       
from fdr.fr_org_hier_levels
;

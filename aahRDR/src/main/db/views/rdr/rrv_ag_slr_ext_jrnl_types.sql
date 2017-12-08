create or replace view rdr.rrv_ag_slr_ext_jrnl_types
as select
  ejt_type                    
, ejt_description             
, ejt_short_desc              
, ejt_jt_type                 
, ejt_balance_type_1          
, ejt_balance_type_2          
, ejt_madj_flag               
, ejt_requires_authorisation  
, ejt_eff_ejtr_code           
, ejt_rev_ejtr_code           
, ejt_rev_validation_flag     
, ejt_client_flag1            
, ejt_active_flag             
, ejt_created_by              
, ejt_created_on              
, ejt_amended_by              
, ejt_amended_on              
from slr.slr_ext_jrnl_types
;
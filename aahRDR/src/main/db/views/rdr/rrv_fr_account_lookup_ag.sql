create or replace view rdr.rrv_fr_account_lookup_ag
as
select 
al_posting_code
,al_lookup_1 as "business_typ"    
,al_lookup_2 as "mtm_yn"   
,al_lookup_3 as "business_unit"   
,al_lookup_4    
,al_lookup_5    
,al_lookup_6    
,al_lookup_7    
,al_lookup_8    
,al_lookup_9    
,al_lookup_10   
,al_lookup_11   
,al_lookup_12   
,al_lookup_13   
,al_lookup_14   
,al_lookup_15   
,al_lookup_16   
,al_lookup_17   
,al_lookup_18   
,al_lookup_19   
,al_lookup_20   
,al_ccy         
,al_account     
,al_valid_from  
,al_valid_to    
,al_active      
,al_action      
,al_input_by    
,al_input_time  
,al_delete_time 
,al_auth_by     
,al_auth_status 
al_id
from fdr.fr_account_lookup          
;

 
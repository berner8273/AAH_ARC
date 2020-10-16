create or replace view rdr.rrv_ag_program
as
select
gc_general_code_id   
,gc_gct_code_type_id  
,gc_client_code as chartfield_cd      
,gc_client_text1 as chartfield_typ     
,gc_client_text2 as chartfield_descr     
,gc_description       
,gc_active            
,gc_input_by          
,gc_auth_by           
,gc_auth_status       
,gc_input_time        
,gc_valid_from        
,gc_valid_to          
,gc_delete_time
from fdr.fr_general_codes
where gc_gct_code_type_id = 'GL_CHARTFIELD'
;
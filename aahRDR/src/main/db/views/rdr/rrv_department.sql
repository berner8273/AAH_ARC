create or replace view rdr.rrv_department
as
select
  bo_book_id dept_cd  
  ,bo_bs_book_status_id                    
  ,bo_ipe_internal_entity_id               
  ,bo_book_clicode                         
  ,bo_book_name dept_descr                           
  ,bo_banking_or_trading                   
  ,bo_ledger_book_code                     
  ,bo_active                               
  ,bo_book_usage                           
  ,bo_input_by                             
  ,bo_associated_funding                   
  ,bo_auth_by                              
  ,bo_client_text1                         
  ,bo_auth_status                          
  ,bo_client_text2                         
  ,bo_input_time                           
  ,bo_client_text3                         
  ,bo_valid_from                           
  ,bo_client_text4                         
  ,bo_valid_to                             
  ,bo_client_text5                         
  ,bo_delete_time                          
  ,bo_sub_account_code                     
  ,bo_ias_ind                              
  ,bo_client_text6                         
  ,bo_client_text7                         
  ,bo_client_text8                         
  ,bo_client_text9                         
  ,bo_client_text10                        
  ,bo_pl_ledger_entity_code                
  ,bo_interfaceadj_active                  
  ,bo_manadj_active                        
  ,bo_associated_fails_book                
  ,bo_fails_funding                        
  ,bo_fx_risk_flag                         
  ,bo_central_flag                         
from fdr.fr_book                           
;

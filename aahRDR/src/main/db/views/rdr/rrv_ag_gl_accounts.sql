create or replace view rdr.rrv_ag_gl_accounts
as
select 
  ga_account_code             
, ga_account_name             
, ga_account_type             
, ga_event                    
, ga_profit_loss_clitype1     
, ga_account_adjustment_type  
, ga_account_parent           
, ga_account_id               
, ga_active                   
, ga_auth_by                  
, ga_auth_status              
, ga_input_time               
, ga_valid_from               
, ga_valid_to                 
, ga_delete_time              
, ga_input_by                 
, ga_control_account_flag     
, ga_account_grouping         
, ga_account_reporting_typ1   
, ga_account_class            
, ga_account_reporting_typ2   
, ga_client_text1             
, ga_client_text2 as acct_cat            
, ga_client_text3 as account_genus            
, ga_client_text4 as acct_cd            
, ga_client_text5             
, ga_account_owner            
, ga_revaluation_ind          
, ga_fak_segment_flag_1       
, ga_fak_segment_flag_2       
, ga_fak_segment_flag_3       
, ga_fak_segment_flag_4       
, ga_fak_segment_flag_5       
, ga_fak_segment_flag_6       
, ga_fak_segment_flag_7       
, ga_fak_segment_flag_8       
, ga_fak_segment_flag_9       
, ga_fak_segment_flag_10      
, ga_eba_segment_flag_1       
, ga_eba_segment_flag_2       
, ga_eba_segment_flag_3       
, ga_eba_segment_flag_4       
, ga_eba_segment_flag_5       
, ga_account_short_name       
, ga_client_text6             
, ga_client_text7             
, ga_client_text8             
, ga_client_text9             
, ga_client_text10            
, ga_client_indicator1        
, ga_client_indicator2        
, ga_client_indicator3        
, ga_client_indicator4        
, ga_client_indicator5        
, ga_lc_liquidity_class_id    
, ga_account_type_flag        
, ga_position_flag
from fdr.fr_gl_account            
;

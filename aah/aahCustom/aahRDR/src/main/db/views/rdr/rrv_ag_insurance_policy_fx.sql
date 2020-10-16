create or replace view rdr.rrv_ag_insurance_policy_fx
as
select
fr_fxrate_date           
,fr_cu_currency_numer_id  
,fr_cu_currency_denom_id  
,fr_si_sys_inst_id        
,fr_fx_rate               
,fr_rty_rate_type_id      
,fr_pl_party_legal_id     
,fr_active                
,fr_input_by              
,fr_input_time            
,fr_fxrate_date_fwd       
,fr_fxrate_id
from fdr.fr_fx_rate
where fr_rty_rate_type_id like '%POL%'
;           
create or replace view rdr.rrv_ag_ledger
as
select
ps_posting_schema       as ledger_cd
,ps_posting_schema_group 
,ps_valid_from           
,ps_valid_to             
,ps_active               
,ps_action               
,ps_input_by             
,ps_input_time           
,ps_delete_time          
,ps_auth_by              
,ps_auth_status
from fdr.fr_posting_schema
;
         
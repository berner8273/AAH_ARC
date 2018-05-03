CREATE OR REPLACE VIEW slr.v_slr_fxreval_rule0_accts(accounting_basis , source_account , execution_type, premium_type, business_type, event_class, fx_event_type) AS 
select distinct 
   lk_match_key1 as accounting_basis
 , lk_match_key2 as source_account
 , lk_match_key3 as execution_type
 , lk_match_key4 as premium_type
 , lk_match_key5 as business_type
 , lk_match_key6 as event_class
 , lk_lookup_value1 as fx_event_type
from fdr.fr_general_lookup 
where LK_LKT_LOOKUP_TYPE_CODE = 'FXREVAL_GL_MAPPINGS'
and lk_match_key9 = 'FXRULE0'
order by 1,7,3,4,5;
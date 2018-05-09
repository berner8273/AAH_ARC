CREATE OR REPLACE VIEW slr.v_slr_fxreval_parameters (mth_nbr , year_nbr , event_class, accounting_basis, run_fx_flag) AS 
  SELECT 
    lk_match_key1 as mth_nbr
  , lk_match_key2 as year_nbr
  , lk_match_key3 as event_class
  , lk_match_key4 as accounting_basis
  , lk_lookup_value1 as run_fx_flag
FROM fdr.fr_general_lookup 
WHERE lk_lkt_lookup_type_code = 'FXREVAL_PARAMETERS';
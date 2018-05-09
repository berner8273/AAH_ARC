CREATE OR REPLACE VIEW slr.v_slr_fxreval_run_values(mth_nbr , year_nbr , event_class) AS 
  SELECT 
    lk_match_key1 as mth_nbr
  , lk_match_key2 as year_nbr
  , lk_match_key3 as event_class
FROM fdr.fr_general_lookup 
WHERE lk_lkt_lookup_type_code = 'FXREVAL_RUN_VALUES';
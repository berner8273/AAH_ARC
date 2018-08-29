create or replace view slr.v_slr_fxreval_run_values as 
select
       fgl.lk_match_key1    mth_nbr
     , fgl.lk_match_key2    year_nbr
     , fgl.lk_match_key3    event_class
  from 
       fdr.fr_general_lookup fgl
 where 
       lk_lkt_lookup_type_code = 'FXREVAL_RUN_VALUES'
;
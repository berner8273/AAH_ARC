create or replace view stn.tax_jurisdiction_default
as
select
       max ( case when fgl.lk_match_key1 = 'SRGC_GCT_CODE_TYPE_ID'
                  then fgl.lk_lookup_value1
             end )   SRGC_GCT_CODE_TYPE_ID
  from
       fdr.fr_general_lookup fgl
 where
       fgl.lk_lkt_lookup_type_code = 'TAX_JURISDICTION_DEFAULT'
     ;
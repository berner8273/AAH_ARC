select
       fsrgl.srlk_lkt_lookup_type_code      feed_typ
     , fsrgl.srlk_match_key1                event_category
     , fsrgl.srlk_lookup_value1             event_category_descr
     , trunc ( fsrgl.srlk_effective_from )  effective_from
     , fsrgl.srlk_effective_to              effective_to
     , fsrgl.srlk_active                    event_category_sts
     , fsrgl.event_status                   event_status
     , fsrgl.lpg_id                         lpg_id
  from
       fdr.fr_stan_raw_general_lookup fsrgl
 where
       fsrgl.srlk_lkt_lookup_type_code = 'EVENT_CATEGORY'
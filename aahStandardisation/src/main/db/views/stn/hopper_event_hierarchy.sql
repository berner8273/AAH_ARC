create or replace view stn.hopper_event_hierarchy
as
select
       fsrgl.srlk_lkt_lookup_type_code  feed_typ
     , fsrgl.srlk_match_key1            event_typ
     , fsrgl.srlk_lookup_value1         event_subgrp
     , fsrgl.srlk_lookup_value2         event_grp
     , fsrgl.srlk_lookup_value3         event_class
     , fsrgl.srlk_lookup_value4         event_category
     , fsrgl.srlk_lookup_value5         is_cash_event
     , fsrgl.srlk_lookup_value6         is_core_earning_event
     , fsrgl.srlk_effective_from        effective_from
     , fsrgl.srlk_effective_to          effective_to
     , fsrgl.srlk_active                event_typ_sts
     , fsrgl.event_status               event_status
     , fsrgl.message_id                 message_id
     , fsrgl.process_id                 process_id
     , fsrgl.lpg_id                     lpg_id
  from
       fdr.fr_stan_raw_general_lookup fsrgl
 where
       fsrgl.srlk_lkt_lookup_type_code = 'EVENT_HIERARCHY'
  with
       check option
     ;
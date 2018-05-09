create or replace view stn.event_hierarchy_reference
as
select
       fgl.lk_match_key1            event_typ
     , fgl.lk_lookup_value1         event_subgrp
     , fgl.lk_lookup_value2         event_grp
     , fgl.lk_lookup_value3         event_class
     , fgl.lk_lookup_value4         event_category
     , fgl.lk_lookup_value5         is_cash_event
     , fgl.lk_lookup_value6         is_core_earning_event
     , fgl.lk_effective_from        effective_from
     , fgl.lk_effective_to          effective_to
     , fgl.lk_active                event_typ_sts
  from
       fdr.fr_general_lookup fgl
 where
       fgl.lk_lkt_lookup_type_code = 'EVENT_HIERARCHY'
;
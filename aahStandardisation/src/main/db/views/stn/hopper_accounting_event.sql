create or replace view stn.hopper_accounting_event
as
select
       fsrgl.srlk_lkt_lookup_type_code  feed_typ
     , fsrgl.srlk_match_key1            event_typ
     , fsrgl.srlk_lookup_value1         event_typ_descr
     , fsrgl.srlk_lookup_value2         business_event_typ
     , fsrgl.srlk_lookup_value3         business_event_typ_descr
     , fsrgl.srlk_lookup_value4         event_subgrp
     , fsrgl.srlk_lookup_value5         event_subgrp_descr
     , fsrgl.srlk_lookup_value6         event_grp
     , fsrgl.srlk_lookup_value7         event_grp_descr
     , fsrgl.srlk_lookup_value8         event_class
     , fsrgl.srlk_lookup_value9         event_class_descr
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
       fsrgl.srlk_lkt_lookup_type_code = 'ACCOUNTING_EVENT'
  with
       check option
     ;
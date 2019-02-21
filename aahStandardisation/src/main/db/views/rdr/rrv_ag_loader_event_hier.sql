create or replace view rdr.rrv_ag_loader_event_hier
as
with
     event_category
  as (
          select
                fgl.lk_match_key1    event_category
              , fgl.lk_lookup_value1 event_category_descr
           from
                     fdr.fr_general_lookup fgl
                join (
                           select
                                  fgli.lk_match_key1         event_category
                                , max ( fgli.lk_input_time ) mx_tm
                             from
                                  fdr.fr_general_lookup fgli
                            where
                                  fgli.lk_lkt_lookup_type_code = 'EVENT_CATEGORY'
                              and fgli.lk_active               = 'A'
                         group by
                                  fgli.lk_match_key1
                     )
                     mx_eg
                  on (
                             fgl.lk_match_key1 = mx_eg.event_category
                         and fgl.lk_input_time = mx_eg.mx_tm
                     )
          where
                fgl.lk_lkt_lookup_type_code = 'EVENT_CLASS'
            and fgl.lk_active               = 'A'
     )
   , event_class
  as (
          select
                fgl.lk_match_key1    event_class
              , fgl.lk_lookup_value1 event_class_descr
              , fgl.lk_lookup_value2 event_class_period_freq
           from
                     fdr.fr_general_lookup fgl
                join (
                           select
                                  fgli.lk_match_key1         event_class
                                , max ( fgli.lk_input_time ) mx_tm
                             from
                                  fdr.fr_general_lookup fgli
                            where
                                  fgli.lk_lkt_lookup_type_code = 'EVENT_CLASS'
                              and fgli.lk_active               = 'A'
                         group by
                                  fgli.lk_match_key1
                     )
                     mx_eg
                  on (
                             fgl.lk_match_key1 = mx_eg.event_class
                         and fgl.lk_input_time = mx_eg.mx_tm
                     )
          where
                fgl.lk_lkt_lookup_type_code = 'EVENT_CLASS'
            and fgl.lk_active               = 'A'
     )
   , event_grp
  as (
          select
                fgl.lk_match_key1    event_grp
              , fgl.lk_lookup_value1 event_grp_descr
           from
                     fdr.fr_general_lookup fgl
                join (
                           select
                                  fgli.lk_match_key1         event_grp
                                , max ( fgli.lk_input_time ) mx_tm
                             from
                                  fdr.fr_general_lookup fgli
                            where
                                  fgli.lk_lkt_lookup_type_code = 'EVENT_GROUP'
                              and fgli.lk_active               = 'A'
                         group by
                                  fgli.lk_match_key1
                     )
                     mx_eg
                  on (
                             fgl.lk_match_key1 = mx_eg.event_grp
                         and fgl.lk_input_time = mx_eg.mx_tm
                     )
          where
                fgl.lk_lkt_lookup_type_code = 'EVENT_GROUP'
            and fgl.lk_active               = 'A'
     )
    , event_subgrp
  as (
          select
                fgl.lk_match_key1    event_subgrp
              , fgl.lk_lookup_value1 event_subgrp_descr
           from
                     fdr.fr_general_lookup fgl
                join (
                           select
                                  fgli.lk_match_key1         event_subgrp
                                , max ( fgli.lk_input_time ) mx_tm
                             from
                                  fdr.fr_general_lookup fgli
                            where
                                  fgli.lk_lkt_lookup_type_code = 'EVENT_SUBGROUP'
                              and fgli.lk_active               = 'A'
                         group by
                                  fgli.lk_match_key1
                     )
                     mx_eg
                  on (
                             fgl.lk_match_key1 = mx_eg.event_subgrp
                         and fgl.lk_input_time = mx_eg.mx_tm
                     )
          where
                fgl.lk_lkt_lookup_type_code = 'EVENT_SUBGROUP'
            and fgl.lk_active               = 'A'
     ) 
    , event_type
  as (
          select
                fgl.lk_match_key1                 event_typ
              , fgl.lk_lookup_value1              event_subgrp
              , fgl.lk_lookup_value2              event_grp
              , fgl.lk_lookup_value3              event_class
              , fgl.lk_lookup_value4              event_category
              , fgl.lk_lookup_value5              is_cash_event
              , fgl.lk_lookup_value6              is_core_earning_event
              , to_number(fgl.lk_lookup_value10)  event_typ_seq_id
           from
                     fdr.fr_general_lookup fgl
                join (
                           select
                                  fgli.lk_match_key1         event_subgrp
                                , max ( fgli.lk_input_time ) mx_tm
                             from
                                  fdr.fr_general_lookup fgli
                            where
                                  fgli.lk_lkt_lookup_type_code = 'EVENT_HIERARCHY'
                              and fgli.lk_active               = 'A'
                         group by
                                  fgli.lk_match_key1
                     )
                     mx_eg
                  on (
                             fgl.lk_match_key1 = mx_eg.event_subgrp
                         and fgl.lk_input_time = mx_eg.mx_tm
                     )
          where
                fgl.lk_lkt_lookup_type_code = 'EVENT_HIERARCHY'
            and fgl.lk_active               = 'A'
     ) 
select
       'Existing'                  change_status
     , etyp.event_class
     , ecls.event_class_descr
     , ecls.event_class_period_freq
     , etyp.event_grp
     , egrp.event_grp_descr
     , etyp.event_subgrp
     , esgp.event_subgrp_descr
     , etyp.event_typ
     , faet.aet_acc_event_type_name   event_typ_descr
     , etyp.event_typ_seq_id
     , etyp.is_cash_event
     , etyp.is_core_earning_event
     , etyp.event_category
     , ecat.event_category_descr
  from
                 event_type            etyp
       left join event_category        ecat on etyp.event_category = ecat.event_category
       left join event_class           ecls on etyp.event_class    = ecls.event_class
       left join event_grp             egrp on etyp.event_grp      = egrp.event_grp
       left join event_subgrp          esgp on etyp.event_subgrp   = esgp.event_subgrp
       left join fdr.fr_acc_event_type faet on etyp.event_typ      = faet.aet_acc_event_type_id
 order by
       event_typ_seq_id
     , event_class
     , event_grp
     , event_subgrp
     , event_typ
;
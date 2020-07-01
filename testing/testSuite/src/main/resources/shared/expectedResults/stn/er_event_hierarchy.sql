select
       feed_uuid
     , event_typ
     , event_typ_descr
     , event_subgrp
     , event_subgrp_descr
     , event_grp
     , event_grp_descr
     , event_class
     , event_class_descr
     , event_category_cd
     , event_category_descr
     , is_cash_event
     , is_core_earning_event
     , event_class_period_freq
     , lpg_id
     , event_status
     , no_retries
  from
       er_event_hierarchy
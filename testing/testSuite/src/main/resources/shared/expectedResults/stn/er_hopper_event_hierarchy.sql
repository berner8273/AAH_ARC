select
       feed_uuid
     , feed_typ
     , event_typ
     , event_subgrp
     , event_grp
     , event_class
     , event_category
     , is_cash_event
     , is_core_earning_event
     , effective_from
	 , effective_to
     , event_typ_sts
     , event_status
     , lpg_id
  from
       er_hopper_event_hierarchy
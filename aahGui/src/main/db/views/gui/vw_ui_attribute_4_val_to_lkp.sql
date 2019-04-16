create or replace view gui.vw_ui_attribute_4_val_to_lkp
(
   fdr_lookup_key,
   description
) as
select aet_acc_event_type_id,
       aet_acc_event_type_name
from fdr.fr_acc_event_type faet
     where faet.aet_active = 'A'
	 order by aet_acc_event_type_name
;

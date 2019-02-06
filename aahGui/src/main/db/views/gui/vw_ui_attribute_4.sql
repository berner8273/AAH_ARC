create or replace view gui.vw_ui_attribute_4
(
   fdr_code,
   fdr_description,
   lookup_key,
   source_system_id,
   parent_id,
   entity
)
as
select aet_acc_event_type_id    as fdr_code,
       aet_acc_event_type_name  as fdr_description,
       aet_acc_event_type_id    as lookup_key,
      'Client Static'           as source_system_id,
       null                     as parent_id,
       null                     as entity
from fdr.fr_acc_event_type faet
     where faet.aet_active = 'A'
;


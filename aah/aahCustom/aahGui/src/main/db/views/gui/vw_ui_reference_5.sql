create or replace view gui.vw_ui_reference_5
(
   fdr_code,
   fdr_description,
   lookup_key,
   source_system_id,
   parent_id,
   entity
)
as
select be.business_event_cd  as fdr_code,
       be.business_event_cd  as fdr_description,
       be.business_event_cd  as lookup_key,
       'Client Static'       as source_system_id,
       null                  as parent_id,
       null                  as entity
from stn.business_event be
;



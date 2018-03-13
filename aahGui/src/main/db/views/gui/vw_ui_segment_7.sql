create or replace view gui.vw_ui_segment_7
(
   fdr_code,
   fdr_description,
   lookup_key,
   source_system_id,
   parent_id,
   entity
)
as
select bt.business_typ        as fdr_code,
       bt.business_typ_descr as fdr_description,
       bt.business_typ        as lookup_key,
       'Client Static' as source_system_id,
       null as parent_id,
       null as entity
from stn.business_type bt
;



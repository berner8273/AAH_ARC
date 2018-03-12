create or replace view gui.vw_ui_attribute_3
(
   fdr_code,
   fdr_description,
   lookup_key,
   source_system_id,
   parent_id,
   entity
)
as
select premium_typ          as fdr_code,
       premium_typ          as fdr_description,
       premium_typ          as lookup_key,
      'Client Static'       as source_system_id,
       null                 as parent_id,
       null                 as entity
from STN.JOURNAL_LINE_PREMIUM_TYPE
;


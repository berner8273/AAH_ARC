create or replace force view gui.vw_ui_attribute_1
(
   fdr_code,
   fdr_description,
   lookup_key,
   source_system_id,
   parent_id,
   entity
)
as
select t_source_tran_no  as fdr_code,
       t_source_tran_no  as fdr_description,
       t_source_tran_no  as lookup_key,
      'Client Static'    as source_system_id,
       null              as parent_id,
       null              as entity
from fdr.fr_trade
;


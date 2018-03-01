create or replace force view gui.vw_ui_attribute_2
(
   fdr_code,
   fdr_description,
   lookup_key,
   source_system_id,
   parent_id,
   entity
)
as
select gc_client_code       as fdr_code,
       gc_client_text2      as fdr_description,
       gc_general_code_id   as lookup_key,
      'Client Static'       as source_system_id,
       null                 as parent_id,
       null                 as entity
from fdr.fr_general_codes where gc_gct_code_type_id = 'TAX_JURISDICTION'
;

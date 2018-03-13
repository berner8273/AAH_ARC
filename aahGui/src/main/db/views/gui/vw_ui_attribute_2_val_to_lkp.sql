create or replace view gui.vw_ui_attribute_2_val_to_lkp
(
   fdr_lookup_key,
   description
) as
select gc_client_code,
       gc_client_text2
from fdr.fr_general_codes where gc_gct_code_type_id = 'TAX_JURISDICTION'
;

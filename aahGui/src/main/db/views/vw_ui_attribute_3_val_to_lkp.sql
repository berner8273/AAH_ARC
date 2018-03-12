create or replace view gui.vw_ui_attribute_3_val_to_lkp
(
   fdr_lookup_key,
   description
) as
select premium_typ,
       premium_typ
from stn.journal_line_premium_type
;

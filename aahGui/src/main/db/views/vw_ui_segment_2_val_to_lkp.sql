create or replace force view gui.vw_ui_segment_2_val_to_lkp
(
   fdr_lookup_key,
   description
)
as
select distinct fgl.lk_lookup_value1,
                   fgl.lk_lookup_value1
from fdr.fr_general_lookup fgl
where fgl.lk_lkt_lookup_type_code like 'ACCOUNTING_BASIS%'
;


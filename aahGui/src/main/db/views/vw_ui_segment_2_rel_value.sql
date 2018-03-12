create or replace view gui.vw_ui_segment_2_rel_value
(
   fdr_code,
   lookup_value
) as
select distinct fgl.lk_lookup_value1,
                   fgl.lk_lookup_value1
from fdr.fr_general_lookup fgl
where fgl.lk_lkt_lookup_type_code like 'ACCOUNTING_BASIS%'
;


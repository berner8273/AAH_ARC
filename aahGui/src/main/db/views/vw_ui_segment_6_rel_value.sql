create or replace force view gui.vw_ui_segment_6_rel_value
(
   fdr_code,
   lookup_value
) as
select et.execution_typ,
        et.execution_typ 
from stn.execution_type et
;


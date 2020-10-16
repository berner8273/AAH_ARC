create or replace view gui.vw_ui_segment_6_val_to_lkp
(
   fdr_lookup_key,
   description
)
as
 select et.execution_typ as fdr_lookup_key,
        et.execution_typ_descr as description 
from stn.execution_type et
;

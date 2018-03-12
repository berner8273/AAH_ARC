create or replace view gui.vw_ui_segment_7_val_to_lkp
(
   fdr_lookup_key,
   description
)
as
   select bt.business_typ as fdr_lookup_key,
          bt.business_typ_descr as description 
from stn.business_type bt
;



create or replace view gui.vw_ui_segment_7_rel_value
(
   fdr_code,
   lookup_value
) as
select bt.business_typ,
       bt.business_typ 
from stn.business_type bt
;


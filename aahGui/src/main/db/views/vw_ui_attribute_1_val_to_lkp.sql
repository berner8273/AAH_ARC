create or replace force view gui.vw_ui_attribute_1_val_to_lkp
(
   fdr_lookup_key,
   description
) as
select t_source_tran_no,
       t_source_tran_no
from fdr.fr_trade
;


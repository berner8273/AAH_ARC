create or replace view gui.vw_ui_segment_1_val_to_lkp
(
   fdr_lookup_key,
   description
)
as
   select ps_posting_schema, ps_posting_schema from fdr.fr_posting_schema
;






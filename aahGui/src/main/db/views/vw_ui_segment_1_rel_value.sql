create or replace force view gui.vw_ui_segment_1_rel_value
(
   fdr_code,
   lookup_value
)
as
   select p.ps_posting_schema as fdr_code, p.ps_posting_schema as lookup_value
     from fdr.fr_posting_schema p
;




create or replace view gui.vw_ui_attribute_1
(
   fdr_code,
   fdr_description,
   lookup_key,
   source_system_id,
   parent_id,
   entity
)
as
   select ft.t_source_tran_no fdr_code
         ,ft.t_source_tran_no fdr_description
         ,ft.t_source_tran_no lookup_key
         ,'Client Static' source_system_id
         ,fiie.iie_cover_signing_party parent_id
         ,NULL entity 
     from fdr.fr_instrument fi
          join fdr.fr_instr_insure_extend fiie
             on fiie.iie_instrument_id = fi.i_instrument_id
          join fdr.fr_trade ft 
             on ft.t_i_instrument_id = fi.i_instrument_id
;



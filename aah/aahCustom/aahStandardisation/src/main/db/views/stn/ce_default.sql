create or replace view stn.ce_default
as
select
       max ( case when fgl.lk_match_key1 = 'SYSTEM_INSTANCE'
                  then fgl.lk_lookup_value1
             end )                                                  system_instance
     , max ( case when fgl.lk_match_key1 = 'SRAE_GL_PERSON_CODE'
                  then fgl.lk_lookup_value1
             end )                                                  srae_gl_person_code
     , max ( case when fgl.lk_match_key1 = 'SRAE_SOURCE_SYSTEM'
                  then fgl.lk_lookup_value1
             end )                                                  srae_source_system
     , max ( case when fgl.lk_match_key1 = 'SRAE_INSTR_SUPER_CLASS'
                  then fgl.lk_lookup_value1
             end )                                                  srae_instr_super_class
     , max ( case when fgl.lk_match_key1 = 'SRAE_INSTRUMENT_CODE'
                  then fgl.lk_lookup_value1
             end )                                                  srae_instrument_code
     , max ( case when fgl.lk_match_key1 = 'TAX_JURISDICTION'
                  then fgl.lk_lookup_value1
             end )                                                  tax_jurisdiction
  from
       fdr.fr_general_lookup fgl
 where
       fgl.lk_lkt_lookup_type_code = 'CE_DEFAULT'
     ;
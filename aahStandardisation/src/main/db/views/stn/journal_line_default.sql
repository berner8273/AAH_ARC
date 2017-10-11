CREATE OR REPLACE VIEW stn.journal_line_default
AS


 select
       max ( case when fgl.lk_match_key1 = 'SRA_AE_SOURCE_SYSTEM'
                  then fgl.lk_lookup_value1
             end )   SRA_AE_SOURCE_SYSTEM,
       max ( case when fgl.lk_match_key1 = 'SRA_AE_ITSC_INST_TYP_SCLSS_CD'
                  then fgl.lk_lookup_value1
             end )   SRA_AE_ITSC_INST_TYP_SCLSS_CD,
       max ( case when fgl.lk_match_key1 = 'SRA_SI_ACCOUNT_SYS_INST_CODE'
                  then fgl.lk_lookup_value1
             end )   SRA_SI_ACCOUNT_SYS_INST_CODE,
       max ( case when fgl.lk_match_key1 = 'SRA_SI_INSTR_SYS_INST_CODE'
                  then fgl.lk_lookup_value1
             end )   SRA_SI_INSTR_SYS_INST_CODE,
       max ( case when fgl.lk_match_key1 = 'SRA_SI_PARTY_SYS_INST_CODE'
                  then fgl.lk_lookup_value1
             end )   SRA_SI_PARTY_SYS_INST_CODE,
       max ( case when fgl.lk_match_key1 = 'SRA_SI_STATIC_SYS_INST_CODE'
                  then fgl.lk_lookup_value1
             end )   SRA_SI_STATIC_SYS_INST_CODE,
       max ( case when fgl.lk_match_key1 = 'SRA_AE_IPE_INT_ENTITY_CODE'
                  then fgl.lk_lookup_value1
             end )   SRA_AE_IPE_INT_ENTITY_CODE,
       max ( case when fgl.lk_match_key1 = 'SRA_AE_AET_ACC_EVENT_TYPE_CODE'
                  then fgl.lk_lookup_value1
             end )   SRA_AE_AET_ACC_EVENT_TYPE_CODE,
       max ( case when fgl.lk_match_key1 = 'SRA_AE_CU_LOCAL_CURRENCY_CODE'
                  then fgl.lk_lookup_value1
             end )   SRA_AE_CU_LOCAL_CURRENCY_CODE,
       max ( case when fgl.lk_match_key1 = 'SRA_AE_CU_BASE_CURRENCY_CODE'
                  then fgl.lk_lookup_value1
             end )   SRA_AE_CU_BASE_CURRENCY_CODE,
       max ( case when fgl.lk_match_key1 = 'SRA_AE_I_INSTRUMENT_CLICODE'
                  then fgl.lk_lookup_value1
             end )   SRA_AE_I_INSTRUMENT_CLICODE,
       max ( case when fgl.lk_match_key1 = 'SRA_AE_IT_INSTR_TYPE_CODE'
                  then fgl.lk_lookup_value1
             end )   SRA_AE_IT_INSTR_TYPE_CODE,
       max ( case when fgl.lk_match_key1 = 'SRA_AE_ITC_INST_TYP_CLS_CODE'
                  then fgl.lk_lookup_value1
             end )   SRA_AE_ITC_INST_TYP_CLS_CODE,
       max ( case when fgl.lk_match_key1 = 'SRA_AE_PE_PERSON_CODE'
                  then fgl.lk_lookup_value1
             end )   SRA_AE_PE_PERSON_CODE,
       max ( case when fgl.lk_match_key1 = 'SRA_AE_GL_INSTRUMENT_ID'
                  then fgl.lk_lookup_value1
             end )   SRA_AE_GL_INSTRUMENT_ID,
       max ( case when fgl.lk_match_key1 = 'SRA_AE_INSTR_TYPE_MAP_CODE'
                  then fgl.lk_lookup_value1
             end )   SRA_AE_INSTR_TYPE_MAP_CODE,
       max ( case when fgl.lk_match_key1 = 'SRA_AE_PBU_EXT_PARTY_CODE'
                  then fgl.lk_lookup_value1
             end )   SRA_AE_PBU_EXT_PARTY_CODE

     FROM fdr.fr_general_lookup fgl
    WHERE fgl.lk_lkt_lookup_type_code = 'JOURNAL_LINE_DEFAULT'

--    grant select on fdr.fr_general_lookup to STN with grant option
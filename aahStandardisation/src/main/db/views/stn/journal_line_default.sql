create or replace view stn.journal_line_default
as
 select
        max ( case when fgl.lk_match_key1 = 'SRA_AE_JOURNAL_TYPE'
                   then fgl.lk_lookup_value1
              end )                                                             sra_ae_journal_type
      , max ( case when fgl.lk_match_key1 = 'SRA_AE_SOURCE_SYSTEM'
                   then fgl.lk_lookup_value1
              end )                                                             sra_ae_source_system
      , max ( case when fgl.lk_match_key1 = 'SRA_AE_ITSC_INST_TYP_SCLSS_CD'
                   then fgl.lk_lookup_value1
              end )                                                             sra_ae_itsc_inst_typ_sclss_cd
      , max ( case when fgl.lk_match_key1 = 'SRA_SI_ACCOUNT_SYS_INST_CODE'
                   then fgl.lk_lookup_value1
              end )                                                             sra_si_account_sys_inst_code
      , max ( case when fgl.lk_match_key1 = 'SRA_SI_INSTR_SYS_INST_CODE'
                   then fgl.lk_lookup_value1
              end )                                                             sra_si_instr_sys_inst_code
      , max ( case when fgl.lk_match_key1 = 'SRA_SI_PARTY_SYS_INST_CODE'
                   then fgl.lk_lookup_value1
              end )                                                             sra_si_party_sys_inst_code
      , max ( case when fgl.lk_match_key1 = 'SRA_SI_STATIC_SYS_INST_CODE'
                   then fgl.lk_lookup_value1
              end )                                                             sra_si_static_sys_inst_code
      , max ( case when fgl.lk_match_key1 = 'SRA_AE_IPE_INT_ENTITY_CODE'
                   then fgl.lk_lookup_value1
              end )                                                             sra_ae_ipe_int_entity_code
      , max ( case when fgl.lk_match_key1 = 'SRA_AE_AET_ACC_EVENT_TYPE_CODE'
                   then fgl.lk_lookup_value1
              end )                                                             sra_ae_aet_acc_event_type_code
      , max ( case when fgl.lk_match_key1 = 'SRA_AE_CU_LOCAL_CURRENCY_CODE'
                   then fgl.lk_lookup_value1
              end )                                                             sra_ae_cu_local_currency_code
      , max ( case when fgl.lk_match_key1 = 'SRA_AE_CU_BASE_CURRENCY_CODE'
                   then fgl.lk_lookup_value1
              end )                                                             sra_ae_cu_base_currency_code
      , max ( case when fgl.lk_match_key1 = 'SRA_AE_I_INSTRUMENT_CLICODE'
                   then fgl.lk_lookup_value1
              end )                                                             sra_ae_i_instrument_clicode
      , max ( case when fgl.lk_match_key1 = 'SRA_AE_IT_INSTR_TYPE_CODE'
                   then fgl.lk_lookup_value1
              end )                                                             sra_ae_it_instr_type_code
      , max ( case when fgl.lk_match_key1 = 'SRA_AE_ITC_INST_TYP_CLS_CODE'
                   then fgl.lk_lookup_value1
              end )                                                             sra_ae_itc_inst_typ_cls_code
      , max ( case when fgl.lk_match_key1 = 'SRA_AE_PE_PERSON_CODE'
                   then fgl.lk_lookup_value1
              end )                                                             sra_ae_pe_person_code
      , max ( case when fgl.lk_match_key1 = 'SRA_AE_GL_INSTRUMENT_ID'
                   then fgl.lk_lookup_value1
              end )                                                             sra_ae_gl_instrument_id
      , max ( case when fgl.lk_match_key1 = 'SRA_AE_INSTR_TYPE_MAP_CODE'
                   then fgl.lk_lookup_value1
              end )                                                             sra_ae_instr_type_map_code
      , max ( case when fgl.lk_match_key1 = 'SRA_AE_PBU_EXT_PARTY_CODE'
                   then fgl.lk_lookup_value1
              end )                                                             sra_ae_pbu_ext_party_code
   from
        fdr.fr_general_lookup fgl
  where
        fgl.lk_lkt_lookup_type_code = 'JOURNAL_LINE_DEFAULT'
      ;

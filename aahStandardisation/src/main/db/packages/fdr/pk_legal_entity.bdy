create or replace package body fdr.pk_legal_entity
as

    procedure pr_seed_data
    (
        p_step_run_sid in number
    )
    as

        v_no_records_inserted number;

    begin
        insert
          into
               fdr.fr_lpg_config
             (
                 lc_lpg_id
             ,   lc_grp_code
             )
        select
               to_number ( fpl.pl_client_text3 ) lc_lpg_id
             , fpl.pl_party_legal_id             lc_grp_code
          from
                    fdr.fr_party_legal fpl
               join fdr.fr_party_type  fpt on fpl.pl_pt_party_type_id = fpt.pt_party_type_id
         where
               fpt.pt_party_type_name = 'Ledger Entity'
           and not exists (
                              select
                                     null
                                from
                                     fdr.fr_lpg_config flc
                               where
                                     flc.lc_lpg_id   = to_number ( fpl.pl_client_text3 )
                                 and flc.lc_grp_code = fpl.pl_party_legal_id
                          );

        v_no_records_inserted := sql%rowcount;

        stn.pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'Created fdr.fr_lpg_config records' , 'v_no_records_inserted' , null , v_no_records_inserted , null );

        if v_no_records_inserted > 0 then

            insert
              into
                   fdr.fr_entity_schema
                 (
                     es_fga_gaap
                 ,   es_ps_posting_schema
                 ,   es_pl_gl_entity
                 ,   es_ledger
                 )
            select
                   fgp.fga_gaap_id
                 , fps.ps_posting_schema
                 , fpl.pl_party_legal_id
                 , sld.sl_ledger_name
              from
                              fdr.fr_gaap           fgp
                   cross join fdr.fr_posting_schema fps
                   cross join fdr.fr_party_legal    fpl
                   cross join slr.slr_ledgers       sld
             where
                   fpl.pl_party_legal_id not in ( '1' , 'NVS' )
               and not exists (
                                  select
                                         null
                                    from
                                         fdr.fr_entity_schema fes
                                   where
                                         fes.es_fga_gaap          = fgp.fga_gaap_id
                                     and fes.es_ps_posting_schema = fps.ps_posting_schema
                                     and fes.es_pl_gl_entity      = fpl.pl_party_legal_id
                                     and fes.es_ledger            = sld.sl_ledger_name
                              );

            stn.pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'Created fdr.fr_entity_schema records' , 'sql%rowcount' , null , sql%rowcount , null );

            insert
              into
                   slr.slr_entities
                 (
                     ent_entity
                 ,   ent_entity_short_code
                 ,   ent_post_eff_date
                 ,   ent_post_val_date
                 ,   ent_post_fak_balances
                 ,   ent_description
                 ,   ent_status
                 ,   ent_business_date
                 ,   ent_base_ccy
                 ,   ent_local_ccy
                 ,   ent_accounts_set
                 ,   ent_currency_set
                 ,   ent_rate_set
                 ,   ent_periods_and_days_set
                 ,   ent_segment_1_set
                 ,   ent_segment_2_set
                 ,   ent_segment_3_set
                 ,   ent_segment_4_set
                 ,   ent_segment_5_set
                 ,   ent_segment_6_set
                 ,   ent_segment_7_set
                 ,   ent_segment_8_set
                 ,   ent_segment_9_set
                 ,   ent_segment_10_set
                 ,   ent_sl_ledger_name
                 ,   ent_apply_fx_translation
                 ,   ent_adjustment_flag
                 ,   ent_created_by
                 ,   ent_created_on
                 ,   ent_amended_by
                 ,   ent_amended_on
                 )
            select
                   fpl.pl_party_legal_id                         ent_entity
                 , substr ( fpl.pl_party_legal_id , 1 , 8 )      ent_entity_short_code
                 , 'N'                                           ent_post_eff_date
                 , 'N'                                           ent_post_val_date
                 , 'Y'                                           ent_post_fak_balances
                 , fpl.pl_full_legal_name                        ent_description
                 , fpl.pl_active                                 ent_status
                 , fgp.gp_todays_bus_date                        ent_business_date
                 , fpl.pl_cu_base_currency_id                    ent_base_ccy
                 , fpl.pl_cu_local_currency_id                   ent_local_ccy
                 , 'ENT_ACCOUNTS_SET'                            ent_accounts_set
                 , 'ENT_CURRENCY_SET'                            ent_currency_set
                 , 'ENT_RATE_SET'                                ent_rate_set
                 , 'ENT_CAL_SET'                                 ent_periods_and_days_set
                 , 'ENT_SEGMENT_1_SET'                           ent_segment_1_set
                 , 'ENT_SEGMENT_2_SET'                           ent_segment_2_set
                 , 'ENT_SEGMENT_3_SET'                           ent_segment_3_set
                 , 'ENT_SEGMENT_4_SET'                           ent_segment_4_set
                 , 'ENT_SEGMENT_5_SET'                           ent_segment_5_set
                 , 'ENT_SEGMENT_6_SET'                           ent_segment_6_set
                 , 'ENT_SEGMENT_7_SET'                           ent_segment_7_set
                 , 'ENT_SEGMENT_8_SET'                           ent_segment_8_set
                 , 'ENT_SEGMENT_9_SET'                           ent_segment_9_set
                 , 'ENT_SEGMENT_10_SET'                          ent_segment_10_set
                 , slg.sl_ledger_name                            ent_sl_ledger_name
                 , 'Y'                                           ent_apply_fx_translation
                 , 'Y'                                           ent_adjustment_flag
                 , user                                          ent_created_by
                 , sysdate                                       ent_created_on
                 , user                                          ent_amended_by
                 , sysdate                                       ent_amended_on
              from
                              fdr.fr_party_legal      fpl
                         join fdr.fr_lpg_config       flc on fpl.pl_party_legal_id = flc.lc_grp_code
                         join fdr.fr_global_parameter fgp on flc.lc_lpg_id         = fgp.lpg_id
                   cross join slr.slr_ledgers         slg
             where
                   not exists (
                                  select
                                         null
                                    from
                                         slr.slr_entities ent
                                   where
                                         ent.ent_entity = fpl.pl_party_legal_id
                              );

            stn.pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'Created slr.slr_entities records' , 'sql%rowcount' , null , sql%rowcount , null );

            insert
              into
                   slr.slr_fak_definitions
                 (
                     fd_entity
                 ,   fd_description
                 ,   fd_segment_1_name
                 ,   fd_segment_1_desc
                 ,   fd_segment_1_type
                 ,   fd_segment_1_gui_type
                 ,   fd_segment_2_name
                 ,   fd_segment_2_desc
                 ,   fd_segment_2_type
                 ,   fd_segment_2_gui_type
                 ,   fd_segment_3_name
                 ,   fd_segment_3_desc
                 ,   fd_segment_3_type
                 ,   fd_segment_3_gui_type
                 ,   fd_segment_4_name
                 ,   fd_segment_4_desc
                 ,   fd_segment_4_type
                 ,   fd_segment_4_gui_type
                 ,   fd_segment_5_name
                 ,   fd_segment_5_desc
                 ,   fd_segment_5_type
                 ,   fd_segment_5_gui_type
                 ,   fd_segment_6_name
                 ,   fd_segment_6_desc
                 ,   fd_segment_6_type
                 ,   fd_segment_6_gui_type
                 ,   fd_segment_7_name
                 ,   fd_segment_7_desc
                 ,   fd_segment_7_type
                 ,   fd_segment_7_gui_type
                 ,   fd_segment_8_name
                 ,   fd_segment_8_desc
                 ,   fd_segment_8_type
                 ,   fd_segment_8_gui_type
                 ,   fd_segment_9_name
                 ,   fd_segment_9_desc
                 ,   fd_segment_9_type
                 ,   fd_segment_9_gui_type
                 ,   fd_segment_10_name
                 ,   fd_segment_10_desc
                 ,   fd_segment_10_type
                 ,   fd_segment_10_gui_type
                 ,   fd_created_by
                 ,   fd_created_on
                 ,   fd_amended_by
                 ,   fd_amended_on
                 ,   fd_segment_1_balance_check
                 ,   fd_segment_2_balance_check
                 ,   fd_segment_3_balance_check
                 ,   fd_segment_4_balance_check
                 ,   fd_segment_5_balance_check
                 ,   fd_segment_6_balance_check
                 ,   fd_segment_7_balance_check
                 ,   fd_segment_8_balance_check
                 ,   fd_segment_9_balance_check
                 ,   fd_segment_10_balance_check
                 )
            select
                   ent.ent_entity                            fd_entity
                 , ent.ent_description                       fd_description
                 , seg_attr_descr.fd_segment_1_name          fd_segment_1_name
                 , seg_attr_descr.fd_segment_1_name          fd_segment_1_desc
                 , seg_attr_descr.fd_segment_1_type          fd_segment_1_type
                 , seg_attr_descr.fd_segment_1_gui_type      fd_segment_1_gui_type
                 , seg_attr_descr.fd_segment_2_name          fd_segment_2_name
                 , seg_attr_descr.fd_segment_2_name          fd_segment_2_desc
                 , seg_attr_descr.fd_segment_2_type          fd_segment_2_type
                 , seg_attr_descr.fd_segment_2_gui_type      fd_segment_2_gui_type
                 , seg_attr_descr.fd_segment_3_name          fd_segment_3_name
                 , seg_attr_descr.fd_segment_3_name          fd_segment_3_desc
                 , seg_attr_descr.fd_segment_3_type          fd_segment_3_type
                 , seg_attr_descr.fd_segment_3_gui_type      fd_segment_3_gui_type
                 , seg_attr_descr.fd_segment_4_name          fd_segment_4_name
                 , seg_attr_descr.fd_segment_4_name          fd_segment_4_desc
                 , seg_attr_descr.fd_segment_4_type          fd_segment_4_type
                 , seg_attr_descr.fd_segment_4_gui_type      fd_segment_4_gui_type
                 , seg_attr_descr.fd_segment_5_name          fd_segment_5_name
                 , seg_attr_descr.fd_segment_5_name          fd_segment_5_desc
                 , seg_attr_descr.fd_segment_5_type          fd_segment_5_type
                 , seg_attr_descr.fd_segment_5_gui_type      fd_segment_5_gui_type
                 , seg_attr_descr.fd_segment_6_name          fd_segment_6_name
                 , seg_attr_descr.fd_segment_6_name          fd_segment_6_desc
                 , seg_attr_descr.fd_segment_6_type          fd_segment_6_type
                 , seg_attr_descr.fd_segment_6_gui_type      fd_segment_6_gui_type
                 , seg_attr_descr.fd_segment_7_name          fd_segment_7_name
                 , seg_attr_descr.fd_segment_7_name          fd_segment_7_desc
                 , seg_attr_descr.fd_segment_7_type          fd_segment_7_type
                 , seg_attr_descr.fd_segment_7_gui_type      fd_segment_7_gui_type
                 , seg_attr_descr.fd_segment_8_name          fd_segment_8_name
                 , seg_attr_descr.fd_segment_8_name          fd_segment_8_desc
                 , seg_attr_descr.fd_segment_8_type          fd_segment_8_type
                 , seg_attr_descr.fd_segment_8_gui_type      fd_segment_8_gui_type
                 , seg_attr_descr.fd_segment_9_name          fd_segment_9_name
                 , seg_attr_descr.fd_segment_9_name          fd_segment_9_desc
                 , seg_attr_descr.fd_segment_9_type          fd_segment_9_type
                 , seg_attr_descr.fd_segment_9_gui_type      fd_segment_9_gui_type
                 , seg_attr_descr.fd_segment_10_name         fd_segment_10_name
                 , seg_attr_descr.fd_segment_10_name         fd_segment_10_desc
                 , seg_attr_descr.fd_segment_10_type         fd_segment_10_type
                 , seg_attr_descr.fd_segment_10_gui_type     fd_segment_10_gui_type
                 , user                                      fd_created_by
                 , sysdate                                   fd_created_on
                 , user                                      fd_amended_by
                 , sysdate                                   fd_amended_on
                 , 'N'                                       fd_segment_1_balance_check
                 , 'N'                                       fd_segment_2_balance_check
                 , 'N'                                       fd_segment_3_balance_check
                 , 'N'                                       fd_segment_4_balance_check
                 , 'N'                                       fd_segment_5_balance_check
                 , 'N'                                       fd_segment_6_balance_check
                 , 'N'                                       fd_segment_7_balance_check
                 , 'N'                                       fd_segment_8_balance_check
                 , 'N'                                       fd_segment_9_balance_check
                 , 'N'                                       fd_segment_10_balance_check
              from
                        slr.slr_entities ent
                   cross join (
                                  select
                                         max ( case when tujlm.column_name = 'SEGMENT_1'
                                                    then tujlm.column_screen_label
                                               end )                                        fd_segment_1_name
                                       , max ( case when tujlm.column_name = 'SEGMENT_1'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        fd_segment_1_type
                                       , max ( case when tujlm.column_name = 'SEGMENT_1'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        fd_segment_1_gui_type
                                       , max ( case when tujlm.column_name = 'SEGMENT_2'
                                                     then tujlm.column_screen_label
                                                end )                                       fd_segment_2_name
                                       , max ( case when tujlm.column_name = 'SEGMENT_2'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        fd_segment_2_type
                                       , max ( case when tujlm.column_name = 'SEGMENT_2'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        fd_segment_2_gui_type
                                       , max ( case when tujlm.column_name = 'SEGMENT_3'
                                                     then tujlm.column_screen_label
                                                end )                                       fd_segment_3_name
                                       , max ( case when tujlm.column_name = 'SEGMENT_3'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        fd_segment_3_type
                                       , max ( case when tujlm.column_name = 'SEGMENT_3'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        fd_segment_3_gui_type
                                       , max ( case when tujlm.column_name = 'SEGMENT_4'
                                                     then tujlm.column_screen_label
                                                end )                                       fd_segment_4_name
                                       , max ( case when tujlm.column_name = 'SEGMENT_4'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        fd_segment_4_type
                                       , max ( case when tujlm.column_name = 'SEGMENT_4'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        fd_segment_4_gui_type
                                       , max ( case when tujlm.column_name = 'SEGMENT_5'
                                                     then tujlm.column_screen_label
                                                end )                                       fd_segment_5_name
                                       , max ( case when tujlm.column_name = 'SEGMENT_5'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        fd_segment_5_type
                                       , max ( case when tujlm.column_name = 'SEGMENT_5'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        fd_segment_5_gui_type
                                       , max ( case when tujlm.column_name = 'SEGMENT_6'
                                                     then tujlm.column_screen_label
                                                end )                                       fd_segment_6_name
                                       , max ( case when tujlm.column_name = 'SEGMENT_6'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        fd_segment_6_type
                                       , max ( case when tujlm.column_name = 'SEGMENT_6'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        fd_segment_6_gui_type
                                       , max ( case when tujlm.column_name = 'SEGMENT_7'
                                                     then tujlm.column_screen_label
                                                end )                                       fd_segment_7_name
                                       , max ( case when tujlm.column_name = 'SEGMENT_7'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        fd_segment_7_type
                                       , max ( case when tujlm.column_name = 'SEGMENT_7'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        fd_segment_7_gui_type
                                       , max ( case when tujlm.column_name = 'SEGMENT_8'
                                                     then tujlm.column_screen_label
                                                end )                                       fd_segment_8_name
                                       , max ( case when tujlm.column_name = 'SEGMENT_8'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        fd_segment_8_type
                                       , max ( case when tujlm.column_name = 'SEGMENT_8'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        fd_segment_8_gui_type
                                       , max ( case when tujlm.column_name = 'SEGMENT_9'
                                                     then tujlm.column_screen_label
                                               end )                                        fd_segment_9_name
                                       , max ( case when tujlm.column_name = 'SEGMENT_9'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        fd_segment_9_type
                                       , max ( case when tujlm.column_name = 'SEGMENT_9'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        fd_segment_9_gui_type
                                       , max ( case when tujlm.column_name = 'SEGMENT_10'
                                                     then tujlm.column_screen_label
                                               end )                                        fd_segment_10_name
                                       , max ( case when tujlm.column_name = 'SEGMENT_10'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        fd_segment_10_type
                                       , max ( case when tujlm.column_name = 'SEGMENT_10'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        fd_segment_10_gui_type
                                    from
                                         gui.t_ui_jrnl_line_meta tujlm
                              )
                              seg_attr_descr
             where
                   not exists (
                                  select
                                         null
                                    from
                                         slr.slr_fak_definitions sfd
                                   where
                                         sfd.fd_entity = ent.ent_entity
                              );

            stn.pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'Created slr.slr_fak_definitions records' , 'sql%rowcount' , null , sql%rowcount , null );

            insert
              into
                   slr.slr_eba_definitions
                 (
                     ed_entity
                 ,   ed_description
                 ,   ed_attribute_1_name
                 ,   ed_attribute_1_desc
                 ,   ed_attribute_1_type
                 ,   ed_attribute_1_gui_type
                 ,   ed_attribute_2_name
                 ,   ed_attribute_2_desc
                 ,   ed_attribute_2_type
                 ,   ed_attribute_2_gui_type
                 ,   ed_attribute_3_name
                 ,   ed_attribute_3_desc
                 ,   ed_attribute_3_type
                 ,   ed_attribute_3_gui_type
                 ,   ed_attribute_4_name
                 ,   ed_attribute_4_desc
                 ,   ed_attribute_4_type
                 ,   ed_attribute_4_gui_type
                 ,   ed_attribute_5_name
                 ,   ed_attribute_5_desc
                 ,   ed_attribute_5_type
                 ,   ed_attribute_5_gui_type
                 ,   ed_created_by
                 ,   ed_created_on
                 ,   ed_amended_by
                 ,   ed_amended_on
                 )
            select
                   ent.ent_entity                            ed_entity
                 , ent.ent_description                       ed_description
                 , seg_attr_descr.ed_attribute_1_name        ed_attribute_1_name
                 , seg_attr_descr.ed_attribute_1_name        ed_attribute_1_desc
                 , seg_attr_descr.ed_attribute_1_type        ed_attribute_1_type
                 , seg_attr_descr.ed_attribute_1_gui_type    ed_attribute_1_gui_type
                 , seg_attr_descr.ed_attribute_2_name        ed_attribute_2_name
                 , seg_attr_descr.ed_attribute_2_name        ed_attribute_2_desc
                 , seg_attr_descr.ed_attribute_2_type        ed_attribute_2_type
                 , seg_attr_descr.ed_attribute_2_gui_type    ed_attribute_2_gui_type
                 , seg_attr_descr.ed_attribute_3_name        ed_attribute_3_name
                 , seg_attr_descr.ed_attribute_3_name        ed_attribute_3_desc
                 , seg_attr_descr.ed_attribute_3_type        ed_attribute_3_type
                 , seg_attr_descr.ed_attribute_3_gui_type    ed_attribute_3_gui_type
                 , seg_attr_descr.ed_attribute_4_name        ed_attribute_4_name
                 , seg_attr_descr.ed_attribute_4_name        ed_attribute_4_desc
                 , seg_attr_descr.ed_attribute_4_type        ed_attribute_4_type
                 , seg_attr_descr.ed_attribute_4_gui_type    ed_attribute_4_gui_type
                 , seg_attr_descr.ed_attribute_5_name        ed_attribute_5_name
                 , seg_attr_descr.ed_attribute_5_name        ed_attribute_5_desc
                 , seg_attr_descr.ed_attribute_5_type        ed_attribute_5_type
                 , seg_attr_descr.ed_attribute_5_gui_type    ed_attribute_5_gui_type
                 , user                                      ed_created_by
                 , sysdate                                   ed_created_on
                 , user                                      ed_amended_by
                 , sysdate                                   ed_amended_on
              from
                        slr.slr_entities ent
                   cross join (
                                  select
                                         max ( case when tujlm.column_name = 'ATTRIBUTE_1'
                                                    then tujlm.column_screen_label
                                               end )                                        ed_attribute_1_name
                                       , max ( case when tujlm.column_name = 'ATTRIBUTE_1'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        ed_attribute_1_type
                                       , max ( case when tujlm.column_name = 'ATTRIBUTE_1'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        ed_attribute_1_gui_type
                                       , max ( case when tujlm.column_name = 'ATTRIBUTE_2'
                                                     then tujlm.column_screen_label
                                                end )                                       ed_attribute_2_name
                                       , max ( case when tujlm.column_name = 'ATTRIBUTE_2'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        ed_attribute_2_type
                                       , max ( case when tujlm.column_name = 'ATTRIBUTE_2'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        ed_attribute_2_gui_type
                                       , max ( case when tujlm.column_name = 'ATTRIBUTE_3'
                                                     then tujlm.column_screen_label
                                                end )                                       ed_attribute_3_name
                                       , max ( case when tujlm.column_name = 'ATTRIBUTE_3'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        ed_attribute_3_type
                                       , max ( case when tujlm.column_name = 'ATTRIBUTE_3'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        ed_attribute_3_gui_type
                                       , max ( case when tujlm.column_name = 'ATTRIBUTE_4'
                                                     then tujlm.column_screen_label
                                                end )                                       ed_attribute_4_name
                                       , max ( case when tujlm.column_name = 'ATTRIBUTE_4'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        ed_attribute_4_type
                                       , max ( case when tujlm.column_name = 'ATTRIBUTE_4'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        ed_attribute_4_gui_type
                                       , max ( case when tujlm.column_name = 'ATTRIBUTE_5'
                                                     then tujlm.column_screen_label
                                                end )                                       ed_attribute_5_name
                                       , max ( case when tujlm.column_name = 'ATTRIBUTE_5'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        ed_attribute_5_type
                                       , max ( case when tujlm.column_name = 'ATTRIBUTE_5'
                                                     and tujlm.column_nullable = 'N'
                                                    then 'O'
                                                    else 'M'
                                               end )                                        ed_attribute_5_gui_type
                                    from
                                         gui.t_ui_jrnl_line_meta tujlm
                              )
                              seg_attr_descr
             where
                   not exists (
                                  select
                                         null
                                    from
                                         slr.slr_eba_definitions sed
                                   where
                                         sed.ed_entity = ent.ent_entity
                              );

            stn.pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'Created slr.slr_eba_definitions records' , 'sql%rowcount' , null , sql%rowcount , null );

            insert
              into
                   slr.slr_entity_grace_days
                 (
                     egd_entity
                 ,   egd_days
                 ,   egd_date
                 ,   egd_status
                 ,   egd_created_by
                 ,   egd_created_on
                 ,   egd_amended_by
                 ,   egd_amended_on
                 )
            select
                   ent.ent_entity                    egd_entity
                 , to_number ( fpl.pl_client_text2 ) egd_days
                 , fgp.gp_todays_bus_date            egd_date
                 , 'A'                               egd_status
                 , user                              egd_created_by
                 , sysdate                           egd_created_on
                 , user                              egd_amended_by
                 , sysdate                           egd_amended_on
              from
                        slr.slr_entities        ent
                   join fdr.fr_lpg_config       flc on ent.ent_entity = flc.lc_grp_code
                   join fdr.fr_global_parameter fgp on flc.lc_lpg_id  = fgp.lpg_id
                   join fdr.fr_party_legal      fpl on ent.ent_entity = fpl.pl_party_legal_id
             where
                   not exists (
                                  select
                                         null
                                    from
                                         slr.slr_entity_grace_days egd
                                   where
                                         ent.ent_entity = egd.egd_entity
                              );

            stn.pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'Created slr.slr_entity_grace_days records' , 'sql%rowcount' , null , sql%rowcount , null );

            insert
              into
                   slr.slr_entity_proc_group
                 (
                     epg_id
                 ,   epg_entity
                 )
            select
                   'AG'             epg_id
                 , ent.ent_entity   epg_entity
              from
                   slr.slr_entities ent
             where
                   not exists (
                                  select
                                         null
                                    from
                                         slr.slr_entity_proc_group epg
                                   where
                                         epg.epg_entity = ent.ent_entity
                              );

            stn.pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'Created slr.slr_entity_proc_group records' , 'sql%rowcount' , null , sql%rowcount , null );

        end if;
    end pr_seed_data;

end pk_legal_entity;
/
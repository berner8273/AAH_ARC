create or replace package body     pk_posting_rules
as

procedure pr_posting_rules_clear
as
begin
    pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Started clearing loader tables', NULL, NULL, NULL, NULL);
    for i in (
                 select
                        'delete from ' || lower ( owner ) || '.' || lower ( table_name ) delete_stmt
                   from
                        all_tables
                  where
                        lower ( owner )      = 'stn'
                    and lower ( table_name ) in ( 'load_event_hierarchy' 
                                                , 'load_business_event'
                                                , 'load_gaap_to_core'
                                                , 'load_posting_method_derivation'
                                                , 'load_vie_posting_method'
                                                , 'load_fr_posting_driver'
                                                , 'load_fr_account_lookup' )
             )
    loop
        execute immediate i.delete_stmt;
    end loop;
    commit;
    pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Completed clearing loader tables', NULL, NULL, NULL, NULL);
end;

procedure pr_posting_rules_check
as
begin
    pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Validating loader records', NULL, NULL, NULL, NULL);
end;

procedure pr_posting_rules_compare ( p_no_load_eh    out number
                                   , p_no_load_be    out number
                                   , p_no_load_gc    out number
                                   , p_no_load_pm    out number
                                   , p_no_load_vp    out number
                                   , p_no_load_pd    out number
                                   , p_no_load_al    out number
                                   , p_no_load_total out number
                                   , p_no_diff_eh    out number
                                   , p_no_diff_be    out number
                                   , p_no_diff_gc    out number
                                   , p_no_diff_pm    out number
                                   , p_no_diff_vp    out number
                                   , p_no_diff_pd    out number
                                   , p_no_diff_al    out number
                                   , p_no_diff_total out number )
as
begin
    p_no_diff_eh    := 0;
    p_no_diff_be    := 0;
    p_no_diff_gc    := 0;
    p_no_diff_pm    := 0;
    p_no_diff_vp    := 0;
    p_no_diff_pd    := 0;
    p_no_diff_al    := 0;
    p_no_diff_total := 0;
-- Get loader table counts
    select count(*) into p_no_load_eh from stn.load_event_hierarchy;
    select count(*) into p_no_load_be from stn.load_business_event;
    select count(*) into p_no_load_gc from stn.load_gaap_to_core;
    select count(*) into p_no_load_pm from stn.load_posting_method_derivation;
    select count(*) into p_no_load_vp from stn.load_vie_posting_method;
    select count(*) into p_no_load_pd from stn.load_fr_posting_driver;
    select count(*) into p_no_load_al from stn.load_fr_account_lookup;
    p_no_load_total :=  p_no_load_eh
                     +  p_no_load_be
                     +  p_no_load_gc
                     +  p_no_load_pm
                     +  p_no_load_vp
                     +  p_no_load_pd
                     +  p_no_load_al;
    pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Loader record count event hierarchy'    , 'p_no_load_eh'    , NULL , p_no_load_eh    , NULL);
    pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Loader record count business event'     , 'p_no_load_be'    , NULL , p_no_load_be    , NULL);
    pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Loader record count GAAP to core'       , 'p_no_load_gc'    , NULL , p_no_load_gc    , NULL);
    pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Loader record count posting method'     , 'p_no_load_pm'    , NULL , p_no_load_pm    , NULL);
    pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Loader record count VIE posting method' , 'p_no_load_vp'    , NULL , p_no_load_vp    , NULL);
    pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Loader record count posting driver'     , 'p_no_load_pd'    , NULL , p_no_load_pd    , NULL);
    pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Loader record count account lookup'     , 'p_no_load_al'    , NULL , p_no_load_al    , NULL);
    pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Loader record count total'              , 'p_no_load_total' , NULL , p_no_load_total , NULL);
if p_no_load_total > 0 then
    -- Calculate differences in event hierarchy
    if p_no_load_eh > 0 then
        select
               count_sum
                    into
                        p_no_diff_eh
          from ( with
                    new_minus_old as (
                        select
                               eh_load.event_class
                             , eh_load.event_class_descr
                             , eh_load.event_class_period_freq
                             , eh_load.event_grp
                             , eh_load.event_grp_descr
                             , eh_load.event_subgrp
                             , eh_load.event_subgrp_descr
                             , eh_load.event_typ
                             , eh_load.event_typ_descr
                             , eh_load.event_typ_seq_id
                             , eh_load.is_cash_event
                             , eh_load.is_core_earning_event
                             , eh_load.event_category
                             , eh_load.event_category_descr
                          from
                               stn.load_event_hierarchy eh_load
                        minus
                        select
                               eh_source.event_class
                             , eh_source.event_class_descr
                             , eh_source.event_class_period_freq
                             , eh_source.event_grp
                             , eh_source.event_grp_descr
                             , eh_source.event_subgrp
                             , eh_source.event_subgrp_descr
                             , eh_source.event_typ
                             , eh_source.event_typ_descr
                             , eh_source.event_typ_seq_id
                             , eh_source.is_cash_event
                             , eh_source.is_core_earning_event
                             , eh_source.event_category
                             , eh_source.event_category_descr
                          from
                               rdr.rrv_ag_loader_event_hier eh_source )
                  , old_minus_new as (
                        select
                               eh_source.event_class
                             , eh_source.event_class_descr
                             , eh_source.event_class_period_freq
                             , eh_source.event_grp
                             , eh_source.event_grp_descr
                             , eh_source.event_subgrp
                             , eh_source.event_subgrp_descr
                             , eh_source.event_typ
                             , eh_source.event_typ_descr
                             , eh_source.event_typ_seq_id
                             , eh_source.is_cash_event
                             , eh_source.is_core_earning_event
                             , eh_source.event_category
                             , eh_source.event_category_descr
                          from
                               rdr.rrv_ag_loader_event_hier eh_source
                        minus
                        select
                               eh_load.event_class
                             , eh_load.event_class_descr
                             , eh_load.event_class_period_freq
                             , eh_load.event_grp
                             , eh_load.event_grp_descr
                             , eh_load.event_subgrp
                             , eh_load.event_subgrp_descr
                             , eh_load.event_typ
                             , eh_load.event_typ_descr
                             , eh_load.event_typ_seq_id
                             , eh_load.is_cash_event
                             , eh_load.is_core_earning_event
                             , eh_load.event_category
                             , eh_load.event_category_descr
                          from
                               stn.load_event_hierarchy eh_load )
                    select
                           sum( counts.count1 ) count_sum
                      from
                           ( select
                                    count(*) count1
                               from
                                    new_minus_old
                             union all
                             select
                                    count(*) count1
                               from
                                    old_minus_new ) counts );
        pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Count of differences event hierarchy' , 'p_no_diff_eh' , NULL , p_no_diff_eh , NULL );
    end if;
    -- Calculate differences in business event
    if p_no_load_be > 0 then
        select
               count_sum
                    into
                        p_no_diff_be
          from ( with
                    new_minus_old as (
                        select
                               be_load.business_event_seq_id
                             , be_load.business_event_cd
                             , be_load.business_event_descr
                             , be_load.business_event_category_descr
                          from
                               stn.load_business_event be_load
                        minus
                        select
                               be_source.business_event_seq_id
                             , be_source.business_event_cd
                             , be_source.business_event_descr
                             , be_source.business_event_category_descr
                          from
                               rdr.rrv_ag_loader_business_event be_source )
                  , old_minus_new as (
                        select
                               be_source.business_event_seq_id
                             , be_source.business_event_cd
                             , be_source.business_event_descr
                             , be_source.business_event_category_descr
                          from
                               rdr.rrv_ag_loader_business_event be_source
                        minus
                        select
                               be_load.business_event_seq_id
                             , be_load.business_event_cd
                             , be_load.business_event_descr
                             , be_load.business_event_category_descr
                          from
                               stn.load_business_event be_load )
                    select
                           sum( counts.count1 ) count_sum
                      from
                           ( select
                                    count(*) count1
                               from
                                    new_minus_old
                             union all
                             select
                                    count(*) count1
                               from
                                    old_minus_new ) counts );
        pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Count of differences business event' , 'p_no_diff_be' , NULL , p_no_diff_be , NULL );
    end if;
    -- Calculate differences in GAAP to core
    if p_no_load_gc > 0 then
        select
               count_sum
                    into
                        p_no_diff_gc
          from ( with
                    new_minus_old as (
                        select
                               gc_load.le_cd
                          from
                               stn.load_gaap_to_core gc_load
                        minus
                        select
                               gc_source.le_cd
                          from
                               rdr.rrv_ag_loader_gaap_to_core gc_source )
                  , old_minus_new as (
                        select
                               gc_source.le_cd
                          from
                               rdr.rrv_ag_loader_gaap_to_core gc_source
                        minus
                        select
                               gc_load.le_cd
                          from
                               stn.load_gaap_to_core gc_load )
                    select
                           sum( counts.count1 ) count_sum
                      from
                           ( select
                                    count(*) count1
                               from
                                    new_minus_old
                             union all
                             select
                                    count(*) count1
                               from
                                    old_minus_new ) counts );
        pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Count of differences GAAP to core' , 'p_no_diff_gc' , NULL , p_no_diff_gc , NULL );
    end if;
    -- Calculate differences in posting method
    if p_no_load_pm > 0 then
        select
               count_sum
                    into
                        p_no_diff_pm
          from ( with
                    new_minus_old as (
                        select
                               pm_load.event_typ
                             , pm_load.is_mark_to_market
                             , pm_load.premium_typ
                             , pm_load.basis_cd
                             , pm_load.psm_cd
                          from
                               stn.load_posting_method_derivation pm_load
                        minus
                        select
                               pm_source.event_typ
                             , pm_source.is_mark_to_market
                             , pm_source.premium_typ
                             , pm_source.basis_cd
                             , pm_source.psm_cd
                          from
                               rdr.rrv_ag_loader_posting_method pm_source )
                  , old_minus_new as (
                        select
                               pm_source.event_typ
                             , pm_source.is_mark_to_market
                             , pm_source.premium_typ
                             , pm_source.basis_cd
                             , pm_source.psm_cd
                          from
                               rdr.rrv_ag_loader_posting_method pm_source
                        minus
                        select
                               pm_load.event_typ
                             , pm_load.is_mark_to_market
                             , pm_load.premium_typ
                             , pm_load.basis_cd
                             , pm_load.psm_cd
                          from
                               stn.load_posting_method_derivation pm_load )
                    select
                           sum( counts.count1 ) count_sum
                      from
                           ( select
                                    count(*) count1
                               from
                                    new_minus_old
                             union all
                             select
                                    count(*) count1
                               from
                                    old_minus_new ) counts );
        pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Count of differences posting method' , 'p_no_diff_pm' , NULL , p_no_diff_pm , NULL );
    end if;
    -- Calculate differences in VIE posting method
    if p_no_load_vp > 0 then
        select
               count_sum
                    into
                        p_no_diff_vp
          from ( with
                    new_minus_old as (
                        select
                               vp_load.event_typ
                             , vp_load.vie_event_typ
                             , vp_load.vie_typ
                          from
                               stn.load_vie_posting_method vp_load
                        minus
                        select
                               vp_source.event_typ
                             , vp_source.vie_event_typ
                             , vp_source.vie_typ
                          from
                               rdr.rrv_ag_loader_vie_posting vp_source )
                  , old_minus_new as (
                        select
                               vp_source.event_typ
                             , vp_source.vie_event_typ
                             , vp_source.vie_typ
                          from
                               rdr.rrv_ag_loader_vie_posting vp_source
                        minus
                        select
                               vp_load.event_typ
                             , vp_load.vie_event_typ
                             , vp_load.vie_typ
                          from
                               stn.load_vie_posting_method vp_load )
                    select
                           sum( counts.count1 ) count_sum
                      from
                           ( select
                                    count(*) count1
                               from
                                    new_minus_old
                             union all
                             select
                                    count(*) count1
                               from
                                    old_minus_new ) counts );
        pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Count of differences VIE posting method' , 'p_no_diff_vp' , NULL , p_no_diff_vp , NULL );
    end if;
    -- Calculate differences in posting driver
    if p_no_load_pd > 0 then
        select
               count_sum
                    into
                        p_no_diff_pd
          from ( with
                    new_minus_old as (
                        select
                               fpd_load.pd_posting_driver_id
                             , fpd_load.pd_posting_schema
                             , fpd_load.pd_aet_event_type
                             , fpd_load.pd_sub_event
                             , fpd_load.pd_amount_type
                             , fpd_load.pd_posting_code
                             , fpd_load.pd_dr_or_cr
                             , fpd_load.pd_transaction_no
                             , fpd_load.pd_negate_flag1
                             , fpd_load.pd_journal_type
                             , fpd_load.pd_valid_from
                             , fpd_load.pd_valid_to
                          from
                               stn.load_fr_posting_driver fpd_load
                        minus
                        select
                               fpd_source.pd_posting_driver_id
                             , fpd_source.pd_posting_schema
                             , fpd_source.pd_aet_event_type
                             , fpd_source.pd_sub_event
                             , fpd_source.pd_amount_type
                             , fpd_source.pd_posting_code
                             , fpd_source.pd_dr_or_cr
                             , fpd_source.pd_transaction_no
                             , fpd_source.pd_negate_flag1
                             , fpd_source.pd_journal_type
                             , fpd_source.pd_valid_from
                             , fpd_source.pd_valid_to
                          from
                               rdr.rrv_ag_loader_posting_driver fpd_source )
                  , old_minus_new as (
                        select
                               fpd_source.pd_posting_driver_id
                             , fpd_source.pd_posting_schema
                             , fpd_source.pd_aet_event_type
                             , fpd_source.pd_sub_event
                             , fpd_source.pd_amount_type
                             , fpd_source.pd_posting_code
                             , fpd_source.pd_dr_or_cr
                             , fpd_source.pd_transaction_no
                             , fpd_source.pd_negate_flag1
                             , fpd_source.pd_journal_type
                             , fpd_source.pd_valid_from
                             , fpd_source.pd_valid_to
                          from
                               rdr.rrv_ag_loader_posting_driver fpd_source
                        minus
                        select
                               fpd_load.pd_posting_driver_id
                             , fpd_load.pd_posting_schema
                             , fpd_load.pd_aet_event_type
                             , fpd_load.pd_sub_event
                             , fpd_load.pd_amount_type
                             , fpd_load.pd_posting_code
                             , fpd_load.pd_dr_or_cr
                             , fpd_load.pd_transaction_no
                             , fpd_load.pd_negate_flag1
                             , fpd_load.pd_journal_type
                             , fpd_load.pd_valid_from
                             , fpd_load.pd_valid_to
                          from
                               stn.load_fr_posting_driver fpd_load )
                    select
                           sum( counts.count1 ) count_sum
                      from
                           ( select
                                    count(*) count1
                               from
                                    new_minus_old
                             union all
                             select
                                    count(*) count1
                               from
                                    old_minus_new ) counts );
        pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Count of differences posting driver' , 'p_no_diff_pd' , NULL , p_no_diff_pd , NULL );
    end if;
    -- Calculate differences in account lookup
    if p_no_load_al > 0 then
        select
               count_sum
                    into
                        p_no_diff_al
          from ( with
                    new_minus_old as (
                        select
                               fal_load.al_posting_code
                             , fal_load.al_lookup_1
                             , fal_load.al_lookup_2
                             , fal_load.al_lookup_3
                             , fal_load.al_lookup_4
                             , fal_load.al_account
                             , fal_load.al_valid_from
                             , fal_load.al_valid_to
                          from
                               stn.load_fr_account_lookup fal_load
                        minus
                        select
                               fal_source.al_posting_code
                             , fal_source.al_lookup_1
                             , fal_source.al_lookup_2
                             , fal_source.al_lookup_3
                             , fal_source.al_lookup_4
                             , fal_source.al_account
                             , fal_source.al_valid_from
                             , fal_source.al_valid_to
                          from
                               rdr.rrv_ag_loader_account_lookup fal_source )
                  , old_minus_new as (
                        select
                               fal_source.al_posting_code
                             , fal_source.al_lookup_1
                             , fal_source.al_lookup_2
                             , fal_source.al_lookup_3
                             , fal_source.al_lookup_4
                             , fal_source.al_account
                             , fal_source.al_valid_from
                             , fal_source.al_valid_to
                          from
                               rdr.rrv_ag_loader_account_lookup fal_source
                        minus
                        select
                               fal_load.al_posting_code
                             , fal_load.al_lookup_1
                             , fal_load.al_lookup_2
                             , fal_load.al_lookup_3
                             , fal_load.al_lookup_4
                             , fal_load.al_account
                             , fal_load.al_valid_from
                             , fal_load.al_valid_to
                          from
                               stn.load_fr_account_lookup fal_load )
                    select
                           sum( counts.count1 ) count_sum
                      from
                           ( select
                                    count(*) count1
                               from
                                    new_minus_old
                             union all
                             select
                                    count(*) count1
                               from
                                    old_minus_new ) counts );
        pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Count of differences posting driver' , 'p_no_diff_al' , NULL , p_no_diff_al , NULL );
    end if;
    p_no_diff_total := p_no_diff_eh
                     + p_no_diff_be
                     + p_no_diff_gc
                     + p_no_diff_pm
                     + p_no_diff_vp
                     + p_no_diff_pd
                     + p_no_diff_al;
    pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Total count of differences' , 'p_no_diff_total' , NULL , p_no_diff_total , NULL );
else
    pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Zero loader records found' , NULL , NULL , NULL , NULL );
end if;

end pr_posting_rules_compare;

procedure pr_posting_rules_eh ( p_no_update_eh out number)
as
    v_no_merge_eh        number(38, 9) default 0;
    v_no_merge_eh_cls    number(38, 9) default 0;
    v_no_merge_eh_grp    number(38, 9) default 0;
    v_no_merge_eh_sgr    number(38, 9) default 0;
    v_no_merge_eh_cat    number(38, 9) default 0;
    v_no_merge_eh_et1    number(38, 9) default 0;
    v_no_merge_eh_et2    number(38, 9) default 0;
begin
    /* Event hierarchy */
    merge into
           fdr.fr_general_lookup fgl
    using (
     select
             eh_load.event_class
           , eh_load.event_grp
           , eh_load.event_subgrp
           , eh_load.event_typ
           , eh_load.event_typ_seq_id
           , eh_load.is_cash_event
           , eh_load.is_core_earning_event
           , eh_load.event_category
           , 'EVENT_HIERARCHY'              lk_lkt_lookup_type_code
           , TO_DATE('2000/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS')                        lk_effective_from
           , TO_DATE('2099/12/31 00:00:00','YYYY/MM/DD HH24:MI:SS')  lk_effective_to
           , 'A'                            lk_active
        from
             stn.load_event_hierarchy  eh_load ) eh_new
      on ( fgl.lk_match_key1           = eh_new.event_typ
       and fgl.lk_lkt_lookup_type_code = eh_new.lk_lkt_lookup_type_code )
      when matched then
        update
           set
               fgl.lk_lookup_value3    = eh_new.event_class
             , fgl.lk_lookup_value2    = eh_new.event_grp
             , fgl.lk_lookup_value1    = eh_new.event_subgrp
             , fgl.lk_lookup_value10   = eh_new.event_typ_seq_id
             , fgl.lk_lookup_value5    = eh_new.is_cash_event
             , fgl.lk_lookup_value6    = eh_new.is_core_earning_event
             , fgl.lk_lookup_value4    = eh_new.event_category
      when not matched then
        insert
            ( fgl.lk_lookup_value3
            , fgl.lk_lookup_value2
            , fgl.lk_lookup_value1
            , fgl.lk_match_key1
            , fgl.lk_lookup_value10
            , fgl.lk_lookup_value5
            , fgl.lk_lookup_value6
            , fgl.lk_lookup_value4
            , fgl.lk_lkt_lookup_type_code
            , fgl.lk_effective_from
            , fgl.lk_effective_to
            , fgl.lk_active )
        values
            ( eh_new.event_class
            , eh_new.event_grp
            , eh_new.event_subgrp
            , eh_new.event_typ
            , eh_new.event_typ_seq_id
            , eh_new.is_cash_event
            , eh_new.is_core_earning_event
            , eh_new.event_category
            , eh_new.lk_lkt_lookup_type_code
            , eh_new.lk_effective_from
            , eh_new.lk_effective_to
            , eh_new.lk_active )
    ;
    v_no_merge_eh := SQL%ROWCOUNT;

    /* Event class */
    merge into
           fdr.fr_general_lookup fgl
    using (
     select
             eh_load.event_class
           , min( eh_load.event_class_descr )       event_class_descr
           , min( eh_load.event_class_period_freq ) event_class_period_freq
           , 'EVENT_CLASS'                          lk_lkt_lookup_type_code
           , TO_DATE('2000/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS')                          lk_effective_from
           , TO_DATE('2099/12/31 00:00:00','YYYY/MM/DD HH24:MI:SS')                          lk_effective_to
           , 'A'                                    lk_active
        from
             stn.load_event_hierarchy  eh_load
       group by
             eh_load.event_class ) eh_new
      on ( fgl.lk_match_key1           = eh_new.event_class
       and fgl.lk_lkt_lookup_type_code = eh_new.lk_lkt_lookup_type_code )
      when matched then
        update
           set
               fgl.lk_lookup_value1    = eh_new.event_class_descr
             , fgl.lk_lookup_value2    = eh_new.event_class_period_freq
      when not matched then
        insert
            ( fgl.lk_match_key1
            , fgl.lk_lookup_value1
            , fgl.lk_lookup_value2
            , fgl.lk_lkt_lookup_type_code
            , fgl.lk_effective_from
            , fgl.lk_effective_to
            , fgl.lk_active )
        values
            ( eh_new.event_class
            , eh_new.event_class_descr
            , eh_new.event_class_period_freq
            , eh_new.lk_lkt_lookup_type_code
            , eh_new.lk_effective_from
            , eh_new.lk_effective_to
            , eh_new.lk_active )
    ;
    v_no_merge_eh_cls := SQL%ROWCOUNT;

    /* Event group */
    merge into
           fdr.fr_general_lookup fgl
    using (
     select
             eh_load.event_grp
           , min( eh_load.event_grp_descr ) event_grp_descr
           , 'EVENT_GROUP'                  lk_lkt_lookup_type_code
           , TO_DATE('2000/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS')                  lk_effective_from
           , TO_DATE('2099/12/31 00:00:00','YYYY/MM/DD HH24:MI:SS')                  lk_effective_to
           , 'A'                            lk_active
        from
             stn.load_event_hierarchy  eh_load
       group by
             eh_load.event_grp ) eh_new
      on ( fgl.lk_match_key1           = eh_new.event_grp
       and fgl.lk_lkt_lookup_type_code = eh_new.lk_lkt_lookup_type_code )
      when matched then
        update
           set
               fgl.lk_lookup_value1    = eh_new.event_grp_descr
      when not matched then
        insert
            ( fgl.lk_match_key1
            , fgl.lk_lookup_value1
            , fgl.lk_lkt_lookup_type_code
            , fgl.lk_effective_from
            , fgl.lk_effective_to
            , fgl.lk_active )
        values
            ( eh_new.event_grp
            , eh_new.event_grp_descr
            , eh_new.lk_lkt_lookup_type_code
            , eh_new.lk_effective_from
            , eh_new.lk_effective_to
            , eh_new.lk_active )
    ;
    v_no_merge_eh_grp := SQL%ROWCOUNT;

    /* Event sub-group */
    merge into
           fdr.fr_general_lookup fgl
    using (
     select
             eh_load.event_subgrp
           , min( eh_load.event_subgrp_descr ) event_subgrp_descr
           , 'EVENT_SUBGROUP'                  lk_lkt_lookup_type_code
           , TO_DATE('2000/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS')                     lk_effective_from
           , TO_DATE('2099/12/31 00:00:00','YYYY/MM/DD HH24:MI:SS')                     lk_effective_to
           , 'A'                               lk_active
        from
             stn.load_event_hierarchy  eh_load
       group by
             eh_load.event_subgrp ) eh_new
      on ( fgl.lk_match_key1           = eh_new.event_subgrp
       and fgl.lk_lkt_lookup_type_code = eh_new.lk_lkt_lookup_type_code )
      when matched then
        update
           set
               fgl.lk_lookup_value1    = eh_new.event_subgrp_descr
      when not matched then
        insert
            ( fgl.lk_match_key1
            , fgl.lk_lookup_value1
            , fgl.lk_lkt_lookup_type_code
            , fgl.lk_effective_from
            , fgl.lk_effective_to
            , fgl.lk_active )
        values
            ( eh_new.event_subgrp
            , eh_new.event_subgrp_descr
            , eh_new.lk_lkt_lookup_type_code
            , eh_new.lk_effective_from
            , eh_new.lk_effective_to
            , eh_new.lk_active )
    ;
    v_no_merge_eh_sgr := SQL%ROWCOUNT;

    /* Event category */
    merge into
           fdr.fr_general_lookup fgl
    using (
     select
             eh_load.event_category
           , min( eh_load.event_category_descr ) event_category_descr
           , 'EVENT_CATEGORY'                    lk_lkt_lookup_type_code
           , TO_DATE('2000/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS')                       lk_effective_from
           , TO_DATE('2099/12/31 00:00:00','YYYY/MM/DD HH24:MI:SS')                       lk_effective_to
           , 'A'                                 lk_active
        from
             stn.load_event_hierarchy  eh_load
       where
             eh_load.event_category is not null
       group by
             eh_load.event_category ) eh_new
      on ( fgl.lk_match_key1           = eh_new.event_category
       and fgl.lk_lkt_lookup_type_code = eh_new.lk_lkt_lookup_type_code )
      when matched then
        update
           set
               fgl.lk_lookup_value1    = eh_new.event_category_descr
      when not matched then
        insert
            ( fgl.lk_match_key1
            , fgl.lk_lookup_value1
            , fgl.lk_lkt_lookup_type_code
            , fgl.lk_effective_from
            , fgl.lk_effective_to
            , fgl.lk_active )
        values
            ( eh_new.event_category
            , eh_new.event_category_descr
            , eh_new.lk_lkt_lookup_type_code
            , eh_new.lk_effective_from
            , eh_new.lk_effective_to
            , eh_new.lk_active )
    ;
    v_no_merge_eh_cat := SQL%ROWCOUNT;

    /* Event type 1 */
    merge into
           stn.event_type et
    using (
     select distinct
             eh_load.event_typ
        from
             stn.load_event_hierarchy  eh_load ) eh_new
      on ( et.event_typ  = eh_new.event_typ )
      when not matched then
        insert
            ( et.event_typ )
        values
            ( eh_new.event_typ )
    ;
    v_no_merge_eh_et1 := SQL%ROWCOUNT;

    /* Event type 2 */
    merge into
           fdr.fr_acc_event_type faet
    using (
     select distinct
             eh_load.event_typ
           , eh_load.event_typ_descr
           , 'A'             aet_active
           , TO_DATE('2000/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS') aet_valid_from
           , TO_DATE('2099/12/31 00:00:00','YYYY/MM/DD HH24:MI:SS') aet_valid_to
           , 'Client Static' aet_si_sys_inst_id
           , 'STN'           aet_auth_by
           , 'A'             aet_auth_status
           , 'N'             aet_cancel_flag
           , 'N'             aet_leg_flag
        from
             stn.load_event_hierarchy  eh_load ) eh_new
      on ( faet.aet_acc_event_type_id  = eh_new.event_typ )
      when matched then
        update
           set
               faet.aet_acc_event_type_name  = eh_new.event_typ_descr
             , faet.aet_active               = eh_new.aet_active
      when not matched then
        insert
            ( faet.aet_acc_event_type_id
            , faet.aet_acc_event_type_name
            , faet.aet_active
            , faet.aet_valid_from
            , faet.aet_valid_to 
            , faet.aet_si_sys_inst_id
            , faet.aet_auth_by
            , faet.aet_auth_status
            , faet.aet_cancel_flag
            , faet.aet_leg_flag)
        values
            ( eh_new.event_typ
            , eh_new.event_typ_descr
            , eh_new.aet_active
            , eh_new.aet_valid_from
            , eh_new.aet_valid_to 
            , eh_new.aet_si_sys_inst_id
            , eh_new.aet_auth_by
            , eh_new.aet_auth_status
            , eh_new.aet_cancel_flag
            , eh_new.aet_leg_flag)
    ;
    v_no_merge_eh_et1 := SQL%ROWCOUNT;
    p_no_update_eh := v_no_merge_eh
                    + v_no_merge_eh_cls
                    + v_no_merge_eh_grp
                    + v_no_merge_eh_sgr
                    + v_no_merge_eh_cat
                    + v_no_merge_eh_et1
                    + v_no_merge_eh_et2;
end pr_posting_rules_eh;

procedure pr_posting_rules_be ( p_no_update_be out number)
as
begin
    merge into
           stn.business_event be
    using (
     select
             be_load.business_event_cd
           , be_load.business_event_descr
           , bec.business_event_category_cd
           , be_load.business_event_seq_id
        from
             stn.load_business_event            be_load
        join stn.business_event_category        bec        
            on be_load.business_event_category_descr = bec.business_event_category_cd) be_new
      on ( be.business_event_cd =  be_new.business_event_cd )
      when matched then
        update
           set
               be.business_event_descr       = be_new.business_event_descr
             , be.business_event_category_cd = be_new.business_event_category_cd
             , be.business_event_seq_id      = be_new.business_event_seq_id
      when not matched then
        insert
            ( business_event_cd
            , business_event_descr
            , business_event_category_cd
            , business_event_seq_id )
        values
            ( be_new.business_event_cd
            , be_new.business_event_descr
            , be_new.business_event_category_cd
            , be_new.business_event_seq_id )
    ;
    p_no_update_be := SQL%ROWCOUNT;
end pr_posting_rules_be;

procedure pr_posting_rules_gc ( p_no_update_gc out number)
as
begin
    merge into
           stn.posting_method_derivation_le psmdl
    using (
     select
             gtc_load.le_cd
           , ( select psm_id from stn.posting_method psm where psm.psm_cd = 'GAAP_TO_CORE' ) psm_id
        from
             stn.load_gaap_to_core            gtc_load ) gtc_new
      on ( psmdl.le_cd =  gtc_new.le_cd )
      when not matched then
        insert
            ( le_cd
            , psm_id )
        values
            ( gtc_new.le_cd
            , gtc_new.psm_id )
    ;
    p_no_update_gc := SQL%ROWCOUNT;
end pr_posting_rules_gc;

procedure pr_posting_rules_pm ( p_no_update_pm out number)
as
begin
    merge into
           stn.posting_method_derivation_mtm psmdm
    using (
     select
             et.event_typ_id
           , psmdm_load.is_mark_to_market
           , psmdm_load.premium_typ
           , pab.basis_id
           , psm.psm_id
        from
             stn.load_posting_method_derivation psmdm_load
        join stn.posting_method                 psm        on psmdm_load.psm_cd    = psm.psm_cd
        join stn.posting_accounting_basis       pab        on psmdm_load.basis_cd  = pab.basis_cd
        join stn.event_type                     et         on psmdm_load.event_typ = et.event_typ ) psmdm_new
      on (     psmdm_new.event_typ_id      =  psmdm.event_typ_id
           and psmdm_new.is_mark_to_market =  psmdm.is_mark_to_market
           and psmdm_new.premium_typ       =  psmdm.premium_typ
           and psmdm_new.basis_id          =  psmdm.basis_id )
      when matched then
        update
           set
               psmdm.psm_id = psmdm_new.psm_id
      when not matched then
        insert
            ( event_typ_id
            , is_mark_to_market
            , premium_typ
            , basis_id
            , psm_id )
        values
            ( psmdm_new.event_typ_id
            , psmdm_new.is_mark_to_market
            , psmdm_new.premium_typ
            , psmdm_new.basis_id
            , psmdm_new.psm_id )
    ;
    p_no_update_pm := SQL%ROWCOUNT;
end pr_posting_rules_pm;

procedure pr_posting_rules_vp ( p_no_update_vp out number)
as
    v_no_merge_vp_vet    number(38, 9) default 0;
    v_no_merge_vp_pst    number(38, 9) default 0;
begin
    /* VIE event type */
    merge into
           stn.vie_event_type vet
    using (
     select distinct
             et.event_typ_id
        from
             stn.load_vie_posting_method  vpml
        join stn.event_type               et   on vpml.vie_event_typ = et.event_typ ) vet_new
      on ( vet.event_typ_id  = vet_new.event_typ_id )
      when not matched then
        insert
            ( vet.event_typ_id )
        values
            ( vet_new.event_typ_id )
    ;
    v_no_merge_vp_vet := SQL%ROWCOUNT;

    /* VIE posting method */
    merge into
           stn.vie_posting_method_ledger vpml
    using (
     select
             ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) input_basis_id
           , et.event_typ_id
           , vie_multi.vie_id
           , vet.event_typ_id                                                                 vie_event_typ_id
           , ( select basis_id from stn.posting_accounting_basis where basis_cd = 'US_GAAP' ) output_basis_id
           , ( select ledger_id from stn.posting_ledger where ledger_cd = 'GO_CONSOL' )       ledger_id
           , pfc.fin_calc_id
           , 1                                                                                negate_flag
           , vie_multi.sub_event
        from
             stn.load_vie_posting_method        vpml_load
        join stn.event_type                     et         on vpml_load.event_typ     = et.event_typ
        join stn.event_type                     vet        on vpml_load.vie_event_typ = vet.event_typ
        join (  select 'Monthly'  vie_typ  , 2 vie_id  , 'NULL'     sub_event  , 'MONTHLY' fin_calc_cd from dual
          union select 'Monthly'           , 5         , 'DECONSOL'            , 'MONTHLY'             from dual
          union select 'Monthly'           , 6         , 'NULL'                , 'MONTHLY'             from dual
          union select 'Consol balance'    , 2         , 'NULL'                , 'BOP'                 from dual
          union select 'Consol balance'    , 3         , 'NULL'                , 'EOP'                 from dual
          union select 'Deconsol balance'  , 4         , 'DECONSOL'            , 'BOP'                 from dual
          union select 'Deconsol balance'  , 5         , 'DECONSOL'            , 'EOP'                 from dual )
                                                vie_multi  on vpml_load.vie_typ       = vie_multi.vie_typ
        join stn.posting_financial_calc         pfc        on vie_multi.fin_calc_cd   = pfc.fin_calc_cd              ) vpml_new
      on (     vpml_new.input_basis_id    =  vpml.input_basis_id
           and vpml_new.event_typ_id      =  vpml.event_typ_id
           and vpml_new.vie_id            =  vpml.vie_id
           and vpml_new.vie_event_typ_id  =  vpml.vie_event_typ_id
           and vpml_new.output_basis_id   =  vpml.output_basis_id
           and vpml_new.ledger_id         =  vpml.ledger_id
           and vpml_new.fin_calc_id       =  vpml.fin_calc_id
           and vpml_new.negate_flag       =  vpml.negate_flag
           and vpml_new.sub_event         =  vpml.sub_event )
      when not matched then
        insert
            ( input_basis_id
            , event_typ_id
            , vie_id
            , vie_event_typ_id
            , output_basis_id
            , ledger_id
            , fin_calc_id
            , negate_flag
            , sub_event )
        values
            ( vpml_new.input_basis_id
            , vpml_new.event_typ_id
            , vpml_new.vie_id
            , vpml_new.vie_event_typ_id
            , vpml_new.output_basis_id
            , vpml_new.ledger_id
            , vpml_new.fin_calc_id
            , vpml_new.negate_flag
            , vpml_new.sub_event )
    ;
    v_no_merge_vp_pst := SQL%ROWCOUNT;
    p_no_update_vp := v_no_merge_vp_vet
                    + v_no_merge_vp_pst;
end pr_posting_rules_vp;

procedure pr_posting_rules_pd ( p_no_update_pd out number)
as
begin
    merge into
           fdr.fr_posting_driver fpd
    using (
    select
           fpd_load.pd_posting_driver_id
         , fpd_load.pd_posting_schema
         , fpd_load.pd_aet_event_type
         , fpd_load.pd_sub_event
         , fpd_load.pd_amount_type
         , fpd_load.pd_posting_code
         , fpd_load.pd_dr_or_cr
         , 'FR_STAN_RAW_ACC_EVENT'              pd_hopper
         , 'SRAE_CLIENT_AMOUNT1'                pd_field1
         , 'SRAE_CLIENT_AMOUNT2'                pd_field2
         , fpd_load.pd_transaction_no
         , fpd_load.pd_negate_flag1
         , fpd_load.pd_negate_flag1             pd_negate_flag2
         , fpd_load.pd_journal_type
         , null                                 pd_base_convert_flag
         , null                                 pd_local_convert_flag
         , null                                 pd_comment
         , null                                 pd_account_type
         , fpd_load.pd_valid_from
         , fpd_load.pd_valid_to
         , 'A'                                  pd_active
         , null                                 pd_action
         , user                                 pd_input_by
         , null                                 pd_input_time
         , null                                 pd_delete_time
         , null                                 pd_auth_by
         , null                                 pd_auth_status
         , null                                 pd_client_type_1
         , null                                 pd_client_type_2
         , null                                 pd_client_type_3
         , null                                 pd_date_type
         , null                                 pd_currency_type
         , null                                 pd_book_type
         , null                                 pd_client_mapping_1
         , null                                 pd_client_mapping_2
         , null                                 pd_client_mapping_3
         , 'Y'                                  pd_keep_signage
         , null                                 pd_ret_recog_type_id
      from
           stn.load_fr_posting_driver fpd_load ) fpd_new
      on (     fpd.pd_posting_driver_id =  fpd_new.pd_posting_driver_id )
      when matched then
        update
           set
               fpd.pd_valid_to = greatest( fpd_new.pd_valid_to , trunc( sysdate - 1 ) )
      when not matched then
        insert
            ( pd_posting_driver_id
            , pd_posting_schema
            , pd_aet_event_type
            , pd_sub_event
            , pd_amount_type
            , pd_posting_code
            , pd_dr_or_cr
            , pd_hopper
            , pd_field1
            , pd_field2
            , pd_transaction_no
            , pd_negate_flag1
            , pd_negate_flag2
            , pd_journal_type
            , pd_base_convert_flag
            , pd_local_convert_flag
            , pd_comment
            , pd_account_type
            , pd_valid_from
            , pd_valid_to
            , pd_active
            , pd_action
            , pd_input_by
            , pd_input_time
            , pd_delete_time
            , pd_auth_by
            , pd_auth_status
            , pd_client_type_1
            , pd_client_type_2
            , pd_client_type_3
            , pd_date_type
            , pd_currency_type
            , pd_book_type
            , pd_client_mapping_1
            , pd_client_mapping_2
            , pd_client_mapping_3
            , pd_keep_signage
            , pd_ret_recog_type_id )
        values
            ( fpd_new.pd_posting_driver_id
            , fpd_new.pd_posting_schema
            , fpd_new.pd_aet_event_type
            , fpd_new.pd_sub_event
            , fpd_new.pd_amount_type
            , fpd_new.pd_posting_code
            , fpd_new.pd_dr_or_cr
            , fpd_new.pd_hopper
            , fpd_new.pd_field1
            , fpd_new.pd_field2
            , fpd_new.pd_transaction_no
            , fpd_new.pd_negate_flag1
            , fpd_new.pd_negate_flag2
            , fpd_new.pd_journal_type
            , fpd_new.pd_base_convert_flag
            , fpd_new.pd_local_convert_flag
            , fpd_new.pd_comment
            , fpd_new.pd_account_type
            , fpd_new.pd_valid_from
            , fpd_new.pd_valid_to
            , fpd_new.pd_active
            , fpd_new.pd_action
            , fpd_new.pd_input_by
            , fpd_new.pd_input_time
            , fpd_new.pd_delete_time
            , fpd_new.pd_auth_by
            , fpd_new.pd_auth_status
            , fpd_new.pd_client_type_1
            , fpd_new.pd_client_type_2
            , fpd_new.pd_client_type_3
            , fpd_new.pd_date_type
            , fpd_new.pd_currency_type
            , fpd_new.pd_book_type
            , fpd_new.pd_client_mapping_1
            , fpd_new.pd_client_mapping_2
            , fpd_new.pd_client_mapping_3
            , fpd_new.pd_keep_signage
            , fpd_new.pd_ret_recog_type_id );
    p_no_update_pd := SQL%ROWCOUNT;
end pr_posting_rules_pd;

procedure pr_posting_rules_al ( p_no_update_al out number)
as
begin
    merge into
           fdr.fr_account_lookup fal
    using (
    select
           fal_load.al_posting_code
         , fal_load.al_lookup_1
         , fal_load.al_lookup_2
         , fal_load.al_lookup_3
         , fal_load.al_lookup_4
         , 'ND~'                        al_lookup_5
         , 'ND~'                        al_lookup_6
         , 'ND~'                        al_lookup_7
         , 'ND~'                        al_lookup_8
         , 'ND~'                        al_lookup_9
         , 'ND~'                        al_lookup_10
         , 'ND~'                        al_lookup_11
         , 'ND~'                        al_lookup_12
         , 'ND~'                        al_lookup_13
         , 'ND~'                        al_lookup_14
         , 'ND~'                        al_lookup_15
         , 'ND~'                        al_lookup_16
         , 'ND~'                        al_lookup_17
         , 'ND~'                        al_lookup_18
         , 'ND~'                        al_lookup_19
         , 'ND~'                        al_lookup_20
         , 'ND~'                        al_ccy
         , fal_load.al_account
         , fal_load.al_valid_from
         , fal_load.al_valid_to
         , 'A'                          al_active
         , 'I'                          al_action
         , user                         al_input_by
         , null                         al_input_time
         , null                         al_delete_time
         , null                         al_auth_by
         , null                         al_auth_status
         , null                         al_id
      from
           stn.load_fr_account_lookup fal_load ) fal_new
      on (     fal.al_posting_code      =  fal_new.al_posting_code
           and fal.al_lookup_1          =  fal_new.al_lookup_1
           and fal.al_lookup_2          =  fal_new.al_lookup_2
           and fal.al_lookup_3          =  fal_new.al_lookup_3
           and fal.al_lookup_4          =  fal_new.al_lookup_4 )
      when matched then
        update
           set
               fal.al_valid_to = greatest( fal_new.al_valid_to , trunc( sysdate - 1 ) )
      when not matched then
        insert
            ( al_posting_code
            , al_lookup_1
            , al_lookup_2
            , al_lookup_3
            , al_lookup_4
            , al_lookup_5
            , al_lookup_6
            , al_lookup_7
            , al_lookup_8
            , al_lookup_9
            , al_lookup_10
            , al_lookup_11
            , al_lookup_12
            , al_lookup_13
            , al_lookup_14
            , al_lookup_15
            , al_lookup_16
            , al_lookup_17
            , al_lookup_18
            , al_lookup_19
            , al_lookup_20
            , al_ccy
            , al_account
            , al_valid_from
            , al_valid_to
            , al_active
            , al_action
            , al_input_by
            , al_input_time
            , al_delete_time
            , al_auth_by
            , al_auth_status
            , al_id )
        values
            ( fal_new.al_posting_code
            , fal_new.al_lookup_1
            , fal_new.al_lookup_2
            , fal_new.al_lookup_3
            , fal_new.al_lookup_4
            , fal_new.al_lookup_5
            , fal_new.al_lookup_6
            , fal_new.al_lookup_7
            , fal_new.al_lookup_8
            , fal_new.al_lookup_9
            , fal_new.al_lookup_10
            , fal_new.al_lookup_11
            , fal_new.al_lookup_12
            , fal_new.al_lookup_13
            , fal_new.al_lookup_14
            , fal_new.al_lookup_15
            , fal_new.al_lookup_16
            , fal_new.al_lookup_17
            , fal_new.al_lookup_18
            , fal_new.al_lookup_19
            , fal_new.al_lookup_20
            , fal_new.al_ccy
            , fal_new.al_account
            , fal_new.al_valid_from
            , fal_new.al_valid_to
            , fal_new.al_active
            , fal_new.al_action
            , fal_new.al_input_by
            , fal_new.al_input_time
            , fal_new.al_delete_time
            , fal_new.al_auth_by
            , fal_new.al_auth_status
            , fal_new.al_id );
    p_no_update_al := SQL%ROWCOUNT;
end pr_posting_rules_al;

procedure pr_posting_rules_update
as
    v_no_load_eh    number(38, 9) default 0;
    v_no_load_be    number(38, 9) default 0;
    v_no_load_gc    number(38, 9) default 0;
    v_no_load_pm    number(38, 9) default 0;
    v_no_load_vp    number(38, 9) default 0;
    v_no_load_pd    number(38, 9) default 0;
    v_no_load_al    number(38, 9) default 0;
    v_no_load_total number(38, 9) default 0;
    v_no_diff_eh    number(38, 9) default 0;
    v_no_diff_be    number(38, 9) default 0;
    v_no_diff_gc    number(38, 9) default 0;
    v_no_diff_pm    number(38, 9) default 0;
    v_no_diff_vp    number(38, 9) default 0;
    v_no_diff_pd    number(38, 9) default 0;
    v_no_diff_al    number(38, 9) default 0;
    v_no_diff_total number(38, 9) default 0;
    v_no_update_eh  number(38, 9) default 0;
    v_no_update_be  number(38, 9) default 0;
    v_no_update_gc  number(38, 9) default 0;
    v_no_update_pm  number(38, 9) default 0;
    v_no_update_vp  number(38, 9) default 0;
    v_no_update_pd  number(38, 9) default 0;
    v_no_update_al  number(38, 9) default 0;
begin
    pr_posting_rules_check();
    pr_posting_rules_compare( v_no_load_eh
                            , v_no_load_be
                            , v_no_load_gc
                            , v_no_load_pm
                            , v_no_load_vp
                            , v_no_load_pd
                            , v_no_load_al
                            , v_no_load_total
                            , v_no_diff_eh
                            , v_no_diff_be
                            , v_no_diff_gc
                            , v_no_diff_pm
                            , v_no_diff_vp
                            , v_no_diff_pd
                            , v_no_diff_al
                            , v_no_diff_total );
    if v_no_load_total > 0 then
        if v_no_diff_total > 0 then
            if v_no_load_eh > 0 and v_no_diff_eh > 0 then
                pr_posting_rules_eh( v_no_update_eh );
                pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Updated event hierarchy', 'v_no_update_eh', NULL, v_no_update_eh, NULL);
            elsif v_no_load_eh = 0 then
                pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'No event hierarchy loader records', NULL, NULL, NULL, NULL);
            elsif v_no_diff_eh = 0 then
                pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'No event hierarchy differences', NULL, NULL, NULL, NULL);
            end if;
            if v_no_load_be > 0 and v_no_diff_be > 0 then
                pr_posting_rules_be( v_no_update_be );
                pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Updated business event', 'v_no_update_be', NULL, v_no_update_be, NULL);
            elsif v_no_load_be = 0 then
                pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'No business event loader records', NULL, NULL, NULL, NULL);
            elsif v_no_diff_be = 0 then
                pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'No business event differences', NULL, NULL, NULL, NULL);
            end if;
            if v_no_load_gc > 0 and v_no_diff_gc > 0 then
                pr_posting_rules_gc( v_no_update_gc );
                pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Updated GAAP to core', 'v_no_update_gc', NULL, v_no_update_gc, NULL);
            elsif v_no_load_gc = 0 then
                pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'No GAAP to core loader records', NULL, NULL, NULL, NULL);
            elsif v_no_diff_gc = 0 then
                pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'No GAAP to core differences', NULL, NULL, NULL, NULL);
            end if;
            if v_no_load_pm > 0 and v_no_diff_pm > 0 then
                pr_posting_rules_pm( v_no_update_pm );
                pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Updated posting method', 'v_no_update_pm', NULL, v_no_update_pm, NULL);
            elsif v_no_load_pm = 0 then
                pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'No posting method loader records', NULL, NULL, NULL, NULL);
            elsif v_no_diff_pm = 0 then
                pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'No posting method differences', NULL, NULL, NULL, NULL);
            end if;
            if v_no_load_vp > 0 and v_no_diff_vp > 0 then
                pr_posting_rules_vp( v_no_update_vp );
                pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Updated VIE posting method', 'v_no_update_vp', NULL, v_no_update_vp, NULL);
            elsif v_no_load_vp = 0 then
                pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'No VIE posting method loader records', NULL, NULL, NULL, NULL);
            elsif v_no_diff_vp = 0 then
                pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'No VIE posting method differences', NULL, NULL, NULL, NULL);
            end if;
            if v_no_load_pd > 0 and v_no_diff_pd > 0 then
                pr_posting_rules_pd( v_no_update_pd );
                pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Updated posting driver', 'v_no_update_pd', NULL, v_no_update_pd, NULL);
            elsif v_no_load_pd = 0 then
                pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'No posting driver loader records', NULL, NULL, NULL, NULL);
            elsif v_no_diff_pd = 0 then
                pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'No posting driver differences', NULL, NULL, NULL, NULL);
            end if;
            if v_no_load_al > 0 and v_no_diff_al > 0 then
                pr_posting_rules_al( v_no_update_al );
                pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Updated account lookup', 'v_no_update_al', NULL, v_no_update_al, NULL);
            elsif v_no_load_al = 0 then
                pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'No account lookup loader records', NULL, NULL, NULL, NULL);
            elsif v_no_diff_al = 0 then
                pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'No account lookup differences', NULL, NULL, NULL, NULL);
            end if;
            pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Completed posting rule updates', NULL, NULL, NULL, NULL);
            commit;
        else
            pr_step_run_log(0, $$plsql_unit, $$plsql_line, 'Zero posting rule differences found', NULL, NULL, NULL, NULL);
        end if;
    end if;
end;

end pk_posting_rules;
/
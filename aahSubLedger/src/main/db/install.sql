-- -----------------------------------------------------------------------------------------
-- filename: install.sql
-- author  : andrew hall
-- purpose : Script to install the objects which are involved in standardisation.
--         :
-- -----------------------------------------------------------------------------------------

whenever sqlerror exit failure

set serveroutput on
set define ~

define fdr_logon=~1
define gui_logon=~2
define rdr_logon=~3
define sla_logon=~4
define slr_logon=~5
define stn_logon=~6
define sys_logon=~7
define unittest_login=~8

conn ~stn_logon
@@grants/tables/stn/business_type.sql
@@grants/tables/stn/insurance_policy.sql
@@grants/tables/stn/execution_type.sql

conn ~fdr_logon

delete from fdr.fr_account_lookup_param;
@@data/fdr/fr_gaap.sql
@@data/fdr/fr_posting_schema.sql
@@data/fdr/fr_account_lookup_param.sql
@@data/fdr/fr_financial_amount.sql
@@data/fdr/fr_posting_driver.sql
--@@data/fdr/fr_account_lookup.sql
@@data/fdr/fr_acc_event_type.sql
@@data/fdr/fr_gl_account.sql
@@grants/tables/fdr/fr_general_lookup.sql
update fdr.fr_acc_event_type
set aet_active = 'I'
where aet_input_by = 'SPS';
commit;


conn ~slr_logon

@@tables/slr/slr_fak_bop_amounts.sql
@@tables/slr/slr_fak_bop_amounts_tmp.sql
@@tables/slr/slr_fak_bop_amounts_tmp2.sql
@@tables/slr/slr_fak_bop_amounts_tmp3.sql
@@tables/slr/slr_eba_bop_amounts.sql
@@tables/slr/slr_eba_bop_amounts_tmp.sql
@@tables/slr/slr_eba_bop_amounts_tmp2.sql
@@tables/slr/slr_eba_bop_amounts_tmp3.sql
@@indices/slr/slr_fak_bop_amounts_tmp.sql
@@indices/slr/slr_fak_bop_amounts_tmp2.sql
@@indices/slr/slr_fak_bop_amounts_tmp3.sql
@@indices/slr/slr_eba_bop_amounts_tmp.sql
@@indices/slr/slr_eba_bop_amounts_tmp2.sql
@@indices/slr/slr_eba_bop_amounts_tmp3.sql
@@indices/slr/slr_jl_slr_process.sql
@@grants/tables/slr/slr_bm_entity_processing_set.sql

delete from slr.slr_entity_proc_group;
commit;

-- update journal type descriptions for manual journal entries by gui
update slr.slr_ext_jrnl_types set ejt_madj_flag = 'N' where ejt_type not in ('MADJPERB','MADJBDPPE','MADJREVPE');
update slr.slr_ext_jrnl_types set ejt_madj_flag = 'Y' where ejt_type in ('MADJPERB','MADJBDPPE','MADJREVPE');
update slr.slr_ext_jrnl_types set ejt_active_flag = 'I' where ejt_type not in ('MADJPERB','MADJBDPPE','MADJREVPE','PERC','FXREVALUE','PLRETEARNINGS');
update slr.slr_ext_jrnl_types set ejt_active_flag = 'A' where ejt_type in ('MADJPERB','MADJBDPPE','MADJREVPE','PERC','FXREVALUE','PLRETEARNINGS');
update slr_ext_jrnl_types set ejt_short_desc = 'Manual JE prior to open period' where ejt_type = 'MADJPERB';
update slr_ext_jrnl_types set ejt_short_desc = 'Manual JE open period'  where ejt_type = 'MADJBDPPE';
update slr_ext_jrnl_types set ejt_short_desc = 'Manual JE rev open period' where ejt_type = 'MADJREVPE';
commit;

@@data/slr/slr_ledgers.sql
@@data/slr/slr_entity_sets.sql
@@data/slr/slr_fak_segment_3.sql
@@data/slr/slr_fak_segment_4.sql
@@data/slr/slr_fak_segment_5.sql
@@data/slr/slr_fak_segment_6.sql
@@data/slr/slr_fak_segment_7.sql
@@data/slr/slr_fak_segment_8.sql
@@packages/slr/slr_pkg.hdr
@@packages/slr/slr_pkg.bdy
@@packages/slr/slr_validate_journals_pkg.hdr
@@packages/slr/slr_validate_journals_pkg.bdy

/*Replace slr_balances_movement_pkg with custom version*/
@@packages/slr/slr_balance_movement_pkg.hdr
@@packages/slr/slr_balance_movement_pkg.bdy


/*Begin SLR QTD modifications*/

--Backup and replace with modified view
@@views/slr/v_slr_jrnl_lines_unposted_bak.sql
@@views/slr/v_slr_jrnl_lines_unposted_jt.sql

--Create custom view
@@views/slr/v_slr_journal_lines.sql

--Add custom columns
ALTER TABLE SLR.SLR_EBA_BALANCES_ROLLBACK 
 ADD  (     
  EDB_TRAN_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    EDB_BASE_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    EDB_LOCAL_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    EDB_PERIOD_QTR NUMBER(1,0) NOT NULL);

ALTER TABLE SLR.SLR_EBA_DAILY_BALANCES
 ADD  (     
  EDB_TRAN_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    EDB_BASE_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    EDB_LOCAL_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    EDB_PERIOD_QTR NUMBER(1,0) NOT NULL);

ALTER TABLE SLR.SLR_EBA_DAILY_BALANCES_ARC
 ADD  (     
  EDBA_TRAN_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    EDBA_BASE_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    EDBA_LOCAL_QTD_BALANCE NUMBER(38,3) NOT NULL);

ALTER TABLE SLR.SLR_FAK_BALANCES_ROLLBACK
 ADD  (
  FDB_TRAN_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    FDB_BASE_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    FDB_LOCAL_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    FDB_PERIOD_QTR NUMBER(1,0) NOT NULL);

ALTER TABLE SLR.SLR_FAK_DAILY_BALANCES
 ADD  (     
  FDB_TRAN_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    FDB_BASE_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    FDB_LOCAL_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    FDB_PERIOD_QTR NUMBER(1,0) NOT NULL);

ALTER TABLE SLR.SLR_FAK_DAILY_BALANCES_ARC
 ADD  (     
  FDBA_TRAN_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    FDBA_BASE_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    FDBA_LOCAL_QTD_BALANCE NUMBER(38,3) NOT NULL);

ALTER TABLE SLR.SLR_FAK_LAST_BALANCES
 ADD  (     
  FLB_TRAN_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    FLB_BASE_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    FLB_LOCAL_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    FLB_PERIOD_QTR NUMBER(1,0) NOT NULL);

ALTER TABLE SLR.SLR_LAST_BALANCES
 ADD  (     
  LB_TRAN_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    LB_BASE_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    LB_LOCAL_QTD_BALANCE NUMBER(38,3) NOT NULL, 
    LB_PERIOD_QTR NUMBER(1,0) NOT NULL);

comment on column slr.slr_eba_balances_rollback.edb_tran_qtd_balance is 'Custom AG';
comment on column slr.slr_eba_balances_rollback.edb_base_qtd_balance is 'Custom AG';
comment on column slr.slr_eba_balances_rollback.edb_local_qtd_balance is 'Custom AG';
comment on column slr.slr_eba_balances_rollback.edb_period_qtr is 'Custom AG';
comment on column slr.slr_eba_daily_balances.edb_tran_qtd_balance is 'Custom AG';
comment on column slr.slr_eba_daily_balances.edb_base_qtd_balance is 'Custom AG';
comment on column slr.slr_eba_daily_balances.edb_local_qtd_balance is 'Custom AG';
comment on column slr.slr_eba_daily_balances.edb_period_qtr is 'Custom AG';
comment on column slr.slr_eba_daily_balances_arc.edba_tran_qtd_balance is 'Custom AG';
comment on column slr.slr_eba_daily_balances_arc.edba_base_qtd_balance is 'Custom AG';
comment on column slr.slr_eba_daily_balances_arc.edba_local_qtd_balance is 'Custom AG';
comment on column slr.slr_fak_balances_rollback.fdb_tran_qtd_balance is 'Custom AG';
comment on column slr.slr_fak_balances_rollback.fdb_base_qtd_balance is 'Custom AG';
comment on column slr.slr_fak_balances_rollback.fdb_local_qtd_balance is 'Custom AG';
comment on column slr.slr_fak_balances_rollback.fdb_period_qtr is 'Custom AG';
comment on column slr.slr_fak_daily_balances.fdb_tran_qtd_balance is 'Custom AG';
comment on column slr.slr_fak_daily_balances.fdb_base_qtd_balance is 'Custom AG';
comment on column slr.slr_fak_daily_balances.fdb_local_qtd_balance is 'Custom AG';
comment on column slr.slr_fak_daily_balances.fdb_period_qtr is 'Custom AG';
comment on column slr.slr_fak_daily_balances_arc.fdba_tran_qtd_balance is 'Custom AG';
comment on column slr.slr_fak_daily_balances_arc.fdba_base_qtd_balance is 'Custom AG';
comment on column slr.slr_fak_daily_balances_arc.fdba_local_qtd_balance is 'Custom AG';
comment on column slr.slr_fak_last_balances.flb_tran_qtd_balance is 'Custom AG';
comment on column slr.slr_fak_last_balances.flb_base_qtd_balance is 'Custom AG';
comment on column slr.slr_fak_last_balances.flb_local_qtd_balance is 'Custom AG';
comment on column slr.slr_fak_last_balances.flb_period_qtr is 'Custom AG';
comment on column slr.slr_last_balances.lb_tran_qtd_balance is 'Custom AG';
comment on column slr.slr_last_balances.lb_base_qtd_balance is 'Custom AG';
comment on column slr.slr_last_balances.lb_local_qtd_balance is 'Custom AG';
comment on column slr.slr_last_balances.lb_period_qtr is 'Custom AG';
commit;

--Backup and replace with modified package

declare ddl clob;
begin
  ddl := dbms_metadata.get_ddl
    (object_type => 'PACKAGE_SPEC'
    ,name => 'SLR_POST_JOURNALS_PKG'
    );
  ddl := REPLACE(ddl, UPPER('SLR_POST_JOURNALS_PKG'), UPPER('SLR_POST_JOURNALS_PKG_BAK'));
  ddl := REPLACE(ddl, LOWER('SLR_POST_JOURNALS_PKG'), LOWER('SLR_POST_JOURNALS_PKG_BAK'));
  EXECUTE IMMEDIATE ddl;
  ddl := dbms_metadata.get_ddl
    (object_type => 'PACKAGE_BODY'
    ,name => 'SLR_POST_JOURNALS_PKG');
  ddl := REPLACE(ddl, UPPER('SLR_POST_JOURNALS_PKG'), UPPER('SLR_POST_JOURNALS_PKG_BAK'));
  ddl := REPLACE(ddl, LOWER('SLR_POST_JOURNALS_PKG'), LOWER('SLR_POST_JOURNALS_PKG_BAK'));
  EXECUTE IMMEDIATE ddl;
end;
/

@@packages/slr/slr_post_journals_pkg.hdr
@@packages/slr/slr_post_journals_pkg.bdy

--End SLR QTD modifications

/*RECOMPILE SLR PACKAGES AND VIEWS*/

BEGIN
  FOR cur_rec IN (SELECT owner,
                         object_name,
                         object_type,
                         DECODE(object_type, 'PACKAGE', 1,
                                             'PACKAGE BODY', 2,
                                             'VIEW', 3, 4) AS recompile_order
                  FROM   dba_objects
                  WHERE  object_type IN ('PACKAGE', 'PACKAGE BODY', 'VIEW')
                  AND    owner = 'SLR'
                  ORDER BY 4)
  LOOP
    BEGIN
      IF cur_rec.object_type in ('PACKAGE','VIEW') THEN
        EXECUTE IMMEDIATE 'ALTER ' || cur_rec.object_type || 
            ' "' || cur_rec.owner || '"."' || cur_rec.object_name || '" COMPILE';
      ElSE
        EXECUTE IMMEDIATE 'ALTER PACKAGE "' || cur_rec.owner || 
            '"."' || cur_rec.object_name || '" COMPILE BODY';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line(cur_rec.object_type || ' : ' || cur_rec.owner || 
                             ' : ' || cur_rec.object_name);
    END;
  END LOOP;
END;
/

-- -----------------------------------------------------------------------------------------
-- purpose : Begin GLINT installation
-- -----------------------------------------------------------------------------------------

conn ~fdr_logon

@@packages/fdr/pg_common.hdr
@@packages/fdr/pg_common.bdy
@@grants/packages/fdr/pg_common.sql
@@data/fdr/fr_general_code_types.sql
@@data/fdr/fr_general_codes.sql

conn ~rdr_logon
@@sequences/rdr/sqrr_glint_batch_control.sql
@@sequences/rdr/sqrr_interface_control.sql
@@sequences/rdr/sqrr_glint_journal_line.sql
@@tables/rdr/rr_glint_temp_journal_line.sql
@@indices/rdr/rr_glint_temp_journal_line.sql
@@tables/rdr/rr_glint_temp_journal.sql
@@tables/rdr/rr_interface_control.sql
@@tables/rdr/rr_glint_batch_control.sql
@@indices/rdr/rr_glint_batch_control.sql
@@tables/rdr/rr_glint_journal.sql
@@indices/rdr/rr_glint_journal.sql
@@tables/rdr/rr_glint_journal_mapping.sql
@@indices/rdr/rr_glint_journal_mapping.sql
@@tables/rdr/rr_glint_journal_line.sql
@@indices/rdr/rr_glint_journal_line.sql
@@views/rdr/rcv_glint_journal_line.sql
@@views/rdr/rcv_glint_journal.sql
@@tables/rdr/rr_glint_to_slr_ag.sql

@@packages/rdr/pg_glint.hdr
@@packages/rdr/pg_glint.bdy
@@grants/packages/rdr/pg_glint.sql
@@packages/rdr/pgc_glint.hdr
@@packages/rdr/pgc_glint.bdy
@@packages/rdr/rdr_pkg.hdr
@@packages/rdr/rdr_pkg.bdy

conn ~slr_logon

update slr.slr_ext_jrnl_types set ejt_client_flag1 = 0 where ejt_client_flag1 is null;
commit;

conn ~gui_logon

@@data/gui/ui_component.sql
@@data/gui/ui_input_field_value.sql
@@data/gui/ui_field.sql

-- -----------------------------------------------------------------------------------------
-- purpose : Begin FX installation
-- -----------------------------------------------------------------------------------------

conn ~fdr_logon

@@data/fdr/fr_general_lookup_type.sql
@@data/fdr/fr_general_lookup.sql
@@grants/tables/fdr/fr_gaap.sql

conn ~slr_logon

begin
    for i in (
                 select
                        'alter table slr.slr_process_config drop constraint ' || upper ( constraint_name ) drop_stmt
                   from
                        all_constraints
                  where
                        lower ( owner )      = 'slr'
                    and lower ( table_name ) = 'slr_process_config'
                    and upper ( search_condition_vc ) like 'PC_METHOD%'
             )
    loop
        execute immediate i.drop_stmt;
    end loop;
end;
/

alter table slr.slr_process_config add constraint ck_pc_method check (PC_METHOD IN ('DEFAULT', 'TRANS-LOCAL', 'LOCAL-BASE', 'TRANS-BASE'));

@@data/slr/slr_process_config.sql
@@data/slr/slr_process_config_detail.sql
@@data/slr/slr_process_source.sql
@@data/slr/slr_hints_sets.sql
@@views/slr/v_slr_fxreval_parameters.sql
@@views/slr/v_slr_fxreval_run_values.sql
@@views/slr/vbmfxreval_eba_ag_r0_usstat.sql
@@views/slr/vbmfxreval_eba_ag_r0_usgaap.sql
@@views/slr/vbmfxreval_eba_ag_r0_ukgaap.sql
@@views/slr/vbmfxreval_eba_ag_r2_usstat.sql
@@views/slr/vbmfxreval_eba_ag_r2_usgaap.sql
@@views/slr/vbmfxreval_eba_ag_r2_ukgaap.sql

-- ye cleardown views
@@views/slr/vbm_ag_retainedearningseba01.sql
@@views/slr/vbm_ag_retainedearningseba02.sql
@@views/slr/vbm_ag_retainedearningseba03.sql
@@views/slr/v_ag_ye_clr_run.sql

-- -----------------------------------------------------------------------------------------
-- purpose : Begin Combo Edit installation
-- -----------------------------------------------------------------------------------------
conn ~slr_logon

alter table slr.slr_entities add (ent_combo_check_flag char(1) default 'N');
alter table slr.slr_entities add constraint ent_combo_check_flag check (ent_combo_check_flag in ('Y','N'));
comment on column slr.slr_entities.ent_combo_check_flag is 'Whether the accounting key combination values should be validated for this entity.';
alter table slr.slr_jrnl_line_errors disable all triggers;

conn ~fdr_logon

@@tables/fdr/fr_combination_check_input.sql
@@tables/fdr/fr_combination_check_error.sql
@@views/fdr/fcv_combination_check_data.sql
@@views/fdr/fcv_combination_check_suspense.sql
@@views/fdr/fcv_combination_check_hopper.sql
@@packages/fdr/pg_combination_check.hdr
@@packages/fdr/pg_combination_check.bdy
@@procedures/fdr/pcombinationcheck_hopper.sql
@@grants/packages/fdr/pg_combination_check.sql
@@grants/tables/fdr/fr_combination_check_input.sql
@@grants/tables/fdr/fr_combination_check_error.sql
@@grants/tables/fdr/fcv_combination_check_data.sql
@@grants/tables/fdr/fcv_combination_check_suspense.sql

conn ~gui_logon

@@views/gui/ucv_combination_check_jlu.sql
@@functions/gui/fcombinationcheck_jlu.sql
@@grants/packages/gui/fcombinationcheck_jlu.sql
@@grants/tables/gui/gui_jrnl_lines_unposted.sql
@@grants/tables/gui/gui_jrnl_headers_unposted.sql
@@data/gui/ui_general_lookup.sql
@@data/gui/ui_gen_lookup_type_properties.sql

conn ~slr_logon

@@views/slr/scv_combination_check_jlu.sql
@@views/slr/srv_combination_check_jte.sql
@@procedures/slr/pcombinationcheck_jlu.sql
delete from slr.slr_error_message where em_error_code = 'JL_COMBO';
@@data/slr/slr_error_message.sql
@@grants/tables/slr/scv_combination_check_jlu.sql
@@grants/tables/slr/slr_jrnl_headers.sql
@@grants/tables/slr/slr_entities.sql
@@grants/tables/slr/slr_jrnl_lines_unposted.sql
@@grants/tables/slr/seq_process_number.sql
@@grants/packages/slr/fnslr_getheaderid.sql
alter table slr.slr_jrnl_line_errors enable all triggers;
commit;

conn ~rdr_logon

@@views/rdr/rrv_combination_check_app_rule.sql
@@views/rdr/rrv_combination_check_rule.sql
@@views/rdr/rcv_combination_check_glint.sql
@@tables/rdr/rr_glint_suspense_line.sql
@@grants/tables/rdr/rcv_combination_check_glint.sql

exit
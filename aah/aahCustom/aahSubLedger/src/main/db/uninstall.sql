-- -----------------------------------------------------------------------------------------
-- filename: uninstall.sql
-- author  : andrew hall
-- purpose : Script to uninstall the objects which manage process invocation.
--         :
-- -----------------------------------------------------------------------------------------

--whenever sqlerror exit failure

set serveroutput on
set define ~
set echo on

define fdr_logon=~1
define gui_logon=~2
define rdr_logon=~3
define sla_logon=~4
define slr_logon=~5
define stn_logon=~6
define sys_logon=~7
define unittest_login=~8

conn ~fdr_logon

--deletes required for AAH Posting Rules Loader
delete from fdr.fr_posting_driver;
delete from fdr.fr_account_lookup;
delete from fdr.fr_general_lookup where lk_lkt_lookup_type_code IN 
    ('EVENT_HIERARCHY',
     'EVENT_CLASS', 
     'EVENT_GROUP',
     'EVENT_SUBGROUP',
     'EVENT_CATEGORY');
delete from fdr.fr_acc_event_type where aet_input_by NOT IN ('SPS', 'FDR Create');
delete from fdr.fr_entity_schema;
delete from fdr.fr_gaap;
delete from fdr.fr_posting_schema;
delete from fdr.fr_lpg_config;
delete from fdr.fr_account_lookup_param;
delete from fdr.fr_financial_amount;
delete from fdr.fr_gl_account_lookup where gal_ga_lookup_key != '1';
delete from fdr.fr_gl_account        where ga_account_code   != '1';
commit;
update fdr.fr_acc_event_type
set aet_active = 'A'
where aet_input_by = 'SPS';
commit;


conn ~slr_logon

drop table slr.slr_fak_bop_amounts;
drop table slr.slr_fak_bop_amounts_tmp;
drop table slr.slr_fak_bop_amounts_tmp2;
drop table slr.slr_fak_bop_amounts_tmp3;
drop table slr.slr_eba_bop_amounts;
drop table slr.slr_eba_bop_amounts_tmp;
drop table slr.slr_eba_bop_amounts_tmp2;
drop table slr.slr_eba_bop_amounts_tmp3;
commit;

conn ~slr_logon
--Begin removal of SLR QTD modifications

--Replace with baseline package

declare ddl clob;
begin
  ddl := dbms_metadata.get_ddl
    (object_type => 'PACKAGE_SPEC'
    ,name => 'SLR.SLR_POST_JOURNALS_PKG_BAK'
    );
  ddl := REPLACE(ddl, UPPER('SLR.SLR_POST_JOURNALS_PKG_BAK'), UPPER('SLR.SLR_POST_JOURNALS_PKG'));
  ddl := REPLACE(ddl, LOWER('SLR.SLR_POST_JOURNALS_PKG_BAK'), LOWER('SLR.SLR_POST_JOURNALS_PKG'));
  EXECUTE IMMEDIATE ddl;
  ddl := dbms_metadata.get_ddl
    (object_type => 'PACKAGE_BODY'
    ,name => 'SLR.SLR_POST_JOURNALS_PKG_BAK');
  ddl := REPLACE(ddl, UPPER('SLR.SLR_POST_JOURNALS_PKG_BAK'), UPPER('SLR.SLR_POST_JOURNALS_PKG'));
  ddl := REPLACE(ddl, LOWER('SLR.SLR_POST_JOURNALS_PKG_BAK'), LOWER('SLR.SLR_POST_JOURNALS_PKG'));
  EXECUTE IMMEDIATE ddl;
end;
/

drop package body slr.slr_post_journals_pkg_bak;
drop package      slr.slr_post_journals_pkg_bak;

--Remove custom columns

truncate table SLR.SLR_EBA_BALANCES_ROLLBACK;
ALTER TABLE SLR.SLR_EBA_BALANCES_ROLLBACK 
 DROP  (     
  EDB_TRAN_QTD_BALANCE, 
    EDB_BASE_QTD_BALANCE, 
    EDB_LOCAL_QTD_BALANCE, 
    EDB_PERIOD_QTR);

truncate table SLR.SLR_EBA_DAILY_BALANCES;
ALTER TABLE SLR.SLR_EBA_DAILY_BALANCES
 DROP  (     
  EDB_TRAN_QTD_BALANCE, 
    EDB_BASE_QTD_BALANCE, 
    EDB_LOCAL_QTD_BALANCE, 
    EDB_PERIOD_QTR);

truncate table SLR.SLR_EBA_DAILY_BALANCES_ARC;
ALTER TABLE SLR.SLR_EBA_DAILY_BALANCES_ARC
 DROP  (     
  EDBA_TRAN_QTD_BALANCE, 
    EDBA_BASE_QTD_BALANCE, 
    EDBA_LOCAL_QTD_BALANCE);

truncate table SLR.SLR_FAK_BALANCES_ROLLBACK;
ALTER TABLE SLR.SLR_FAK_BALANCES_ROLLBACK
 DROP  (
  FDB_TRAN_QTD_BALANCE, 
    FDB_BASE_QTD_BALANCE, 
    FDB_LOCAL_QTD_BALANCE, 
    FDB_PERIOD_QTR);

truncate table SLR.SLR_FAK_DAILY_BALANCES;
ALTER TABLE SLR.SLR_FAK_DAILY_BALANCES
 DROP  (     
  FDB_TRAN_QTD_BALANCE, 
    FDB_BASE_QTD_BALANCE, 
    FDB_LOCAL_QTD_BALANCE, 
    FDB_PERIOD_QTR);

truncate table SLR.SLR_FAK_DAILY_BALANCES_ARC;
ALTER TABLE SLR.SLR_FAK_DAILY_BALANCES_ARC
 DROP  (     
  FDBA_TRAN_QTD_BALANCE, 
    FDBA_BASE_QTD_BALANCE, 
    FDBA_LOCAL_QTD_BALANCE);

truncate table SLR.SLR_FAK_LAST_BALANCES;
ALTER TABLE SLR.SLR_FAK_LAST_BALANCES
 DROP  (     
  FLB_TRAN_QTD_BALANCE, 
    FLB_BASE_QTD_BALANCE, 
    FLB_LOCAL_QTD_BALANCE, 
    FLB_PERIOD_QTR);

truncate table SLR.SLR_LAST_BALANCES;
ALTER TABLE SLR.SLR_LAST_BALANCES
 DROP  (     
  LB_TRAN_QTD_BALANCE, 
    LB_BASE_QTD_BALANCE, 
    LB_LOCAL_QTD_BALANCE, 
    LB_PERIOD_QTR);

--Drop custom view
drop view slr.v_slr_journal_lines;

--Restore baseline view and drop modified view
drop view slr.v_slr_jrnl_lines_unposted_jt;
rename v_slr_jrnl_lines_unposted_bak to v_slr_jrnl_lines_unposted_jt;

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

--End removal of SLR QTD modifications

drop package body slr.slr_pkg;
drop package      slr.slr_pkg;

delete from slr.slr_bm_entity_processing_set;
delete from slr.slr_entities;

delete from slr.slr_eba_definitions;
delete from slr.slr_fak_definitions;
delete from slr.slr_fak_definitions;
delete from slr.slr_entity_grace_days;
delete from slr.slr_ledgers;
delete from slr.slr_entity_sets;
delete from slr.slr_fak_segment_8;
delete from slr.slr_fak_segment_7;
delete from slr.slr_fak_segment_6;
delete from slr.slr_fak_segment_5;
delete from slr.slr_fak_segment_4;
delete from slr.slr_fak_segment_3;
commit;

commit;

-- -----------------------------------------------------------------------------------------
-- purpose : Begin GLINT uninstall
-- -----------------------------------------------------------------------------------------
conn ~gui_logon
-- jb
delete from GUI.UI_GENERAL_LOOKUP where ugl_uf_id in (
    select uf_id from gui.ui_field where uf_uc_id in (1000,50000,10000,20000) );
delete from gui.ui_field where uf_id between 10000 and 10050;
delete from gui.ui_field where uf_uc_id in (1000,50000,10000,20000);
delete from gui.ui_input_field_value where uif_category_code in ('Status','YesOrNo','GLINTSchema','GLINTSourceObject','GLINTTargetObject') or (uif_category_code = 'GLINTSourceAttribute' and uif_description = 'RR_GLINT_BATCH_CONTROL');
delete from gui.ui_input_field_value where (uif_description like 'RCV_JOURNAL%' or uif_description like 'Custom%') and uif_category_code like 'GLINT%';
delete from gui.ui_component where uc_id in (1000,50000,10000,20000);
commit;

conn ~slr_logon
update slr.slr_ext_jrnl_types set ejt_client_flag1 = NULL where ejt_client_flag1 = 0;
commit;

conn ~rdr_logon
drop package body rdr.rdr_pkg;
drop package      rdr.rdr_pkg;
drop package body rdr.pgc_glint;
drop package      rdr.pgc_glint;
drop package body rdr.pg_glint;
drop package      rdr.pg_glint;
drop view         rdr.rcv_glint_journal;
drop view         rdr.rcv_glint_journal_line;
drop index        rdr.xif1gl_interface_journal_line;
drop table        rdr.rr_glint_journal_line;
drop index        rdr.xif2gl_interface_journal_mappi;
drop index        rdr.xif1gl_interface_journal_mappi;
drop table        rdr.rr_glint_journal_mapping;
drop index        rdr.xif1gl_interface_journal;
drop table        rdr.rr_glint_journal;
drop index        rdr.xif1gl_interface_batch_control;
drop table        rdr.rr_glint_batch_control;
drop table        rdr.rr_interface_control;
drop table        rdr.rr_glint_temp_journal;
drop index        rdr.xie1gl_previous_flag;
drop table        rdr.rr_glint_temp_journal_line;
drop index 		  rdr.idx_rr_glint_to_slr_ag_hdr;
alter table		  rdr.rr_glint_to_slr_ag drop constraint "xpk_rr_glint_to_slr_ag";
drop table        rdr.rr_glint_to_slr_ag;
drop sequence     rdr.sqrr_glint_journal_line;
drop sequence     rdr.sqrr_interface_control;
drop sequence     rdr.sqrr_glint_batch_control;
commit;

conn ~fdr_logon
delete from       fdr.fr_general_codes where gc_gct_code_type_id = 'GL';
delete from       fdr.fr_general_code_types where gct_code_type_id = 'GL';
drop package body fdr.pg_common;
drop package      fdr.pg_common;
drop index 		  fdr.idxfr_stan_raw_general_codes;
commit;

-- -----------------------------------------------------------------------------------------
-- purpose : Begin FX uninstall
-- -----------------------------------------------------------------------------------------

conn ~slr_logon

drop view         slr.vbmfxreval_eba_ag_r2_usgaap;
drop view         slr.vbmfxreval_eba_ag_r2_usstat;
drop view         slr.vbmfxreval_eba_ag_r2_ukgaap;
drop view         slr.vbmfxreval_eba_ag_r0_usgaap;
drop view         slr.vbmfxreval_eba_ag_r0_usstat;
drop view         slr.vbmfxreval_eba_ag_r0_ukgaap;
drop view         slr.v_slr_fxreval_parameters;
drop view         slr.v_slr_fxreval_run_values;
drop index 		  slr.idx_jrnl_lines_slrprocess;
drop index 		  SLR.IDX_JH_JRNL_INTPRD_FLAG;
alter table 	  SLR.SLR_JRNL_HEADERS DROP CONSTRAINT PK_JRNL_HDR_P;

delete from       slr.slr_process_source             where upper(sps_db_object_name) like 'VBMFXREVAL_EBA_AG%';
delete from       slr.slr_process_config_detail      where pcd_pc_p_process = 'FXREVALUE' and pcd_pc_config <> 'FXREVALUE';
delete from       slr.slr_process_config             where pc_p_process = 'FXREVALUE' and pc_config <> 'FXREVALUE';
delete from       slr.slr_entity_rates               where er_entity_set in ( 'FX_RULE0' , 'FX_RULE1' , 'FX_RULE2' );
delete from       slr.slr_process_errors             where spe_p_process = 'FXREVALUE';
delete from       slr.slr_hints_sets                 where hs_statement in ( 'FX_REVALUATION_ADJUST' , 'PL_REPATRIATION' , 'PL_RETAINED_EARNINGS' );
commit;

-- ye cleardown
drop view         slr.vbm_ag_retainedearningseba01;
drop view         slr.vbm_ag_retainedearningseba02;
drop view         slr.vbm_ag_retainedearningseba03;
drop view         slr.v_ag_ye_clr_run;
delete from       slr.slr_process_config_detail where pcd_pc_p_process = 'PLRETEARNINGS';
delete from       slr.slr_process_config where pc_p_process = 'PLRETEARNINGS';
delete from       slr.slr_process_source where upper(sps_source_name) like 'BMRETAINEDEARNINGSEBA%';
commit;

conn ~fdr_logon

delete from       fdr.fr_general_lookup where lk_lkt_lookup_type_code = 'FXREVAL_REBAL_ACCTS';
delete from       fdr.fr_general_lookup where lk_lkt_lookup_type_code = 'FXREVAL_GL_MAPPINGS';
delete from       fdr.fr_general_lookup where lk_lkt_lookup_type_code = 'FXREVAL_PARAMETERS';
delete from       fdr.fr_general_lookup where lk_lkt_lookup_type_code = 'FXREVAL_RUN_VALUES';
delete from       fdr.fr_general_lookup_type where lkt_lookup_type_code = 'FXREVAL_REBAL_ACCTS';
delete from       fdr.fr_general_lookup_type where lkt_lookup_type_code = 'FXREVAL_GL_MAPPINGS';
delete from       fdr.fr_general_lookup_type where lkt_lookup_type_code = 'FXREVAL_PARAMETERS';
delete from       fdr.fr_general_lookup_type where lkt_lookup_type_code = 'FXREVAL_RUN_VALUES';
commit;

-- -----------------------------------------------------------------------------------------
-- purpose : Begin Combo Edit uninstall
-- -----------------------------------------------------------------------------------------

conn ~rdr_logon

drop table        rdr.rr_glint_suspense_line;
drop view         rdr.rcv_combination_check_glint;
drop view         rdr.rrv_combination_check_rule;
drop view         rdr.rrv_combination_check_app_rule;

conn ~slr_logon

delete from slr.slr_error_message where em_error_code = 'JL_COMBO';
drop procedure    slr.pcombinationcheck_jlu;
drop view         slr.srv_combination_check_jte;
drop view         slr.scv_combination_check_jlu;

alter table slr.slr_jrnl_line_errors enable all triggers;
alter table slr.slr_entities drop constraint ent_combo_check_flag;
alter table slr.slr_entities drop column ent_combo_check_flag;
commit;

conn ~gui_logon

delete from gui.ui_input_field_value where uif_category_code like 'COMBO%';
delete from gui.ui_gen_lookup_type_properties where ugltp_lookup_type_code = 'COMBO_SUSPENSE';
delete from gui.ui_general_lookup where ugl_lkt_lookup_type_code like 'COMBO%';
delete from gui.ui_field where uf_id between 20000 and 20078;
drop function     gui.fcombinationcheck_jlu;
drop view         gui.ucv_combination_check_jlu;
drop package body gui.pgui_manual_journal;
drop package      gui.pgui_manual_journal;

delete from gui.ui_component where uc_id in (10000, 20000);
commit;

conn ~fdr_logon

delete from       fdr.fr_general_lookup_type where lkt_lookup_type_code = 'COMBO_SUSPENSE';
drop procedure    fdr.pcombinationcheck_hopper;
drop package body fdr.pg_combination_check;
drop package      fdr.pg_combination_check;
drop view         fdr.fcv_combination_check_hopper;
drop view         fdr.fcv_combination_check_suspense;
drop view         fdr.fcv_combination_check_data;
drop table        fdr.fr_combination_check_error;
drop table        fdr.fr_combination_check_input;
commit;
-- -----------------------------------------------------------------------------------------
-- filename: install.sql
-- author  : andrew hall
-- purpose : Script to install the objects which are involved in standardisation.
--         :
-- -----------------------------------------------------------------------------------------

whenever sqlerror exit failure

set serveroutput on
set define ~

define tns_alias    = @oracleTnsAlias@
define stn_user     = @stnUsername@
define stn_password = @stnPassword@
define stn_logon    = ~stn_user/~stn_password@~tns_alias

define fdr_user     = @fdrUsername@
define fdr_password = @fdrPassword@
define fdr_logon    = ~fdr_user/~fdr_password@~tns_alias

define slr_user     = @slrUsername@
define slr_password = @slrPassword@
define slr_logon    = ~slr_user/~slr_password@~tns_alias

define rdr_user     = @rdrUsername@
define rdr_password = @rdrPassword@
define rdr_logon    = ~rdr_user/~rdr_password@~tns_alias

define gui_user     = @guiUsername@
define gui_password = @guiPassword@
define gui_logon    = ~gui_user/~gui_password@~tns_alias

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
@@data/fdr/fr_account_lookup.sql
@@data/fdr/fr_acc_event_type.sql
@@data/fdr/fr_gl_account.sql
@@grants/tables/fdr/fr_general_lookup.sql

conn ~slr_logon

@@tables/slr/slr_fak_bop_amounts.sql
@@tables/slr/slr_fak_bop_amounts_tmp.sql
@@tables/slr/slr_eba_bop_amounts.sql
@@tables/slr/slr_eba_bop_amounts_tmp.sql

delete from slr.slr_entity_proc_group;
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
@@packages/rdr/pg_glint.hdr
@@packages/rdr/pg_glint.bdy
@@grants/packages/rdr/pg_glint.sql
@@packages/rdr/pgc_glint.hdr
@@packages/rdr/pgc_glint.bdy

conn ~slr_logon

update slr.slr_ext_jrnl_types set ejt_client_flag1 = 0 where ejt_client_flag1 is null;
commit;

conn ~gui_logon

@@data/gui/ui_component.sql
@@data/gui/ui_input_field_value.sql
@@data/gui/ui_field.sql



exit
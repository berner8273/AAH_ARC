-- -----------------------------------------------------------------------------------------
-- filename: uninstall.sql
-- author  : andrew hall
-- purpose : Script to uninstall the objects which manage process invocation.
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

conn ~fdr_logon

delete from fdr.fr_entity_schema;
delete from fdr.fr_gaap;
delete from fdr.fr_posting_schema;
delete from fdr.fr_lpg_config;
delete from fdr.fr_account_lookup_param;
delete from fdr.fr_account_lookup;
delete from fdr.fr_posting_driver;
delete from fdr.fr_financial_amount;
delete from fdr.fr_acc_event_type    where aet_input_by not in ( 'FDR Create' , 'SPS' );
delete from fdr.fr_gl_account_lookup where gal_ga_lookup_key != '1';
delete from fdr.fr_gl_account        where ga_account_code   != '1';
commit;

conn ~slr_logon

drop table slr.slr_fak_bop_amounts;
drop table slr.slr_fak_bop_amounts_tmp;
drop table slr.slr_eba_bop_amounts;
drop table slr.slr_eba_bop_amounts_tmp;
commit;

conn ~slr_logon
/*Begin removal of SLR QTD modifications*/

--Replace with baseline package

declare ddl clob;
begin
  ddl := dbms_metadata.get_ddl
    (object_type => 'PACKAGE_SPEC'
    ,name => 'SLR_POST_JOURNALS_PKG_BAK'
    );
  ddl := REPLACE(ddl, UPPER('SLR_POST_JOURNALS_PKG_BAK'), UPPER('SLR_POST_JOURNALS_PKG'));
  ddl := REPLACE(ddl, LOWER('SLR_POST_JOURNALS_PKG_BAK'), LOWER('SLR_POST_JOURNALS_PKG'));
  EXECUTE IMMEDIATE ddl;
  ddl := dbms_metadata.get_ddl
    (object_type => 'PACKAGE_BODY'
    ,name => 'SLR_POST_JOURNALS_PKG_BAK');
  ddl := REPLACE(ddl, UPPER('SLR_POST_JOURNALS_PKG_BAK'), UPPER('SLR_POST_JOURNALS_PKG'));
  ddl := REPLACE(ddl, LOWER('SLR_POST_JOURNALS_PKG_BAK'), LOWER('SLR_POST_JOURNALS_PKG'));
  EXECUTE IMMEDIATE ddl;
end;
/

drop package body slr.slr_post_journals_pkg_bak;
drop package      slr.slr_post_journals_pkg_bak;

--Remove custom columns

ALTER TABLE SLR.SLR_EBA_BALANCES_ROLLBACK 
 DROP  (     
  EDB_TRAN_QTD_BALANCE, 
    EDB_BASE_QTD_BALANCE, 
    EDB_LOCAL_QTD_BALANCE, 
    EDB_PERIOD_QTR);

ALTER TABLE SLR.SLR_EBA_DAILY_BALANCES
 DROP  (     
  EDB_TRAN_QTD_BALANCE, 
    EDB_BASE_QTD_BALANCE, 
    EDB_LOCAL_QTD_BALANCE, 
    EDB_PERIOD_QTR);

ALTER TABLE SLR.SLR_EBA_DAILY_BALANCES_ARC
 DROP  (     
  EDBA_TRAN_QTD_BALANCE, 
    EDBA_BASE_QTD_BALANCE, 
    EDBA_LOCAL_QTD_BALANCE);

ALTER TABLE SLR.SLR_FAK_BALANCES_ROLLBACK
 DROP  (
  FDB_TRAN_QTD_BALANCE, 
    FDB_BASE_QTD_BALANCE, 
    FDB_LOCAL_QTD_BALANCE, 
    FDB_PERIOD_QTR);

ALTER TABLE SLR.SLR_FAK_DAILY_BALANCES
 DROP  (     
  FDB_TRAN_QTD_BALANCE, 
    FDB_BASE_QTD_BALANCE, 
    FDB_LOCAL_QTD_BALANCE, 
    FDB_PERIOD_QTR);

ALTER TABLE SLR.SLR_FAK_DAILY_BALANCES_ARC
 DROP  (     
  FDBA_TRAN_QTD_BALANCE, 
    FDBA_BASE_QTD_BALANCE, 
    FDBA_LOCAL_QTD_BALANCE);

ALTER TABLE SLR.SLR_FAK_LAST_BALANCES
 DROP  (     
  FLB_TRAN_QTD_BALANCE, 
    FLB_BASE_QTD_BALANCE, 
    FLB_LOCAL_QTD_BALANCE, 
    FLB_PERIOD_QTR);

ALTER TABLE SLR.SLR_LAST_BALANCES
 DROP  (     
  LB_TRAN_QTD_BALANCE, 
    LB_BASE_QTD_BALANCE, 
    LB_LOCAL_QTD_BALANCE, 
    LB_PERIOD_QTR);

--Drop custom view
drop view v_slr_journal_lines;

--Restore baseline view and drop modified view
drop view v_slr_jrnl_lines_unposted_jt;
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

/*End removal of SLR QTD modifications*/

drop package body slr.slr_pkg;
drop package      slr.slr_pkg;

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

conn ~stn_logon
revoke select on stn.business_type      from slr;
revoke select on stn.insurance_policy   from slr;
revoke select on stn.execution_type     from slr;

exit
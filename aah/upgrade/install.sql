-- -----------------------------------------------------------------------------------------
-- filename: install.sql
-- author  : andrew hall
-- purpose : Script to install AAH custom upgrades
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
define arc_logon=~9
define oraServiceName=~10
define arcPwd=~11

/* Check AAH upgrade versions - do not remove */
conn ~sys_logon
@@sys/00001_check_upgrade_versions.sql

/************************************** Begin AAH custom upgrades *****************************************************/

conn ~stn_logon
@@stn/archive_stn_insert.sql

conn ~gui_logon

conn ~fdr_logon
@@fdr/FR_ARCHIVE_CTL_Insert.sql
@@fdr/archive_fdr_insert.sql
@@fdr/archive_fdr_custom_pkg.sql

conn ~rdr_logon
conn ~sys_logon as sysdba

    DECLARE space_exists number;
	BEGIN
		select count(*) into space_exists from dba_tablespaces where tablespace_name = 'ARC_DATA';
		IF (space_exists = 0) THEN
			EXECUTE IMMEDIATE '
			create bigfile tablespace ARC_DATA
			datafile ''/oradata/~oraServiceName/datafile/ARC_DATA_FILE.dbf''    
			size 10g autoextend on next 1g maxsize 20G';
		END IF;
	END;
	/
	DECLARE user_exists number;
	BEGIN
		select count(*) into user_exists from dba_users where username='ARC';
		IF (user_exists = 0) THEN
        EXECUTE IMMEDIATE '
			create user ARC identified by "~arcPwd"
				default tablespace ARC_DATA
				temporary tablespace temp
				quota unlimited on ARC_DATA
				profile default
				account unlock';
		END IF;
	END;
    /
	grant create session to ARC;
	grant CONNECT to ARC;
	ALTER USER ARC DEFAULT ROLE CONNECT;

conn ~sys_logon as sysdba
@@sys/archive_grants.sql

conn ~arc_logon
@@arc/arc_setup.sql

conn ~sys_logon as sysdba
@@sys/archive_grants_post.sql

/********************************* End AAH custom upgrades ********************************************************/

/* Refresh grants to aah_read_only and aah_rdr roles - do not remove */
conn ~sys_logon as sysdba
@@sys/99999_refresh_aah_roles.sql

/* recompile any packages or procedures that are not compiled */
@@sys/recompile_objects.sql

/* Register upgrade - do not remove */
conn ~fdr_logon
@@fdr/99999_register_upgrade.sql

exit
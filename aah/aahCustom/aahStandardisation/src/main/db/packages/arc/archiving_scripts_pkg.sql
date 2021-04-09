--------------------------------------------------------
--  DDL for Package ARCHIVING_SCRIPTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "ARC"."ARCHIVING_SCRIPTS_PKG" AUTHID DEFINER AS
---------------------------------------------------------------------------------
-- Id:          $Id: RUN_ARCHIVING_SCRIPTS_PKG.sql,v 1 2012/11/08 18:03:51 abulgajewska Exp $
--
-- Description: Package contains procedure which allows to execute given script with definer user grants.
-- As archiving module has been created in FDR schema it is crucial to have this package defined for every
-- other schema which should be affected by archiving process.
-- With this packaged created and granted to user FDR, archiving process can execute procedure pRUN_ARCHIVING_SCRIPTS
-- with priviliges of user who has created it.
---------------------------------------------------------------------------------
-- History:
-- 2012/11/08: basic version of package created
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- Types
---------------------------------------------------------------------------------
TYPE QUERY_TABLE_ARRAY IS TABLE OF LONG;
TYPE PART_ROW IS RECORD (PARTITION_NAME user_objects.subobject_name%type, PARTITION_TYPE all_objects.object_type%type);
TYPE str_array IS TABLE OF PART_ROW;

---------------------------------------------------------------------------------
-- PROCEDURES
---------------------------------------------------------------------------------

PROCEDURE PRUN_ARCHIVE_SCRIPTS(QUERY LONG);

PROCEDURE PGRANT_PRIVILIGES_FOR_TABLE( pTableName in VARCHAR2,
                                       pUserName in VARCHAR2);

FUNCTION fFindPartitions                ( pSchemaName             in VARCHAR2,
                                          pTableName              in VARCHAR2,
                                          pwhere                  in varchar2 default null
                                        ) return str_array PIPELINED;

-------------------------------------------------------------------------------------------------------------------------

END ARCHIVING_SCRIPTS_PKG;

/

--------------------------------------------------------
--  DDL for Package Body ARCHIVING_SCRIPTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "ARC"."ARCHIVING_SCRIPTS_PKG" AS

---------------------------------------------------------------------------------
-- Private package attributes
---------------------------------------------------------------------------------
gv_emsg     VARCHAR2(4000);
gv_ecode    NUMBER := -20999;
gc_nl		VARCHAR2(4) := chr(10);

PROCEDURE PRUN_ARCHIVE_SCRIPTS(QUERY LONG) IS

    s_proc_name VARCHAR2(80) := 'ARC.ARCHIVING_SCRIPTS_PKG.PRUN_ARCHIVE_SCRIPTS';
    gv_ecode 	NUMBER := -20999;
    gv_emsg VARCHAR(10000);

BEGIN
    --dbms_output.enable;
    --dbms_output.put_line(query);
    execute immediate QUERY;

    EXCEPTION
		WHEN OTHERS THEN
			gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
			RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);

END PRUN_ARCHIVE_SCRIPTS;

PROCEDURE PGRANT_PRIVILIGES_FOR_TABLE( pTableName in VARCHAR2,
                                       pUserName in VARCHAR2) IS

    s_proc_name VARCHAR2(80) := 'ARC.ARCHIVING_SCRIPTS_PKG.PGRANT_PRIVILIGES_FOR_TABLE';
    gv_ecode 	NUMBER := -20999;
    gv_emsg VARCHAR(10000);

    vTableExistFlag INTEGER := 0;

    vSql VARCHAR2(1000);

BEGIN
    SELECT count(*) INTO vTableExistFlag FROM USER_TABLES WHERE TABLE_NAME = pTableName;

    IF vTableExistFlag > 0
    THEN
        vSql := 'GRANT ALL ON ' ||  pTableName || ' TO ' || pUserName  ;
        execute immediate vSql;
    END IF;

    EXCEPTION
		WHEN OTHERS THEN
			gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
			RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);

END PGRANT_PRIVILIGES_FOR_TABLE;

-- -----------------------------------------------------------------------------------------------
-- Function:   	fFindPartitions
-- Description: Function return list of partitions
-- Notes:
-- -----------------------------------------------------------------------------------------------
FUNCTION fFindPartitions (	pSchemaName       in varchar2,
							pTableName        in varchar2,
							pwhere varchar2 default null
							)
return str_array PIPELINED
is
	s_proc_name varchar2(50):= 'ARC_ARCHIVING_PKG.fFindPartitions';

	v_sql varchar2(32700);
	V_ROW PART_ROW;
	TYPE cursor_ref IS REF CURSOR;
	c1 cursor_ref;
begin
    --dbms_output.enable();
	v_sql := 'SELECT subobject_name, object_type FROM all_objects ao, '||pSchemaName||'.'||pTableName || ' ';

	IF pwhere is not null THEN
		v_sql := v_sql || pwhere ||' and dbms_rowid.rowid_object(' || pTableName || '.rowid) = ao.data_object_id';
	ELSE
		v_sql := v_sql||'where dbms_rowid.rowid_object('||pTableName || '.rowid) = ao.data_object_id';
	END IF;

	v_sql := v_sql||' and ao.object_name = ''' || pTableName || '''  group by subobject_name, object_type';
    --dbms_output.put_line(v_sql);

	OPEN C1 FOR V_SQL;
	LOOP
		FETCH C1 INTO V_ROW;
		EXIT WHEN C1%NOTFOUND;
		PIPE ROW (V_ROW);
	END LOOP;
	CLOSE C1;

	return ;

	EXCEPTION
        WHEN OTHERS THEN
			--gv_ecode := SQLCODE;
            gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
            RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);

end fFindPartitions;

END ARCHIVING_SCRIPTS_PKG;
/
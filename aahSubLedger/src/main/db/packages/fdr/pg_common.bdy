Create or Replace Package Body fdr.pg_common
/* Package Body for Common Routines. */
As

/* Local Constants. */
lgcUnitName  Constant all_objects.object_name%TYPE := 'PG_COMMON';

/* Public Procedure to log debug messages. */
Procedure pLogDebug(
  pinMessage in Varchar2)
Is
/* Constants. */
lcUnitName  Constant all_procedures.procedure_name%TYPE := 'pLogDebug';

myHeader  Varchar2(32);
myMessage Varchar2(32767);

Begin
  If gDebug_Log Then
    fdr.PR_Error (
      a_type => gcErrorEventType_Info,
      a_text => pinMessage,
      a_category => gcErrorCategory_Tech,
      a_error_source => lgcUnitName || '.' || lcUnitName,
      a_error_table => NULL,
      a_row => NULL,
      a_error_field => NULL,
      a_stage => user,
      a_technology => gcErrorTechnology_PLSQL,
      a_value => NULL,
      a_entity => NULL,
      a_book => NULL,
      a_security => NULL,
      a_source_system => NULL,
      a_client_key => NULL,
      a_client_ver => NULL,
      a_lpg_id => NULL
    );
  End If;
  If gDebug_DBMSOutput Then
    myHeader := to_char(systimestamp,'YYYY-MM-DD HH24:MI:SS.FF') || ' : ';
    myMessage := pinMessage;
    While length(myMessage) > 0 Loop
      dbms_output.put_line(myHeader || substr(myMessage,1,gcMaxSize_DBMSOutputLine - length(myHeader)));
      myMessage := substr(myMessage,gcMaxSize_DBMSOutputLine + 1 - length(myHeader));
    End Loop;
  End If;
End pLogDebug;
Procedure pLogDebug(
  pinMessage in Clob)
Is
/* Constants. */
lcUnitName  Constant all_procedures.procedure_name%TYPE := 'pLogDebug';

myOffset    Pls_Integer := 1;
myChunkSize Pls_Integer := 32767;
myChunk     Varchar2(32767);

Begin
  If gDebug_Log or gDebug_DBMSOutput Then
    /* Read the input message CLOB in chunks of the maximum size for Varchar2. */
    While sys.dbms_lob.getlength(pinMessage) > myOffset Loop
      sys.dbms_lob.read(pinMessage,myChunkSize,myOffset,myChunk);
      myOffset := myOffset + myChunkSize;
      /* Log the debug message chunk. */
      pLogDebug(myChunk);
    End Loop;
  End If;
End pLogDebug;

/* Public Procedure to execute dynamic SQL. */
Procedure pExecuteSQL(
  pinSQL in Varchar2)
Is
/* Constants. */
lcUnitName Constant all_procedures.procedure_name%TYPE := 'pExecuteSQL';
Begin
  pLogDebug(pinMessage => pinSQL);
  Execute Immediate pinSQL;
  gRowCount := SQL%ROWCOUNT;
  pLogDebug(pinMessage => '  Row Count = '||to_char(gRowCount));
Exception
When Others Then
  /* Log the generated SQL statement. */
  fdr.PR_Error (
    a_type => gcErrorEventType_Info,
    a_text => pinSQL,
    a_category => gcErrorCategory_Tech,
    a_error_source => lgcUnitName || '.' || lcUnitName,
    a_error_table => NULL,
    a_row => NULL,
    a_error_field => NULL,
    a_stage => user,
    a_technology => gcErrorTechnology_PLSQL,
    a_value => NULL,
    a_entity => NULL,
    a_book => NULL,
    a_security => NULL,
    a_source_system => NULL,
    a_client_key => NULL,
    a_client_ver => NULL,
    a_lpg_id => NULL
  );
  Raise;
End pExecuteSQL;
Procedure pExecuteSQL(
  pinSQL in Clob)
Is
/* Constants. */
lcUnitName Constant all_procedures.procedure_name%TYPE := 'pExecuteSQL';

myCursor Pls_Integer;

Begin
  pLogDebug(pinMessage => pinSQL);
  /* Use dbms_sql for dynamic SQL that is larger than Varchar2 maximum size. */
  myCursor := sys.dbms_sql.open_cursor;
  sys.dbms_sql.parse(
    c => myCursor,
    statement => pinSQL,
    language_flag => sys.dbms_sql.native);
  gRowCount := sys.dbms_sql.execute(c => myCursor);
  sys.dbms_sql.close_cursor(c => myCursor);
  pLogDebug(pinMessage => '  Row Count = '||to_char(gRowCount));
Exception
When Others Then
  If sys.dbms_sql.is_open(c => myCursor) Then
    sys.dbms_sql.close_cursor(c => myCursor);
  End If;
  /* Log the generated SQL statement. */
  fdr.PR_Error (
    a_type => gcErrorEventType_Info,
    a_text => pinSQL,
    a_category => gcErrorCategory_Tech,
    a_error_source => lgcUnitName || '.' || lcUnitName,
    a_error_table => NULL,
    a_row => NULL,
    a_error_field => NULL,
    a_stage => user,
    a_technology => gcErrorTechnology_PLSQL,
    a_value => NULL,
    a_entity => NULL,
    a_book => NULL,
    a_security => NULL,
    a_source_system => NULL,
    a_client_key => NULL,
    a_client_ver => NULL,
    a_lpg_id => NULL
  );
  Raise;
End pExecuteSQL;


End pg_common;
/
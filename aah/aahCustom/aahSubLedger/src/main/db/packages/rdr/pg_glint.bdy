create or replace package body     pg_glint AS
/* Package Body for GL Interface. */


/* Local Constants. */
lgcUnitName            Constant all_objects.object_name%TYPE := 'PG_GLINT';

/* Local Variables. */
lgControlID RR_INTERFACE_CONTROL.rgic_id%TYPE;
lgRowCount  Pls_Integer;

/* Private Procedure to return data type conversions for use in dynamic SQL. */
Procedure pConvertDataType(
  pupString      in out Varchar2,
  pinSourceType  in     all_tab_columns.data_type%TYPE,
  pinSourceLen   in     all_tab_columns.data_length%TYPE,
  pinSourcePre   in     all_tab_columns.data_precision%TYPE,
  pinTargetType  in     all_tab_columns.data_type%TYPE,
  pinTargetLen   in     all_tab_columns.data_type%TYPE,
  pinTargetPre   in     all_tab_columns.data_precision%TYPE,
  pinDateFormat  in     Varchar2,
  pinLookupKeyID in     fdr.fr_general_lookup.lk_lookup_key_id%TYPE)
As
/* Constants. */
lcUnitName Constant all_procedures.procedure_name%TYPE := 'pConvertDataType';

Begin
  /* Check the source data type with the target data type and cast (i.e. convert) if necessary.
      Explicit conversions can be done as "casts" within the configuration in match key 5 (for source line to target line) or lookup value 6 (for source line to batch control)
      e.g. cast(%% as Varchar2(23)). This will be required if wanting to map using specific date formats for example.
      Some basic checking is performed here but the true test will be when the query runs using the configured values. */
  If pinSourceType = FDR.PG_COMMON.gcDataType_Number and pinTargetType = FDR.PG_COMMON.gcDataType_Varchar Then --Number to Varchar
    If pinSourceLen + Case When pinSourcePre > 0 Then pinSourcePre + 1 Else 0 End > pinTargetLen Then
      sys.dbms_standard.raise_application_error(-20000,'Cannot convert ' || pinSourceType || ' to ' || pinTargetType || ' : Source precision is too large for Target : ID=' || to_char(pinLookupKeyID),False);
    End If;
    pupString := 'cast(' || pupString || ' as ' || FDR.PG_COMMON.gcDataType_Varchar || '(' || pinTargetLen || '))';
  ElsIf pinSourceType = FDR.PG_COMMON.gcDataType_Varchar and pinTargetType = FDR.PG_COMMON.gcDataType_Number Then --Varchar to Number
    pupString := 'cast(' || pupString || ' as ' || FDR.PG_COMMON.gcDataType_Number || '(' || pinTargetLen || ',' || pinTargetPre || '))';
  ElsIf pinSourceType = FDR.PG_COMMON.gcDataType_Timestamp and pinTargetType = FDR.PG_COMMON.gcDataType_Date Then --Timestamp to Date
    pupString := 'cast(' || pupString || ' as ' || FDR.PG_COMMON.gcDataType_Date || ')';
  ElsIf pinSourceType = FDR.PG_COMMON.gcDataType_Date and pinTargetType = FDR.PG_COMMON.gcDataType_Timestamp Then --Date to Timestamp
    pupString := 'cast(' || pupString || ' as ' || FDR.PG_COMMON.gcDataType_Timestamp || ')';
  ElsIf pinSourceType = FDR.PG_COMMON.gcDataType_Timestamp and pinTargetType = FDR.PG_COMMON.gcDataType_Varchar Then --Timestamp to Varchar
    /* Length of Timestamp on Oracle is 32 characters. If Varchar is not big enough then use the date format parameter. */
    If pinTargetLen >= length(pinDateFormat) and pinTargetLen < FDR.PG_COMMON.gcMaxSize_Timestamp Then
      /* Cast using date format parameter. */
      pupString := 'to_char(' || pupString || ',' ||  sys.dbms_assert.enquote_literal(pinDateFormat) || ')';
    Elsif pinTargetLen >= FDR.PG_COMMON.gcMaxSize_Timestamp Then
      /* Target is big enough so cast directly. */
      pupString := 'cast(' || pupString || ' as ' || FDR.PG_COMMON.gcDataType_Varchar || '(' || pinTargetLen || ')';
    Else
      sys.dbms_standard.raise_application_error(-20000,'Cannot convert ' || pinSourceType || ' to ' || pinTargetType || '. Target column size not compatible for source : ID=' || to_char(pinLookupKeyID),False);
    End If;
  ElsIf pinSourceType = FDR.PG_COMMON.gcDataType_Date and pinTargetType = FDR.PG_COMMON.gcDataType_Varchar Then --Date to Varchar
    /* Length of Date on Oracle is 18 characters. If Varchar is not big enough then use the date format parameter. */
    If pinTargetLen >= length(pinDateFormat) and pinTargetLen < FDR.PG_COMMON.gcMaxSize_Date Then
      /* Cast using date format parameter. */
      pupString := 'to_char(' || pupString || ',' ||  sys.dbms_assert.enquote_literal(pinDateFormat) || ')';
    Elsif pinTargetLen >= FDR.PG_COMMON.gcMaxSize_Date Then
      /* Target is big enough so cast directly. */
      pupString := 'cast(' || pupString || ' as ' || FDR.PG_COMMON.gcDataType_Varchar || '(' || pinTargetLen || ')';
    Else
      sys.dbms_standard.raise_application_error(-20000,'Cannot convert ' || pinSourceType || ' to ' || pinTargetType || '. Target column size not compatible for source : ID=' || to_char(pinLookupKeyID),False);
    End If;
  ElsIf pinSourceType = FDR.PG_COMMON.gcDataType_Varchar and pinTargetType = FDR.PG_COMMON.gcDataType_Date Then --Varchar to Date
    pupString := 'cast(' || pupString || ' as ' || FDR.PG_COMMON.gcDataType_Date || ')';
  ElsIf pinSourceType = FDR.PG_COMMON.gcDataType_Varchar and pinTargetType = FDR.PG_COMMON.gcDataType_Timestamp Then --Varchar to Timestamp
    pupString := 'cast(' || pupString || ' as ' || FDR.PG_COMMON.gcDataType_Timestamp || ')';
  ElsIf pinSourceType = FDR.PG_COMMON.gcDataType_Varchar and pinTargetType = FDR.PG_COMMON.gcDataType_Varchar and pinSourceLen > pinTargetLen Then --Varchar(Large) to Varchar(Small)
    /* Silently truncate the string such that it will fit the target column length. */
    pupString := 'substr(' || pupString || ',1,' || pinTargetLen || ')';
  ElsIf pinSourceType in (FDR.PG_COMMON.gcDataType_Timestamp,FDR.PG_COMMON.gcDataType_Date) and pinTargetType = FDR.PG_COMMON.gcDataType_Number Then --Timestamp/Date to Number
    sys.dbms_standard.raise_application_error(-20000,'Cannot convert ' || pinSourceType || ' to ' || pinTargetType || ' : ID=' || to_char(pinLookupKeyID),False);
  End If;
End pConvertDataType;

/* Public Function to return the next batch control sequence number. */
Function fGetBatchControlID
Return rr_glint_batch_control.rgbc_id%TYPE
Parallel_Enable
As
Begin
  Return sqrr_glint_batch_control.nextval;
End fGetBatchControlID;

/* Public Procedure to process posted journals for sending to a GL.
   This would be called with the EPG and journal identifiers in the custom GUI exit when a user authorises/posts the journals manually.
   This would be called with the EPG from a batch process. */
Procedure pProcess(
  pinLoadNamePrefix in rr_glint_batch_control.rgbc_load_name%TYPE Default 'AAH',
  pinCustomProcess  in all_objects.object_name%TYPE Default NULL,
  pinEPGID          in slr.slr_entity_proc_group.epg_id%TYPE Default NULL,
  pinArrayJournalID in Varchar2 Default NULL)
Is
/* Constants. */
lcUnitName               Constant all_procedures.procedure_name%TYPE := 'pProcess';

lcEntity_GLINTBatch      Constant all_objects.object_name%TYPE := 'RR_GLINT_BATCH_CONTROL';
lcEntity_GLINTJournal    Constant all_objects.object_name%TYPE := 'RR_GLINT_JOURNAL';
lcAttribute_LoadName     Constant all_tab_columns.column_name%TYPE := 'RGBC_LOAD_NAME';
lcPackage_Custom         Constant all_objects.object_name%TYPE := 'PGC_GLINT';

lcGCType_GLINT           Constant fdr.fr_general_codes.gc_gct_code_type_id%TYPE := 'GL';
lcJournalAction_Ignore   Constant fdr.fr_general_codes.gc_client_text2%TYPE := 'IGNORE';
lcJournalAction_Defer    Constant fdr.fr_general_codes.gc_client_text2%TYPE := 'DEFER';
lcSeparator              Constant Char(1) := '_';

lcSpecialCharacter       Constant Varchar2(20) := '%%';
lcDefault                Constant all_tab_columns.data_default%TYPE := 'DEFAULT';

/* Variables. */
myCount             Pls_Integer;
myCount2            Pls_Integer;
myJournalCount      Pls_Integer;
myLoadName          Varchar2(200);
mySQLHintInsert     Varchar2(200);
mySQLHintSelect     Varchar2(200);
mySQLHintTempInsert Varchar2(200);
mySQLHintTempSelect Varchar2(200);
myAggregation       Boolean;

/* Dynamic SQL Variables. */
mySQL_JT            Varchar2(3000);
mySQL_JLT           Varchar2(20000);
mySQL_BC            Varchar2(4000);
mySQL_JL            Varchar2(10000);
mySelect_JL         Varchar2(2000);
mySelect_JLT        Varchar2(2000);
mySelect_JLT_Agg    Varchar2(3000);
mySelect_JLT_NonAgg Varchar2(3000);
mySelect_JL_Agg     Varchar2(2000);
mySelect_BC         Varchar2(500);
mySelect_BC_Agg     Varchar2(500);
mySelect_BC_NonAgg  Varchar2(500);
myFrom_JLT          Varchar2(3000);
myWhere_JLT         Varchar2(500);
myWhere_JLT_In      Varchar2(500);
myWhere_JLT_Ex      Varchar2(500);
myHaving_JL         Varchar2(500);
myGroup_JLT         Varchar2(2000);
myGroup_BC          Varchar2(1000);
myGroup_BC2         Varchar2(1000);
myGroup_BC3         Varchar2(1000);
myGroup_JL          Varchar2(2000);
myHaving_JLT        Varchar2(1000);
myDefault           Varchar2(100);
myTemp              Varchar2(500);
myTemp2             Varchar2(500);
myTemp3             Varchar2(500);

Begin

  dbms_application_info.set_module(
    module_name => lgcUnitName || '.' || lcUnitName,
    action_name => 'Start');

  /* When this procedure is called we have already previously committed the transaction by posting the journal(s) into the slr.slr_jrnl_headers table.
     Therefore this process can commit/rollback as necessary.
     When specific journal identifiers are provided to the procedure, then use those to identify what to send to the GL, otherwise send everything has hasn't been sent before (or marked for retry). */

  FDR.PG_COMMON.pLogDebug(pinMessage => 'Start GL Interface');
  FDR.PG_COMMON.pLogDebug(pinMessage => '  Load Name Prefix=' || pinLoadNamePrefix);
  FDR.PG_COMMON.pLogDebug(pinMessage => '  Custom Process=' || pinCustomProcess);
  FDR.PG_COMMON.pLogDebug(pinMessage => '  EPG=' || pinEPGID);
  FDR.PG_COMMON.pLogDebug(pinMessage => '  Journal ID List=' || pinArrayJournalID);

  /* Insert the control record for this processing instance. */
  Select sqRR_INTERFACE_CONTROL.nextval into PG_GLINT.lgControlID from dual;
  myJournalCount := 0;
  dbms_application_info.set_action('Insert into RR_INTERFACE_CONTROL');
  Insert into rr_interface_control (
      rgic_id,
      rgic_count,
      rgic_status_flag,
      input_user,
      input_time,
      modified_user,
      modified_time
  ) Values (
      PG_GLINT.lgControlID,
      myJournalCount,
      FDR.PG_COMMON.gcStatusFlag_Unprocessed,
      user,
      sysdate,
      user,
      sysdate
  );
  Commit;
  FDR.PG_COMMON.pLogDebug(pinMessage => 'Interface Control ID='||to_char(PG_GLINT.lgControlID));

  dbms_application_info.set_action('Build Journal Query');
  /* Use parallel hints if this is a batch run. */
  If pinArrayJournalID is null Then
    mySQLHintTempInsert := gSQLHint_InsertTempBatch;
    mySQLHintTempSelect := gSQLHint_SelectTempBatch;
    mySQLHintInsert := gSQLHint_InsertBatch;
    mySQLHintSelect := gSQLHint_SelectBatch;
  Else
    mySQLHintTempInsert := gSQLHint_InsertTempMADJ;
    mySQLHintTempSelect := gSQLHint_SelectTempMADJ;
    mySQLHintInsert := gSQLHint_InsertMADJ;
    mySQLHintSelect := gSQLHint_SelectMADJ;
  End If;

  /* Collect the journals (headers) that are required to be sent to the GL in this run and put the list into a temporary table.
     The journals can be further filtered outside by way of configuring the RCV_GLINT_JOURNAL configurable view.
     For batch runs:
       Collect those journals that have not been procesed UNION ALL journals that have been processed but had an error,
       then were subsequently marked for resubmission (event_status='U').
     For manual runs:
       Collect only the journals that have been authorised (we assume these newly created journals have not yet been sent).
       Filter out any that are marked as deferred (until the batch run). */
  mySQL_JT := 'Insert ' || mySQLHintTempInsert || ' into rr_glint_temp_journal (jh_jrnl_id,jh_jrnl_date,jh_jrnl_entity,jh_jrnl_epg_id,jh_jrnl_type,jh_jrnl_internal_period_flag,jh_jrnl_description,previous_flag,lkt_lookup_type_code)'
           || ' Select ' || mySQLHintTempSelect || ' jh.jh_jrnl_id,jh.jh_jrnl_date,jh.jh_jrnl_entity,jh.jh_jrnl_epg_id,jh.jh_jrnl_type,jh.jh_jrnl_internal_period_flag,jh.jh_jrnl_description,jh.previous_flag,lkt_lookup_type_code'
           || ' from ('
           || ' Select jh_jrnl_id,jh_jrnl_date,jh_jrnl_entity,jh_jrnl_epg_id,jh_jrnl_type,jh_jrnl_internal_period_flag,jh_jrnl_description,' || sys.dbms_assert.enquote_literal(FDR.PG_COMMON.gcYesOrNo_No) || ' as previous_flag'
           || '   from rcv_glint_journal';
  If pinEPGID is not null Then
    mySQL_JT := mySQL_JT
             || ' where jh_jrnl_epg_id = ' || sys.dbms_assert.enquote_literal(pinEPGID);
  Else
    mySQL_JT := mySQL_JT
             || ' where 1=1';
  End If;
  If pinArrayJournalID is not null Then
    mySQL_JT := mySQL_JT
             || '   and jh_jrnl_id IN (' || pinArrayJournalID || ')';
  Else
    mySQL_JT := mySQL_JT
             || '   and not exists (Select Null'
             || '                     from rr_glint_journal_mapping'
             || '                     join rr_glint_journal on rgj_id = rgjm_rgj_id'
             || '                    where jh_jrnl_id = rgjm_input_jrnl_id)'
             || ' Union All'
             /* If the configuration is (probably wrongly) setup to split a GL journal across batches (and therefore AAH journals), ensure that this only collects the distinct AAH journals. */
             || ' Select jh_jrnl_id, max(jh_jrnl_date),max(jh_jrnl_entity), max(jh_jrnl_epg_id),max(jh_jrnl_type),max(jh_jrnl_internal_period_flag),max(jh_jrnl_description),' || sys.dbms_assert.enquote_literal(FDR.PG_COMMON.gcYesOrNo_Yes) || ' as previous_flag'
             || '   from rcv_glint_journal'
             || '   join rr_glint_journal_mapping on jh_jrnl_id = rgjm_input_jrnl_id'
             || '   join rr_glint_journal on rgj_id = rgjm_rgj_id'
             || '                        and event_status= ' || sys.dbms_assert.enquote_literal(FDR.PG_COMMON.gcStatusFlag_Unprocessed)
             || '  group by jh_jrnl_id';
  End If;
  mySQL_JT := mySQL_JT
           || ') jh'
           || ' join slr.slr_ext_jrnl_types on jh.jh_jrnl_type = ejt_type'
           || ' join fdr.fr_general_codes on ejt_client_flag1 = gc_general_code_id'
           || ' join fdr.fr_general_lookup_type on gc_client_text1 = lkt_lookup_type_code'
           || ' where gc_gct_code_type_id = ' || sys.dbms_assert.enquote_literal(lcGCType_GLINT)
           || '   and gc_client_text2 <> ' || sys.dbms_assert.enquote_literal(lcJournalAction_Ignore);
  If pinArrayJournalID is not null Then
    /* When authorising journals, do not include those marked for deferral. */
    mySQL_JT := mySQL_JT
             || ' and gc_client_text2 <> ' || sys.dbms_assert.enquote_literal(lcJournalAction_Defer);
  End If;

  /* Insert the Journal Headers that should be processed by the interface into a temporary table. */
  dbms_application_info.set_action('Insert into RR_GLINT_TEMP_JOURNAL');
  FDR.PG_COMMON.pExecuteSQL(pinSQL => mySQL_JT);
  myJournalCount := PG_GLINT.lgRowCount;

  /* Run the custom process if one has been defined. */
  If pinCustomProcess is not null Then
    dbms_application_info.set_action('Execute Custom SQL:' || sys.dbms_assert.sql_object_name(lcPackage_Custom || '.' || pinCustomProcess));
    FDR.PG_COMMON.pExecuteSQL(pinSQL => 'Begin ' || sys.dbms_assert.sql_object_name(lcPackage_Custom || '.' || pinCustomProcess) || '(pinControlID => ' || PG_GLINT.lgControlID || '); End;');
  End If;

  /* Collect the distinct mapping structures to use from the pending journals that were written to the temporary table. */
  dbms_application_info.set_action(NULL);
  For cRec1 in (Select distinct(lkt_lookup_type_code) as lkt_lookup_type_code
                  from rr_glint_temp_journal) Loop
    dbms_application_info.set_action('Generating SQL for '||cRec1.lkt_lookup_type_code);
    /* For each mapping structure, collect each of the configuration records to be able to
       construct the dynamic SQL that will insert into the various interface tables as follows:
         rr_glint_temp_journal_line (configurable mappings defined in fr_general_lookup - not including those attributes that are sourced from the GLINT tables)
         rr_glint_batch_control (hard-coded from temp table with some configuration mappings defined in fr_general_lookup)
         rr_glint_journal (hard-coded from temp table)
         rr_glint_journal_line (copied from the temp table with configurable mappings defined in fr_general_lookup)
         rr_glint_journal_mapping (hard-coded from temp table) */
    myCount := 0;
    For cRec2 in (Select gl1.lk_lookup_key_id,                            --Unique identifier of configuration
                         gl1.lk_match_key1,                               --Source schema name
                         gl1.lk_match_key2,                               --Source object name
                         gl1.lk_match_key3,                               --Source column name
                         gl1.lk_match_key4,                               --Default value if source is null or to pass if aggregating
                         gl1.lk_match_key5,                               --Select condition for source column e.g. "Case when *** < 0 then *** else 0 end"
                         gl1.lk_match_key6,                               --Filter source data e.g. "jl_segment_1='IFRS_MAIN'" or filter before writing to output e.g. "rgjl_entered_cr <> 0"
                         gl1.lk_match_key7,                               --Whether to aggregate by this source column
                         gl1.lk_match_key8,                               --Aggregate exception filter e.g. "ea_account_type in ('C')"
                         gl1.lk_lookup_value1,                            --Target schema
                         gl1.lk_lookup_value2,                            --Target object
                         gl1.lk_lookup_value3,                            --Target column
                         gl1.lk_lookup_value4,                            --Aggregate for batch control
                         gl1.lk_lookup_value5,                            --Target batch attribute
                         gl1.lk_lookup_value6,                            --Select condition for target column when mapping to batch attribute
                         sc.data_type as "sType",                         --Source column type
                         case when sc.data_type = FDR.PG_COMMON.gcDataType_Number
                              then to_char(sc.data_precision)
                              else to_char(sc.data_length) end as "sLen", --Length of source column
                         sc.data_scale as "sPre",                         --Precision of source column
                         tc.column_name,                                  --Target column name
                         tc.data_type as "tType",                         --Target column type
                         case when tc.data_type = FDR.PG_COMMON.gcDataType_Number
                              then to_char(tc.data_precision)
                              else to_char(tc.data_length) end as "tLen", --Length of target column
                         tc.data_scale as "tPre",                         --Precision of target column
                         count(*) over (partition by gl1.lk_lookup_value1, gl1.lk_lookup_value2, gl1.lk_lookup_value3) as "count_target", --Count the unique target columns.
                         count(*) over (partition by gl1.lk_match_key1, gl1.lk_match_key2, gl1.lk_match_key3, gl1.lk_match_key4, gl1.lk_match_key5, gl1.lk_match_key7, gl1.lk_lookup_value1, gl1.lk_lookup_value2, gl1.lk_lookup_value3) as "count_target2", --Count the unique source columns for the target columns.
                         row_number() over (partition by gl1.lk_match_key1, gl1.lk_match_key2, gl1.lk_match_key3, gl1.lk_match_key4, gl1.lk_match_key5, gl1.lk_match_key7, gl1.lk_lookup_value1, gl1.lk_lookup_value2, gl1.lk_lookup_value3 order by to_number(gl1.lk_match_key10)) as "order_target", --Order of targets.
                         gl2.lk_lookup_value1 as orig_lookup_value1,
                         gl2.lk_lookup_value2 as orig_lookup_value2,
                         gl2.lk_lookup_value3 as orig_lookup_value3
                    from fdr.fr_general_lookup gl1
                    left join all_tab_columns sc on upper(sc.owner) = upper(gl1.lk_match_key1)
                                                and upper(sc.table_name) = upper(gl1.lk_match_key2)
                                                and upper(sc.column_name) = upper(gl1.lk_match_key3)
                                                and lk_match_key3 is not null  --only join when sourcing from a column value
                    left join all_tab_columns tc on upper(tc.owner) = upper(gl1.lk_lookup_value1)
                                                and upper(tc.table_name) = upper(gl1.lk_lookup_value2)
                                                and upper(tc.column_name) = upper(gl1.lk_lookup_value3)
                    join /* Collect the first occurrence of the source column (in the case that the same source is used in different mappings) in the configuration to determine the target column. */
                         (Select lk_match_key1,
                                 lk_match_key2,
                                 lk_match_key3,
                                 lk_lookup_value1,
                                 lk_lookup_value2,
                                 lk_lookup_value3
                            from (Select row_number() over (partition by lk_match_key1, lk_match_key2, lk_match_key3, lk_match_key4 order by to_number(lk_match_key10)) rn,
                                         lk_match_key1,
                                         lk_match_key2,
                                         lk_match_key3,
                                         lk_lookup_value1,
                                         lk_lookup_value2,
                                         lk_lookup_value3
                                    from fdr.fr_general_lookup
                                   where lk_lkt_lookup_type_code = cRec1.lkt_lookup_type_code
                                     and lk_active = FDR.PG_COMMON.gcActiveInactive_Active)
                           where rn = 1) gl2 on gl1.lk_match_key1 = gl2.lk_match_key1
                                            and gl1.lk_match_key2 = gl2.lk_match_key2
                                            and gl1.lk_match_key3 = gl2.lk_match_key3
                   where gl1.lk_lkt_lookup_type_code = cRec1.lkt_lookup_type_code
                     and gl1.lk_active = FDR.PG_COMMON.gcActiveInactive_Active
                   order by to_number(gl1.lk_match_key10)) Loop   --The ordering is necessary to ensure the load name (myLoadName) is populated correctly (also used for ordering the configuration within the GUI and helpful for debugging since the generated query will be in the same order each time).
      myCount := myCount + 1;

      /* Check the target column exists. */
      If cRec2.column_name is null Then
        sys.dbms_standard.raise_application_error(-20000,'The target column does not exist : ID=' || to_char(cRec2.lk_lookup_key_id),False);
      End If;

      /* Ensure that any duplicate target columns are coming from the same source columns in the configuration. */
      If cRec2."count_target" <> cRec2."count_target2" Then
        sys.dbms_standard.raise_application_error(-20000,'There are ' || cRec2."count_target" || ' occurrences of the target column in the configuration with ' || cRec2."count_target2" || ' different sources : ID=' || to_char(cRec2.lk_lookup_key_id),False);
      End If;

      /* Initialise the SQL variables the first time round each configuration. */
      If myCount = 1 Then
        mySQL_JLT := 'Insert ' || mySQLHintInsert || ' into rr_glint_temp_journal_line('
                  || 'jh_jrnl_id,jl_jrnl_line_number,rgj_id,rgbc_id,rgbc_process_type,rgbc_load_type,previous_flag,aggregate_line_flag,';
        mySQL_BC := 'Insert into rr_glint_batch_control('
                 || 'rgbc_id,rgbc_line_count,rgbc_rgic_id,rgbc_process_type,rgbc_load_type,input_time,input_user,modified_time,modified_user,';
        mySQL_JL := 'Insert ' || mySQLHintInsert || ' into rr_glint_journal_line('
                 || 'rgjl_id,rgjl_rgj_id,rgjl_rgj_rgbc_id,rgjl_aah_journal,rgjl_aah_journal_line,input_time,input_user,modified_time,modified_user,';
        myLoadName := sys.dbms_assert.enquote_literal(pinLoadNamePrefix);
        mySelect_JL := '';
        mySelect_JLT_Agg := '';
        mySelect_JLT_NonAgg := '';
        mySelect_JL_Agg := '';
        mySelect_JLT := '';
        mySelect_BC := '';
        mySelect_BC_Agg := '';
        mySelect_BC_NonAgg := '';
        /* Collect the journals corresponding to the configuration that is to be processed along with their respective lines.
           If a source attribute comes from another Sub-Ledger source view, then this will be built upon later when the attributes are read. */
        myFrom_JLT := ' from rr_glint_temp_journal j'
               || ' join rcv_glint_journal on j.jh_jrnl_id = rcv_glint_journal.jh_jrnl_id'
               || '                       and j.jh_jrnl_epg_id = rcv_glint_journal.jh_jrnl_epg_id'
               || '                       and j.jh_jrnl_entity = rcv_glint_journal.jh_jrnl_entity'
               || '                       and j.jh_jrnl_date = rcv_glint_journal.jh_jrnl_date'
               || ' join rcv_glint_journal_line on j.jh_jrnl_id = rcv_glint_journal_line.jl_jrnl_hdr_id'
               || '                            and j.jh_jrnl_epg_id = rcv_glint_journal_line.jl_epg_id'
               || '                            and j.jh_jrnl_entity = rcv_glint_journal_line.jl_entity'
               || '                            and j.jh_jrnl_date = rcv_glint_journal_line.jl_effective_date'
               || ' join slr.slr_entities on j.jh_jrnl_entity = slr_entities.ent_entity'
               || ' join slr.slr_ext_jrnl_types on rcv_glint_journal.jh_jrnl_type = slr_ext_jrnl_types.ejt_type'
               || ' join fdr.fr_general_codes on slr_ext_jrnl_types.ejt_client_flag1 = gc_general_code_id'
               || '                          and gc_gct_code_type_id = ' || sys.dbms_assert.enquote_literal(lcGCType_GLINT);
        myWhere_JLT := ' where gc_client_text1 = ' || sys.dbms_assert.enquote_literal(cRec1.lkt_lookup_type_code);
        myWhere_JLT_In := '';
        myWhere_JLT_Ex := '';
        myHaving_JL := '';
        myGroup_JLT := '';
        myGroup_BC := '';
        myGroup_BC2 := '';
        myGroup_BC3 := '';
        myGroup_JL := '';
        myHaving_JLT := '';
        myAggregation := False;
      End If;

      /* Append the configuration record to the relevant SQL part. */

      /* Determine the default value to use if supplied. */
      myDefault := '';
      If cRec2.lk_match_key4 is null Then --no value
          /* No need to cast the null value to the target data type on Oracle, so just use the NULL keyword. */
          myDefault := FDR.PG_COMMON.gcDefault_NULL;
      Else
        /* If default value starts with %% then this is a function value, otherwise it is a literal value that should be single quoted. */
        If substr(cRec2.lk_match_key4,1,length(lcSpecialCharacter)) = lcSpecialCharacter Then
          myDefault := replace(cRec2.lk_match_key4,lcSpecialCharacter); --function value
        Else
          myDefault := sys.dbms_assert.enquote_literal(cRec2.lk_match_key4); --literal value
        End If;
      End If;

      /* Determine the value to select. */
      myTemp  := NULL; -- Source Condition(Source attribute/default - coalesced with "is null" value)
      myTemp2 := NULL; -- Source Condition(SUM of myTemp)
      myTemp3 := NULL; -- Source Condition(SUM of Original Target attribute)
      If cRec2.lk_match_key2 = lcDefault Then --use the default value
        myTemp := myDefault;
      Else --use the column value
        myTemp := sys.dbms_assert.enquote_name(cRec2.lk_match_key2) || '.' || sys.dbms_assert.enquote_name(cRec2.lk_match_key3);
      End If;

      /* Check the target is valid. */
      If myTemp is null Then
        sys.dbms_standard.raise_application_error(-20000,'Could not parse configuration lookup record for select criteria : ID=' || to_char(cRec2.lk_lookup_key_id),False);
      End If;

      /* Journal Line Group. */
      If cRec2.lk_match_key7 is not null Then
        myAggregation := True;
      End If;

      If cRec2.lk_match_key7 = FDR.PG_COMMON.gcYesOrNo_Yes Then
        /* Only need to add to the grouping when match key 2 is an attribute. */
        If cRec2.lk_match_key2 <> lcDefault Then
          myGroup_JLT := myGroup_JLT || myTemp || ',';
        End If;
        myGroup_BC := myGroup_BC || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value3) || ',';
      End If;

      /* Use the default value if column value is null. */
      If cRec2.lk_match_key2 <> lcDefault and cRec2.lk_match_key4 is not null Then
        myTemp := 'coalesce(' || myTemp || ',' || myDefault || ')';
      End If;

      /* Convert the source to the target data type if not specifying logic. */
      If cRec2.lk_match_key5 is null Then
        pConvertDataType(
          pupString => myTemp,
          pinSourceType => cRec2."sType",
          pinSourceLen => cRec2."sLen",
          pinSourcePre => cRec2."sPre",
          pinTargetType => cRec2."tType",
          pinTargetLen => cRec2."tLen",
          pinTargetPre => cRec2."tPre",
          pinDateFormat => FDR.PG_COMmon.gcDateFormat,
          pinLookupKeyID => cRec2.lk_lookup_key_id);
      End If;

      /* Determine if an aggregated attribute is required and modify the selected value with the aggregate function (SUM). */
      If cRec2.lk_match_key7 = FDR.PG_COMMON.gcYesOrNo_No Then
        myTemp2 := 'SUM(' || myTemp || ')';
      End If;

      /* Value to use is within custom logic. */
      myTemp3 := 'SUM('||cRec2.orig_lookup_value3||')';
      If cRec2.lk_match_key5 is not null Then
        myTemp := replace(cRec2.lk_match_key5,lcSpecialCharacter,myTemp);
        If myTemp2 is not null Then
          myTemp2 := replace(cRec2.lk_match_key5,lcSpecialCharacter,myTemp2);
        End If;
        myTemp3 := replace(cRec2.lk_match_key5,lcSpecialCharacter,myTemp3);
      End If;

      /* Ensure that in the case of multiple configs of source/target, that only one of them is added to the relevant part of the Journal Line SQL statements.
         The difference for these will be mapping the same source attribute to different batch control attributes. */
      If cRec2."order_target" = 1 Then

        /* Determine whether the mapping attribute is from a parent entity and add to the relevant part of the SQL.
           For the temporary journal line insert, these columns are omitted from the SQL as it is too early for those. */
        If upper(cRec2.lk_match_key2) not in (upper(lcEntity_GLINTBatch), upper(lcEntity_GLINTJournal)) Then

          /* Journal Line Insert. */
          mySQL_JL := mySQL_JL || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value3) || ',';

          /* Journal Line Temp Insert. */
          mySQL_JLT := mySQL_JLT || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value3) || ',';

          /* Journal Line Temp Select. */
          mySelect_JLT_NonAgg := mySelect_JLT_NonAgg || myTemp || ' as ' || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value3) || ',';
          mySelect_JLT := mySelect_JLT || 'rr_glint_temp_journal_line.' || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value3) || ',';

          /* Journal Line Select. */
          mySelect_JL := mySelect_JL || 'rr_glint_temp_journal_line.' || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value3) || ',';

          /* Determine whether to select for an aggregate query. */
          If cRec2.lk_match_key7 = FDR.PG_COMMON.gcYesOrNo_No Then
            mySelect_JLT_Agg := mySelect_JLT_Agg || myTemp2;
            mySelect_JL_Agg := mySelect_JL_Agg || myTemp3 || ' as ' || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value3) || ',';
          ElsIf cRec2.lk_match_key7 is null Then
            /* Use the default value if not grouping by this attribute. */
            /* If a source column was provided for this configuration record but another configuration record aggregates the query, then this source column is ignored as it is really an error.
              We potentially don't yet know if this is an error since we are in the middle of looping through each configuration record.
              If another configuration record does aggregate the query (lk_match_key7 = 'Y'), then for this one, the lk_match_key7 should be 'N'. */
            mySelect_JLT_Agg := mySelect_JLT_Agg || myDefault;
            mySelect_JL_Agg := mySelect_JL_Agg || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value3) || ',';
            myGroup_JL := myGroup_JL || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value3) || ',';
          Else --Yes (grouping by this attribute).
            mySelect_JLT_Agg := mySelect_JLT_Agg || myTemp;
            mySelect_JL_Agg := mySelect_JL_Agg || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value3) || ',';
            myGroup_JL := myGroup_JL || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value3) || ',';
          End If;
          mySelect_JLT_Agg := mySelect_JLT_Agg || ' as ' || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value3) || ',';

        Else
          If cRec2.lk_match_key7 is not null Then
            sys.dbms_standard.raise_application_error(-20000,'Cannot aggregate by an attribute for a parent output table : ID=' || to_char(cRec2.lk_lookup_key_id),False);
          End If;
          /* Journal Line Insert. */
          mySQL_JL := mySQL_JL || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value3) || ',';

          /* Journal Line Select - Attribute is from a parent table. */
          mySelect_JL := mySelect_JL || myTemp || ' as ' || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value3) || ',';
        End If;
      End If;

      /* Add Source Data Filter. */
      If cRec2.lk_match_key6 is not null Then
        If cRec2.lk_match_key7 = FDR.PG_COMMON.gcYesOrNo_No Then
          /* Add to the "having" clause (SUM). */
          myHaving_JLT := myHaving_JLT || ' and SUM(' || myTemp || ') ' || cRec2.lk_match_key6;
          myHaving_JL := myHaving_JL || ' and SUM(' || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value3) || ') ' || cRec2.lk_match_key6;
        ElsIf cRec2.lk_match_key7 = FDR.PG_COMMON.gcYesOrNo_Yes Then
          /* Add to the "having" clause. */
          myHaving_JLT := myHaving_JLT || ' and ' || myTemp || ' ' || cRec2.lk_match_key6;
          myHaving_JL := myHaving_JL || ' and ' || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value3) || ' ' || cRec2.lk_match_key6;
        Else
          /* Not a grouping attribute, therefore add to the "where" clause to filter out the source records before writing to the temp journal line table. */
          myWhere_JLT := myWhere_JLT || ' and ' || cRec2.lk_match_key6;
        End If;
      End If;

      /* Journal Line Temp Group Exception. */
      If cRec2.lk_match_key8 is not null then
        myWhere_JLT_Ex := myWhere_JLT_Ex ||' and ' || cRec2.lk_match_key8;
        myWhere_JLT_In := myWhere_JLT_In ||' and not (' || cRec2.lk_match_key8 || ')';
      End If;

      /* Batch Control. */
      If cRec2.lk_lookup_value4 is not null and cRec2.lk_lookup_value5 is null Then
        sys.dbms_standard.raise_application_error(-20000,'The batch target key has been provided without a batch target column : ID=' || to_char(cRec2.lk_lookup_key_id),False);
      End If;
      If cRec2.lk_lookup_value5 is not null and cRec2.lk_lookup_value4 is null Then
        sys.dbms_standard.raise_application_error(-20000,'The batch target column has been provided without a batch target key : ID=' || to_char(cRec2.lk_lookup_key_id),False);
      End If;

      myTemp := sys.dbms_assert.enquote_name(cRec2.lk_lookup_value3);
      myTemp2 := 'SUM (' || myTemp || ')';

      /* Check the data types when mapping journal line attributes (source) to batch control attributes (target). */
      If cRec2.lk_lookup_value5 is not null Then
        myCount2 := 0;
        For cRec3 in (Select sc.data_type as "sType",                         --Source column type
                             case when sc.data_type = FDR.PG_COMMON.gcDataType_Number
                                  then to_char(sc.data_precision)
                                  else to_char(sc.data_length) end as "sLen", --Length of source column
                             sc.data_scale as "sPre",                         --Precision of source column
                             tc.column_name,                                  --Target column name
                             tc.data_type as "tType",                         --Target column type
                             case when tc.data_type = FDR.PG_COMMON.gcDataType_Number
                                  then to_char(tc.data_precision)
                                  else to_char(tc.data_length) end as "tLen", --Length of target column
                             tc.data_scale as "tPre"                          --Precision of target column
                        from all_tab_columns sc
                        join all_tab_columns tc on upper(tc.owner) = upper(FDR.PG_COMMON.gcSchema_RDR)
                                               and upper(tc.table_name) = upper(lcEntity_GLINTBatch)
                                               and upper(tc.column_name) = upper(cRec2.lk_lookup_value5)
                       where upper(sc.owner) = upper(cRec2.lk_lookup_value1)
                         and upper(sc.table_name) = upper(cRec2.lk_lookup_value2)
                         and upper(sc.column_name) = upper(cRec2.lk_lookup_value3)) Loop
          myCount2 := myCount2 + 1;

          /* When custom formatting has not been provided. */
          /* Convert the source to the target data type. */
          If cRec2.lk_lookup_value6 is null Then
            pConvertDataType(
              pupString => myTemp,
              pinSourceType => cRec3."sType",
              pinSourceLen => cRec3."sLen",
              pinSourcePre => cRec3."sPre",
              pinTargetType => cRec3."tType",
              pinTargetLen => cRec3."tLen",
              pinTargetPre => cRec3."tPre",
              pinDateFormat => FDR.PG_COMMON.gcDateFormat,
              pinLookupKeyID => cRec2.lk_lookup_key_id);
          End If;

          /* Value to use is within a condition clause. */
          If cRec2.lk_lookup_value6 is not null Then
            myTemp := replace(cRec2.lk_lookup_value6,lcSpecialCharacter,myTemp);
            myTemp2 := replace(cRec2.lk_lookup_value6,lcSpecialCharacter,myTemp2);
          End If;
        End Loop;

        /* Check the batch control target column exists. */
        If myCount2 <> 1 Then
          sys.dbms_standard.raise_application_error(-20000,'The batch target column does not exist : ID=' || to_char(cRec2.lk_lookup_key_id),False);
        End If;
      End If;

      If cRec2.lk_lookup_value4 = FDR.PG_COMMON.gcYesOrNo_Yes Then
        If cRec2.lk_match_key7 = FDR.PG_COMMON.gcYesOrNo_No Then
          /* Match Key 7 must be Yes or NULL when aggregating by an attribute used for batch control. */
          sys.dbms_standard.raise_application_error(-20000,'The batch key must be included as an aggregation in lk_match_key7 : ID=' || to_char(cRec2.lk_lookup_key_id),False);
        End If;
        mySelect_BC_Agg := mySelect_BC_Agg || myTemp || ' as ' || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value5) || ',';
        mySelect_BC_NonAgg := mySelect_BC_NonAgg || myTemp || ' as ' || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value5) || ',';
        If cRec2.lk_lookup_value5 <> lcAttribute_LoadName Then
          mySQL_BC := mySQL_BC || cRec2.lk_lookup_value5 || ',';
          mySelect_BC := mySelect_BC || 'rr_glint_temp_journal_line.' || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value5) || ' as ' || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value5) || ',';
          myGroup_BC3 := myGroup_BC3 || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value5) || ',';
        Else
          /* Update the load name according to the configuration. */
            myLoadName := myLoadName || ' || ' || sys.dbms_assert.enquote_literal(lcSeparator) || ' || ' || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value3);
        End If;
        myGroup_BC2 := myGroup_BC2 || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value3) || ',';
      ElsIf cRec2.lk_lookup_value4 = FDR.PG_COMMON.gcYesOrNo_No Then
        If cRec2.lk_lookup_value5 <> lcAttribute_LoadName Then
          mySQL_BC := mySQL_BC || cRec2.lk_lookup_value5 || ',';
          mySelect_BC := mySelect_BC || 'SUM(rr_glint_temp_journal_line.' || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value5) || ') as ' || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value5) || ',';
          mySelect_BC_Agg := mySelect_BC_Agg || myTemp2 || ' as ' || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value5) || ',';
          mySelect_BC_NonAgg := mySelect_BC_NonAgg || myTemp || ' as ' || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value5) || ',';
        Else
          mySelect_BC_Agg := mySelect_BC_Agg || myTemp2 || ' as ' || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value5) || ',';
          mySelect_BC_NonAgg := mySelect_BC_NonAgg || myTemp || ' as ' || sys.dbms_assert.enquote_name(cRec2.lk_lookup_value5) || ',';
        End If;
      ElsIf cRec2.lk_lookup_value4 is not null Then
        sys.dbms_standard.raise_application_error(-20000,'Invalid value in lk_lookup_value4. Must be either ' || FDR.PG_COMMON.gcYesOrNo_Yes || ' or ' || FDR.PG_COMMON.gcYesOrNo_No || ' : ID=' || to_char(cRec2.lk_lookup_key_id),False);
      End If;

    End Loop; --General Lookup

    /* If no configuration definitions were found for the type, then error. */
    If myCount = 0 Then
      sys.dbms_standard.raise_application_error(-20000,'No configuration found : Lookup Type Code=' || cRec1.lkt_lookup_type_code,False);
    End If;

    /* Append the load name to the batch control statement. */
    If myLoadName is not null Then
      mySQL_BC := mySQL_BC || lcAttribute_LoadName || ')';
      mySelect_BC := mySelect_BC || myLoadName || ' as ' || sys.dbms_assert.enquote_name(lcAttribute_LoadName);
      myGroup_BC3 := myGroup_BC3 || myLoadName;
    End If;

    /* Tidyup the relevant SQL parts (remove trailing commas). */
    mySQL_JLT := trim(trailing ',' from mySQL_JLT) || ')';
    mySQL_JL := trim(trailing ',' from mySQL_JL) || ')';
    mySelect_JL_Agg := trim(trailing ',' from mySelect_JL_Agg);
    mySelect_JL := trim(trailing ',' from mySelect_JL);
    mySelect_JLT := trim(trailing ',' from mySelect_JLT);
    mySelect_JLT_Agg := trim(trailing ',' from mySelect_JLT_Agg);
    mySelect_JLT_NonAgg := trim(trailing ',' from mySelect_JLT_NonAgg);
    mySelect_BC_Agg := trim(trailing ',' from mySelect_BC_Agg);
    mySelect_BC_NonAgg := trim(trailing ',' from mySelect_BC_NonAgg);
    myGroup_JLT := trim(trailing ',' from myGroup_JLT);
    myGroup_BC := trim(trailing ',' from myGroup_BC);
    myGroup_BC2 := trim(trailing ',' from myGroup_BC2);
    myGroup_BC3 := trim(trailing ',' from myGroup_BC3);
    myGroup_JL := trim(trailing ',' from myGroup_JL);

    /* Concatenate the SQL Parts collected from the configuration depending on whether this is a summary (aggregation) or detailed configuration.
       When aggregating, only include the non-aggregated query part if there are exceptions (myWhere_JLT_Ex). */

    /* Journal Line Temp. */
    mySQL_JLT := mySQL_JLT
              || ' Select ' || mySQLHintSelect || ' '
              || 'rr_glint_temp_journal_line.jh_jrnl_id as "jh_jrnl_id", rr_glint_temp_journal_line.jl_jrnl_line_number as "jl_jrnl_line_number",';
    If myAggregation Then
      mySQL_JLT := mySQL_JLT || 'rr_glint_temp_journal_line.gc_client_text4 || ' || sys.dbms_assert.enquote_literal(lcSeparator) || ' || to_char(' || ' Max(PG_GLINT.fGetBatchControlID) over (partition by ' || myGroup_BC2 || ')) as "rgj_id",';
    Else
      mySQL_JLT := mySQL_JLT || 'rr_glint_temp_journal_line.gc_client_text4 || ' || sys.dbms_assert.enquote_literal(lcSeparator) || ' || to_char(rr_glint_temp_journal_line.jh_jrnl_id) as "rgj_id",';
    End If;
    mySQL_JLT := mySQL_JLT
              || 'Max(PG_GLINT.fGetBatchControlID) over (partition by ' || myGroup_BC2 || ') as "rgbc_id",'
              || 'rr_glint_temp_journal_line.gc_client_text3 as "rgbc_process_type",'
              || 'rr_glint_temp_journal_line.gc_client_text5 as "rgbc_load_type",'
              || 'rr_glint_temp_journal_line.previous_flag as "previous_flag",'
              || 'rr_glint_temp_journal_line.aggregate_line_flag as "aggregate_line_flag",'
              || mySelect_JLT
              || ' from (';
    If Not(myAggregation) or (myAggregation and myWhere_JLT_Ex is not null) Then
      mySQL_JLT := mySQL_JLT
                || 'Select '
                || 'j.jh_jrnl_id,jl_jrnl_line_number,gc_client_text3,gc_client_text4,gc_client_text5,j.previous_flag,'
                || sys.dbms_assert.enquote_literal(FDR.PG_COMMON.gcYesOrNo_No) || ' as aggregate_line_flag,'
                || mySelect_JLT_NonAgg
                || myFrom_JLT
                || myWhere_JLT
                || myWhere_JLT_Ex;
      /* When aggregating and there are exceptions then union join the queries together. */
      If myAggregation Then
        mySQL_JLT := mySQL_JLT || ' Union All ';
      End If;
    End If;
    If myAggregation Then
      mySQL_JLT := mySQL_JLT
                || 'Select '
                || 'j.jh_jrnl_id,NULL as jl_jrnl_line_number,gc_client_text3,gc_client_text4,gc_client_text5,j.previous_flag,'
                || sys.dbms_assert.enquote_literal(FDR.PG_COMMON.gcYesOrNo_Yes) || ' as aggregate_line_flag,'
                || mySelect_JLT_Agg
                || myFrom_JLT
                || myWhere_JLT
                || myWhere_JLT_In
                || ' group by ' || myGroup_JLT || ',j.jh_jrnl_id,gc_client_text3,gc_client_text4,gc_client_text5,j.previous_flag '
                || ' having 1 = 1 ' || myHaving_JLT;
    End If;
    mySQL_JLT := mySQL_JLT
              || ' ) rr_glint_temp_journal_line';

    /* Batch Control. */
    mySQL_BC := mySQL_BC
             || ' Select ' || mySQLHintSelect || ' '
             || 'rr_glint_temp_journal_line.rgbc_id as "rgbc_id",'
             || 'count(*) as "rgbc_line_count",'
             || to_char(PG_GLINT.lgControlID) || ' as "rgbc_rgic_id",'
             || 'rr_glint_temp_journal_line.rgbc_process_type as "rgbc_process_type",'
             || 'rr_glint_temp_journal_line.rgbc_load_type as "rgbc_load_type",'
             || 'sysdate as "input_time",'
             || 'user as "input_user",'
             || 'sysdate as "modified_time",'
             || 'user as "modified_user",'
             || mySelect_BC
             || ' from (';
    If Not(myAggregation) or (myAggregation and myWhere_JLT_Ex is not null) Then
      /* When aggregating journal lines, only include this non-aggregated query if there are exceptions (myWhere_JLT_Ex). */
      mySQL_BC := mySQL_BC
               || 'Select rgbc_id,rgbc_process_type,rgbc_load_type,'
               || mySelect_BC_NonAgg
               || ' from rr_glint_temp_journal_line'
               || ' where aggregate_line_flag = ' || sys.dbms_assert.enquote_literal(FDR.PG_COMMON.gcYesOrNo_No);
      If myAggregation Then
        mySQL_BC := mySQL_BC
                 || ' Union All ';
      End If;
    End If;
    If myAggregation Then
      mySQL_BC := mySQL_BC
               || 'Select rgbc_id,rgbc_process_type,rgbc_load_type,'
               || mySelect_BC_Agg
               || ' from rr_glint_temp_journal_line'
               || ' where aggregate_line_flag = ' || sys.dbms_assert.enquote_literal(FDR.PG_COMMON.gcYesOrNo_Yes)
               || ' group by ' || myGroup_BC || ',rgbc_id,rgbc_process_type,rgbc_load_type,' || myGroup_BC2;
    End If;
    mySQL_BC := mySQL_BC || ' ) rr_glint_temp_journal_line'
             || ' group by ' || myGroup_BC3 || ',rgbc_id,rgbc_process_type,rgbc_load_type';

    /* Journal Line. */
    mySQL_JL := mySQL_JL
             || ' Select ' || mySQLHintSelect || ' '
             || 'sqrr_glint_journal_line.nextval as "rgjl_id",'
             || 'rr_glint_temp_journal_line.rgj_id as "rgjl_rgj_id",'
             || 'rr_glint_temp_journal_line.rgbc_id as "rgjl_rgj_rgbc_id",'
             || 'rr_glint_temp_journal_line.jh_jrnl_id as "jh_jrnl_id",'
             || 'rr_glint_temp_journal_line.jl_jrnl_line_number as "jl_jrnl_line_number",'
             || 'sysdate as "input_time",'
             || 'user as "input_user",'
             || 'sysdate as "modified_time",'
             || 'user as "modified_user",'
             || mySelect_JL --Same as mySelect_JLT but with parent table attributes.
             || ' from (';
    If Not(myAggregation) or (myAggregation and myWhere_JLT_Ex is not null) Then
      mySQL_JL := mySQL_JL
               || ' Select rgbc_id,rgj_id,jh_jrnl_id,jl_jrnl_line_number,'
               || mySelect_JLT
               || ' from rr_glint_temp_journal_line'
               || ' where aggregate_line_flag = ' || sys.dbms_assert.enquote_literal(FDR.PG_COMMON.gcYesOrNo_No);
      If myAggregation Then
        mySQL_JL := mySQL_JL
                 || ' Union All ';
      End If;
    End If;
    If myAggregation Then
      mySQL_JL := mySQL_JL
               || 'Select rgbc_id,rgj_id,NULL as jh_jrnl_id,NULL as jl_jrnl_line_number,'
               || mySelect_JL_Agg
               || ' from rr_glint_temp_journal_line where aggregate_line_flag = ' || sys.dbms_assert.enquote_literal(FDR.PG_COMMON.gcYesOrNo_Yes)
               || ' group by ' || myGroup_JL || ',rgbc_id,rgj_id'
               || ' having 1 = 1' || myHaving_JL;
    End If;
    mySQL_JL := mySQL_JL || ' ) rr_glint_temp_journal_line'
             || ' join rr_glint_batch_control on rr_glint_batch_control.rgbc_id = rr_glint_temp_journal_line.rgbc_id'
             || ' join rr_glint_journal on rr_glint_journal.rgj_id = rr_glint_temp_journal_line.rgj_id'
             || '                      and rr_glint_journal.rgj_rgbc_id = rr_glint_temp_journal_line.rgbc_id';

    /* Insert the Temporary Journal Line Records. */
    dbms_application_info.set_action('Insert into RR_GLINT_TEMP_JOURNAL_LINE');
    FDR.PG_COMMON.pExecuteSQL(pinSQL => mySQL_JLT);

    /* Insert the Batch Control Records. */
    dbms_application_info.set_action('Insert into RR_GLINT_BATCH_CONTROL');
    FDR.PG_COMMON.pExecuteSQL(pinSQL => mySQL_BC);

    /* Insert the Journal Records. */
    dbms_application_info.set_action('Insert into RR_GLINT_JOURNAL');
    FDR.PG_COMMON.pExecuteSQL(pinSQL => 'Insert ' || mySQLHintInsert || ' into rr_glint_journal('
                                     || '  rgj_id,'
                                     || '  rgj_rgbc_id,'
                                     || '  event_status,'
                                     || '  input_time,'
                                     || '  input_user,'
                                     || '  modified_time,'
                                     || '  modified_user)'
                                     || ' Select ' || mySQLHintSelect || ' rgj_id as "rgj_id",'
                                     || '        rgbc_id as "rgbc_id",'
                                     || sys.dbms_assert.enquote_literal(FDR.PG_COMMON.gcStatusFlag_Processed) || ' as "event_status",'
                                     || '        sysdate as "input_time",'
                                     || '        user as "input_user",'
                                     || '        sysdate as "modified_time",'
                                     || '        user as "modified_user"'
                                     || '   from rr_glint_temp_journal_line'
                                     || '  group by rgbc_id,rgj_id');

    /* Insert the Journal Mapping Records. */
    dbms_application_info.set_action('Insert into RR_GLINT_JOURNAL_MAPPING');
    FDR.PG_COMMON.pExecuteSQL(pinSQL => 'Insert ' || mySQLHintInsert || ' into rr_glint_journal_mapping('
                                     || '  rgjm_rgbc_id,'
                                     || '  rgjm_input_jrnl_id,'
                                     || '  rgjm_rgj_id,'
                                     || '  input_time,'
                                     || '  input_user,'
                                     || '  modified_time,'
                                     || '  modified_user)'
                                     || ' Select ' || mySQLHintSelect || ' rgbc_id as "rgbc_id",'
                                     || '        jh_jrnl_id as "jh_jrnl_id",'
                                     || '        rgj_id as "rgj_id",'
                                     || '        sysdate as "input_time",'
                                     || '        user as "input_user",'
                                     || '        sysdate as "modified_time",'
                                     || '        user as "modified_user"'
                                     || '   from rr_glint_temp_journal_line'
                                     || '  group by rgbc_id, jh_jrnl_id, rgj_id');

    /* Insert the Journal Line Records. */
    dbms_application_info.set_action('Insert into RR_GLINT_JOURNAL_LINE');
    FDR.PG_COMMON.pExecuteSQL(pinSQL => mySQL_JL);

    /* Update the previous journal records (for prior batches) to resubmitted. */
    dbms_application_info.set_action('Merge into RR_GLINT_JOURNAL');
    FDR.PG_COMMON.pExecuteSQL(pinSQL => 'Merge into rr_glint_journal a using ('
                                     || '  Select rr_glint_journal.rgj_rgbc_id, rr_glint_journal.rgj_id'
                                     || '    from rr_glint_temp_journal_line'
                                     || '    join rr_glint_journal_mapping on rr_glint_journal_mapping.rgjm_input_jrnl_id = rr_glint_temp_journal_line.jh_jrnl_id'
                                     || '                                 and rr_glint_journal_mapping.rgjm_rgbc_id <> rr_glint_temp_journal_line.rgbc_id'
                                     || '    join rr_glint_journal on rr_glint_journal.rgj_rgbc_id = rr_glint_journal_mapping.rgjm_rgbc_id'
                                     || '                         and rr_glint_journal.rgj_id = rr_glint_journal_mapping.rgjm_rgj_id'
                                     || '                         and rr_glint_journal.event_status = ' || sys.dbms_assert.enquote_literal(FDR.PG_COMMON.gcStatusFlag_Unprocessed)
                                     || '   where rr_glint_temp_journal_line.previous_flag = ' || sys.dbms_assert.enquote_literal(FDR.PG_COMMON.gcYesOrNo_Yes)
                                     || '   group by rr_glint_journal.rgj_rgbc_id, rr_glint_journal.rgj_id) b'
                                     || '  on (a.rgj_rgbc_id = b.rgj_rgbc_id'
                                     || '    and a.rgj_id = b.rgj_id)'
                                     || '  When Matched Then Update'
                                     || '    Set a.event_status = ' || sys.dbms_assert.enquote_literal(FDR.PG_COMMON.gcStatusFlag_Resubmitted));

  End Loop; --LookupTypeCode

  /* Update the control record. */
  dbms_application_info.set_action('Update RR_INTERFACE_CONTROL');
  Update rr_interface_control
     Set rgic_status_flag = FDR.PG_COMMON.gcStatusFlag_Processed,
         rgic_count = myJournalCount,
         modified_user = user,
         modified_time = sysdate
   where rgic_id = PG_GLINT.lgControlID;

  Commit;

  FDR.PG_COMMON.pLogDebug(pinMessage => 'End GL Interface');
  dbms_application_info.set_action(NULL);

Exception
When Others Then
  Rollback;

  /* Update the interface control record. */
  Update RR_INTERFACE_CONTROL
     Set rgic_status_flag =FDR.PG_COMMON.gcStatusFlag_Error,
         rgic_count = myJournalCount,
         modified_user = user,
         modified_time = sysdate
   where rgic_id = PG_GLINT.lgControlID;
  Commit;

  /* Log the error. */
  PR_Error (
    a_type => FDR.PG_COMMON.gcErrorEventType_Error,
    a_text => dbms_utility.format_error_backtrace,
    a_category => FDR.PG_COMMON.gcErrorCategory_Tech,
    a_error_source => lgcUnitName || '.' || lcUnitName,
    a_error_table => gcEntity_InterfaceControl,
    a_row => PG_GLINT.lgControlID,
    a_error_field => NULL,
    a_stage => user,
    a_technology => FDR.PG_COMMON.gcErrorTechnology_PLSQL,
    a_value => NULL,
    a_entity => NULL,
    a_book => NULL,
    a_security => NULL,
    a_source_system => NULL,
    a_client_key => NULL,
    a_client_ver => NULL,
    a_lpg_id => NULL
  );

  /* Raise an error back to the caller. */
  Raise;
End pProcess;

End pg_glint;
/
create or replace package body fdr.pg_combination_check
/* Package Body for Code Combination Checking. */
As

/* Local Constants. */
lgcUnitName  Constant all_objects.object_name%TYPE := 'PG_COMBINATION_CHECK';

/* Combination Check Procedure. */
Procedure pCombinationCheck (
  pinObjectName   in     all_objects.object_name%TYPE,
  pinFilter       in     Varchar2,
  pinBusinessDate in     fr_global_parameter.gp_todays_bus_date%TYPE,
  poutErrorCount     out Pls_Integer)
As

/* Constants. */
lcUnitName              Constant all_procedures.procedure_name%TYPE := 'pCombinationCheck';

lcTableName_Input       Constant all_objects.object_name%TYPE := 'FR_COMBINATION_CHECK_INPUT';
lcTableName_Error       Constant all_objects.object_name%TYPE := 'FR_COMBINATION_CHECK_ERROR';
lcAction_Fail           Constant fr_general_lookup.lk_lookup_value1%TYPE := 'FAIL';
lcAction_Check          Constant fr_general_lookup.lk_lookup_value1%TYPE := 'CHECK';
lcCondition_IN          Constant fr_general_lookup.lk_match_key3%TYPE := 'IN';
lcCondition_NOTIN       Constant fr_general_lookup.lk_match_key3%TYPE := 'NOT IN';
lcCondition_Null        Constant fr_general_lookup.lk_match_key3%TYPE := 'NULL';
lcCondition_NotNull     Constant fr_general_lookup.lk_match_key3%TYPE := 'NOT NULL';
lcCondition_Equals      Constant fr_general_lookup.lk_match_key3%TYPE := 'EQUALS';
lcCondition_NotEquals   Constant fr_general_lookup.lk_match_key3%TYPE := 'NOT EQUALS';
lcType_Set              Constant fr_general_lookup.lk_match_key4%TYPE := 'SET';
lcType_SetRange         Constant fr_general_lookup.lk_match_key4%TYPE := 'SET RANGE';
lcType_Date             Constant fr_general_lookup.lk_match_key4%TYPE := 'DATE';
lcType_Numeric          Constant fr_general_lookup.lk_match_key4%TYPE := 'NUMERIC';
lcType_Char             Constant fr_general_lookup.lk_match_key4%TYPE := 'CHAR';
lcFormat_Date           Constant fr_general_lookup.lk_match_key5%TYPE := 'YYYY-MM-DD';

/* Variables. */
mySQL        Varchar2(32767);
mySQL_Clob   Clob;

Begin
  dbms_application_info.set_action(lcUnitName || ':Start');
  PG_COMMON.pLogDebug(pinMessage => 'Starting Combo Check');

  /* Reset the error count. */
  poutErrorCount := 0;

  /* Reset the input table. */
  dbms_application_info.set_action(lcUnitName || ':Reset Tables');
  mySQL := 'Delete ' || gSQLHint_DeleteComboInput || ' from ' || PG_COMMON.gcSchema_FDR || '.' || lcTableName_Input;
  PG_COMMON.pExecuteSQL(pinSQL => mySQL);
  /* Reset the error table. */
  mySQL := 'Delete ' || gSQLHint_DeleteComboError || ' from ' || PG_COMMON.gcSchema_FDR || '.' || lcTableName_Error;
  PG_COMMON.pExecuteSQL(pinSQL => mySQL);

  /* Populate the input table. */
  /* Some potential alternatives: 1. Use the input view and filter directly in the combo check SQL instead of materializing the table (could force a materialize hint in the SQL (combo_input)).
                                  2. Force the caller to populate the temporary table before calling the process. */
  dbms_application_info.set_action(lcUnitName || ':Generate Input Query');
  mySQL := 'Insert ' || gSQLHint_InsertInput || ' into ' || PG_COMMON.gcSchema_FDR || '.' || lcTableName_Input || ' ('
        || '  ci_input_id,'
        || '  ci_ruleset,'
        || '  ci_attribute_1,'
        || '  ci_attribute_2,'
        || '  ci_attribute_3,'
        || '  ci_attribute_4,'
        || '  ci_attribute_5,'
        || '  ci_attribute_6,'
        || '  ci_attribute_7,'
        || '  ci_attribute_8,'
        || '  ci_attribute_9,'
        || '  ci_attribute_10,'
        || '  ci_suspense_id)'
        || 'Select ' || gSQLHint_SelectInput
        || '       ci_input_id,'
        || '       ci_ruleset,'
        || '       ci_attribute_1,'
        || '       ci_attribute_2,'
        || '       ci_attribute_3,'
        || '       ci_attribute_4,'
        || '       ci_attribute_5,'
        || '       ci_attribute_6,'
        || '       ci_attribute_7,'
        || '       ci_attribute_8,'
        || '       ci_attribute_9,'
        || '       ci_attribute_10,'
        || '       ci_suspense_id'
        || '  from ' || sys.dbms_assert.sql_object_name(pinObjectName);
  If pinFilter is not null Then
    mySQL := mySQL || ' where ' || pinFilter;
  End If;
  dbms_application_info.set_action(lcUnitName || ':Execute Input Query');
  PG_COMMON.pExecuteSQL(pinSQL => mySQL);
  
  /* Skip to end if nothing to do. */
  If PG_COMMON.gRowCount = 0 Then Goto EndProcess; End If;

  /* Step 1: Lookup the rule(s) to apply from General Lookup from the rule set provided
                Lookup Type = COMBO_RULESET
                Match Key 1 = Rule Set
                Match Key 2 = Output Rule
                Lookup Value 1 = Action (CHECK)

     APPLICABLE CONDITION
     Step 2: Lookup the Applicable Rule(s) from General Lookup
                Lookup Type = COMBO_APPLICABLE
                Match Key 1 = Rule
                Match Key 2 = Attribute (ci_attribute_1..10)
                Match Key 3 = Condition (IN, NOT IN, NULL, NOT NULL, EQUALS or NOT EQUALS)
                Match Key 4 = Condition Type (DATE, NUMERIC, SET, SET RANGE or CHAR)
                Match Key 5 = Set of Values (SET or SET RANGE) or start value (DATE, NUMERIC or CHAR)
                Match Key 6 = End value (DATE, NUMERIC)
                Lookup Value 1 = Action (CHECK or FAIL)

     If the Input Attribute satisfies the condition and the action is CHECK, then we need to check the combination (move to step 3).
     If the Input Attribute satisfies the condition and the action is FAIL then fail the input record.
     If the Input Attribute does not match then no need to perform combination checking for this record provided no other applicable condition is satisfied.

     CHECK CONDITION
     Step 3: Lookup the Check Rule(s) from General Lookup (only if 1 or more applicable conditions were satisfied or the rule has none)
                Lookup Type = COMBO_CHECK
                Match Key 1 = Rule
                Match Key 2 = Attribute (ci_attribute_1..10)
                Match Key 3 = Condition (IN, NOT IN, NULL, NOT NULL, EQUALS or NOT EQUALS)
                Match Key 4 = Condition Type (DATE, NUMERIC, SET, SET RANGE or CHAR)
                Match Key 5 = Set of Values (SET or SET RANGE) or start value (DATE, NUMERIC or CHAR)
                Match Key 6 = End value (DATE, NUMERIC)
                Lookup Value 1 = Action (CHECK)

     If the Check Condition fails then fail the input record. */

  /* Some potential alternatives: 1. Use an output view (add this as a parameter) and write to that view (e.g. create a view on Sub-Ledger Journal Line Error table and write directly to that). */
  dbms_application_info.set_action(lcUnitName || ':Generate Combo Query'); 
  mySQL := 'Insert ' || gSQLHint_InsertComboError || ' into ' || PG_COMMON.gcSchema_FDR || '.'|| lcTableName_Error || ' ('
        || '  ce_rule_id,'
        || '  ce_rule,'
        || '  ce_attribute_name,'
        || '  ce_input_id,'
        || '  ce_ruleset,'
        || '  ce_attribute_1,'
        || '  ce_attribute_2,'
        || '  ce_attribute_3,'
        || '  ce_attribute_4,'
        || '  ce_attribute_5,'
        || '  ce_attribute_6,'
        || '  ce_attribute_7,'
        || '  ce_attribute_8,'
        || '  ce_attribute_9,'
        || '  ce_attribute_10,'
        || '  ce_suspense_id)'
        || 'With '
        || 'combo_input as '
        || '(Select ci_ruleset,'
        || '        ci_attribute_1,'
        || '        ci_attribute_2,'
        || '        ci_attribute_3,'
        || '        ci_attribute_4,'
        || '        ci_attribute_5,'
        || '        ci_attribute_6,'
        || '        ci_attribute_7,'
        || '        ci_attribute_8,'
        || '        ci_attribute_9,'
        || '        ci_attribute_10,'
        || '        ci_suspense_id'
        || '   from ' || PG_COMMON.gcSchema_FDR || '.' || lcTableName_Input
        || '  group by ci_ruleset,'
        || '           ci_attribute_1,'
        || '           ci_attribute_2,'
        || '           ci_attribute_3,'
        || '           ci_attribute_4,'
        || '           ci_attribute_5,'
        || '           ci_attribute_6,'
        || '           ci_attribute_7,'
        || '           ci_attribute_8,'
        || '           ci_attribute_9,'
        || '           ci_attribute_10,'
        || '           ci_suspense_id),'
        || 'combo_rule as '
        || '(Select lk_match_key1,'
        || '        lk_match_key2'
        || '   from fdr.fr_general_lookup'
        || '  where lk_lkt_lookup_type_code = ' || sys.dbms_assert.enquote_literal(gcLookupType_RuleSet);
  If pinBusinessDate is not null Then
    mySQL := mySQL
          || ' and to_date(' || to_char(pinBusinessDate,'YYYYMMDD') || ',''YYYYMMDD'') between lk_effective_from and lk_effective_to';
  End If;
  mySQL := mySQL
        || '    and lk_active = ' || sys.dbms_assert.enquote_literal(PG_COMMON.gcActiveInactive_Active) || '),'
        || 'combo_set as '
        || '(Select data_set,'
        || '        from_value,'
        || '        to_value'
        || '   from fdr.fcv_combination_check_data),'
        || 'combo_applicable as '
        || '(Select lk_lookup_key_id,'
        || '        lk_match_key1,'
        || '        lk_match_key2,'
        || '        lk_match_key3,'
        || '        lk_match_key4,'
        || '        lk_match_key5,'
        || '        lk_match_key6,'
        || '        lk_lookup_value1'
        || '   from fdr.fr_general_lookup'
        || '  where lk_lkt_lookup_type_code = ' || sys.dbms_assert.enquote_literal(gcLookupType_Applicable);
  If pinBusinessDate is not null Then
    mySQL := mySQL
          || ' and to_date(' || to_char(pinBusinessDate,'YYYYMMDD') || ',''YYYYMMDD'') between lk_effective_from and lk_effective_to';
  End If;
  mySQL := mySQL
        || '    and lk_active = ' || sys.dbms_assert.enquote_literal(PG_COMMON.gcActiveInactive_Active) || '),'
        || 'combo_check as '
        || '(Select lk_lookup_key_id,'
        || '        lk_match_key1,'
        || '        lk_match_key2,'
        || '        lk_match_key3,'
        || '        lk_match_key4,'
        || '        lk_match_key5,'
        || '        lk_match_key6,'
        || '        lk_lookup_value1'
        || '   from fdr.fr_general_lookup'
        || '  where lk_lkt_lookup_type_code = ' || sys.dbms_assert.enquote_literal(gcLookupType_Check);
  If pinBusinessDate is not null Then
    mySQL := mySQL
          || ' and to_date(' || to_char(pinBusinessDate,'YYYYMMDD') || ',''YYYYMMDD'') between lk_effective_from and lk_effective_to';
  End If;
  mySQL := mySQL
        || '    and lk_active = ' || sys.dbms_assert.enquote_literal(PG_COMMON.gcActiveInactive_Active) || '),'
        || 'combo_applicable_fail as '
        || '(Select combo_rule.lk_match_key2 as ce_rule,'
        || '        combo_applicable.lk_match_key2 as ce_attribute_name,'
        || '        combo_applicable.lk_lookup_key_id as ce_rule_id,'
        || '        combo_input.ci_ruleset as ce_ruleset,'
        || '        combo_input.ci_attribute_1 as ce_attribute_1,'
        || '        combo_input.ci_attribute_2 as ce_attribute_2,'
        || '        combo_input.ci_attribute_3 as ce_attribute_3,'
        || '        combo_input.ci_attribute_4 as ce_attribute_4,'
        || '        combo_input.ci_attribute_5 as ce_attribute_5,'
        || '        combo_input.ci_attribute_6 as ce_attribute_6,'
        || '        combo_input.ci_attribute_7 as ce_attribute_7,'
        || '        combo_input.ci_attribute_8 as ce_attribute_8,'
        || '        combo_input.ci_attribute_9 as ce_attribute_9,'
        || '        combo_input.ci_attribute_10 as ce_attribute_10,'
        || '        combo_input.ci_suspense_id as ce_suspense_id'
        || '   from combo_input'
        || '   join combo_rule on combo_input.ci_ruleset = combo_rule.lk_match_key1'
        || '   join combo_applicable on combo_rule.lk_match_key2 = combo_applicable.lk_match_key1'
        || '  where combo_applicable.lk_lookup_value1 = ' || sys.dbms_assert.enquote_literal(lcAction_Fail)
        || '    and ((combo_applicable.lk_match_key3 = ' || sys.dbms_assert.enquote_literal(lcCondition_IN)
        || '          and ( (combo_applicable.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_Set)
        || '                 and exists (Select NULL'
        || '                               from combo_set ca_set'
        || '                              where combo_applicable.lk_match_key5 = ca_set.data_set'
        || '                                and decode(combo_applicable.lk_match_key2,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_input.ci_attribute_1,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_input.ci_attribute_2,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_input.ci_attribute_3,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_input.ci_attribute_4,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_input.ci_attribute_5,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_input.ci_attribute_6,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_input.ci_attribute_7,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_input.ci_attribute_8,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_input.ci_attribute_9,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_input.ci_attribute_10) = ca_set.from_value))'
        || '                or (combo_applicable.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_SetRange)
        || '                    and exists (Select NULL'
        || '                                  from combo_set ca_set'
        || '                                 where combo_applicable.lk_match_key5 = ca_set.data_set'
        || '                                   and decode(combo_applicable.lk_match_key2,'
        ||                                                sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_input.ci_attribute_1,'
        ||                                                sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_input.ci_attribute_2,'
        ||                                                sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_input.ci_attribute_3,'
        ||                                                sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_input.ci_attribute_4,'
        ||                                                sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_input.ci_attribute_5,'
        ||                                                sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_input.ci_attribute_6,'
        ||                                                sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_input.ci_attribute_7,'
        ||                                                sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_input.ci_attribute_8,'
        ||                                                sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_input.ci_attribute_9,'
        ||                                                sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_input.ci_attribute_10) between ca_set.from_value and ca_set.to_value))'
        || '                or (combo_applicable.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_Numeric)
        || '                    and decode(combo_applicable.lk_match_key2,'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_1) || ',to_number(combo_input.ci_attribute_1),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_2) || ',to_number(combo_input.ci_attribute_2),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_3) || ',to_number(combo_input.ci_attribute_3),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_4) || ',to_number(combo_input.ci_attribute_4),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_5) || ',to_number(combo_input.ci_attribute_5),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_6) || ',to_number(combo_input.ci_attribute_6),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_7) || ',to_number(combo_input.ci_attribute_7),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_8) || ',to_number(combo_input.ci_attribute_8),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_9) || ',to_number(combo_input.ci_attribute_9),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_10) || ',to_number(combo_input.ci_attribute_10)) between to_number(combo_applicable.lk_match_key5) and to_number(combo_applicable.lk_match_key6))'
        || '                or (combo_applicable.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_Date)
        || '                    and decode(combo_applicable.lk_match_key2,'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_1) || ',to_date(combo_input.ci_attribute_1,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_2) || ',to_date(combo_input.ci_attribute_2,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_3) || ',to_date(combo_input.ci_attribute_3,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_4) || ',to_date(combo_input.ci_attribute_4,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_5) || ',to_date(combo_input.ci_attribute_5,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_6) || ',to_date(combo_input.ci_attribute_6,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_7) || ',to_date(combo_input.ci_attribute_7,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_8) || ',to_date(combo_input.ci_attribute_8,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_9) || ',to_date(combo_input.ci_attribute_9,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_10) || ',to_date(combo_input.ci_attribute_10,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || ')) between to_date(combo_applicable.lk_match_key5,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || ') and to_date(combo_applicable.lk_match_key6,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '))'
        || '              )'
        || '         )'
        || '         or (combo_applicable.lk_match_key3 = ' || sys.dbms_assert.enquote_literal(lcCondition_NOTIN)
        || '          and ( (combo_applicable.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_Set)
        || '                 and not exists (Select NULL'
        || '                                   from combo_set ca_set'
        || '                                  where combo_applicable.lk_match_key5 = ca_set.data_set'
        || '                                    and decode(combo_applicable.lk_match_key2,'
        ||                                                 sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_input.ci_attribute_1,'
        ||                                                 sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_input.ci_attribute_2,'
        ||                                                 sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_input.ci_attribute_3,'
        ||                                                 sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_input.ci_attribute_4,'
        ||                                                 sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_input.ci_attribute_5,'
        ||                                                 sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_input.ci_attribute_6,'
        ||                                                 sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_input.ci_attribute_7,'
        ||                                                 sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_input.ci_attribute_8,'
        ||                                                 sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_input.ci_attribute_9,'
        ||                                                 sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_input.ci_attribute_10) = ca_set.from_value))'
        || '                or (combo_applicable.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_SetRange)
        || '                    and not exists (Select NULL'
        || '                                      from combo_set ca_set'
        || '                                     where combo_applicable.lk_match_key5 = ca_set.data_set'
        || '                                       and decode(combo_applicable.lk_match_key2,'
        ||                                                    sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_input.ci_attribute_1,'
        ||                                                    sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_input.ci_attribute_2,'
        ||                                                    sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_input.ci_attribute_3,'
        ||                                                    sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_input.ci_attribute_4,'
        ||                                                    sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_input.ci_attribute_5,'
        ||                                                    sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_input.ci_attribute_6,'
        ||                                                    sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_input.ci_attribute_7,'
        ||                                                    sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_input.ci_attribute_8,'
        ||                                                    sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_input.ci_attribute_9,'
        ||                                                    sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_input.ci_attribute_10) between ca_set.from_value and ca_set.to_value))'
        || '                or (combo_applicable.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_Numeric)
        || '                    and not decode(combo_applicable.lk_match_key2,'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_1) || ',to_number(combo_input.ci_attribute_1),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_2) || ',to_number(combo_input.ci_attribute_2),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_3) || ',to_number(combo_input.ci_attribute_3),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_4) || ',to_number(combo_input.ci_attribute_4),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_5) || ',to_number(combo_input.ci_attribute_5),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_6) || ',to_number(combo_input.ci_attribute_6),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_7) || ',to_number(combo_input.ci_attribute_7),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_8) || ',to_number(combo_input.ci_attribute_8),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_9) || ',to_number(combo_input.ci_attribute_9),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_10) || ',to_number(combo_input.ci_attribute_10)) between to_number(combo_applicable.lk_match_key5) and to_number(combo_applicable.lk_match_key6))'
        || '                or (combo_applicable.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_Date)
        || '                    and not decode(combo_applicable.lk_match_key2,'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_1) || ',to_date(combo_input.ci_attribute_1,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_2) || ',to_date(combo_input.ci_attribute_2,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_3) || ',to_date(combo_input.ci_attribute_3,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_4) || ',to_date(combo_input.ci_attribute_4,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_5) || ',to_date(combo_input.ci_attribute_5,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_6) || ',to_date(combo_input.ci_attribute_6,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_7) || ',to_date(combo_input.ci_attribute_7,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_8) || ',to_date(combo_input.ci_attribute_8,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_9) || ',to_date(combo_input.ci_attribute_9,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_10) || ',to_date(combo_input.ci_attribute_10,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || ')) between to_date(combo_applicable.lk_match_key5,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || ') and to_date(combo_applicable.lk_match_key6,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '))'
        || '              )'
        || '         )'
        || '         or (combo_applicable.lk_match_key3 = ' || sys.dbms_assert.enquote_literal(lcCondition_Null)
        || '             and decode(combo_applicable.lk_match_key2,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_input.ci_attribute_1,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_input.ci_attribute_2,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_input.ci_attribute_3,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_input.ci_attribute_4,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_input.ci_attribute_5,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_input.ci_attribute_6,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_input.ci_attribute_7,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_input.ci_attribute_8,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_input.ci_attribute_9,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_input.ci_attribute_10) is null)'
        || '         or (combo_applicable.lk_match_key3 = ' || sys.dbms_assert.enquote_literal(lcCondition_NotNull)
        || '             and decode(combo_applicable.lk_match_key2,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_input.ci_attribute_1,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_input.ci_attribute_2,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_input.ci_attribute_3,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_input.ci_attribute_4,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_input.ci_attribute_5,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_input.ci_attribute_6,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_input.ci_attribute_7,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_input.ci_attribute_8,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_input.ci_attribute_9,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_input.ci_attribute_10) is not null)'
        || '         or (combo_applicable.lk_match_key3 = ' || sys.dbms_assert.enquote_literal(lcCondition_Equals)
        || '             and decode(combo_applicable.lk_match_key2,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_input.ci_attribute_1,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_input.ci_attribute_2,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_input.ci_attribute_3,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_input.ci_attribute_4,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_input.ci_attribute_5,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_input.ci_attribute_6,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_input.ci_attribute_7,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_input.ci_attribute_8,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_input.ci_attribute_9,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_input.ci_attribute_10) = combo_applicable.lk_match_key5)'
        || '         or (combo_applicable.lk_match_key3 = ' || sys.dbms_assert.enquote_literal(lcCondition_NotEquals)
        || '             and decode(combo_applicable.lk_match_key2,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_input.ci_attribute_1,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_input.ci_attribute_2,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_input.ci_attribute_3,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_input.ci_attribute_4,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_input.ci_attribute_5,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_input.ci_attribute_6,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_input.ci_attribute_7,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_input.ci_attribute_8,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_input.ci_attribute_9,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_input.ci_attribute_10) <> combo_applicable.lk_match_key5)'
        || '        )'
        || '),';
  /* As query will exceed 32k, need to put into a CLOB. */
  sys.dbms_lob.createtemporary(mySQL_Clob,True);
  sys.dbms_lob.append(mySQL_Clob,mySQL);
  sys.dbms_lob.append(mySQL_Clob,'combo_applicable_check as'
        || '(Select combo_rule.lk_match_key2 as ci_rule,'
        || '        combo_input.ci_ruleset as ci_ruleset,'
        || '        combo_input.ci_attribute_1 as ci_attribute_1,'
        || '        combo_input.ci_attribute_2 as ci_attribute_2,'
        || '        combo_input.ci_attribute_3 as ci_attribute_3,'
        || '        combo_input.ci_attribute_4 as ci_attribute_4,'
        || '        combo_input.ci_attribute_5 as ci_attribute_5,'
        || '        combo_input.ci_attribute_6 as ci_attribute_6,'
        || '        combo_input.ci_attribute_7 as ci_attribute_7,'
        || '        combo_input.ci_attribute_8 as ci_attribute_8,'
        || '        combo_input.ci_attribute_9 as ci_attribute_9,'
        || '        combo_input.ci_attribute_10 as ci_attribute_10,'
        || '        combo_input.ci_suspense_id as ci_suspense_id'
        || '   from combo_input'
        || '   join combo_rule on combo_input.ci_ruleset = combo_rule.lk_match_key1'
               /* No applicable conditions => "Always" */
        || '   left join combo_applicable on combo_rule.lk_match_key2 = combo_applicable.lk_match_key1'
        || '  where combo_applicable.lk_match_key1 is null'
        || '     or (combo_applicable.lk_lookup_value1 = ' || sys.dbms_assert.enquote_literal(lcAction_Check)
        || '         and ((combo_applicable.lk_match_key3 = ' || sys.dbms_assert.enquote_literal(lcCondition_IN)
        || '               and ( (combo_applicable.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_Set)
        || '                      and exists (Select NULL'
        || '                                    from combo_set ca_set'
        || '                                   where combo_applicable.lk_match_key5 = ca_set.data_set'
        || '                                     and decode(combo_applicable.lk_match_key2,'
        ||                                                  sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_input.ci_attribute_1,'
        ||                                                  sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_input.ci_attribute_2,'
        ||                                                  sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_input.ci_attribute_3,'
        ||                                                  sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_input.ci_attribute_4,'
        ||                                                  sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_input.ci_attribute_5,'
        ||                                                  sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_input.ci_attribute_6,'
        ||                                                  sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_input.ci_attribute_7,'
        ||                                                  sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_input.ci_attribute_8,'
        ||                                                  sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_input.ci_attribute_9,'
        ||                                                  sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_input.ci_attribute_10) = ca_set.from_value))'
        || '                     or (combo_applicable.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_SetRange)
        || '                         and exists (Select NULL'
        || '                                       from combo_set ca_set'
        || '                                      where combo_applicable.lk_match_key5 = ca_set.data_set'
        || '                                        and decode(combo_applicable.lk_match_key2,'
        ||                                                     sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_input.ci_attribute_1,'
        ||                                                     sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_input.ci_attribute_2,'
        ||                                                     sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_input.ci_attribute_3,'
        ||                                                     sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_input.ci_attribute_4,'
        ||                                                     sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_input.ci_attribute_5,'
        ||                                                     sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_input.ci_attribute_6,'
        ||                                                     sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_input.ci_attribute_7,'
        ||                                                     sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_input.ci_attribute_8,'
        ||                                                     sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_input.ci_attribute_9,'
        ||                                                     sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_input.ci_attribute_10) between ca_set.from_value and ca_set.to_value))'
        || '                     or (combo_applicable.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_Numeric)
        || '                         and decode(combo_applicable.lk_match_key2,'
        ||                                      sys.dbms_assert.enquote_literal(gcAttribute_1) || ',to_number(combo_input.ci_attribute_1),'
        ||                                      sys.dbms_assert.enquote_literal(gcAttribute_2) || ',to_number(combo_input.ci_attribute_2),'
        ||                                      sys.dbms_assert.enquote_literal(gcAttribute_3) || ',to_number(combo_input.ci_attribute_3),'
        ||                                      sys.dbms_assert.enquote_literal(gcAttribute_4) || ',to_number(combo_input.ci_attribute_4),'
        ||                                      sys.dbms_assert.enquote_literal(gcAttribute_5) || ',to_number(combo_input.ci_attribute_5),'
        ||                                      sys.dbms_assert.enquote_literal(gcAttribute_6) || ',to_number(combo_input.ci_attribute_6),'
        ||                                      sys.dbms_assert.enquote_literal(gcAttribute_7) || ',to_number(combo_input.ci_attribute_7),'
        ||                                      sys.dbms_assert.enquote_literal(gcAttribute_8) || ',to_number(combo_input.ci_attribute_8),'
        ||                                      sys.dbms_assert.enquote_literal(gcAttribute_9) || ',to_number(combo_input.ci_attribute_9),'
        ||                                      sys.dbms_assert.enquote_literal(gcAttribute_10) || ',to_number(combo_input.ci_attribute_10)) between to_number(combo_applicable.lk_match_key5) and to_number(combo_applicable.lk_match_key6))'
        || '                     or (combo_applicable.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_Date)
        || '                         and decode(combo_applicable.lk_match_key2,'
        ||                                      sys.dbms_assert.enquote_literal(gcAttribute_1) || ',to_date(combo_input.ci_attribute_1,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                      sys.dbms_assert.enquote_literal(gcAttribute_2) || ',to_date(combo_input.ci_attribute_2,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                      sys.dbms_assert.enquote_literal(gcAttribute_3) || ',to_date(combo_input.ci_attribute_3,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                      sys.dbms_assert.enquote_literal(gcAttribute_4) || ',to_date(combo_input.ci_attribute_4,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                      sys.dbms_assert.enquote_literal(gcAttribute_5) || ',to_date(combo_input.ci_attribute_5,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                      sys.dbms_assert.enquote_literal(gcAttribute_6) || ',to_date(combo_input.ci_attribute_6,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                      sys.dbms_assert.enquote_literal(gcAttribute_7) || ',to_date(combo_input.ci_attribute_7,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                      sys.dbms_assert.enquote_literal(gcAttribute_8) || ',to_date(combo_input.ci_attribute_8,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                      sys.dbms_assert.enquote_literal(gcAttribute_9) || ',to_date(combo_input.ci_attribute_9,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                      sys.dbms_assert.enquote_literal(gcAttribute_10) || ',to_date(combo_input.ci_attribute_10,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || ')) between to_date(combo_applicable.lk_match_key5,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || ') and to_date(combo_applicable.lk_match_key6,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '))'
        || '                   )'
        || '              )'
        || '              or (combo_applicable.lk_match_key3 = ' || sys.dbms_assert.enquote_literal(lcCondition_NOTIN)
        || '                  and ( (combo_applicable.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_Set)
        || '                         and not exists (Select NULL'
        || '                                           from combo_set ca_set'
        || '                                          where combo_applicable.lk_match_key5 = ca_set.data_set'
        || '                                            and decode(combo_applicable.lk_match_key2,'
        ||                                                         sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_input.ci_attribute_1,'
        ||                                                         sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_input.ci_attribute_2,'
        ||                                                         sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_input.ci_attribute_3,'
        ||                                                         sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_input.ci_attribute_4,'
        ||                                                         sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_input.ci_attribute_5,'
        ||                                                         sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_input.ci_attribute_6,'
        ||                                                         sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_input.ci_attribute_7,'
        ||                                                         sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_input.ci_attribute_8,'
        ||                                                         sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_input.ci_attribute_9,'
        ||                                                         sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_input.ci_attribute_10) = ca_set.from_value))'
        || '                        or (combo_applicable.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_SetRange)
        || '                            and not exists (Select NULL'
        || '                                              from combo_set ca_set'
        || '                                             where combo_applicable.lk_match_key5 = ca_set.data_set'
        || '                                               and decode(combo_applicable.lk_match_key2,'
        ||                                                            sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_input.ci_attribute_1,'
        ||                                                            sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_input.ci_attribute_2,'
        ||                                                            sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_input.ci_attribute_3,'
        ||                                                            sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_input.ci_attribute_4,'
        ||                                                            sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_input.ci_attribute_5,'
        ||                                                            sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_input.ci_attribute_6,'
        ||                                                            sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_input.ci_attribute_7,'
        ||                                                            sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_input.ci_attribute_8,'
        ||                                                            sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_input.ci_attribute_9,'
        ||                                                            sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_input.ci_attribute_10) between ca_set.from_value and ca_set.to_value))'
        || '                        or (combo_applicable.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_Numeric)
        || '                            and not decode(combo_applicable.lk_match_key2,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_1) || ',to_number(combo_input.ci_attribute_1),'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_2) || ',to_number(combo_input.ci_attribute_2),'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_3) || ',to_number(combo_input.ci_attribute_3),'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_4) || ',to_number(combo_input.ci_attribute_4),'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_5) || ',to_number(combo_input.ci_attribute_5),'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_6) || ',to_number(combo_input.ci_attribute_6),'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_7) || ',to_number(combo_input.ci_attribute_7),'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_8) || ',to_number(combo_input.ci_attribute_8),'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_9) || ',to_number(combo_input.ci_attribute_9),'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_10) || ',to_number(combo_input.ci_attribute_10)) between to_number(combo_applicable.lk_match_key5) and to_number(combo_applicable.lk_match_key6))'
        || '                        or (combo_applicable.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_Date)
        || '                            and not decode(combo_applicable.lk_match_key2,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_1) || ',to_date(combo_input.ci_attribute_1,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_2) || ',to_date(combo_input.ci_attribute_2,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_3) || ',to_date(combo_input.ci_attribute_3,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_4) || ',to_date(combo_input.ci_attribute_4,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_5) || ',to_date(combo_input.ci_attribute_5,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_6) || ',to_date(combo_input.ci_attribute_6,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_7) || ',to_date(combo_input.ci_attribute_7,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_8) || ',to_date(combo_input.ci_attribute_8,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_9) || ',to_date(combo_input.ci_attribute_9,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_10) || ',to_date(combo_input.ci_attribute_10,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || ')) between to_date(combo_applicable.lk_match_key5,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || ') and to_date(combo_applicable.lk_match_key6,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '))'
        || '                      )'
        || '                 )'
        || '              or (combo_applicable.lk_match_key3 = ' || sys.dbms_assert.enquote_literal(lcCondition_Null)
        || '                  and decode(combo_applicable.lk_match_key2,'
        ||                               sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_input.ci_attribute_1,'
        ||                               sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_input.ci_attribute_2,'
        ||                               sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_input.ci_attribute_3,'
        ||                               sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_input.ci_attribute_4,'
        ||                               sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_input.ci_attribute_5,'
        ||                               sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_input.ci_attribute_6,'
        ||                               sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_input.ci_attribute_7,'
        ||                               sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_input.ci_attribute_8,'
        ||                               sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_input.ci_attribute_9,'
        ||                               sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_input.ci_attribute_10) is null)'
        || '              or (combo_applicable.lk_match_key3 = ' || sys.dbms_assert.enquote_literal(lcCondition_NotNull)
        || '                  and decode(combo_applicable.lk_match_key2,'
        ||                               sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_input.ci_attribute_1,'
        ||                               sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_input.ci_attribute_2,'
        ||                               sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_input.ci_attribute_3,'
        ||                               sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_input.ci_attribute_4,'
        ||                               sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_input.ci_attribute_5,'
        ||                               sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_input.ci_attribute_6,'
        ||                               sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_input.ci_attribute_7,'
        ||                               sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_input.ci_attribute_8,'
        ||                               sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_input.ci_attribute_9,'
        ||                               sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_input.ci_attribute_10) is not null)'
        || '         or (combo_applicable.lk_match_key3 = ' || sys.dbms_assert.enquote_literal(lcCondition_Equals)
        || '             and decode(combo_applicable.lk_match_key2,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_input.ci_attribute_1,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_input.ci_attribute_2,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_input.ci_attribute_3,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_input.ci_attribute_4,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_input.ci_attribute_5,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_input.ci_attribute_6,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_input.ci_attribute_7,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_input.ci_attribute_8,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_input.ci_attribute_9,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_input.ci_attribute_10) = combo_applicable.lk_match_key5)'
        || '         or (combo_applicable.lk_match_key3 = ' || sys.dbms_assert.enquote_literal(lcCondition_NotEquals)
        || '             and decode(combo_applicable.lk_match_key2,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_input.ci_attribute_1,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_input.ci_attribute_2,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_input.ci_attribute_3,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_input.ci_attribute_4,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_input.ci_attribute_5,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_input.ci_attribute_6,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_input.ci_attribute_7,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_input.ci_attribute_8,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_input.ci_attribute_9,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_input.ci_attribute_10) <> combo_applicable.lk_match_key5)'
        || '             )'
        || '        )'
        || '  group by combo_rule.lk_match_key2,'
        || '           combo_input.ci_ruleset,'
        || '           combo_input.ci_attribute_1,'
        || '           combo_input.ci_attribute_2,'
        || '           combo_input.ci_attribute_3,'
        || '           combo_input.ci_attribute_4,'
        || '           combo_input.ci_attribute_5,'
        || '           combo_input.ci_attribute_6,'
        || '           combo_input.ci_attribute_7,'
        || '           combo_input.ci_attribute_8,'
        || '           combo_input.ci_attribute_9,'
        || '           combo_input.ci_attribute_10,'
        || '           combo_input.ci_suspense_id'
        || '),'
        || 'combo_check_fail as'
        || '(Select combo_check.lk_match_key1 as ce_rule,'
        || '        combo_check.lk_match_key2 as ce_attribute_name,'
        || '        combo_check.lk_lookup_key_id as ce_rule_id,'
        || '        combo_applicable_check.ci_ruleset as ce_ruleset,'
        || '        combo_applicable_check.ci_attribute_1 as ce_attribute_1,'
        || '        combo_applicable_check.ci_attribute_2 as ce_attribute_2,'
        || '        combo_applicable_check.ci_attribute_3 as ce_attribute_3,'
        || '        combo_applicable_check.ci_attribute_4 as ce_attribute_4,'
        || '        combo_applicable_check.ci_attribute_5 as ce_attribute_5,'
        || '        combo_applicable_check.ci_attribute_6 as ce_attribute_6,'
        || '        combo_applicable_check.ci_attribute_7 as ce_attribute_7,'
        || '        combo_applicable_check.ci_attribute_8 as ce_attribute_8,'
        || '        combo_applicable_check.ci_attribute_9 as ce_attribute_9,'
        || '        combo_applicable_check.ci_attribute_10 as ce_attribute_10,'
        || '        combo_applicable_check.ci_suspense_id as ce_suspense_id'
        || '   from combo_applicable_check'
        || '   join combo_check on combo_applicable_check.ci_rule = combo_check.lk_match_key1'
        || '  where combo_check.lk_lookup_value1 = ' || sys.dbms_assert.enquote_literal(lcAction_Check)
        || '    and ((combo_check.lk_match_key3 = ' || sys.dbms_assert.enquote_literal(lcCondition_IN)
        || '          and ( (combo_check.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_Set)
        || '                 and not exists (Select NULL'
        || '                                   from combo_set ca_set'
        || '                                  where combo_check.lk_match_key5 = ca_set.data_set'
        || '                                    and decode(combo_check.lk_match_key2,'
        ||                                                 sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_applicable_check.ci_attribute_1,'
        ||                                                 sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_applicable_check.ci_attribute_2,'
        ||                                                 sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_applicable_check.ci_attribute_3,'
        ||                                                 sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_applicable_check.ci_attribute_4,'
        ||                                                 sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_applicable_check.ci_attribute_5,'
        ||                                                 sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_applicable_check.ci_attribute_6,'
        ||                                                 sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_applicable_check.ci_attribute_7,'
        ||                                                 sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_applicable_check.ci_attribute_8,'
        ||                                                 sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_applicable_check.ci_attribute_9,'
        ||                                                 sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_applicable_check.ci_attribute_10) = ca_set.from_value))'
        || '                or (combo_check.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_SetRange)
        || '                    and not exists (Select NULL'
        || '                                      from combo_set ca_set'
        || '                                     where combo_check.lk_match_key5 = ca_set.data_set'
        || '                                       and decode(combo_check.lk_match_key2,'
        ||                                                    sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_applicable_check.ci_attribute_1,'
        ||                                                    sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_applicable_check.ci_attribute_2,'
        ||                                                    sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_applicable_check.ci_attribute_3,'
        ||                                                    sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_applicable_check.ci_attribute_4,'
        ||                                                    sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_applicable_check.ci_attribute_5,'
        ||                                                    sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_applicable_check.ci_attribute_6,'
        ||                                                    sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_applicable_check.ci_attribute_7,'
        ||                                                    sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_applicable_check.ci_attribute_8,'
        ||                                                    sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_applicable_check.ci_attribute_9,'
        ||                                                    sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_applicable_check.ci_attribute_10) between ca_set.from_value and ca_set.to_value))'
        || '                or (combo_check.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_Numeric)
        || '                    and not decode(combo_check.lk_match_key2,'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_1) || ',to_number(combo_applicable_check.ci_attribute_1),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_2) || ',to_number(combo_applicable_check.ci_attribute_2),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_3) || ',to_number(combo_applicable_check.ci_attribute_3),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_4) || ',to_number(combo_applicable_check.ci_attribute_4),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_5) || ',to_number(combo_applicable_check.ci_attribute_5),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_6) || ',to_number(combo_applicable_check.ci_attribute_6),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_7) || ',to_number(combo_applicable_check.ci_attribute_7),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_8) || ',to_number(combo_applicable_check.ci_attribute_8),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_9) || ',to_number(combo_applicable_check.ci_attribute_9),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_10) || ',to_number(combo_applicable_check.ci_attribute_10)) between to_number(combo_check.lk_match_key5) and to_number(combo_check.lk_match_key6))'
        || '                or (combo_check.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_Date)
        || '                    and not decode(combo_check.lk_match_key2,'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_1) || ',to_date(combo_applicable_check.ci_attribute_1,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_2) || ',to_date(combo_applicable_check.ci_attribute_2,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_3) || ',to_date(combo_applicable_check.ci_attribute_3,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_4) || ',to_date(combo_applicable_check.ci_attribute_4,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_5) || ',to_date(combo_applicable_check.ci_attribute_5,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_6) || ',to_date(combo_applicable_check.ci_attribute_6,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_7) || ',to_date(combo_applicable_check.ci_attribute_7,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_8) || ',to_date(combo_applicable_check.ci_attribute_8,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_9) || ',to_date(combo_applicable_check.ci_attribute_9,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                     sys.dbms_assert.enquote_literal(gcAttribute_10) || ',to_date(combo_applicable_check.ci_attribute_10,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || ')) between to_date(combo_check.lk_match_key5,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || ') and to_date(combo_check.lk_match_key6,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '))'
        || '              )'
        || '         )'
        || '         or (combo_check.lk_match_key3 = ' || sys.dbms_assert.enquote_literal(lcCondition_NOTIN)
        || '          and ( (combo_check.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_Set)
        || '                 and exists (Select NULL'
        || '                               from combo_set ca_set'
        || '                              where combo_check.lk_match_key5 = ca_set.data_set'
        || '                                and decode(combo_check.lk_match_key2,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_applicable_check.ci_attribute_1,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_applicable_check.ci_attribute_2,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_applicable_check.ci_attribute_3,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_applicable_check.ci_attribute_4,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_applicable_check.ci_attribute_5,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_applicable_check.ci_attribute_6,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_applicable_check.ci_attribute_7,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_applicable_check.ci_attribute_8,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_applicable_check.ci_attribute_9,'
        ||                                             sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_applicable_check.ci_attribute_10) = ca_set.from_value))'
        || '                or (combo_check.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_SetRange)
        || '                    and exists (Select NULL'
        || '                                  from combo_set ca_set'
        || '                                 where combo_check.lk_match_key5 = ca_set.data_set'
        || '                                   and decode(combo_check.lk_match_key2,'
        ||                                                sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_applicable_check.ci_attribute_1,'
        ||                                                sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_applicable_check.ci_attribute_2,'
        ||                                                sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_applicable_check.ci_attribute_3,'
        ||                                                sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_applicable_check.ci_attribute_4,'
        ||                                                sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_applicable_check.ci_attribute_5,'
        ||                                                sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_applicable_check.ci_attribute_6,'
        ||                                                sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_applicable_check.ci_attribute_7,'
        ||                                                sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_applicable_check.ci_attribute_8,'
        ||                                                sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_applicable_check.ci_attribute_9,'
        ||                                                sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_applicable_check.ci_attribute_10) between ca_set.from_value and ca_set.to_value))'
        || '                or (combo_check.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_Numeric)
        || '                    and decode(combo_check.lk_match_key2,'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_1) || ',to_number(combo_applicable_check.ci_attribute_1),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_2) || ',to_number(combo_applicable_check.ci_attribute_2),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_3) || ',to_number(combo_applicable_check.ci_attribute_3),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_4) || ',to_number(combo_applicable_check.ci_attribute_4),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_5) || ',to_number(combo_applicable_check.ci_attribute_5),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_6) || ',to_number(combo_applicable_check.ci_attribute_6),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_7) || ',to_number(combo_applicable_check.ci_attribute_7),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_8) || ',to_number(combo_applicable_check.ci_attribute_8),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_9) || ',to_number(combo_applicable_check.ci_attribute_9),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_10) || ',to_number(combo_applicable_check.ci_attribute_10)) between to_number(combo_check.lk_match_key5) and to_number(combo_check.lk_match_key6))'
        || '                or (combo_check.lk_match_key4 = ' || sys.dbms_assert.enquote_literal(lcType_Date)
        || '                    and decode(combo_check.lk_match_key2,'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_1) || ',to_date(combo_applicable_check.ci_attribute_1,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_2) || ',to_date(combo_applicable_check.ci_attribute_2,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_3) || ',to_date(combo_applicable_check.ci_attribute_3,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_4) || ',to_date(combo_applicable_check.ci_attribute_4,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_5) || ',to_date(combo_applicable_check.ci_attribute_5,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_6) || ',to_date(combo_applicable_check.ci_attribute_6,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_7) || ',to_date(combo_applicable_check.ci_attribute_7,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_8) || ',to_date(combo_applicable_check.ci_attribute_8,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_9) || ',to_date(combo_applicable_check.ci_attribute_9,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '),'
        ||                                 sys.dbms_assert.enquote_literal(gcAttribute_10) || ',to_date(combo_applicable_check.ci_attribute_10,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || ')) between to_date(combo_check.lk_match_key5,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || ') and to_date(combo_check.lk_match_key6,' || sys.dbms_assert.enquote_literal(lcFormat_Date) || '))'
        || '              )'
        || '         )'
        || '         or (combo_check.lk_match_key3 = ' || sys.dbms_assert.enquote_literal(lcCondition_Null)
        || '             and decode(combo_check.lk_match_key2,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_applicable_check.ci_attribute_1,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_applicable_check.ci_attribute_2,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_applicable_check.ci_attribute_3,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_applicable_check.ci_attribute_4,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_applicable_check.ci_attribute_5,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_applicable_check.ci_attribute_6,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_applicable_check.ci_attribute_7,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_applicable_check.ci_attribute_8,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_applicable_check.ci_attribute_9,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_applicable_check.ci_attribute_10) is not null)'
        || '         or (combo_check.lk_match_key3 = ' || sys.dbms_assert.enquote_literal(lcCondition_NotNull)
        || '             and decode(combo_check.lk_match_key2,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_applicable_check.ci_attribute_1,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_applicable_check.ci_attribute_2,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_applicable_check.ci_attribute_3,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_applicable_check.ci_attribute_4,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_applicable_check.ci_attribute_5,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_applicable_check.ci_attribute_6,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_applicable_check.ci_attribute_7,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_applicable_check.ci_attribute_8,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_applicable_check.ci_attribute_9,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_applicable_check.ci_attribute_10) is null)'
        || '         or (combo_check.lk_match_key3 = ' || sys.dbms_assert.enquote_literal(lcCondition_Equals)
        || '             and decode(combo_check.lk_match_key2,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_applicable_check.ci_attribute_1,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_applicable_check.ci_attribute_2,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_applicable_check.ci_attribute_3,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_applicable_check.ci_attribute_4,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_applicable_check.ci_attribute_5,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_applicable_check.ci_attribute_6,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_applicable_check.ci_attribute_7,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_applicable_check.ci_attribute_8,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_applicable_check.ci_attribute_9,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_applicable_check.ci_attribute_10) <> combo_check.lk_match_key5)'
        || '         or (combo_check.lk_match_key3 = ' || sys.dbms_assert.enquote_literal(lcCondition_NotEquals)
        || '             and decode(combo_check.lk_match_key2,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_1) || ',combo_applicable_check.ci_attribute_1,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_2) || ',combo_applicable_check.ci_attribute_2,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_3) || ',combo_applicable_check.ci_attribute_3,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_4) || ',combo_applicable_check.ci_attribute_4,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_5) || ',combo_applicable_check.ci_attribute_5,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_6) || ',combo_applicable_check.ci_attribute_6,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_7) || ',combo_applicable_check.ci_attribute_7,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_8) || ',combo_applicable_check.ci_attribute_8,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_9) || ',combo_applicable_check.ci_attribute_9,'
        ||                          sys.dbms_assert.enquote_literal(gcAttribute_10) || ',combo_applicable_check.ci_attribute_10) = combo_check.lk_match_key5)'
        || '        )'
        || '),'
        || 'combo_fail as'
        || '(Select * from combo_applicable_fail'
        || ' Union All'
        || ' Select * from combo_check_fail)'
        || 'Select ' || gSQLHint_SelectComboError
        || '       combo_fail.ce_rule_id as ce_rule_id,'
        || '       combo_fail.ce_rule as ce_rule,'
        || '       combo_fail.ce_attribute_name as ce_attribute_name,'
        || '       input.ci_input_id as ce_input_id,'
        || '       combo_fail.ce_ruleset as ce_ruleset,'
        || '       combo_fail.ce_attribute_1 as ce_attribute_1,'
        || '       combo_fail.ce_attribute_2 as ce_attribute_2,'
        || '       combo_fail.ce_attribute_3 as ce_attribute_3,'
        || '       combo_fail.ce_attribute_4 as ce_attribute_4,'
        || '       combo_fail.ce_attribute_5 as ce_attribute_5,'
        || '       combo_fail.ce_attribute_6 as ce_attribute_6,'
        || '       combo_fail.ce_attribute_7 as ce_attribute_7,'
        || '       combo_fail.ce_attribute_8 as ce_attribute_8,'
        || '       combo_fail.ce_attribute_9 as ce_attribute_9,'
        || '       combo_fail.ce_attribute_10 as ce_attribute_10,'
        || '       combo_fail.ce_suspense_id as ce_suspense_id'
        || '  from ' || PG_COMMON.gcSchema_FDR || '.' || lcTableName_Input || ' input'
        || '  join combo_fail on combo_fail.ce_ruleset = input.ci_ruleset'
        || '                 and decode(combo_fail.ce_attribute_1,input.ci_attribute_1,1,0) = 1'
        || '                 and decode(combo_fail.ce_attribute_2,input.ci_attribute_2,1,0) = 1'
        || '                 and decode(combo_fail.ce_attribute_3,input.ci_attribute_3,1,0) = 1'
        || '                 and decode(combo_fail.ce_attribute_4,input.ci_attribute_4,1,0) = 1'
        || '                 and decode(combo_fail.ce_attribute_5,input.ci_attribute_5,1,0) = 1'
        || '                 and decode(combo_fail.ce_attribute_6,input.ci_attribute_6,1,0) = 1'
        || '                 and decode(combo_fail.ce_attribute_7,input.ci_attribute_7,1,0) = 1'
        || '                 and decode(combo_fail.ce_attribute_8,input.ci_attribute_8,1,0) = 1'
        || '                 and decode(combo_fail.ce_attribute_9,input.ci_attribute_9,1,0) = 1'
        || '                 and decode(combo_fail.ce_attribute_10,input.ci_attribute_10,1,0) = 1');

  dbms_application_info.set_action(lcUnitName || ':Execute Combo Query');
  PG_COMMON.pExecuteSQL(pinSQL => mySQL_Clob);
  poutErrorCount := PG_COMMON.gRowCount;

<<EndProcess>>
  PG_COMMON.pLogDebug(pinMessage => 'End Combo Check : ErrorCount=' || poutErrorCount);
  dbms_application_info.set_action(NULL);

Exception
When Others Then
  /* Log the error. */
  PR_Error (
    a_type => PG_COMMON.gcErrorEventType_Error,
    a_text => dbms_utility.format_error_backtrace,
    a_category => PG_COMMON.gcErrorCategory_Tech,
    a_error_source => lgcUnitName || '.' || lcUnitName,
    a_error_table => lcTableName_Input,
    a_row => NULL,
    a_error_field => NULL,
    a_stage => user,
    a_technology => PG_COMMON.gcErrorTechnology_PLSQL,
    a_value => NULL,
    a_entity => NULL,
    a_book => NULL,
    a_security => NULL,
    a_source_system => NULL,
    a_client_key => NULL,
    a_client_ver => NULL,
    a_lpg_id => NULL
  );

  /* Raise the error. */
  Raise;
End pCombinationCheck;

end pg_combination_check;
/
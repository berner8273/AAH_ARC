CREATE OR REPLACE VIEW slr.v_slr_jrnl_lines_unposted_jt ("JLU_JRNL_HDR_ID", "JLU_JRNL_LINE_NUMBER", "JLU_FAK_ID", "JLU_EBA_ID", "JLU_JRNL_STATUS", "JLU_JRNL_STATUS_TEXT", "JLU_JRNL_PROCESS_ID", "JLU_DESCRIPTION", "JLU_SOURCE_JRNL_ID", "JLU_EFFECTIVE_DATE", "JLU_VALUE_DATE", "JLU_ENTITY", "JLU_EPG_ID", "JLU_ACCOUNT", "JLU_SEGMENT_1", "JLU_SEGMENT_2", "JLU_SEGMENT_3", "JLU_SEGMENT_4", "JLU_SEGMENT_5", "JLU_SEGMENT_6", "JLU_SEGMENT_7", "JLU_SEGMENT_8", "JLU_SEGMENT_9", "JLU_SEGMENT_10", "JLU_ATTRIBUTE_1", "JLU_ATTRIBUTE_2", "JLU_ATTRIBUTE_3", "JLU_ATTRIBUTE_4", "JLU_ATTRIBUTE_5", "JLU_REFERENCE_1", "JLU_REFERENCE_2", "JLU_REFERENCE_3", "JLU_REFERENCE_4", "JLU_REFERENCE_5", "JLU_REFERENCE_6", "JLU_REFERENCE_7", "JLU_REFERENCE_8", "JLU_REFERENCE_9", "JLU_REFERENCE_10", "JLU_TRAN_CCY", "JLU_TRAN_AMOUNT", "JLU_BASE_RATE", "JLU_BASE_CCY", "JLU_BASE_AMOUNT", "JLU_LOCAL_RATE", "JLU_LOCAL_CCY", "JLU_LOCAL_AMOUNT", "JLU_CREATED_BY", "JLU_CREATED_ON", "JLU_AMENDED_BY", "JLU_AMENDED_ON", "JLU_JRNL_TYPE", "JLU_JRNL_DATE", "JLU_JRNL_DESCRIPTION", "JLU_JRNL_SOURCE", "JLU_JRNL_SOURCE_JRNL_ID", "JLU_JRNL_AUTHORISED_BY", "JLU_JRNL_AUTHORISED_ON", "JLU_JRNL_VALIDATED_BY", "JLU_JRNL_VALIDATED_ON", "JLU_JRNL_POSTED_BY", "JLU_JRNL_POSTED_ON", "JLU_JRNL_TOTAL_HASH_DEBIT", "JLU_JRNL_TOTAL_HASH_CREDIT", "JLU_JRNL_PREF_STATIC_SRC", "JLU_JRNL_REF_ID", "JLU_JRNL_REV_DATE", "JLU_TRANSLATION_DATE", "JLU_PERIOD_MONTH", "JLU_PERIOD_YEAR", "JLU_PERIOD_LTD", "JLU_JRNL_INTERNAL_PERIOD_FLAG", "JT_BALANCE_TYPE", "JLU_PERIOD_QTR") AS 
  SELECT
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_HDR_ID",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_LINE_NUMBER",
    SLR_JRNL_LINES_UNPOSTED."JLU_FAK_ID",
    SLR_JRNL_LINES_UNPOSTED."JLU_EBA_ID",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_STATUS",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_STATUS_TEXT",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_PROCESS_ID",
    SLR_JRNL_LINES_UNPOSTED."JLU_DESCRIPTION",
    SLR_JRNL_LINES_UNPOSTED."JLU_SOURCE_JRNL_ID",
    SLR_JRNL_LINES_UNPOSTED."JLU_EFFECTIVE_DATE",
    SLR_JRNL_LINES_UNPOSTED."JLU_VALUE_DATE",
    SLR_JRNL_LINES_UNPOSTED."JLU_ENTITY",
    SLR_JRNL_LINES_UNPOSTED."JLU_EPG_ID",
    SLR_JRNL_LINES_UNPOSTED."JLU_ACCOUNT",
    SLR_JRNL_LINES_UNPOSTED."JLU_SEGMENT_1",
    SLR_JRNL_LINES_UNPOSTED."JLU_SEGMENT_2",
    SLR_JRNL_LINES_UNPOSTED."JLU_SEGMENT_3",
    SLR_JRNL_LINES_UNPOSTED."JLU_SEGMENT_4",
    SLR_JRNL_LINES_UNPOSTED."JLU_SEGMENT_5",
    SLR_JRNL_LINES_UNPOSTED."JLU_SEGMENT_6",
    SLR_JRNL_LINES_UNPOSTED."JLU_SEGMENT_7",
    SLR_JRNL_LINES_UNPOSTED."JLU_SEGMENT_8",
    SLR_JRNL_LINES_UNPOSTED."JLU_SEGMENT_9",
    SLR_JRNL_LINES_UNPOSTED."JLU_SEGMENT_10",
    SLR_JRNL_LINES_UNPOSTED."JLU_ATTRIBUTE_1",
    SLR_JRNL_LINES_UNPOSTED."JLU_ATTRIBUTE_2",
    SLR_JRNL_LINES_UNPOSTED."JLU_ATTRIBUTE_3",
    SLR_JRNL_LINES_UNPOSTED."JLU_ATTRIBUTE_4",
    SLR_JRNL_LINES_UNPOSTED."JLU_ATTRIBUTE_5",
    SLR_JRNL_LINES_UNPOSTED."JLU_REFERENCE_1",
    SLR_JRNL_LINES_UNPOSTED."JLU_REFERENCE_2",
    SLR_JRNL_LINES_UNPOSTED."JLU_REFERENCE_3",
    SLR_JRNL_LINES_UNPOSTED."JLU_REFERENCE_4",
    SLR_JRNL_LINES_UNPOSTED."JLU_REFERENCE_5",
    SLR_JRNL_LINES_UNPOSTED."JLU_REFERENCE_6",
    SLR_JRNL_LINES_UNPOSTED."JLU_REFERENCE_7",
    SLR_JRNL_LINES_UNPOSTED."JLU_REFERENCE_8",
    SLR_JRNL_LINES_UNPOSTED."JLU_REFERENCE_9",
    SLR_JRNL_LINES_UNPOSTED."JLU_REFERENCE_10",
    SLR_JRNL_LINES_UNPOSTED."JLU_TRAN_CCY",
    SLR_JRNL_LINES_UNPOSTED."JLU_TRAN_AMOUNT",
    SLR_JRNL_LINES_UNPOSTED."JLU_BASE_RATE",
    SLR_JRNL_LINES_UNPOSTED."JLU_BASE_CCY",
    SLR_JRNL_LINES_UNPOSTED."JLU_BASE_AMOUNT",
    SLR_JRNL_LINES_UNPOSTED."JLU_LOCAL_RATE",
    SLR_JRNL_LINES_UNPOSTED."JLU_LOCAL_CCY",
    SLR_JRNL_LINES_UNPOSTED."JLU_LOCAL_AMOUNT",
    SLR_JRNL_LINES_UNPOSTED."JLU_CREATED_BY",
    SLR_JRNL_LINES_UNPOSTED."JLU_CREATED_ON",
    SLR_JRNL_LINES_UNPOSTED."JLU_AMENDED_BY",
    SLR_JRNL_LINES_UNPOSTED."JLU_AMENDED_ON",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_TYPE",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_DATE",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_DESCRIPTION",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_SOURCE",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_SOURCE_JRNL_ID",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_AUTHORISED_BY",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_AUTHORISED_ON",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_VALIDATED_BY",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_VALIDATED_ON",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_POSTED_BY",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_POSTED_ON",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_TOTAL_HASH_DEBIT",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_TOTAL_HASH_CREDIT",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_PREF_STATIC_SRC",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_REF_ID",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_REV_DATE",
    SLR_JRNL_LINES_UNPOSTED."JLU_TRANSLATION_DATE",
    SLR_JRNL_LINES_UNPOSTED."JLU_PERIOD_MONTH",
    SLR_JRNL_LINES_UNPOSTED."JLU_PERIOD_YEAR",
    SLR_JRNL_LINES_UNPOSTED."JLU_PERIOD_LTD",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_INTERNAL_PERIOD_FLAG",
    EJT_BALANCE_TYPE_1 JT_BALANCE_TYPE,
    to_number(to_char(SLR_JRNL_LINES_UNPOSTED."JLU_EFFECTIVE_DATE",'Q')) as JLU_PERIOD_QTR
FROM
    SLR_JRNL_LINES_UNPOSTED JOIN slr_ext_jrnl_types
    ON EJT_TYPE = JLU_JRNL_TYPE
    AND EJT_BALANCE_TYPE_1 IS NOT NULL
UNION ALL
SELECT
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_HDR_ID",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_LINE_NUMBER",
    SLR_JRNL_LINES_UNPOSTED."JLU_FAK_ID",
    SLR_JRNL_LINES_UNPOSTED."JLU_EBA_ID",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_STATUS",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_STATUS_TEXT",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_PROCESS_ID",
    SLR_JRNL_LINES_UNPOSTED."JLU_DESCRIPTION",
    SLR_JRNL_LINES_UNPOSTED."JLU_SOURCE_JRNL_ID",
    SLR_JRNL_LINES_UNPOSTED."JLU_EFFECTIVE_DATE",
    SLR_JRNL_LINES_UNPOSTED."JLU_VALUE_DATE",
    SLR_JRNL_LINES_UNPOSTED."JLU_ENTITY",
    SLR_JRNL_LINES_UNPOSTED."JLU_EPG_ID",
    SLR_JRNL_LINES_UNPOSTED."JLU_ACCOUNT",
    SLR_JRNL_LINES_UNPOSTED."JLU_SEGMENT_1",
    SLR_JRNL_LINES_UNPOSTED."JLU_SEGMENT_2",
    SLR_JRNL_LINES_UNPOSTED."JLU_SEGMENT_3",
    SLR_JRNL_LINES_UNPOSTED."JLU_SEGMENT_4",
    SLR_JRNL_LINES_UNPOSTED."JLU_SEGMENT_5",
    SLR_JRNL_LINES_UNPOSTED."JLU_SEGMENT_6",
    SLR_JRNL_LINES_UNPOSTED."JLU_SEGMENT_7",
    SLR_JRNL_LINES_UNPOSTED."JLU_SEGMENT_8",
    SLR_JRNL_LINES_UNPOSTED."JLU_SEGMENT_9",
    SLR_JRNL_LINES_UNPOSTED."JLU_SEGMENT_10",
    SLR_JRNL_LINES_UNPOSTED."JLU_ATTRIBUTE_1",
    SLR_JRNL_LINES_UNPOSTED."JLU_ATTRIBUTE_2",
    SLR_JRNL_LINES_UNPOSTED."JLU_ATTRIBUTE_3",
    SLR_JRNL_LINES_UNPOSTED."JLU_ATTRIBUTE_4",
    SLR_JRNL_LINES_UNPOSTED."JLU_ATTRIBUTE_5",
    SLR_JRNL_LINES_UNPOSTED."JLU_REFERENCE_1",
    SLR_JRNL_LINES_UNPOSTED."JLU_REFERENCE_2",
    SLR_JRNL_LINES_UNPOSTED."JLU_REFERENCE_3",
    SLR_JRNL_LINES_UNPOSTED."JLU_REFERENCE_4",
    SLR_JRNL_LINES_UNPOSTED."JLU_REFERENCE_5",
    SLR_JRNL_LINES_UNPOSTED."JLU_REFERENCE_6",
    SLR_JRNL_LINES_UNPOSTED."JLU_REFERENCE_7",
    SLR_JRNL_LINES_UNPOSTED."JLU_REFERENCE_8",
    SLR_JRNL_LINES_UNPOSTED."JLU_REFERENCE_9",
    SLR_JRNL_LINES_UNPOSTED."JLU_REFERENCE_10",
    SLR_JRNL_LINES_UNPOSTED."JLU_TRAN_CCY",
    SLR_JRNL_LINES_UNPOSTED."JLU_TRAN_AMOUNT",
    SLR_JRNL_LINES_UNPOSTED."JLU_BASE_RATE",
    SLR_JRNL_LINES_UNPOSTED."JLU_BASE_CCY",
    SLR_JRNL_LINES_UNPOSTED."JLU_BASE_AMOUNT",
    SLR_JRNL_LINES_UNPOSTED."JLU_LOCAL_RATE",
    SLR_JRNL_LINES_UNPOSTED."JLU_LOCAL_CCY",
    SLR_JRNL_LINES_UNPOSTED."JLU_LOCAL_AMOUNT",
    SLR_JRNL_LINES_UNPOSTED."JLU_CREATED_BY",
    SLR_JRNL_LINES_UNPOSTED."JLU_CREATED_ON",
    SLR_JRNL_LINES_UNPOSTED."JLU_AMENDED_BY",
    SLR_JRNL_LINES_UNPOSTED."JLU_AMENDED_ON",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_TYPE",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_DATE",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_DESCRIPTION",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_SOURCE",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_SOURCE_JRNL_ID",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_AUTHORISED_BY",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_AUTHORISED_ON",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_VALIDATED_BY",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_VALIDATED_ON",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_POSTED_BY",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_POSTED_ON",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_TOTAL_HASH_DEBIT",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_TOTAL_HASH_CREDIT",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_PREF_STATIC_SRC",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_REF_ID",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_REV_DATE",
    SLR_JRNL_LINES_UNPOSTED."JLU_TRANSLATION_DATE",
    SLR_JRNL_LINES_UNPOSTED."JLU_PERIOD_MONTH",
    SLR_JRNL_LINES_UNPOSTED."JLU_PERIOD_YEAR",
    SLR_JRNL_LINES_UNPOSTED."JLU_PERIOD_LTD",
    SLR_JRNL_LINES_UNPOSTED."JLU_JRNL_INTERNAL_PERIOD_FLAG",
    EJT_BALANCE_TYPE_2 JT_BALANCE_TYPE,
    to_number(to_char(SLR_JRNL_LINES_UNPOSTED."JLU_EFFECTIVE_DATE",'Q')) as JLU_PERIOD_QTR
FROM
    SLR_JRNL_LINES_UNPOSTED JOIN slr_ext_jrnl_types
    ON EJT_TYPE = JLU_JRNL_TYPE
    AND EJT_BALANCE_TYPE_2 IS NOT NULL;
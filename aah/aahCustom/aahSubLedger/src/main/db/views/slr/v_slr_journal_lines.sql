CREATE OR REPLACE FORCE EDITIONABLE VIEW SLR.V_SLR_JOURNAL_LINES ("JL_JRNL_HDR_ID", "JL_JRNL_LINE_NUMBER", "JL_FAK_ID", "JL_EBA_ID", "JL_JRNL_STATUS", "JL_JRNL_STATUS_TEXT", "JL_JRNL_PROCESS_ID", "JL_DESCRIPTION", "JL_SOURCE_JRNL_ID", "JL_EFFECTIVE_DATE", "JL_VALUE_DATE", "JL_ENTITY", "JL_EPG_ID", "JL_ACCOUNT", "JL_SEGMENT_1", "JL_SEGMENT_2", "JL_SEGMENT_3", "JL_SEGMENT_4", "JL_SEGMENT_5", "JL_SEGMENT_6", "JL_SEGMENT_7", "JL_SEGMENT_8", "JL_SEGMENT_9", "JL_SEGMENT_10", "JL_ATTRIBUTE_1", "JL_ATTRIBUTE_2", "JL_ATTRIBUTE_3", "JL_ATTRIBUTE_4", "JL_ATTRIBUTE_5", "JL_REFERENCE_1", "JL_REFERENCE_2", "JL_REFERENCE_3", "JL_REFERENCE_4", "JL_REFERENCE_5", "JL_REFERENCE_6", "JL_REFERENCE_7", "JL_REFERENCE_8", "JL_REFERENCE_9", "JL_REFERENCE_10", "JL_TRAN_CCY", "JL_TRAN_AMOUNT", "JL_BASE_RATE", "JL_BASE_CCY", "JL_BASE_AMOUNT", "JL_LOCAL_RATE", "JL_LOCAL_CCY", "JL_LOCAL_AMOUNT", "JL_CREATED_BY", "JL_CREATED_ON", "JL_AMENDED_BY", "JL_AMENDED_ON", "JL_RECON_STATUS", "JL_TRANSLATION_DATE", "JL_BUS_POSTING_DATE", "JL_PERIOD_MONTH", "JL_PERIOD_YEAR", "JL_PERIOD_LTD", "JL_TYPE", "JL_PERIOD_QTR") AS 
SELECT  JL_JRNL_HDR_ID,
        JL_JRNL_LINE_NUMBER,
        JL_FAK_ID,
        JL_EBA_ID,
        JL_JRNL_STATUS,
        JL_JRNL_STATUS_TEXT,
        JL_JRNL_PROCESS_ID,
        JL_DESCRIPTION,
        JL_SOURCE_JRNL_ID,
        JL_EFFECTIVE_DATE,
        JL_VALUE_DATE,
        JL_ENTITY,
        JL_EPG_ID,
        JL_ACCOUNT,
        JL_SEGMENT_1,
        JL_SEGMENT_2,
        JL_SEGMENT_3,
        JL_SEGMENT_4,
        JL_SEGMENT_5,
        JL_SEGMENT_6,
        JL_SEGMENT_7,
        JL_SEGMENT_8,
        JL_SEGMENT_9,
        JL_SEGMENT_10,
        JL_ATTRIBUTE_1,
        JL_ATTRIBUTE_2,
        JL_ATTRIBUTE_3,
        JL_ATTRIBUTE_4,
        JL_ATTRIBUTE_5,
        JL_REFERENCE_1,
        JL_REFERENCE_2,
        JL_REFERENCE_3,
        JL_REFERENCE_4,
        JL_REFERENCE_5,
        JL_REFERENCE_6,
        JL_REFERENCE_7,
        JL_REFERENCE_8,
        JL_REFERENCE_9,
        JL_REFERENCE_10,
        JL_TRAN_CCY,
        JL_TRAN_AMOUNT,
        JL_BASE_RATE,
        JL_BASE_CCY,
        JL_BASE_AMOUNT,
        JL_LOCAL_RATE,
        JL_LOCAL_CCY,
        JL_LOCAL_AMOUNT,
        JL_CREATED_BY,
        JL_CREATED_ON,
        JL_AMENDED_BY,
        JL_AMENDED_ON,
        JL_RECON_STATUS,
        JL_TRANSLATION_DATE,
        JL_BUS_POSTING_DATE,
        JL_PERIOD_MONTH,
        JL_PERIOD_YEAR,
        JL_PERIOD_LTD,
        JL_TYPE,
        TO_NUMBER(TO_CHAR(JL_EFFECTIVE_DATE,'Q')) AS JL_PERIOD_QTR
FROM SLR_JRNL_LINES;
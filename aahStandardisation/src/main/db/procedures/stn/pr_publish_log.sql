CREATE OR REPLACE PROCEDURE stn.pr_publish_log
(
    log_table IN VARCHAR2 DEFAULT 'STN.STANDARDISATION_LOG'
)
AS
    dynamic_log_sql varchar2(10000);
BEGIN

    dynamic_log_sql := 'INSERT INTO fdr.FR_LOG
                (LO_EVENT_DATETIME, LO_EVENT_TYPE_ID, LO_ERROR_STATUS, LO_CATEGORY_ID, LO_EVENT_TEXT, LO_TABLE_IN_ERROR_NAME, LO_ROW_IN_ERROR_KEY_ID, LO_FIELD_IN_ERROR_NAME, LO_ERROR_TECHNOLOGY, LO_ERROR_RULE_IDENT, LO_ERROR_VALUE, LO_TODAYS_BUS_DATE, LO_SOURCE_SYSTEM, LO_PROCESSING_STAGE, LO_OWNER, LO_CLIENT_SPARE01, LO_CLIENT_SPARE02, LPG_ID, LO_CLIENT_SPARE03, LO_ERROR_CLIENT_KEY_NO)
                SELECT
                    CURRENT_DATE AS LO_EVENT_DATETIME,
                    stdl.EVENT_TYPE AS LO_EVENT_TYPE_ID,
                    stdl.ERROR_STATUS AS LO_ERROR_STATUS,
                    stdl.CATEGORY_ID AS LO_CATEGORY_ID,
                    stdl.EVENT_TEXT AS LO_EVENT_TEXT,
                    stdl.TABLE_IN_ERROR_NAME AS LO_TABLE_IN_ERROR_NAME,
                    stdl.ROW_IN_ERROR_KEY_ID AS LO_ROW_IN_ERROR_KEY_ID,
                    stdl.FIELD_IN_ERROR_NAME AS LO_FIELD_IN_ERROR_NAME,
                    stdl.ERROR_TECHNOLOGY AS LO_ERROR_TECHNOLOGY,
                    stdl.RULE_IDENTITY AS LO_ERROR_RULE_IDENT,
                    stdl.ERROR_VALUE AS LO_ERROR_VALUE,
                    stdl.TODAYS_BUSINESS_DT AS LO_TODAYS_BUS_DATE,
                    stdl.SOURCE_CD AS LO_SOURCE_SYSTEM,
                    stdl.PROCESSING_STAGE AS LO_PROCESSING_STAGE,
                    stdl.OWNER AS LO_OWNER,
                    TO_CHAR(stdl.STEP_RUN_SID) AS LO_CLIENT_SPARE01,
                    stdl.CODE_MODULE_NM AS LO_CLIENT_SPARE02,
                    stdl.LPG_ID AS LPG_ID,
                    TO_CHAR(stdl.FEED_SID) AS LO_CLIENT_SPARE03,
                    stdl.ROW_IN_ERROR_KEY_ID AS LO_ERROR_CLIENT_KEY_NO
                FROM ' || log_table || ' stdl';
    
    EXECUTE IMMEDIATE dynamic_log_sql;
    
END;    



/
CREATE GLOBAL TEMPORARY TABLE rdr.rr_glint_temp_journal_line 
(
  JH_JRNL_ID           NUMBER(18)               NOT NULL,
  JL_JRNL_LINE_NUMBER  NUMBER(18),
  RGJ_ID               VARCHAR2(30 BYTE)        NOT NULL,
  RGBC_ID              NUMBER(18)               NOT NULL,
  RGBC_LOAD_TYPE       VARCHAR2(20 BYTE),
  RGBC_PROCESS_TYPE    VARCHAR2(20 BYTE),
  PREVIOUS_FLAG        CHAR(1 BYTE),
  AGGREGATE_LINE_FLAG  CHAR(1 BYTE),
  GL_DISTRIB_STATUS    CHAR(1 BYTE),
  APPL_JRNL_ID         VARCHAR2(10 BYTE),
  BUSINESS_UNIT_GL     VARCHAR2(5 BYTE),
  BUSINESS_UNIT        VARCHAR2(5 BYTE),
  LEDGER_GROUP         VARCHAR2(10 BYTE),
  LEDGER               VARCHAR2(10 BYTE),
  JOURNAL_ID           VARCHAR2(10 BYTE),
  JOURNAL_DATE         DATE,
  JOURNAL_LINE         NUMBER(9),
  ACCOUNTING_DT        DATE,
  FISCAL_YEAR          NUMBER(4),
  ACCOUNTING_PERIOD    NUMBER(3),
  FOREIGN_CURRENCY     VARCHAR2(3 BYTE),
  FOREIGN_AMOUNT       NUMBER(23,3),
  CURRENCY_CD          VARCHAR2(3 BYTE),
  MONETARY_AMOUNT      NUMBER(23,3),
  ACCOUNT              VARCHAR2(10 BYTE),
  DEPTID               VARCHAR2(10 BYTE),
  PRODUCT              VARCHAR2(6 BYTE),
  AFFILIATE            VARCHAR2(5 BYTE),
  PROGRAM_CODE         VARCHAR2(5 BYTE),
  CHARTFIELD1          VARCHAR2(10 BYTE),
  LINE_DESCR           VARCHAR2(30 BYTE),
  JRNL_LN_REF          VARCHAR2(10 BYTE),
  PROCESS_INSTANCE     NUMBER(10),
  NOTES_254            VARCHAR2(256 BYTE)     ,
  DTTM_STAMP           DATE,
  EVENT_CLASS          VARCHAR2(30 BYTE)       ,
  AAH_JRNL_HDR_NBR     NUMBER(10)              ,
  CREDIT_AMT           NUMBER(23,3),
  DEBIT_AMT            NUMBER(23,3),
  EVENT_STATUS         CHAR(1 BYTE)            ,
  SLR_PROCESS_ID       NUMBER(30),
  MANUAL_JE            CHAR(1 BYTE),
  PS_FILTER            CHAR(1 BYTE)         
) ON COMMIT DELETE ROWS ;

 
COMMENT ON TABLE RDR.RR_GLINT_TEMP_JOURNAL_LINE IS 'Temporary table to hold the non-aggregated journal lines that will be sent to the GL for a particular interface run.
Amend the custom columns within this table as per the changes made in RR_GLINT_JOURNAL_LINE. The default custom column list is for an Oracle GL.';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.JH_JRNL_ID IS 'The AAH Journal Internal Identifier (RCV_GLINT_JOURNAL).
Core Column.';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.JL_JRNL_LINE_NUMBER IS 'The AAH Journal Line Number (for non-aggregated lines - RCV_GLINT_JOURNAL_LINE).
Core Column.';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.RGJ_ID IS 'The Journal Identifier as it will appear in the GL (RR_GLINT_JOURNAL).
Core Column.';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.RGBC_ID IS 'The unique batch identifier (RR_GLINT_BATCH_CONTROL).
Core Column.';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.RGBC_LOAD_TYPE IS 'The load type for the batch (RR_GLINT_BATCH_CONTROL).
Core Column.';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.RGBC_PROCESS_TYPE IS 'The process type for the batch (RR_GLINT_BATCH_CONTROL).
Core Column.';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.PREVIOUS_FLAG IS 'Whether this AAH journal has been previously sent to the GL (''Y'') or not (''N'').
Core Column.';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.AGGREGATE_LINE_FLAG IS 'Whether the line should be aggregated (when possible).
Core Column.';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.GL_DISTRIB_STATUS IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.APPL_JRNL_ID IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.BUSINESS_UNIT_GL IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.BUSINESS_UNIT IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.LEDGER_GROUP IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.LEDGER IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.JOURNAL_ID IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.JOURNAL_DATE IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.JOURNAL_LINE IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.ACCOUNTING_DT IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.FISCAL_YEAR IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.ACCOUNTING_PERIOD IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.FOREIGN_CURRENCY IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.FOREIGN_AMOUNT IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.CURRENCY_CD IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.MONETARY_AMOUNT IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.ACCOUNT IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.DEPTID IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.PRODUCT IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.AFFILIATE IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.PROGRAM_CODE IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.CHARTFIELD1 IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.LINE_DESCR IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.JRNL_LN_REF IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.PROCESS_INSTANCE IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.NOTES_254 IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.DTTM_STAMP IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.EVENT_CLASS IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.AAH_JRNL_HDR_NBR IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.CREDIT_AMT IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.DEBIT_AMT IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.EVENT_STATUS IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.MANUAL_JE IS 'Custom Column';

COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL_LINE.PS_FILTER IS 'Custom Column';
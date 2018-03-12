CREATE TABLE rdr.rr_glint_journal_line 
   (	"RGJL_ID" NUMBER(18,0) NOT NULL ENABLE, 
	"RGJL_RGJ_ID" VARCHAR2(30 BYTE) NOT NULL ENABLE, 
	"RGJL_RGJ_RGBC_ID" NUMBER(18,0) NOT NULL ENABLE, 
	"RGJL_AAH_JOURNAL" NUMBER(18,0), 
	"RGJL_AAH_JOURNAL_LINE" NUMBER(18,0), 
	"INPUT_TIME" DATE DEFAULT sysdate NOT NULL ENABLE, 
	"INPUT_USER" VARCHAR2(30 BYTE) DEFAULT user NOT NULL ENABLE, 
	"MODIFIED_TIME" DATE DEFAULT sysdate NOT NULL ENABLE, 
	"MODIFIED_USER" VARCHAR2(30 BYTE) DEFAULT user NOT NULL ENABLE, 
	"GL_DISTRIB_STATUS" VARCHAR2(1 BYTE), 
	"APPL_JRNL_ID" VARCHAR2(20 BYTE), 
	"BUSINESS_UNIT_GL" VARCHAR2(20 BYTE), 
	"BUSINESS_UNIT" VARCHAR2(3 BYTE), 
	"LEDGER_GROUP" VARCHAR2(20 BYTE), 
	"LEDGER" VARCHAR2(20 BYTE), 
	"JOURNAL_ID" VARCHAR2(20 BYTE), 
	"JOURNAL_DATE" DATE, 
	"JOURNAL_LINE" VARCHAR2(20 BYTE), 
	"ACCOUNTING_DT" DATE, 
	"FISCAL_YEAR" VARCHAR2(4 BYTE), 
	"ACCOUNTING_PERIOD" VARCHAR2(20 BYTE), 
	"FOREIGN_CURRENCY" VARCHAR2(20 BYTE), 
	"FOREIGN_AMOUNT" NUMBER(12,2), 
	"CURRENCY_CD" VARCHAR2(20 BYTE), 
	"MONETARY_AMOUNT" NUMBER(12,2), 
	"ACCOUNT" VARCHAR2(256 BYTE), 
	"DEPTID" VARCHAR2(256 BYTE), 
	"PRODUCT" VARCHAR2(256 BYTE), 
	"AFFILIATE" VARCHAR2(256 BYTE), 
	"PROGRAM_CODE" VARCHAR2(256 BYTE), 
	"CHARTFIELD1" VARCHAR2(20 BYTE), 
	"LINE_DESCR" VARCHAR2(256 BYTE), 
	"JRNL_LN_REF" VARCHAR2(256 BYTE), 
	"PROCESS_INSTANCE" VARCHAR2(20 BYTE), 
	"GL_POST_K" VARCHAR2(256 BYTE), 
	"GL_ENTRY_LINE" VARCHAR2(256 BYTE), 
	"NOTES_254" VARCHAR2(256 BYTE), 
	"DTTM_STAMP" VARCHAR2(20 BYTE), 
	"EVENT_GROUP" VARCHAR2(256 BYTE), 
	 CONSTRAINT "XPK_GLINT_JOURNAL_LINE" PRIMARY KEY ("RGJL_ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "RDR_DATA"  ENABLE, 
	 CONSTRAINT "GLINT_J_JL" FOREIGN KEY ("RGJL_RGJ_RGBC_ID", "RGJL_RGJ_ID")
	  REFERENCES "RDR"."RR_GLINT_JOURNAL" ("RGJ_RGBC_ID", "RGJ_ID") ENABLE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "RDR_DATA" ;
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."RGJL_ID" IS 'The unique identifier for the journal line.
Core Column.';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."RGJL_RGJ_ID" IS 'The Journal Identifier as it will appear in the GL (RR_GLINT_JOURNAL).
Core Column.';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."RGJL_RGJ_RGBC_ID" IS 'The unique batch identifier (RR_GLINT_BATCH_CONTROL).
Core Column.';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."RGJL_AAH_JOURNAL" IS 'If this line has been directly mapped from a SLR Journal Line, then this will be populated with the SLR Journal Identifier.
Core Column.';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."RGJL_AAH_JOURNAL_LINE" IS 'If this line has been directly mapped from a SLR Journal Line, then this will be populated with the SLR Journal Line Number.
Core Column.';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."INPUT_TIME" IS 'Date/Time the record was first inserted.
Core Column.';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."INPUT_USER" IS 'User/Process that created the record.
Core Column.';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."MODIFIED_TIME" IS 'Date/Time the record was last updated.
Core Column.';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."MODIFIED_USER" IS 'User/Process that last updated the record.
Core Column.';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."GL_DISTRIB_STATUS" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."APPL_JRNL_ID" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."BUSINESS_UNIT_GL" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."BUSINESS_UNIT" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."LEDGER_GROUP" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."LEDGER" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."JOURNAL_ID" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."JOURNAL_DATE" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."JOURNAL_LINE" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."ACCOUNTING_DT" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."FISCAL_YEAR" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."ACCOUNTING_PERIOD" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."FOREIGN_CURRENCY" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."FOREIGN_AMOUNT" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."CURRENCY_CD" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."MONETARY_AMOUNT" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."ACCOUNT" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."DEPTID" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."PRODUCT" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."AFFILIATE" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."PROGRAM_CODE" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."CHARTFIELD1" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."LINE_DESCR" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."JRNL_LN_REF" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."PROCESS_INSTANCE" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."GL_POST_K" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."GL_ENTRY_LINE" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."NOTES_254" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."DTTM_STAMP" IS 'Custom Column';
   COMMENT ON COLUMN "RDR"."RR_GLINT_JOURNAL_LINE"."EVENT_GROUP" IS 'Custom Column';
   COMMENT ON TABLE "RDR"."RR_GLINT_JOURNAL_LINE"  IS 'Stores each of the journal lines that is to be sent to the GL.
Amend the custom columns within this table (and RR_GLINT_TEMP_JOURNAL_LINE) according to the specific General Ledger that is used. The default custom column list is for an Oracle GL.';
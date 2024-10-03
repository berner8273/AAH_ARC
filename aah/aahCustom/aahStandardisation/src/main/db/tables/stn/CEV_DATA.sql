DROP TABLE STN.CEV_DATA CASCADE CONSTRAINTS;

CREATE TABLE STN.CEV_DATA
(
  GAAP_FUT_ACCTS_FLAG            VARCHAR2(1 CHAR),
  LE_FLAG                        VARCHAR2(1 CHAR),
  BUSINESS_TYPE_ASSOCIATION_ID   NUMBER,
  INTERCOMPANY_ASSOCIATION_ID    NUMBER,
  GAAP_FUT_ACCTS_ASSOCIATION_ID  NUMBER,
  BASIS_ASSOCIATION_ID           NUMBER,
  CORRELATION_UUID               RAW(16),
  EVENT_SEQ_ID                   NUMBER(38),
  ROW_SID                        NUMBER(38),
  INPUT_BASIS_ID                 NUMBER(38),
  INPUT_BASIS_CD                 VARCHAR2(20 CHAR),
  PARTNER_BASIS_CD               VARCHAR2(7 CHAR),
  ACCOUNTING_DT                  DATE,
  EVENT_TYP                      VARCHAR2(30 CHAR),
  EVENT_TYP_ID                   NUMBER,
  BUSINESS_EVENT_TYP             VARCHAR2(50 CHAR),
  POLICY_ID                      VARCHAR2(40 CHAR),
  POLICY_ABBR_NM                 VARCHAR2(80 CHAR),
  STREAM_ID                      NUMBER(38),
  PARENT_STREAM_ID               VARCHAR2(80 CHAR),
  VIE_ID                         NUMBER(38),
  VIE_CD                         NUMBER(1),
  VIE_STATUS                     VARCHAR2(80 CHAR),
  VIE_EFFECTIVE_DT               DATE,
  VIE_ACCT_DT                    DATE,
  IS_MARK_TO_MARKET              VARCHAR2(20 CHAR),
  PREMIUM_TYP                    VARCHAR2(1 CHAR),
  POLICY_PREMIUM_TYP             VARCHAR2(80 CHAR),
  POLICY_ACCIDENT_YR             VARCHAR2(80 CHAR),
  POLICY_UNDERWRITING_YR         NUMBER(28,8),
  ULTIMATE_PARENT_STREAM_ID      VARCHAR2(80 CHAR),
  ULTIMATE_PARENT_LE_CD          VARCHAR2(80 CHAR),
  EXECUTION_TYP                  VARCHAR2(80 CHAR),
  POLICY_TYP                     VARCHAR2(80 CHAR),
  BUSINESS_TYP                   VARCHAR2(2 CHAR),
  GENERATE_INTERCO_ACCOUNTING    VARCHAR2(1 CHAR),
  BUSINESS_UNIT                  VARCHAR2(20 CHAR),
  AFFILIATE                      VARCHAR2(20 CHAR),
  OWNER_LE_CD                    VARCHAR2(20 CHAR),
  COUNTERPARTY_LE_CD             VARCHAR2(20 CHAR),
  INPUT_TRANSACTION_AMT          NUMBER(38,9),
  PARTNER_TRANSACTION_AMT        NUMBER,
  TRANSACTION_CCY                VARCHAR2(3 CHAR),
  INPUT_FUNCTIONAL_AMT           NUMBER(38,9),
  PARTNER_FUNCTIONAL_AMT         NUMBER,
  FUNCTIONAL_CCY                 VARCHAR2(3 CHAR),
  INPUT_REPORTING_AMT            NUMBER(38,9),
  PARTNER_REPORTING_AMT          NUMBER,
  REPORTING_CCY                  VARCHAR2(3 CHAR),
  LPG_ID                         NUMBER(38),
  ACCOUNT_CD                     VARCHAR2(20 BYTE),
  CHARTFIELD_1                   VARCHAR2(20 BYTE),
  JL_DESCRIPTION                 VARCHAR2(100 BYTE)
)
TABLESPACE STN_DATA
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


CREATE INDEX STN.IDX_CEV_DATA_COMP1 ON STN.CEV_DATA
(PREMIUM_TYP, CORRELATION_UUID, EVENT_TYP)
LOGGING
TABLESPACE STN_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOPARALLEL;


CREATE INDEX STN.IDX_CEV_DATA_COMP2 ON STN.CEV_DATA
(GAAP_FUT_ACCTS_FLAG, PREMIUM_TYP)
LOGGING
TABLESPACE STN_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOPARALLEL;


CREATE INDEX STN.I_CEV_DATA ON STN.CEV_DATA
(CORRELATION_UUID)
LOGGING
TABLESPACE STN_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOPARALLEL;


GRANT SELECT ON STN.CEV_DATA TO AAH_READ_ONLY;

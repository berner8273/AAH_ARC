create table slr.slr_fak_bop_amounts 
(
  FDB_FAK_ID NUMBER(12, 0) NOT NULL 
, FDB_BALANCE_DATE DATE NOT NULL 
, FDB_BALANCE_TYPE NUMBER(3, 0) NOT NULL 
, FDB_TRAN_BOP_MTD_BALANCE NUMBER(33, 3) 
, FDB_TRAN_BOP_QTD_BALANCE NUMBER(33, 3) 
, FDB_TRAN_BOP_YTD_BALANCE NUMBER(33, 3) 
, FDB_BASE_BOP_MTD_BALANCE NUMBER(33, 3) 
, FDB_BASE_BOP_QTD_BALANCE NUMBER(33, 3) 
, FDB_BASE_BOP_YTD_BALANCE NUMBER(33, 3) 
, FDB_LOCAL_BOP_MTD_BALANCE NUMBER(33, 3) 
, FDB_LOCAL_BOP_QTD_BALANCE NUMBER(33, 3) 
, FDB_LOCAL_BOP_YTD_BALANCE NUMBER(33, 3) 
, FDB_PERIOD_MONTH NUMBER(2, 0) NOT NULL 
, FDB_PERIOD_QTR NUMBER(1, 0) NOT NULL 
, FDB_PERIOD_YEAR NUMBER(4, 0) NOT NULL 
, FDB_PERIOD_LTD NUMBER(2, 0) NOT NULL 
, FDB_AMENDED_ON DATE NOT NULL 
, CONSTRAINT SLR_FAK_BOP_AMOUNTS_PK PRIMARY KEY 
  (
    FDB_FAK_ID 
  , FDB_BALANCE_DATE 
  , FDB_BALANCE_TYPE 
  )
  ENABLE 
);
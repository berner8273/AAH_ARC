CREATE OR REPLACE PACKAGE BODY FDR."FDR_CUSTOM_ARCHIVING_PKG" AS
---------------------------------------------------------------------------------
-- Id:          $Id: FDR_CUSTOM_ARCHIVING_PKG.sql,v 1 2012/06/18 16:03:51 abulgajewska Exp $
--
-- Description: Package containing procedures used during archiving process
--
---------------------------------------------------------------------------------
-- History:
-- 2012/06/18: basic version of package created
---------------------------------------------------------------------------------

/*************************************************************************************************************************
Custom procedure which will be executed by Automatic archiving process must cover following pattern:
Input parameters:
PROCEDURE pCUST_TemplateArchProc      (           pLPGId                    in FR_LPG_CONFIG.LC_LPG_ID%TYPE default NULL,
                                                  pBatchSize                in INTEGER DEFAULT NULL,
                                                  pARCT_ID                  in FR_ARCHIVE_CTL.ARCT_ID%TYPE DEFAULT NULL,
                                                  pArchRecCounter           out INTEGER
                                            );
Define custom errors:
    SUCCESSED EXCEPTION;
    PRAGMA EXCEPTION_INIT(SUCCESSED, -20998);

    PROCEED EXCEPTION;
    PRAGMA EXCEPTION_INIT(PROCEED, -20997);

and rise SUCCESS if automatic archivisation procedure must not be executed after this custom procedure execution
or
rise PROCEED if automatic archiving must be continued after that procedure is executed.
************************************************************************************************************************/

---------------------------------------------------------------------------------
-- Private package attributes
---------------------------------------------------------------------------------
gv_emsg     VARCHAR2(4000);
gv_ecode    NUMBER := -20999;
gc_nl		VARCHAR2(4) := chr(10);

PROCEDURE pCUST_RollFAKBalancesToME        (      pLPGId                    in FR_LPG_CONFIG.LC_LPG_ID%TYPE default NULL,
                                                  pBatchSize                in INTEGER DEFAULT NULL,
                                                  pARCT_ID                  in FR_ARCHIVE_CTL.ARCT_ID%TYPE,
                                                  pArchRecCounter           out INTEGER
                                            )
IS
	s_proc_name varchar2(60):= 'FDR_CUSTOM_ARCHIVING_PKG.pCUST_RollFAKBalancesToME';

    cnrl_tbl_list   CNTRL_TABLE_ARRAY;

    TYPE ENTITY_ARRAY IS TABLE OF FR_LPG_CONFIG.LC_GRP_CODE%TYPE;
    entity_list ENTITY_ARRAY;

    lvBusinessDate  DATE;
    lvArchDate      DATE;
    lvMaxPeriod     DATE;
    lvPeriodCounter INTEGER;

    lvProcessedRecCounter INTEGER;

    --EXCEPTIONS
    SUCCESSED EXCEPTION;
    PRAGMA EXCEPTION_INIT(SUCCESSED, -20998);

    PROCEED EXCEPTION;
    PRAGMA EXCEPTION_INIT(PROCEED, -20997);
	lvColumnEPG varchar2(100);
	lvColumnEPG2 varchar2(100);
BEGIN

    BEGIN
    cnrl_tbl_list := CNTRL_TABLE_ARRAY();

    pLoadArchCntrList( pARCT_ID, cnrl_tbl_list);
    --dbms_output.disable;
		SELECT ARCT_ENTITY_COLUMN_NAME, ARCT_LPG_COLUMN_NAME INTO lvColumnEPG,lvColumnEPG2 FROM FR_ARCHIVE_CTL WHERE ARCT_ID = pARCT_ID;
    IF (/*cnrl_tbl_list(1).ARCT_ARCHIVE_DATE_COLUMN IS NOT NULL AND */ cnrl_tbl_list(1).ARCT_ARCHIVE_DAYS IS NOT NULL)
    THEN
        SELECT GP_TODAYS_BUS_DATE
        INTO lvBusinessDate
        FROM FR_GLOBAL_PARAMETER
        WHERE COALESCE(pLPGId,1) = LPG_ID;

        lvArchDate := lvBusinessDate - cnrl_tbl_list(1).ARCT_ARCHIVE_DAYS;

        IF pLPGId IS NOT NULL AND (lvColumnEPG IS NOT NULL or lvColumnEPG2 IS NOT NULL)
        THEN
		SELECT DISTINCT EPG_ENTITY  BULK COLLECT INTO entity_list FROM SLR_ENTITY_PROC_GROUP WHERE EPG_ID  IN
		(SELECT EPG_ID FROM SLR_ENTITY_PROC_GROUP WHERE EPG_ENTITY  IN (SELECT LC_GRP_CODE  FROM FR_LPG_CONFIG WHERE LC_LPG_ID = pLPGId));

        ELSE
            SELECT ENT_ENTITY BULK COLLECT INTO entity_list FROM SLR_ENTITIES;
        END IF;

        IF entity_list.COUNT > 0
        THEN
            FOR indx IN entity_list.FIRST..entity_list.LAST
            LOOP
                SELECT count(*)
                INTO lvPeriodCounter
                FROM SLR_ENTITY_PERIODS
                    WHERE EP_ENTITY = entity_list(indx)
                    AND EP_PERIOD_TYPE != 0
                    AND EP_STATUS = 'C'
                    AND EP_BUS_PERIOD_END < lvArchDate;

                 -- check if any closed period exists
                IF lvPeriodCounter != 0 THEN

                    -- find max closed period end date prior archiving date
                    SELECT MAX(EP_BUS_PERIOD_END)
                    INTO lvMaxPeriod
                    FROM SLR_ENTITY_PERIODS
                        WHERE EP_ENTITY = entity_list(indx)
                        AND EP_PERIOD_TYPE != 0
                        AND EP_STATUS = 'C'
                        AND EP_BUS_PERIOD_END < lvArchDate;

                        pRollFAKBalancesToME_full(entity_list(indx),pBatchSize,lvMaxPeriod,pArchRecCounter);

                    --pRollFAKBalancesToME(entity_list(indx),pBatchSize,lvMaxPeriod,pArchRecCounter);

                    COMMIT;  -- after each ENTITY

                 END IF;

            END LOOP;
          END IF;
    END IF;

	EXCEPTION
        WHEN OTHERS THEN
			--gv_ecode := SQLCODE;
            gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
            RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);
    END;

    pArchRecCounter := 0;
    RAISE PROCEED;

END pCUST_RollFAKBalancesToME;

PROCEDURE pRollFAKBalancesToME              (         pEntity                   in SLR_ENTITIES.ENT_ENTITY%type,
                                                      pBatchSize                in INTEGER DEFAULT NULL,
                                                      pDate                     in FR_GLOBAL_PARAMETER.gp_todays_bus_date%type,
                                                      pArchRecCounter           out INTEGER
                                                )
IS
    s_proc_name varchar2(60):= 'FDR_CUSTOM_ARCHIVING_PKG.pRollFAKBalancesToME';

    TYPE PERIOD_RECORD IS RECORD
        (   EP_BUS_YEAR             SLR_ENTITY_PERIODS.EP_BUS_YEAR%type,
            EP_BUS_PERIOD           SLR_ENTITY_PERIODS.EP_BUS_PERIOD%type
        ) ;

    TYPE periods_array IS TABLE OF PERIOD_RECORD;
    periods_list periods_array;

    lvAffectedRecCount INTEGER;

BEGIN

        -- find all periods which can be affected by roll balances to ME procedure
        SELECT
                EP_BUS_YEAR,
                EP_BUS_PERIOD
        BULK COLLECT
        INTO periods_list
            FROM SLR_ENTITY_PERIODS
        WHERE EP_ENTITY = pEntity
            AND EP_PERIOD_TYPE != 0
            AND EP_STATUS = 'C'
            AND EP_BUS_PERIOD_END <= pDate
        ORDER BY  EP_BUS_YEAR, EP_BUS_PERIOD ASC;

        lvAffectedRecCount :=0;

        IF periods_list.count > 0 THEN
            FOR indx IN periods_list.FIRST..periods_list.LAST
            LOOP
                pRollFAKBalancesToME(pEntity,pBatchSize,periods_list(indx).EP_BUS_YEAR, periods_list(indx).EP_BUS_PERIOD, pArchRecCounter);
                lvAffectedRecCount := lvAffectedRecCount + pArchRecCounter;
                IF lvAffectedRecCount >= Nvl(pBatchSize,0)
                THEN
                    COMMIT;
                    lvAffectedRecCount := 0;
                END IF;
            END LOOP;
         END IF;

 EXCEPTION
        WHEN OTHERS THEN
			--gv_ecode := SQLCODE;
            gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
            RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);

END pRollFAKBalancesToME;

PROCEDURE pRollFAKBalancesToME              (         pEntity                   in SLR_ENTITIES.ENT_ENTITY%type,
                                                      pBatchSize                in INTEGER DEFAULT NULL,
                                                      pYear                     in SLR_ENTITY_PERIODS.ep_bus_year%type,
                                                      pPeriod                   in SLR_ENTITY_PERIODS.ep_bus_period%type,
                                                      pArchRecCounter           out INTEGER
                                                )
IS
    s_proc_name varchar2(60):= 'FDR_CUSTOM_ARCHIVING_PKG.pRollFAKBalancesToME';

    lvBusPeriodStart_ID      NUMBER(10,0);
    lvBusPeriodEnd_ID        NUMBER(10,0);

    lvBusPeriodStart         SLR_ENTITY_PERIODS.EP_BUS_PERIOD_START%type;
    lvBusPeriodEnd           SLR_ENTITY_PERIODS.EP_BUS_PERIOD_END%type;

    lvAffectedRecCount INTEGER;

BEGIN

        SELECT
                EP_BUS_PERIOD_START,
                EP_BUS_PERIOD_END,
                to_number(to_char(EP_BUS_PERIOD_START,'YYYYMMDD')) * 100,
                (to_number(to_char(EP_BUS_PERIOD_END,'YYYYMMDD')) * 100) + 99
            INTO     lvBusPeriodStart, lvBusPeriodEnd, lvBusPeriodStart_ID, lvBusPeriodEnd_ID
            FROM SLR_ENTITY_PERIODS
        WHERE
            EP_BUS_YEAR = pYear
            AND EP_BUS_PERIOD = pPeriod
            AND EP_PERIOD_TYPE != 0
            AND EP_STATUS = 'C'
            AND EP_ENTITY = pEntity;

        INSERT INTO SLR_FAK_DAILY_BALANCES
        (
             FDB_FAK_ID
            ,FDB_BALANCE_DATE
            ,FDB_BALANCE_TYPE
            ,FDB_TRAN_DAILY_MOVEMENT
            ,FDB_TRAN_MTD_BALANCE
            ,FDB_TRAN_YTD_BALANCE
            ,FDB_TRAN_LTD_BALANCE
            ,FDB_BASE_DAILY_MOVEMENT
            ,FDB_BASE_MTD_BALANCE
            ,FDB_BASE_YTD_BALANCE
            ,FDB_BASE_LTD_BALANCE
            ,FDB_LOCAL_DAILY_MOVEMENT
            ,FDB_LOCAL_MTD_BALANCE
            ,FDB_LOCAL_YTD_BALANCE
            ,FDB_LOCAL_LTD_BALANCE
            ,FDB_ENTITY
            ,FDB_EPG_ID
			,FDB_PERIOD_MONTH
            ,FDB_PERIOD_YEAR
            ,FDB_PERIOD_LTD
             ,FDB_PROCESS_ID
            ,FDB_TRAN_QTD_BALANCE
            ,FDB_BASE_QTD_BALANCE
            ,FDB_LOCAL_QTD_BALANCE
            ,FDB_PERIOD_QTR
        )
        SELECT
             FDB_FAK_ID
            ,lvBusPeriodEnd
            ,FDB_BALANCE_TYPE
            ,0
            ,FDB_TRAN_MTD_BALANCE
            ,FDB_TRAN_YTD_BALANCE
            ,FDB_TRAN_LTD_BALANCE
            ,0
            ,FDB_BASE_MTD_BALANCE
            ,FDB_BASE_YTD_BALANCE
            ,FDB_BASE_LTD_BALANCE
            ,0
            ,FDB_LOCAL_MTD_BALANCE
            ,FDB_LOCAL_YTD_BALANCE
            ,FDB_LOCAL_LTD_BALANCE
            ,pEntity
            ,fdb1.FDB_EPG_ID
			,fdb1.FDB_PERIOD_MONTH
             ,fdb1.FDB_PERIOD_YEAR
             ,fdb1.FDB_PERIOD_LTD
            ,fdb1.FDB_PROCESS_ID
            ,FDB_TRAN_QTD_BALANCE
            ,FDB_BASE_QTD_BALANCE
            ,FDB_LOCAL_QTD_BALANCE
            ,FDB_PERIOD_QTR
    FROM SLR_FAK_DAILY_BALANCES fdb1
    WHERE
        FDB_ENTITY = pEntity
        AND FDB_EPG_ID IN (SELECT EPG_ID FROM SLR_ENTITY_PROC_GROUP WHERE EPG_ENTITY = FDB_ENTITY)
        AND TO_CHAR(FDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(FDB_BALANCE_TYPE) >= lvBusPeriodStart_ID
        AND TO_CHAR(FDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(FDB_BALANCE_TYPE) <= lvBusPeriodEnd_ID
        AND FDB_BALANCE_TYPE != 10
        AND TO_CHAR(FDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(FDB_BALANCE_TYPE) =
								( SELECT MAX(TO_CHAR(FDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(FDB_BALANCE_TYPE))
                                 FROM SLR_FAK_DAILY_BALANCES fdb
                                 WHERE fdb1.FDB_BALANCE_TYPE = fdb.FDB_BALANCE_TYPE
                                       AND fdb1.FDB_FAK_ID = fdb.FDB_FAK_ID
                                       AND TO_CHAR(fdb.FDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(fdb.FDB_BALANCE_TYPE) >= lvBusPeriodStart_ID
                                       AND TO_CHAR(fdb.FDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(fdb.FDB_BALANCE_TYPE) <= lvBusPeriodEnd_ID
                                       AND fdb1.FDB_ENTITY = fdb.FDB_ENTITY
                                       AND fdb1.FDB_EPG_ID = fdb.FDB_EPG_ID
                                )
        AND FDB_BALANCE_DATE  !=  lvBusPeriodEnd;


    pArchRecCounter := Nvl(pArchRecCounter,0) + SQL%ROWCOUNT;

 EXCEPTION
        WHEN OTHERS THEN
			--gv_ecode := SQLCODE;
            gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
            RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);

END pRollFAKBalancesToME;

PROCEDURE pRollFAKBalancesToME_full              (    pEntity                   in SLR_ENTITIES.ENT_ENTITY%type,
                                                      pBatchSize                in INTEGER DEFAULT NULL,
                                                      pDate                     in FR_GLOBAL_PARAMETER.gp_todays_bus_date%type,
                                                      pArchRecCounter           out INTEGER
                                                )
IS
    s_proc_name varchar2(60):= 'FDR_CUSTOM_ARCHIVING_PKG.pRollFAKBalancesToME_full';

    lvAffectedRecCount INTEGER;

    CURSOR cJrnTypes is
  SELECT DISTINCT EJT_BALANCE_TYPE_1 BAL_TYPE
  FROM SLR_EXT_JRNL_TYPES
    WHERE EJT_BALANCE_TYPE_1 != 10
  UNION
    SELECT DISTINCT EJT_BALANCE_TYPE_2 BAL_TYPE
  FROM SLR_EXT_JRNL_TYPES
    WHERE EJT_BALANCE_TYPE_2 != 10;

    TYPE jrnl_bal_types_array IS TABLE OF cJrnTypes%rowtype;
    jrnl_bal_types_list jrnl_bal_types_array;

BEGIN

        open cJrnTypes;
		fetch cJrnTypes bulk collect INTO jrnl_bal_types_list;
        close cJrnTypes;

         IF jrnl_bal_types_list.COUNT > 0 THEN

        	FOR s IN jrnl_bal_types_list.FIRST .. jrnl_bal_types_list.LAST
            LOOP
                INSERT INTO SLR_ENTITY_PERIODS_TMP_DEF
                (
                    EP_ENTITY,
                    EP_BUS_PERIOD_START,
                    EP_BUS_PERIOD_END,
                    EP_BUS_PERIOD_START_ID,
                    EP_BUS_PERIOD_END_ID,
                    EP_BAL_TYPE,
                    EP_ARC_DATE_ID
                )
                SELECT
                    EP_ENTITY,
                    EP_BUS_PERIOD_START,
                    EP_BUS_PERIOD_END,
                    EXTRACT(YEAR FROM EP_BUS_PERIOD_START) * 1000000 + EXTRACT(MONTH FROM EP_BUS_PERIOD_START) * 10000 + EXTRACT(DAY FROM EP_BUS_PERIOD_START) * 100 + jrnl_bal_types_list(s).BAL_TYPE,
                    EXTRACT(YEAR FROM EP_BUS_PERIOD_END) * 1000000 + EXTRACT(MONTH FROM EP_BUS_PERIOD_END) * 10000 + EXTRACT(DAY FROM EP_BUS_PERIOD_END) * 100 + jrnl_bal_types_list(s).BAL_TYPE,
                    jrnl_bal_types_list(s).BAL_TYPE,
                    EXTRACT(YEAR FROM pDate) * 1000000 + EXTRACT(MONTH FROM pDate) * 10000 + EXTRACT(DAY FROM pDate) * 100 + jrnl_bal_types_list(s).BAL_TYPE
                FROM SLR_ENTITY_PERIODS
                WHERE EP_ENTITY = pEntity
                AND  EP_PERIOD_TYPE != 0
                AND EP_STATUS = 'C'
                AND EP_BUS_PERIOD_END <= pDate;

            END LOOP;
         END IF;

         INSERT INTO SLR_FAK_DAILY_BALANCES
                (
                    FDB_FAK_ID
                    ,FDB_BALANCE_DATE
                    ,FDB_BALANCE_TYPE
                    ,FDB_TRAN_DAILY_MOVEMENT
                    ,FDB_TRAN_MTD_BALANCE
                    ,FDB_TRAN_YTD_BALANCE
                    ,FDB_TRAN_LTD_BALANCE
                    ,FDB_BASE_DAILY_MOVEMENT
                    ,FDB_BASE_MTD_BALANCE
                    ,FDB_BASE_YTD_BALANCE
                    ,FDB_BASE_LTD_BALANCE
                    ,FDB_LOCAL_DAILY_MOVEMENT
                    ,FDB_LOCAL_MTD_BALANCE
                    ,FDB_LOCAL_YTD_BALANCE
                    ,FDB_LOCAL_LTD_BALANCE
                    ,FDB_ENTITY
                    ,FDB_EPG_ID
					,FDB_AMENDED_ON
					,FDB_PERIOD_MONTH
                    ,FDB_PERIOD_YEAR
                    ,FDB_PERIOD_LTD
                    ,FDB_PROCESS_ID
                    ,FDB_TRAN_QTD_BALANCE
                    ,FDB_BASE_QTD_BALANCE
                    ,FDB_LOCAL_QTD_BALANCE
                    ,FDB_PERIOD_QTR

                )
                SELECT
                    FDB_FAK_ID
                    ,EP_BUS_PERIOD_END
                    ,FDB_BALANCE_TYPE
                    ,0
                    ,FDB_TRAN_MTD_BALANCE
                    ,FDB_TRAN_YTD_BALANCE
                    ,FDB_TRAN_LTD_BALANCE
                    ,0
                    ,FDB_BASE_MTD_BALANCE
                    ,FDB_BASE_YTD_BALANCE
                    ,FDB_BASE_LTD_BALANCE
                    ,0
                    ,FDB_LOCAL_MTD_BALANCE
                    ,FDB_LOCAL_YTD_BALANCE
                    ,FDB_LOCAL_LTD_BALANCE
                    ,pEntity
                    ,fdb1.FDB_EPG_ID
					,current_timestamp
					,fdb1.FDB_PERIOD_MONTH
                    ,fdb1.FDB_PERIOD_YEAR
                    ,fdb1.FDB_PERIOD_LTD
                    ,fdb1.FDB_PROCESS_ID
                    ,FDB_TRAN_QTD_BALANCE
                    ,FDB_BASE_QTD_BALANCE
                    ,FDB_LOCAL_QTD_BALANCE
                    ,FDB_PERIOD_QTR
            FROM SLR_FAK_DAILY_BALANCES fdb1
            INNER JOIN SLR_ENTITY_PERIODS_TMP_DEF
            ON fdb1.FDB_ENTITY = EP_ENTITY
                AND TO_CHAR(fdb1.FDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(fdb1.FDB_BALANCE_TYPE) < EP_BUS_PERIOD_END_ID
                AND TO_CHAR(fdb1.FDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(fdb1.FDB_BALANCE_TYPE) >= EP_BUS_PERIOD_START_ID
                AND TO_CHAR(fdb1.FDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(fdb1.FDB_BALANCE_TYPE) <= EP_ARC_DATE_ID
                AND fdb1.FDB_BALANCE_TYPE = EP_BAL_TYPE
            WHERE
                fdb1.FDB_ENTITY = pEntity
                AND fdb1.FDB_EPG_ID IN (SELECT EPG_ID FROM SLR_ENTITY_PROC_GROUP WHERE EPG_ENTITY = fdb1.FDB_ENTITY)
                AND fdb1.FDB_BALANCE_TYPE != 10
                AND TO_CHAR(fdb1.FDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(fdb1.FDB_BALANCE_TYPE) =
												(   SELECT MAX(TO_CHAR(FDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(FDB_BALANCE_TYPE))
                                                    FROM SLR_FAK_DAILY_BALANCES fdb
                                                    WHERE fdb1.FDB_BALANCE_TYPE = fdb.FDB_BALANCE_TYPE
                                                        AND fdb1.FDB_FAK_ID = fdb.FDB_FAK_ID
                                                        AND TO_CHAR(fdb.FDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(fdb.FDB_BALANCE_TYPE) < EP_BUS_PERIOD_END_ID
                                                        AND TO_CHAR(fdb.FDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(fdb.FDB_BALANCE_TYPE) >= EP_BUS_PERIOD_START_ID
                                                        AND TO_CHAR(fdb.FDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(fdb.FDB_BALANCE_TYPE) <= EP_ARC_DATE_ID
                                                        AND fdb1.FDB_ENTITY = fdb.FDB_ENTITY
                                                        AND fdb1.FDB_EPG_ID = fdb.FDB_EPG_ID
                                                )
               ;

               pArchRecCounter := Nvl(pArchRecCounter,0) + SQL%ROWCOUNT;

 EXCEPTION
        WHEN OTHERS THEN
			--gv_ecode := SQLCODE;
            gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
            RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);

END pRollFAKBalancesToME_full;

PROCEDURE pCUST_RollEBABalancesToME        (      pLPGId                    in FR_LPG_CONFIG.LC_LPG_ID%TYPE default NULL,
                                                  pBatchSize                in INTEGER DEFAULT NULL,
                                                  pARCT_ID                  in FR_ARCHIVE_CTL.ARCT_ID%TYPE,
                                                  pArchRecCounter           out INTEGER
                                            )
IS
	s_proc_name varchar2(60):= 'FDR_CUSTOM_ARCHIVING_PKG.pCUST_RollEBABalancesToME';

    cnrl_tbl_list   CNTRL_TABLE_ARRAY;

    TYPE ENTITY_ARRAY IS TABLE OF FR_LPG_CONFIG.LC_GRP_CODE%TYPE;
    entity_list ENTITY_ARRAY;

    lvBusinessDate  DATE;
    lvArchDate      DATE;
    lvMaxPeriod     DATE;
    lvPeriodCounter INTEGER;

     --EXCEPTIONS
    SUCCESSED EXCEPTION;
    PRAGMA EXCEPTION_INIT(SUCCESSED, -20998);

    PROCEED EXCEPTION;
    PRAGMA EXCEPTION_INIT(PROCEED, -20997);
	 lvColumnEPG varchar2(100);
	 lvColumnEPG2 varchar2(100);
BEGIN

    BEGIN
    cnrl_tbl_list := CNTRL_TABLE_ARRAY();

    pLoadArchCntrList( pARCT_ID, cnrl_tbl_list);
	SELECT ARCT_ENTITY_COLUMN_NAME, ARCT_LPG_COLUMN_NAME INTO lvColumnEPG,lvColumnEPG2 FROM FR_ARCHIVE_CTL WHERE ARCT_ID = pARCT_ID;
    IF (/*cnrl_tbl_list(1).ARCT_ARCHIVE_DATE_COLUMN IS NOT NULL AND */ cnrl_tbl_list(1).ARCT_ARCHIVE_DAYS IS NOT NULL)
    THEN
        SELECT GP_TODAYS_BUS_DATE
        INTO lvBusinessDate
        FROM FR_GLOBAL_PARAMETER
        WHERE COALESCE(pLPGId,1) = LPG_ID;

        lvArchDate := lvBusinessDate - cnrl_tbl_list(1).ARCT_ARCHIVE_DAYS;

        IF pLPGId IS NOT NULL AND (lvColumnEPG IS NOT NULL or lvColumnEPG2 IS NOT NULL)
        THEN
             SELECT DISTINCT EPG_ENTITY  BULK COLLECT INTO entity_list FROM SLR_ENTITY_PROC_GROUP WHERE EPG_ID  IN
				(SELECT EPG_ID FROM SLR_ENTITY_PROC_GROUP WHERE EPG_ENTITY  IN (SELECT LC_GRP_CODE  FROM FR_LPG_CONFIG WHERE LC_LPG_ID = pLPGId));
        ELSE
            SELECT ENT_ENTITY BULK COLLECT INTO entity_list FROM SLR_ENTITIES;
        END IF;

        IF entity_list.count > 0 THEN

            FOR indx IN entity_list.FIRST..entity_list.LAST
            LOOP
                SELECT count(*)
                INTO lvPeriodCounter
                FROM SLR_ENTITY_PERIODS
                    WHERE EP_ENTITY = entity_list(indx)
                    AND EP_PERIOD_TYPE != 0
                    AND EP_STATUS = 'C'
                    AND EP_BUS_PERIOD_END < lvArchDate;

                 -- check if any closed period exists
                IF lvPeriodCounter != 0 THEN

                    SELECT MAX(EP_BUS_PERIOD_END)
                    INTO lvMaxPeriod
                    FROM SLR_ENTITY_PERIODS
                        WHERE EP_ENTITY = entity_list(indx)
                        AND EP_PERIOD_TYPE != 0
                        AND EP_STATUS = 'C'
                        AND EP_BUS_PERIOD_END < lvArchDate;

                    --pRollEBABalancesToME(entity_list(indx),pBatchSize,lvMaxPeriod,pArchRecCounter);
                    pRollEBABalancesToME_full(entity_list(indx),pBatchSize,lvMaxPeriod,pArchRecCounter);

                    COMMIT;
                 END IF;

            END LOOP;
        END IF;
    END IF;

	EXCEPTION
        WHEN OTHERS THEN
			--gv_ecode := SQLCODE;
            gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
            RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);
    END;

    pArchRecCounter := 0;
    RAISE PROCEED;

END pCUST_RollEBABalancesToME;

PROCEDURE pRollEBABalancesToME              (         pEntity                   SLR_ENTITIES.ENT_ENTITY%type,
                                                      pBatchSize                in INTEGER DEFAULT NULL,
                                                      pDate                     FR_GLOBAL_PARAMETER.gp_todays_bus_date%type,
                                                      pArchRecCounter           out INTEGER
                                                )
IS
    s_proc_name varchar2(60):= 'FDR_CUSTOM_ARCHIVING_PKG.pRollEBABalancesToME ';

    lvAffectedRecCount INTEGER;

    TYPE PERIOD_RECORD IS RECORD
        (   EP_BUS_YEAR             SLR_ENTITY_PERIODS.EP_BUS_YEAR%type,
            EP_BUS_PERIOD           SLR_ENTITY_PERIODS.EP_BUS_PERIOD%type
        ) ;

    TYPE periods_array IS TABLE OF PERIOD_RECORD;
    periods_list periods_array;

BEGIN
        SELECT
                EP_BUS_YEAR,
                EP_BUS_PERIOD
        BULK COLLECT
        INTO periods_list
            FROM SLR_ENTITY_PERIODS
        WHERE EP_ENTITY = pEntity
            AND EP_PERIOD_TYPE != 0
            AND EP_STATUS = 'C'
            AND EP_BUS_PERIOD_END <= pDate
        ORDER BY  EP_BUS_YEAR, EP_BUS_PERIOD ASC;

        lvAffectedRecCount := 0;

        FOR indx IN periods_list.FIRST..periods_list.LAST
        LOOP
            pRollEBABalancesToME(pEntity,pBatchSize,periods_list(indx).EP_BUS_YEAR, periods_list(indx).EP_BUS_PERIOD, pArchRecCounter);

            IF lvAffectedRecCount >= Nvl(pBatchSize,0)
            THEN
                COMMIT;
                lvAffectedRecCount := 0;
            END IF;
        END LOOP;

 EXCEPTION
        WHEN OTHERS THEN
			--gv_ecode := SQLCODE;
            gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
            RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);

END pRollEBABalancesToME;

PROCEDURE pRollEBABalancesToME              (         pEntity                   SLR_ENTITIES.ENT_ENTITY%type,
                                                      pBatchSize                in INTEGER DEFAULT NULL,
                                                      pYear                     SLR_ENTITY_PERIODS.ep_bus_year%type,
                                                      pPeriod                   SLR_ENTITY_PERIODS.ep_bus_period%type,
                                                      pArchRecCounter           out INTEGER
                                                )
IS
    s_proc_name varchar2(60):= 'FDR_CUSTOM_ARCHIVING_PKG.pRollEBABalancesToME ';

    pBusPeriodStart_ID      NUMBER(10,0);
    pBusPeriodEnd_ID        NUMBER(10,0);

    pBusPeriodStart         SLR_ENTITY_PERIODS.EP_BUS_PERIOD_START%type;
    pBusPeriodEnd           SLR_ENTITY_PERIODS.EP_BUS_PERIOD_END%type;

    lvAffectedRecCount INTEGER;

BEGIN

        SELECT
                EP_BUS_PERIOD_START,
                EP_BUS_PERIOD_END,
                to_number(to_char(EP_BUS_PERIOD_START,'YYYYMMDD')) * 100,
                (to_number(to_char(EP_BUS_PERIOD_END,'YYYYMMDD')) * 100) + 99
            INTO     pBusPeriodStart, pBusPeriodEnd, pBusPeriodStart_ID, pBusPeriodEnd_ID
            FROM SLR_ENTITY_PERIODS
        WHERE
            EP_BUS_YEAR = pYear
            AND EP_BUS_PERIOD = pPeriod
            AND EP_PERIOD_TYPE != 0
            AND EP_STATUS = 'C'
            AND EP_ENTITY = pEntity;

        INSERT INTO SLR_EBA_DAILY_BALANCES
        (
             EDB_FAK_ID
            ,EDB_EBA_ID
            ,EDB_BALANCE_DATE
            ,EDB_BALANCE_TYPE
            ,EDB_TRAN_DAILY_MOVEMENT
            ,EDB_TRAN_MTD_BALANCE
            ,EDB_TRAN_YTD_BALANCE
            ,EDB_TRAN_LTD_BALANCE
            ,EDB_BASE_DAILY_MOVEMENT
            ,EDB_BASE_MTD_BALANCE
            ,EDB_BASE_YTD_BALANCE
            ,EDB_BASE_LTD_BALANCE
            ,EDB_LOCAL_DAILY_MOVEMENT
            ,EDB_LOCAL_MTD_BALANCE
            ,EDB_LOCAL_YTD_BALANCE
            ,EDB_LOCAL_LTD_BALANCE
            ,EDB_ENTITY
            ,EDB_EPG_ID
			,EDB_PERIOD_MONTH
            ,EDB_PERIOD_YEAR
            ,EDB_PERIOD_LTD
            ,EDB_PROCESS_ID
            ,EDB_TRAN_QTD_BALANCE
            ,EDB_LOCAL_QTD_BALANCE
            ,EDB_BASE_QTD_BALANCE
            ,EDB_PERIOD_QTR
        )
        SELECT
             EDB_FAK_ID
            ,EDB_EBA_ID
            ,pBusPeriodEnd
            ,EDB_BALANCE_TYPE
            ,0
            ,MAX(EDB_TRAN_MTD_BALANCE)
            ,MAX(EDB_TRAN_YTD_BALANCE)
            ,MAX(EDB_TRAN_LTD_BALANCE)
            ,0
            ,MAX(EDB_BASE_MTD_BALANCE)
            ,MAX(EDB_BASE_YTD_BALANCE)
            ,MAX(EDB_BASE_LTD_BALANCE)
            ,0
            ,MAX(EDB_LOCAL_MTD_BALANCE)
            ,MAX(EDB_LOCAL_YTD_BALANCE)
            ,MAX(EDB_LOCAL_LTD_BALANCE)
            ,pEntity
            ,edb1.EDB_EPG_ID
			,MAX(EDB_PERIOD_MONTH)
			,MAX(EDB_PERIOD_YEAR)
			,MAX(EDB_PERIOD_LTD)
			,MAX(EDB_PROCESS_ID)
            ,MAX(EDB_TRAN_QTD_BALANCE)
            ,MAX(EDB_LOCAL_QTD_BALANCE)
            ,MAX(EDB_BASE_QTD_BALANCE)
            ,MAX(EDB_PERIOD_QTR)

    FROM SLR_EBA_DAILY_BALANCES edb1
    WHERE
        EDB_ENTITY = pEntity
        AND EDB_EPG_ID IN (SELECT EPG_ID FROM SLR_ENTITY_PROC_GROUP WHERE EPG_ENTITY = EDB_ENTITY)
        AND TO_CHAR(EDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(EDB_BALANCE_TYPE) >= pBusPeriodStart_ID
        AND TO_CHAR(EDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(EDB_BALANCE_TYPE) <= pBusPeriodEnd_ID
        AND EDB_BALANCE_TYPE != 10
        AND EDB_BALANCE_DATE = ( SELECT MAX(EDB_BALANCE_DATE)
                                  FROM SLR_EBA_DAILY_BALANCES edb
                                  WHERE edb1.EDB_BALANCE_TYPE = edb.EDB_BALANCE_TYPE
                                        AND edb1.EDB_FAK_ID = edb.EDB_FAK_ID
                                        AND edb1.EDB_EBA_ID = edb.EDB_EBA_ID
                                        AND TO_CHAR(edb.EDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(edb.EDB_BALANCE_TYPE) >= pBusPeriodStart_ID
                                        AND TO_CHAR(edb.EDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(edb.EDB_BALANCE_TYPE) <= pBusPeriodEnd_ID
                                        AND edb1.EDB_ENTITY = edb.EDB_ENTITY
                                        AND edb1.EDB_EPG_ID = edb.EDB_EPG_ID
                                )
        AND EDB_BALANCE_DATE  != pBusPeriodEnd
    GROUP BY EDB_BALANCE_DATE, EDB_BALANCE_TYPE, EDB_FAK_ID , EDB_EBA_ID, EDB_EPG_ID;

    pArchRecCounter := Nvl(pArchRecCounter,0) + SQL%ROWCOUNT;

 EXCEPTION
        WHEN OTHERS THEN
			--gv_ecode := SQLCODE;
            gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
            RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);

END pRollEBABalancesToME;

PROCEDURE pRollEBABalancesToME_full              (    pEntity                   in SLR_ENTITIES.ENT_ENTITY%type,
                                                      pBatchSize                in INTEGER DEFAULT NULL,
                                                      pDate                     in FR_GLOBAL_PARAMETER.gp_todays_bus_date%type,
                                                      pArchRecCounter           out INTEGER
                                                )
IS
    s_proc_name varchar2(60):= 'FDR_CUSTOM_ARCHIVING_PKG.pRollEBABalancesToME_full';

    lvAffectedRecCount INTEGER;

    CURSOR cJrnTypes is
  SELECT DISTINCT EJT_BALANCE_TYPE_1 BAL_TYPE
  FROM SLR_EXT_JRNL_TYPES
    WHERE EJT_BALANCE_TYPE_1 != 10
  UNION
    SELECT DISTINCT EJT_BALANCE_TYPE_2 BAL_TYPE
  FROM SLR_EXT_JRNL_TYPES
    WHERE EJT_BALANCE_TYPE_2 != 10;

    TYPE jrnl_bal_types_array IS TABLE OF cJrnTypes%rowtype;
    jrnl_bal_types_list jrnl_bal_types_array;

BEGIN

        open cJrnTypes;
		fetch cJrnTypes bulk collect INTO jrnl_bal_types_list;
        close cJrnTypes;

         IF jrnl_bal_types_list.COUNT > 0 THEN

        	FOR s IN jrnl_bal_types_list.FIRST .. jrnl_bal_types_list.LAST
            LOOP
                INSERT INTO SLR_ENTITY_PERIODS_TMP_DEF
                (
                    EP_ENTITY,
                    EP_BUS_PERIOD_START,
                    EP_BUS_PERIOD_END,
                    EP_BUS_PERIOD_START_ID,
                    EP_BUS_PERIOD_END_ID,
                    EP_BAL_TYPE,
                    EP_ARC_DATE_ID
                )
                SELECT
                    EP_ENTITY,
                    EP_BUS_PERIOD_START,
                    EP_BUS_PERIOD_END,
                    EXTRACT(YEAR FROM EP_BUS_PERIOD_START) * 1000000 + EXTRACT(MONTH FROM EP_BUS_PERIOD_START) * 10000 + EXTRACT(DAY FROM EP_BUS_PERIOD_START) * 100 + jrnl_bal_types_list(s).BAL_TYPE,
                    EXTRACT(YEAR FROM EP_BUS_PERIOD_END) * 1000000 + EXTRACT(MONTH FROM EP_BUS_PERIOD_END) * 10000 + EXTRACT(DAY FROM EP_BUS_PERIOD_END) * 100 + jrnl_bal_types_list(s).BAL_TYPE,
                    jrnl_bal_types_list(s).BAL_TYPE,
                    EXTRACT(YEAR FROM pDate) * 1000000 + EXTRACT(MONTH FROM pDate) * 10000 + EXTRACT(DAY FROM pDate) * 100 + jrnl_bal_types_list(s).BAL_TYPE
                FROM SLR_ENTITY_PERIODS
                WHERE EP_ENTITY = pEntity
                AND  EP_PERIOD_TYPE != 0
                AND EP_STATUS = 'C'
                AND EP_BUS_PERIOD_END <= pDate;

            END LOOP;
         END IF;

         INSERT INTO SLR_EBA_DAILY_BALANCES
                (
                     EDB_FAK_ID
                    ,EDB_EBA_ID
                    ,EDB_BALANCE_DATE
                    ,EDB_BALANCE_TYPE
                    ,EDB_TRAN_DAILY_MOVEMENT
                    ,EDB_TRAN_MTD_BALANCE
                    ,EDB_TRAN_YTD_BALANCE
                    ,EDB_TRAN_LTD_BALANCE
                    ,EDB_BASE_DAILY_MOVEMENT
                    ,EDB_BASE_MTD_BALANCE
                    ,EDB_BASE_YTD_BALANCE
                    ,EDB_BASE_LTD_BALANCE
                    ,EDB_LOCAL_DAILY_MOVEMENT
                    ,EDB_LOCAL_MTD_BALANCE
                    ,EDB_LOCAL_YTD_BALANCE
                    ,EDB_LOCAL_LTD_BALANCE
                    ,EDB_ENTITY
                    ,EDB_EPG_ID
					,EDB_AMENDED_ON
					,EDB_PERIOD_MONTH
					,EDB_PERIOD_YEAR
					,EDB_PERIOD_LTD
					,EDB_PROCESS_ID
                    ,EDB_TRAN_QTD_BALANCE
                    ,EDB_LOCAL_QTD_BALANCE
                    ,EDB_BASE_QTD_BALANCE
                    ,EDB_PERIOD_QTR
                )
                SELECT
                    EDB_FAK_ID
                    ,EDB_EBA_ID
                    ,EP_BUS_PERIOD_END
                    ,EDB_BALANCE_TYPE
                    ,0
                    ,EDB_TRAN_MTD_BALANCE
                    ,EDB_TRAN_YTD_BALANCE
                    ,EDB_TRAN_LTD_BALANCE
                    ,0
                    ,EDB_BASE_MTD_BALANCE
                    ,EDB_BASE_YTD_BALANCE
                    ,EDB_BASE_LTD_BALANCE
                    ,0
                    ,EDB_LOCAL_MTD_BALANCE
                    ,EDB_LOCAL_YTD_BALANCE
                    ,EDB_LOCAL_LTD_BALANCE
                    ,pEntity
                    ,edb1.EDB_EPG_ID
					,current_timestamp
					,edb1.EDB_PERIOD_MONTH
					,edb1.EDB_PERIOD_YEAR
					,edb1.EDB_PERIOD_LTD
					,edb1.EDB_PROCESS_ID
                    ,EDB_TRAN_QTD_BALANCE
                    ,EDB_LOCAL_QTD_BALANCE
                    ,EDB_BASE_QTD_BALANCE
                    ,EDB_PERIOD_QTR
            FROM SLR_EBA_DAILY_BALANCES edb1
            INNER JOIN SLR_ENTITY_PERIODS_TMP_DEF
            ON edb1.EDB_ENTITY = EP_ENTITY
                AND TO_CHAR(edb1.EDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(edb1.EDB_BALANCE_TYPE) < EP_BUS_PERIOD_END_ID
                AND TO_CHAR(edb1.EDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(edb1.EDB_BALANCE_TYPE) >= EP_BUS_PERIOD_START_ID
                AND TO_CHAR(edb1.EDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(edb1.EDB_BALANCE_TYPE) <= EP_ARC_DATE_ID
                AND edb1.EDB_BALANCE_TYPE = EP_BAL_TYPE
            WHERE
                edb1.EDB_ENTITY = pEntity
				AND edb1.EDB_EPG_ID IN (SELECT EPG_ID FROM SLR_ENTITY_PROC_GROUP WHERE EPG_ENTITY = edb1.EDB_ENTITY)
                AND edb1.EDB_BALANCE_TYPE != 10
                AND TO_CHAR(edb1.EDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(edb1.EDB_BALANCE_TYPE) =
												( SELECT MAX(TO_CHAR(edb.EDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(edb.EDB_BALANCE_TYPE))
                                                  FROM SLR_EBA_DAILY_BALANCES edb
                                                  WHERE edb1.EDB_BALANCE_TYPE = edb.EDB_BALANCE_TYPE
                                                        AND edb1.EDB_EBA_ID = edb.EDB_EBA_ID
                                                        AND edb1.EDB_FAK_ID = edb.EDB_FAK_ID
                                                        AND TO_CHAR(edb.EDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(edb.EDB_BALANCE_TYPE) < EP_BUS_PERIOD_END_ID
                                                        AND TO_CHAR(edb.EDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(edb.EDB_BALANCE_TYPE) >= EP_BUS_PERIOD_START_ID
                                                        AND TO_CHAR(edb.EDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(edb.EDB_BALANCE_TYPE) <= EP_ARC_DATE_ID
                                                        AND edb1.EDB_ENTITY = edb.EDB_ENTITY
                                                        AND edb1.EDB_EPG_ID = edb.EDB_EPG_ID
                                            )
               ;

               pArchRecCounter := Nvl(pArchRecCounter,0) + SQL%ROWCOUNT;

 EXCEPTION
        WHEN OTHERS THEN
			--gv_ecode := SQLCODE;
            gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
            RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);

END pRollEBABalancesToME_full;

PROCEDURE pCUST_RollFAKBlncsAcrossPrds     (      pLPGId                    in FR_LPG_CONFIG.LC_LPG_ID%TYPE default NULL,
                                                  pBatchSize                in INTEGER DEFAULT NULL,
                                                  pARCT_ID                  in FR_ARCHIVE_CTL.ARCT_ID%TYPE,
                                                  pArchRecCounter           out INTEGER
                                            )
IS
	s_proc_name varchar2(60):= 'FDR_CUSTOM_ARCHIVING_PKG.pCUST_RollFAKBlncsAcrossPrds';

    cnrl_tbl_list   CNTRL_TABLE_ARRAY;

    TYPE ENTITY_ARRAY IS TABLE OF FR_LPG_CONFIG.LC_GRP_CODE%TYPE;
    entity_list ENTITY_ARRAY;

    lvBusinessDate  DATE;
    lvArchDate      DATE;
    lvPeriodEnd     DATE;

      --EXCEPTIONS
    SUCCESSED EXCEPTION;
    PRAGMA EXCEPTION_INIT(SUCCESSED, -20998);

    PROCEED EXCEPTION;
    PRAGMA EXCEPTION_INIT(PROCEED, -20997);
	lvColumnEPG varchar2(100);
	lvColumnEPG2 varchar2(100);
BEGIN

    BEGIN
    cnrl_tbl_list := CNTRL_TABLE_ARRAY();

    pLoadArchCntrList( pARCT_ID, cnrl_tbl_list);
	SELECT ARCT_ENTITY_COLUMN_NAME, ARCT_LPG_COLUMN_NAME INTO lvColumnEPG,lvColumnEPG2 FROM FR_ARCHIVE_CTL WHERE ARCT_ID = pARCT_ID;
    --dbms_output.enable;
    IF (/*cnrl_tbl_list(1).ARCT_ARCHIVE_DATE_COLUMN IS NOT NULL AND*/ cnrl_tbl_list(1).ARCT_ARCHIVE_DAYS IS NOT NULL)
    THEN
        SELECT GP_TODAYS_BUS_DATE
        INTO lvBusinessDate
        FROM FR_GLOBAL_PARAMETER
        WHERE COALESCE(pLPGId,1) = LPG_ID;

        lvArchDate := lvBusinessDate - cnrl_tbl_list(1).ARCT_ARCHIVE_DAYS;

        IF pLPGId IS NOT NULL AND (lvColumnEPG IS NOT NULL or lvColumnEPG2 IS NOT NULL)
        THEN
            SELECT DISTINCT EPG_ENTITY  BULK COLLECT INTO entity_list FROM SLR_ENTITY_PROC_GROUP WHERE EPG_ID  IN
				(SELECT EPG_ID FROM SLR_ENTITY_PROC_GROUP WHERE EPG_ENTITY  IN (SELECT LC_GRP_CODE  FROM FR_LPG_CONFIG WHERE LC_LPG_ID = pLPGId));
        ELSE
               SELECT ENT_ENTITY BULK COLLECT INTO entity_list FROM SLR_ENTITIES where ent_entity in (select /*+PARALLEL*/ distinct fdb_entity from slr_fak_daily_balances);
        END IF;

        IF entity_list.COUNT > 0 THEN
        FOR indx IN entity_list.FIRST..entity_list.LAST
            LOOP
                SELECT MIN(EP_BUS_PERIOD_END)
                INTO lvPeriodEnd
                FROM SLR_ENTITY_PERIODS
                    WHERE EP_ENTITY = entity_list(indx)
                    AND EP_PERIOD_TYPE != 0
                    --AND EP_STATUS = 'C'
                    AND EP_BUS_PERIOD_END > lvArchDate;

                IF lvPeriodEnd IS NOT NULL THEN
                    pRollFAKBalances_AP(entity_list(indx),pBatchSize,lvPeriodEnd,NULL,NULL,pArchRecCounter);

                    COMMIT;

                END IF;

            END LOOP;
        END IF;
    END IF;

	EXCEPTION
        WHEN OTHERS THEN
			--gv_ecode := SQLCODE;
            gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
            RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);
    END;

    RAISE PROCEED;

END pCUST_RollFAKBlncsAcrossPrds;

PROCEDURE pRollFAKBalances_AP( pEntity                   in SLR_ENTITIES.ENT_ENTITY%type,
                               pBatchSize                in INTEGER DEFAULT NULL,
                               pDate                     in FR_GLOBAL_PARAMETER.gp_todays_bus_date%type DEFAULT NULL,
                               pYear                     in SLR_ENTITY_PERIODS.ep_bus_year%type DEFAULT NULL,
                               pPeriod                   in SLR_ENTITY_PERIODS.ep_bus_period%type DEFAULT NULL,
                               pArchRecCounter           out INTEGER
                              )
IS
    s_proc_name varchar2(60):= 'FDR_CUSTOM_ARCHIVING_PKG.pRollFAKBalances_AP';

    lvBusPeriodStart_ID      NUMBER(10,0);
    lvBusPeriodEnd_ID        NUMBER(10,0);

    lvBusPeriodStart         SLR_ENTITY_PERIODS.EP_BUS_PERIOD_START%type;
    lvBusPeriodEnd           SLR_ENTITY_PERIODS.EP_BUS_PERIOD_END%type;
    lvBusPeriodYear          SLR_ENTITY_PERIODS.EP_BUS_YEAR%TYPE;
	lvBusPeriodMonth        SLR_ENTITY_PERIODS.EP_BUS_PERIOD%TYPE;

    TYPE PERIOD_RECORD IS RECORD
        (   EP_BUS_YEAR             SLR_ENTITY_PERIODS.EP_BUS_YEAR%type,
            EP_BUS_PERIOD           SLR_ENTITY_PERIODS.EP_BUS_PERIOD%type,
            EP_BUS_PERIOD_START     SLR_ENTITY_PERIODS.EP_BUS_PERIOD_START%type,
            EP_BUS_PERIOD_END       SLR_ENTITY_PERIODS.EP_BUS_PERIOD_END%type,
            EP_BUS_PERIOD_START_ID  NUMBER(10,0),
            EP_BUS_PERIOD_END_ID    NUMBER(10,0)
        ) ;

    TYPE periods_array IS TABLE OF PERIOD_RECORD;
    periods_list periods_array;

BEGIN
    SELECT  EP_BUS_PERIOD_END, to_number(to_char(EP_BUS_PERIOD_START,'YYYYMMDD') || '00'), to_number(to_char(EP_BUS_PERIOD_END,'YYYYMMDD') || '99'), EP_BUS_YEAR, EP_BUS_PERIOD_START, EP_BUS_PERIOD
            INTO  lvBusPeriodEnd, lvBusPeriodStart_ID, lvBusPeriodEnd_ID, lvBusPeriodYear,lvBusPeriodStart, lvBusPeriodMonth
            FROM SLR_ENTITY_PERIODS
                WHERE EP_ENTITY = pEntity
                AND EP_PERIOD_TYPE != 0
                --AND EP_STATUS = 'C'
                AND EP_BUS_PERIOD_END = pDate;

    IF lvBusPeriodEnd != pDate
    THEN
        dbms_output.put_line('Error wrongly given period end date and exit');
    END IF;

    IF pYear IS NOT NULL AND pPeriod IS NOT NULL
    THEN
        SELECT  EP_BUS_YEAR, EP_BUS_PERIOD, EP_BUS_PERIOD_START, EP_BUS_PERIOD_END, to_number(to_char(EP_BUS_PERIOD_START,'yyyymmdd')) * 100, to_number(to_char(EP_BUS_PERIOD_END,'yyyymmdd')) * 100
            BULK COLLECT
            INTO periods_list
        FROM SLR_ENTITY_PERIODS
            WHERE EP_ENTITY = pEntity
            AND EP_PERIOD_TYPE != 0
           -- AND EP_STATUS = 'C'
            AND EP_BUS_PERIOD_END < lvBusPeriodStart
            AND EP_BUS_YEAR >= pYear
            AND EP_BUS_PERIOD >= pPeriod
       ORDER BY EP_BUS_YEAR DESC, EP_BUS_PERIOD DESC;

    ELSE
        SELECT  EP_BUS_YEAR, EP_BUS_PERIOD, EP_BUS_PERIOD_START, EP_BUS_PERIOD_END, to_number(to_char(EP_BUS_PERIOD_START,'yyyymmdd')) * 100, to_number(to_char(EP_BUS_PERIOD_END,'yyyymmdd')) * 100
            BULK COLLECT
            INTO periods_list
        FROM SLR_ENTITY_PERIODS
            WHERE EP_ENTITY = pEntity
            AND EP_PERIOD_TYPE != 0
            --AND EP_STATUS = 'C'
            AND EP_BUS_PERIOD_END < lvBusPeriodStart
        ORDER BY EP_BUS_YEAR DESC, EP_BUS_PERIOD DESC;
    END IF;

       IF periods_list.COUNT > 0 THEN
         FOR indx IN periods_list.FIRST..periods_list.LAST
         LOOP
                   -- pRollFAKBalances_AP(pEntity,NULL,lvBusPeriodEnd, periods_list(indx).EP_BUS_PERIOD, pArchRecCounter);
             INSERT INTO SLR_FAK_DAILY_BALANCES
             (
                 FDB_FAK_ID
                ,FDB_BALANCE_DATE
                ,FDB_BALANCE_TYPE
                ,FDB_TRAN_DAILY_MOVEMENT
                ,FDB_TRAN_MTD_BALANCE
                ,FDB_TRAN_YTD_BALANCE
                ,FDB_TRAN_LTD_BALANCE
                ,FDB_BASE_DAILY_MOVEMENT
                ,FDB_BASE_MTD_BALANCE
                ,FDB_BASE_YTD_BALANCE
                ,FDB_BASE_LTD_BALANCE
                ,FDB_LOCAL_DAILY_MOVEMENT
                ,FDB_LOCAL_MTD_BALANCE
                ,FDB_LOCAL_YTD_BALANCE
                ,FDB_LOCAL_LTD_BALANCE
                ,FDB_ENTITY
                ,FDB_EPG_ID --added
				,FDB_AMENDED_ON
				,FDB_PERIOD_MONTH
                ,FDB_PERIOD_YEAR
                ,FDB_PERIOD_LTD
				,FDB_PROCESS_ID
            )
            SELECT
                FDB_FAK_ID
                ,lvBusPeriodEnd
                ,FDB_BALANCE_TYPE
                ,0
                ,0
                ,CASE WHEN lvBusPeriodYear > periods_list(indx).EP_BUS_YEAR THEN 0 ELSE FDB_TRAN_YTD_BALANCE END
                ,FDB_TRAN_LTD_BALANCE
                ,0
                ,0
                ,CASE WHEN lvBusPeriodYear > periods_list(indx).EP_BUS_YEAR THEN 0 ELSE FDB_BASE_YTD_BALANCE END
                ,FDB_BASE_LTD_BALANCE
                ,0
                ,0
                ,CASE WHEN lvBusPeriodYear > periods_list(indx).EP_BUS_YEAR THEN 0 ELSE FDB_LOCAL_YTD_BALANCE END
                ,FDB_LOCAL_LTD_BALANCE
                ,pEntity
                ,fdb.FDB_EPG_ID --added
				,current_timestamp
                ,lvBusPeriodMonth
                ,lvBusPeriodYear
                ,1
                ,fdb.FDB_PROCESS_ID
        FROM
        SLR_FAK_DAILY_BALANCES fdb
        INNER JOIN SLR.SLR_ENTITIES ent
				ON fdb.FDB_ENTITY = ent.ENT_Entity
        INNER JOIN SLR.SLR_ENTITY_ACCOUNTS ea
				ON ent.ENT_ACCOUNTS_SET = ea.EA_ENTITY_SET
        INNER JOIN SLR.SLR_FAK_COMBINATIONS fc
				ON
					ea.EA_ACCOUNT = fc.FC_ACCOUNT
				AND fc.FC_FAK_ID = fdb.fDB_FAK_ID
        WHERE
            fdb.FDB_ENTITY = pEntity
            AND fdb.FDB_EPG_ID IN (SELECT EPG_ID FROM SLR_ENTITY_PROC_GROUP WHERE EPG_ENTITY = fdb.FDB_ENTITY)
            AND TO_CHAR(fdb.FDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(fdb.FDB_BALANCE_TYPE) = periods_list(indx).EP_BUS_PERIOD_END_ID + fdb.FDB_BALANCE_TYPE
            AND FDB.FDB_BALANCE_TYPE != 10
            AND NOT EXISTS (    SELECT 1 FROM SLR_FAK_DAILY_BALANCES fdb1
                                WHERE fdb.FDB_FAK_ID = fdb1.FDB_FAK_ID
                                    AND fdb1.FDB_ENTITY = pEntity
                                    AND fdb1.FDB_EPG_ID = fdb.FDB_EPG_ID
                                    AND TO_CHAR(fdb1.FDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(fdb1.FDB_BALANCE_TYPE) >= lvBusPeriodStart_ID     -- start arch period
                                    AND TO_CHAR(fdb1.FDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(fdb1.FDB_BALANCE_TYPE) <= lvBusPeriodEnd_ID       -- end arch period
                                    AND fdb1.FDB_BALANCE_TYPE = fdb.FDB_BALANCE_TYPE );

         pArchRecCounter := Nvl(pArchRecCounter,0) + SQL%ROWCOUNT;

         END LOOP;
      END IF;

 EXCEPTION
        WHEN OTHERS THEN
			--gv_ecode := SQLCODE;
            gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
            RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);

END pRollFAKBalances_AP;

PROCEDURE pRollEBABalances_AP( pEntity                   SLR_ENTITIES.ENT_ENTITY%type,
                               pBatchSize                in INTEGER DEFAULT NULL,
                               pDate                     FR_GLOBAL_PARAMETER.gp_todays_bus_date%type DEFAULT NULL,
                               pYear                     SLR_ENTITY_PERIODS.ep_bus_year%type DEFAULT NULL,
                               pPeriod                   SLR_ENTITY_PERIODS.ep_bus_period%type DEFAULT NULL,
                               pArchRecCounter           out INTEGER
                              )
IS
    s_proc_name varchar2(60):= 'FDR_CUSTOM_ARCHIVING_PKG.pRollEBABalances_AP';

    lvBusPeriodStart_ID      NUMBER(10,0);
    lvBusPeriodEnd_ID        NUMBER(10,0);

    lvBusPeriodStart         SLR_ENTITY_PERIODS.EP_BUS_PERIOD_START%type;
    lvBusPeriodEnd           SLR_ENTITY_PERIODS.EP_BUS_PERIOD_END%type;
    lvBusPeriodYear          SLR_ENTITY_PERIODS.EP_BUS_YEAR%TYPE;
	lvBusPeriodMonth        SLR_ENTITY_PERIODS.EP_BUS_PERIOD%TYPE;

    TYPE PERIOD_RECORD IS RECORD
        (   EP_BUS_YEAR             SLR_ENTITY_PERIODS.EP_BUS_YEAR%type,
            EP_BUS_PERIOD           SLR_ENTITY_PERIODS.EP_BUS_PERIOD%type,
            EP_BUS_PERIOD_START     SLR_ENTITY_PERIODS.EP_BUS_PERIOD_START%type,
            EP_BUS_PERIOD_END       SLR_ENTITY_PERIODS.EP_BUS_PERIOD_END%type,
            EP_BUS_PERIOD_START_ID  NUMBER(10,0),
            EP_BUS_PERIOD_END_ID    NUMBER(10,0)
        ) ;

    TYPE periods_array IS TABLE OF PERIOD_RECORD;
    periods_list periods_array;

BEGIN

    SELECT  EP_BUS_PERIOD_END, to_number(to_char(EP_BUS_PERIOD_START,'YYYYMMDD') || '00'), to_number(to_char(EP_BUS_PERIOD_END,'YYYYMMDD') || '99'), EP_BUS_YEAR, EP_BUS_PERIOD_START, EP_BUS_PERIOD
            INTO  lvBusPeriodEnd, lvBusPeriodStart_ID, lvBusPeriodEnd_ID, lvBusPeriodYear, lvBusPeriodStart, lvBusPeriodMonth
            FROM SLR_ENTITY_PERIODS
                WHERE EP_ENTITY = pEntity
                AND EP_PERIOD_TYPE != 0
               -- AND EP_STATUS = 'C'
                AND EP_BUS_PERIOD_END = pDate;

    IF lvBusPeriodEnd !=   pDate
    THEN
        dbms_output.put_line('Error wrongly given period end date and exit');
    END IF;

    IF pYear IS NOT NULL AND pPeriod IS NOT NULL
    THEN
        SELECT  EP_BUS_YEAR, EP_BUS_PERIOD, EP_BUS_PERIOD_START, EP_BUS_PERIOD_END, to_number(to_char(EP_BUS_PERIOD_START,'yyyymmdd')) * 100, to_number(to_char(EP_BUS_PERIOD_END,'yyyymmdd')) * 100
            BULK COLLECT
            INTO periods_list
        FROM SLR_ENTITY_PERIODS
            WHERE EP_ENTITY = pEntity
            AND EP_PERIOD_TYPE != 0
            --AND EP_STATUS = 'C'
            AND EP_BUS_PERIOD_END < lvBusPeriodStart
            AND EP_BUS_YEAR >= pYear
            AND EP_BUS_PERIOD >= pPeriod
        ORDER BY  EP_BUS_YEAR DESC, EP_BUS_PERIOD DESC;

    ELSE
        SELECT  EP_BUS_YEAR, EP_BUS_PERIOD, EP_BUS_PERIOD_START, EP_BUS_PERIOD_END, to_number(to_char(EP_BUS_PERIOD_START,'yyyymmdd')) * 100, to_number(to_char(EP_BUS_PERIOD_END,'yyyymmdd')) * 100
            BULK COLLECT
            INTO periods_list
        FROM SLR_ENTITY_PERIODS
            WHERE EP_ENTITY = pEntity
            AND EP_PERIOD_TYPE != 0
            --AND EP_STATUS = 'C'
            AND EP_BUS_PERIOD_END < lvBusPeriodStart
        ORDER BY  EP_BUS_YEAR DESC, EP_BUS_PERIOD DESC;
    END IF;

        IF periods_list.count > 0 THEN
         FOR indx IN periods_list.FIRST..periods_list.LAST
         LOOP
                   -- pRollFAKBalances_AP(pEntity,NULL,lvBusPeriodEnd, periods_list(indx).EP_BUS_PERIOD, pArchRecCounter);
             INSERT INTO SLR_EBA_DAILY_BALANCES
             (
                 EDB_FAK_ID
                ,EDB_EBA_ID
                ,EDB_BALANCE_DATE
                ,EDB_BALANCE_TYPE
                ,EDB_TRAN_DAILY_MOVEMENT
                ,EDB_TRAN_MTD_BALANCE
                ,EDB_TRAN_YTD_BALANCE
                ,EDB_TRAN_LTD_BALANCE
                ,EDB_BASE_DAILY_MOVEMENT
                ,EDB_BASE_MTD_BALANCE
                ,EDB_BASE_YTD_BALANCE
                ,EDB_BASE_LTD_BALANCE
                ,EDB_LOCAL_DAILY_MOVEMENT
                ,EDB_LOCAL_MTD_BALANCE
                ,EDB_LOCAL_YTD_BALANCE
                ,EDB_LOCAL_LTD_BALANCE
                ,EDB_ENTITY
                ,EDB_EPG_ID
				,EDB_AMENDED_ON
				,EDB_PERIOD_MONTH
                ,EDB_PERIOD_YEAR
                ,EDB_PERIOD_LTD
				,EDB_PROCESS_ID
            )
           SELECT
                 EDB_FAK_ID
                ,EDB_EBA_ID
                ,lvBusPeriodEnd
                ,EDB_BALANCE_TYPE
                ,0
                ,0
                ,CASE WHEN lvBusPeriodYear > periods_list(indx).EP_BUS_YEAR THEN 0 ELSE EDB_TRAN_YTD_BALANCE END
                ,EDB_TRAN_LTD_BALANCE
                ,0
                ,0
                ,CASE WHEN lvBusPeriodYear > periods_list(indx).EP_BUS_YEAR THEN 0 ELSE EDB_BASE_YTD_BALANCE END
                ,EDB_BASE_LTD_BALANCE
                ,0
                ,0
                ,CASE WHEN lvBusPeriodYear > periods_list(indx).EP_BUS_YEAR THEN 0 ELSE EDB_LOCAL_YTD_BALANCE END
                ,EDB_LOCAL_LTD_BALANCE
                ,pEntity
                ,edb.EDB_EPG_ID
				,current_timestamp
                ,lvBusPeriodMonth
                ,lvBusPeriodYear
                ,1
                ,edb.EDB_PROCESS_ID
        FROM
        SLR_EBA_DAILY_BALANCES edb
		INNER JOIN SLR.SLR_ENTITIES ent
				ON edb.EDB_ENTITY = ent.ENT_Entity
		INNER JOIN SLR.SLR_ENTITY_ACCOUNTS ea
				ON ent.ENT_ACCOUNTS_SET = ea.EA_ENTITY_SET
		INNER JOIN SLR.SLR_FAK_COMBINATIONS fc
				ON
					ea.EA_ACCOUNT = fc.FC_ACCOUNT
				AND fc.FC_FAK_ID = edb.EDB_FAK_ID
        WHERE
            edb.EDB_ENTITY = pEntity
            AND edb.EDB_EPG_ID IN (SELECT EPG_ID FROM SLR_ENTITY_PROC_GROUP WHERE EPG_ENTITY = edb.EDB_ENTITY)
            AND TO_CHAR(edb.EDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(edb.EDB_BALANCE_TYPE) = (periods_list(indx).EP_BUS_PERIOD_END_ID + edb.EDB_BALANCE_TYPE)
            AND edb.EDB_BALANCE_TYPE != 10
            AND NOT EXISTS (    SELECT 1 FROM SLR_EBA_DAILY_BALANCES edb1
                                WHERE edb.EDB_FAK_ID = edb1.EDB_FAK_ID
                                    AND edb.EDB_EBA_ID = edb1.EDB_EBA_ID
                                    AND edb1.EDB_ENTITY = pEntity
                                    AND edb1.EDB_EPG_ID = edb.EDB_EPG_ID
                                    AND TO_CHAR(edb1.EDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(edb1.EDB_BALANCE_TYPE) >= lvBusPeriodStart_ID -- start arch period
                                    AND TO_CHAR(edb1.EDB_BALANCE_DATE,'YYYYMMDD')||TO_CHAR(edb1.EDB_BALANCE_TYPE)  <= lvBusPeriodEnd_ID -- end arch period
                                    AND edb1.EDB_BALANCE_TYPE = edb.EDB_BALANCE_TYPE );

         END LOOP;
         END IF;

    pArchRecCounter := Nvl(pArchRecCounter,0) + SQL%ROWCOUNT;

 EXCEPTION
        WHEN OTHERS THEN
			--gv_ecode := SQLCODE;
            gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
            RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);

END pRollEBABalances_AP;

PROCEDURE pCUST_RollEBABlncsAcrossPrds     (      pLPGId                    in FR_LPG_CONFIG.LC_LPG_ID%TYPE default NULL,
                                                  pBatchSize                in INTEGER DEFAULT NULL,
                                                  pARCT_ID                  in FR_ARCHIVE_CTL.ARCT_ID%TYPE,
                                                  pArchRecCounter           out INTEGER
                                            )
IS
	s_proc_name varchar2(60):= 'FDR_CUSTOM_ARCHIVING_PKG.pCUST_RollEBABlncsAcrossPrds';

    cnrl_tbl_list   CNTRL_TABLE_ARRAY;

    TYPE ENTITY_ARRAY IS TABLE OF FR_LPG_CONFIG.LC_GRP_CODE%TYPE;
    entity_list ENTITY_ARRAY;

    lvBusinessDate  DATE;
    lvArchDate      DATE;
    lvPeriodEnd     DATE;

      --EXCEPTIONS
    SUCCESSED EXCEPTION;
    PRAGMA EXCEPTION_INIT(SUCCESSED, -20998);

    PROCEED EXCEPTION;
    PRAGMA EXCEPTION_INIT(PROCEED, -20997);
	lvColumnEPG varchar2(100);
	lvColumnEPG2 varchar2(100);
BEGIN

    BEGIN
    cnrl_tbl_list := CNTRL_TABLE_ARRAY();

    pLoadArchCntrList( pARCT_ID, cnrl_tbl_list);
	SELECT ARCT_ENTITY_COLUMN_NAME, ARCT_LPG_COLUMN_NAME INTO lvColumnEPG,lvColumnEPG2 FROM FR_ARCHIVE_CTL WHERE ARCT_ID = pARCT_ID;
    --dbms_output.enable;
    IF (/*cnrl_tbl_list(1).ARCT_ARCHIVE_DATE_COLUMN IS NOT NULL AND*/ cnrl_tbl_list(1).ARCT_ARCHIVE_DAYS IS NOT NULL)
    THEN
        SELECT GP_TODAYS_BUS_DATE
        INTO lvBusinessDate
        FROM FR_GLOBAL_PARAMETER
        WHERE COALESCE(pLPGId,1) = LPG_ID;

        lvArchDate := lvBusinessDate - cnrl_tbl_list(1).ARCT_ARCHIVE_DAYS;

        IF pLPGId IS NOT NULL AND (lvColumnEPG IS NOT NULL or lvColumnEPG2 IS NOT NULL)
        THEN
           SELECT DISTINCT EPG_ENTITY  BULK COLLECT INTO entity_list FROM SLR_ENTITY_PROC_GROUP WHERE EPG_ID  IN
				(SELECT EPG_ID FROM SLR_ENTITY_PROC_GROUP WHERE EPG_ENTITY  IN (SELECT LC_GRP_CODE  FROM FR_LPG_CONFIG WHERE LC_LPG_ID = pLPGId));
        ELSE
                SELECT ENT_ENTITY BULK COLLECT INTO entity_list FROM SLR_ENTITIES where ent_entity in (select /*+PARALLEL*/ distinct edb_entity from slr_eba_daily_balances);
        END IF;

        IF entity_list.COUNT > 0 THEN
        FOR indx IN entity_list.FIRST..entity_list.LAST
            LOOP
                SELECT MIN(EP_BUS_PERIOD_END)
                INTO lvPeriodEnd
                FROM SLR_ENTITY_PERIODS
                    WHERE EP_ENTITY = entity_list(indx)
                    AND EP_PERIOD_TYPE != 0
                    --AND EP_STATUS = 'C'
                    AND EP_BUS_PERIOD_END > lvArchDate;

                IF lvPeriodEnd IS NOT NULL THEN
                    pRollEBABalances_AP(entity_list(indx),pBatchSize,lvPeriodEnd,NULL,NULL,pArchRecCounter);

                    COMMIT;

                END IF;

            END LOOP;
        END IF;
    END IF;

	EXCEPTION
        WHEN OTHERS THEN
			--gv_ecode := SQLCODE;
            gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
            RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);
    END;

    RAISE PROCEED;

END pCUST_RollEBABlncsAcrossPrds;

PROCEDURE pCUST_ArchiveEBABalances_After(         pLPGId                    in FR_LPG_CONFIG.LC_LPG_ID%TYPE default NULL,
                                                  pBatchSize                in INTEGER DEFAULT NULL,
                                                  pARCT_ID                  in FR_ARCHIVE_CTL.ARCT_ID%TYPE DEFAULT NULL,
                                                  pArchRecCounter           out INTEGER
                                            )
IS
    s_proc_name varchar2(60):= 'FDR_CUSTOM_ARCHIVING_PKG.pCUST_ArchiveEBABalances_After';

    cnrl_tbl_list   CNTRL_TABLE_ARRAY;

    TYPE ENTITY_ARRAY IS TABLE OF FR_LPG_CONFIG.LC_GRP_CODE%TYPE;
    epgId_list ENTITY_ARRAY;

    lvBusinessDate  DATE;
    lvArchDate      DATE;
    lvMaxPeriod     DATE;

    lvProcessedRecCounter INTEGER;

    lvBusPeriodStart_ID      NUMBER(10,0);
    lvBusPeriodEnd_ID        NUMBER(10,0);

    lvBusPeriodStart         SLR_ENTITY_PERIODS.EP_BUS_PERIOD_START%type;
    lvBusPeriodEnd           SLR_ENTITY_PERIODS.EP_BUS_PERIOD_END%type;
    lvBusPeriodYear          SLR_ENTITY_PERIODS.EP_BUS_YEAR%TYPE;

    TYPE PERIOD_RECORD IS RECORD
        (   EP_BUS_YEAR             SLR_ENTITY_PERIODS.EP_BUS_YEAR%type,
            EP_BUS_PERIOD           SLR_ENTITY_PERIODS.EP_BUS_PERIOD%type,
            EP_BUS_PERIOD_START     SLR_ENTITY_PERIODS.EP_BUS_PERIOD_START%type,
            EP_BUS_PERIOD_END       SLR_ENTITY_PERIODS.EP_BUS_PERIOD_END%type,
            EP_BUS_PERIOD_START_ID  NUMBER(10,0),
            EP_BUS_PERIOD_END_ID    NUMBER(10,0)
        ) ;

    TYPE periods_array IS TABLE OF PERIOD_RECORD;
    periods_list periods_array;

    --EXCEPTIONS
    SUCCESSED EXCEPTION;
    PRAGMA EXCEPTION_INIT(SUCCESSED, -20998);

    PROCEED EXCEPTION;
    PRAGMA EXCEPTION_INIT(PROCEED, -20997);
	lvColumnEPG varchar2(100);
	lvColumnEPG2 varchar2(100);
BEGIN

    BEGIN

    cnrl_tbl_list := CNTRL_TABLE_ARRAY();

    pLoadArchCntrList( pARCT_ID, cnrl_tbl_list);
	SELECT ARCT_ENTITY_COLUMN_NAME, ARCT_LPG_COLUMN_NAME INTO lvColumnEPG,lvColumnEPG2 FROM FR_ARCHIVE_CTL WHERE ARCT_ID = pARCT_ID;
    IF (/*cnrl_tbl_list(1).ARCT_ARCHIVE_DATE_COLUMN IS NOT NULL AND */ cnrl_tbl_list(1).ARCT_ARCHIVE_DAYS IS NOT NULL)
    THEN
        SELECT GP_TODAYS_BUS_DATE
        INTO lvBusinessDate
        FROM FR_GLOBAL_PARAMETER
        WHERE COALESCE(pLPGId,1) = LPG_ID;

        lvArchDate := lvBusinessDate - cnrl_tbl_list(1).ARCT_ARCHIVE_DAYS;

        IF pLPGId IS NOT NULL and (lvColumnEPG IS NOT NULL or lvColumnEPG2 IS NOT NULL)
        THEN
            SELECT DISTINCT EPG_ID BULK COLLECT INTO epgId_list FROM FR_LPG_CONFIG INNER JOIN slr_entity_proc_group ON LC_GRP_CODE = EPG_ENTITY WHERE LC_LPG_ID = pLPGId;
        ELSE
            SELECT DISTINCT EPG_ID BULK COLLECT INTO epgId_list FROM SLR_ENTITIES INNER JOIN slr_entity_proc_group ON ENT_ENTITY = EPG_ENTITY;
        END IF;

        IF epgId_list.COUNT > 0 THEN

            FOR indx IN epgId_list.FIRST..epgId_list.LAST
            LOOP
                SELECT MIN(EP_BUS_PERIOD_END)
                INTO lvMaxPeriod
                FROM SLR_ENTITY_PERIODS
				INNER JOIN SLR_ENTITY_PROC_GROUP ON EP_ENTITY = EPG_ENTITY
                    WHERE EPG_ID = epgId_list(indx)
                    AND EP_PERIOD_TYPE != 0
                    --AND EP_STATUS = 'C'
                    AND EP_BUS_PERIOD_END > lvArchDate;

                IF lvMaxPeriod IS NOT NULL
                THEN
                    pArchiveEBABalances_After(epgId_list(indx),pBatchSize,lvMaxPeriod,pArchRecCounter);
                    COMMIT;
                END IF;

            END LOOP;
        END IF;
    END IF;
    pArchRecCounter := Nvl(pArchRecCounter,0) + SQL%ROWCOUNT;

    EXCEPTION
        WHEN OTHERS THEN
			--gv_ecode := SQLCODE;
            gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
            RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);
    END;

    RAISE PROCEED;

END pCUST_ArchiveEBABalances_After;

PROCEDURE pCUST_ArchiveFAKBalances_After(         pLPGId                    in FR_LPG_CONFIG.LC_LPG_ID%TYPE default NULL,
                                                  pBatchSize                in INTEGER DEFAULT NULL,
                                                  pARCT_ID                  in FR_ARCHIVE_CTL.ARCT_ID%TYPE DEFAULT NULL,
                                                  pArchRecCounter           out INTEGER
                                            )
IS
    s_proc_name varchar2(60):= 'FDR_CUSTOM_ARCHIVING_PKG.pCUST_ArchiveFAKBalances_After';

    cnrl_tbl_list   CNTRL_TABLE_ARRAY;

    TYPE ENTITY_ARRAY IS TABLE OF FR_LPG_CONFIG.LC_GRP_CODE%TYPE;
    epgId_list ENTITY_ARRAY;

    lvBusinessDate  DATE;
    lvArchDate      DATE;
    lvMaxPeriod     DATE;

    lvProcessedRecCounter INTEGER;

    lvBusPeriodStart_ID      NUMBER(10,0);
    lvBusPeriodEnd_ID        NUMBER(10,0);

    lvBusPeriodStart         SLR_ENTITY_PERIODS.EP_BUS_PERIOD_START%type;
    lvBusPeriodEnd           SLR_ENTITY_PERIODS.EP_BUS_PERIOD_END%type;
    lvBusPeriodYear          SLR_ENTITY_PERIODS.EP_BUS_YEAR%TYPE;

    TYPE PERIOD_RECORD IS RECORD
        (   EP_BUS_YEAR             SLR_ENTITY_PERIODS.EP_BUS_YEAR%type,
            EP_BUS_PERIOD           SLR_ENTITY_PERIODS.EP_BUS_PERIOD%type,
            EP_BUS_PERIOD_START     SLR_ENTITY_PERIODS.EP_BUS_PERIOD_START%type,
            EP_BUS_PERIOD_END       SLR_ENTITY_PERIODS.EP_BUS_PERIOD_END%type,
            EP_BUS_PERIOD_START_ID  NUMBER(10,0),
            EP_BUS_PERIOD_END_ID    NUMBER(10,0)
        ) ;

    TYPE periods_array IS TABLE OF PERIOD_RECORD;
    periods_list periods_array;

    --EXCEPTIONS
    SUCCESSED EXCEPTION;
    PRAGMA EXCEPTION_INIT(SUCCESSED, -20998);

    PROCEED EXCEPTION;
    PRAGMA EXCEPTION_INIT(PROCEED, -20997);
	lvColumnEPG varchar2(100);
	lvColumnEPG2 varchar2(100);
BEGIN

    BEGIN

    cnrl_tbl_list := CNTRL_TABLE_ARRAY();

    pLoadArchCntrList( pARCT_ID, cnrl_tbl_list);
	SELECT ARCT_ENTITY_COLUMN_NAME, ARCT_LPG_COLUMN_NAME INTO lvColumnEPG,lvColumnEPG2 FROM FR_ARCHIVE_CTL WHERE ARCT_ID = pARCT_ID;
    IF (/*cnrl_tbl_list(1).ARCT_ARCHIVE_DATE_COLUMN IS NOT NULL AND */ cnrl_tbl_list(1).ARCT_ARCHIVE_DAYS IS NOT NULL)
    THEN
        SELECT GP_TODAYS_BUS_DATE
        INTO lvBusinessDate
        FROM FR_GLOBAL_PARAMETER
        WHERE COALESCE(pLPGId,1) = LPG_ID;

        lvArchDate := lvBusinessDate - cnrl_tbl_list(1).ARCT_ARCHIVE_DAYS;

        IF pLPGId IS NOT NULL and (lvColumnEPG IS NOT NULL or lvColumnEPG2 IS NOT NULL)
        THEN
            SELECT DISTINCT EPG_ID BULK COLLECT INTO epgId_list FROM FR_LPG_CONFIG INNER JOIN slr_entity_proc_group ON LC_GRP_CODE = EPG_ENTITY WHERE LC_LPG_ID = pLPGId;
        ELSE
            SELECT DISTINCT EPG_ID BULK COLLECT INTO epgId_list FROM SLR_ENTITIES INNER JOIN slr_entity_proc_group ON ENT_ENTITY = EPG_ENTITY;
        END IF;

        IF epgId_list.COUNT > 0 THEN

            FOR indx IN epgId_list.FIRST..epgId_list.LAST
            LOOP
                SELECT MIN(EP_BUS_PERIOD_END)
                INTO lvMaxPeriod
                FROM SLR_ENTITY_PERIODS
				INNER JOIN SLR_ENTITY_PROC_GROUP ON EP_ENTITY = EPG_ENTITY
                    WHERE EPG_ID = epgId_list(indx)
                    AND EP_PERIOD_TYPE != 0
                    --AND EP_STATUS = 'C'
                    AND EP_BUS_PERIOD_END > lvArchDate;

                IF lvMaxPeriod IS NOT NULL
                THEN
                    pArchiveFAKBalances_After(epgId_list(indx),pBatchSize,lvMaxPeriod,pArchRecCounter);
                    COMMIT;
                END IF;

            END LOOP;
        END IF;
    END IF;
    pArchRecCounter := Nvl(pArchRecCounter,0) + SQL%ROWCOUNT;

    EXCEPTION
        WHEN OTHERS THEN
			--gv_ecode := SQLCODE;
            gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
            RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);
    END;

    RAISE PROCEED;

END pCUST_ArchiveFAKBalances_After;



PROCEDURE pArchiveEBABalances_After   ( pEpgId                    SLR_ENTITY_PROC_GROUP.EPG_ID%type,
                                        pBatchSize                in INTEGER DEFAULT NULL,
                                        pDate                     FR_GLOBAL_PARAMETER.gp_todays_bus_date%type DEFAULT NULL,
                                        pArchRecCounter           out INTEGER
                                       )
IS
    s_proc_name varchar2(60):= 'FDR_CUSTOM_ARCHIVING_PKG.pArchiveEBABalances_After';

    lvArchPeriodEndDate_ID NUMBER(10,0);

    lvAffectedRecCount INTEGER;

BEGIN
	SLR.SLR_POST_JOURNALS_PKG.pGenerateLastBalances(pEpgId,null,pDate);
END pArchiveEBABalances_After;

PROCEDURE pArchiveFAKBalances_After   ( pEpgId                    SLR_ENTITY_PROC_GROUP.EPG_ID%type,
                                        pBatchSize                in INTEGER DEFAULT NULL,
                                        pDate                     FR_GLOBAL_PARAMETER.gp_todays_bus_date%type DEFAULT NULL,
                                        pArchRecCounter           out INTEGER
                                       )
IS
    s_proc_name varchar2(60):= 'FDR_CUSTOM_ARCHIVING_PKG.pArchiveFAKBalances_After';

    lvArchPeriodEndDate_ID NUMBER(10,0);

    lvAffectedRecCount INTEGER;

BEGIN
	SLR.SLR_POST_JOURNALS_PKG.pGenerateFAKLastBalances(pEpgId,null,pDate);
END pArchiveFAKBalances_After;




PROCEDURE pCUST_ArchiveHopper_Before (            pLPGId                    in FR_LPG_CONFIG.LC_LPG_ID%TYPE default NULL,
                                                  pBatchSize                in INTEGER DEFAULT NULL,
                                                  pARCT_ID                  in FR_ARCHIVE_CTL.ARCT_ID%TYPE DEFAULT NULL,
                                                  pArchRecCounter           out INTEGER
                                      )
IS
	s_proc_name varchar2(60):= 'FDR_CUSTOM_ARCHIVING_PKG.pCUST_ArchiveHopper_Before';

    cnrl_tbl_list   CNTRL_TABLE_ARRAY;

    TYPE ENTITY_ARRAY IS TABLE OF FR_LPG_CONFIG.LC_GRP_CODE%TYPE;
    entity_list ENTITY_ARRAY;

    lvBusinessDate  DATE;
    lvArchDate      DATE;
    lvPeriodEnd     DATE;

    lvInsert_SQL    VARCHAR2(4000);
    lvDelete_SQL    VARCHAR2(4000);
    lvWhereClause   VARCHAR2(4000);

    lvCounter INTEGER := 0;

      --EXCEPTIONS
    SUCCESSED EXCEPTION;
    PRAGMA EXCEPTION_INIT(SUCCESSED, -20998);

    PROCEED EXCEPTION;
    PRAGMA EXCEPTION_INIT(PROCEED, -20997);

BEGIN

    BEGIN
    cnrl_tbl_list := CNTRL_TABLE_ARRAY();

    pLoadArchCntrList( pARCT_ID, cnrl_tbl_list);

    IF ((cnrl_tbl_list(1).ARCT_ARCHIVE_DATE_COLUMN IS NOT NULL AND cnrl_tbl_list(1).ARCT_ARCHIVE_DAYS IS NOT NULL) OR cnrl_tbl_list(1).ARCT_ARCHIVE_WHERE_CLAUSE IS NOT NULL)
    THEN

        SELECT GP_TODAYS_BUS_DATE
        INTO lvBusinessDate
        FROM FR_GLOBAL_PARAMETER
        WHERE COALESCE(pLPGId,1) = LPG_ID;

        lvArchDate := lvBusinessDate - cnrl_tbl_list(1).ARCT_ARCHIVE_DAYS;

        lvWhereClause := FDR_ARCHIVING_PKG.fBuildArchWhereSttmnt (      cnrl_tbl_list(1).ARCT_ARCHIVE_DAYS,
                                                                        cnrl_tbl_list(1).ARCT_ARCHIVE_DATE_COLUMN ,
                                                                        cnrl_tbl_list(1).ARCT_ARCHIVE_WHERE_CLAUSE,
                                                                        cnrl_tbl_list(1).ARCT_LPG_COLUMN_NAME,
                                                                        cnrl_tbl_list(1).ARCT_ENTITY_COLUMN_NAME,
                                                                        pLPGId);
    END IF;

    IF pBatchSize IS NOT NULL
    THEN

        lvInsert_SQL :=
        'DECLARE '
        || ' TYPE ARRAY IS TABLE OF ' || cnrl_tbl_list(1).ARCT_SCHEMA_NAME || '.' || cnrl_tbl_list(1).ARCT_TABLE_NAME || '%ROWTYPE; '||gc_nl
        || ' l_data ARRAY;' ||gc_nl
        || ' lvCounter INTEGER;' || gc_nl
        ||' CURSOR cRowsToInsert IS SELECT * FROM ' || cnrl_tbl_list(1).ARCT_SCHEMA_NAME || '.' || cnrl_tbl_list(1).ARCT_TABLE_NAME || ' ' || NVL(lvWhereClause,'') || ';'||gc_nl
        ||' BEGIN '||gc_nl
        || ' OPEN cRowsToInsert; '||gc_nl
        || ' LOOP   ' ||gc_nl
        || ' FETCH cRowsToInsert BULK COLLECT INTO l_data LIMIT ' || pBatchSize || ';'||gc_nl
        ||    ' FORALL i IN 1..l_data.COUNT ' ||gc_nl
        ||    ' INSERT INTO ' || cnrl_tbl_list(1).ARCT_ARC_SCHEMA_NAME ||  '.' || cnrl_tbl_list(1).ARCT_ARC_TABLE_NAME || ' VALUES NULL,l_data(i); '||gc_nl
        ||    ' lvCounter := Nvl(lvCounter,0) + sql%rowcount '
        ||    ' COMMIT; '||gc_nl
        ||    ' EXIT WHEN cRowsToInsert%NOTFOUND; '||gc_nl
        ||    ' END LOOP; '||gc_nl
        ||    ' CLOSE cRowsToInsert; '||gc_nl
        ||    ' :out_cnt := lvCounter; ' ||gc_nl
        || ' END BulkDML_Insert;';

        execute immediate(lvInsert_SQL) using OUT lvCounter;

         lvDelete_SQL :=
        'DECLARE '||gc_nl
        || ' TYPE ARRAY IS TABLE OF ROWID; '||gc_nl
        || ' l_data ARRAY; '||gc_nl
        ||' CURSOR cRowsToDelete IS SELECT ROWID FROM ' || cnrl_tbl_list(1).ARCT_SCHEMA_NAME || '.' || cnrl_tbl_list(1).ARCT_TABLE_NAME || ' ' || NVL(lvWhereClause,'') || ';'||gc_nl
        ||' BEGIN '||gc_nl
        || ' OPEN cRowsToDelete; '||gc_nl
        || ' LOOP   '||gc_nl
        || ' FETCH cRowsToDelete BULK COLLECT INTO l_data LIMIT ' || pBatchSize || ';'||gc_nl
        ||    ' FORALL i IN 1..l_data.COUNT '||gc_nl
        ||    ' DELETE FROM ' || cnrl_tbl_list(1).ARCT_SCHEMA_NAME || '.' || cnrl_tbl_list(1).ARCT_TABLE_NAME ||   ' WHERE ROWID= l_data(i) ; '||gc_nl
        ||    ' COMMIT; '||gc_nl
        ||    ' EXIT WHEN cRowsToDelete%NOTFOUND; '||gc_nl
        ||    ' END LOOP; '||gc_nl
        ||    ' CLOSE cRowsToDelete; '||gc_nl
        || ' END BulkDML_Delete;';

        execute immediate(lvDelete_SQL);

     ELSE
        lvInsert_SQL :=
        'BEGIN '
        || 'INSERT INTO ' || cnrl_tbl_list(1).ARCT_ARC_SCHEMA_NAME ||  '.' || cnrl_tbl_list(1).ARCT_ARC_TABLE_NAME
        || ' SELECT NULL,' || cnrl_tbl_list(1).ARCT_TABLE_NAME ||'.* '
        || ' FROM ' || cnrl_tbl_list(1).ARCT_SCHEMA_NAME || '.' || cnrl_tbl_list(1).ARCT_TABLE_NAME
        || ' ' || NVL(lvWhereClause,'') || ';'
        || ' :COUNTER := SQL%ROWCOUNT; '
        || ' END;' ;

        execute immediate(lvInsert_SQL) using OUT lvCounter;

        lvDelete_SQL :=
        ' DELETE FROM ' || cnrl_tbl_list(1).ARCT_SCHEMA_NAME || '.' || cnrl_tbl_list(1).ARCT_TABLE_NAME
        ||' '|| NVL(lvWhereClause,'');

        execute immediate(lvDelete_SQL);

     END IF;

       pArchRecCounter := lvCounter;

       COMMIT;

	EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
			--gv_ecode := SQLCODE;
            gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
            RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);
    END;

    RAISE SUCCESSED;

END pCUST_ArchiveHopper_Before;

PROCEDURE pLoadArchCntrList              (        pARCT_ID                  in FR_ARCHIVE_CTL.ARCT_ID%TYPE,
                                                  cnrl_tbl_list             out CNTRL_TABLE_ARRAY
                                         )
IS
	s_proc_name varchar2(60):= 'FDR_CUSTOM_ARCHIVING_PKG.pLoadArchCntrList';

BEGIN

    SELECT * BULK COLLECT INTO cnrl_tbl_list FROM FR_ARCHIVE_CTL WHERE ARCT_ID = pARCT_ID;

	EXCEPTION
        WHEN OTHERS THEN
			--gv_ecode := SQLCODE;
            gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
            RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);

END pLoadArchCntrList;

/*******************************************************************************************************************
*
*                                         TEMPLATES
*
* The following procedures are executed once at the begining and the end of archiving process.
* Can be customized as needed to e.g. switch on/off constraints, collect stats etc.
* Note: Please do not raise custom exception (SUCCESSED OR PROCEED) in pCUST_ArchiveAfterProcess
*
********************************************************************************************************************/
PROCEDURE pCUST_ArchiveBeforeProcess (            pLPGId                    in FR_LPG_CONFIG.LC_LPG_ID%TYPE default NULL,
                                                  pBatchSize                in INTEGER DEFAULT NULL,
                                                  pArchRecCounter           out INTEGER
                                      )
IS
	s_proc_name varchar2(60):= 'FDR_CUSTOM_ARCHIVING_PKG.pCUST_ArchiveBeforeProcess';

      --EXCEPTIONS
    SUCCESSED EXCEPTION;
    PRAGMA EXCEPTION_INIT(SUCCESSED, -20998);

    PROCEED EXCEPTION;
    PRAGMA EXCEPTION_INIT(PROCEED, -20997);

 CURSOR c_stn
  IS
    SELECT
        arct_table_name t_name
    FROM
        fdr.fr_archive_ctl
    WHERE
        arct_archive = 'Y' and arct_schema_name = 'STN';

BEGIN

    pArchRecCounter := 0;

  -- disable STN constraints for performance issues
  FOR r_stn IN c_stn
  LOOP
          for cur in (select fk.owner, fk.constraint_name , fk.table_name
            from all_constraints fk, all_constraints pk
            where fk.CONSTRAINT_TYPE = 'R' and
                pk.owner = 'STN' and
                fk.r_owner = pk.owner and
                fk.R_CONSTRAINT_NAME = pk.CONSTRAINT_NAME and
                pk.TABLE_NAME = r_stn.t_name) loop
            execute immediate 'ALTER TABLE "'||cur.owner||'"."'||cur.table_name||'" MODIFY CONSTRAINT "'||cur.constraint_name||'" DISABLE';
            end loop;

    END LOOP;


    PGRANT_PRIVILIGES;


    COMMIT;

    RAISE PROCEED;

END pCUST_ArchiveBeforeProcess;

PROCEDURE pCUST_ArchiveAfterProcess (             pLPGId                    in FR_LPG_CONFIG.LC_LPG_ID%TYPE default NULL,
                                                  pBatchSize                in INTEGER DEFAULT NULL,
                                                  pArchRecCounter           out INTEGER
                                      )
IS
	s_proc_name varchar2(60):= 'FDR_CUSTOM_ARCHIVING_PKG.pCUST_ArchiveAfterProcess';

  CURSOR c_stn
  IS
    SELECT
        arct_table_name t_name
    FROM
        fdr.fr_archive_ctl
    WHERE
        arct_archive = 'Y' and arct_schema_name = 'STN';


BEGIN

  pArchRecCounter := 0;

   -- add back constraints removed before archiving
  FOR r_stn IN c_stn
  LOOP
          for cur in (select fk.owner, fk.constraint_name , fk.table_name
            from all_constraints fk, all_constraints pk
            where fk.CONSTRAINT_TYPE = 'R' and
                pk.owner = 'STN' and
                fk.r_owner = pk.owner and
                fk.R_CONSTRAINT_NAME = pk.CONSTRAINT_NAME and
                pk.TABLE_NAME = r_stn.t_name) loop
            execute immediate 'ALTER TABLE "'||cur.owner||'"."'||cur.table_name||'" MODIFY CONSTRAINT "'||cur.constraint_name||'" ENABLE';
            end loop;

    END LOOP;

     COMMIT;

END pCUST_ArchiveAfterProcess;

PROCEDURE PGRANT_PRIVILIGES IS

    s_proc_name VARCHAR2(80) := 'FDR_CUSTOM_ARCHIVING_PKG.PGRANT_PRIVILIGES';
    gv_ecode 	NUMBER := -20999;
    gv_emsg VARCHAR(10000);

    vSql VARCHAR2(1000);
    vGrant VARCHAR(200);
    vProcedureName VARCHAR2(100);

    cursor cTablesList
    is
    SELECT
                UPPER(ARCT_SCHEMA_NAME) SCHEMA_NAME,
                UPPER(ARCT_TABLE_NAME) TABLE_NAME
                FROM FR_ARCHIVE_CTL
                WHERE ARCT_ARCHIVE = 'Y'
                AND ARCT_SCHEMA_NAME != USER
                GROUP BY ARCT_SCHEMA_NAME,ARCT_TABLE_NAME
        UNION
        SELECT
                UPPER(ARCT_ARC_SCHEMA_NAME) SCHEMA_NAME,
                UPPER(ARCT_ARC_TABLE_NAME) TABLE_NAME
                FROM FR_ARCHIVE_CTL
                WHERE ARCT_ARCHIVE = 'Y'
                AND ARCT_ARC_TABLE_NAME != 'PURGE'
                AND ARCT_ARC_SCHEMA_NAME != USER
                GROUP BY ARCT_ARC_SCHEMA_NAME,ARCT_ARC_TABLE_NAME
    ;

    cursor cUserTablesList
    is
    SELECT
                UPPER(ARCT_SCHEMA_NAME) SCHEMA_NAME,
                UPPER(ARCT_TABLE_NAME) TABLE_NAME,
                UPPER(ARCT_ARC_SCHEMA_NAME) ARCH_SCHEMA_NAME
                FROM FR_ARCHIVE_CTL
                WHERE ARCT_ARCHIVE = 'Y'
                AND ARCT_SCHEMA_NAME != ARCT_ARC_SCHEMA_NAME
                AND ARCT_ARC_TABLE_NAME != 'PURGE'
                GROUP BY ARCT_SCHEMA_NAME,ARCT_TABLE_NAME, ARCT_ARC_SCHEMA_NAME, ARCT_ARC_TABLE_NAME
    ;

    TYPE tables_array IS TABLE OF cTablesList%rowtype;
    tables_list tables_array;

    TYPE user_tables_array IS TABLE OF cUserTablesList%rowtype;
    user_tables_list user_tables_array;

    db_link_flag INTEGER;
    db_link_flag2 INTEGER;

    BEGIN
    --dbms_output.enable;
        -- grant priviliges on each tables defined in archive control table to FDR user exept those defined in FDR schema
        open cTablesList;
        FETCH cTablesList bulk collect INTO tables_list;
        close cTablesList;

        IF tables_list.count > 0 THEN

            FOR i IN tables_list.FIRST .. tables_list.LAST
            LOOP
                SELECT COUNT(*) INTO db_link_flag FROM USER_DB_LINKS WHERE USERNAME =  tables_list(i).SCHEMA_NAME;
                IF db_link_flag = 0 THEN
                    vProcedureName := tables_list(i).SCHEMA_NAME || '_ARCHIVING_SCRIPTS_PKG.PGRANT_PRIVILIGES_FOR_TABLE';
                    vSql := 'BEGIN ' || vProcedureName || '(:1, :2);  END;';
                    execute immediate  vSql USING  tables_list(i).TABLE_NAME, USER  ;
                END IF;
            END LOOP;

        END IF;

         -- grant create all table privilege to FDR user for every schema defined in control table except FDR schema
        open cUserTablesList;
        FETCH cUserTablesList bulk collect INTO user_tables_list;
        close cUserTablesList;

        IF user_tables_list.count > 0 THEN
            FOR i IN user_tables_list.FIRST .. user_tables_list.LAST
            LOOP
                -- check in case double instance configuration (if double instance grant across instances not allowed)
                SELECT COUNT(*) INTO db_link_flag FROM USER_DB_LINKS WHERE USERNAME =  user_tables_list(i).SCHEMA_NAME;
                SELECT COUNT(*) INTO db_link_flag2 FROM USER_DB_LINKS WHERE USERNAME =  user_tables_list(i).ARCH_SCHEMA_NAME;

                IF (db_link_flag = 0 AND db_link_flag2 = 0) OR (db_link_flag = 1 AND db_link_flag2 = 1)  THEN
                    IF user_tables_list(i).SCHEMA_NAME != USER THEN
                        -- grant create table to FDR on all schemas which are affected by archiving procedures
                        vProcedureName := user_tables_list(i).SCHEMA_NAME || '_ARCHIVING_SCRIPTS_PKG.PGRANT_PRIVILIGES_FOR_TABLE';
                        vSql := 'BEGIN ' || vProcedureName || '(:1, :2);  END;';
                        execute immediate vSql USING user_tables_list(i).TABLE_NAME, user_tables_list(i).ARCH_SCHEMA_NAME;
                    ELSE
                        --dbms_output.put_line('GRANT ALL ON ' || user_tables_list(i).TABLE_NAME || ' TO ' || user_tables_list(i).ARCH_SCHEMA_NAME);
                        execute immediate 'GRANT ALL ON ' || user_tables_list(i).TABLE_NAME || ' TO ' || user_tables_list(i).ARCH_SCHEMA_NAME;
                    END IF;
               END IF;
            END LOOP;
        END IF;



    EXCEPTION
		WHEN OTHERS THEN
			gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
			RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);

END PGRANT_PRIVILIGES;

PROCEDURE pCUST_RollFAKBalancesCUST     (      pLPGId                    in FR_LPG_CONFIG.LC_LPG_ID%TYPE default NULL,
                                                  pBatchSize                in INTEGER DEFAULT NULL,
                                                  pARCT_ID                  in FR_ARCHIVE_CTL.ARCT_ID%TYPE,
                                                  pArchRecCounter           out INTEGER
                                            )
IS

new_bal_date FDR.FR_GLOBAL_PARAMETER.GP_TODAYS_BUS_DATE%type;

 CURSOR cJrnTypes is
  SELECT DISTINCT EJT_BALANCE_TYPE_1 BAL_TYPE
  FROM SLR.SLR_EXT_JRNL_TYPES
    WHERE EJT_BALANCE_TYPE_1 != 10
  UNION
    SELECT DISTINCT EJT_BALANCE_TYPE_2 BAL_TYPE
  FROM SLR.SLR_EXT_JRNL_TYPES
    WHERE EJT_BALANCE_TYPE_2 != 10;

s_proc_name VARCHAR2(80) := 'FDR_CUSTOM_ARCHIVING_PKG.pCUST_RollFAKBalancesCUST';
gv_emsg VARCHAR(10000);

BEGIN

SELECT (g.gp_todays_bus_date - a.arct_archive_days) + 1
  INTO new_bal_date
  FROM fdr.fr_global_parameter g
       JOIN fdr.fr_archive_ctl a ON a.arct_id = pARCT_ID
 WHERE g.lpg_id = pLPGId;


FOR r_jt IN cJrnTypes
LOOP

INSERT INTO SLR.SLR_FAK_DAILY_BALANCES_TMP (
FDB_FAK_ID, FDB_BALANCE_DATE, FDB_BALANCE_TYPE,
   FDB_TRAN_DAILY_MOVEMENT, FDB_TRAN_MTD_BALANCE, FDB_TRAN_YTD_BALANCE,
   FDB_TRAN_LTD_BALANCE, FDB_BASE_DAILY_MOVEMENT, FDB_BASE_MTD_BALANCE,
   FDB_BASE_YTD_BALANCE, FDB_BASE_LTD_BALANCE, FDB_LOCAL_DAILY_MOVEMENT,
   FDB_LOCAL_MTD_BALANCE, FDB_LOCAL_YTD_BALANCE, FDB_LOCAL_LTD_BALANCE,
   FDB_ENTITY, FDB_EPG_ID, FDB_PERIOD_MONTH,
   FDB_PERIOD_YEAR, FDB_PERIOD_LTD, FDB_PROCESS_ID,
   FDB_AMENDED_ON, FDB_TRAN_QTD_BALANCE, FDB_BASE_QTD_BALANCE,
   FDB_LOCAL_QTD_BALANCE, FDB_PERIOD_QTR )
SELECT
FDB_FAK_ID, new_bal_date, FDB_BALANCE_TYPE,
   FDB_TRAN_DAILY_MOVEMENT, FDB_TRAN_MTD_BALANCE, FDB_TRAN_YTD_BALANCE,
   FDB_TRAN_LTD_BALANCE, FDB_BASE_DAILY_MOVEMENT, FDB_BASE_MTD_BALANCE,
   FDB_BASE_YTD_BALANCE, FDB_BASE_LTD_BALANCE, FDB_LOCAL_DAILY_MOVEMENT,
   FDB_LOCAL_MTD_BALANCE, FDB_LOCAL_YTD_BALANCE, FDB_LOCAL_LTD_BALANCE,
   FDB_ENTITY, FDB_EPG_ID, to_number(to_char(new_bal_date,'MM')) AS FDB_PERIOD_MONTH,
   TO_NUMBER(TO_CHAR(new_bal_date,'YYYY')) AS FDB_PERIOD_YEAR, FDB_PERIOD_LTD, FDB_PROCESS_ID,
   FDB_AMENDED_ON, FDB_TRAN_QTD_BALANCE, FDB_BASE_QTD_BALANCE,
   FDB_LOCAL_QTD_BALANCE, TO_NUMBER(TO_CHAR(new_bal_date,'Q')) AS FDB_PERIOD_QTR
FROM SLR.SLR_FAK_DAILY_BALANCES
WHERE FDB_BALANCE_TYPE = r_jt.BAL_TYPE
    and FDB_BALANCE_TYPE||fdb_fak_id||fdb_balance_date in (
with maxbal
as (
    select fdb_fak_id,FDB_BALANCE_TYPE,max(fdb_balance_date) mdate from slr.slr_fak_daily_balances
    where fdb_balance_date <= new_bal_date
    group by fdb_fak_id,FDB_BALANCE_TYPE)
    select db.FDB_BALANCE_TYPE||db.fdb_fak_id||db.fdb_balance_date
        from slr.slr_fak_daily_balances db
        join maxbal m on db.fdb_fak_id = m.fdb_fak_id and db.fdb_balance_date = m.mdate
        join fdr.fr_global_parameter gp on gp.lpg_id = pLPGId
        join fdr.fr_archive_ctl arc on arc.arct_id = pARCT_ID
        where m.mdate <= (gp.gp_todays_bus_date - arc.arct_archive_days )
        and db.fdb_balance_type = m.fdb_balance_type
        AND db.fdb_balance_type= r_jt.BAL_TYPE
        );
        fdr.PG_COMMON.pLogDebug(pinMessage => 'inserted TEMP FAK balances - '||to_char(sql%rowcount));

END LOOP;

INSERT /*+ APPEND */ INTO SLR.SLR_FAK_DAILY_BALANCES SELECT * FROM SLR.SLR_FAK_DAILY_BALANCES_TMP;


EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
        gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
        RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);

END;

PROCEDURE pCUST_RollEBABalancesCUST     (      pLPGId                    in FR_LPG_CONFIG.LC_LPG_ID%TYPE default NULL,
                                                  pBatchSize                in INTEGER DEFAULT NULL,
                                                  pARCT_ID                  in FR_ARCHIVE_CTL.ARCT_ID%TYPE,
                                                  pArchRecCounter           out INTEGER
                                            )
IS

new_bal_date FDR.FR_GLOBAL_PARAMETER.GP_TODAYS_BUS_DATE%type;

 CURSOR cJrnTypes is
  SELECT DISTINCT EJT_BALANCE_TYPE_1 BAL_TYPE
  FROM SLR.SLR_EXT_JRNL_TYPES
    WHERE EJT_BALANCE_TYPE_1 != 10
  UNION
    SELECT DISTINCT EJT_BALANCE_TYPE_2 BAL_TYPE
  FROM SLR.SLR_EXT_JRNL_TYPES
    WHERE EJT_BALANCE_TYPE_2 != 10;

s_proc_name VARCHAR2(80) := 'FDR_CUSTOM_ARCHIVING_PKG.pCUST_RollEBABalancesCUST';
gv_emsg VARCHAR(10000);

BEGIN

SELECT (g.gp_todays_bus_date - a.arct_archive_days) + 1
  INTO new_bal_date
  FROM fdr.fr_global_parameter g
       JOIN fdr.fr_archive_ctl a ON a.arct_id = pARCT_ID
 WHERE g.lpg_id = pLPGId;


FOR r_jt IN cJrnTypes
LOOP

INSERT INTO SLR.SLR_EBA_DAILY_BALANCES_TMP (
EDB_FAK_ID, EDB_EBA_ID, EDB_BALANCE_DATE,
   EDB_BALANCE_TYPE, EDB_TRAN_DAILY_MOVEMENT, EDB_TRAN_MTD_BALANCE,
   EDB_TRAN_YTD_BALANCE, EDB_TRAN_LTD_BALANCE, EDB_BASE_DAILY_MOVEMENT,
   EDB_BASE_MTD_BALANCE, EDB_BASE_YTD_BALANCE, EDB_BASE_LTD_BALANCE,
   EDB_LOCAL_DAILY_MOVEMENT, EDB_LOCAL_MTD_BALANCE, EDB_LOCAL_YTD_BALANCE,
   EDB_LOCAL_LTD_BALANCE, EDB_ENTITY, EDB_EPG_ID,
   EDB_PERIOD_MONTH, EDB_PERIOD_YEAR, EDB_PERIOD_LTD,
   EDB_PROCESS_ID, EDB_AMENDED_ON, EDB_TRAN_QTD_BALANCE,
   EDB_BASE_QTD_BALANCE, EDB_LOCAL_QTD_BALANCE, EDB_PERIOD_QTR )
SELECT
EDB_FAK_ID, EDB_EBA_ID, new_bal_date,
   EDB_BALANCE_TYPE, EDB_TRAN_DAILY_MOVEMENT, EDB_TRAN_MTD_BALANCE,
   EDB_TRAN_YTD_BALANCE, EDB_TRAN_LTD_BALANCE, EDB_BASE_DAILY_MOVEMENT,
   EDB_BASE_MTD_BALANCE, EDB_BASE_YTD_BALANCE, EDB_BASE_LTD_BALANCE,
   EDB_LOCAL_DAILY_MOVEMENT, EDB_LOCAL_MTD_BALANCE, EDB_LOCAL_YTD_BALANCE,
   EDB_LOCAL_LTD_BALANCE, EDB_ENTITY, EDB_EPG_ID,
   to_number(to_char(new_bal_date,'MM')) AS EDB_PERIOD_MONTH,
   to_number(to_char(new_bal_date,'YYYY')) AS EDB_PERIOD_YEAR, EDB_PERIOD_LTD,
   EDB_PROCESS_ID, EDB_AMENDED_ON, EDB_TRAN_QTD_BALANCE,
   EDB_BASE_QTD_BALANCE, EDB_LOCAL_QTD_BALANCE,
   to_number(to_char(new_bal_date,'Q')) AS EDB_PERIOD_QTR
FROM SLR.SLR_EBA_DAILY_BALANCES
WHERE EDB_BALANCE_TYPE = r_jt.BAL_TYPE
 AND EDB_BALANCE_TYPE||EDB_FAK_ID||EDB_EBA_ID||EDB_BALANCE_DATE in (
with maxbal
as (
    select EDB_FAK_ID,EDB_EBA_ID,EDB_BALANCE_TYPE,max(edb_balance_date) mdate from slr.slr_eba_daily_balances
    where edb_balance_date <= new_bal_date
    group by EDB_FAK_ID,EDB_EBA_ID,EDB_BALANCE_TYPE)
    select db.EDB_BALANCE_TYPE||db.EDB_FAK_ID||db.EDB_EBA_ID||db.edb_balance_date
        from slr.slr_eba_daily_balances db
        join maxbal m on db.EDB_FAK_ID = m.EDB_FAK_ID and db.edb_balance_date = m.mdate
                and db.EDB_EBA_ID = m.EDB_EBA_ID
        join fdr.fr_global_parameter gp on gp.lpg_id = pLPGId
        join fdr.fr_archive_ctl arc on arc.arct_id = pARCT_ID
        where m.mdate <= (gp.gp_todays_bus_date - arc.arct_archive_days )
        and db.edb_balance_type = m.edb_balance_type
        AND db.edb_balance_type= r_jt.BAL_TYPE
        );

END LOOP;

INSERT /*+ APPEND */ INTO SLR.SLR_EBA_DAILY_BALANCES SELECT * FROM SLR.SLR_EBA_DAILY_BALANCES_TMP;

    EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
            gv_emsg := 'Failure in ' || s_proc_name || ': '|| sqlerrm;
            RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);


END;

END FDR_CUSTOM_ARCHIVING_PKG;
/
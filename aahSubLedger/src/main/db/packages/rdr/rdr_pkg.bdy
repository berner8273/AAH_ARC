create or replace PACKAGE BODY     rdr_pkg
AS
    PROCEDURE pGLINT_CLEANUP
    AS
        max_glint_id  NUMBER;

    BEGIN


      -- SET MANUALS PERIODS REQUESTS BACK TO N AND RECORD DATE

      UPDATE fdr.fr_general_lookup
         SET lk_lookup_value5 = 'N',
             lk_lookup_value6 =
                CONCAT (
                   CONCAT (TO_CHAR (SYSDATE, 'MM-DD-YYYY HH:MI:SS'), '  '),
                   lk_input_by)
       WHERE     lk_lkt_lookup_type_code = 'EVENT_CLASS_PERIOD'
             AND lk_lookup_value5 = 'Y';


      -- STORE THE MAPPING FROM SLR JOURNALS TO GLINT JOURNALS

    SELECT NVL (MAX (RGJL_ID), 0) INTO max_glint_id FROM RDR.RR_GLINT_TO_SLR_AG GTS;
    DBMS_OUTPUT.PUT_LINE(max_glint_id);

    INSERT INTO RDR.RR_GLINT_TO_SLR_AG (RGJL_ID, JL_JRNL_HDR_ID, JL_JRNL_LINE_NUMBER)
    SELECT GJL.G_RGJL_ID, SJL.S_JL_JRNL_HDR_ID, SJL.S_JL_JRNL_LINE_NUMBER
    FROM
        (
            SELECT  
                     GJL.RGJL_ID            AS G_RGJL_ID
                    ,GJL.ACCOUNTING_DT      AS G_ACCOUNTING_DT
                    ,GJL.FOREIGN_CURRENCY   AS G_FOREIGN_CURRENCY
                    ,GJL.CURRENCY_CD        AS G_CURRENCY_CD
                    ,GJL.ACCOUNT            AS G_ACCOUNT
                    ,GJL.CHARTFIELD1        AS G_CHARTFIELD1
                    ,GJL.DEPTID             AS G_DEPTID
                    ,GJL.AFFILIATE          AS G_AFFILIATE
                    ,GJL.BUSINESS_UNIT_GL   AS G_BUSINESS_UNIT_GL
                    ,GJL.SLR_PROCESS_ID     AS G_SLR_PROCESS_ID
                    ,GJL.LEDGER_GROUP       AS G_LEDGER_GROUP
                    ,GJL.EVENT_CLASS        AS G_EVENT_CLASS
                    ,GJL.JH_JRNL_TYPE       AS G_JRNL_TYPE
                    ,CASE WHEN GJL.MANUAL_JE = 'Y' THEN GJL.AAH_JRNL_HDR_NBR ELSE 0 END AS G_MANUAL_HEADER_ID
            FROM RDR.RR_GLINT_JOURNAL_LINE GJL
        ) GJL
    JOIN
        (
            SELECT   SJL.JL_JRNL_HDR_ID         AS S_JL_JRNL_HDR_ID
                    ,SJL.JL_JRNL_LINE_NUMBER    AS S_JL_JRNL_LINE_NUMBER               
                    ,SJL.JL_EFFECTIVE_DATE      AS S_JL_EFFECTIVE_DATE
                    ,SJL.JL_TRAN_CCY            AS S_JL_TRAN_CCY
                    ,CASE WHEN SJL.JL_SEGMENT_1 = 'UKGAAP_ADJ' THEN  SJL.JL_LOCAL_CCY ELSE SJL.JL_BASE_CCY END AS S_JL_BASE_CCY
                    ,SUBSTR (SJL.JL_ACCOUNT, 1, 8) AS S_ACCOUNT
                    ,CASE WHEN SJL.JL_SEGMENT_3 = 'NVS' THEN ' '  ELSE SJL.JL_SEGMENT_3 END  AS S_DEPTID
                    ,CASE WHEN SJL.JL_SEGMENT_5 = 'NVS' THEN ' ' ELSE SUBSTR (SJL.JL_SEGMENT_5, 1, 10) END AS S_CHARTFIELD1
                    ,CASE WHEN SJL.JL_SEGMENT_4 = 'NVS' THEN ' ' ELSE SJL.JL_SEGMENT_4 END AS S_AFFILIATE
                    ,SJL.JL_ENTITY              AS S_JL_ENTITY
                    ,SJL.JL_JRNL_PROCESS_ID     AS S_JL_JRNL_PROCESS_ID
                    ,SJL.JL_SEGMENT_1           AS S_LEDGER_GROUP        
                    ,sjh.JH_JRNL_TYPE           AS S_JRNL_TYPE
                    ,eh.EVENT_CLASS             AS S_EVENT_CLASS
                    ,CASE WHEN jh_jrnl_type like 'MADJ%' THEN sjl.JL_JRNL_HDR_ID ELSE 0 END AS S_MANUAL_HEADER_ID
            FROM     SLR.SLR_JRNL_LINES SJL
                JOIN SLR.SLR_JRNL_HEADERS sjh ON sjh.JH_JRNL_ID = sjl.JL_JRNL_HDR_ID 
                JOIN 
                    (   SELECT LK_MATCH_KEY1 AS EVENT_TYPE, LK_LOOKUP_VALUE3 AS EVENT_CLASS
                        FROM FDR.FR_GENERAL_LOOKUP l 
                        WHERE l.LK_LKT_LOOKUP_TYPE_CODE = 'EVENT_HIERARCHY'
                    ) eh ON SJL.JL_ATTRIBUTE_4 = eh.EVENT_TYPE
        ) SJL ON     GJL.G_ACCOUNTING_DT      = SJL.S_JL_EFFECTIVE_DATE 
                 AND GJL.G_FOREIGN_CURRENCY   = SJL.S_JL_TRAN_CCY
                 AND GJL.G_CURRENCY_CD        = SJL.S_JL_BASE_CCY
                 AND GJL.G_ACCOUNT            = SJL.S_ACCOUNT
                 AND GJL.G_CHARTFIELD1        = SJL.S_CHARTFIELD1
                 AND GJL.G_DEPTID             = SJL.S_DEPTID
                 AND GJL.G_AFFILIATE          = SJL.S_AFFILIATE
                 AND GJL.G_BUSINESS_UNIT_GL   = SJL.S_JL_ENTITY
                 AND GJL.G_SLR_PROCESS_ID     = SJL.S_JL_JRNL_PROCESS_ID
                 AND GJL.G_LEDGER_GROUP       = SJL.S_LEDGER_GROUP
                 AND GJL.G_EVENT_CLASS        = SJL.S_EVENT_CLASS
                 AND GJL.G_MANUAL_HEADER_ID   = SJL.S_MANUAL_HEADER_ID
                 AND GJL.G_JRNL_TYPE   = SJL.S_JRNL_TYPE    
    WHERE GJL.G_RGJL_ID > max_glint_id ;

   END pGLINT_CLEANUP;

END rdr_pkg;
/
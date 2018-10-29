CREATE OR REPLACE PACKAGE BODY rdr.rdr_pkg
AS
   PROCEDURE pGLINT_CLEANUP
   AS
   
   BEGIN

   -- SET MANUALS PERIODS REQUESTS BACK TO N AND RECORD DATE

   UPDATE fdr.fr_general_lookup
   SET lk_lookup_value5 = 'N',
       lk_lookup_value6 = SYSDATE
   WHERE   lk_lkt_lookup_type_code = 'EVENT_CLASS_PERIOD'
   AND     lk_lookup_value5 = 'Y';

   
   -- STORE THE MAPPING FROM SLR JOURNALS TO GLINT JOURNALS
   
   INSERT INTO RDR.RR_GLINT_TO_SLR_AG (RGJL_ID,
                                    JL_JRNL_HDR_ID,
                                    JL_JRNL_LINE_NUMBER)
     SELECT GJL.RGJL_ID,
            SJL.JL_JRNL_HDR_ID,
            SJL.JL_JRNL_LINE_NUMBER
       FROM RDR.RR_GLINT_JOURNAL_LINE GJL
            JOIN SLR.SLR_JRNL_LINES SJL
               ON     SJL.JL_EFFECTIVE_DATE = GJL.ACCOUNTING_DT
                  AND SJL.JL_TRAN_CCY = GJL.FOREIGN_CURRENCY
                  AND SJL.JL_BASE_CCY = GJL.CURRENCY_CD
                  AND SUBSTR (SJL.JL_ACCOUNT, 1, 8) = GJL.ACCOUNT
                  AND (CASE
                          WHEN SJL.JL_SEGMENT_3 = 'NVS' THEN ' '
                          ELSE SJL.JL_SEGMENT_3
                       END) = GJL.DEPTID
                  AND (CASE
                          WHEN SJL.JL_SEGMENT_5 = 'NVS' THEN ' '
                          ELSE SUBSTR (SJL.JL_SEGMENT_5, 1, 10)
                       END) = GJL.CHARTFIELD1
                  AND (CASE
                          WHEN SJL.JL_SEGMENT_4 = 'NVS' THEN ' '
                          ELSE SJL.JL_SEGMENT_4
                       END) = GJL.AFFILIATE
                  AND SJL.JL_ENTITY = GJL.BUSINESS_UNIT_GL
                  AND SJL.JL_JRNL_PROCESS_ID = GJL.SLR_PROCESS_ID
                  AND SJL.JL_SEGMENT_1 = GJL.LEDGER_GROUP
                  AND (   (    GJL.MANUAL_JE = 'Y'
                           AND SJL.JL_JRNL_HDR_ID = GJL.AAH_JRNL_HDR_NBR)
                       OR (GJL.MANUAL_JE = 'N' AND GJL.AAH_JRNL_HDR_NBR = 0))
            JOIN FDR.FR_GENERAL_LOOKUP FGL
               ON     SJL.JL_ATTRIBUTE_4 = FGL.LK_MATCH_KEY1
                  AND FGL.LK_LKT_LOOKUP_TYPE_CODE = 'EVENT_HIERARCHY'
                  AND GJL.EVENT_CLASS = FGL.LK_LOOKUP_VALUE3
      WHERE GJL.RGJL_ID > (SELECT NVL (MAX (RGJL_ID), 0)
                                      FROM RDR.RR_GLINT_TO_SLR_AG GTS)
   ORDER BY 1;
   
   END pGLINT_CLEANUP;

END rdr_pkg;
/
CREATE OR REPLACE FORCE VIEW SLR.V_AG_YE_CLR_RUN
(
   PC_CONFIG,
   SPS_SOURCE_NAME,
   YE_DATE
)
AS
   SELECT C.PC_CONFIG,
          S.SPS_SOURCE_NAME,
          TO_DATE ('12/31/' || TO_CHAR (YE.CLOSE_YEAR), 'mm/dd/yyyy')
             AS YE_DATE
     FROM SLR.SLR_PROCESS_CONFIG C
          INNER JOIN SLR.SLR_PROCESS_SOURCE S
             ON SUBSTR (S.SPS_SOURCE_NAME, -1, LENGTH (S.SPS_SOURCE_NAME)) =
                   SUBSTR (C.PC_CONFIG, -1, LENGTH (C.PC_CONFIG)),
          (SELECT (EXTRACT (YEAR FROM GP_TODAYS_BUS_DATE) - 1) AS CLOSE_YEAR
             FROM FDR.FR_GLOBAL_PARAMETER
            WHERE LPG_ID = 2) YE
    WHERE     C.PC_CONFIG LIKE 'PLRETEARNINGS0%'
          AND S.SPS_SOURCE_NAME LIKE 'BMRETAINEDEARNINGSEBA0%'
          AND NOT EXISTS   /*CHECK THAT ALL PERIODS IN PRIOR YEAR ARE CLOSED*/
                     (SELECT 'X'
                        FROM FDR.FR_GENERAL_LOOKUP
                       WHERE     LK_LKT_LOOKUP_TYPE_CODE =
                                    'EVENT_CLASS_PERIOD'
                             AND LK_LOOKUP_VALUE1 = 'O'
                             AND LK_MATCH_KEY2 = YE.CLOSE_YEAR)
          AND NOT EXISTS                /*CHECK THAT JAN OF NEW YEAR IS OPEN*/
                     (SELECT 'X'
                        FROM FDR.FR_GENERAL_LOOKUP
                       WHERE     LK_LKT_LOOKUP_TYPE_CODE =
                                    'EVENT_CLASS_PERIOD'
                             AND LK_LOOKUP_VALUE1 = 'C'
                             AND LK_MATCH_KEY2 = (YE.CLOSE_YEAR + 1)
                             AND LK_MATCH_KEY3 = 01)
          AND EXISTS /*CHECK THAT A PERIOD CLOSED AFTER THE LAST YE PROCESS RAN*/
                 (SELECT 'X'
                    FROM FDR.FR_GENERAL_LOOKUP_AUD
                   WHERE     LK_LKT_LOOKUP_TYPE_CODE = 'EVENT_CLASS_PERIOD'
                         AND LK_LOOKUP_VALUE1 = 'C'
                         AND LK_MATCH_KEY2 = YE.CLOSE_YEAR
                         AND LK_VALID_FROM >
                                (SELECT NVL (
                                           MAX (JH_JRNL_POSTED_ON),
                                           TO_DATE ('01/01/2000',
                                                    'mm/dd/yyyy'))
                                   FROM SLR.SLR_JRNL_HEADERS
                                  WHERE     JH_JRNL_INTERNAL_PERIOD_FLAG =
                                               'Y'
                                        AND EXTRACT (YEAR FROM JH_JRNL_DATE) =
                                               YE.CLOSE_YEAR + 1));
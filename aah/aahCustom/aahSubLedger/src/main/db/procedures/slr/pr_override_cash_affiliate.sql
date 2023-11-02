CREATE OR REPLACE PROCEDURE SLR.pr_override_cash_affiliate
AS
      s_proc_name   VARCHAR2 (80) := 'slr.pr_override_cash_affiliate';

BEGIN

MERGE INTO SLR.SLR_JRNL_LINES_UNPOSTED JRNL
     USING (SELECT jlu_eba_id, jlu_jrnl_line_number
              FROM SLR.SLR_JRNL_LINES_UNPOSTED
             WHERE     JLU_SOURCE_JRNL_ID IN (SELECT JLU_SOURCE_JRNL_ID
                                                FROM SLR.SLR_JRNL_LINES_UNPOSTED JRNL
                                                     INNER JOIN
                                                     FDR.FR_ACCOUNTING_EVENT_IMP FAE
                                                        ON     FAE.AE_AMOUNT =
                                                                  JRNL.JLU_TRAN_AMOUNT
                                                           AND JRNL.JLU_SOURCE_JRNL_ID =
                                                                  FAE.ae_acc_event_id
                                                           AND AE_EPG_ID =
                                                                  JLU_EPG_ID
                                               WHERE     SUBSTR (
                                                            AE_GL_ACCOUNT,
                                                            1,
                                                            8) <> '18250255'
                                                     AND SUBSTR (
                                                            AE_GL_ACCOUNT,
                                                            1,
                                                            8) =
                                                            AE_CLIENT_SPARE_ID2)
                   AND SUBSTR (JLU_ACCOUNT, 1, 8) IN (SELECT DISTINCT
                                                             al_lookup_5
                                                        FROM fdr.fr_account_lookup
                                                       WHERE al_lookup_5 NOT IN ('ND~',
                                                                                 'NVS'))) CO
        ON (    JRNL.JLU_eba_ID = CO.JLU_eba_ID
            AND JRNL.JLU_jrnl_line_number = CO.JLU_jrnl_line_number)
WHEN MATCHED
THEN
   UPDATE SET JRNL.JLU_SEGMENT_4 = 'NVS',
              JLU_FAK_ID= standard_hash(jlu_entity||jlu_epg_id||jlu_account||jlu_segment_1||jlu_segment_2||jlu_segment_3||'NVS'||jlu_segment_5||jlu_segment_6||jlu_segment_7||jlu_segment_8||jlu_segment_9||jlu_segment_10||jlu_tran_ccy, 'MD5');
     
   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      pr_error (slr_global_pkg.C_MAJERR,
                'Failure to execute pr_override_cash_affiliate: ' || SQLERRM,
                slr_global_pkg.C_TECHNICAL,
                s_proc_name,
                'SLR_JRNL_LINES_UNPOSTED',
                NULL,
                'Entity',
                NULL,
                'PL/SQL',
                SQLCODE);

      RAISE_APPLICATION_ERROR (
         -20001,
         'Fatal error during call of pr_override_cash_affiliate: ' || SQLERRM);
END pr_override_cash_affiliate;
/
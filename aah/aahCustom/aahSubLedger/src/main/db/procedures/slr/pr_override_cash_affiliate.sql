CREATE OR REPLACE PROCEDURE SLR.pr_override_cash_affiliate
AS
      s_proc_name   VARCHAR2 (80) := 'SLR_PKH.pOverride_cash_affiliate';

BEGIN

/* Formatted on 11/01/2023 3:50:17 PM (QP5 v5.252.13127.32847) */
MERGE INTO SLR.SLR_JRNL_LINES_UNPOSTED JRNL
     USING (SELECT jlu_fak_id, jlu_jrnl_line_number
              FROM SLR.SLR_JRNL_LINES_UNPOSTED
                   INNER JOIN
                   (SELECT lk_match_key1
                      FROM fdr.fr_general_lookup
                     WHERE lk_lkt_lookup_type_code = 'CASH_ACCOUNTS') C
                      ON c.lk_match_key1 = jlu_account
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
                                                                                 'NVS')))
           CO
        ON (    JRNL.JLU_FAK_ID = CO.JLU_FAK_ID
            AND JRNL.JLU_jrnl_line_number = CO.JLU_jrnl_line_number)
WHEN MATCHED
THEN
   UPDATE SET JRNL.JLU_SEGMENT_4 = 'NVS';
   
   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      pr_error (slr_global_pkg.C_MAJERR,
                'Failure to execute pOverride_cash_affiliate: ' || SQLERRM,
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
         'Fatal error during call of pOverride_cash_affiliate: ' || SQLERRM);
END pr_override_cash_affiliate;
/
CREATE OR REPLACE PROCEDURE SLR.pr_override_cash_affiliate
AS
      s_proc_name   VARCHAR2 (80) := 'SLR_PKH.pOverride_cash_affiliate';

BEGIN
   
   MERGE INTO SLR.SLR_JRNL_LINES_UNPOSTED JRNL
        USING (SELECT DISTINCT JLU_SOURCE_JRNL_ID, JLU_SEGMENT_4
                 FROM SLR.SLR_JRNL_LINES_UNPOSTED JRNL
                      INNER JOIN FDR.FR_ACCOUNTING_EVENT_IMP FAE
                         ON     FAE.AE_AMOUNT = JRNL.JLU_TRAN_AMOUNT
                            AND JRNL.JLU_SOURCE_JRNL_ID = FAE.ae_acc_event_id
                            AND AE_EPG_ID = JLU_EPG_ID
                WHERE     SUBSTR (AE_GL_ACCOUNT, 1, 8) <> '18250255'
                      AND SUBSTR (AE_GL_ACCOUNT, 1, 8) = AE_CLIENT_SPARE_ID2)
              CO
           ON (JRNL.JLU_SOURCE_JRNL_ID = CO.JLU_SOURCE_JRNL_ID)
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
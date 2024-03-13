CREATE OR REPLACE PROCEDURE SLR.pr_override_cash_affiliate
AS
   s_proc_name   VARCHAR2 (80) := 'slr.pr_override_cash_affiliate';
BEGIN
   UPDATE SLR.SLR_JRNL_LINES_UNPOSTED
      SET JLU_SEGMENT_4 = 'NVS',
          JLU_FAK_ID =
             standard_hash (
                   jlu_entity
                || jlu_epg_id
                || jlu_account
                || jlu_segment_1
                || jlu_segment_2
                || jlu_segment_3
                || 'NVS'
                || jlu_segment_5
                || jlu_segment_6
                || jlu_segment_7
                || jlu_segment_8
                || jlu_segment_9
                || jlu_segment_10
                || jlu_tran_ccy,
                'MD5'),
          JLU_EBA_ID =
             standard_hash (
                   jlu_entity
                || jlu_epg_id
                || jlu_account
                || jlu_segment_1
                || jlu_segment_2
                || jlu_segment_3
                || 'NVS'
                || jlu_segment_5
                || jlu_segment_6
                || jlu_segment_7
                || jlu_segment_8
                || jlu_segment_9
                || jlu_segment_10
                || jlu_tran_ccy
                || jlu_attribute_1
                || jlu_attribute_2
                || jlu_attribute_3
                || jlu_attribute_4
                || jlu_attribute_5,
                'MD5')
    WHERE     jlu_entity NOT IN (select distinct elimination_le_cd from stn.elimination_legal_entity)
          AND jlu_type is null AND SUBSTR (JLU_ACCOUNT, 1, 8) IN (SELECT DISTINCT al_lookup_5
                                               FROM fdr.fr_account_lookup
                                              WHERE al_lookup_5 NOT IN ('ND~','18250255',                                                                   
                                                                        'NVS'));


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
                'SLR',
                NULL,
                'PL/SQL',
                SQLCODE);

      RAISE_APPLICATION_ERROR (
         -20001,
         'Fatal error during call of pr_override_cash_affiliate: ' || SQLERRM);
END pr_override_cash_affiliate;
/
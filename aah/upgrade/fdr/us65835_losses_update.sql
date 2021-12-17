UPDATE fdr.fr_stan_raw_acc_event fsrae
SET fsrae.srae_client_spare_id2 = 'NVS'
WHERE fsrae.srae_dimension_12 in ('A','D')
     and fsrae.srae_acc_event_type in (
                                'LOSSES_PAID',
                                'LOSS_RECOVERIES',
                                'LAE_PAID',
                                'LAE_RECOVERIES',
                                'LM_PAID',
                                'LM_RECOVERED')
     and fsrae.srae_client_spare_id2 is null
     and to_char(fsrae.srae_accevent_date,'mm-yyyy') IN (
SELECT  to_char(TO_DATE (fgl.lk_lookup_value3, 'DD-MON-YYYY'),'mm-yyyy') 
     FROM fdr.fr_general_lookup fgl
          JOIN
          (  SELECT MIN (fgl2.lk_match_key2 || LPAD (lk_match_key3, 2, '0'))
                       min_period,
                    fgl2.lk_match_key1 event_class
               FROM fdr.fr_general_lookup fgl2
              WHERE     fgl2.lk_lkt_lookup_type_code = 'EVENT_CLASS_PERIOD'
                    AND fgl2.lk_lookup_value1 = 'O'
           GROUP BY fgl2.lk_match_key1) open_period
             ON     fgl.lk_match_key2 || lk_match_key3 =
                       open_period.min_period
                AND fgl.lk_match_key1 = open_period.event_class
    WHERE fgl.lk_lkt_lookup_type_code = 'EVENT_CLASS_PERIOD' and fgl.lk_match_key1 = 'LOSSES');
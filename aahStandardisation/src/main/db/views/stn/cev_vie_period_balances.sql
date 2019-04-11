create or replace view stn.cev_vie_period_balances as
  SELECT 
    SUM (transaction_balance) transaction_balance,
    SUM (reporting_balance) reporting_balance,
    SUM (functional_balance) functional_balance,
    stream_id,
    business_unit,
    sub_account,
    currency,
    basis_cd,
    balance_date end_of_period
FROM (
        WITH edb_bal AS (
                SELECT
                    RANK() OVER (PARTITION BY sedb.edb_eba_id, sedb.edb_fak_id ORDER BY sedb.edb_balance_date DESC) AS date_rank,
                    MAX(sedb.edb_balance_date) OVER (PARTITION BY sec.ec_attribute_1, sfc.fc_entity, sfc.fc_account) AS max_agg_date,
                    sedb.edb_eba_id,
                    sedb.edb_fak_id,
                    sedb.edb_balance_date balance_date,
                    sec.ec_attribute_1 stream_id,
                    sfc.fc_entity business_unit,
                    sfc.fc_account sub_account,
                    sfc.fc_ccy currency,
                    'US_GAAP' basis_cd,
                    sedb.edb_tran_ltd_balance transaction_balance,
                    sedb.edb_base_ltd_balance reporting_balance,
                    sedb.edb_local_ltd_balance functional_balance
                FROM slr.slr_eba_daily_balances sedb
                    JOIN slr.slr_fak_combinations sfc
                        ON sedb.edb_fak_id = sfc.fc_fak_id
                    JOIN slr.slr_eba_combinations sec
                        ON sedb.edb_eba_id = sec.ec_eba_id
                WHERE sfc.fc_segment_2 IN ('US_STAT', 'US_GAAP'))
        SELECT
            LAST_DAY(ADD_MONTHS((SELECT TRUNC(MIN(eb.balance_date),'MONTH') FROM edb_bal), rownum -1)) AS balance_date,
            eb.stream_id,
            eb.business_unit,
            eb.sub_account,
            eb.currency,
            eb.basis_cd,
            eb.transaction_balance,
            eb.reporting_balance,
            eb.functional_balance
        FROM edb_bal eb
            JOIN all_objects on 1=1
        WHERE ROWNUM <= MONTHS_BETWEEN((SELECT TRUNC(MAX(max_agg_date),'MONTH') FROM edb_bal),(SELECT TRUNC(MIN(balance_date),'MONTH') FROM edb_bal))+1
            AND eb.date_rank = 1 
            AND eb.max_agg_date > balance_date
        UNION
        SELECT
            eb2.balance_date,
            eb2.stream_id,
            eb2.business_unit,
            eb2.sub_account,
            eb2.currency,
            eb2.basis_cd,
            eb2.transaction_balance,
            eb2.reporting_balance,
            eb2.functional_balance
        FROM edb_bal eb2
) 
GROUP BY 
    stream_id,
    business_unit,
    sub_account,
    currency,
    basis_cd,
    balance_date;
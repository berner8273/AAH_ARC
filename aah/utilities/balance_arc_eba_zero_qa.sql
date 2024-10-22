-- get the most recent eba balance record for each combination of fak_id, eba_id, and balance type
with max_eba as
(select 
    edb_fak_id, 
    edb_eba_id, 
    edb2.edb_balance_type, 
    max(edb_balance_date ) max_date
from 
    slr.slr_eba_daily_balances edb2
group by 
    edb2.edb_fak_id, 
    edb2.edb_eba_id,
    edb2.edb_balance_type )
-- main query
select 
    fc_entity,
    fc_ccy,
    fc_segment_1 ledger,
    fc_segment_7 business_type,
    --fc_segment_8 policy_id,
    edb1.edb_balance_type,
    sum(edb1.edb_base_ltd_balance),
    sum(edb1.edb_local_ltd_balance),
    sum(edb1.edb_tran_ltd_balance)
from 
    max_eba,
    slr.slr_eba_daily_balances edb1,
    slr.slr_fak_combinations fc,
    slr.slr_eba_combinations ec  ,
    fdr.fr_gl_account gla
where 
    max_eba.edb_fak_id = edb1.edb_fak_id and 
    max_eba.edb_eba_id = edb1.edb_eba_id and
    max_eba.edb_balance_type = edb1.edb_balance_type and
    max_eba.max_date = edb1.edb_balance_date and  
    edb1.edb_fak_id = fc.fc_fak_id and  
    edb1.edb_eba_id = ec.ec_eba_id and 
    gla.ga_account_code = fc.fc_account
group by 
    fc_entity,
    fc_ccy,
    fc_segment_1,
    fc_segment_7,
    --fc_segment_8,  policy_id
    edb1.edb_balance_type


with max_fak as
    (select 
        fdb_fak_id, 
        fak2.fdb_balance_type, 
        max(fdb_balance_date ) max_date
from 
    slr.slr_fak_daily_balances fak2
group by 
    fak2.fdb_fak_id,
    fak2.fdb_balance_type )
-- main query
select 
    fc_entity,
    fc_ccy,
    fc_segment_1 ledger,
    fc_segment_7 business_type,
    --fc_segment_8 policy_id,
    fdb1.fdb_balance_type,
    sum(fdb1.fdb_base_ltd_balance) base_bal,
    sum(fdb1.fdb_local_ltd_balance) local_bal,
    sum(fdb1.fdb_tran_ltd_balance) tran_bal
from 
    max_fak,
    slr.slr_fak_daily_balances fdb1,
    slr.slr_fak_combinations fc,
    fdr.fr_gl_account gla
where 
    max_fak.fdb_fak_id = fdb1.fdb_fak_id and 
    max_fak.fdb_balance_type = fdb1.fdb_balance_type and
    max_fak.max_date = fdb1.fdb_balance_date and  
    fdb1.fdb_fak_id = fc.fc_fak_id and  
    gla.ga_account_code = fc.fc_account
group by 
    fc_entity,
    fc_ccy,
    fc_segment_1,
    fc_segment_7,
    --fc_segment_8,  policy_id
    fdb1.fdb_balance_type

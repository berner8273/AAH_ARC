DECLARE 

dNewBalDate date := '02-jan-23';

cursor cur_jrnl_types is
select 
    distinct ejt_balance_type_1 bal_type
from 
    slr.slr_ext_jrnl_types
where ejt_balance_type_1 != 10
union
select distinct ejt_balance_type_2 bal_type
from slr.slr_ext_jrnl_types
where ejt_balance_type_2 != 10;

s_proc_name varchar2(80) := 'FDR_CUSTOM_ARCHIVING_PKG.pCUST_RollEBABalancesCUST';
gv_emsg varchar(10000);

BEGIN



for rec in cur_jrnl_types LOOP


insert into slr.slr_eba_daily_balances (
    edb_fak_id, 
    edb_eba_id, 
    edb_balance_date,
    edb_balance_type, 
    edb_tran_daily_movement, 
    edb_tran_mtd_balance,
    edb_tran_ytd_balance, 
    edb_tran_ltd_balance, 
    edb_base_daily_movement,
    edb_base_mtd_balance, 
    edb_base_ytd_balance, 
    edb_base_ltd_balance,
    edb_local_daily_movement, 
    edb_local_mtd_balance, 
    edb_local_ytd_balance,
    edb_local_ltd_balance, 
    edb_entity, 
    edb_epg_id,
    edb_period_month, 
    edb_period_year, 
    edb_period_ltd,
    edb_process_id, 
    edb_amended_on, 
    edb_tran_qtd_balance,
    edb_base_qtd_balance, 
    edb_local_qtd_balance, 
    edb_period_qtr )
select
    edb1.edb_fak_id, 
    edb1.edb_eba_id, 
    dNewBalDate as new_bal_date, --new_bal_date,
    edb1.edb_balance_type, 
    edb1.edb_tran_daily_movement, 
    edb1.edb_tran_mtd_balance,
    edb1.edb_tran_ytd_balance, 
    edb1.edb_tran_ltd_balance, 
    edb1.edb_base_daily_movement,
    edb1.edb_base_mtd_balance, 
    edb1.edb_base_ytd_balance, 
    edb1.edb_base_ltd_balance,
    edb1.edb_local_daily_movement, 
    edb1.edb_local_mtd_balance, 
    edb1.edb_local_ytd_balance,
    edb1.edb_local_ltd_balance, 
    edb1.edb_entity, 
    edb1.edb_epg_id,
    extract(month from dNewBalDate) as edb_period_month, 
    extract(year from dNewBalDate) as edb_period_year, 
    edb1.edb_period_ltd,
    edb1.edb_process_id, 
    sysdate as edb_amended_on, 
    edb1.edb_tran_qtd_balance,
    edb1.edb_base_qtd_balance, 
    edb1.edb_local_qtd_balance, 
    1 as edb_period_qtr
from 
    slr.slr_eba_daily_balances edb1
where 
    edb1.edb_balance_type = rec.bal_type and 
    edb1.edb_balance_type||edb1.edb_fak_id||edb1.edb_eba_id||edb1.edb_balance_date in (
with maxbal
as (
    select 
        m.edb_fak_id,
        m.edb_eba_id,
        m.edb_balance_type,
        max(m.edb_balance_date) mdate 
    from 
        slr.slr_eba_daily_balances m
    group by 
        m.edb_fak_id,
        m.edb_eba_id,
        m.edb_balance_type)
select 
    edb.edb_balance_type||edb.edb_fak_id||edb.edb_eba_id||edb.edb_balance_date
from 
    slr.slr_eba_daily_balances edb
    join slr.slr_fak_combinations fc on edb.edb_fak_id = fc.fc_fak_id
    join maxbal m on edb.edb_fak_id = m.edb_fak_id and edb.edb_balance_date = m.mdate  and edb.edb_eba_id = m.edb_eba_id
where 
        substr(fc.fc_account,1,8) =  '31580017' and 
        edb.edb_balance_type = m.edb_balance_type and 
        edb.edb_balance_type= rec.bal_type);

end loop;

commit;


END;

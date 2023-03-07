select edb_balance_date,EDB_BALANCE_TYPE,edb_entity,sum(edb_tran_ltd_balance),sum(edb_base_ltd_balance),sum(edb_local_ltd_balance) from slr.slr_eba_daily_balances 
where EDB_FAK_ID||EDB_EBA_ID||edb_balance_date in (   
with maxbal
as (
    select EDB_FAK_ID,EDB_EBA_ID,max(edb_balance_date) mdate from slr.slr_eba_daily_balances  
    group by EDB_FAK_ID,EDB_EBA_ID)
    select db.EDB_FAK_ID||db.EDB_EBA_ID||db.edb_balance_date 
        from slr.slr_eba_daily_balances db
        join maxbal m on db.EDB_FAK_ID = m.EDB_FAK_ID and db.edb_balance_date = m.mdate
                and db.EDB_EBA_ID = m.EDB_EBA_ID  )
group by edb_balance_date,EDB_BALANCE_TYPE,edb_entity 
order by edb_balance_date,EDB_BALANCE_TYPE

-- by balance date

select fdb_balance_date,FDB_BALANCE_TYPE,fdb_entity,sum(fdb_tran_ltd_balance),sum(fdb_base_ltd_balance),sum(fdb_local_ltd_balance) from slr.slr_fak_daily_balances
where FDB_BALANCE_TYPE||fdb_fak_id||fdb_balance_date in ( 
WITH maxbal
as (
    select fdb_fak_id,FDB_BALANCE_TYPE,max(fdb_balance_date) mdate 
        from slr.slr_fak_daily_balances
        group by fdb_fak_id,FDB_BALANCE_TYPE
        )
    select db.FDB_BALANCE_TYPE||db.fdb_fak_id||db.fdb_balance_date
        from slr.slr_fak_daily_balances db
        join maxbal m on db.fdb_fak_id = m.fdb_fak_id 
        and db.fdb_balance_type= m.fdb_balance_type and db.fdb_balance_date = m.mdate)
group by fdb_balance_date,FDB_BALANCE_TYPE,fdb_entity

-- by entity

select FDB_BALANCE_TYPE,fdb_entity,sum(fdb_tran_ltd_balance),sum(fdb_base_ltd_balance),sum(fdb_local_ltd_balance) from slr.slr_fak_daily_balances
where FDB_BALANCE_TYPE||fdb_fak_id||fdb_balance_date in ( 
WITH maxbal
as (
    select fdb_fak_id,FDB_BALANCE_TYPE,max(fdb_balance_date) mdate 
        from slr.slr_fak_daily_balances
        group by fdb_fak_id,FDB_BALANCE_TYPE
        )
    select db.FDB_BALANCE_TYPE||db.fdb_fak_id||db.fdb_balance_date
        from slr.slr_fak_daily_balances db
        join maxbal m on db.fdb_fak_id = m.fdb_fak_id and db.fdb_balance_type= m.fdb_balance_type 
        and db.fdb_balance_date = m.mdate)
group by FDB_BALANCE_TYPE,fdb_entity



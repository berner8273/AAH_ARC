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


SELECT FDB_BALANCE_TYPE,count(*)
--sum(FDB_TRAN_LTD_BALANCE), sum(FDB_BASE_LTD_BALANCE), sum(FDB_LOCAL_LTD_BALANCE) 
FROM SLR.SLR_FAK_DAILY_BALANCES
WHERE FDB_BALANCE_TYPE in (20,50)
    and FDB_BALANCE_TYPE||fdb_fak_id||fdb_balance_date in (
with maxbal
as (
    select fdb_fak_id,FDB_BALANCE_TYPE,max(fdb_balance_date) mdate from slr.slr_fak_daily_balances
    group by fdb_fak_id,FDB_BALANCE_TYPE)
    select db.FDB_BALANCE_TYPE||db.fdb_fak_id||db.fdb_balance_date
        from slr.slr_fak_daily_balances db
        join maxbal m on db.fdb_fak_id = m.fdb_fak_id and db.fdb_balance_date = m.mdate
        join fdr.fr_global_parameter gp on gp.lpg_id = 2
        join fdr.fr_archive_ctl arc on arc.arct_id = 254
        where m.mdate < (gp.gp_todays_bus_date - arc.arct_archive_days )
        and db.fdb_balance_type = m.fdb_balance_type
        AND db.fdb_balance_type in (20,50))
group by FDB_BALANCE_TYPE
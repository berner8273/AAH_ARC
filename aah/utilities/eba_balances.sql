-- By balance date

select edb_balance_date,EDB_BALANCE_TYPE,edb_entity,sum(edb_tran_ltd_balance),sum(edb_base_ltd_balance),sum(edb_local_ltd_balance) from slr.slr_eba_daily_balances 
where EDB_BALANCE_TYPE||EDB_FAK_ID||EDB_EBA_ID||edb_balance_date in (   
with maxbal
as (
    select EDB_BALANCE_TYPE,EDB_FAK_ID,EDB_EBA_ID,max(edb_balance_date) mdate from slr.slr_eba_daily_balances  
    group by EDB_BALANCE_TYPE,EDB_FAK_ID,EDB_EBA_ID)
    select db.EDB_BALANCE_TYPE||db.EDB_FAK_ID||db.EDB_EBA_ID||db.edb_balance_date 
        from slr.slr_eba_daily_balances db
        join maxbal m on db.EDB_FAK_ID = m.EDB_FAK_ID and db.edb_balance_date = m.mdate
                and db.EDB_BALANCE_TYPE = m.EDB_BALANCE_TYPE and db.EDB_EBA_ID = m.EDB_EBA_ID  )
group by edb_balance_date,EDB_BALANCE_TYPE,edb_entity 
order by edb_balance_date,EDB_BALANCE_TYPE

-- By entity

select EDB_BALANCE_TYPE,edb_entity,sum(edb_tran_ltd_balance),sum(edb_base_ltd_balance),sum(edb_local_ltd_balance) from slr.slr_eba_daily_balances 
where EDB_BALANCE_TYPE||EDB_FAK_ID||EDB_EBA_ID||edb_balance_date in (   
with maxbal
as (
    select EDB_BALANCE_TYPE,EDB_FAK_ID,EDB_EBA_ID,max(edb_balance_date) mdate from slr.slr_eba_daily_balances  
    group by EDB_BALANCE_TYPE,EDB_FAK_ID,EDB_EBA_ID)
    select db.EDB_BALANCE_TYPE||db.EDB_FAK_ID||db.EDB_EBA_ID||db.edb_balance_date 
        from slr.slr_eba_daily_balances db
        join maxbal m on db.EDB_FAK_ID = m.EDB_FAK_ID and db.edb_balance_date = m.mdate
              and db.EDB_BALANCE_TYPE = m.EDB_BALANCE_TYPE and db.EDB_EBA_ID = m.EDB_EBA_ID  )
group by EDB_BALANCE_TYPE,edb_entity 
order by EDB_BALANCE_TYPE


--SELECT EDB_BALANCE_TYPE,count(*)
select EDB_BALANCE_TYPE,sum(EDB_TRAN_LTD_BALANCE), sum(EDB_BASE_LTD_BALANCE), sum(EDB_LOCAL_LTD_BALANCE)
FROM SLR.SLR_EBA_DAILY_BALANCES
WHERE EDB_BALANCE_TYPE in (20,50)
 AND EDB_BALANCE_TYPE||EDB_FAK_ID||EDB_EBA_ID||EDB_BALANCE_DATE in (
with maxbal
as (
    select EDB_FAK_ID,EDB_EBA_ID,EDB_BALANCE_TYPE,max(edb_balance_date) mdate from slr.slr_eba_daily_balances
    group by EDB_FAK_ID,EDB_EBA_ID,EDB_BALANCE_TYPE)
    select db.EDB_BALANCE_TYPE||db.EDB_FAK_ID||db.EDB_EBA_ID||db.edb_balance_date
        from slr.slr_eba_daily_balances db
        join maxbal m on db.EDB_FAK_ID = m.EDB_FAK_ID and db.edb_balance_date = m.mdate
                and db.EDB_EBA_ID = m.EDB_EBA_ID
        join fdr.fr_global_parameter gp on gp.lpg_id = 2
        join fdr.fr_archive_ctl arc on arc.arct_id = 255
        where m.mdate < (gp.gp_todays_bus_date - arc.arct_archive_days )
        and db.edb_balance_type = m.edb_balance_type
        AND db.edb_balance_type in (20,50))
group by EDB_BALANCE_TYPE        

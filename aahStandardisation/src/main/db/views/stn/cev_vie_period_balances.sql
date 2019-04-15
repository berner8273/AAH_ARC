create or replace view stn.cev_vie_period_balances as
select 
    sum (transaction_balance) transaction_balance,
    sum (reporting_balance) reporting_balance,
    sum (functional_balance) functional_balance,
    stream_id,
    tax_jurisdiction,
    business_unit,
    sub_account,
    currency,
    basis_cd,
    balance_date end_of_period
from (
        with edb_bal as (
            select
                sedb.edb_eba_id,
                sedb.edb_fak_id,
                sedb.edb_balance_date balance_date,
                sec.ec_attribute_1 stream_id,
                sec.ec_attribute_2 tax_jurisdiction,
                sfc.fc_entity business_unit,
                sfc.fc_account sub_account,
                sfc.fc_ccy currency,
                sedb.edb_tran_ltd_balance transaction_balance,
                sedb.edb_base_ltd_balance reporting_balance,
                sedb.edb_local_ltd_balance functional_balance
            from slr.slr_eba_daily_balances sedb
                join slr.slr_fak_combinations sfc
                    on sedb.edb_fak_id = sfc.fc_fak_id
                join slr.slr_eba_combinations sec
                    on sedb.edb_eba_id = sec.ec_eba_id
            where 
                sfc.fc_segment_2 in ('US_STAT', 'US_GAAP')
                    and sfc.fc_segment_7 in ('D','A'))
        , edb_dt as (
            select distinct balance_date 
            from edb_bal)
        , eom_dt as (
            select 
                last_day(add_months((select min(balance_date) from edb_dt), level-1 )) dt,
                1 is_eom
            from dual
            connect by level <= months_between((select max(balance_date) from edb_dt),(select min(balance_date) from edb_dt))+1)
        , no_eom_dt as (
            select 
                balance_date dt,
                0 is_eom
            from eom_dt 
                right outer join edb_dt 
                    on edb_dt.balance_date = eom_dt.dt
            where eom_dt.dt is null)
        , m_periods as (
            select dt,is_eom 
            from eom_dt 
                union all 
            select dt, is_eom 
            from no_eom_dt )   
        select  
            edb_eba_id,
            dt balance_date,
            is_eom,
            'US_GAAP' basis_cd,
            last_value (stream_id ignore NULLS) over (partition by edb_eba_id order by dt) stream_id,
            last_value (tax_jurisdiction ignore NULLS) over (partition by edb_eba_id order by dt) tax_jurisdiction,
            last_value (business_unit ignore NULLS) over (partition by edb_eba_id order by dt) business_unit,
            last_value (sub_account ignore NULLS) over (partition by edb_eba_id order by dt) sub_account,
            last_value (currency ignore NULLS) over (partition by edb_eba_id order by dt) currency,
            last_value (reporting_balance ignore NULLS) over (partition by edb_eba_id order by dt) reporting_balance,
            last_value (transaction_balance ignore NULLS) over (partition by edb_eba_id order by dt) transaction_balance,
            last_value (functional_balance ignore NULLS) over (partition by edb_eba_id order by dt) functional_balance
        from (select 
                edb_eba_id, 
                mp.dt,
                mp.is_eom,
                reporting_balance,
                transaction_balance,
                functional_balance,
                stream_id, 
                tax_jurisdiction,
                business_unit, 
                sub_account, 
                currency
              from edb_bal partition by (edb_eba_id) 
              right outer join m_periods mp 
                on mp.dt = edb_bal.balance_date)) 
where 
    stream_id is not null
        and is_eom=1
group by 
    stream_id,
    tax_jurisdiction,
    business_unit,
    sub_account,
    currency,
    basis_cd,
    balance_date;
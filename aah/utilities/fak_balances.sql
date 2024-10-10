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

SELECT fdb_balance_type,count(*) count
    from slr.slr_fak_daily_balances db
where FDB_BALANCE_TYPE in (20,50) and db.FDB_BALANCE_TYPE||db.fdb_fak_id||db.fdb_balance_date 
IN (WITH maxbal
                                                                          AS (  SELECT fdb_fak_id,
                                                                                       FDB_BALANCE_TYPE,
                                                                                       MAX (
                                                                                          fdb_balance_date)
                                                                                          mdate
                                                                                  FROM slr.slr_fak_daily_balances ,fdr.fr_global_parameter g
                                                                    WHERE g.lpg_id = 2 and fdb_balance_date <= (g.gp_todays_bus_date - 390) + 1
                                                                              GROUP BY fdb_fak_id,
                                                                                       FDB_BALANCE_TYPE)
                                                                     SELECT    db.FDB_BALANCE_TYPE
                                                                            || db.fdb_fak_id
                                                                            || db.fdb_balance_date
                                                                       FROM slr.slr_fak_daily_balances db
                                                                            JOIN
                                                                            maxbal m
                                                                               ON     db.fdb_fak_id =
                                                                                         m.fdb_fak_id
                                                                                  AND db.fdb_balance_date =
                                                                                         m.mdate
                                                                            JOIN
                                                                            fdr.fr_global_parameter gp
                                                                               ON gp.lpg_id =
                                                                                     2
                                                                            JOIN
                                                                            fdr.fr_archive_ctl arc
                                                                               ON arc.arct_id =
                                                                                     254
                                                                      WHERE     m.mdate <=
                                                                                   (  gp.gp_todays_bus_date
                                                                                    - arc.arct_archive_days)
                                                                            AND db.fdb_balance_type =
                                                                                   m.fdb_balance_type
                                                                            AND db.fdb_balance_date <> (gp.gp_todays_bus_date- arc.arct_archive_days) + 1
                                                                            AND db.fdb_balance_type in (20,50)) group by fdb_balance_type



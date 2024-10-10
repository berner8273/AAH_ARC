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


SELECT EDB_BALANCE_TYPE,count(*) count
 FROM SLR.SLR_EBA_DAILY_BALANCES
 WHERE EDB_BALANCE_TYPE in (20,50)
    and  EDB_BALANCE_TYPE
              || EDB_FAK_ID
              || EDB_EBA_ID
              || EDB_BALANCE_DATE IN (WITH maxbal
                                           AS (  SELECT EDB_FAK_ID,
                                                        EDB_EBA_ID,
                                                        EDB_BALANCE_TYPE,
                                                        MAX (edb_balance_date)
                                                           mdate
                                                   FROM slr.slr_eba_daily_balances,fdr.fr_global_parameter g
                                                  WHERE g.lpg_id = 2 and edb_balance_date <= (g.gp_todays_bus_date - 390) + 1
                                               GROUP BY EDB_FAK_ID,
                                                        EDB_EBA_ID,
                                                        EDB_BALANCE_TYPE)
                                      SELECT    db.EDB_BALANCE_TYPE
                                             || db.EDB_FAK_ID
                                             || db.EDB_EBA_ID
                                             || db.edb_balance_date
                                        FROM slr.slr_eba_daily_balances db
                                             JOIN maxbal m
                                                ON     db.EDB_FAK_ID =
                                                          m.EDB_FAK_ID
                                                   AND db.edb_balance_date =
                                                          m.mdate
                                                   AND db.EDB_EBA_ID =
                                                          m.EDB_EBA_ID
                                             JOIN fdr.fr_global_parameter gp
                                                ON gp.lpg_id = 2
                                             JOIN fdr.fr_archive_ctl arc
                                                ON arc.arct_id = 255
                                       WHERE     m.mdate <=
                                                    (  gp.gp_todays_bus_date
                                                     - arc.arct_archive_days)
                                             AND db.edb_balance_date <>  (gp.gp_todays_bus_date- arc.arct_archive_days) + 1
                                             AND db.edb_balance_type =
                                                    m.edb_balance_type
                                             AND db.edb_balance_type in (20,50)) group by EDB_BALANCE_TYPE

SELECT (g.gp_todays_bus_date - a.arct_archive_days) + 1
  FROM fdr.fr_global_parameter g
       JOIN fdr.fr_archive_ctl a ON a.arct_id = 255
 WHERE g.lpg_id = 2

--select count(*) from STN.merger_balances
-- note table does not need to recalc stats that is done with index

-- merger_ddl.sql must be run before this 

--truncate table stn.merger_balances

--create table stn.merger_balances as
begin

insert into stn.merger_balances
select    eab_fak_id,
          eab_eba_id,
          eab_balance_date,
          eab_balance_type,
          eab_tran_daily_movement,
          eab_tran_mtd_balance,
          eab_tran_ytd_balance,
          eab_tran_ltd_balance,
          eab_base_daily_movement,
          eab_base_mtd_balance,
          eab_base_ytd_balance,
          eab_base_ltd_balance,
          eab_local_daily_movement,
          eab_local_mtd_balance,
          eab_local_ytd_balance,
          eab_local_ltd_balance,
          eab_entity,
          eab_epg_id,
          eab_period_month,
          eab_period_year,
          eab_period_ltd
     from (select eab_fak_id,
                  eab_eba_id,
                  eab_balance_date,
                  eab_balance_type,
                  eab_tran_daily_movement,
                  eab_tran_mtd_balance,
                  eab_tran_ytd_balance,
                  eab_tran_ltd_balance,
                  eab_base_daily_movement,
                  eab_base_mtd_balance,
                  eab_base_ytd_balance,
                  eab_base_ltd_balance,
                  eab_local_daily_movement,
                  eab_local_mtd_balance,
                  eab_local_ytd_balance,
                  eab_local_ltd_balance,
                  eab_entity,
                  eab_epg_id,
                  eab_period_month,
                  eab_period_year,
                  eab_period_ltd,
                  row_number ()
                  over (partition by eab_eba_id, eab_balance_type  order by eab_balance_date desc)   rn
             from (

                     select
                          edb_fak_id as eab_fak_id,
                          edb_eba_id as eab_eba_id,
                          edb_balance_date as eab_balance_date,
                          edb_balance_type as eab_balance_type,
                          edb_tran_daily_movement as eab_tran_daily_movement,
                          edb_tran_mtd_balance as eab_tran_mtd_balance,
                          edb_tran_ytd_balance as eab_tran_ytd_balance,
                          edb_tran_ltd_balance as eab_tran_ltd_balance,
                          edb_base_daily_movement as eab_base_daily_movement,
                          edb_base_mtd_balance as eab_base_mtd_balance,
                          edb_base_ytd_balance as eab_base_ytd_balance,
                          edb_base_ltd_balance as eab_base_ltd_balance,
                          edb_local_daily_movement  as eab_local_daily_movement,
                          edb_local_mtd_balance as eab_local_mtd_balance,
                          edb_local_ytd_balance as eab_local_ytd_balance,
                          edb_local_ltd_balance as eab_local_ltd_balance,
                          edb_entity as eab_entity,
                          edb_epg_id as eab_epg_id,
                          edb_period_month as eab_period_month,
                          edb_period_year as eab_period_year,
                          edb_period_ltd as eab_period_ltd
                      from 
                        slr.slr_eba_daily_balances b, 
                        slr.slr_fak_combinations fc,
                        fdr.fr_gl_account gla
                    where 
                        b.edb_fak_id = fc.fc_fak_id and  
                        fc.fc_account = gla.ga_account_code and     
                        edb_balance_date <='31-aug-24' and 
                        edb_balance_type = 50 and
                        ga_account_Type = 'B' and
                        (fc_entity = 'FSANY' or fc_segment_4 = 'FSANY') and
                        --fc_attribute_1 = 'NVS'
                        substr(ga_account_code,1,1) in ('1','2') 
              ))
where rn = 1;

commit;

DBMS_STATS.GATHER_TABLE_STATS ('STN','MERGER_BALANCES');

end;
/
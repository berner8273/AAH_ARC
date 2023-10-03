create or replace force view slr.vbm_ag_retainedearningseba04
(
   key_id,
   fak_id,
   balance_type,
   entity,
   balance_date,
   epg_id,
   tran_ltd_balance,
   base_ltd_balance,
   local_ltd_balance,
   tran_ytd_balance,
   base_ytd_balance,
   local_ytd_balance,
   tran_mtd_balance,
   base_mtd_balance,
   local_mtd_balance,
   period_month,
   period_year,
   period_ltd
)
   bequeath definer
as
   select /*+ parallel(slr_eba_daily_balances )*/
         edb_eba_id as key_id,
          edb_fak_id as fak_id,
          edb_balance_type as balance_type,
          edb_entity as entity,
          edb_balance_date as balance_date,
          edb_epg_id as epg_id,
          edb_tran_ltd_balance as tran_ltd_balance,
          edb_base_ltd_balance as base_ltd_balance,
          edb_local_ltd_balance as local_ltd_balance,
          edb_tran_ytd_balance as tran_ytd_balance,
          edb_base_ytd_balance as base_ytd_balance,
          edb_local_ytd_balance as local_ytd_balance,
          edb_tran_mtd_balance as tran_mtd_balance,
          edb_base_mtd_balance as base_mtd_balance,
          edb_local_mtd_balance as local_mtd_balance,
          edb_period_month as period_month,
          edb_period_year as period_year,
          edb_period_ltd as period_ltd
     from slr_eba_daily_balances edb
          inner join slr_fak_combinations fc
             on (    edb.edb_epg_id = fc.fc_epg_id
                 and edb.edb_fak_id = fc.fc_fak_id)
          inner join slr_entities ent on (edb.edb_entity = ent.ent_entity)
          inner join slr_entity_accounts ea
             on (    ea.ea_entity_set = ent.ent_accounts_set
                 and ea.ea_account = fc.fc_account)
    where     ea.ea_account_type_flag = 'p'
          and edb.edb_balance_type = 50
          and ea_account like '31580017%';

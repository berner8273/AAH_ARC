create or replace view slr.vbmfxreval_eba_ag_r2_usgaap ("KEY_ID", "FAK_ID", "BALANCE_TYPE", "ENTITY", "BALANCE_DATE", "EPG_ID", "TRAN_LTD_BALANCE", "BASE_LTD_BALANCE", "LOCAL_LTD_BALANCE", "TRAN_YTD_BALANCE", "BASE_YTD_BALANCE", "LOCAL_YTD_BALANCE", "TRAN_MTD_BALANCE", "BASE_MTD_BALANCE", "LOCAL_MTD_BALANCE", "PERIOD_MONTH", "PERIOD_YEAR", "PERIOD_LTD") as 
select
/*+ PARALLEL(SLR_EBA_DAILY_BALANCES )*/
edb_eba_id            as key_id,
edb_fak_id            as fak_id,
edb_balance_type      as balance_type,
edb_entity            as entity ,
edb_balance_date      as balance_date,
edb_epg_id            as epg_id ,
edb_tran_ltd_balance  as tran_ltd_balance,
edb_base_ltd_balance  as base_ltd_balance,
edb_local_ltd_balance as local_ltd_balance ,
edb_tran_ytd_balance  as tran_ytd_balance,
edb_base_ytd_balance  as base_ytd_balance,
edb_local_ytd_balance as local_ytd_balance ,
edb_tran_mtd_balance  as tran_mtd_balance,
edb_base_mtd_balance  as base_mtd_balance,
edb_local_mtd_balance as local_mtd_balance ,
edb_period_month      as period_month,
edb_period_year       as period_year,
edb_period_ltd        as period_ltd
from slr_eba_daily_balances
inner join slr_eba_combinations ec
on (edb_eba_id = ec_eba_id
and edb_fak_id = ec_fak_id)
inner join slr_fak_combinations fc
on (edb_epg_id = fc_epg_id
and edb_fak_id = fc_fak_id)
inner join slr_entities
on (edb_entity = ent_entity)
inner join slr_entity_accounts ea
on ( ent_accounts_set   = ea_entity_set
and fc_account          = ea_account)
inner join fdr.fr_general_lookup fgl 
on (fc.fc_segment_1 = fgl.lk_lookup_value2
and fgl.lk_lkt_lookup_type_code = 'ACCOUNTING_BASIS_LEDGER'
and fgl.lk_lookup_value1 = 'US_GAAP')
inner join slr.v_slr_fxreval_rule2_events r2
on ( fc.fc_segment_6   = r2.execution_type
 and fc.fc_segment_7   = r2.business_type
 and ec.ec_attribute_3 = r2.premium_type
 and (ec.ec_attribute_4 = r2.source_event or ec.ec_attribute_4 = r2.fx_event_type))
inner join stn.event_hierarchy_reference event_hier
on (ec.ec_attribute_4 = event_hier.event_typ)
inner join slr.v_slr_fxreval_run_values runval
on (event_hier.event_class = runval.event_class) 
where 
edb_balance_type  = 50;

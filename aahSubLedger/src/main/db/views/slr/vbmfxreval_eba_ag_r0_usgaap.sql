create or replace view slr.vbmfxreval_eba_ag_r0_usgaap as
with
rule0_accounts as
(
select
       fgl.lk_match_key1       accounting_basis
     , fgl.lk_match_key7       source_account
     , fgl.lk_match_key3       execution_type
     , fgl.lk_match_key4       premium_type
     , fgl.lk_match_key5       business_type
     , fgl.lk_match_key6       event_class
     , fgl.lk_match_key10      offset_adjust
     , fgl.lk_lookup_value1    fx_event_type
     , fgl.lk_lookup_value2    fx_account
     , fgl.lk_lookup_value3    fx_ledger
  from
       fdr.fr_general_lookup fgl
 where
       fgl.lk_lkt_lookup_type_code = 'FXREVAL_GL_MAPPINGS'
   and fgl.lk_match_key9           = 'FXRULE0'
   and fgl.lk_match_key1           = 'US_GAAP'
)
, population as
(
select
       ec.ec_eba_id
     , ec.ec_fak_id
     , ec.ec_epg_id
  from
       slr.slr_eba_combinations      ec
  join slr.slr_fak_combinations      fc     on ec.ec_epg_id              = fc.fc_epg_id
                                           and ec.ec_fak_id              = fc.fc_fak_id
  join fdr.fr_general_lookup         fgl    on fc.fc_segment_1           = fgl.lk_lookup_value2
                                           and 'ACCOUNTING_BASIS_LEDGER' = fgl.lk_lkt_lookup_type_code
                                           and 'US_GAAP'                 = fgl.lk_lookup_value1
  join stn.event_hierarchy_reference eh     on ec.ec_attribute_4         = eh.event_typ
 where exists ( select null
                  from slr.v_slr_fxreval_parameters  fxparam
                 where eh.event_class    = fxparam.event_class )
   and exists ( select null
                  from rule0_accounts r0
                 where fc.fc_account     = r0.source_account
                   and fc.fc_segment_6   = r0.execution_type
                   and fc.fc_segment_7   = r0.business_type
                   and ec.ec_attribute_3 = r0.premium_type )
)
, fx_population as
(
select
       ec.ec_eba_id
     , ec.ec_fak_id
     , ec.ec_epg_id
  from
       slr.slr_eba_combinations      ec
  join slr.slr_fak_combinations      fc     on (    ec.ec_epg_id = fc.fc_epg_id
                                                and ec.ec_fak_id = fc.fc_fak_id )
  join fdr.fr_general_lookup         fgl    on (    fc.fc_segment_1           = fgl.lk_lookup_value2
                                                and 'ACCOUNTING_BASIS_LEDGER' = fgl.lk_lkt_lookup_type_code
                                                and 'US_GAAP'                 = fgl.lk_lookup_value1 )
  join stn.event_hierarchy_reference eh     on      ec.ec_attribute_4 = eh.event_typ
 where exists ( select null
                  from slr.v_slr_fxreval_parameters  fxparam
                 where eh.event_class    = fxparam.event_class )
   and exists ( select null
                  from rule0_accounts r0
                 where fc.fc_segment_6       = r0.execution_type
                   and fc.fc_segment_7       = r0.business_type
                   and ec.ec_attribute_3     = r0.premium_type
                   and ec.ec_attribute_4     = r0.fx_event_type
                   and fc.fc_account         = r0.fx_account )
)
, fx_fak_eba as
(
select distinct
       ec_fx.ec_eba_id              eba_id_fx
     , fc_fx.fc_fak_id              fak_id_fx
     , ec_orig.ec_eba_id            eba_id_orig
     , fc_orig.fc_fak_id            fak_id_orig
     , ec_orig.ec_epg_id            epg_id
  from
       slr.slr_eba_combinations     ec_orig
  join slr.slr_fak_combinations     fc_orig   on   ec_orig.ec_fak_id      = fc_orig.fc_fak_id
                                             and   ec_orig.ec_epg_id      = fc_orig.fc_epg_id
  join rule0_accounts               r0        on   fc_orig.fc_account     = r0.source_account
                                             and   fc_orig.fc_segment_2   = r0.accounting_basis
                                             and   'Adjust'               = r0.offset_adjust
  join slr.slr_fak_combinations     fc_fx     on   r0.fx_account          = fc_fx.fc_account
                                             and   r0.fx_ledger           = fc_fx.fc_segment_1
                                             and   fc_orig.fc_segment_2   = fc_fx.fc_segment_2
                                             and   fc_orig.fc_segment_3   = fc_fx.fc_segment_3
                                             and   fc_orig.fc_segment_4   = fc_fx.fc_segment_4
                                             and   fc_orig.fc_segment_5   = fc_fx.fc_segment_5
                                             and   fc_orig.fc_segment_6   = fc_fx.fc_segment_6
                                             and   fc_orig.fc_segment_7   = fc_fx.fc_segment_7
                                             and   fc_orig.fc_segment_8   = fc_fx.fc_segment_8
  join slr.slr_eba_combinations     ec_fx     on   fc_fx.fc_fak_id        = ec_fx.ec_fak_id
                                             and   fc_fx.fc_epg_id        = ec_fx.ec_epg_id
                                             and   ec_orig.ec_epg_id      = ec_fx.ec_epg_id
                                             and   ec_orig.ec_attribute_1 = ec_fx.ec_attribute_1
                                             and   ec_orig.ec_attribute_2 = ec_fx.ec_attribute_2
                                             and   ec_orig.ec_attribute_3 = ec_fx.ec_attribute_3
                                             and   r0.fx_event_type       = ec_fx.ec_attribute_4
 where exists ( select
                       null
                  from
                       population pop
                 where
                       ec_orig.ec_eba_id = pop.ec_eba_id
                  and  ec_orig.ec_fak_id = pop.ec_fak_id
                  and  ec_orig.ec_epg_id = pop.ec_epg_id )
)
, balances as
(
select /*+ parallel( edb )*/
       edb.edb_eba_id               key_id
     , edb.edb_fak_id               fak_id
     , edb.edb_balance_type         balance_type
     , edb.edb_entity               entity
     , add_months(edb.edb_balance_date,1)         balance_date
     , edb.edb_epg_id               epg_id
     , edb.edb_tran_ltd_balance     tran_ltd_balance
     , edb.edb_base_ltd_balance     base_ltd_balance
     , edb.edb_local_ltd_balance    local_ltd_balance
     , edb.edb_tran_ytd_balance     tran_ytd_balance
     , edb.edb_base_ytd_balance     base_ytd_balance
     , edb.edb_local_ytd_balance    local_ytd_balance
     , edb.edb_tran_mtd_balance     tran_mtd_balance
     , edb.edb_base_mtd_balance     base_mtd_balance
     , edb.edb_local_mtd_balance    local_mtd_balance
     , extract(month from add_months(edb.edb_balance_date,1))         period_month
     , extract(year from add_months(edb.edb_balance_date,1))          period_year
     , case
            when edb.edb_period_ltd = 1 then 1
            else extract(year from add_months(edb.edb_balance_date,1))
       end                                                            period_ltd
  from
       slr_eba_daily_balances edb
  join population             pop  on pop.ec_eba_id = edb.edb_eba_id
                                  and pop.ec_fak_id = edb.edb_fak_id
                                  and pop.ec_epg_id = edb.edb_epg_id
 where
       edb_balance_type  = 50
union all
select /*+ parallel( edb )*/
       fx_fak_eba.eba_id_orig       key_id
     , fx_fak_eba.fak_id_orig       fak_id
     , edb.edb_balance_type         balance_type
     , edb.edb_entity               entity
     , edb.edb_balance_date         balance_date
     , edb.edb_epg_id               epg_id
     , edb.edb_tran_ltd_balance     tran_ltd_balance
     , edb.edb_base_ltd_balance     base_ltd_balance
     , edb.edb_local_ltd_balance    local_ltd_balance
     , edb.edb_tran_ytd_balance     tran_ytd_balance
     , edb.edb_base_ytd_balance     base_ytd_balance
     , edb.edb_local_ytd_balance    local_ytd_balance
     , edb.edb_tran_mtd_balance     tran_mtd_balance
     , edb.edb_base_mtd_balance     base_mtd_balance
     , edb.edb_local_mtd_balance    local_mtd_balance
     , edb.edb_period_month         period_month
     , edb.edb_period_year          period_year
     , edb.edb_period_ltd           period_ltd
  from
       slr.slr_eba_daily_balances edb
  join fx_population              fx_pop   on fx_pop.ec_eba_id = edb.edb_eba_id
                                          and fx_pop.ec_fak_id = edb.edb_fak_id
                                          and fx_pop.ec_epg_id = edb.edb_epg_id
  join fx_fak_eba                          on fx_pop.ec_eba_id = fx_fak_eba.eba_id_fx
                                          and fx_pop.ec_fak_id = fx_fak_eba.fak_id_fx
                                          and fx_pop.ec_epg_id = fx_fak_eba.epg_id
 where
       edb.edb_balance_type = 50
)
select
       key_id
     , fak_id
     , balance_type
     , entity
     , balance_date
     , epg_id
     , sum(tran_ltd_balance)    tran_ltd_balance
     , sum(base_ltd_balance)    base_ltd_balance
     , sum(local_ltd_balance)   local_ltd_balance
     , sum(tran_ytd_balance)    tran_ytd_balance
     , sum(base_ytd_balance)    base_ytd_balance
     , sum(local_ytd_balance)   local_ytd_balance
     , sum(tran_mtd_balance)    tran_mtd_balance
     , sum(base_mtd_balance)    base_mtd_balance
     , sum(local_mtd_balance)   local_mtd_balance
     , period_month
     , period_year
     , period_ltd
  from
       balances
 group by
       key_id
     , fak_id
     , balance_type
     , entity
     , balance_date
     , epg_id
     , period_month
     , period_year
     , period_ltd
;
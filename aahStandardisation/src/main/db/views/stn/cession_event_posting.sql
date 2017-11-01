create or replace view stn.cession_event_posting
as
with
     ce_data
  as (
  select
                   ipr.policy_id
                 , ipr.stream_id
                 , vie.vie_id
                 , vie.vie_cd
                 , ipr.le_cd
                 , ipr.is_mark_to_market
                 , ipr.policy_premium_typ
                 , ipr.policy_accident_yr
                 , ipr.policy_underwriting_yr
                 , ipr.policy_typ
                 , ipr.parent_stream_id
                 , pipr.le_cd              parent_cession_le_cd
                 , ipr.ultimate_parent_stream_id
                 , ipr.execution_typ
              from
                        stn.insurance_policy_reference  ipr
                   join stn.vie_event_cd                vec on ipr.stream_id = vec.stream_id
                   join stn.vie_code                    vie on vec.vie_cd = vie.vie_cd
              left join stn.insurance_policy_reference  pipr on ipr.parent_stream_id = pipr.stream_id
     )
   , cev_data
  as (
         select
                business_type_association_id
              , intercompany_association_id
              , correlation_uuid
              , row_sid
              , basis_id                                                                                                   input_basis_id
              , basis_cd                                                                                                   input_basis_cd
              , coalesce ( lag  ( basis_cd ) over ( partition by business_type_association_id order by basis_cd )
                         , lead ( basis_cd ) over ( partition by business_type_association_id order by basis_cd ) )        partner_basis_cd
              , accounting_dt
              , event_typ
              , event_typ_id
              , policy_id
              , stream_id
              , parent_stream_id
              , vie_id
              , vie_cd
              , is_mark_to_market
              , premium_typ
              , policy_premium_typ
              , policy_accident_yr
              , policy_underwriting_yr
              , ultimate_parent_stream_id
              , execution_typ
              , policy_typ
              , business_typ
              , generate_interco_accounting
              , business_unit
              , affiliate
              , transaction_amt                                                                                            input_transaction_amt
              , coalesce ( lag  ( transaction_amt ) over ( partition by business_type_association_id order by basis_cd )
                         , lead ( transaction_amt ) over ( partition by business_type_association_id order by basis_cd ) ) partner_transaction_amt
              , transaction_ccy
              , functional_amt                                                                                             input_functional_amt
              , coalesce ( lag  ( functional_amt ) over ( partition by business_type_association_id order by basis_cd )
                         , lead ( functional_amt ) over ( partition by business_type_association_id order by basis_cd ) )  partner_functional_amt
              , functional_ccy
              , reporting_amt                                                                                              input_reporting_amt
              , coalesce ( lag  ( reporting_amt ) over ( partition by business_type_association_id order by basis_cd )
                         , lead ( reporting_amt ) over ( partition by business_type_association_id order by basis_cd ) )   partner_reporting_amt
              , reporting_ccy
              , lpg_id
           from (
                    select
                           rank () over ( order by
                                                   cev.feed_uuid
                                                 , cev.correlation_uuid
                                                 , cev.accounting_dt
                                                 , cev.event_id
                                                 , cev.stream_id
                                                 , cev.event_typ
                                                 , cev.business_typ )          business_type_association_id
                         , rank () over ( order by
                                                   cev.feed_uuid
                                                 , cev.correlation_uuid
                                                 , cev.accounting_dt
                                                 , cev.event_id
                                                 , cev.stream_id
                                                 , cev.event_typ )             intercompany_association_id
                         , cev.correlation_uuid
                         , cev.row_sid
                         , cev.basis_cd
                         , abasis.basis_id
                         , cev.accounting_dt
                         , case
                               when cev.event_typ in ( 'UPR' , 'PGAAP_UPR' )
                               then etout.event_typ
                               else cev.event_typ
                           end event_typ
                         , case
                               when cev.event_typ in ( 'UPR' , 'PGAAP_UPR' )
                               then etout.event_typ_id
                               else et.event_typ_id
                           end event_typ_id
                         , ce_data.policy_id
                         , cev.stream_id
                         , ce_data.parent_stream_id
                         , ce_data.vie_id
                         , ce_data.vie_cd
                         , ce_data.is_mark_to_market
                         , ce_data.policy_premium_typ
                         , ce_data.policy_accident_yr
                         , ce_data.policy_underwriting_yr
                         , ce_data.ultimate_parent_stream_id
                         , ce_data.execution_typ
                         , ce_data.policy_typ
                         , cev.business_typ
                         , case
                               when cev.premium_typ = 'X'
                               then ppt.cession_event_premium_typ
                               else cev.premium_typ
                           end                                                       premium_typ --added
                         , bt.generate_interco_accounting
                         , case
                               when bt.bu_derivation_method = 'CESSION'
                               then ce_data.le_cd
                               when bt.bu_derivation_method = 'PARENT_CESSION'
                               then ce_data.parent_cession_le_cd
                               else null
                           end                                                       business_unit
                         , case
                               when bt.bu_derivation_method = 'CESSION'
                               then ce_data.parent_cession_le_cd
                               when bt.bu_derivation_method = 'PARENT_CESSION'
                               then ce_data.le_cd
                               else null
                           end                                                       affiliate
                         , cev.transaction_amt
                         , cev.transaction_ccy
                         , cev.functional_amt
                         , cev.functional_ccy
                         , cev.reporting_amt
                         , cev.reporting_ccy
                         , cev.lpg_id
                      from
                                stn.cession_event                cev
                           join stn.identified_record            idr     on cev.row_sid                = idr.row_sid
                           join                                  ce_data on cev.stream_id              = ce_data.stream_id
                           join stn.event_type                   et      on cev.event_typ              = et.event_typ
                           join stn.posting_accounting_basis     abasis  on cev.basis_cd               = abasis.basis_cd
                           join stn.business_type                bt      on cev.business_typ           = bt.business_typ
                           join stn.policy_premium_type          ppt     on ce_data.policy_premium_typ = ppt.policy_premium_typ --added
                      left join stn.posting_method_derivation_et psmdet  on et.event_typ_id            = psmdet.input_event_typ_id --added
                      left join stn.event_type                   etout   on psmdet.output_event_typ_id = etout.event_typ_id --added
                     where
                                cev.event_status = 'V'
                )
     )
   , gaap_fut_accts
  as (
         select
                cev.correlation_uuid correlation_uuid
           from
                     stn.cession_event                  cev
                join stn.event_type                     et     on cev.EVENT_TYP = et.EVENT_TYP
                join stn.posting_method_derivation_mtm  psmdm  on et.event_typ_id = psmdm.event_typ_id
                join stn.posting_method                 psm    on psmdm.psm_id = psm.psm_id
          where
                     psm.psm_cd = 'GAAP_FUT_ACCTS'
     )
   , period_detail
  as (
         select
                sedb.edb_balance_date         balance_date
              , sec.ec_attribute_1            stream_id
              , sfc.fc_entity                 business_unit
              , sfc.fc_account                sub_account
              , sfc.fc_ccy                    currency
              , sec.ec_attribute_3            premium_typ
              , sfc.fc_segment_2              basis_cd
              , sedb.edb_tran_ltd_balance     transaction_balance
              , sedb.edb_base_ltd_balance     reporting_balance
              , sedb.edb_local_ltd_balance    functional_balance
              , sedb.edb_period_month         period_month
              , sedb.edb_period_year          period_year
           from
                     slr.slr_eba_daily_balances sedb
                join slr.slr_fak_combinations   sfc   on sedb.edb_fak_id = sfc.fc_fak_id
                join slr.slr_eba_combinations   sec   on sedb.edb_eba_id = sec.ec_eba_id
          where (
                    select
                           max(sedb2.edb_balance_date) max_period_date
                      from
                                slr.slr_eba_daily_balances   sedb2
                           join slr.slr_fak_combinations     sfc2   on sedb2.edb_fak_id = sfc2.fc_fak_id
                           join slr.slr_eba_combinations     sec2   on sedb2.edb_eba_id = sec2.ec_eba_id
                     where sec2.ec_attribute_1          = sec.ec_attribute_1
                       and sfc2.fc_entity               = sfc.fc_entity
                       and sfc2.fc_account              = sfc.fc_account
                       and sfc2.fc_ccy                  = sfc.fc_ccy
                       and sec2.ec_attribute_3          = sec.ec_attribute_3
                       and sfc2.fc_segment_2            = sfc.fc_segment_2
                       and sedb2.edb_period_month       = sedb.edb_period_month
                       and sedb2.edb_period_year        = sedb.edb_period_year
                ) = sedb.edb_balance_date
    )
   , period_balances
  as (
         select
                sum(pd.transaction_balance) transaction_balance
              , sum(pd.reporting_balance)   reporting_balance
              , sum(pd.functional_balance)  functional_balance
              , stream_id
              , business_unit
              , sub_account
              , currency
              , premium_typ
              , basis_cd
              , period_month
              , period_year
           from
                period_detail pd
          group by
                stream_id
              , business_unit
              , sub_account
              , currency
              , premium_typ
              , basis_cd
              , period_month
              , period_year
    )
   , vie_data
  as (
         select
                'VIE'                             posting_type
              , cev_data.correlation_uuid
              , cev_data.row_sid
              , vc.sub_event
              , cev_data.accounting_dt
              , cev_data.policy_id
              , cev_data.stream_id
              , abasis.basis_cd
              , cev_data.business_typ
              , cev_data.premium_typ
              , cev_data.policy_premium_typ
              , cev_data.policy_accident_yr
              , cev_data.policy_underwriting_yr
              , cev_data.ultimate_parent_stream_id
              , cev_data.execution_typ
              , cev_data.policy_typ
              , et.event_typ
              , vle.vie_le_cd                     business_unit
              , null                              affiliate
              , pldgr.ledger_cd
              , cev_data.vie_cd
              , cev_data.is_mark_to_market
              , cev_data.transaction_ccy
              , cev_data.input_transaction_amt    transaction_amt
              , cev_data.functional_ccy
              , cev_data.input_functional_amt     functional_amt
              , cev_data.reporting_ccy
              , cev_data.input_reporting_amt      reporting_amt
              , cev_data.lpg_id
           from
                     cev_data
                join stn.vie_code                  vc     on cev_data.vie_id = vc.vie_id
                join stn.vie_posting_method_ledger vpml   on (
                                                                     cev_data.input_basis_id = vpml.input_basis_id
                                                                 and cev_data.event_typ_id   = vpml.event_typ_id
                                                                 and cev_data.vie_id         = vpml.vie_id
                                                             )
                join stn.posting_accounting_basis  abasis on vpml.output_basis_id  = abasis.basis_id
                join stn.event_type                et     on vpml.vie_event_typ_id = et.event_typ_id
                join stn.posting_ledger            pldgr  on vpml.ledger_id        = pldgr.ledger_id
                join stn.vie_legal_entity          vle    on (
                                                                     cev_data.business_unit = vle.le_cd
                                                                 and abasis.basis_typ       = vle.legal_entity_link_typ
                                                             )
                join (
                         select
                                step_run_sid
                           from (
                                    select
                                           srse.step_run_sid
                                         , srse.step_run_state_start_ts
                                         , max ( srse.step_run_state_start_ts ) over ( order by null ) mxts
                                      from
                                                stn.step_run_state  srse
                                           join stn.step_run_status srsu on srse.step_run_status_id = srsu.step_run_status_id
                                     where
                                           srsu.step_run_status_cd = 'S'
                                       and exists (
                                                      select
                                                             null
                                                        from
                                                             stn.vie_legal_entity vle
                                                       where
                                                             vle.step_run_sid = srse.step_run_sid
                                                  )
                                )
                          where
                                step_run_state_start_ts = mxts
                     )
                     lvd on vle.step_run_sid = lvd.step_run_sid
     )
   , mtm_data
  as (
         select
                psm.psm_cd
              , cev_data.business_type_association_id
              , cev_data.intercompany_association_id
              , cev_data.correlation_uuid
              , cev_data.row_sid
              , pml.sub_event
              , cev_data.accounting_dt
              , cev_data.policy_id
              , cev_data.stream_id
              , cev_data.parent_stream_id
              , abasis.basis_typ
              , abasis.basis_cd
              , pldgr.ledger_cd
              , cev_data.event_typ
              , cev_data.is_mark_to_market
              , cev_data.vie_cd
              , cev_data.premium_typ
              , cev_data.policy_premium_typ
              , cev_data.policy_accident_yr
              , cev_data.policy_underwriting_yr
              , cev_data.ultimate_parent_stream_id
              , cev_data.execution_typ
              , cev_data.policy_typ
              , cev_data.business_typ
              , cev_data.generate_interco_accounting
              , cev_data.business_unit
              , cev_data.affiliate
              , fincalc.fin_calc_cd
              , cev_data.transaction_ccy
              , case
                    when padt.amount_typ_descr in ( 'DERIVED' , 'DERIVED_PLUS' )
                        then cev_data.input_transaction_amt - nvl(pb.transaction_balance,0)
                    else cev_data.input_transaction_amt
                end input_transaction_amt
              , case
                    when padt.amount_typ_descr in ( 'DERIVED' , 'DERIVED_PLUS' )
                        then cev_data.partner_transaction_amt - nvl(pb.transaction_balance,0)
                    else cev_data.partner_transaction_amt
                end partner_transaction_amt
              , cev_data.functional_ccy
              , case
                    when padt.amount_typ_descr in ( 'DERIVED' , 'DERIVED_PLUS' )
                        then cev_data.input_functional_amt - nvl(pb.functional_balance,0)
                    else cev_data.input_functional_amt
                end input_functional_amt
              , case
                    when padt.amount_typ_descr in ( 'DERIVED' , 'DERIVED_PLUS' )
                        then cev_data.partner_functional_amt - nvl(pb.functional_balance,0)
                    else cev_data.partner_functional_amt
                end partner_functional_amt
              , cev_data.reporting_ccy
              , case
                    when padt.amount_typ_descr in ( 'DERIVED' , 'DERIVED_PLUS' )
                        then cev_data.input_reporting_amt - nvl(pb.reporting_balance,0)
                    else cev_data.input_reporting_amt
                end input_reporting_amt
              , case
                    when padt.amount_typ_descr in ( 'DERIVED' , 'DERIVED_PLUS' )
                        then cev_data.partner_reporting_amt - nvl(pb.reporting_balance,0)
                    else cev_data.partner_reporting_amt
                end partner_reporting_amt
              , cev_data.lpg_id
           from
                                                        cev_data
                join stn.posting_method_derivation_mtm  psmtm    on (
                                                                           cev_data.event_typ_id      = psmtm.event_typ_id
                                                                       and cev_data.is_mark_to_market = psmtm.is_mark_to_market
                                                                       and cev_data.premium_typ       = psmtm.premium_typ
                                                                   )
                join stn.posting_method_ledger          pml      on (
                                                                           psmtm.psm_id            = pml.psm_id
                                                                       and cev_data.input_basis_id = pml.input_basis_id
                                                                   )
                join stn.posting_method                 psm      on psmtm.psm_id          = psm.psm_id
                join stn.posting_ledger                 pldgr    on pml.ledger_id         = pldgr.ledger_id
                join stn.posting_accounting_basis       abasis   on pml.output_basis_id   = abasis.basis_id
                join stn.posting_financial_calc         fincalc  on pml.fin_calc_id       = fincalc.fin_calc_id
                join stn.posting_amount_derivation      pad      on cev_data.event_typ_id = pad.event_typ_id
                join stn.posting_amount_derivation_type padt     on pad.amount_typ_id     = padt.amount_typ_id
           left join stn.posting_account_derivation     pacd     on (
                                                                           pldgr.ledger_cd            = pacd.posting_schema
                                                                     and   cev_data.event_typ         = pacd.event_typ
                                                                     and   pml.sub_event              = pacd.sub_event
                                                                     and ( cev_data.business_typ      = pacd.business_typ
                                                                        or pacd.business_typ          = 'ND~' )
                                                                     and ( cev_data.is_mark_to_market = pacd.is_mark_to_market
                                                                        or pacd.is_mark_to_market     = 'ND~' )
                                                                     and ( cev_data.business_unit     = pacd.business_unit
                                                                        or pacd.business_unit         = 'ND~' )
                                                                     and cev_data.transaction_ccy     = pacd.currency
                                                                    )
           left join period_balances                    pb       on (
                                                                           cev_data.stream_id                           = pb.stream_id
                                                                       and cev_data.business_unit                       = pb.business_unit
                                                                       and pacd.sub_account                             = pb.sub_account
                                                                       and cev_data.transaction_ccy                     = pb.currency
                                                                       and cev_data.premium_typ                         = pb.premium_typ
                                                                       and abasis.basis_cd                              = pb.basis_cd
                                                                       and extract( month from cev_data.accounting_dt ) = pb.period_month
                                                                       and extract( year from cev_data.accounting_dt )  = pb.period_year
                                                                    )
          where
                not exists (
                               select
                                      null
                                 from
                                      stn.posting_method_derivation_le pdml
                                where
                                      pdml.le_cd = cev_data.business_unit
                           )
            and cev_data.correlation_uuid not in (select correlation_uuid from gaap_fut_accts)
     )
   , le_data
  as (
         select
                psm.psm_cd
              , cev_data.business_type_association_id
              , cev_data.intercompany_association_id
              , cev_data.correlation_uuid
              , cev_data.row_sid
              , pml.sub_event
              , cev_data.accounting_dt
              , cev_data.policy_id
              , cev_data.stream_id
              , cev_data.parent_stream_id
              , abasis.basis_typ
              , abasis.basis_cd
              , pldgr.ledger_cd
              , cev_data.event_typ
              , cev_data.is_mark_to_market
              , cev_data.vie_cd
              , cev_data.premium_typ
              , cev_data.policy_premium_typ
              , cev_data.policy_accident_yr
              , cev_data.policy_underwriting_yr
              , cev_data.ultimate_parent_stream_id
              , cev_data.execution_typ
              , cev_data.policy_typ
              , cev_data.business_typ
              , cev_data.generate_interco_accounting
              , cev_data.business_unit
              , cev_data.affiliate
              , fincalc.fin_calc_cd
              , cev_data.transaction_ccy
              , cev_data.input_transaction_amt
              , cev_data.partner_transaction_amt
              , cev_data.functional_ccy
              , cev_data.input_functional_amt
              , cev_data.partner_functional_amt
              , cev_data.reporting_ccy
              , cev_data.input_reporting_amt
              , cev_data.partner_reporting_amt
              , cev_data.lpg_id
           from
                                                      cev_data
                join stn.posting_method_derivation_le psml      on cev_data.business_unit = psml.le_cd
                join stn.posting_method_ledger        pml       on (
                                                                           psml.psm_id             = pml.psm_id
                                                                       and cev_data.input_basis_id = pml.input_basis_id
                                                                   )
                join stn.posting_method               psm       on psml.psm_id         = psm.psm_id
                join stn.posting_ledger               pldgr     on pml.ledger_id       = pldgr.ledger_id
                join stn.posting_accounting_basis     abasis    on pml.output_basis_id = abasis.basis_id
                join stn.posting_financial_calc       fincalc   on pml.fin_calc_id     = fincalc.fin_calc_id
          where
                cev_data.correlation_uuid not in (select correlation_uuid from gaap_fut_accts)
     )
   , gaap_fut_accts_data
  as (
         select distinct
                psm.psm_cd
              , cev_data.business_type_association_id
              , cev_data.intercompany_association_id
              , cev_data.correlation_uuid
              , ( min ( row_sid ) over ( partition by intercompany_association_id order by row_sid ) )   row_sid
              , pml.sub_event
              , cev_data.accounting_dt
              , cev_data.policy_id
              , cev_data.stream_id
              , cev_data.parent_stream_id
              , abasis.basis_typ
              , abasis.basis_cd
              , pldgr.ledger_cd
              , coalesce
                (
                    ( select
                             etout.event_typ
                        from
                             stn.event_type                   etout
                        join stn.posting_method_derivation_et psmdet on etout.event_typ_id = psmdet.output_event_typ_id
                        join stn.event_type                   etin   on psmdet.input_event_typ_id = etin.event_typ_id
                       where cev_data.event_typ = etin.event_typ
                    )
                    , cev_data.event_typ
                ) event_typ
              , cev_data.is_mark_to_market
              , cev_data.vie_cd
              , case
                    when (
                        exists (select null
                                    from cev_data cvd2
                                    where cvd2.premium_typ = 'U'
                                    and cvd2.correlation_uuid = cev_data.correlation_uuid
                                    and cev_data.event_typ = 'WRITTEN_PREMIUM'
                                )
                    and exists (select null
                                    from cev_data cvd2
                                    where cvd2.premium_typ = 'I'
                                    and cvd2.correlation_uuid = cev_data.correlation_uuid
                                    and cev_data.event_typ = 'WRITTEN_PREMIUM'
                                )
                         )
                    then 'M'
                else cev_data.premium_typ
                end premium_typ
              , cev_data.policy_premium_typ
              , cev_data.policy_accident_yr
              , cev_data.policy_underwriting_yr
              , cev_data.ultimate_parent_stream_id
              , cev_data.execution_typ
              , cev_data.policy_typ
              , cev_data.business_typ
              , cev_data.generate_interco_accounting
              , cev_data.business_unit
              , cev_data.affiliate
              , fincalc.fin_calc_cd
              , cev_data.transaction_ccy
              , (
                    select sum(cvd2.input_transaction_amt)
                      from cev_data cvd2
                     where cvd2.correlation_uuid = cev_data.correlation_uuid
                       and cvd2.intercompany_association_id = cev_data.intercompany_association_id
                )        input_transaction_amt
              , 0  partner_transaction_amt
              , cev_data.functional_ccy
              , (
                    select sum(cvd2.input_functional_amt)
                      from cev_data cvd2
                     where cvd2.correlation_uuid = cev_data.correlation_uuid
                       and cvd2.intercompany_association_id = cev_data.intercompany_association_id
                )        input_functional_amt
              , 0        partner_functional_amt
              , cev_data.reporting_ccy
              , (
                    select sum(cvd2.input_reporting_amt)
                      from cev_data cvd2
                     where cvd2.correlation_uuid = cev_data.correlation_uuid
                       and cvd2.intercompany_association_id = cev_data.intercompany_association_id
                )        input_reporting_amt
              , 0 partner_reporting_amt
              , cev_data.lpg_id
           from
                     cev_data
                join stn.posting_method                psm      on psm.psm_cd = 'GAAP_FUT_ACCTS'
                join stn.posting_method_ledger         pml      on (
                                                                           psm.psm_id            = pml.psm_id
                                                                       and cev_data.input_basis_id = pml.input_basis_id
                                                                   )
                join stn.posting_ledger                pldgr    on pml.ledger_id       = pldgr.ledger_id
                join stn.posting_accounting_basis      abasis   on pml.output_basis_id = abasis.basis_id
                join stn.posting_financial_calc        fincalc  on pml.fin_calc_id     = fincalc.fin_calc_id
          where
                not exists (
                               select
                                      null
                                 from
                                      stn.posting_method_derivation_le pdml
                                where
                                      pdml.le_cd = cev_data.business_unit
                           )
            and cev_data.correlation_uuid in (select correlation_uuid from gaap_fut_accts)
     )
   , non_intercompany_data
  as (
         select
                psm_cd                        posting_type
              , business_type_association_id
              , intercompany_association_id
              , correlation_uuid
              , row_sid
              , sub_event
              , accounting_dt
              , policy_id
              , stream_id
              , parent_stream_id
              , basis_typ
              , basis_cd
              , ledger_cd
              , event_typ
              , is_mark_to_market
              , vie_cd
              , premium_typ
              , policy_premium_typ
              , policy_accident_yr
              , policy_underwriting_yr
              , ultimate_parent_stream_id
              , execution_typ
              , policy_typ
              , business_typ
              , generate_interco_accounting
              , business_unit
              , affiliate
              , transaction_ccy
              , case fin_calc_cd
                    when 'INPUT'
                    then input_transaction_amt
                    when 'PARTNER'
                    then partner_transaction_amt
                    when 'INPUT_MINUS_PARTNER'
                    then input_transaction_amt - partner_transaction_amt
                    else null
                end                                                         transaction_amt
              , functional_ccy
              , case fin_calc_cd
                    when 'INPUT'
                    then input_functional_amt
                    when 'PARTNER'
                    then partner_functional_amt
                    when 'INPUT_MINUS_PARTNER'
                    then input_functional_amt - partner_functional_amt
                    else null
                end                                                         functional_amt
              , reporting_ccy
              , case fin_calc_cd
                    when 'INPUT'
                    then input_reporting_amt
                    when 'PARTNER'
                    then partner_reporting_amt
                    when 'INPUT_MINUS_PARTNER'
                    then input_reporting_amt - partner_reporting_amt
                    else null
                end                                                         reporting_amt
              , lpg_id
           from (
                       select
                              psm_cd
                            , business_type_association_id
                            , intercompany_association_id
                            , correlation_uuid
                            , row_sid
                            , sub_event
                            , accounting_dt
                            , policy_id
                            , stream_id
                            , parent_stream_id
                            , basis_typ
                            , basis_cd
                            , ledger_cd
                            , event_typ
                            , is_mark_to_market
                            , vie_cd
                            , premium_typ
                            , policy_premium_typ
                            , policy_accident_yr
                            , policy_underwriting_yr
                            , ultimate_parent_stream_id
                            , execution_typ
                            , policy_typ
                            , business_typ
                            , generate_interco_accounting
                            , business_unit
                            , affiliate
                            , fin_calc_cd
                            , transaction_ccy
                            , input_transaction_amt
                            , partner_transaction_amt
                            , functional_ccy
                            , input_functional_amt
                            , partner_functional_amt
                            , reporting_ccy
                            , input_reporting_amt
                            , partner_reporting_amt
                            , lpg_id
                         from
                              mtm_data
                    union all
                       select
                              psm_cd
                            , business_type_association_id
                            , intercompany_association_id
                            , correlation_uuid
                            , row_sid
                            , sub_event
                            , accounting_dt
                            , policy_id
                            , stream_id
                            , parent_stream_id
                            , basis_typ
                            , basis_cd
                            , ledger_cd
                            , event_typ
                            , is_mark_to_market
                            , vie_cd
                            , premium_typ
                            , policy_premium_typ
                            , policy_accident_yr
                            , policy_underwriting_yr
                            , ultimate_parent_stream_id
                            , execution_typ
                            , policy_typ
                            , business_typ
                            , generate_interco_accounting
                            , business_unit
                            , affiliate
                            , fin_calc_cd
                            , transaction_ccy
                            , input_transaction_amt
                            , partner_transaction_amt
                            , functional_ccy
                            , input_functional_amt
                            , partner_functional_amt
                            , reporting_ccy
                            , input_reporting_amt
                            , partner_reporting_amt
                            , lpg_id
                         from
                              le_data
                    union all
                       select
                              psm_cd
                            , business_type_association_id
                            , intercompany_association_id
                            , correlation_uuid
                            , row_sid
                            , sub_event
                            , accounting_dt
                            , policy_id
                            , stream_id
                            , parent_stream_id
                            , basis_typ
                            , basis_cd
                            , ledger_cd
                            , event_typ
                            , is_mark_to_market
                            , vie_cd
                            , premium_typ
                            , policy_premium_typ
                            , policy_accident_yr
                            , policy_underwriting_yr
                            , ultimate_parent_stream_id
                            , execution_typ
                            , policy_typ
                            , business_typ
                            , generate_interco_accounting
                            , business_unit
                            , affiliate
                            , fin_calc_cd
                            , transaction_ccy
                            , input_transaction_amt
                            , partner_transaction_amt
                            , functional_ccy
                            , input_functional_amt
                            , partner_functional_amt
                            , reporting_ccy
                            , input_reporting_amt
                            , partner_reporting_amt
                            , lpg_id
                         from
                              gaap_fut_accts_data
                )
     )
   , intercompany_data
  as (
         select
                'INTERCOMPANY_ELIMINATION'                           posting_type
              , non_intercompany_data.business_type_association_id
              , non_intercompany_data.intercompany_association_id
              , non_intercompany_data.correlation_uuid
              , non_intercompany_data.row_sid
              , non_intercompany_data.sub_event
              , non_intercompany_data.accounting_dt
              , non_intercompany_data.policy_id
              , non_intercompany_data.stream_id
              , non_intercompany_data.parent_stream_id
              , non_intercompany_data.basis_cd
              , non_intercompany_data.basis_typ
              , pldgr.ledger_cd
              , non_intercompany_data.event_typ
              , non_intercompany_data.is_mark_to_market
              , non_intercompany_data.vie_cd
              , non_intercompany_data.premium_typ
              , non_intercompany_data.policy_premium_typ
              , non_intercompany_data.policy_accident_yr
              , non_intercompany_data.policy_underwriting_yr
              , non_intercompany_data.ultimate_parent_stream_id
              , non_intercompany_data.execution_typ
              , non_intercompany_data.policy_typ
              , non_intercompany_data.business_typ
              , ele.elimination_le_cd                                business_unit
              , non_intercompany_data.business_unit                  affiliate
              , non_intercompany_data.transaction_ccy
              , non_intercompany_data.transaction_amt * -1           transaction_amt
              , non_intercompany_data.functional_ccy
              , non_intercompany_data.functional_amt * -1            functional_amt
              , non_intercompany_data.reporting_ccy
              , non_intercompany_data.reporting_amt * -1             reporting_amt
              , non_intercompany_data.lpg_id
           from
                     non_intercompany_data
                join stn.elimination_legal_entity ele on (
                                                                 non_intercompany_data.business_unit = ele.le_1_cd
                                                             and non_intercompany_data.affiliate     = ele.le_2_cd
                                                             and non_intercompany_data.basis_typ     = ele.legal_entity_link_typ
                                                         )
                join (
                         select
                                step_run_sid
                           from (
                                    select
                                           srse.step_run_sid
                                         , srse.step_run_state_start_ts
                                         , max ( srse.step_run_state_start_ts ) over ( order by null ) mxts
                                      from
                                                stn.step_run_state  srse
                                           join stn.step_run_status srsu on srse.step_run_status_id = srsu.step_run_status_id
                                     where
                                           srsu.step_run_status_cd = 'S'
                                       and exists (
                                                      select
                                                             null
                                                        from
                                                             stn.elimination_legal_entity ele
                                                       where
                                                             ele.step_run_sid = srse.step_run_sid
                                                  )
                                )
                          where
                                step_run_state_start_ts = mxts
                     )
                                                      led    on ele.step_run_sid               = led.step_run_sid
                join stn.posting_accounting_basis     abasis on non_intercompany_data.basis_cd = abasis.basis_cd
                join stn.posting_method_derivation_ic pdmic  on abasis.basis_id                = pdmic.basis_id
                join stn.posting_method_ledger        pml    on (
                                                                        pdmic.psm_id   = pml.psm_id
                                                                    and pdmic.basis_id = pml.input_basis_id
                                                                )
                join stn.posting_ledger               pldgr  on pml.ledger_id = pldgr.ledger_id
          where
                non_intercompany_data.generate_interco_accounting = 'Y'
     )
   , balancing_intercompany_data
  as (
         select
                'BALANCING_INTERCOMPANY_ELIMINATION'          posting_type
              , business_type_association_id
              , intercompany_association_id
              , correlation_uuid
              , row_sid
              , case when sub_event = 'REVERSE'
                     then 'INTERCO_REVERSE'
                     else 'INTERCO'
                end                                           sub_event
              , accounting_dt
              , policy_id
              , stream_id
              , parent_stream_id
              , basis_cd
              , basis_typ
              , ledger_cd
              , event_typ
              , is_mark_to_market
              , vie_cd
              , premium_typ
              , policy_premium_typ
              , policy_accident_yr
              , policy_underwriting_yr
              , ultimate_parent_stream_id
              , execution_typ
              , policy_typ
              , null                                          business_typ
              , business_unit
              , null                                          affiliate
              , transaction_ccy                               transaction_ccy
              , ( greatest ( abs ( transaction_amt_1 )
                           , abs ( transaction_amt_2 ) )
                   - least ( abs ( transaction_amt_1 )
                           , abs ( transaction_amt_2 ) ) )
                *
                transaction_amt_sign                          transaction_amt
              , functional_ccy                                functional_ccy
              , ( greatest ( abs ( functional_amt_1 )
                           , abs ( functional_amt_2 ) )
                   - least ( abs ( functional_amt_1 )
                           , abs ( functional_amt_2 ) ) )
                *
                functional_amt_sign                           functional_amt
              , reporting_ccy                                 reporting_ccy
              , ( greatest ( abs ( reporting_amt_1 )
                           , abs ( reporting_amt_2 ) )
                   - least ( abs ( reporting_amt_1 )
                           , abs ( reporting_amt_2 ) ) )
                *
                reporting_amt_sign                            reporting_amt
              , lpg_id
           from (
                    select
                           intercompany_data.business_type_association_id
                         , intercompany_data.intercompany_association_id
                         , intercompany_data.correlation_uuid
                         , intercompany_data.row_sid
                         , intercompany_data.sub_event
                         , intercompany_data.accounting_dt
                         , intercompany_data.policy_id
                         , intercompany_data.stream_id
                         , intercompany_data.parent_stream_id
                         , intercompany_data.basis_cd
                         , intercompany_data.basis_typ
                         , intercompany_data.ledger_cd
                         , intercompany_data.event_typ
                         , intercompany_data.is_mark_to_market
                         , intercompany_data.vie_cd
                         , intercompany_data.premium_typ
                         , intercompany_data.policy_premium_typ
                         , intercompany_data.policy_accident_yr
                         , intercompany_data.policy_underwriting_yr
                         , intercompany_data.ultimate_parent_stream_id
                         , intercompany_data.execution_typ
                         , intercompany_data.policy_typ
                         , intercompany_data.business_unit
                         , intercompany_data.transaction_ccy
                         , intercompany_data.transaction_amt                                              transaction_amt_1
                         , lead ( intercompany_data.transaction_amt )
                               over ( partition by intercompany_data.intercompany_association_id
                                                 , intercompany_data.basis_cd
                                                 , intercompany_data.sub_event
                                                 , intercompany_data.transaction_ccy
                                          order by intercompany_data.intercompany_association_id
                                                 , intercompany_data.business_typ )                       transaction_amt_2
                         , lead ( case intercompany_data.business_typ when 'CA' then
                                      case when intercompany_data.transaction_amt < 0 then -1 else 1 end
                                  end )
                              over ( partition by intercompany_data.intercompany_association_id
                                                , intercompany_data.basis_cd
                                                , intercompany_data.sub_event
                                                , intercompany_data.transaction_ccy
                                         order by intercompany_data.intercompany_association_id
                                                , intercompany_data.business_typ )                        transaction_amt_sign
                         , functional_ccy
                         , functional_amt                                                                 functional_amt_1
                         , lead ( intercompany_data.functional_amt )
                               over ( partition by intercompany_data.intercompany_association_id
                                                 , intercompany_data.basis_cd
                                                 , intercompany_data.sub_event
                                                 , intercompany_data.functional_ccy
                                          order by intercompany_data.intercompany_association_id
                                                 , intercompany_data.business_typ )                       functional_amt_2
                         , lead ( case intercompany_data.business_typ when 'CA' then
                                      case when intercompany_data.functional_amt < 0 then -1 else 1 end
                                  end )
                              over ( partition by intercompany_data.intercompany_association_id
                                                , intercompany_data.basis_cd
                                                , intercompany_data.sub_event
                                                , intercompany_data.functional_ccy
                                         order by intercompany_data.intercompany_association_id
                                                , intercompany_data.business_typ )                        functional_amt_sign
                         , reporting_ccy
                         , reporting_amt                                                                  reporting_amt_1
                         , lead ( intercompany_data.reporting_amt )
                               over ( partition by intercompany_data.intercompany_association_id
                                                 , intercompany_data.basis_cd
                                                 , intercompany_data.sub_event
                                                 , intercompany_data.reporting_ccy
                                          order by intercompany_data.intercompany_association_id
                                                 , intercompany_data.business_typ )                       reporting_amt_2
                         , lead ( case intercompany_data.business_typ when 'CA' then
                                      case when intercompany_data.reporting_amt < 0 then -1 else 1 end
                                  end )
                              over ( partition by intercompany_data.intercompany_association_id
                                                , intercompany_data.basis_cd
                                                , intercompany_data.sub_event
                                                , intercompany_data.reporting_ccy
                                         order by intercompany_data.intercompany_association_id
                                                , intercompany_data.business_typ )                        reporting_amt_sign
                         , intercompany_data.lpg_id
                      from
                           intercompany_data
                )
          where
                (
                        transaction_amt_2 is not null
                    and transaction_amt_1 != transaction_amt_2
                )
             or (
                        functional_amt_2 is not null
                    and functional_amt_1 != functional_amt_2
                )
             or (
                        reporting_amt_2 is not null
                    and reporting_amt_1 != reporting_amt_2
                )
      )
             select
                    posting_type
                  , correlation_uuid
                  , row_sid
                  , sub_event
                  , accounting_dt
                  , policy_id
                  , stream_id
                  , basis_cd
                  , business_typ
                  , premium_typ
                  , policy_premium_typ
                  , policy_accident_yr
                  , policy_underwriting_yr
                  , ultimate_parent_stream_id
                  , execution_typ
                  , policy_typ
                  , event_typ
                  , business_unit
                  , affiliate
                  , ledger_cd
                  , vie_cd
                  , is_mark_to_market
                  , transaction_ccy
                  , transaction_amt
                  , functional_ccy
                  , functional_amt
                  , reporting_ccy
                  , reporting_amt
                  , lpg_id
               from
                    non_intercompany_data
          union all
             select
                    posting_type
                  , correlation_uuid
                  , row_sid
                  , sub_event
                  , accounting_dt
                  , policy_id
                  , stream_id
                  , basis_cd
                  , business_typ
                  , premium_typ
                  , policy_premium_typ
                  , policy_accident_yr
                  , policy_underwriting_yr
                  , ultimate_parent_stream_id
                  , execution_typ
                  , policy_typ
                  , event_typ
                  , business_unit
                  , affiliate
                  , ledger_cd
                  , vie_cd
                  , is_mark_to_market
                  , transaction_ccy
                  , transaction_amt
                  , functional_ccy
                  , functional_amt
                  , reporting_ccy
                  , reporting_amt
                  , lpg_id
               from
                    intercompany_data
          union all
             select
                    posting_type
                  , correlation_uuid
                  , row_sid
                  , sub_event
                  , accounting_dt
                  , policy_id
                  , stream_id
                  , basis_cd
                  , business_typ
                  , premium_typ
                  , policy_premium_typ
                  , policy_accident_yr
                  , policy_underwriting_yr
                  , ultimate_parent_stream_id
                  , execution_typ
                  , policy_typ
                  , event_typ
                  , business_unit
                  , affiliate
                  , ledger_cd
                  , vie_cd
                  , is_mark_to_market
                  , transaction_ccy
                  , transaction_amt
                  , functional_ccy
                  , functional_amt
                  , reporting_ccy
                  , reporting_amt
                  , lpg_id
               from
                    vie_data
                  ;
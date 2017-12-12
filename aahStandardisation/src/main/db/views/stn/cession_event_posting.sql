create or replace view stn.cession_event_posting
as
with
     ce_data
  as (
  select
                   ipr.policy_id
                 , ipr.policy_abbr_nm
                 , ipr.stream_id
                 , vie.vie_id
                 , vie.vie_cd
                 , ipr.ledger_entity_cd                 le_cd
                 , ipr.is_mark_to_market
                 , ipr.policy_premium_typ
                 , ipr.policy_accident_yr
                 , ipr.policy_underwriting_yr
                 , ipr.policy_typ
                 , ipr.parent_stream_id
                 , pipr.ledger_entity_cd                parent_cession_le_cd
                 , ipr.ultimate_parent_stream_id
                 , ipr.execution_typ
                 , ipr.le_cd                            owner_le_cd
                 , pipr.le_cd                           counterparty_le_cd
              from
                        stn.insurance_policy_reference  ipr
                   join stn.vie_event_cd                vec  on ipr.stream_id        = vec.stream_id
                   join stn.vie_code                    vie  on vec.vie_cd           = vie.vie_cd
              left join stn.insurance_policy_reference  pipr on ipr.parent_stream_id = pipr.stream_id
     )
   , cev_data
  as (
         select
                business_type_association_id
              , intercompany_association_id
              , derived_plus_association_id
              , gaap_fut_accts_association_id
              , basis_association_id
              , correlation_uuid
              , event_seq_id
              , row_sid
              , basis_id                                                                                                   input_basis_id
              , basis_cd                                                                                                   input_basis_cd
              , partner_basis_cd
              , accounting_dt
              , event_typ
              , event_typ_id
              , business_event_typ
              , policy_id
              , policy_abbr_nm
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
              , owner_le_cd
              , counterparty_le_cd
              , transaction_amt                                                                                            input_transaction_amt
              , coalesce ( lag  ( basis_transaction_amt ) over ( partition by business_type_association_id order by basis_cd )
                         , lead ( basis_transaction_amt ) over ( partition by business_type_association_id order by basis_cd ) )   partner_transaction_amt
              , coalesce ( lag  ( transaction_amt ) over ( partition by derived_plus_association_id order by basis_cd )
                         , lead ( transaction_amt ) over ( partition by derived_plus_association_id order by basis_cd ) )  dp_partner_transaction_amt
              , transaction_ccy
              , functional_amt                                                                                             input_functional_amt
              , coalesce ( lag  ( basis_functional_amt ) over ( partition by business_type_association_id order by basis_cd )
                         , lead ( basis_functional_amt ) over ( partition by business_type_association_id order by basis_cd ) )  partner_functional_amt
              , coalesce ( lag  ( functional_amt ) over ( partition by derived_plus_association_id order by basis_cd )
                         , lead ( functional_amt ) over ( partition by derived_plus_association_id order by basis_cd ) )   dp_partner_functional_amt
              , functional_ccy
              , reporting_amt                                                                                              input_reporting_amt
              , coalesce ( lag  ( basis_reporting_amt ) over ( partition by business_type_association_id order by basis_cd )
                         , lead ( basis_reporting_amt ) over ( partition by business_type_association_id order by basis_cd ) )   partner_reporting_amt
              , coalesce ( lag  ( reporting_amt ) over ( partition by derived_plus_association_id order by basis_cd )
                         , lead ( reporting_amt ) over ( partition by derived_plus_association_id order by basis_cd ) )    dp_partner_reporting_amt
              , reporting_ccy
              , lpg_id
           from (
                    select
                           rank () over ( order by
                                                   cev.feed_uuid
                                                 , cev.correlation_uuid
                                                 , cev.accounting_dt
                                                 , cev.stream_id
                                                 , cev.event_typ
                                                 , cev.business_typ )          business_type_association_id
                         , rank () over ( order by
                                                   cev.feed_uuid
                                                 , cev.correlation_uuid
                                                 , cev.accounting_dt
                                                 , cev.stream_id
                                                 , cev.event_typ )             intercompany_association_id
                         , rank () over ( order by
                                                   cev.feed_uuid
                                                 , cev.correlation_uuid
                                                 , cev.accounting_dt
                                                 , cev.basis_cd
                                                 , cev.stream_id
                                                 , cev.premium_typ
                                                 , cev.business_typ )          derived_plus_association_id
                         , rank () over ( order by
                                                   cev.feed_uuid
                                                 , cev.correlation_uuid
                                                 , cev.accounting_dt
                                                 , cev.stream_id
                                                 , cev.event_typ 
                                                 , cev.business_typ )          gaap_fut_accts_association_id
                         , rank () over ( order by
                                                   cev.feed_uuid
                                                 , cev.correlation_uuid
                                                 , cev.accounting_dt
                                                 , cev.stream_id
                                                 , cev.event_typ 
                                                 , cev.business_typ
                                                 , cev.basis_cd )              basis_association_id
                         , cev.correlation_uuid
                         , cev.event_id                                        event_seq_id
                         , cev.row_sid
                         , cev.basis_cd
                         , decode ( cev.basis_cd
                                    , 'US_GAAP' , 'US_STAT' 
                                    , 'US_STAT' , 'US_GAAP'
                                    , null )                                   partner_basis_cd
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
                         , cev.business_event_typ
                         , ce_data.policy_id
                         , ce_data.policy_abbr_nm
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
                           end                                                       premium_typ
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
                         , case
                               when bt.bu_derivation_method = 'CESSION'
                               then ce_data.owner_le_cd
                               when bt.bu_derivation_method = 'PARENT_CESSION'
                               then ce_data.counterparty_le_cd
                               else null
                           end                                                       owner_le_cd
                         , case
                               when bt.bu_derivation_method = 'CESSION'
                               then ce_data.counterparty_le_cd
                               when bt.bu_derivation_method = 'PARENT_CESSION'
                               then ce_data.owner_le_cd
                               else null
                           end                                                       counterparty_le_cd
                         , cev.transaction_amt                                       transaction_amt
                         , cevsum.transaction_amt                                    basis_transaction_amt
                         , cev.transaction_ccy
                         , cev.functional_amt                                        functional_amt
                         , cevsum.functional_amt                                     basis_functional_amt
                         , cev.functional_ccy
                         , cev.reporting_amt                                         reporting_amt
                         , cevsum.reporting_amt                                      basis_reporting_amt
                         , cev.reporting_ccy
                         , cev.lpg_id
                      from
                                stn.cession_event                cev
                           join stn.identified_record            idr     on cev.row_sid                = idr.row_sid
                           join                                  ce_data on cev.stream_id              = ce_data.stream_id
                           join stn.event_type                   et      on cev.event_typ              = et.event_typ
                           join stn.posting_accounting_basis     abasis  on cev.basis_cd               = abasis.basis_cd
                           join stn.business_type                bt      on cev.business_typ           = bt.business_typ
                           join stn.policy_premium_type          ppt     on ce_data.policy_premium_typ = ppt.premium_typ
                      left join stn.posting_method_derivation_et psmdet  on et.event_typ_id            = psmdet.input_event_typ_id
                      left join stn.event_type                   etout   on psmdet.output_event_typ_id = etout.event_typ_id
                           join (select sum (cev2.transaction_amt) transaction_amt
                                      , sum (cev2.functional_amt)  functional_amt
                                      , sum (cev2.reporting_amt)   reporting_amt
                                      , cev2.feed_uuid
                                      , cev2.correlation_uuid
                                      , cev2.accounting_dt
                                      , cev2.stream_id
                                      , cev2.event_typ 
                                      , cev2.business_typ
                                      , cev2.basis_cd
                                   from stn.cession_event cev2
                               group by cev2.feed_uuid
                                      , cev2.correlation_uuid
                                      , cev2.accounting_dt
                                      , cev2.stream_id
                                      , cev2.event_typ 
                                      , cev2.business_typ
                                      , cev2.basis_cd )           cevsum
                                                 on cev.feed_uuid        = cevsum.feed_uuid
                                                and cev.correlation_uuid = cevsum.correlation_uuid
                                                and cev.accounting_dt    = cevsum.accounting_dt
                                                and cev.stream_id        = cevsum.stream_id
                                                and cev.event_typ        = cevsum.event_typ 
                                                and cev.business_typ     = cevsum.business_typ
                                                and cev.basis_cd         = cevsum.basis_cd
                     where
                                cev.event_status = 'V'
                )
     )
   , gaap_fut_accts
  as (
         select distinct
                cev.correlation_uuid correlation_uuid
              , cev.event_seq_id     event_seq_id
              , cev.event_typ        event_typ
           from
                cev_data                  cev
          where exists (
                        select null 
                          from 
                               stn.cession_event cev2
                         where
                               cev2.event_typ        = 'WP_PV_FUTURE'
                           and cev2.correlation_uuid = cev.correlation_uuid
                           and cev.event_typ         in ( 'WP_PV_FUTURE' , 'WRITTEN_PREMIUM' )
                union all 
                        select null
                          from
                               stn.cession_event cev2
                         where
                               cev2.event_typ        = 'CC_PV_FUTURE'
                           and cev2.correlation_uuid = cev.correlation_uuid
                           and cev.event_typ         in ( 'CC_PV_FUTURE' , 'CC_INCOME_EXPENSE' )
                       )
     )
   , derived_plus
  as (
         select distinct
                cev.correlation_uuid correlation_uuid
              , cev.event_id         event_seq_id
           from
                     stn.cession_event                  cev
                join stn.event_type                     et     on cev.EVENT_TYP = et.EVENT_TYP
                join stn.posting_amount_derivation      psad   on et.event_typ_id = psad.event_typ_id
                join stn.posting_amount_derivation_type psadt  on psad.amount_typ_id = psadt.amount_typ_id
          where
                     psadt.amount_typ_descr = 'DERIVED_PLUS'
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
              , last_day(balance_date) end_of_period
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
              , last_day(balance_date)
    )
   , vie_data
  as (
         select
                'VIE'                             posting_type
              , cev_data.correlation_uuid
              , cev_data.event_seq_id
              , cev_data.row_sid
              , vc.sub_event
              , cev_data.accounting_dt
              , cev_data.policy_id
              , cev_data.policy_abbr_nm
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
              , cev_data.business_event_typ
              , vle.vie_le_cd                     business_unit
              , null                              affiliate
              , null                              owner_le_cd
              , null                              counterparty_le_cd
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
              , 0        derived_plus_association_id
              , 0        gaap_fut_accts_association_id
              , cev_data.correlation_uuid
              , cev_data.event_seq_id
              , cev_data.row_sid
              , pml.sub_event
              , cev_data.accounting_dt
              , cev_data.policy_id
              , cev_data.policy_abbr_nm
              , cev_data.stream_id
              , cev_data.parent_stream_id
              , abasis.basis_typ
              , abasis.basis_cd
              , pldgr.ledger_cd
              , cev_data.event_typ
              , cev_data.business_event_typ
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
              , cev_data.owner_le_cd
              , cev_data.counterparty_le_cd
              , fincalc.fin_calc_cd
              , cev_data.transaction_ccy
              , case
                    when padt.amount_typ_descr in ( 'DERIVED' )
                        then cev_data.input_transaction_amt - nvl(pb.transaction_balance,0)
                    else cev_data.input_transaction_amt
                end input_transaction_amt
              , case
                    when padt.amount_typ_descr in ( 'DERIVED' )
                        then cev_data.partner_transaction_amt - nvl(pb.transaction_balance,0)
                    else cev_data.partner_transaction_amt
                end partner_transaction_amt
              , cev_data.functional_ccy
              , case
                    when padt.amount_typ_descr in ( 'DERIVED' )
                        then cev_data.input_functional_amt - nvl(pb.functional_balance,0)
                    else cev_data.input_functional_amt
                end input_functional_amt
              , case
                    when padt.amount_typ_descr in ( 'DERIVED' )
                        then cev_data.partner_functional_amt - nvl(pb.functional_balance,0)
                    else cev_data.partner_functional_amt
                end partner_functional_amt
              , cev_data.reporting_ccy
              , case
                    when padt.amount_typ_descr in ( 'DERIVED' )
                        then cev_data.input_reporting_amt - nvl(pb.reporting_balance,0)
                    else cev_data.input_reporting_amt
                end input_reporting_amt
              , case
                    when padt.amount_typ_descr in ( 'DERIVED' )
                        then cev_data.partner_reporting_amt - nvl(pb.reporting_balance,0)
                    else cev_data.partner_reporting_amt
                end partner_reporting_amt
              , cev_data.lpg_id
           from
                                                        cev_data
                join stn.posting_method_derivation_mtm  psmtm    on (
                                                                           cev_data.event_typ_id      = psmtm.event_typ_id
                                                                       and cev_data.is_mark_to_market = psmtm.is_mark_to_market
                                                                       and (
                                                                            case
                                                                                when exists (
                                                                                            select null
                                                                                              from gaap_fut_accts gfa  
                                                                                             where cev_data.correlation_uuid = gfa.correlation_uuid
                                                                                               and cev_data.event_seq_id     = gfa.event_seq_id
                                                                                               and cev_data.premium_typ      = 'U'
                                                                                             )
                                                                                then 'M'
                                                                                else cev_data.premium_typ
                                                                             end
                                                                           )                          = psmtm.premium_typ
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
                                                                       and extract( month from ( add_months ( cev_data.accounting_dt , -1 ) ) ) = pb.period_month
                                                                       and extract( year from ( add_months ( cev_data.accounting_dt , -1 ) ) )  = pb.period_year
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
            and cev_data.correlation_uuid||cev_data.event_seq_id not in (select correlation_uuid||event_seq_id from derived_plus)
            and cev_data.correlation_uuid||cev_data.event_seq_id||'WP_PV_FUTURE' not in (select correlation_uuid||event_seq_id||event_typ from gaap_fut_accts)
            and cev_data.correlation_uuid||cev_data.event_seq_id||'CC_PV_FUTURE' not in (select correlation_uuid||event_seq_id||event_typ from gaap_fut_accts)
     )
   , le_data
  as (
         select
                psm.psm_cd
              , cev_data.business_type_association_id
              , cev_data.intercompany_association_id
              , 0        derived_plus_association_id
              , 0        gaap_fut_accts_association_id
              , cev_data.correlation_uuid
              , cev_data.event_seq_id
              , cev_data.row_sid
              , pml.sub_event
              , cev_data.accounting_dt
              , cev_data.policy_id
              , cev_data.policy_abbr_nm
              , cev_data.stream_id
              , cev_data.parent_stream_id
              , abasis.basis_typ
              , abasis.basis_cd
              , pldgr.ledger_cd
              , cev_data.event_typ
              , cev_data.business_event_typ
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
              , cev_data.owner_le_cd
              , cev_data.counterparty_le_cd
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
                cev_data.correlation_uuid||cev_data.event_seq_id not in (select correlation_uuid||event_seq_id from derived_plus)
            and cev_data.correlation_uuid||cev_data.event_seq_id not in (select correlation_uuid||event_seq_id from gaap_fut_accts)     )
   , gaap_fut_accts_data
  as (
         select distinct
                psm.psm_cd
              , cev_data.business_type_association_id
              , cev_data.intercompany_association_id
              , 0        derived_plus_association_id
              , cev_data.gaap_fut_accts_association_id
              , cev_data.correlation_uuid
              , ( min ( event_seq_id ) over ( partition by gaap_fut_accts_association_id order by event_seq_id ) )   event_seq_id
              , ( min ( row_sid ) over ( partition by gaap_fut_accts_association_id order by row_sid ) )   row_sid
              , pml.sub_event
              , cev_data.accounting_dt
              , cev_data.policy_id
              , cev_data.policy_abbr_nm
              , cev_data.stream_id
              , cev_data.parent_stream_id
              , abasis.basis_typ
              , abasis.basis_cd
              , pldgr.ledger_cd
              , coalesce
                (
                    (
                      select
                             etout.event_typ
                        from
                             stn.event_type                   etout
                        join stn.posting_method_derivation_et psmdet on etout.event_typ_id = psmdet.output_event_typ_id
                        join stn.event_type                   etin   on psmdet.input_event_typ_id = etin.event_typ_id
                       where cev_data.event_typ = etin.event_typ
                    )
                    , cev_data.event_typ
                ) event_typ
              , cev_data.business_event_typ
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
              , cev_data.owner_le_cd
              , cev_data.counterparty_le_cd
              , fincalc.fin_calc_cd
              , cev_data.transaction_ccy
              , (
                    select sum(cvd2.input_transaction_amt)
                      from cev_data cvd2
                     where cvd2.correlation_uuid = cev_data.correlation_uuid
                       and cvd2.gaap_fut_accts_association_id = cev_data.gaap_fut_accts_association_id
                )        input_transaction_amt
              , 0  partner_transaction_amt
              , cev_data.functional_ccy
              , (
                    select sum(cvd2.input_functional_amt)
                      from cev_data cvd2
                     where cvd2.correlation_uuid = cev_data.correlation_uuid
                       and cvd2.gaap_fut_accts_association_id = cev_data.gaap_fut_accts_association_id
                )        input_functional_amt
              , 0 partner_functional_amt
              , cev_data.reporting_ccy
              , (
                    select sum(cvd2.input_reporting_amt)
                      from cev_data cvd2
                     where cvd2.correlation_uuid = cev_data.correlation_uuid
                       and cvd2.gaap_fut_accts_association_id = cev_data.gaap_fut_accts_association_id
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
            and cev_data.correlation_uuid||cev_data.event_seq_id not in (select correlation_uuid||event_seq_id from derived_plus)
            and cev_data.correlation_uuid||cev_data.event_seq_id in (select correlation_uuid||event_seq_id from gaap_fut_accts)
     )
   , derived_plus_data
  as (
         select
                psm.psm_cd
              , cev_data.business_type_association_id
              , cev_data.intercompany_association_id
              , cev_data.derived_plus_association_id
              , 0        gaap_fut_accts_association_id
              , cev_data.correlation_uuid
              , cev_data.event_seq_id
              , cev_data.row_sid
              , pml.sub_event
              , cev_data.accounting_dt
              , cev_data.policy_id
              , cev_data.policy_abbr_nm
              , cev_data.stream_id
              , cev_data.parent_stream_id
              , abasis.basis_typ
              , abasis.basis_cd
              , pldgr.ledger_cd
              , cev_data.event_typ
              , cev_data.business_event_typ
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
              , cev_data.owner_le_cd
              , cev_data.counterparty_le_cd
              , fincalc.fin_calc_cd
              , cev_data.transaction_ccy
              , case
                    when padt.amount_typ_descr in ( 'DERIVED_PLUS' )
                        then cev_data.input_transaction_amt - cev_data.dp_partner_transaction_amt - nvl(pb.transaction_balance,0)
                    else cev_data.input_transaction_amt
                end input_transaction_amt
              , nvl(pb.transaction_balance,0) transaction_balance
              , (
                    (
                    sum ( ( case
                        when padt.amount_typ_descr in ( 'DERIVED_PLUS' )
                            then cev_data.input_transaction_amt - cev_data.dp_partner_transaction_amt - nvl(pb.transaction_balance,0)
                        else cev_data.input_transaction_amt
                    end ) ) over ( partition by derived_plus_association_id )
                    ) -
                    (
                    case
                        when padt.amount_typ_descr in ( 'DERIVED_PLUS' )
                            then cev_data.input_transaction_amt - cev_data.dp_partner_transaction_amt - nvl(pb.transaction_balance,0)
                        else cev_data.input_transaction_amt
                    end
                    )
                )                 
                partner_transaction_amt
              , cev_data.dp_partner_transaction_amt
              , cev_data.functional_ccy
              , case
                    when padt.amount_typ_descr in ( 'DERIVED_PLUS' )
                        then cev_data.input_functional_amt - cev_data.dp_partner_functional_amt - nvl(pb.functional_balance,0)
                    else cev_data.input_functional_amt
                end input_functional_amt
              , nvl(pb.functional_balance,0) functional_balance
              , (
                    (
                    sum ( ( case
                        when padt.amount_typ_descr in ( 'DERIVED_PLUS' )
                            then cev_data.input_functional_amt - cev_data.dp_partner_functional_amt - nvl(pb.functional_balance,0)
                        else cev_data.input_functional_amt
                    end ) ) over ( partition by derived_plus_association_id )
                    ) -
                    (
                    case
                        when padt.amount_typ_descr in ( 'DERIVED_PLUS' )
                            then cev_data.input_functional_amt - cev_data.dp_partner_functional_amt - nvl(pb.functional_balance,0)
                        else cev_data.input_functional_amt
                    end
                    )
                )                 
                partner_functional_amt
              , cev_data.dp_partner_functional_amt
              , cev_data.reporting_ccy
              , case
                    when padt.amount_typ_descr in ( 'DERIVED_PLUS' )
                        then cev_data.input_reporting_amt - cev_data.dp_partner_reporting_amt - nvl(pb.reporting_balance,0)
                    else cev_data.input_reporting_amt
                end input_reporting_amt
              , nvl(pb.reporting_balance,0) reporting_balance
              , (
                    (
                    sum ( ( case
                        when padt.amount_typ_descr in ( 'DERIVED_PLUS' )
                            then cev_data.input_reporting_amt - cev_data.dp_partner_reporting_amt - nvl(pb.reporting_balance,0)
                        else cev_data.input_reporting_amt
                    end ) ) over ( partition by derived_plus_association_id )
                    ) -
                    (
                    case
                        when padt.amount_typ_descr in ( 'DERIVED_PLUS' )
                            then cev_data.input_reporting_amt - cev_data.dp_partner_reporting_amt - nvl(pb.reporting_balance,0)
                        else cev_data.input_reporting_amt
                    end
                    )
                )                 
                partner_reporting_amt
              , cev_data.dp_partner_reporting_amt
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
                                                                       and extract( month from ( add_months ( cev_data.accounting_dt , -1 ) ) ) = pb.period_month
                                                                       and extract( year from ( add_months ( cev_data.accounting_dt , -1 ) ) )  = pb.period_year
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
            and cev_data.correlation_uuid||cev_data.event_seq_id in (select correlation_uuid||event_seq_id from derived_plus)
            and cev_data.correlation_uuid||cev_data.event_seq_id not in (select correlation_uuid||event_seq_id from gaap_fut_accts)
     )
   , amount_derivation
  as (
         select
                psm_cd                        posting_type
              , business_type_association_id
              , intercompany_association_id
              , derived_plus_association_id
              , gaap_fut_accts_association_id
              , correlation_uuid
              , event_seq_id
              , row_sid
              , sub_event
              , accounting_dt
              , policy_id
              , policy_abbr_nm
              , stream_id
              , parent_stream_id
              , basis_typ
              , basis_cd
              , ledger_cd
              , event_typ
              , business_event_typ
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
              , owner_le_cd
              , counterparty_le_cd
              , transaction_ccy
              , case fin_calc_cd
                    when 'INPUT'
                    then input_transaction_amt
                    when 'PARTNER'
                    then partner_transaction_amt
                    when 'INPUT_MINUS_PARTNER'
                    then input_transaction_amt - partner_transaction_amt
                    when 'INPUT_PLUS_PARTNER'
                    then input_transaction_amt  --partner amount already added in gaap_fut_accts_data step
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
                    when 'INPUT_PLUS_PARTNER'
                    then input_functional_amt  --partner amount already added in gaap_fut_accts_data step
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
                    when 'INPUT_PLUS_PARTNER'
                    then input_reporting_amt  --partner amount already added in gaap_fut_accts_data step
                    else null
                end                                                         reporting_amt
              , lpg_id
           from (
                       select
                              psm_cd
                            , business_type_association_id
                            , intercompany_association_id
                            , derived_plus_association_id
                            , gaap_fut_accts_association_id
                            , correlation_uuid
                            , event_seq_id
                            , row_sid
                            , sub_event
                            , accounting_dt
                            , policy_id
                            , policy_abbr_nm
                            , stream_id
                            , parent_stream_id
                            , basis_typ
                            , basis_cd
                            , ledger_cd
                            , event_typ
                            , business_event_typ
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
                            , owner_le_cd
                            , counterparty_le_cd
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
                            , derived_plus_association_id
                            , gaap_fut_accts_association_id
                            , correlation_uuid
                            , event_seq_id
                            , row_sid
                            , sub_event
                            , accounting_dt
                            , policy_id
                            , policy_abbr_nm
                            , stream_id
                            , parent_stream_id
                            , basis_typ
                            , basis_cd
                            , ledger_cd
                            , event_typ
                            , business_event_typ
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
                            , owner_le_cd
                            , counterparty_le_cd
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
                            , derived_plus_association_id
                            , gaap_fut_accts_association_id
                            , correlation_uuid
                            , event_seq_id
                            , row_sid
                            , sub_event
                            , accounting_dt
                            , policy_id
                            , policy_abbr_nm
                            , stream_id
                            , parent_stream_id
                            , basis_typ
                            , basis_cd
                            , ledger_cd
                            , event_typ
                            , business_event_typ
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
                            , owner_le_cd
                            , counterparty_le_cd
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
                    union all
                       select
                              psm_cd
                            , business_type_association_id
                            , intercompany_association_id
                            , derived_plus_association_id
                            , gaap_fut_accts_association_id
                            , correlation_uuid
                            , event_seq_id
                            , row_sid
                            , sub_event
                            , accounting_dt
                            , policy_id
                            , policy_abbr_nm
                            , stream_id
                            , parent_stream_id
                            , basis_typ
                            , basis_cd
                            , ledger_cd
                            , event_typ
                            , business_event_typ
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
                            , owner_le_cd
                            , counterparty_le_cd
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
                              derived_plus_data
                )
     )
   , non_intercompany_data
  as (
         select
                posting_type
              , business_type_association_id
              , intercompany_association_id
              , derived_plus_association_id
              , gaap_fut_accts_association_id
              , correlation_uuid
              , event_seq_id
              , row_sid
              , sub_event
              , accounting_dt
              , policy_id
              , policy_abbr_nm
              , stream_id
              , parent_stream_id
              , basis_typ
              , basis_cd
              , ledger_cd
              , event_typ
              , business_event_typ
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
              , owner_le_cd
              , counterparty_le_cd
              , tax_jurisdiction_cd
              , transaction_ccy
              , transaction_amt
              , functional_ccy
              , functional_amt
              , reporting_ccy
              , reporting_amt
              , lpg_id
           from (
                       select
                              ad.posting_type
                            , ad.business_type_association_id
                            , ad.intercompany_association_id
                            , ad.derived_plus_association_id
                            , ad.gaap_fut_accts_association_id
                            , ad.correlation_uuid
                            , ad.event_seq_id
                            , ad.row_sid
                            , ad.sub_event
                            , ad.accounting_dt
                            , ad.policy_id
                            , ad.policy_abbr_nm
                            , ad.stream_id
                            , ad.parent_stream_id
                            , ad.basis_typ
                            , ad.basis_cd
                            , ad.ledger_cd
                            , ad.event_typ
                            , ad.business_event_typ
                            , ad.is_mark_to_market
                            , ad.vie_cd
                            , ad.premium_typ
                            , ad.policy_premium_typ
                            , ad.policy_accident_yr
                            , ad.policy_underwriting_yr
                            , ad.ultimate_parent_stream_id
                            , ad.execution_typ
                            , ad.policy_typ
                            , ad.business_typ
                            , ad.generate_interco_accounting
                            , ad.business_unit
                            , ad.affiliate
                            , ad.owner_le_cd
                            , ad.counterparty_le_cd
                            , pt.tax_jurisdiction_cd                                                 tax_jurisdiction_cd
                            , ad.transaction_ccy
                            , ( ( ad.transaction_amt * nvl(pt.tax_jurisdiction_pct,100) ) / 100 )    transaction_amt
                            , ad.functional_ccy
                            , ( ( ad.functional_amt * nvl(pt.tax_jurisdiction_pct,100) ) / 100 )     functional_amt
                            , ad.reporting_ccy
                            , ( ( ad.reporting_amt * nvl(pt.tax_jurisdiction_pct,100) ) / 100 )      reporting_amt
                            , ad.lpg_id
                         from
                              amount_derivation  ad
                    left join
                              stn.policy_tax     pt     on ad.policy_id = pt.policy_id
                )
     )
   /*  
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
              , non_intercompany_data.policy_abbr_nm
              , non_intercompany_data.stream_id
              , non_intercompany_data.parent_stream_id
              , non_intercompany_data.basis_cd
              , non_intercompany_data.basis_typ
              , pldgr.ledger_cd
              , non_intercompany_data.event_typ
              , non_intercompany_data.business_event_typ
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
              , policy_abbr_nm
              , stream_id
              , parent_stream_id
              , basis_cd
              , basis_typ
              , ledger_cd
              , event_typ
              , business_event_typ
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
                         , intercompany_data.policy_abbr_nm
                         , intercompany_data.stream_id
                         , intercompany_data.parent_stream_id
                         , intercompany_data.basis_cd
                         , intercompany_data.basis_typ
                         , intercompany_data.ledger_cd
                         , intercompany_data.event_typ
                         , intercompany_data.business_event_typ
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
      )   */
             select
                    posting_type
                  , correlation_uuid
                  , event_seq_id
                  , row_sid
                  , sub_event
                  , accounting_dt
                  , policy_id
                  , policy_abbr_nm
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
                  , business_event_typ
                  , business_unit
                  , affiliate
                  , owner_le_cd
                  , counterparty_le_cd
                  , ledger_cd
                  , vie_cd
                  , is_mark_to_market
                  , tax_jurisdiction_cd
                  , transaction_ccy
                  , transaction_amt
                  , functional_ccy
                  , functional_amt
                  , reporting_ccy
                  , reporting_amt
                  , lpg_id
               from
                    non_intercompany_data
      /*    union all
             select
                    posting_type
                  , correlation_uuid
                  , row_sid
                  , sub_event
                  , accounting_dt
                  , policy_id
                  , policy_abbr_nm
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
                  , business_event_typ
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
                  , policy_abbr_nm
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
                  , business_event_typ
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
                    vie_data */;

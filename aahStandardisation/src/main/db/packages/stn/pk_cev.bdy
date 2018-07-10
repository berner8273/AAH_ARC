CREATE OR REPLACE PACKAGE BODY stn.PK_CEV AS
    PROCEDURE pr_cession_event_idf
        (
            p_lpg_id IN NUMBER,
            p_step_run_sid IN NUMBER,
            p_no_identified_records OUT NUMBER
        )
    AS
    BEGIN
        INSERT /*+ PARALLEL */ INTO IDENTIFIED_RECORD
            (ROW_SID)
            SELECT
                ce.ROW_SID AS ROW_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
            WHERE
                    ce.event_status = 'U'
and ce.lpg_id       = p_lpg_id
and not exists (
                   select
                          null
                     from
                          stn.broken_feed bf
                    where
                          bf.feed_sid = fd.FEED_SID
               )
and not exists (
                  select
                         null
                    from
                         stn.superseded_feed sf
                   where
                         sf.superseded_feed_sid = fd.FEED_SID
              )
and exists    (
                  select
                         null
                    from
                         stn.feed fd2 
                    join 
                         stn.cession_event             ce2 on fd2.feed_uuid = ce2.feed_uuid
                    join stn.event_hierarchy_reference ehr on ce2.event_typ = ehr.event_typ
                    join stn.period_status ps  on ( extract ( year from ce2.accounting_dt ) || lpad ( extract ( month from ce2.accounting_dt ) , 2 , 0 ) ) = ps.period
                                              and ehr.event_class = ps.event_class
                                              and 'O'             = ps.status
                   where 
                         fd2.feed_sid = fd.FEED_SID
              );
        dbms_stats.gather_table_stats ( ownname => 'STN' , tabname => 'IDENTIFIED_RECORD' , cascade => true );
        UPDATE CESSION_EVENT ce
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.identified_record idr
            where
                  ce.row_sid = idr.row_sid
       );
        p_no_identified_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_cession_event_pub
        (
            p_step_run_sid IN NUMBER,
            p_no_published_records OUT NUMBER,
            p_no_pub_rev_hist_records OUT NUMBER,
            p_no_pub_rev_curr_records OUT NUMBER
        )
    AS
        v_no_cev_valid NUMBER(38, 9) DEFAULT 0;
        v_no_cev_data NUMBER(38, 9) DEFAULT 0;
        v_no_cev_mtm_data NUMBER(38, 9) DEFAULT 0;
        v_no_cev_gaap_fut_accts_data NUMBER(38, 9) DEFAULT 0;
        v_no_cev_derived_plus_data NUMBER(38, 9) DEFAULT 0;
        v_no_cev_le_data NUMBER(38, 9) DEFAULT 0;
        v_no_cev_non_intercompany_data NUMBER(38, 9) DEFAULT 0;
        v_no_cev_intercompany_data NUMBER(38, 9) DEFAULT 0;
                                                  
    BEGIN
        delete /*+ parallel*/ from stn.cev_valid;
        insert /*+ parallel*/ into stn.cev_valid
        (   row_sid
        ,   correlation_uuid
        ,   event_id
        ,   accounting_dt
        ,   stream_id
        ,   basis_cd
        ,   premium_typ
        ,   business_typ
        ,   event_typ
        ,   business_event_typ
        ,   source_event_ts
        ,   transaction_ccy
        ,   transaction_amt
        ,   functional_ccy
        ,   functional_amt
        ,   reporting_ccy
        ,   reporting_amt
        ,   lpg_id
        ,   event_status
        ,   feed_uuid
        ,   no_retries
        ,   step_run_sid )
        select
            cev.row_sid
        ,   cev.correlation_uuid
        ,   cev.event_id
        ,   cev.accounting_dt
        ,   cev.stream_id
        ,   cev.basis_cd
        ,   cev.premium_typ
        ,   cev.business_typ
        ,   cev.event_typ
        ,   cev.business_event_typ
        ,   cev.source_event_ts
        ,   cev.transaction_ccy
        ,   cev.transaction_amt
        ,   cev.functional_ccy
        ,   cev.functional_amt
        ,   cev.reporting_ccy
        ,   cev.reporting_amt
        ,   cev.lpg_id
        ,   cev.event_status
        ,   cev.feed_uuid
        ,   cev.no_retries
        ,   cev.step_run_sid
          from
               stn.cession_event                cev
          join stn.identified_record            idr     on cev.row_sid = idr.row_sid
         where
               cev.event_status = 'V'
        ;
        
        v_no_cev_valid := sql%rowcount;
        
        dbms_stats.gather_table_stats ( ownname => 'STN', tabname => 'CEV_VALID' , cascade => true );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cev_valid', 'v_no_cev_valid', NULL, v_no_cev_valid, NULL);
        insert into stn.posting_account_derivation
        select distinct
               fpd.pd_posting_schema     posting_schema
             , fpd.pd_aet_event_type     event_typ
             , fpd.pd_sub_event          sub_event
             , fal.al_lookup_1           business_typ
             , fal.al_lookup_2           is_mark_to_market
             , fal.al_lookup_3           business_unit
             , fal.al_ccy                currency
             , fal.al_account            sub_account
          from
               fdr.fr_posting_driver              fpd
          join fdr.fr_account_lookup              fal   on fpd.pd_posting_code    = fal.al_posting_code
          join fdr.fr_gl_account                  fgl   on fal.al_account         = fgl.ga_account_code
          join stn.event_type                     et    on fpd.pd_aet_event_type  = et.event_typ
          join stn.posting_amount_derivation      pad   on et.event_typ_id        = pad.event_typ_id
          join stn.posting_amount_derivation_type padt  on pad.amount_typ_id      = padt.amount_typ_id
         where
               fgl.ga_account_type     = 'B'
           and padt.amount_typ_descr   in ( 'DERIVED' , 'DERIVED_PLUS' )
             ;
        
        --dbms_stats.gather_table_stats ( ownname => 'STN', tabname => 'POSTING_ACCOUNT_DERIVATION' );
        insert into stn.vie_posting_account_derivation
        select distinct
               fpd.pd_posting_schema     posting_schema
             , fpd.pd_aet_event_type     event_typ
             , fpd.pd_sub_event          sub_event
             , fal.al_lookup_1           business_typ
             , fal.al_lookup_2           is_mark_to_market
             , fal.al_lookup_3           business_unit
             , fal.al_ccy                currency
             , fal.al_account            sub_account
          from
               fdr.fr_posting_driver              fpd
          join fdr.fr_account_lookup              fal   on fpd.pd_posting_code    = fal.al_posting_code
          join fdr.fr_gl_account                  fgl   on fal.al_account         = fgl.ga_account_code
          join stn.event_type                     et    on fpd.pd_aet_event_type  = et.event_typ
          join stn.posting_amount_derivation      pad   on et.event_typ_id        = pad.event_typ_id
          join stn.posting_amount_derivation_type padt  on pad.amount_typ_id      = padt.amount_typ_id
         where
               fgl.ga_account_type     = 'B'
           and exists ( select
                               null
                          from
                               stn.event_type      et
                          join stn.vie_event_type  vet   on et.event_typ_id = vet.event_typ_id
                         where et.event_typ = fpd.pd_aet_event_type )
             ;
        
        --dbms_stats.gather_table_stats ( ownname => 'STN', tabname => 'VIE_POSTING_ACCOUNT_DERIVATION' );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed posting_account_derivation', NULL, NULL, NULL, NULL);
        insert into stn.cev_data
        with
          ce_data
          as (
          select
                           ipr.policy_id
                         , ipr.policy_abbr_nm
                         , ipr.stream_id
                         , 1                                    vie_id
                         , 1                                    vie_cd
                         , ipr.vie_effective_dt
                         , ipr.vie_acct_dt
                         , ipr.ledger_entity_cd                 le_cd
                         , ipr.is_mark_to_market
                         , ipr.policy_premium_typ
                         , ipr.policy_accident_yr
                         , ipr.policy_underwriting_yr
                         , ipr.policy_typ
                         , ipr.parent_stream_id
                         , pipr.ledger_entity_cd                parent_cession_le_cd
                         , ipr.ultimate_parent_stream_id
                         , upipr.le_cd                          ultimate_parent_le_cd
                         , ipr.execution_typ
                         , ipr.le_cd                            owner_le_cd
                         , pipr.le_cd                           counterparty_le_cd
                      from
                                stn.insurance_policy_reference  ipr
                      left join stn.insurance_policy_reference  pipr  on ipr.parent_stream_id          = pipr.stream_id
                      left join stn.insurance_policy_reference  upipr on ipr.ultimate_parent_stream_id = upipr.stream_id
             )
           , cev_ex_in
          as (
                 select
                        feed_uuid
                      , correlation_uuid
                      , event_id
                      , row_sid
                      , basis_cd
                      , accounting_dt
                      , event_typ
                      , business_event_typ
                      , policy_id
                      , policy_abbr_nm
                      , stream_id
                      , parent_stream_id
                      , vie_id
                      , vie_cd
                      , vie_effective_dt
                      , vie_acct_dt
                      , is_mark_to_market
                      , premium_typ
                      , policy_premium_typ
                      , policy_accident_yr
                      , policy_underwriting_yr
                      , ultimate_parent_stream_id
                      , ultimate_parent_le_cd
                      , execution_typ
                      , policy_typ
                      , business_typ
                      , le_cd
                      , parent_cession_le_cd
                      , owner_le_cd
                      , counterparty_le_cd
                      , transaction_amt
                      , transaction_ccy
                      , functional_amt
                      , functional_ccy
                      , reporting_amt
                      , reporting_ccy
                      , lpg_id
                   from (
                            select
                                   cev.feed_uuid
                                 , cev.correlation_uuid
                                 , cev.event_id
                                 , cev.row_sid
                                 , cev.basis_cd
                                 , cev.accounting_dt
                                 , cev.event_typ
                                 , cev.business_event_typ
                                 , ce_data.policy_id
                                 , ce_data.policy_abbr_nm
                                 , cev.stream_id
                                 , ce_data.parent_stream_id
                                 , ce_data.vie_id
                                 , ce_data.vie_cd
                                 , ce_data.vie_effective_dt
                                 , ce_data.vie_acct_dt
                                 , ce_data.is_mark_to_market
                                 , ce_data.policy_premium_typ
                                 , ce_data.policy_underwriting_yr
                                 , ce_data.policy_accident_yr
                                 , ce_data.ultimate_parent_stream_id
                                 , ce_data.ultimate_parent_le_cd
                                 , ce_data.execution_typ
                                 , ce_data.policy_typ
                                 , cev.business_typ
                                 , case
                                        when cev.premium_typ = 'X'
                                        then ppt.cession_event_premium_typ
                                        else cev.premium_typ
                                   end                                          premium_typ
                                 , case
                                        when ce_data.le_cd = 'FSAUK'
                                         and cev.event_typ like 'PGAAP%'
                                        then 'FSANY'
                                        when cev.event_typ = 'DAC_CC_CONS_ADJUST'
                                        then 'CA005'
                                        else ce_data.le_cd
                                   end                                          le_cd
                                 , ce_data.parent_cession_le_cd
                                 , ce_data.owner_le_cd
                                 , ce_data.counterparty_le_cd
                                 , cev.transaction_amt
                                 , cev.transaction_ccy
                                 , cev.functional_amt
                                 , cev.functional_ccy
                                 , cev.reporting_amt
                                 , cev.reporting_ccy
                                 , cev.lpg_id
                              from
                                        stn.cev_valid               cev
                                   join                             ce_data on cev.stream_id = ce_data.stream_id
                                   join stn.policy_premium_type     ppt     on ce_data.policy_premium_typ = ppt.premium_typ
                        )
                  )
           , cev_sum
          as (
          select
                    sum (cev_ex_in.transaction_amt) transaction_amt
                  , sum (cev_ex_in.functional_amt)  functional_amt
                  , sum (cev_ex_in.reporting_amt)   reporting_amt
                  , cev_ex_in.feed_uuid
                  , cev_ex_in.correlation_uuid
                  , cev_ex_in.accounting_dt
                  , cev_ex_in.stream_id
                  , cev_ex_in.event_typ
                  , cev_ex_in.business_typ
                  , cev_ex_in.basis_cd
            from
                    cev_ex_in
            group by
                    cev_ex_in.feed_uuid
                  , cev_ex_in.correlation_uuid
                  , cev_ex_in.accounting_dt
                  , cev_ex_in.stream_id
                  , cev_ex_in.event_typ
                  , cev_ex_in.business_typ
                  , cev_ex_in.basis_cd
             )
                 select
                        gaap_fut_accts_flag
                      , derived_plus_flag
                      , le_flag
                      , business_type_association_id
                      , intercompany_association_id
                      , derived_plus_association_id
                      , gaap_fut_accts_association_id
                      , basis_association_id
                      , correlation_uuid
                      , event_seq_id
                      , row_sid
                      , basis_id                           input_basis_id
                      , basis_cd                           input_basis_cd
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
                      , vie_effective_dt
                      , vie_acct_dt
                      , is_mark_to_market
                      , premium_typ
                      , policy_premium_typ
                      , policy_accident_yr
                      , policy_underwriting_yr
                      , ultimate_parent_stream_id
                      , ultimate_parent_le_cd
                      , execution_typ
                      , policy_typ
                      , business_typ
                      , generate_interco_accounting
                      , business_unit
                      , affiliate
                      , owner_le_cd
                      , counterparty_le_cd
                      , transaction_amt      input_transaction_amt
                      , nvl
                            (
                                coalesce ( lag  ( basis_transaction_amt ) over ( partition by business_type_association_id order by basis_cd )
                                         , lead ( basis_transaction_amt ) over ( partition by business_type_association_id order by basis_cd ) )
                              , 0
                            )                partner_transaction_amt
                      , nvl
                            (
                                coalesce ( lag  ( transaction_amt ) over ( partition by derived_plus_association_id order by basis_cd )
                                         , lead ( transaction_amt ) over ( partition by derived_plus_association_id order by basis_cd ) )
                              , 0
                            )                dp_partner_transaction_amt
                      , transaction_ccy
                      , functional_amt       input_functional_amt
                      , nvl
                            (
                                coalesce ( lag  ( basis_functional_amt ) over ( partition by business_type_association_id order by basis_cd )
                                         , lead ( basis_functional_amt ) over ( partition by business_type_association_id order by basis_cd ) )
                              , 0
                            )                partner_functional_amt
                      , nvl
                            (
                                coalesce ( lag  ( functional_amt ) over ( partition by derived_plus_association_id order by basis_cd )
                                         , lead ( functional_amt ) over ( partition by derived_plus_association_id order by basis_cd ) )
                              , 0
                            )                dp_partner_functional_amt
                      , functional_ccy
                      , reporting_amt        input_reporting_amt
                      , nvl
                            (
                                coalesce ( lag  ( basis_reporting_amt ) over ( partition by business_type_association_id order by basis_cd )
                                         , lead ( basis_reporting_amt ) over ( partition by business_type_association_id order by basis_cd ) )
                              , 0
                            )                partner_reporting_amt
                      , nvl
                            (
                                coalesce ( lag  ( reporting_amt ) over ( partition by derived_plus_association_id order by basis_cd )
                                         , lead ( reporting_amt ) over ( partition by derived_plus_association_id order by basis_cd ) )
                              , 0
                            )                dp_partner_reporting_amt
                      , reporting_ccy
                      , lpg_id
                   from (
                            select /*+ parallel(8)*/
                                   nvl( gfa.gaap_fut_accts_flag , 'N' )                                    gaap_fut_accts_flag
                                 , case when psadt.amount_typ_descr = 'DERIVED_PLUS' then 'Y' else 'N' end derived_plus_flag
                                 , nvl2( pmdl.le_cd , 'Y' , 'N' )                                          le_flag
                                 , rank () over ( order by
                                                           cev.feed_uuid
                                                         , cev.correlation_uuid
                                                         , cev.accounting_dt
                                                         , cev.stream_id
                                                         , cev.event_typ
                                                         , cev.business_typ
                                                         , abasis.basis_grp )          business_type_association_id
                                 , rank () over ( order by
                                                           cev.feed_uuid
                                                         , cev.correlation_uuid
                                                         , cev.accounting_dt
                                                         , cev.stream_id
                                                         , cev.event_typ
                                                         , abasis.basis_grp )             intercompany_association_id
                                 , rank () over ( order by
                                                           cev.feed_uuid
                                                         , cev.correlation_uuid
                                                         , cev.accounting_dt
                                                         , cev.basis_cd
                                                         , cev.stream_id
                                                         , cev.premium_typ
                                                         , case
                                                            when cev.event_typ in ('UPR','UPR_INITIAL','UPR_CHANGE')
                                                            then 1
                                                            when cev.event_typ in ('PGAAP_UPR','PGAAP_UPR_INITIAL','PGAAP_UPR_CHANGE')
                                                            then 2
                                                            else 0
                                                           end
                                                         , cev.business_typ )          derived_plus_association_id
                                 , rank () over ( order by
                                                           cev.feed_uuid
                                                         , cev.correlation_uuid
                                                         , cev.accounting_dt
                                                         , cev.stream_id
                                                         , cev.event_typ
                                                         , cev.business_typ
                                                         , abasis.basis_grp )          gaap_fut_accts_association_id
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
                                 , case
                                        when cev.basis_cd = 'US_GAAP'
                                        then 'US_STAT'
                                        when cev.basis_cd = 'US_STAT'
                                        then 'US_GAAP'
                                        else null
                                   end                                                 partner_basis_cd
                                 , abasis.basis_id
                                 , cev.accounting_dt
                                 , coalesce ( gfaout.event_typ    , etout.event_typ    , cev.event_typ )     event_typ
                                 , coalesce ( gfaout.event_typ_id , etout.event_typ_id , et.event_typ_id )   event_typ_id
                                 , cev.business_event_typ
                                 , cev.policy_id
                                 , cev.policy_abbr_nm
                                 , cev.stream_id
                                 , cev.parent_stream_id
                                 , cev.vie_id
                                 , cev.vie_cd
                                 , cev.vie_effective_dt
                                 , cev.vie_acct_dt
                                 , cev.is_mark_to_market
                                 , cev.policy_premium_typ
                                 , case
                                       when ehr.event_class = 'LOSSES'
                                       then cev.policy_accident_yr
                                       else null
                                   end                                                       policy_accident_yr
                                 , cev.policy_underwriting_yr
                                 , cev.ultimate_parent_stream_id
                                 , cev.ultimate_parent_le_cd
                                 , cev.execution_typ
                                 , cev.policy_typ
                                 , cev.business_typ
                                 , cev.premium_typ
                                 , bt.generate_interco_accounting
                                 , case
                                       when bt.bu_derivation_method = 'CESSION'
                                       then cev.le_cd
                                       when bt.bu_derivation_method = 'PARENT_CESSION'
                                       then cev.parent_cession_le_cd
                                       else null
                                   end                                                       business_unit
                                 , case
                                       when bt.afflte_derivation_method = 'CESSION'
                                       then cev.le_cd
                                       when bt.afflte_derivation_method = 'PARENT_CESSION'
                                       then cev.parent_cession_le_cd
                                       else null
                                   end                                                       affiliate
                                 , case
                                       when bt.owner_derivation_method = 'CESSION'
                                       then cev.owner_le_cd
                                       when bt.owner_derivation_method = 'PARENT_CESSION'
                                       then cev.counterparty_le_cd
                                       else null
                                   end                                                       owner_le_cd
                                 , case
                                       when bt.cparty_derivation_method = 'CESSION'
                                       then cev.owner_le_cd
                                       when bt.cparty_derivation_method = 'PARENT_CESSION'
                                       then cev.counterparty_le_cd
                                       else null
                                   end                                                       counterparty_le_cd
                                 , cev.transaction_amt * psanf.negate_flag_in                transaction_amt
                                 , cev_sum.transaction_amt * psanf.negate_flag_in            basis_transaction_amt
                                 , cev.transaction_ccy
                                 , cev.functional_amt * psanf.negate_flag_in                 functional_amt
                                 , cev_sum.functional_amt * psanf.negate_flag_in             basis_functional_amt
                                 , cev.functional_ccy
                                 , cev.reporting_amt * psanf.negate_flag_in                  reporting_amt
                                 , cev_sum.reporting_amt * psanf.negate_flag_in              basis_reporting_amt
                                 , cev.reporting_ccy
                                 , cev.lpg_id
                              from
                                        cev_ex_in                        cev
                                   join stn.event_type                   et      on cev.event_typ              = et.event_typ
                              left join stn.event_hierarchy_reference    ehr     on cev.event_typ              = ehr.event_typ
                                   join stn.posting_accounting_basis     abasis  on cev.basis_cd               = abasis.basis_cd
                                   join stn.business_type                bt      on cev.business_typ           = bt.business_typ
                              left join stn.posting_method_derivation_et psmdet  on et.event_typ_id            = psmdet.input_event_typ_id
                              left join stn.event_type                   etout   on psmdet.output_event_typ_id = etout.event_typ_id
                                   join cev_sum                                  on (
                                                                                    cev.feed_uuid        = cev_sum.feed_uuid
                                                                                and cev.correlation_uuid = cev_sum.correlation_uuid
                                                                                and cev.accounting_dt    = cev_sum.accounting_dt
                                                                                and cev.stream_id        = cev_sum.stream_id
                                                                                and cev.event_typ        = cev_sum.event_typ
                                                                                and cev.business_typ     = cev_sum.business_typ
                                                                                and cev.basis_cd         = cev_sum.basis_cd
                                                                                    )
        
                            left join stn.posting_method_derivation_gfa  gfa    on et.event_typ_id      = gfa.event_typ_in
                                                                               and exists (
                                                                                            select null
                                                                                              from stn.cev_valid     cev2
                                                                                              join stn.event_type    et2
                                                                                                on cev2.event_typ = et2.event_typ
                                                                                              join stn.posting_method_derivation_gfa gfa2
                                                                                                on et2.event_typ_id = gfa2.event_typ_qualifier
                                                                                             where cev2.correlation_uuid = cev.correlation_uuid
                                                                                          )
                            left join stn.event_type                     gfaout on gfa.event_typ_out    = gfaout.event_typ_id
                                 join stn.posting_amount_derivation      psad   on et.event_typ_id      = psad.event_typ_id
                                 join stn.posting_amount_derivation_type psadt  on psad.amount_typ_id   = psadt.amount_typ_id
                                 join stn.posting_amount_negate_flag     psanf  on psadt.amount_typ_id  = psanf.amount_typ_id
                                                                               and cev.business_typ     = psanf.business_typ
                            left join stn.posting_method_derivation_le   pmdl   on (case
                                                                                     when bt.bu_derivation_method = 'CESSION'
                                                                                     then cev.le_cd
                                                                                     when bt.bu_derivation_method = 'PARENT_CESSION'
                                                                                     then cev.parent_cession_le_cd
                                                                                    else null
                                                                                    end  ) = pmdl.le_cd
                        )
              ;
        
        v_no_cev_data := sql%rowcount;
        
        --dbms_stats.gather_table_stats ( ownname => 'STN', tabname => 'CEV_DATA' );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cev_data', 'v_no_cev_data', NULL, v_no_cev_data, NULL);
        insert into stn.cev_premium_typ_override
                select distinct
                    cev_data.correlation_uuid
                  , cev_data.event_typ_id
                  , 'M'      premium_typ_override
                from stn.cev_data                       cev_data
                join stn.posting_method_derivation_gfa  gfa
                on (
                    cev_data.event_typ_id = gfa.event_typ_in
                and exists (
                             select null
                               from stn.cev_data        cev2
                              where cev2.event_typ_id      = gfa.event_typ_qualifier
                                and cev2.correlation_uuid  = cev_data.correlation_uuid
                                and cev_data.premium_typ   = 'U'
                           )
                and exists (
                             select null
                               from stn.cev_data        cev3
                              where cev3.correlation_uuid = cev_data.correlation_uuid
                                and cev3.premium_typ     in ( 'M' , 'I' )
                           )
                   )
        ;
        
        --dbms_stats.gather_table_stats ( ownname => 'STN', tabname => 'CEV_PREMIUM_TYP_OVERRIDE' );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cev_premium_typ_override', NULL, NULL, NULL, NULL);
        insert into stn.cev_mtm_data
                 select /*+ parallel*/
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
                      , cev_data.vie_effective_dt
                      , cev_data.vie_acct_dt
                      , cev_data.premium_typ
                      , cev_data.policy_premium_typ
                      , cev_data.policy_accident_yr
                      , cev_data.policy_underwriting_yr
                      , cev_data.ultimate_parent_stream_id
                      , cev_data.ultimate_parent_le_cd
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
                             stn.cev_data                       cev_data
                   left join stn.cev_premium_typ_override       cevpto   on cev_data.correlation_uuid = cevpto.correlation_uuid
                                                                        and cev_data.event_typ_id     = cevpto.event_typ_id
                        join stn.posting_method_derivation_mtm  psmtm    on (
                                                                               cev_data.event_typ_id      = psmtm.event_typ_id
                                                                           and cev_data.is_mark_to_market = psmtm.is_mark_to_market
                                                                           and coalesce( cevpto.premium_typ_override
                                                                                       , cev_data.premium_typ ) = psmtm.premium_typ
                                                                           and cev_data.input_basis_id    = psmtm.basis_id
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
                                                                             and ( decode ( cev_data.business_unit
                                                                                          , 'AGFPI' , 'AGFPI'
                                                                                          , 'NULL' )          = pacd.business_unit
                                                                                or pacd.business_unit         = 'ND~' )
                                                                            )
                   left join stn.cev_period_balances            pb       on (
                                                                                   cev_data.stream_id                           = pb.stream_id
                                                                               and cev_data.business_unit                       = pb.business_unit
                                                                               and pacd.sub_account                             = pb.sub_account
                                                                               and cev_data.transaction_ccy                     = pb.currency
                                                                               and cev_data.premium_typ                         = pb.premium_typ
                                                                               and cev_data.input_basis_cd                      = pb.basis_cd
                                                                               and cev_data.event_typ                           = pb.event_typ
                                                                               and extract( month from ( add_months ( cev_data.accounting_dt , -1 ) ) ) = pb.period_month
                                                                               and extract( year from ( add_months ( cev_data.accounting_dt , -1 ) ) )  = pb.period_year
                                                                            )
                  where cev_data.gaap_fut_accts_flag = 'N'
                    and cev_data.derived_plus_flag   = 'N'
                    and cev_data.le_flag             = 'N'
        ;
        
        v_no_cev_mtm_data := sql%rowcount;
        
        --dbms_stats.gather_table_stats ( ownname => 'STN' , tabname => 'CEV_MTM_DATA' );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cev_mtm_data', 'v_no_cev_mtm_data', NULL, v_no_cev_mtm_data, NULL);
        insert into stn.cev_gaap_fut_accts_data
        with gfa_1 as
               (          select
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
                              , cev_data.vie_effective_dt
                              , cev_data.vie_acct_dt
                              , case
                                    when (
                                        exists (select null
                                                    from stn.cev_data cvd2
                                                    where cvd2.premium_typ = 'U'
                                                    and cvd2.correlation_uuid = cev_data.correlation_uuid
                                                    and cev_data.event_typ = 'WP_FUT_TO_CUR'
                                                )
                                    and exists (select null
                                                    from stn.cev_data cvd2
                                                    where cvd2.premium_typ = 'I'
                                                    and cvd2.correlation_uuid = cev_data.correlation_uuid
                                                    and cev_data.event_typ = 'WP_FUT_TO_CUR'
                                                )
                                         )
                                    then 'M'
                                    when (
                                        exists (select null
                                                    from stn.cev_data cvd2
                                                    where cvd2.premium_typ = 'U'
                                                    and cvd2.correlation_uuid = cev_data.correlation_uuid
                                                    and cev_data.event_typ = 'CC_FUT_TO_CUR'
                                                )
                                    and exists (select null
                                                    from stn.cev_data cvd2
                                                    where cvd2.premium_typ = 'I'
                                                    and cvd2.correlation_uuid = cev_data.correlation_uuid
                                                    and cev_data.event_typ = 'CC_FUT_TO_CUR'
                                                )
                                         )
                                    then 'M'
                                else cev_data.premium_typ
                                end premium_typ
                              , cev_data.policy_premium_typ
                              , cev_data.policy_accident_yr
                              , cev_data.policy_underwriting_yr
                              , cev_data.ultimate_parent_stream_id
                              , cev_data.ultimate_parent_le_cd
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
                              , 0  partner_transaction_amt
                              , cev_data.functional_ccy
                              , cev_data.input_functional_amt
                              , 0 partner_functional_amt
                              , cev_data.reporting_ccy
                              , cev_data.input_reporting_amt
                              , 0 partner_reporting_amt
                              , cev_data.lpg_id
                           from
                                     stn.cev_data                      cev_data
                                join stn.posting_method                psm      on ( psm.psm_cd = 'GAAP_FUT_ACCTS'
                                                                                 or  psm.psm_cd = 'GAAP_TO_CORE' )
                                join stn.posting_method_ledger         pml      on (
                                                                                           psm.psm_id            = pml.psm_id
                                                                                       and cev_data.input_basis_id = pml.input_basis_id
                                                                                   )
                                join stn.posting_ledger                pldgr    on pml.ledger_id       = pldgr.ledger_id
                                join stn.posting_accounting_basis      abasis   on pml.output_basis_id = abasis.basis_id
                                join stn.posting_financial_calc        fincalc  on pml.fin_calc_id     = fincalc.fin_calc_id
                          where cev_data.gaap_fut_accts_flag = 'Y'
                            and cev_data.derived_plus_flag   = 'N'
                            and exists (
                                         select null
                                           from cev_data                cev3
                                          where cev3.correlation_uuid = cev_data.correlation_uuid
                                            and cev3.premium_typ      in ( 'M' , 'I' )
                                       )
                            --and cev_data.le_flag             = 'N'
               )
               select psm_cd
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
                    , vie_effective_dt
                    , vie_acct_dt
                    , premium_typ
                    , policy_premium_typ
                    , policy_accident_yr
                    , policy_underwriting_yr
                    , ultimate_parent_stream_id
                    , ultimate_parent_le_cd
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
                    , sum (input_transaction_amt) input_transaction_amt
                    , partner_transaction_amt
                    , functional_ccy
                    , sum (input_functional_amt)  input_functional_amt
                    , partner_functional_amt
                    , reporting_ccy
                    , sum (input_reporting_amt)   input_reporting_amt
                    , partner_reporting_amt
                    , lpg_id
                 from
                      gfa_1
             group by
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
                    , vie_effective_dt
                    , vie_acct_dt
                    , premium_typ
                    , policy_premium_typ
                    , policy_accident_yr
                    , policy_underwriting_yr
                    , ultimate_parent_stream_id
                    , ultimate_parent_le_cd
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
                    , partner_transaction_amt
                    , functional_ccy
                    , partner_functional_amt
                    , reporting_ccy
                    , partner_reporting_amt
                    , lpg_id
        ;
        
        v_no_cev_gaap_fut_accts_data := sql%rowcount;
        
        --dbms_stats.gather_table_stats ( ownname => 'STN', tabname => 'CEV_GAAP_FUT_ACCTS_DATA' );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cev_gaap_fut_accts_data', 'v_no_cev_gaap_fut_accts_data', NULL, v_no_cev_gaap_fut_accts_data, NULL);
insert into stn.cev_derived_plus_data
select /*+ parallel */
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
     , cev_data.vie_effective_dt
     , cev_data.vie_acct_dt
     , cev_data.premium_typ
     , cev_data.policy_premium_typ
     , cev_data.policy_accident_yr
     , cev_data.policy_underwriting_yr
     , cev_data.ultimate_parent_stream_id
     , cev_data.ultimate_parent_le_cd
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
     , ( cev_data.input_transaction_amt
       - nvl( ( cev_data.dp_partner_transaction_amt * psanf.negate_flag_in ) , 0 )
       - nvl( pb.transaction_balance , 0 ) )                                            input_transaction_amt
     , nvl( pb.transaction_balance , 0 )                                                transaction_balance
     , 0                                                                                partner_transaction_amt
     , ( cev_data.dp_partner_transaction_amt * psanf.negate_flag_in )                   dp_partner_transaction_amt
     , cev_data.functional_ccy
     , ( cev_data.input_functional_amt
       - nvl( ( cev_data.dp_partner_functional_amt * psanf.negate_flag_in ) , 0 )
       - nvl( pb.functional_balance , 0 ) )                                             input_functional_amt
     , nvl( pb.functional_balance , 0 )                                                 functional_balance
     , 0                                                                                partner_functional_amt
     , ( cev_data.dp_partner_functional_amt * psanf.negate_flag_in )                    dp_partner_functional_amt
     , cev_data.reporting_ccy
     , ( cev_data.input_reporting_amt
       - nvl( ( cev_data.dp_partner_reporting_amt * psanf.negate_flag_in ) , 0 )
       - nvl( pb.reporting_balance , 0 ) )                                              input_reporting_amt
     , nvl( pb.reporting_balance , 0 )                                                  reporting_balance
     , 0                                                                                partner_reporting_amt
     , ( cev_data.dp_partner_reporting_amt * psanf.negate_flag_in )                     dp_partner_reporting_amt
     , cev_data.lpg_id
  from
            stn.cev_data                       cev_data
  left join stn.posting_method_derivation_le   pmdl     on cev_data.business_unit = pmdl.le_cd
       join stn.posting_method_derivation_mtm  psmtm    on (
                                                                cev_data.event_typ_id      = psmtm.event_typ_id
                                                            and cev_data.is_mark_to_market = psmtm.is_mark_to_market
                                                            and cev_data.premium_typ       = psmtm.premium_typ
                                                            and cev_data.input_basis_id    = psmtm.basis_id
                                                           )
       join stn.posting_method_ledger          pml      on (
                                                                coalesce( pmdl.psm_id , psmtm.psm_id )   = pml.psm_id
                                                            and cev_data.input_basis_id                  = pml.input_basis_id
                                                           )
       join stn.posting_method                 psm      on coalesce( pmdl.psm_id , psmtm.psm_id )        = psm.psm_id
       join stn.posting_ledger                 pldgr    on pml.ledger_id                                 = pldgr.ledger_id
       join stn.posting_accounting_basis       abasis   on pml.output_basis_id                           = abasis.basis_id
       join stn.posting_financial_calc         fincalc  on pml.fin_calc_id                               = fincalc.fin_calc_id
       join stn.posting_amount_derivation      pad      on cev_data.event_typ_id                         = pad.event_typ_id
       join stn.posting_amount_derivation_type padt     on pad.amount_typ_id                             = padt.amount_typ_id
       join stn.posting_amount_negate_flag     psanf    on padt.amount_typ_id                            = psanf.amount_typ_id
                                                       and cev_data.business_typ                         = psanf.business_typ
  left join stn.posting_account_derivation     pacd     on (
                                                                  pldgr.ledger_cd                 = pacd.posting_schema
                                                            and   cev_data.event_typ              = pacd.event_typ
                                                            and   pml.sub_event                   = pacd.sub_event
                                                            and ( cev_data.business_typ           = pacd.business_typ
                                                               or pacd.business_typ               = 'ND~' )
                                                            and ( cev_data.is_mark_to_market      = pacd.is_mark_to_market
                                                               or pacd.is_mark_to_market          = 'ND~' )
                                                            and ( decode ( cev_data.business_unit
                                                                         , 'AGFPI' , 'AGFPI'
                                                                         , 'NULL' )               = pacd.business_unit
                                                               or pacd.business_unit              = 'ND~' )
                                                           )
  left join stn.cev_period_balances            pb       on (
                                                                cev_data.stream_id                = pb.stream_id
                                                            and cev_data.business_unit            = pb.business_unit
                                                            and pacd.sub_account                  = pb.sub_account
                                                            and cev_data.transaction_ccy          = pb.currency
                                                            and cev_data.premium_typ              = pb.premium_typ
                                                            and cev_data.input_basis_cd           = pb.basis_cd
                                                            and cev_data.event_typ                = pb.event_typ
                                                            and extract( month from ( add_months ( cev_data.accounting_dt , -1 ) ) ) = pb.period_month
                                                            and extract( year from ( add_months ( cev_data.accounting_dt , -1 ) ) )  = pb.period_year
                                                           )
 where cev_data.gaap_fut_accts_flag = 'N'
   and cev_data.derived_plus_flag   = 'Y'
       ;
       
       v_no_cev_derived_plus_data := sql%rowcount;
       
merge into
      stn.cev_derived_plus_data cdpd
using (
        select
               pamt.correlation_uuid
             , pamt.business_type_association_id
             , pamt.stream_id
             , pamt.basis_cd
             , pamt.event_typ
             , pamt.sub_event
             , pamt.premium_typ
             , pamt.business_typ
             , pamt.business_unit
             , nvl(
                      coalesce (
                                 lag  ( pamt.input_transaction_amt ) over ( partition by pamt.business_type_association_id order by pamt.basis_cd )
                               , lead ( pamt.input_transaction_amt ) over ( partition by pamt.business_type_association_id order by pamt.basis_cd )
                               )
                    , 0
                  )                                           partner_transaction_amt
             , nvl(
                      coalesce (
                                 lag  ( pamt.input_functional_amt ) over ( partition by pamt.business_type_association_id order by pamt.basis_cd )
                               , lead ( pamt.input_functional_amt ) over ( partition by pamt.business_type_association_id order by pamt.basis_cd )
                               )
                    , 0
                  )                                           partner_functional_amt
             , nvl(
                      coalesce (
                                 lag  ( pamt.input_reporting_amt ) over ( partition by pamt.business_type_association_id order by pamt.basis_cd )
                               , lead ( pamt.input_reporting_amt ) over ( partition by pamt.business_type_association_id order by pamt.basis_cd )
                               )
                    , 0
                  )                                           partner_reporting_amt
          from
               stn.cev_derived_plus_data  pamt
      ) partner_amount
    on (
            cdpd.correlation_uuid = partner_amount.correlation_uuid
        and cdpd.stream_id        = partner_amount.stream_id
        and cdpd.basis_cd         = partner_amount.basis_cd
        and cdpd.event_typ        = partner_amount.event_typ
        and cdpd.sub_event        = partner_amount.sub_event
        and cdpd.premium_typ      = partner_amount.premium_typ
        and cdpd.business_typ     = partner_amount.business_typ
        and cdpd.fin_calc_cd      = 'INPUT_MINUS_PARTNER'
       )
  when matched then update
   set
       cdpd.partner_transaction_amt = partner_amount.partner_transaction_amt
     , cdpd.partner_functional_amt  = partner_amount.partner_functional_amt
     , cdpd.partner_reporting_amt   = partner_amount.partner_reporting_amt
;

merge into
      stn.cev_derived_plus_data cdpd
using (
        with dp_mixed_amount as
        (
        select
               dp_mixed_amt.correlation_uuid
             , dp_mixed_amt.business_type_association_id
             , dp_mixed_amt.stream_id
             , dp_mixed_amt.basis_cd
             , dp_mixed_amt.event_typ
             , dp_mixed_amt.sub_event
             , 'M'                                          premium_typ
             , dp_mixed_amt.business_typ
             , dp_mixed_amt.business_unit
             , sum(dp_mixed_amt.input_transaction_amt)    input_transaction_amt
             , sum(dp_mixed_amt.input_functional_amt)     input_functional_amt
             , sum(dp_mixed_amt.input_reporting_amt)      input_reporting_amt
          from
               stn.cev_derived_plus_data      dp_mixed_amt
         group by
               dp_mixed_amt.correlation_uuid
             , dp_mixed_amt.business_type_association_id
             , dp_mixed_amt.stream_id
             , dp_mixed_amt.basis_cd
             , dp_mixed_amt.event_typ
             , dp_mixed_amt.sub_event
             , dp_mixed_amt.business_typ
             , dp_mixed_amt.business_unit
        )
        select
               dpmx.correlation_uuid
             , dpmx.business_type_association_id
             , dpmx.stream_id
             , dpmx.basis_cd
             , dpmx.event_typ
             , dpmx.sub_event
             , dpmx.premium_typ
             , dpmx.business_typ
             , dpmx.business_unit
             , nvl(
                      coalesce (
                                 lag  ( dpmx.input_transaction_amt ) over ( partition by dpmx.business_type_association_id order by dpmx.basis_cd )
                               , lead ( dpmx.input_transaction_amt ) over ( partition by dpmx.business_type_association_id order by dpmx.basis_cd )
                               )
                    , 0
                  )                                           partner_transaction_amt
             , nvl(
                      coalesce (
                                 lag  ( dpmx.input_functional_amt ) over ( partition by dpmx.business_type_association_id order by dpmx.basis_cd )
                               , lead ( dpmx.input_functional_amt ) over ( partition by dpmx.business_type_association_id order by dpmx.basis_cd )
                               )
                    , 0
                  )                                           partner_functional_amt
             , nvl(
                      coalesce (
                                 lag  ( dpmx.input_reporting_amt ) over ( partition by dpmx.business_type_association_id order by dpmx.basis_cd )
                               , lead ( dpmx.input_reporting_amt ) over ( partition by dpmx.business_type_association_id order by dpmx.basis_cd )
                               )
                    , 0
                  )                                           partner_reporting_amt
          from
               dp_mixed_amount  dpmx
      ) partner_mixed_amount
    on (
            cdpd.correlation_uuid = partner_mixed_amount.correlation_uuid
        and cdpd.stream_id        = partner_mixed_amount.stream_id
        and cdpd.basis_cd         = partner_mixed_amount.basis_cd
        and cdpd.event_typ        = partner_mixed_amount.event_typ
        and cdpd.sub_event        = partner_mixed_amount.sub_event
        and cdpd.premium_typ      = partner_mixed_amount.premium_typ
        and cdpd.business_typ     = partner_mixed_amount.business_typ
        and cdpd.fin_calc_cd      = 'INPUT_MINUS_PARTNER'
       )
  when matched then update
   set
       cdpd.partner_transaction_amt = partner_mixed_amount.partner_transaction_amt
     , cdpd.partner_functional_amt  = partner_mixed_amount.partner_functional_amt
     , cdpd.partner_reporting_amt   = partner_mixed_amount.partner_reporting_amt
;
       
        --dbms_stats.gather_table_stats ( ownname => 'STN', tabname => 'CEV_DERIVED_PLUS_DATA' );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cev_derived_plus_data', 'v_no_cev_derived_plus_data', NULL, v_no_cev_derived_plus_data, NULL);
        insert into stn.cev_le_data
        (
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
                      , cev_data.vie_effective_dt
                      , cev_data.vie_acct_dt
                      , cev_data.premium_typ
                      , cev_data.policy_premium_typ
                      , cev_data.policy_accident_yr
                      , cev_data.policy_underwriting_yr
                      , cev_data.ultimate_parent_stream_id
                      , cev_data.ultimate_parent_le_cd
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
                             stn.cev_data                     cev_data
                        join stn.posting_method_derivation_le psml      on cev_data.business_unit = psml.le_cd
                        join stn.posting_method_ledger        pml       on (
                                                                                   psml.psm_id             = pml.psm_id
                                                                               and cev_data.input_basis_id = pml.input_basis_id
                                                                           )
                        join stn.posting_method               psm       on psml.psm_id         = psm.psm_id
                        join stn.posting_ledger               pldgr     on pml.ledger_id       = pldgr.ledger_id
                        join stn.posting_accounting_basis     abasis    on pml.output_basis_id = abasis.basis_id
                        join stn.posting_financial_calc       fincalc   on pml.fin_calc_id     = fincalc.fin_calc_id
                        join stn.posting_amount_derivation      pad      on cev_data.event_typ_id = pad.event_typ_id
                        join stn.posting_amount_derivation_type padt     on pad.amount_typ_id     = padt.amount_typ_id
                  where cev_data.le_flag             = 'Y'
                    and padt.amount_typ_descr not in ('DERIVED_PLUS')
                    )
        ;
        
        v_no_cev_le_data := sql%rowcount;
        
        --dbms_stats.gather_table_stats ( ownname => 'STN', tabname => 'CEV_LE_DATA' );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cev_le_data', 'v_no_cev_le_data', NULL, v_no_cev_le_data, NULL);
        insert into stn.cev_non_intercompany_data
        with amount_derivation
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
                      , vie_effective_dt
                      , vie_acct_dt
                      , premium_typ
                      , policy_premium_typ
                      , policy_accident_yr
                      , policy_underwriting_yr
                      , ultimate_parent_stream_id
                      , ultimate_parent_le_cd
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
                                    , vie_effective_dt
                                    , vie_acct_dt
                                    , premium_typ
                                    , policy_premium_typ
                                    , policy_accident_yr
                                    , policy_underwriting_yr
                                    , ultimate_parent_stream_id
                                    , ultimate_parent_le_cd
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
                                      stn.cev_mtm_data
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
                                    , vie_effective_dt
                                    , vie_acct_dt
                                    , premium_typ
                                    , policy_premium_typ
                                    , policy_accident_yr
                                    , policy_underwriting_yr
                                    , ultimate_parent_stream_id
                                    , ultimate_parent_le_cd
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
                                      stn.cev_le_data
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
                                    , vie_effective_dt
                                    , vie_acct_dt
                                    , premium_typ
                                    , policy_premium_typ
                                    , policy_accident_yr
                                    , policy_underwriting_yr
                                    , ultimate_parent_stream_id
                                    , ultimate_parent_le_cd
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
                                      stn.cev_gaap_fut_accts_data
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
                                    , vie_effective_dt
                                    , vie_acct_dt
                                    , premium_typ
                                    , policy_premium_typ
                                    , policy_accident_yr
                                    , policy_underwriting_yr
                                    , ultimate_parent_stream_id
                                    , ultimate_parent_le_cd
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
                                      stn.cev_derived_plus_data
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
                      , vie_effective_dt
                      , vie_acct_dt
                      , premium_typ
                      , policy_premium_typ
                      , policy_accident_yr
                      , policy_underwriting_yr
                      , ultimate_parent_stream_id
                      , ultimate_parent_le_cd
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
                                    , ad.vie_effective_dt
                                    , ad.vie_acct_dt
                                    , ad.premium_typ
                                    , ad.policy_premium_typ
                                    , ad.policy_accident_yr
                                    , ad.policy_underwriting_yr
                                    , ad.ultimate_parent_stream_id
                                    , ad.ultimate_parent_le_cd
                                    , ad.execution_typ
                                    , ad.policy_typ
                                    , case
                                           when ad.affiliate = 'AGFPI'
                                            and ad.business_typ = 'AA'
                                           then 'D'
                                           else ad.business_typ
                                      end business_typ
                                    , ad.generate_interco_accounting
                                    , ad.business_unit
                                    , ad.affiliate
                                    , ad.owner_le_cd
                                    , ad.counterparty_le_cd
                                    , pt.tax_jurisdiction_cd                                                                         tax_jurisdiction_cd
                                    , ad.transaction_ccy
                                    , ( ( ad.transaction_amt * nvl(pt.tax_jurisdiction_pct,100) ) / 100 ) * psanf.negate_flag_out    transaction_amt
                                    , ad.functional_ccy
                                    , ( ( ad.functional_amt * nvl(pt.tax_jurisdiction_pct,100) ) / 100 ) * psanf.negate_flag_out     functional_amt
                                    , ad.reporting_ccy
                                    , ( ( ad.reporting_amt * nvl(pt.tax_jurisdiction_pct,100) ) / 100 ) * psanf.negate_flag_out      reporting_amt
                                    , ad.lpg_id
                                 from
                                      amount_derivation                  ad
                                 join stn.event_type                     et     on ad.event_typ         = et.event_typ     
                                 join stn.posting_amount_derivation      psad   on et.event_typ_id      = psad.event_typ_id
                                 join stn.posting_amount_derivation_type psadt  on psad.amount_typ_id   = psadt.amount_typ_id
                                 join stn.posting_amount_negate_flag     psanf  on psadt.amount_typ_id  = psanf.amount_typ_id
                                                                               and ad.business_typ      = psanf.business_typ
                            left join stn.policy_tax                     pt     on ad.policy_id         = pt.policy_id
                        )
             )
        
                     select
                            posting_type
                          , business_type_association_id
                          , intercompany_association_id
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
                          , business_typ
                          , generate_interco_accounting
                          , premium_typ
                          , policy_premium_typ
                          , policy_accident_yr
                          , policy_underwriting_yr
                          , ultimate_parent_stream_id
                          , ultimate_parent_le_cd
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
                          , vie_effective_dt
                          , vie_acct_dt
                          , is_mark_to_market
                          , tax_jurisdiction_cd
                          , null                 chartfield_cd
                          , transaction_ccy
                          , transaction_amt
                          , functional_ccy
                          , functional_amt
                          , reporting_ccy
                          , reporting_amt
                          , lpg_id
                       from
                            non_intercompany_data
        ;
        
        v_no_cev_non_intercompany_data := sql%rowcount;
        
        --dbms_stats.gather_table_stats ( ownname => 'STN', tabname => 'CEV_NON_INTERCOMPANY_DATA' );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cev_non_intercompany_data', 'v_no_cev_non_intercompany_data', NULL, v_no_cev_non_intercompany_data, NULL);
        insert into stn.cev_intercompany_data
        with intercompany_data
          as (
                 select
                        'INTERCOMPANY_ELIMINATION'                              posting_type
                      , cevnid.generate_interco_accounting
                      , cevnid.business_type_association_id
                      , cevnid.intercompany_association_id
                      , cevnid.correlation_uuid
                      , cevnid.event_seq_id
                      , cevnid.row_sid
                      , cevnid.sub_event
                      , cevnid.accounting_dt
                      , cevnid.policy_id
                      , cevnid.policy_abbr_nm
                      , cevnid.stream_id
                      , cevnid.parent_stream_id
                      , cevnid.basis_cd
                      , cevnid.basis_typ
                      , pldgr.ledger_cd
                      , cevnid.event_typ
                      , cevnid.business_event_typ
                      , cevnid.is_mark_to_market
                      , cevnid.tax_jurisdiction_cd
                      , cevnid.vie_effective_dt
                      , cevnid.vie_acct_dt
                      , cevnid.vie_cd
                      , cevnid.premium_typ
                      , cevnid.policy_premium_typ
                      , cevnid.policy_accident_yr
                      , cevnid.policy_underwriting_yr
                      , cevnid.ultimate_parent_stream_id
                      , cevnid.ultimate_parent_le_cd
                      , cevnid.execution_typ
                      , cevnid.policy_typ
                      , case
                             when cevnid.affiliate = 'AGFPI'
                              and cevnid.business_typ = 'AA'
                             then 'D'
                             else cevnid.business_typ
                         end business_typ
                      , coalesce( psmre.reins_le_cd , ele.elimination_le_cd )   business_unit
                      , nvl2( psmre.reins_le_cd , null , cevnid.affiliate ) affiliate
                      , cevnid.owner_le_cd           --what should these be
                      , cevnid.counterparty_le_cd    --what should these be
                      , psmre.chartfield_cd
                      , cevnid.transaction_ccy
                      , cevnid.transaction_amt                             transaction_amt
                      , cevnid.functional_ccy
                      , cevnid.functional_amt                              functional_amt
                      , cevnid.reporting_ccy
                      , cevnid.reporting_amt                               reporting_amt
                      , cevnid.lpg_id
                   from
                             stn.cev_non_intercompany_data  cevnid
                        join stn.posting_accounting_basis   abasis on cevnid.basis_cd   = abasis.basis_cd
                        join stn.elimination_legal_entity   ele    on (
                                                                           cevnid.business_unit           = ele.le_1_cd
                                                                       and cevnid.affiliate               = ele.le_2_cd
                                                                       and abasis.basis_consolidation_typ = ele.legal_entity_link_typ
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
                                                              led    on ele.step_run_sid  = led.step_run_sid
                        join stn.posting_method_derivation_ic pdmic  on abasis.basis_id   = pdmic.basis_id
                        join stn.posting_method_ledger        pml    on (
                                                                                pdmic.psm_id   = pml.psm_id
                                                                            and pdmic.basis_id = pml.input_basis_id
                                                                        )
                        join stn.posting_ledger               pldgr  on pml.ledger_id = pldgr.ledger_id
                   left join stn.posting_method_derivation_rein psmre on (
                                                                                cevnid.business_unit           = psmre.le_1_cd
                                                                            and cevnid.affiliate               = psmre.le_2_cd
                                                                         )
                  where
                        cevnid.generate_interco_accounting = 'Y'
             )
           /*, balancing_intercompany_data
          as (
                 select
                        'BALANCING_INTERCOMPANY_ELIMINATION'          posting_type
                      , generate_interco_accounting
                      , business_type_association_id
                      , intercompany_association_id
                      , correlation_uuid
                      , event_seq_id
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
                      , tax_jurisdiction_cd
                      , vie_effective_dt
                      , vie_acct_dt
                      , vie_cd
                      , premium_typ
                      , policy_premium_typ
                      , policy_accident_yr
                      , policy_underwriting_yr
                      , ultimate_parent_stream_id
                      , ultimate_parent_le_cd
                      , execution_typ
                      , policy_typ
                      , null                                          business_typ
                      , business_unit
                      , null                                          affiliate
                      , owner_le_cd           --what should these be
                      , counterparty_le_cd    --what should these be
                      , chartfield_cd
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
                                   intercompany_data.generate_interco_accounting
                                 , intercompany_data.business_type_association_id
                                 , intercompany_data.intercompany_association_id
                                 , intercompany_data.correlation_uuid
                                 , intercompany_data.event_seq_id
                                 , intercompany_data.row_sid
                                 , intercompany_data.sub_event
                                 , intercompany_data.accounting_dt
                                 , intercompany_data.policy_id
                                 , intercompany_data.policy_abbr_nm
                                 , intercompany_data.stream_id
                                 , intercompany_data.parent_stream_id
                                 , intercompany_data.ultimate_parent_le_cd
                                 , intercompany_data.basis_cd
                                 , intercompany_data.basis_typ
                                 , intercompany_data.ledger_cd
                                 , intercompany_data.event_typ
                                 , intercompany_data.business_event_typ
                                 , intercompany_data.is_mark_to_market
                                 , intercompany_data.tax_jurisdiction_cd
                                 , intercompany_data.vie_effective_dt
                                 , intercompany_data.vie_acct_dt
                                 , intercompany_data.vie_cd
                                 , intercompany_data.premium_typ
                                 , intercompany_data.policy_premium_typ
                                 , intercompany_data.policy_accident_yr
                                 , intercompany_data.policy_underwriting_yr
                                 , intercompany_data.ultimate_parent_stream_id
                                 , intercompany_data.execution_typ
                                 , intercompany_data.policy_typ
                                 , intercompany_data.business_unit
                                 , intercompany_data.owner_le_cd           --what should these be
                                 , intercompany_data.counterparty_le_cd    --what should these be
                                 , intercompany_data.chartfield_cd
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
              )*/
                     select
                            posting_type
                          , business_type_association_id
                          , intercompany_association_id
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
                          , business_typ
                          , generate_interco_accounting
                          , premium_typ
                          , policy_premium_typ
                          , policy_accident_yr
                          , policy_underwriting_yr
                          , ultimate_parent_stream_id
                          , ultimate_parent_le_cd
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
                          , vie_effective_dt
                          , vie_acct_dt
                          , is_mark_to_market
                          , tax_jurisdiction_cd
                          , chartfield_cd
                          , transaction_ccy
                          , transaction_amt
                          , functional_ccy
                          , functional_amt
                          , reporting_ccy
                          , reporting_amt
                          , lpg_id
                       from
                            intercompany_data
                    /*union all
                     select
                            posting_type
                          , business_type_association_id
                          , intercompany_association_id
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
                          , business_typ
                          , generate_interco_accounting
                          , premium_typ
                          , policy_premium_typ
                          , policy_accident_yr
                          , policy_underwriting_yr
                          , ultimate_parent_stream_id
                          , ultimate_parent_le_cd
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
                          , vie_effective_dt
                          , vie_acct_dt
                          , is_mark_to_market
                          , tax_jurisdiction_cd
                          , chartfield_cd
                          , transaction_ccy
                          , transaction_amt
                          , functional_ccy
                          , functional_amt
                          , reporting_ccy
                          , reporting_amt
                          , lpg_id
                       from
                            balancing_intercompany_data*/
                       ;
        
        v_no_cev_intercompany_data := sql%rowcount;
        
        --dbms_stats.gather_table_stats ( ownname => 'STN', tabname => 'CEV_INTERCOMPANY_DATA' );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cev_intercompany_data', 'v_no_cev_intercompany_data', NULL, v_no_cev_intercompany_data, NULL);
        INSERT INTO HOPPER_CESSION_EVENT
            (BUSINESS_UNIT, AFFILIATE_LE_CD, ACCOUNTING_DT, ACCIDENT_YR, UNDERWRITING_YR, POLICY_ID, ULTIMATE_PARENT_LE_CD, TAX_JURISDICTION_CD, EVENT_TYP, TRANSACTION_CCY, TRANSACTION_AMT, BUSINESS_TYP, POLICY_TYP, PREMIUM_TYP, SUB_EVENT, IS_MARK_TO_MARKET, VIE_CD, LPG_ID, PARTY_BUSINESS_LE_CD, PARTY_BUSINESS_SYSTEM_CD, AAH_EVENT_TYP, SRAE_STATIC_SYS_INST_CODE, SRAE_INSTR_SYS_INST_CODE, TRANSACTION_POS_NEG, SRAE_GL_PERSON_CODE, DEPT_CD, SRAE_SOURCE_SYSTEM, SRAE_INSTR_SUPER_CLASS, SRAE_INSTRUMENT_CODE, LEDGER_CD, STREAM_ID, POSTING_DT, BOOK_CD, CORRELATION_UUID, CHARTFIELD_1, COUNTERPARTY_LE_CD, EXECUTION_TYP, OWNER_LE_CD, JOURNAL_DESCR, FUNCTIONAL_CCY, FUNCTIONAL_AMT, REPORTING_CCY, REPORTING_AMT, BUSINESS_EVENT_TYP, EVENT_SEQ_ID, BASIS_CD, POSTING_INDICATOR, MESSAGE_ID, PROCESS_ID, EFFECTIVE_DT, BU_ACCOUNT_LOOKUP)
            SELECT
                cep.BUSINESS_UNIT AS BUSINESS_UNIT,
                cep.AFFILIATE AS AFFILIATE_LE_CD,
                trunc(cep.ACCOUNTING_DT) AS ACCOUNTING_DT,
                cep.POLICY_ACCIDENT_YR AS ACCIDENT_YR,
                cep.POLICY_UNDERWRITING_YR AS UNDERWRITING_YR,
                cep.POLICY_ID AS POLICY_ID,
                cep.ULTIMATE_PARENT_LE_CD AS ULTIMATE_PARENT_LE_CD,
                cep.TAX_JURISDICTION_CD AS TAX_JURISDICTION_CD,
                cep.EVENT_TYP AS EVENT_TYP,
                cep.TRANSACTION_CCY AS TRANSACTION_CCY,
                NVL(cep.TRANSACTION_AMT, 0) AS TRANSACTION_AMT,
                cep.BUSINESS_TYP AS BUSINESS_TYP,
                cep.POLICY_TYP AS POLICY_TYP,
                cep.PREMIUM_TYP AS PREMIUM_TYP,
                cep.SUB_EVENT AS SUB_EVENT,
                cep.IS_MARK_TO_MARKET AS IS_MARK_TO_MARKET,
                cep.VIE_CD AS VIE_CD,
                cep.LPG_ID AS LPG_ID,
                cep.BUSINESS_UNIT AS PARTY_BUSINESS_LE_CD,
                ce_default.SYSTEM_INSTANCE AS PARTY_BUSINESS_SYSTEM_CD,
                cep.EVENT_TYP AS AAH_EVENT_TYP,
                ce_default.SYSTEM_INSTANCE AS SRAE_STATIC_SYS_INST_CODE,
                ce_default.SYSTEM_INSTANCE AS SRAE_INSTR_SYS_INST_CODE,
                (CASE
                    WHEN cep.TRANSACTION_AMT > 0 THEN 'POS'
                    ELSE 'NEG'
                END) AS TRANSACTION_POS_NEG,
                ce_default.SRAE_GL_PERSON_CODE AS SRAE_GL_PERSON_CODE,
                NULL AS DEPT_CD,
                ce_default.SRAE_SOURCE_SYSTEM AS SRAE_SOURCE_SYSTEM,
                ce_default.SRAE_INSTR_SUPER_CLASS AS SRAE_INSTR_SUPER_CLASS,
                ce_default.SRAE_INSTRUMENT_CODE AS SRAE_INSTRUMENT_CODE,
                cep.LEDGER_CD AS LEDGER_CD,
                cep.STREAM_ID AS STREAM_ID,
                trunc(gp.GP_TODAYS_BUS_DATE) AS POSTING_DT,
                cep.BUSINESS_UNIT AS BOOK_CD,
                cep.CORRELATION_UUID AS CORRELATION_UUID,
                cep.CHARTFIELD_CD AS CHARTFIELD_1,
                cep.COUNTERPARTY_LE_CD AS COUNTERPARTY_LE_CD,
                cep.EXECUTION_TYP AS EXECUTION_TYP,
                cep.OWNER_LE_CD AS OWNER_LE_CD,
                cep.POLICY_ABBR_NM AS JOURNAL_DESCR,
                cep.FUNCTIONAL_CCY AS FUNCTIONAL_CCY,
                NVL(cep.FUNCTIONAL_AMT, 0) AS FUNCTIONAL_AMT,
                cep.REPORTING_CCY AS REPORTING_CCY,
                NVL(cep.REPORTING_AMT, 0) AS REPORTING_AMT,
                cep.BUSINESS_EVENT_TYP AS BUSINESS_EVENT_TYP,
                cep.EVENT_SEQ_ID AS EVENT_SEQ_ID,
                cep.BASIS_CD AS BASIS_CD,
                'ORIGINAL' AS POSTING_INDICATOR,
                cep.ROW_SID AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                trunc(LEAST( gp.GP_TODAYS_BUS_DATE , cep.ACCOUNTING_DT )) AS EFFECTIVE_DT,
                case
when exists ( select
                     null
                from
                     fdr.fr_account_lookup fal
               where
                     fal.al_lookup_3 = cep.BUSINESS_UNIT
                 and sysdate between fal.al_valid_from and fal.al_valid_to
             )
then cep.BUSINESS_UNIT
else 'NULL'
end AS BU_ACCOUNT_LOOKUP
            FROM
                CESSION_EVENT_POSTING cep
                INNER JOIN CE_DEFAULT ON 1 = 1
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON cep.LPG_ID = gp.LPG_ID
            WHERE
                (cep.TRANSACTION_AMT <> 0 OR cep.FUNCTIONAL_AMT <> 0 OR cep.REPORTING_AMT <> 0);
        p_no_published_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed inserting cession events into hopper', 'p_no_published_records', NULL, p_no_published_records, NULL);
        INSERT  /*+ parallel(8)*/ INTO HOPPER_CESSION_EVENT
            (BUSINESS_UNIT, AFFILIATE_LE_CD, ACCOUNTING_DT, ACCIDENT_YR, UNDERWRITING_YR, POLICY_ID, ULTIMATE_PARENT_LE_CD, TAX_JURISDICTION_CD, EVENT_TYP, TRANSACTION_CCY, TRANSACTION_AMT, BUSINESS_TYP, POLICY_TYP, PREMIUM_TYP, SUB_EVENT, IS_MARK_TO_MARKET, VIE_CD, LPG_ID, PARTY_BUSINESS_LE_CD, PARTY_BUSINESS_SYSTEM_CD, AAH_EVENT_TYP, SRAE_STATIC_SYS_INST_CODE, SRAE_INSTR_SYS_INST_CODE, TRANSACTION_POS_NEG, SRAE_GL_PERSON_CODE, DEPT_CD, SRAE_SOURCE_SYSTEM, SRAE_INSTR_SUPER_CLASS, SRAE_INSTRUMENT_CODE, LEDGER_CD, STREAM_ID, POSTING_DT, BOOK_CD, CORRELATION_UUID, CHARTFIELD_1, COUNTERPARTY_LE_CD, EXECUTION_TYP, OWNER_LE_CD, JOURNAL_DESCR, FUNCTIONAL_CCY, FUNCTIONAL_AMT, REPORTING_CCY, REPORTING_AMT, BUSINESS_EVENT_TYP, EVENT_SEQ_ID, BASIS_CD, POSTING_INDICATOR, MESSAGE_ID, PROCESS_ID, EFFECTIVE_DT, BU_ACCOUNT_LOOKUP)
            SELECT
                cerhist.BUSINESS_UNIT AS BUSINESS_UNIT,
                cerhist.AFFILIATE AS AFFILIATE_LE_CD,
                trunc(cerhist.ACCOUNTING_DT) AS ACCOUNTING_DT,
                cerhist.POLICY_ACCIDENT_YR AS ACCIDENT_YR,
                cerhist.POLICY_UNDERWRITING_YR AS UNDERWRITING_YR,
                cerhist.POLICY_ID AS POLICY_ID,
                cerhist.ULTIMATE_PARENT_LE_CD AS ULTIMATE_PARENT_LE_CD,
                cerhist.TAX_JURISDICTION_CD AS TAX_JURISDICTION_CD,
                cerhist.EVENT_TYP AS EVENT_TYP,
                cerhist.TRANSACTION_CCY AS TRANSACTION_CCY,
                NVL(cerhist.TRANSACTION_AMT, 0) AS TRANSACTION_AMT,
                cerhist.BUSINESS_TYP AS BUSINESS_TYP,
                cerhist.POLICY_TYP AS POLICY_TYP,
                cerhist.PREMIUM_TYP AS PREMIUM_TYP,
                cerhist.SUB_EVENT AS SUB_EVENT,
                cerhist.IS_MARK_TO_MARKET AS IS_MARK_TO_MARKET,
                cerhist.VIE_CD AS VIE_CD,
                cerhist.LPG_ID AS LPG_ID,
                cerhist.BUSINESS_UNIT AS PARTY_BUSINESS_LE_CD,
                ce_default.SYSTEM_INSTANCE AS PARTY_BUSINESS_SYSTEM_CD,
                cerhist.EVENT_TYP AS AAH_EVENT_TYP,
                ce_default.SYSTEM_INSTANCE AS SRAE_STATIC_SYS_INST_CODE,
                ce_default.SYSTEM_INSTANCE AS SRAE_INSTR_SYS_INST_CODE,
                (CASE
                    WHEN cerhist.TRANSACTION_AMT > 0 THEN 'POS'
                    ELSE 'NEG'
                END) AS TRANSACTION_POS_NEG,
                ce_default.SRAE_GL_PERSON_CODE AS SRAE_GL_PERSON_CODE,
                NULL AS DEPT_CD,
                ce_default.SRAE_SOURCE_SYSTEM AS SRAE_SOURCE_SYSTEM,
                ce_default.SRAE_INSTR_SUPER_CLASS AS SRAE_INSTR_SUPER_CLASS,
                ce_default.SRAE_INSTRUMENT_CODE AS SRAE_INSTRUMENT_CODE,
                cerhist.LEDGER_CD AS LEDGER_CD,
                cerhist.STREAM_ID AS STREAM_ID,
                trunc(gp.GP_TODAYS_BUS_DATE) AS POSTING_DT,
                cerhist.BUSINESS_UNIT AS BOOK_CD,
                cerhist.CORRELATION_UUID AS CORRELATION_UUID,
                cerhist.CHARTFIELD_CD AS CHARTFIELD_1,
                cerhist.COUNTERPARTY_LE_CD AS COUNTERPARTY_LE_CD,
                cerhist.EXECUTION_TYP AS EXECUTION_TYP,
                cerhist.OWNER_LE_CD AS OWNER_LE_CD,
                cerhist.JOURNAL_DESCR AS JOURNAL_DESCR,
                cerhist.FUNCTIONAL_CCY AS FUNCTIONAL_CCY,
                NVL(cerhist.FUNCTIONAL_AMT, 0) AS FUNCTIONAL_AMT,
                cerhist.REPORTING_CCY AS REPORTING_CCY,
                NVL(cerhist.REPORTING_AMT, 0) AS REPORTING_AMT,
                cerhist.BUSINESS_EVENT_TYP AS BUSINESS_EVENT_TYP,
                cerhist.EVENT_SEQ_ID AS EVENT_SEQ_ID,
                cerhist.BASIS_CD AS BASIS_CD,
                'REVERSE_REPOST' AS POSTING_INDICATOR,
                cerhist.ROW_SID AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                trunc(LEAST( gp.GP_TODAYS_BUS_DATE , cerhist.ACCOUNTING_DT )) AS EFFECTIVE_DT,
                case
when exists ( select
                     null
                from
                     fdr.fr_account_lookup fal
               where
                     fal.al_lookup_3 = cerhist.BUSINESS_UNIT
                 and sysdate between fal.al_valid_from and fal.al_valid_to
             )
then cerhist.BUSINESS_UNIT
else 'NULL'
end AS BU_ACCOUNT_LOOKUP
            FROM
                CESSION_EVENT_REVERSAL_HIST cerhist
                INNER JOIN CE_DEFAULT ON 1 = 1
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON cerhist.LPG_ID = gp.LPG_ID
            WHERE
                (cerhist.TRANSACTION_AMT <> 0 OR cerhist.FUNCTIONAL_AMT <> 0 OR cerhist.REPORTING_AMT <> 0);
        p_no_pub_rev_hist_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed inserting historical reversal records into hopper', 'p_no_pub_rev_hist_records', NULL, p_no_pub_rev_hist_records, NULL);
        INSERT /*+ parallel(8)*/ INTO HOPPER_CESSION_EVENT
            (BUSINESS_UNIT, AFFILIATE_LE_CD, ACCOUNTING_DT, ACCIDENT_YR, UNDERWRITING_YR, POLICY_ID, ULTIMATE_PARENT_LE_CD, TAX_JURISDICTION_CD, EVENT_TYP, TRANSACTION_CCY, TRANSACTION_AMT, BUSINESS_TYP, POLICY_TYP, PREMIUM_TYP, SUB_EVENT, IS_MARK_TO_MARKET, VIE_CD, LPG_ID, PARTY_BUSINESS_LE_CD, PARTY_BUSINESS_SYSTEM_CD, AAH_EVENT_TYP, SRAE_STATIC_SYS_INST_CODE, SRAE_INSTR_SYS_INST_CODE, TRANSACTION_POS_NEG, SRAE_GL_PERSON_CODE, DEPT_CD, SRAE_SOURCE_SYSTEM, SRAE_INSTR_SUPER_CLASS, SRAE_INSTRUMENT_CODE, LEDGER_CD, STREAM_ID, POSTING_DT, BOOK_CD, CORRELATION_UUID, CHARTFIELD_1, COUNTERPARTY_LE_CD, EXECUTION_TYP, OWNER_LE_CD, JOURNAL_DESCR, FUNCTIONAL_CCY, FUNCTIONAL_AMT, REPORTING_CCY, REPORTING_AMT, BUSINESS_EVENT_TYP, EVENT_SEQ_ID, BASIS_CD, POSTING_INDICATOR, MESSAGE_ID, PROCESS_ID, EFFECTIVE_DT, BU_ACCOUNT_LOOKUP)
            SELECT
                cercurr.BUSINESS_UNIT AS BUSINESS_UNIT,
                cercurr.AFFILIATE AS AFFILIATE_LE_CD,
                trunc(cercurr.ACCOUNTING_DT) AS ACCOUNTING_DT,
                cercurr.POLICY_ACCIDENT_YR AS ACCIDENT_YR,
                cercurr.POLICY_UNDERWRITING_YR AS UNDERWRITING_YR,
                cercurr.POLICY_ID AS POLICY_ID,
                cercurr.ULTIMATE_PARENT_LE_CD AS ULTIMATE_PARENT_LE_CD,
                cercurr.TAX_JURISDICTION_CD AS TAX_JURISDICTION_CD,
                cercurr.EVENT_TYP AS EVENT_TYP,
                cercurr.TRANSACTION_CCY AS TRANSACTION_CCY,
                NVL(cercurr.TRANSACTION_AMT, 0) AS TRANSACTION_AMT,
                cercurr.BUSINESS_TYP AS BUSINESS_TYP,
                cercurr.POLICY_TYP AS POLICY_TYP,
                cercurr.PREMIUM_TYP AS PREMIUM_TYP,
                cercurr.SUB_EVENT AS SUB_EVENT,
                cercurr.IS_MARK_TO_MARKET AS IS_MARK_TO_MARKET,
                cercurr.VIE_CD AS VIE_CD,
                cercurr.LPG_ID AS LPG_ID,
                cercurr.BUSINESS_UNIT AS PARTY_BUSINESS_LE_CD,
                ce_default.SYSTEM_INSTANCE AS PARTY_BUSINESS_SYSTEM_CD,
                cercurr.EVENT_TYP AS AAH_EVENT_TYP,
                ce_default.SYSTEM_INSTANCE AS SRAE_STATIC_SYS_INST_CODE,
                ce_default.SYSTEM_INSTANCE AS SRAE_INSTR_SYS_INST_CODE,
                (CASE
                    WHEN cercurr.TRANSACTION_AMT > 0 THEN 'POS'
                    ELSE 'NEG'
                END) AS TRANSACTION_POS_NEG,
                ce_default.SRAE_GL_PERSON_CODE AS SRAE_GL_PERSON_CODE,
                NULL AS DEPT_CD,
                ce_default.SRAE_SOURCE_SYSTEM AS SRAE_SOURCE_SYSTEM,
                ce_default.SRAE_INSTR_SUPER_CLASS AS SRAE_INSTR_SUPER_CLASS,
                ce_default.SRAE_INSTRUMENT_CODE AS SRAE_INSTRUMENT_CODE,
                cercurr.LEDGER_CD AS LEDGER_CD,
                cercurr.STREAM_ID AS STREAM_ID,
                trunc(gp.GP_TODAYS_BUS_DATE) AS POSTING_DT,
                cercurr.BUSINESS_UNIT AS BOOK_CD,
                cercurr.CORRELATION_UUID AS CORRELATION_UUID,
                cercurr.CHARTFIELD_CD AS CHARTFIELD_1,
                cercurr.COUNTERPARTY_LE_CD AS COUNTERPARTY_LE_CD,
                cercurr.EXECUTION_TYP AS EXECUTION_TYP,
                cercurr.OWNER_LE_CD AS OWNER_LE_CD,
                cercurr.JOURNAL_DESCR AS JOURNAL_DESCR,
                cercurr.FUNCTIONAL_CCY AS FUNCTIONAL_CCY,
                NVL(cercurr.FUNCTIONAL_AMT, 0) AS FUNCTIONAL_AMT,
                cercurr.REPORTING_CCY AS REPORTING_CCY,
                NVL(cercurr.REPORTING_AMT, 0) AS REPORTING_AMT,
                cercurr.BUSINESS_EVENT_TYP AS BUSINESS_EVENT_TYP,
                cercurr.EVENT_SEQ_ID AS EVENT_SEQ_ID,
                cercurr.BASIS_CD AS BASIS_CD,
                'REVERSE_REPOST' AS POSTING_INDICATOR,
                cercurr.ROW_SID AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                trunc(LEAST( gp.GP_TODAYS_BUS_DATE , cercurr.ACCOUNTING_DT )) AS EFFECTIVE_DT,
                case
when exists ( select
                     null
                from
                     fdr.fr_account_lookup fal
               where
                     fal.al_lookup_3 = cercurr.BUSINESS_UNIT
                 and sysdate between fal.al_valid_from and fal.al_valid_to
             )
then cercurr.BUSINESS_UNIT
else 'NULL'
end AS BU_ACCOUNT_LOOKUP
            FROM
                CESSION_EVENT_REVERSAL_CURR cercurr
                INNER JOIN CE_DEFAULT ON 1 = 1
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON cercurr.LPG_ID = gp.LPG_ID
            WHERE
                (cercurr.TRANSACTION_AMT <> 0 OR cercurr.FUNCTIONAL_AMT <> 0 OR cercurr.REPORTING_AMT <> 0);
        p_no_pub_rev_curr_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed inserting current reversal records into hopper', 'p_no_pub_rev_curr_records', NULL, p_no_pub_rev_curr_records, NULL);
    END;
    
    PROCEDURE pr_cession_event_rval
        (
            p_step_run_sid IN NUMBER
        )
    AS
    BEGIN
        INSERT INTO STANDARDISATION_LOG
            (CATEGORY_ID, ERROR_STATUS, ERROR_TECHNOLOGY, ERROR_VALUE, EVENT_TEXT, EVENT_TYPE, FIELD_IN_ERROR_NAME, LPG_ID, PROCESSING_STAGE, ROW_IN_ERROR_KEY_ID, TABLE_IN_ERROR_NAME, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, FEED_SID)
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                TO_CHAR(ce.STREAM_ID) AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                ce.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                ce.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ce-stream_id'
and not exists (
                   select
                          null
                     from
                          stn.insurance_policy_reference ipr
                    where
                          ipr.stream_id = ce.STREAM_ID
               )
            UNION ALL
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                ce.BASIS_CD AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                ce.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                ce.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ce-basis_cd'
and not exists (
                   select
                          null
                     from
                          fdr.fr_gaap fg
                    where
                          fg.fga_gaap_id = ce.BASIS_CD
               )
            UNION ALL
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                ce.TRANSACTION_CCY AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                ce.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                ce.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN CE_DEFAULT ced ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ce-transaction_ccy'
and not exists (
                   select
                          null
                     from
                          fdr.fr_currency_lookup fcl
                    where
                          fcl.cul_currency_lookup_code = ce.TRANSACTION_CCY
                      and fcl.cul_sil_sys_inst_clicode = ced.SYSTEM_INSTANCE
               )
            UNION ALL
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                ce.FUNCTIONAL_CCY AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                ce.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                ce.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN CE_DEFAULT ced ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ce-functional_ccy'
and not exists (
                   select
                          null
                     from
                          fdr.fr_currency_lookup fcl
                    where
                          fcl.cul_currency_lookup_code = ce.FUNCTIONAL_CCY
                      and fcl.cul_sil_sys_inst_clicode = ced.SYSTEM_INSTANCE
               )
            UNION ALL
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                ce.REPORTING_CCY AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                ce.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                ce.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN CE_DEFAULT ced ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ce-reporting_ccy'
and not exists (
                   select
                          null
                     from
                          fdr.fr_currency_lookup fcl
                    where
                          fcl.cul_currency_lookup_code = ce.REPORTING_CCY
                      and fcl.cul_sil_sys_inst_clicode = ced.SYSTEM_INSTANCE
               )
            UNION ALL
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                ce.EVENT_TYP AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                ce.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                ce.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ce-event_typ'
and not exists (
                   select
                          null
                     from
                          fdr.fr_acc_event_type faet
                    where
                          faet.aet_acc_event_type_id = ce.EVENT_TYP
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Loaded records to stn.standardisation_log', 'sql%rowcount', NULL, sql%rowcount, NULL);
        INSERT INTO STANDARDISATION_LOG
            (CATEGORY_ID, ERROR_STATUS, ERROR_TECHNOLOGY, ERROR_VALUE, EVENT_TEXT, EVENT_TYPE, FIELD_IN_ERROR_NAME, LPG_ID, PROCESSING_STAGE, ROW_IN_ERROR_KEY_ID, TABLE_IN_ERROR_NAME, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, FEED_SID)
            SELECT
                "ce-validate-correlation-uuid".CATEGORY_ID AS CATEGORY_ID,
                "ce-validate-correlation-uuid".ERROR_STATUS AS ERROR_STATUS,
                "ce-validate-correlation-uuid".ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                "ce-validate-correlation-uuid".error_value AS ERROR_VALUE,
                "ce-validate-correlation-uuid".event_text AS EVENT_TEXT,
                "ce-validate-correlation-uuid".EVENT_TYPE AS EVENT_TYPE,
                "ce-validate-correlation-uuid".field_in_error_name AS FIELD_IN_ERROR_NAME,
                "ce-validate-correlation-uuid".LPG_ID AS LPG_ID,
                "ce-validate-correlation-uuid".PROCESSING_STAGE AS PROCESSING_STAGE,
                "ce-validate-correlation-uuid".row_in_error_key_id AS ROW_IN_ERROR_KEY_ID,
                "ce-validate-correlation-uuid".table_in_error_name AS TABLE_IN_ERROR_NAME,
                "ce-validate-correlation-uuid".rule_identity AS RULE_IDENTITY,
                "ce-validate-correlation-uuid".CODE_MODULE_NM AS CODE_MODULE_NM,
                "ce-validate-correlation-uuid".STEP_RUN_SID AS STEP_RUN_SID,
                "ce-validate-correlation-uuid".FEED_SID AS FEED_SID
            FROM
                (SELECT
                    vdl.TABLE_NM AS table_in_error_name,
                    ce.ROW_SID AS row_in_error_key_id,
                    'Correlated record invalid' AS error_value,
                    ce.LPG_ID AS LPG_ID,
                    vdl.COLUMN_NM AS field_in_error_name,
                    rveld.EVENT_TYPE AS EVENT_TYPE,
                    rveld.ERROR_STATUS AS ERROR_STATUS,
                    rveld.CATEGORY_ID AS CATEGORY_ID,
                    rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                    rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                    vdl.VALIDATION_CD AS rule_identity,
                    gp.GP_TODAYS_BUS_DATE AS todays_business_dt,
                    fd.SYSTEM_CD AS SYSTEM_CD,
                    vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                    ce.STEP_RUN_SID AS STEP_RUN_SID,
                    vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                    fd.FEED_SID AS FEED_SID
                FROM
                    CESSION_EVENT ce
                    INNER JOIN IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                    INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                    INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                    INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                    INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                WHERE
                        vdl.VALIDATION_CD = 'ce-correlation_uuid'
and exists (
       select
              null
         from
              stn.standardisation_log sl
         join 
              stn.cession_event ce2 on 
            ( sl.row_in_error_key_id = ce2.row_sid
          and sl.step_run_sid = ce2.step_run_sid )
        where 
              ce.correlation_uuid = ce2.correlation_uuid
            )
and not exists (
       select
              null
         from
              stn.standardisation_log sl3
        where 
              ce.ROW_SID = sl3.row_in_error_key_id
            )) "ce-validate-correlation-uuid";
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Loaded correlated records to stn.standardisation_log', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;
    
    PROCEDURE pr_cession_event_sps
        (
            p_no_processed_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE CESSION_EVENT ce
            SET
                EVENT_STATUS = 'P'
            WHERE
                exists (
           select
                  null
             from
                  stn.hopper_cession_event hce
            where
                  hce.correlation_uuid = ce.CORRELATION_UUID
              and ce.EVENT_STATUS = 'V'
           );
        p_no_processed_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_cession_event_svs
        (
            p_step_run_sid IN NUMBER,
            p_no_errored_records OUT NUMBER,
            p_no_validated_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE CESSION_EVENT ce
            SET
                EVENT_STATUS = 'E'
            WHERE
                       exists (
                  select
                         null
                    from
                         stn.standardisation_log sl
                   where
                         sl.table_in_error_name = 'cession_event'
                     and sl.row_in_error_key_id = ce.row_sid
              );
        p_no_errored_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of cession_event records set to error', 'sql%rowcount', NULL, sql%rowcount, NULL);
        UPDATE CESSION_EVENT ce
            SET
                EVENT_STATUS = 'V'
            WHERE
                    ce.EVENT_STATUS = 'U'
and exists ( 
             select
                    null
               from
                    stn.identified_record idr
              where
                    ce.ROW_SID = idr.row_sid
           );
        p_no_validated_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of cession_event records set to passed validation', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;
    
    PROCEDURE pr_cession_event_cur
        (
            p_step_run_sid IN NUMBER,
            p_no_unprocessed_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE CESSION_EVENT ce
            SET
                EVENT_STATUS = 'X'
            WHERE
                ce.EVENT_STATUS = 'V';
        p_no_unprocessed_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Number of unprocessed records cancelled', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;
    
    PROCEDURE pr_cession_event_sval
        (
            p_step_run_sid IN NUMBER
        )
    AS
    BEGIN
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : cession-event-validate-event-class', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                cev.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                TO_CHAR(cevecd.COUNT_DISTINCT) AS ERROR_VALUE,
                cev.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                sveld.EVENT_TYPE AS EVENT_TYPE,
                sveld.ERROR_STATUS AS ERROR_STATUS,
                sveld.CATEGORY_ID AS CATEGORY_ID,
                sveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                sveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                cev.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT cev
                INNER JOIN IDENTIFIED_RECORD idr ON cev.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON cev.FEED_UUID = fd.FEED_UUID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN SET_VAL_ERROR_LOG_DEFAULT sveld ON 1 = 1
                INNER JOIN (SELECT
                    cev.FEED_UUID AS FEED_UUID,
                    COUNT(DISTINCT fgl.LK_LOOKUP_VALUE3) AS COUNT_DISTINCT
                FROM
                    CESSION_EVENT cev
                    INNER JOIN fdr.FR_GENERAL_LOOKUP fgl ON cev.EVENT_TYP = fgl.LK_LOOKUP_VALUE1
                GROUP BY
                    cev.FEED_UUID) cevecd ON cev.FEED_UUID = cevecd.FEED_UUID
            WHERE
                vdl.VALIDATION_CD = 'ce-event_class_count' AND cevecd.COUNT_DISTINCT > 1;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : jcession-event-validate-event-class', 'sql%rowcount', NULL, sql%rowcount, NULL);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : cession-event-validate-event-class-period', NULL, NULL, NULL, NULL);
        INSERT INTO STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                cev.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                cev.EVENT_TYP AS ERROR_VALUE,
                cev.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                sveld.EVENT_TYPE AS EVENT_TYPE,
                sveld.ERROR_STATUS AS ERROR_STATUS,
                sveld.CATEGORY_ID AS CATEGORY_ID,
                sveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                sveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                cev.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT cev
                INNER JOIN IDENTIFIED_RECORD idr ON cev.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON cev.FEED_UUID = fd.FEED_UUID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN SET_VAL_ERROR_LOG_DEFAULT sveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ce-event_class_period_status'
and not exists ( select
                        null
                   from
                        stn.event_hierarchy_reference ehr
                   join stn.period_status             ps on ( extract ( year from cev.accounting_dt ) || lpad ( extract ( month from cev.accounting_dt ) , 2 , 0 ) ) = ps.period
                                                        and ehr.event_class = ps.event_class
                                                        and 'O'             = ps.status
                  where
                        cev.EVENT_TYP = ehr.event_typ
                    
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : jcession-event-validate-event-class-period', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;
    
    PROCEDURE pr_cession_event_res
        (
            p_no_reset_event_status OUT NUMBER
        )
    AS
    BEGIN
        UPDATE CESSION_EVENT ce
            SET
                EVENT_STATUS = 'U'
            WHERE
                ce.EVENT_STATUS = 'V';
        p_no_reset_event_status := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_cession_event_prc
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_processed_records OUT NUMBER,
            p_no_failed_records OUT NUMBER
        )
    AS
        v_no_reset_event_status NUMBER(38, 9) DEFAULT 0;
        v_no_identified_records NUMBER(38, 9) DEFAULT 0;
        v_no_updated_hopper_records NUMBER(38, 9) DEFAULT 0;
        v_no_validated_records NUMBER(38, 9) DEFAULT 0;
        v_no_errored_records NUMBER(38, 9) DEFAULT 0;
        v_no_published_records NUMBER(38, 9) DEFAULT 0;
        v_no_pub_rev_hist_records NUMBER(38, 9) DEFAULT 0;
        v_no_pub_rev_curr_records NUMBER(38, 9) DEFAULT 0;
        v_no_processed_records NUMBER(38, 9) DEFAULT 0;
        v_no_unprocessed_records NUMBER(38, 9) DEFAULT 0;
        pub_val_mismatch EXCEPTION;
    BEGIN
        dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Reset ''V'' event_status to ''U'' from prior failed run' );
        pr_cession_event_res(v_no_reset_event_status);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Reset cession event event_status to U', 'v_no_reset_event_status', NULL, v_no_reset_event_status, NULL);
        dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Identify cession event records' );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start identify cession event records', NULL, NULL, NULL, NULL);
        pr_cession_event_idf(p_lpg_id, p_step_run_sid, v_no_identified_records);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Identified cession event records', 'v_no_identified_records', NULL, v_no_identified_records, NULL);
        IF v_no_identified_records > 0 THEN
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Row level validate cession event records' );
            pr_cession_event_rval(p_step_run_sid);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed row level validations', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set cession event status = "V"' );
            pr_cession_event_svs(p_step_run_sid, v_no_errored_records, v_no_validated_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting validation status', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish log records' );
            pr_publish_log;
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish cession event records' );
            pr_cession_event_pub(p_step_run_sid, v_no_published_records, v_no_pub_rev_hist_records, v_no_pub_rev_curr_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing records', 'v_no_published_records + v_no_pub_rev_hist_records + v_no_pub_rev_curr_records', NULL, v_no_published_records + v_no_pub_rev_hist_records + v_no_pub_rev_curr_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set cession event status = "P"' );
            pr_cession_event_sps(v_no_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status', 'v_no_processed_records', NULL, v_no_processed_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Cancel unprocessed valid records' );
            pr_cession_event_cur(p_step_run_sid, v_no_unprocessed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cancelling unprocessed records', NULL, NULL, NULL, NULL);
            IF v_no_validated_records <> (v_no_processed_records + v_no_unprocessed_records) THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_no_validated_records != v_no_processed_records', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 1' );
                raise pub_val_mismatch;
            END IF;
            p_no_processed_records := v_no_processed_records;
            p_no_failed_records    := v_no_errored_records;
        ELSE
            p_no_processed_records := 0;
            p_no_failed_records    := 0;
        END IF;
    END;
END PK_CEV;
/
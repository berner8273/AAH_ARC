CREATE OR REPLACE PACKAGE BODY STN.PK_CEV AS
    PROCEDURE pr_cession_event_idf
        (
            p_lpg_id IN NUMBER,
            p_step_run_sid IN NUMBER,
            p_no_cev_identified_records OUT NUMBER
        )
    AS
    BEGIN
        execute immediate 'truncate table STN.CEV_IDENTIFIED_RECORD';
        INSERT /*+ APPEND */ INTO CEV_IDENTIFIED_RECORD
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
     and exists (
            select
                 null
            from
                stn.event_hierarchy_reference ehr
           join stn.period_status ps on ehr.event_class = ps.event_class
           where ps.status = 'O'
             and trunc(ce.accounting_dt,'MONTH') = trunc(ps.period_end,'MONTH')
             and ce.event_typ = ehr.event_typ
              );
        commit;
        dbms_stats.gather_table_stats ( ownname => 'STN' , tabname => 'CEV_IDENTIFIED_RECORD' , estimate_percent => 30 , cascade => true );
        UPDATE CESSION_EVENT ce
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.cev_identified_record idr
            where
                  ce.row_sid = idr.row_sid
       );
        p_no_cev_identified_records := SQL%ROWCOUNT;
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
        v_no_cev_vie_data NUMBER(38, 9) DEFAULT 0;
        lcOUT_OF_BALANCE_ACCT CONSTANT VARCHAR2(50) DEFAULT '18250255';
    BEGIN

    -- Gather all cession event data from stn.cession_event was identified as Valid and store in (CEV_VALID) table

        execute immediate 'truncate table stn.cev_valid';
        insert /*+ APPEND */ into stn.cev_valid
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
        ,   reclass_entity
        ,   account_cd
        ,   chartfield_1
        ,   jl_description
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
        ,   cev.reclass_entity
        ,   cev.account_cd
        ,   cev.chartfield_1
        ,   jl_description
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
               stn.cession_event            cev
          join stn.cev_identified_record        idr     on cev.row_sid = idr.row_sid
         where
               cev.event_status = 'V'
        ;
        v_no_cev_valid := sql%rowcount;
        commit;

        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cev_valid', 'v_no_cev_valid', NULL, v_no_cev_valid, NULL);
        execute immediate 'truncate table STN.posting_account_derivation';

        -- Create table mapping of account codes to posting schema (stn.posting_account_derivation)

        insert into stn.posting_account_derivation
        select distinct
               fpd.pd_posting_schema     posting_schema
             , fpd.pd_aet_event_type     event_typ
             , fpd.pd_sub_event          sub_event
             , fal.al_lookup_1           business_typ
             , fal.al_lookup_2           is_mark_to_market
             , fal.al_lookup_3           business_unit
             , fal.al_ccy                currency
             , min(fal.al_account)       sub_account
             , fal.al_lookup_4           vie_business_unit
             , fal.al_lookup_5           account_cd
          from
               fdr.fr_posting_driver              fpd
          join fdr.fr_account_lookup              fal   on fpd.pd_posting_code    = fal.al_posting_code
          join fdr.fr_gl_account                  fgl   on fal.al_account         = fgl.ga_account_code
          join stn.event_type                     et    on fpd.pd_aet_event_type  = et.event_typ
         where
               fgl.ga_account_type     = 'B'
        group by
                      fpd.pd_posting_schema
             , fpd.pd_aet_event_type
             , fpd.pd_sub_event
             , fal.al_lookup_1
             , fal.al_lookup_2
             , fal.al_lookup_3
             , fal.al_lookup_4
             , fal.al_lookup_5
             , fal.al_ccy
        ;


        dbms_stats.gather_table_stats ( ownname => 'STN' , tabname => 'POSTING_ACCOUNT_DERIVATION' , estimate_percent => 30 , cascade => true );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed posting_account_derivation', NULL, NULL, NULL, NULL);
            execute immediate 'truncate table STN.CEV_DATA';

        --    ***************************  C E V   D A T A  ****************************************
        --  Create table (CEV_DATA)
        -- This data takes CESSION_EVENT and enriches with policy data and creates new FUT_TO_CUR events for WRITTEN_PREMIUM and CC_INCOME_EXPENSE
        --  SUB QUERY:
        --      CE_DATA   POLICY Reference data based on Stream Hierarachy
        --      CEV_EX_IN Enriches CE_DATA with policy reference data
        --  Calculate NEW data points:
        --      PARTNER_TRANSACTION_AMT:
        --         NVL( coalesce ( lag  ( basis_transaction_amt ) over ( partition by business_type_association_id order by basis_cd )
        --         , lead ( basis_transaction_amt ) over ( partition by business_type_association_id order by basis_cd, 0 )
        --      PARTNER_FUNCTIONAL_AMT:
        --         nvl(coalesce ( lag  ( basis_functional_amt ) over ( partition by business_type_association_id order by basis_cd )
        --          , lead ( basis_functional_amt ) over ( partition by business_type_association_id order by basis_cd ) ),0)
        --      PARTNER_REPORTING_AMT:
        --          NVL( coalesce ( lag  ( basis_reporting_amt ) over ( partition by business_type_association_id order by basis_cd )
        --            , lead ( basis_reporting_amt ) over ( partition by business_type_association_id order by basis_cd ) ),0)
        --      INPUT_FUNCTIONAL_AMT = FUNCTIONAL_AMT
        --      INPUT_REPORTING_AMT = REPORTING_AMT
        --      PREMIUM_TYP         For 'X' then policy premium type else CEV.PREMIUM_TYP
        --      BUSINESS_UNIT:      For CESSION (A,D,C,AA) then LE_CD for PARENT_CESSION (CA) then parent_cessinon_le_cd (unless reclass_entity)  ELSE NULL
        --      AFFILIATE:          For CESSION (CA) then LE_CD for PARENT_CESSION (AA) then parent_cessinon_le_cd ELSE NULL
        --      OWNER_LE_CD         For CESSION (A,D,AA) then OWNER_LE_CD for PARENT_CESSION (C,CA) then counterparty_le_cd ELSE NULL
        --      COUNTERPARTY_LE_CD  For CESSION (A,D,C,CA) then OWNER_LE_CD for PARENT_CESSION (AA) then counterparty_le_cd ELSE NULL
        --      BUSINESS_TYPE_ASSOCIATION_ID: Rank over cev.feed_uuid, cev.correlation_uuid, cev.accounting_dt, cev.stream_id, cev.event_typ, cev.business_typ, abasis.basis_grp
        --      INTERCOMPANY_ASSOCIATION_ID Rank over cev.feed_uuid, cev.correlation_uuid, cev.accounting_dt, cev.stream_id, cev.event_typ, abasis.basis_grp
        --      GAAP_FUT_ACCTS_ASSOCIATION_ID Rank over cev.feed_uuid, cev.correlation_uuid, cev.accounting_dt, cev.stream_id, cev.event_typ, cev.business_typ, abasis.basis_grp
        --      BASIS_ASSOCIATION_ID Rank over cev.feed_uuid, cev.correlation_uuid, cev.accounting_dt, cev.stream_id, cev.event_typ, cev.business_typ, cev.basis_cd
        --      EVENT_SEQ_ID = cev.event_id
        --      PARTNER_BASIS_CD = IF cev.basis_cd = 'US_GAAP' then US_STAT elsif US_STAT then US_GAAP else NULL
        --      CREATE NEW EVENTS:
        --          EVENT_TYP = IF BASIS_CD = 'US_STAT AND WRITTEN_PREMIUM then CREATE NEW EVENT WP_FUT_TO_CUR, IF CC_INCOME_EXPENSE then CREATE CC_FUT_TO_CUR else just existing event_typ
        --          EVENT_TYP_ID = ID from EVENT_TYP
        --      POLICY_ACCIDENT_YR = IF event_class = 'LOSSES' then cev.policy_accident_yr else NULL

        insert /*+ APPEND */ into stn.cev_data
        with
          ce_data -- POLICY Reference data based on Stream Hierarachy
          as (
          select  /*+ MATERIALIZE*/
                           ipr.policy_id
                         , ipr.policy_abbr_nm
                         , ipr.stream_id
                         , 1                                    vie_id
                         , 1                                    vie_cd
                         , ipr.vie_status
                         , ipr.vie_effective_dt
                         , ipr.vie_acct_dt
                         , ipr.ledger_entity_cd                 le_cd
                         , ipr.is_mark_to_market
                         , ipr.policy_premium_typ
                         , ipr.policy_accident_yr
                         , ipr.underwriting_yr       policy_underwriting_yr
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
                                 , ce_data.vie_status
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
                                        end premium_typ

                                  ,ce_data.le_cd
                                  ,ce_data.parent_cession_le_cd
                                  ,cev.reclass_entity
                                  ,cev.account_cd
                                  ,cev.chartfield_1
                                  ,cev.jl_description
                                  ,ce_data.owner_le_cd
                                  ,ce_data.counterparty_le_cd
                                  ,cev.transaction_amt
                                  ,cev.transaction_ccy
                                  ,cev.functional_amt
                                  ,cev.functional_ccy
                                  ,cev.reporting_amt
                                  ,cev.reporting_ccy
                                  ,cev.lpg_id
                                      from
                                                stn.cev_valid               cev
                                           join                             ce_data on cev.stream_id = ce_data.stream_id
                                           join stn.policy_premium_type     ppt     on ce_data.policy_premium_typ = ppt.premium_typ
                                )
                 select
                        gaap_fut_accts_flag
                      , le_flag
                      , business_type_association_id
                      , intercompany_association_id
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
                      , vie_status
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
                      , transaction_ccy
                      , functional_amt       input_functional_amt
                      , nvl
                            (
                                coalesce ( lag  ( basis_functional_amt ) over ( partition by business_type_association_id order by basis_cd )
                                         , lead ( basis_functional_amt ) over ( partition by business_type_association_id order by basis_cd ) )
                              , 0
                            )                partner_functional_amt
                      , functional_ccy
                      , reporting_amt        input_reporting_amt
                      , nvl
                            (
                                coalesce ( lag  ( basis_reporting_amt ) over ( partition by business_type_association_id order by basis_cd )
                                         , lead ( basis_reporting_amt ) over ( partition by business_type_association_id order by basis_cd ) )
                              , 0
                            )                partner_reporting_amt
                      , reporting_ccy
                      , lpg_id
                      , account_cd
                      , chartfield_1
                      , jl_description
                   from (
                            select
                                   nvl( gfa.gaap_fut_accts_flag , 'N' )                                    gaap_fut_accts_flag
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
                                 , coalesce ( gfaout.event_typ    , cev.event_typ )     event_typ
                                 , coalesce ( gfaout.event_typ_id , et.event_typ_id )   event_typ_id
                                 , cev.business_event_typ
                                 , cev.policy_id
                                 , cev.policy_abbr_nm
                                 , cev.stream_id
                                 , cev.parent_stream_id
                                 , cev.vie_id
                                 , cev.vie_cd
                                 , cev.vie_status
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
                                       then nvl(cev.reclass_entity,cev.le_cd)
                                       when bt.bu_derivation_method = 'PARENT_CESSION'
                                       then nvl(cev.reclass_entity,cev.parent_cession_le_cd)
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
                                   end                                                      counterparty_le_cd
                                 , cev.transaction_amt                                      transaction_amt
                                 , sum (cev.transaction_amt) over ( partition by cev.feed_uuid, cev.correlation_uuid, cev.accounting_dt, cev.stream_id, cev.event_typ, cev.business_typ, cev.basis_cd) as basis_transaction_amt
                                 , cev.transaction_ccy
                                 , cev.functional_amt                                       functional_amt
                                 , sum (cev.functional_amt) over ( partition by cev.feed_uuid, cev.correlation_uuid, cev.accounting_dt, cev.stream_id, cev.event_typ, cev.business_typ, cev.basis_cd) as basis_functional_amt
                                 , cev.functional_ccy
                                 , cev.reporting_amt                                        reporting_amt
                                 , sum (cev.reporting_amt) over ( partition by cev.feed_uuid, cev.correlation_uuid, cev.accounting_dt, cev.stream_id, cev.event_typ, cev.business_typ, cev.basis_cd) as basis_reporting_amt
                                 , cev.reporting_ccy
                                 , cev.lpg_id
                                 , cev.account_cd
                                 , cev.chartfield_1
                                 , cev.jl_description
                              from
                                        cev_ex_in                        cev
                                   join stn.event_type                   et      on cev.event_typ              = et.event_typ
                              left join stn.event_hierarchy_reference    ehr     on cev.event_typ              = ehr.event_typ
                                   join stn.posting_accounting_basis     abasis  on cev.basis_cd               = abasis.basis_cd
                                   join stn.business_type                bt      on cev.business_typ           = bt.business_typ
                            left join stn.posting_method_derivation_gfa  gfa    on et.event_typ_id      = gfa.event_typ_in and cev.basis_cd = 'US_STAT'
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
        commit;

        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cev_data', 'v_no_cev_data', NULL, v_no_cev_data, NULL);
        execute immediate 'truncate table STN.cev_premium_typ_override';

--        Using reference data from stn.posting_method_derivation_gfa, the correlation_uuid and event_typ_id are identified
--        where a record should be processed according to the ?mixed? rule rather than ?upfront?.
--        This is to accomplish rule 7D in the Posting Driver Rules document.
--        This step was separated due to its added complexity causing the execution of stn.cev_data to run inefficiently.


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

        dbms_stats.gather_table_stats ( ownname => 'STN' , tabname => 'CEV_PREMIUM_TYP_OVERRIDE' , estimate_percent => 30 , cascade => true );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cev_premium_typ_override', NULL, NULL, NULL, NULL);
        execute immediate 'truncate table stn.cev_mtm_data';

        --    ***************************  C E V   M T M  D A T A   ****************************************

--            Processes standard events using the posting method derivation logic, primarily using event type, premium type, ledger,
--            and mark to market (MTM) flag (stn.posting_method_derivation_mtm).
--            Events that have been flagged as gaap_fut_accts in stn.cev_data are excluded.

        --  WHERE cev_data.gaap_fut_accts_flag = 'N' (CEV_DATA that did not create new events)
        -- Create SUB_EVENT (MTM,REVERSE,NULL) based on ledger/ posting_method_ledger
        -- Create accoutning basis (basis_typ,basis_cd)
        -- Create ledger_cd based on input_ledger_cd
        -- Create fin_calc_cd based on posting_method_ledger (1,3,4 -input,input_minus_partner,input_plus_partner)

        insert into stn.cev_mtm_data
                 select /*+ parallel*/
                        psm.psm_cd
                      , cev_data.business_type_association_id
                      , cev_data.intercompany_association_id
                      , 0        gaap_fut_accts_association_id
                      , cev_data.correlation_uuid
                      , cev_data.event_seq_id
                      , cev_data.row_sid
                      , case when cev_data.is_mark_to_market = 'Y'
                                and psm.psm_cd = 'GAAP_TO_CORE'
                                and pldgr.ledger_cd = 'CORE'
                            then 'MTM'
                            else pml.sub_event
                        end sub_event
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
                      , cev_data.vie_status
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
                      , cev_data.account_cd
                      , cev_data.chartfield_1
                      , cev_data.jl_description
                   from
                             stn.cev_data                       cev_data
                   left join stn.cev_premium_typ_override       cevpto   on cev_data.correlation_uuid  = cevpto.correlation_uuid
                                                                        and cev_data.event_typ_id      = cevpto.event_typ_id
                   left join stn.posting_method_derivation_le   psml     on cev_data.business_unit     = psml.le_cd
                        join stn.posting_method_derivation_mtm  psmtm    on cev_data.event_typ_id      = psmtm.event_typ_id
                                                                        and cev_data.is_mark_to_market = psmtm.is_mark_to_market
                                                                        and coalesce( cevpto.premium_typ_override
                                                                                    , nvl( cev_data.premium_typ , 'NVS' ) ) = psmtm.premium_typ
                                                                        and cev_data.input_basis_id                = psmtm.basis_id
                        join stn.posting_method_ledger          pml      on coalesce( psml.psm_id , psmtm.psm_id ) = pml.psm_id
                                                                        and cev_data.input_basis_id                = pml.input_basis_id
                        join stn.posting_method                 psm      on coalesce( psml.psm_id , psmtm.psm_id ) = psm.psm_id
                        join stn.posting_ledger                 pldgr    on pml.ledger_id                          = pldgr.ledger_id
                        join stn.posting_accounting_basis       abasis   on pml.output_basis_id                    = abasis.basis_id
                        join stn.posting_financial_calc         fincalc  on pml.fin_calc_id                        = fincalc.fin_calc_id
                    where cev_data.gaap_fut_accts_flag = 'N'
        ;

        v_no_cev_mtm_data := sql%rowcount;

        dbms_stats.gather_table_stats ( ownname => 'STN' , tabname => 'CEV_MTM_DATA' , estimate_percent => 30 , cascade => true );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cev_mtm_data', 'v_no_cev_mtm_data', NULL, v_no_cev_mtm_data, NULL);
        execute immediate 'truncate table STN.cev_gaap_fut_accts_data';

        --    ***************************  C E V   G A A P  F U T  A C C T S   D A T A   ****************************************
        -- Processes events that qualify for ?GAAP future accounts? processing.  The majority of this step is done in the gfa_1 sub-query.
        --  The final select statement sums amounts to combine amounts when premium types of U and I exist for the future to current events.
        --  The rule only applies for premium types M and I, not for U only policies (where clause).
        --
        -- CEV_DATA where cev_data.gaap_fut_accts_flag = 'Y' (from derived events in CEV_DATA)
        --      SUM amounts and group by cev_data details
        --
        --  SUB QUERYS
        --      GFA_1 based on CEV_DATA with the following new data pointsL
        --          event_seq_id and row_sid
        --         LEDGER_CD = when business unit is (AGFPI,AGFRA,FSAUK,MBIU1,MBUK) THEN CORE else Posting Ledger.LEDGER_CD
        --        PREMIUM_TYP = IF event is CC/WP_FUT_TO_CUR then special or existing

        insert into stn.cev_gaap_fut_accts_data
        with gfa_1 as
               (          select
                                psm.psm_cd
                              , cev_data.business_type_association_id
                              , cev_data.intercompany_association_id
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
                              , case
                                    when pmdle.le_cd is not null
                                        then 'CORE'
                                    else pldgr.ledger_cd
                                end as ledger_cd
                              , cev_data.event_typ
                              , cev_data.business_event_typ
                              , cev_data.is_mark_to_market
                              , cev_data.vie_cd
                              , cev_data.vie_status
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
                              , cev_data.account_cd
                              , cev_data.chartfield_1
                              , cev_data.jl_description
                              from
                                        stn.cev_data                      cev_data
                                   join stn.posting_method                psm      on (psm.psm_cd = 'GAAP_FUT_ACCTS'
                                                                                       or  psm.psm_cd = 'GAAP_TO_CORE')
                                   join stn.posting_method_ledger         pml      on (psm.psm_id = pml.psm_id
                                                                                       and cev_data.input_basis_id = pml.input_basis_id)
                                   join stn.posting_ledger                pldgr    on pml.ledger_id       = pldgr.ledger_id
                                   join stn.posting_accounting_basis      abasis   on pml.output_basis_id = abasis.basis_id
                                   join stn.posting_financial_calc        fincalc  on pml.fin_calc_id     = fincalc.fin_calc_id
                                   left join stn.posting_method_derivation_le  pmdle    on pmdle.le_cd         = cev_data.business_unit
                                where cev_data.gaap_fut_accts_flag = 'Y'
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
                    , vie_status
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
                    , account_cd
                    , chartfield_1
                    , jl_description
                 from
                      gfa_1
             group by
                      psm_cd
                    , business_type_association_id
                    , intercompany_association_id
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
                    , vie_status
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
                    , account_cd
                    , chartfield_1
                    , jl_description
        ;

        v_no_cev_gaap_fut_accts_data := sql%rowcount;

        dbms_stats.gather_table_stats ( ownname => 'STN' , tabname => 'CEV_GAAP_FUT_ACCTS_DATA' , estimate_percent => 30 , cascade => true );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cev_gaap_fut_accts_data', 'v_no_cev_gaap_fut_accts_data', NULL, v_no_cev_gaap_fut_accts_data, NULL);
        -- Derived plus logic no longer needed in cession event standardisation
        -- UPR change logic is done in upstream system
        v_no_cev_derived_plus_data := 0;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Bypassing cev_derived_plus_data', 'v_no_cev_derived_plus_data', NULL, v_no_cev_derived_plus_data, NULL);
        -- Special handling for GAAP_TO_CORE rule incorporated into cev_mtm_data step
        v_no_cev_le_data := 0;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Bypassing cev_le_data', 'v_no_cev_le_data', NULL, v_no_cev_le_data, NULL);
        execute immediate 'truncate table STN.cev_non_intercompany_data';

        --    ***************************  C E V   N O N  I N T E R C O M P A N Y   D A T A   ****************************************
        --  Processes final transformations and exceptions for ?original? non-intercompany, non-VIE events,
        --      unioning datasets from stn.cev_mtm_data and stn.cev_gaap_fut_accts_data.
        --  SUB QUERYS
        --      AMOUNT_DERIVATION based on UNION of CEV_MTM_DATA and CEV_GAAP_FUT_ACCTS_DATA with new datapoints:
        --          TRANSACTION_AMOUNT - based on FIN_CALC_CD
        --          FUNCTIONAL_AMOUNT  - based on FIN_CALC_CD
        --          REPORTING_AMOUNT  - based on FIN_CALC_CD
        --      NON_INTERCOMPANY_DATA based on AMOUNT_DERIVATION with NEW rows by tax state percentage with new datapoints:
        --          BUSINESS_TYP = IF Affilate = AGFPI and AA then 'D' else busines_typ
        --          TRANSACTION_AMOUNT - by TAX STATE PERCENTAGE
        --          FUNCTIONAL_AMOUNT  -by TAX STATE PERCENTAGE
        --          REPORTING_AMOUNT  - by TAX STATE PERCENTAGE

        --
                insert into stn.cev_non_intercompany_data
                with amount_derivation
                  as (
                         select
                                psm_cd                        posting_type
                              , business_type_association_id
                              , intercompany_association_id
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
                              , vie_status
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
                              , input_transaction_amt
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
                              , input_functional_amt
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
                              , input_reporting_amt
                              , lpg_id
                              , account_cd
                              , chartfield_1
                              , jl_description
                           from (
                                       select
                                              psm_cd
                                            , business_type_association_id
                                            , intercompany_association_id
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
                                            , vie_status
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
                                            , account_cd
                                            , chartfield_1
                                            , jl_description
                                         from
                                              stn.cev_mtm_data
                                    union all
                                       select
                                              psm_cd
                                            , business_type_association_id
                                            , intercompany_association_id
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
                                            , vie_status
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
                                            , account_cd
                                            , chartfield_1
                                            , jl_description
                                         from
                                              stn.cev_gaap_fut_accts_data
                                )
                     )
                   , non_intercompany_data
                  as (
                         select
                                posting_type
                              , business_type_association_id
                              , intercompany_association_id
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
                              , vie_status
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
                              , input_transaction_amt
                              , functional_ccy
                              , functional_amt
                              , input_functional_amt
                              , reporting_ccy
                              , reporting_amt
                              , input_reporting_amt
                              , lpg_id
                              , account_cd
                              , chartfield_1
                              , jl_description
                           from (
                                       select
                                              ad.posting_type
                                            , ad.business_type_association_id
                                            , ad.intercompany_association_id
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
                                            , ad.vie_status
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
                                            , pt.tax_jurisdiction_cd                                                                        tax_jurisdiction_cd
                                            , ad.transaction_ccy
                                            , ( ( ad.transaction_amt * nvl(pt.tax_jurisdiction_pct,100) ) / 100 )                           transaction_amt
                                            , ( ( ad.input_transaction_amt * nvl(pt.tax_jurisdiction_pct,100) ) / 100 )                     input_transaction_amt
                                            , ad.functional_ccy
                                            , ( ( ad.functional_amt * nvl(pt.tax_jurisdiction_pct,100) ) / 100 )                            functional_amt
                                            , ( ( ad.input_functional_amt * nvl(pt.tax_jurisdiction_pct,100) ) / 100 )                      input_functional_amt
                                            , ad.reporting_ccy
                                            , ( ( ad.reporting_amt * nvl(pt.tax_jurisdiction_pct,100) ) / 100 )                             reporting_amt
                                            , ( ( ad.input_reporting_amt * nvl(pt.tax_jurisdiction_pct,100) ) / 100 )                       input_reporting_amt
                                            , ad.lpg_id
                                            , ad.account_cd
                                            , ad.chartfield_1
                                            , ad.jl_description
                                         from
                                              amount_derivation                  ad
                                         join stn.event_type                     et     on ad.event_typ         = et.event_typ
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
                                  , business_unit bu_lookup
                                  , affiliate
                                  , owner_le_cd
                                  , counterparty_le_cd
                                  , ledger_cd
                                  , vie_cd
                                  , vie_status
                                  , vie_effective_dt
                                  , vie_acct_dt
                                  , is_mark_to_market
                                  , tax_jurisdiction_cd
                                  , chartfield_1
                                  , transaction_ccy
                                  , transaction_amt
                                  , input_transaction_amt
                                  , functional_ccy
                                  , functional_amt
                                  , input_functional_amt
                                  , reporting_ccy
                                  , reporting_amt
                                  , input_reporting_amt
                                  , lpg_id
                                  , account_cd
                                  , jl_description
                               from
                                    non_intercompany_data
                ;
                v_no_cev_non_intercompany_data := sql%rowcount;

                dbms_stats.gather_table_stats ( ownname => 'STN' , tabname => 'CEV_NON_INTERCOMPANY_DATA' , estimate_percent => 30 , cascade => true );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cev_non_intercompany_data', 'v_no_cev_non_intercompany_data', NULL, v_no_cev_non_intercompany_data, NULL);
        execute immediate 'truncate table STN.cev_intercompany_data';

        --    ***************************  C E V   I N T E R C O M P A N Y   D A T A   ****************************************
        --  Intercompany elimination events are generated using events in stn.cev_non_intercompany_data.
        --      Intercompany elimination events are flagged in previous steps for business types CA/AA in which one stream represents both sides of a cession.
        --      Reinsurance entries are also generated in this process when the business unit/affiliate relationship is defined in stn.posting_method_derivation_rein.
        --      Elimination entities according to business unit/affiliate relationships are derived and stored in stn.elimination_legal_entity as part of the legal entity
        --      reference data standardisation process.
        --
        --  Select from non intercompany data WHERE generate_interco_accounting = 'Y' (Business Type = AA or CA only)
        --  For CORE Ledger create NEW event for GAAP/STAT Consolidation
        --  Calc ledger_cd = based on orig ledger cd and posting_method_derivation_ic
        --  Calc Business_typ = if affiliate = AGFPI and business_typ = 'AA' then D else business_typ
        --  Calc business Unit based on buiness unit and affiliate lookup to posting_method_derivation_rein
        --  Calc Affiliate = IF above posting_method_derivation_rein.REINS_LE_CD is null than use Affiliate else NULL
        --  Calc Accound_cd = IF Account_CD is not null USE OutOFBalance cd else NULL.
        --  Calc chartfield_1 based on above posting_method_derivation_rein table

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
                              , pldgrout.ledger_cd
                              , cevnid.event_typ
                              , cevnid.business_event_typ
                              , cevnid.is_mark_to_market
                              , cevnid.tax_jurisdiction_cd
                              , cevnid.vie_effective_dt
                              , cevnid.vie_acct_dt
                              , cevnid.vie_cd
                              , cevnid.vie_status
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
                              , cevnid.bu_lookup
                              , nvl2( psmre.reins_le_cd , null , cevnid.affiliate ) affiliate
                              , cevnid.owner_le_cd
                              , cevnid.counterparty_le_cd
                              , psmre.chartfield_cd
                              , cevnid.transaction_ccy
                              , cevnid.transaction_amt * pdmic.negate_flag                             transaction_amt
                              , cevnid.functional_ccy
                              , cevnid.functional_amt * pdmic.negate_flag                              functional_amt
                              , cevnid.reporting_ccy
                              , cevnid.reporting_amt * pdmic.negate_flag                               reporting_amt
                              , cevnid.lpg_id
                              , NVL2( cevnid.account_cd, lcOUT_OF_BALANCE_ACCT, null ) account_cd
                              , cevnid.chartfield_cd chartfield_1
                              , cevnid.jl_description
                           from
                                     stn.cev_non_intercompany_data    cevnid
                                join stn.posting_ledger               pldgrin  on cevnid.ledger_cd       = pldgrin.ledger_cd
                                join stn.posting_method_derivation_ic pdmic    on pldgrin.ledger_id      = pdmic.input_ledger_id
                                join stn.posting_ledger               pldgrout on pdmic.output_ledger_id = pldgrout.ledger_id
                                join stn.elimination_legal_entity     ele      on (
                                                                                        cevnid.business_unit        = ele.le_1_cd
                                                                                    and cevnid.affiliate            = ele.le_2_cd
                                                                                    and pdmic.legal_entity_link_typ = ele.legal_entity_link_typ
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
                           left join stn.posting_method_derivation_rein psmre  on (
                                                                                        cevnid.business_unit           = psmre.le_1_cd
                                                                                    and cevnid.affiliate               = psmre.le_2_cd
                                                                                    and pdmic.legal_entity_link_typ = 'GAAP_CONSOLIDATION'
                                                                                  )
                          where
                                cevnid.generate_interco_accounting = 'Y'
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
                                  , bu_lookup
                                  , affiliate
                                  , owner_le_cd
                                  , counterparty_le_cd
                                  , ledger_cd
                                  , vie_cd
                                  , vie_status
                                  , vie_effective_dt
                                  , vie_acct_dt
                                  , is_mark_to_market
                                  , tax_jurisdiction_cd
                                  , chartfield_cd chartfield_1
                                  , transaction_ccy
                                  , transaction_amt
                                  , functional_ccy
                                  , functional_amt
                                  , reporting_ccy
                                  , reporting_amt
                                  , lpg_id
                                  , account_cd
                                  , jl_description
                               from
                                    intercompany_data;
                v_no_cev_intercompany_data := sql%rowcount;

                dbms_stats.gather_table_stats ( ownname => 'STN' , tabname => 'CEV_INTERCOMPANY_DATA' , estimate_percent => 30 , cascade => true );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cev_intercompany_data', 'v_no_cev_intercompany_data', NULL, v_no_cev_intercompany_data, NULL);
        execute immediate 'truncate table STN.cev_vie_data';

        --    ***************************  C E V   V  I  E   D A T A   ****************************************
        --  Generates VIE events for monthly flow activity and, when applicable (derived VIE codes 2, 3, 4, or 5),
        --    balance consolidation or deconsolidation events.

        --  SUB QUERIES
        --      VIE_EVENT_CD
        --          Calc VIE_CD (1 - 6) based on VIE_STATUS and VIE_EFFECTIVE_DT
        --      VIE_DATA
        --          Set POSTING_TYPE = 'VIE'
        --          Calculate begin/end period amounts from EBA/FAK daily balance tables
        --              transaction_bop
        --              functional_bop
        --              reporting_bop
        --              transaction_eop
        --              functional_eop
        --              reporting_eop
        --          Set subevent based on posting_account_derivation
        --          Set negate flag based on posting_account_derivation
        --          Set Accounting_basis = output basis from vie_posting_method_ledger
        --          Set New VIE event type (ceating new event)
        --          Set VIE business unit as business unit
        --      VIE_HOPPER_SUM - SUM the amounts by detail from the existing HOPPER_CESSION_EVENT for 'P'rocessed data and LEDGER_CD in ('CORE','GAAP_ADJ')
        --          Set correlation_uud as MIN correlation
        --          Set event_seg_id as MIN
        --          Set row_sid as MIN message_id
        --          Set Basis_cd as 'US_GAAP'
        --          Set policy_premium_typ as 'NVS'
        --          SUM transaction_amt * -1 for REVERSE sub_event or * 1
        --          SUM functional_amt * -1 for REVERSE sub_event or * 1
        --          SUM reporting_amt * -1 for REVERSE sub_event or * 1
        --      VIE_HIST - select from VIE_HOPPER_SUM
        --          Set posting_type = 'VIE_HISTTORICAL'
        --          Set subevent = if vie_cd in (4,5) then DECONSOL otherwise NULL
        --          Set accounting_dt = VIE_ACCT_DT from insurance_policy_reference
        --          Set basis_cd = basis_cd based on VIE_POSTING_METHOD_LEDTER
        --          Set policy_premium_typ as 'NVS'
        --          Set event_type = VIE event type based on vie_posting_method_ledger
        --          Set bu_lookup = NULL
        --          Set affiliate = NULL
        --          Set ledger_cd based on vie_posting_method_ledger
        --          Set vie_cd based on VIE_EVENT_CD subquery
        --          Set vie_stastus based on VIE_EVENT_CD subquery
        --          Set transaction_amt = transaction_amt * negate_flag unless policy_premium_typ = 'S' and premium_typ not null then 0
        --          Set functional_amt = functional_amt * negate_flag unless policy_premium_typ = 'S' and premium_typ not null then 0
        --          Set reporting_amt = repoprting_amt * negate_flag unless policy_premium_typ = 'S' and premium_typ not null then 0
        --          Set reversal_indicator = NULL
        --          Set vie/acct_dt/effective_dt from insurance_policy_reference
        --          Set parent_stream_id from insurance_policy_reference
        --          Set policy_abbr_nm  from insurance_policy_reference
        --          Set fin_calc_cd from posting_financial_calc
        --      UNION ALL VIE_DATA and VIE_HIST

                insert into stn.cev_vie_data
                with vie_event_cd
                  as (
                        select distinct
                               cev_nid.stream_id     stream_id
                             , cev_nid.event_typ     event_typ
                             , cev_nid.vie_status    vie_status
                             , case
                                    when cev_nid.VIE_STATUS is null
                                         then 1
                                    when cev_nid.VIE_STATUS = 'CONSOL'
                                            and nvl( ps.status , null ) = 'O'
                                            and extract(day from cev_nid.VIE_EFFECTIVE_DT) = 1
                                         then 2
                                    when cev_nid.VIE_STATUS = 'CONSOL'
                                            and nvl( ps.status , null ) = 'O'
                                            and extract(day from cev_nid.VIE_EFFECTIVE_DT+1) = 1
                                         then 3
                                    when cev_nid.VIE_STATUS = 'CONSOL'
                                            and nvl( ps.status , null ) is null
                                         then 6
                                    when cev_nid.VIE_STATUS = 'DECONSOL'
                                            and nvl( ps.status , null ) = 'O'
                                            and extract(day from cev_nid.VIE_EFFECTIVE_DT) = 1
                                         then 4
                                    when cev_nid.VIE_STATUS = 'DECONSOL'
                                            and nvl( ps.status , null ) = 'O'
                                            and extract(day from cev_nid.VIE_EFFECTIVE_DT+1) = 1
                                         then 5
                                    when cev_nid.VIE_STATUS = 'DECONSOL'
                                            and nvl( ps.status , null ) is null
                                         then 1
                                    else 1
                               end     vie_cd
                          from
                               stn.cev_non_intercompany_data   cev_nid
                          join stn.event_hierarchy_reference   ehr      on cev_nid.event_typ                      = ehr.event_typ
                     left join stn.period_status               ps       on trunc( cev_nid.vie_acct_dt , 'MONTH' ) = trunc( ps.period_start , 'MONTH' )
                                                                       and ehr.event_class                        = ps.event_class
            where cev_nid.vie_status is not null
                     )
                , vie_data
                  as (
                         select
                                'VIE'                                           posting_type
                              , cev_nid.business_type_association_id
                              , cev_nid.intercompany_association_id
                              , cev_nid.correlation_uuid
                              , cev_nid.row_sid
                              , pacd.sub_account
                              , prpb.transaction_balance                        transaction_bop
                              , prpb.functional_balance                         functional_bop
                              , prpb.reporting_balance                          reporting_bop
                              , cupb.transaction_balance                        transaction_eop
                              , cupb.functional_balance                         functional_eop
                              , cupb.reporting_balance                          reporting_eop
                              , cev_nid.event_seq_id
                              , cev_nid.vie_acct_dt
                              , cev_nid.vie_effective_dt
                              , vpml.sub_event
                              , vpml.negate_flag
                              , pfc.fin_calc_cd
                              , cev_nid.accounting_dt
                              , cev_nid.policy_id
                              , cev_nid.policy_abbr_nm
                              , cev_nid.stream_id
                              , cev_nid.parent_stream_id
                              , cev_nid.basis_typ
                              , abasis.basis_cd                                 orig_basis_cd
                              , abasisv.basis_cd
                              , cev_nid.business_typ
                              , cev_nid.premium_typ
                              , cev_nid.policy_premium_typ
                              , cast (cev_nid.policy_accident_yr as number)     policy_accident_yr
                              , cev_nid.policy_underwriting_yr
                              , cev_nid.ultimate_parent_stream_id
                              , cev_nid.ultimate_parent_le_cd
                              , cev_nid.execution_typ
                              , cev_nid.policy_typ
                              , et.event_typ                                    orig_event_typ
                              , etv.event_typ
                              , cev_nid.business_event_typ
                              , vle.vie_le_cd                                   business_unit
                              , cev_nid.account_cd
                              , cev_nid.chartfield_cd
                              , cev_nid.jl_description
                              , cev_nid.bu_lookup                               bu_lookup
                              , null                                            affiliate
                              , cev_nid.owner_le_cd
                              , cev_nid.counterparty_le_cd
                              , vpldgr.ledger_cd
                              , vc.vie_cd
                              , vieec.vie_status
                              , cev_nid.is_mark_to_market
                              , cev_nid.tax_jurisdiction_cd
                              , cev_nid.transaction_ccy
                              , cev_nid.transaction_amt                         orig_transaction_amt
                              , cev_nid.functional_ccy
                              , cev_nid.functional_amt                          orig_functional_amt
                              , cev_nid.reporting_ccy
                              , cev_nid.reporting_amt                           orig_reporting_amt
                              , ( case
                                    when nvl(cev_nid.premium_typ,'NVS') <> 'NVS' and cev_nid.policy_premium_typ = 'S'
                                        then null
                                    when pfc.fin_calc_cd = 'BOP'
                                        then prpb.transaction_balance
                                    when pfc.fin_calc_cd = 'EOP'
                                        then cupb.transaction_balance
                                    when  pfc.fin_calc_cd = 'MONTHLY'
                                            and (   vc.vie_cd in ('2','6')
                                                or (vc.vie_cd ='3' and cev_nid.vie_acct_dt > cev_nid.vie_effective_dt)
                                                or (vc.vie_cd ='5' and cev_nid.vie_acct_dt = cev_nid.vie_effective_dt)
                                                 )
                                        then cev_nid.input_transaction_amt
                                    else null
                                    end) * vpml.negate_flag   transaction_amt
                              , ( case
                                    when nvl(cev_nid.premium_typ,'NVS') <> 'NVS' and cev_nid.policy_premium_typ = 'S'
                                        then null
                                    when pfc.fin_calc_cd = 'BOP'
                                        then prpb.functional_balance
                                    when pfc.fin_calc_cd = 'EOP'
                                        then cupb.functional_balance
                                    when  pfc.fin_calc_cd = 'MONTHLY'
                                            and (   vc.vie_cd in ('2','6')
                                                or (vc.vie_cd ='3' and cev_nid.vie_acct_dt > cev_nid.vie_effective_dt)
                                                or (vc.vie_cd ='5' and cev_nid.vie_acct_dt = cev_nid.vie_effective_dt)
                                                )
                                        then cev_nid.input_functional_amt
                                    else null
                                    end ) * vpml.negate_flag   functional_amt
                              , ( case
                                    when nvl(cev_nid.premium_typ,'NVS') <> 'NVS' and cev_nid.policy_premium_typ = 'S'
                                        then null
                                    when pfc.fin_calc_cd = 'BOP'
                                        then prpb.reporting_balance
                                    when pfc.fin_calc_cd = 'EOP'
                                        then cupb.reporting_balance
                                    when  pfc.fin_calc_cd = 'MONTHLY'
                                            and (   vc.vie_cd in ('2','6')
                                                or (vc.vie_cd ='3' and cev_nid.vie_acct_dt > cev_nid.vie_effective_dt)
                                                or (vc.vie_cd ='5' and cev_nid.vie_acct_dt = cev_nid.vie_effective_dt)
                                                )
                                        then cev_nid.input_reporting_amt
                                    else null
                                    end ) * vpml.negate_flag   reporting_amt
                              , cev_nid.lpg_id
                           from
                                     stn.cev_non_intercompany_data      cev_nid
                                join     vie_event_cd                   vieec    on cev_nid.stream_id = vieec.stream_id
                                                                                and cev_nid.event_typ = vieec.event_typ
                                join stn.vie_code                       vc       on vieec.vie_cd = vc.vie_cd
                                join stn.event_type                     et       on cev_nid.event_typ = et.event_typ
                                join stn.posting_accounting_basis       abasis   on cev_nid.basis_cd  = abasis.basis_cd
                                join stn.vie_posting_method_ledger      vpml     on abasis.basis_id         = vpml.input_basis_id
                                                                                and et.event_typ_id         = vpml.event_typ_id
                                                                                and vc.vie_id               = vpml.vie_id
                                join stn.posting_financial_calc         pfc      on vpml.fin_calc_id      = pfc.fin_calc_id
                                join stn.posting_accounting_basis       abasisv  on vpml.output_basis_id  = abasisv.basis_id
                                join stn.event_type                     etv      on vpml.vie_event_typ_id = etv.event_typ_id
                                join stn.posting_ledger                 vpldgr   on vpml.ledger_id        = vpldgr.ledger_id
                                join stn.vie_legal_entity               vle      on cev_nid.business_unit = vle.le_cd
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
                                     )                                  lvd      on vle.step_run_sid = lvd.step_run_sid
                           left join stn.posting_account_derivation      pacd    on (
                                                                                       cev_nid.ledger_cd           = pacd.posting_schema
                                                                                 and   et.event_typ                = pacd.event_typ
                                                                                 and   cev_nid.sub_event           = pacd.sub_event
                                                                                 and ( cev_nid.business_typ        = pacd.business_typ
                                                                                    or pacd.business_typ           = 'ND~' )
                                                                                 and ( cev_nid.is_mark_to_market   = pacd.is_mark_to_market
                                                                                    or pacd.is_mark_to_market      = 'ND~' )
                                                                                 and ( cev_nid.account_cd        = pacd.account_cd
                                                                                    or pacd.account_cd           = 'ND~' )
                                                                                 and ( decode ( cev_nid.business_unit
                                                                                              , 'AGFPI' , 'AGFPI'
                                                                                              , 'NULL' )           = pacd.business_unit
                                                                                    or pacd.business_unit         = 'ND~' )
                                                                                     )
                           left join stn.cev_vie_period_balances              prpb   on (
                                                                                     to_char( cev_nid.stream_id )                = to_char( prpb.stream_id )
                                                                                 and cev_nid.business_unit                       = prpb.business_unit
                                                                                 and pacd.sub_account                            = prpb.sub_account
                                                                                 and cev_nid.tax_jurisdiction_cd                 = prpb.tax_jurisdiction
                                                                                 and cev_nid.transaction_ccy                     = prpb.currency
                                                                                 and abasis.basis_cd                             = prpb.basis_cd
                                                                                 and trunc( add_months( cev_nid.vie_effective_dt , -1 ) , 'MONTH' ) = trunc( prpb.end_of_period , 'MONTH' )
                                                                                     )
                           left join stn.cev_vie_period_balances              cupb   on (
                                                                                     to_char( cev_nid.stream_id )                = to_char( cupb.stream_id )
                                                                                 and cev_nid.business_unit                       = cupb.business_unit
                                                                                 and pacd.sub_account                            = cupb.sub_account
                                                                                 and cev_nid.tax_jurisdiction_cd                 = cupb.tax_jurisdiction
                                                                                 and cev_nid.transaction_ccy                     = cupb.currency
                                                                                 and abasis.basis_cd                             = cupb.basis_cd
                                                                                 and trunc( cev_nid.vie_effective_dt , 'MONTH' ) = trunc( cupb.end_of_period , 'MONTH' )
                                                                                     )
                     )
                , vie_hopper_sum as
                     (
                         select
                                min( cast( hce.correlation_uuid as raw(16) ) )  correlation_uuid
                              , min( cast( hce.event_seq_id as number ) )       event_seq_id
                              , min( cast( hce.message_id as number ) )         row_sid
                              , hce.accounting_dt
                              , hce.policy_id
                              , min( hce.journal_descr )                        journal_descr
                              , cast( hce.stream_id as number )                 stream_id
                              , 'US_GAAP'                                       basis_cd
                              , hce.business_typ
                              , hce.premium_typ
                              , 'NVS'                                           policy_premium_typ
                              , cast( hce.accident_yr as number )               policy_accident_yr
                              , cast( hce.underwriting_yr as number )           policy_underwriting_yr
                              , hce.ultimate_parent_le_cd
                              , hce.execution_typ
                              , hce.policy_typ
                              , hce.event_typ
                              , hce.business_event_typ
                              , hce.business_unit
                              , hce.account_cd
                              , hce.chartfield_1
                              , hce.jl_description
                              , hce.affiliate_le_cd
                              , hce.owner_le_cd
                              , hce.counterparty_le_cd
                              , hce.is_mark_to_market
                              , hce.tax_jurisdiction_cd
                              , hce.transaction_ccy
                              , sum( ( case when hce.sub_event = 'REVERSE' then -1 else 1 end ) * hce.transaction_amt )  transaction_amt
                              , hce.functional_ccy
                              , sum( ( case when hce.sub_event = 'REVERSE' then -1 else 1 end ) * hce.functional_amt )   functional_amt
                              , hce.reporting_ccy
                              , sum( ( case when hce.sub_event = 'REVERSE' then -1 else 1 end ) * hce.reporting_amt )    reporting_amt
                              , hce.lpg_id
                           from
                                stn.hopper_cession_event   hce
                          where hce.ledger_cd in ( 'CORE' , 'GAAP_ADJ' )
                            and hce.event_status = 'P'
                          group by
                                hce.accounting_dt
                              , hce.policy_id
                              , hce.stream_id
                              , hce.business_typ
                              , hce.premium_typ
                              , hce.accident_yr
                              , hce.underwriting_yr
                              , hce.ultimate_parent_le_cd
                              , hce.execution_typ
                              , hce.policy_typ
                              , hce.event_typ
                              , hce.business_event_typ
                              , hce.business_unit
                              , hce.account_cd
                              , hce.affiliate_le_cd
                              , hce.owner_le_cd
                              , hce.counterparty_le_cd
                              , hce.is_mark_to_market
                              , hce.tax_jurisdiction_cd
                              , hce.chartfield_1
                              , hce.jl_description
                              , hce.transaction_ccy
                              , hce.functional_ccy
                              , hce.reporting_ccy
                              , hce.lpg_id
                          )
                , vie_hist as
                     (
                         select
                                'VIE_HISTORICAL'                                posting_type
                              , vhop.correlation_uuid
                              , vhop.event_seq_id
                              , vhop.row_sid
                              , case vc.vie_cd
                                  when 4 then 'DECONSOL'
                                  when 5 then 'DECONSOL'
                                  else 'NULL'
                                end                                             sub_event
                              , ipr.vie_acct_dt                                 accounting_dt
                              , vhop.policy_id
                              , vhop.journal_descr
                              , vhop.stream_id
                              , abasisv.basis_cd
                              , vhop.business_typ
                              , vhop.premium_typ
                              , 'NVS'                                           policy_premium_typ
                              , vhop.policy_accident_yr
                              , vhop.policy_underwriting_yr
                              , vhop.ultimate_parent_le_cd
                              , vhop.execution_typ
                              , vhop.policy_typ
                              , etv.event_typ
                              , vhop.business_event_typ
                              , vle.vie_le_cd                                   business_unit
                              , vhop.account_cd
                              , null                                            bu_lookup
                              , null                                            affiliate
                              , vhop.owner_le_cd
                              , vhop.counterparty_le_cd
                              , vpldgr.ledger_cd
                              , cast( vc.vie_cd as number )                     vie_cd
                              , vieec.vie_status
                              , vhop.is_mark_to_market
                              , vhop.tax_jurisdiction_cd
                              , vhop.chartfield_1
                              , vhop.jl_description
                              , vhop.transaction_ccy
                              , case
                                    when vhop.premium_typ is not null and ipr.policy_premium_typ='S' then 0
                                    else vhop.transaction_amt * vpml.negate_flag
                                    end transaction_amt
                              , vhop.functional_ccy
                              , case
                                    when vhop.premium_typ is not null and ipr.policy_premium_typ='S' then 0
                                    else vhop.functional_amt * vpml.negate_flag
                                    end functional_amt
                              , vhop.reporting_ccy
                              , case
                                    when vhop.premium_typ is not null and ipr.policy_premium_typ='S' then 0
                                    else vhop.reporting_amt * vpml.negate_flag
                                    end reporting_amt
                              , vhop.lpg_id
                              , null reversal_indicator
                              , ipr.vie_acct_dt
                              , ipr.vie_effective_dt
                              , ipr.ultimate_parent_stream_id
                              , cast( ipr.parent_stream_id as number )          parent_stream_id
                              , ipr.policy_abbr_nm
                              , pfc.fin_calc_cd
                           from
                                vie_hopper_sum                     vhop
                           join stn.insurance_policy_reference     ipr      on to_char( vhop.stream_id ) = to_char( ipr.stream_id )
                           join     vie_event_cd                   vieec    on to_char( vhop.stream_id ) = to_char( vieec.stream_id )
                                                                           and vhop.event_typ            = vieec.event_typ
                           join stn.vie_code                       vc       on vieec.vie_cd              = vc.vie_cd
                           join stn.event_type                     et       on vhop.event_typ            = et.event_typ
                           join stn.posting_accounting_basis       abasis   on vhop.basis_cd             = abasis.basis_cd
                           join stn.vie_posting_method_ledger      vpml     on abasis.basis_id           = vpml.input_basis_id
                                                                           and et.event_typ_id           = vpml.event_typ_id
                                                                           and '6'                       = vpml.vie_id
                           join stn.posting_financial_calc         pfc      on vpml.fin_calc_id          = pfc.fin_calc_id
                           join stn.posting_accounting_basis       abasisv  on vpml.output_basis_id      = abasisv.basis_id
                           join stn.event_type                     etv      on vpml.vie_event_typ_id     = etv.event_typ_id
                           join stn.posting_ledger                 vpldgr   on vpml.ledger_id            = vpldgr.ledger_id
                           join stn.vie_legal_entity               vle      on vhop.business_unit        = vle.le_cd
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
                                )                                  lvd      on vle.step_run_sid = lvd.step_run_sid
                          where
                                vc.vie_cd                                   in ( '2' , '3' , '4' , '5' )
                            and trunc( ipr.vie_effective_dt + 1 , 'MONTH' ) <= trunc( vhop.accounting_dt , 'MONTH' )
                            and trunc( ipr.vie_acct_dt , 'MONTH' )          >  trunc( vhop.accounting_dt , 'MONTH' )
                            and (
                                    (   pfc.fin_calc_cd in ( 'MONTHLY' , 'EOP' )
                                    and vpml.sub_event = 'NULL' )
                                 or (   pfc.fin_calc_cd in ( 'MONTHLY' , 'BOP' )
                                    and vpml.sub_event = 'DECONSOL' )
                                )
                            and not exists ( select null
                                               from stn.hopper_cession_event     hce2
                                              where hce2.posting_indicator = 'VIE_HISTORICAL'
                                                and hce2.correlation_uuid  = vhop.correlation_uuid
                                                and hce2.event_seq_id      = vhop.event_seq_id
                                                and hce2.event_typ         = etv.event_typ
                                                and hce2.ledger_cd         = vpldgr.ledger_cd
                                                and hce2.accounting_dt     = ipr.vie_acct_dt )
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
                     , null generate_interco_accounting
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
                     , bu_lookup
                     , affiliate
                     , owner_le_cd
                     , counterparty_le_cd
                     , ledger_cd
                     , vie_cd
                     , vie_status
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
                     , account_cd
                     , jl_description
                  from
                       vie_data
                union all
                select
                       posting_type
                     , null business_type_association_id
                     , null intercompany_association_id
                     , correlation_uuid
                     , event_seq_id
                     , row_sid
                     , sub_event
                     , accounting_dt
                     , policy_id
                     , policy_abbr_nm
                     , stream_id
                     , parent_stream_id
                     , null basis_typ
                     , basis_cd
                     , business_typ
                     , null generate_interco_accounting
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
                     , bu_lookup
                     , affiliate
                     , owner_le_cd
                     , counterparty_le_cd
                     , ledger_cd
                     , vie_cd
                     , vie_status
                     , vie_effective_dt
                     , vie_acct_dt
                     , is_mark_to_market
                     , tax_jurisdiction_cd
                     , chartfield_1
                     , transaction_ccy
                     , transaction_amt
                     , functional_ccy
                     , functional_amt
                     , reporting_ccy
                     , reporting_amt
                     , lpg_id
                     , account_cd
                     , jl_description
                  from
                       vie_hist
                ;
                v_no_cev_vie_data := sql%rowcount;

                dbms_stats.gather_table_stats ( ownname => 'STN' , tabname => 'CEV_VIE_DATA' , estimate_percent => 30 , cascade => true );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed cev_vie_data', 'v_no_cev_vie_data', NULL, v_no_cev_vie_data, NULL);

--INSERT INTO HOPPER_CESSION_EVENT FROM CESSION_EVENT_POSTING
--    WHERE transaction + functional + reporting amounts <> 0
--    CESSION_EVENT_POSTING:
--            CEV_NON_INTERCOMPANY_DATA
--                UNION ALL
--            CEV_INTERCOMPANY_DATA
--                UNION ALL
--            CEV_VIE_DATA
--    HOPPER INSERT:
--        Set premium_typ  = IF 'M' THEN 'I' else premiuim_typ
--        Set transaction_pos_neg = IF transaction_amt/functional/reporting > 0 THEN 'POS" ELSE 'NEG'
--        Set dept_cd = if event_typ in ('DAC_CC_CAP_DEF', 'VIECC_DAC_CAP_DEF', 'VIECD_DAC_CAP_DEF','VIECF_DAC_CAP_DEF') then '4001' else NULL
--        Set posting_dt = GP_TODAYS_BUS_DATE
--        Set process_id = step_run_sid
--        Set effective_dt = earliest of Todays Business Date or Accounting Date
--        Set bu_account_lookup = IF bu_lookup in fr_account_lookup then bu_lookup else NULL
--        Set vie_bu_account_lookup = IF business_unit in fr_account_lookup then bussiness_unit else NULL

        INSERT /*+ APPEND */ INTO HOPPER_CESSION_EVENT
            (BUSINESS_UNIT, AFFILIATE_LE_CD, ACCOUNTING_DT, ACCIDENT_YR, UNDERWRITING_YR, POLICY_ID, ULTIMATE_PARENT_LE_CD, TAX_JURISDICTION_CD, EVENT_TYP, TRANSACTION_CCY, TRANSACTION_AMT, BUSINESS_TYP, POLICY_TYP, PREMIUM_TYP, SUB_EVENT, IS_MARK_TO_MARKET, VIE_CD, LPG_ID, PARTY_BUSINESS_LE_CD, PARTY_BUSINESS_SYSTEM_CD, AAH_EVENT_TYP, SRAE_STATIC_SYS_INST_CODE, SRAE_INSTR_SYS_INST_CODE, TRANSACTION_POS_NEG, SRAE_GL_PERSON_CODE, DEPT_CD, SRAE_SOURCE_SYSTEM, SRAE_INSTR_SUPER_CLASS, SRAE_INSTRUMENT_CODE, LEDGER_CD, STREAM_ID, POSTING_DT, BOOK_CD, CORRELATION_UUID, CHARTFIELD_1, COUNTERPARTY_LE_CD, EXECUTION_TYP, OWNER_LE_CD, JOURNAL_DESCR, FUNCTIONAL_CCY, FUNCTIONAL_AMT, REPORTING_CCY, REPORTING_AMT, BUSINESS_EVENT_TYP, EVENT_SEQ_ID, BASIS_CD, POSTING_INDICATOR, MESSAGE_ID, PROCESS_ID, EFFECTIVE_DT, JL_DESCRIPTION, BU_ACCOUNT_LOOKUP, VIE_BU_ACCOUNT_LOOKUP, ACCOUNT_CD)
            SELECT
                cep.BUSINESS_UNIT AS BUSINESS_UNIT,
                case
when cep.EVENT_TYP not in ('DAC_CC_CONS_ADJUST', 'CONSOL_DAC_AMORT', 'CONSOL_CC_CAP_DEF')
then cep.AFFILIATE
else null
end
 AS AFFILIATE_LE_CD,
                trunc(cep.ACCOUNTING_DT) AS ACCOUNTING_DT,
                cep.POLICY_ACCIDENT_YR AS ACCIDENT_YR,
                cep.POLICY_UNDERWRITING_YR AS UNDERWRITING_YR,
                cep.POLICY_ID AS POLICY_ID,
                cep.ULTIMATE_PARENT_LE_CD AS ULTIMATE_PARENT_LE_CD,
                cep.TAX_JURISDICTION_CD AS TAX_JURISDICTION_CD,
                cep.EVENT_TYP AS EVENT_TYP,
                cep.TRANSACTION_CCY AS TRANSACTION_CCY,
                ROUND(NVL(cep.TRANSACTION_AMT, 0), 2) AS TRANSACTION_AMT,
                cep.BUSINESS_TYP AS BUSINESS_TYP,
                cep.POLICY_TYP AS POLICY_TYP,
                case
when cep.PREMIUM_TYP = 'M' then 'I'
else cep.PREMIUM_TYP
end AS PREMIUM_TYP,
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
                    WHEN ROUND(NVL(cep.TRANSACTION_AMT, 0), 2) > 0 THEN 'POS'
                    WHEN ROUND(NVL(cep.TRANSACTION_AMT, 0), 2) < 0 THEN 'NEG'
                    WHEN ROUND(NVL(cep.FUNCTIONAL_AMT, 0), 2) > 0 THEN 'POS'
                    WHEN ROUND(NVL(cep.FUNCTIONAL_AMT, 0), 2) < 0 THEN 'NEG'
                    WHEN ROUND(NVL(cep.REPORTING_AMT, 0), 2) > 0 THEN 'POS'
                    ELSE 'NEG'
                END) AS TRANSACTION_POS_NEG,
                ce_default.SRAE_GL_PERSON_CODE AS SRAE_GL_PERSON_CODE,
                case
when cep.EVENT_TYP in ( 'DAC_CC_CAP_DEF'
                      , 'VIECC_DAC_CAP_DEF'
                      , 'VIECD_DAC_CAP_DEF'
                      , 'VIECF_DAC_CAP_DEF' )
then '4001'
else null
end AS DEPT_CD,
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
                ROUND(NVL(cep.FUNCTIONAL_AMT, 0), 2) AS FUNCTIONAL_AMT,
                cep.REPORTING_CCY AS REPORTING_CCY,
                ROUND(NVL(cep.REPORTING_AMT, 0), 2) AS REPORTING_AMT,
                cep.BUSINESS_EVENT_TYP AS BUSINESS_EVENT_TYP,
                cep.EVENT_SEQ_ID AS EVENT_SEQ_ID,
                cep.BASIS_CD AS BASIS_CD,
                cep.POSTING_TYPE AS POSTING_INDICATOR,
                cep.ROW_SID AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                trunc(LEAST( gp.GP_TODAYS_BUS_DATE , cep.ACCOUNTING_DT )) AS EFFECTIVE_DT,
                cep.JL_DESCRIPTION,
                case
when exists ( select
                     null
                from
                     fdr.fr_account_lookup fal
               where
                     fal.al_lookup_3 = cep.bu_lookup
                 and sysdate between fal.al_valid_from and fal.al_valid_to
             )
then cep.bu_lookup
else 'NULL'
end AS BU_ACCOUNT_LOOKUP,
                case
when exists ( select
                     null
                from
                     fdr.fr_account_lookup fal
               where
                     fal.al_lookup_4 = cep.BUSINESS_UNIT
                 and sysdate between fal.al_valid_from and fal.al_valid_to
             )
then cep.BUSINESS_UNIT
else 'NULL'
end AS VIE_BU_ACCOUNT_LOOKUP,
                cep.ACCOUNT_CD AS ACCOUNT_CD
            FROM
                CESSION_EVENT_POSTING cep
                INNER JOIN CE_DEFAULT ON 1 = 1
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON cep.LPG_ID = gp.LPG_ID
            WHERE
                (ROUND(cep.TRANSACTION_AMT, 2) <> 0 OR ROUND(cep.FUNCTIONAL_AMT, 2) <> 0 OR ROUND(cep.REPORTING_AMT, 2) <> 0);
        p_no_published_records := SQL%ROWCOUNT;
	commit;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed inserting cession events into hopper', 'p_no_published_records', NULL, p_no_published_records, NULL);

--INSERT INTO HOPPER_CESSION_EVENT FROM CESSION_EVENT_REVERSAL_HIST
--    WHERE transaction + functional + reporting amounts <> 0
--    CESSION_EVENT_REVERSAL_HIST:
--        joins HOPPER and CESSION_EVENT_POSTING to SLR_JRNL_LINES
--        Set posting_type = 'REVERSE_REPOST'
--        Set Accounting = CEP.accounting_dt
--        Set policy_premium_typ = 'NVS'
--        Set transaction_amt = transaction_amt * -1
--        Set functional_amt = functional_amt * -1
--        Set reporting_amt = reporting_amt * -1
--    HOPPER INSERT:
--            Set affiliate_le_cd = IF event_typ not in ('DAC_CC_CONS_ADJUST', 'CONSOL_DAC_AMORT', 'CONSOL_CC_CAP_DEF')    then Affiliate else NULL
--            Set premium_typ  = IF 'M' THEN 'I' else premiuim_typ
--            Set transaction_pos_neg = IF transaction_amt/functional/reporting > 0 THEN 'POS" ELSE 'NEG'
--            Set dept_cd = if event_typ in ('DAC_CC_CAP_DEF', 'VIECC_DAC_CAP_DEF', 'VIECD_DAC_CAP_DEF','VIECF_DAC_CAP_DEF') then '4001' else NULL
--            Set posting_dt = GP_TODAYS_BUS_DATE
--            Set posting_indicator = 'REVERSE_REPOST'
--          Set process_id = step_run_sid
--          Set effective_dt = earliest of Todays Business Date or Accounting Date



        INSERT /*+ APPEND */ INTO HOPPER_CESSION_EVENT
            (BUSINESS_UNIT, AFFILIATE_LE_CD, ACCOUNTING_DT, ACCIDENT_YR, UNDERWRITING_YR, POLICY_ID, ULTIMATE_PARENT_LE_CD, TAX_JURISDICTION_CD, EVENT_TYP, TRANSACTION_CCY, TRANSACTION_AMT, BUSINESS_TYP, POLICY_TYP, PREMIUM_TYP, SUB_EVENT, IS_MARK_TO_MARKET, VIE_CD, LPG_ID, PARTY_BUSINESS_LE_CD, PARTY_BUSINESS_SYSTEM_CD, AAH_EVENT_TYP, SRAE_STATIC_SYS_INST_CODE, SRAE_INSTR_SYS_INST_CODE, TRANSACTION_POS_NEG, SRAE_GL_PERSON_CODE, DEPT_CD, SRAE_SOURCE_SYSTEM, SRAE_INSTR_SUPER_CLASS, SRAE_INSTRUMENT_CODE, LEDGER_CD, STREAM_ID, POSTING_DT, BOOK_CD, CORRELATION_UUID, CHARTFIELD_1, COUNTERPARTY_LE_CD, EXECUTION_TYP, OWNER_LE_CD, JOURNAL_DESCR, FUNCTIONAL_CCY, FUNCTIONAL_AMT, REPORTING_CCY, REPORTING_AMT, BUSINESS_EVENT_TYP, EVENT_SEQ_ID, BASIS_CD, POSTING_INDICATOR, MESSAGE_ID, PROCESS_ID, EFFECTIVE_DT, JL_DESCRIPTION, BU_ACCOUNT_LOOKUP, VIE_BU_ACCOUNT_LOOKUP, ORIGINAL_POSTING_DT,ACCOUNT_CD)
            SELECT
                cerhist.BUSINESS_UNIT AS BUSINESS_UNIT,
                case
when cerhist.EVENT_TYP not in ('DAC_CC_CONS_ADJUST', 'CONSOL_DAC_AMORT', 'CONSOL_CC_CAP_DEF')
then cerhist.AFFILIATE
else null
end
 AS AFFILIATE_LE_CD,
                trunc(cerhist.ACCOUNTING_DT) AS ACCOUNTING_DT,
                cerhist.POLICY_ACCIDENT_YR AS ACCIDENT_YR,
                cerhist.POLICY_UNDERWRITING_YR AS UNDERWRITING_YR,
                cerhist.POLICY_ID AS POLICY_ID,
                cerhist.ULTIMATE_PARENT_LE_CD AS ULTIMATE_PARENT_LE_CD,
                cerhist.TAX_JURISDICTION_CD AS TAX_JURISDICTION_CD,
                cerhist.EVENT_TYP AS EVENT_TYP,
                cerhist.TRANSACTION_CCY AS TRANSACTION_CCY,
                ROUND(NVL(cerhist.TRANSACTION_AMT, 0), 2) AS TRANSACTION_AMT,
                cerhist.BUSINESS_TYP AS BUSINESS_TYP,
                cerhist.POLICY_TYP AS POLICY_TYP,
                case
when cerhist.PREMIUM_TYP = 'M' then 'I'
else cerhist.PREMIUM_TYP
end  AS PREMIUM_TYP,
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
                    WHEN ROUND(NVL(cerhist.TRANSACTION_AMT, 0), 2) > 0 THEN 'POS'
                    WHEN ROUND(NVL(cerhist.TRANSACTION_AMT, 0), 2) < 0 THEN 'NEG'
                    WHEN ROUND(NVL(cerhist.FUNCTIONAL_AMT, 0), 2) > 0 THEN 'POS'
                    WHEN ROUND(NVL(cerhist.FUNCTIONAL_AMT, 0), 2) < 0 THEN 'NEG'
                    WHEN ROUND(NVL(cerhist.REPORTING_AMT, 0), 2) > 0 THEN 'POS'
                    ELSE 'NEG'
                END) AS TRANSACTION_POS_NEG,
                ce_default.SRAE_GL_PERSON_CODE AS SRAE_GL_PERSON_CODE,
                case
when cerhist.EVENT_TYP in ( 'DAC_CC_CAP_DEF'
                          , 'VIECC_DAC_CAP_DEF'
                          , 'VIECD_DAC_CAP_DEF'
                          , 'VIECF_DAC_CAP_DEF' )
then '4001'
else null
end AS DEPT_CD,
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
                ROUND(NVL(cerhist.FUNCTIONAL_AMT, 0), 2) AS FUNCTIONAL_AMT,
                cerhist.REPORTING_CCY AS REPORTING_CCY,
                ROUND(NVL(cerhist.REPORTING_AMT, 0), 2) AS REPORTING_AMT,
                cerhist.BUSINESS_EVENT_TYP AS BUSINESS_EVENT_TYP,
                cerhist.EVENT_SEQ_ID AS EVENT_SEQ_ID,
                cerhist.BASIS_CD AS BASIS_CD,
                'REVERSE_REPOST' AS POSTING_INDICATOR,
                cerhist.ROW_SID AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                trunc(LEAST( gp.GP_TODAYS_BUS_DATE , cerhist.ACCOUNTING_DT )) AS EFFECTIVE_DT,
		        cerhist.JL_DESCRIPTION,
                cerhist.BU_LOOKUP AS BU_ACCOUNT_LOOKUP,
                cerhist.VIE_BU_LOOKUP AS VIE_BU_ACCOUNT_LOOKUP,
                cerhist.ORIGINAL_POSTING_DT AS ORIGINAL_POSTING_DT,
                cerhist.account_cd
            FROM
                CESSION_EVENT_REVERSAL_HIST cerhist
                INNER JOIN CE_DEFAULT ON 1 = 1
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON cerhist.LPG_ID = gp.LPG_ID
            WHERE
                (ROUND(cerhist.TRANSACTION_AMT, 2) <> 0 OR ROUND(cerhist.FUNCTIONAL_AMT, 2) <> 0 OR ROUND(cerhist.REPORTING_AMT, 2) <> 0);
        p_no_pub_rev_hist_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed inserting historical reversal records into hopper', 'p_no_pub_rev_hist_records', NULL, p_no_pub_rev_hist_records, NULL);
        commit;

--INSERT INTO HOPPER_CESSION_EVENT FROM CESSION_EVENT_REVERSAL_CURR
--    CESSION_EVENT_REVERSAL_CURR:
--
--        Joins CEP (cession event posting) Where not event_class = 'CASH_TXN' with CEV_VALID where event_status = 'V'  for current feed
--            Set posting_type = 'REVERSE_REPOST'
--            Set reversal_indicator = NULL
--    Set affiliate_le_cd = IF event_typ not in ('DAC_CC_CONS_ADJUST', 'CONSOL_DAC_AMORT', 'CONSOL_CC_CAP_DEF')    then Affiliate else NULL
--    Set premium_typ  = IF 'M' THEN 'I' else premiuim_typ
--    Set transaction_pos_neg = IF transaction_amt/functional/reporting > 0 THEN 'POS" ELSE 'NEG'
--    Set dept_cd = if event_typ in ('DAC_CC_CAP_DEF', 'VIECC_DAC_CAP_DEF', 'VIECD_DAC_CAP_DEF','VIECF_DAC_CAP_DEF') then '4001' else NULL
--    Set posting_dt = GP_TODAYS_BUS_DATE
--    Set posting_indicator = 'REVERSE_REPOST'
--    Set process_id = step_run_sid
--    Set effective_dt = earliest of Todays Business Date or Accounting Date
--    Set bu_account_lookup = IF bu_lookup in fr_account_lookup then bu_lookup else NULL
--    Set vie_bu_account_lookup = IF business_unit in fr_account_lookup then business_unit else NULL

        INSERT /*+ parallel(8) */ INTO HOPPER_CESSION_EVENT
            (BUSINESS_UNIT, AFFILIATE_LE_CD, ACCOUNTING_DT, ACCIDENT_YR, UNDERWRITING_YR, POLICY_ID, ULTIMATE_PARENT_LE_CD, TAX_JURISDICTION_CD, EVENT_TYP, TRANSACTION_CCY, TRANSACTION_AMT, BUSINESS_TYP, POLICY_TYP, PREMIUM_TYP, SUB_EVENT, IS_MARK_TO_MARKET, VIE_CD, LPG_ID, PARTY_BUSINESS_LE_CD, PARTY_BUSINESS_SYSTEM_CD, AAH_EVENT_TYP, SRAE_STATIC_SYS_INST_CODE, SRAE_INSTR_SYS_INST_CODE, TRANSACTION_POS_NEG, SRAE_GL_PERSON_CODE, DEPT_CD, SRAE_SOURCE_SYSTEM, SRAE_INSTR_SUPER_CLASS, SRAE_INSTRUMENT_CODE, LEDGER_CD, STREAM_ID, POSTING_DT, BOOK_CD, CORRELATION_UUID, CHARTFIELD_1, COUNTERPARTY_LE_CD, EXECUTION_TYP, OWNER_LE_CD, JOURNAL_DESCR, FUNCTIONAL_CCY, FUNCTIONAL_AMT, REPORTING_CCY, REPORTING_AMT, BUSINESS_EVENT_TYP, EVENT_SEQ_ID, BASIS_CD, POSTING_INDICATOR, MESSAGE_ID, PROCESS_ID, EFFECTIVE_DT, JL_DESCRIPTION, BU_ACCOUNT_LOOKUP, VIE_BU_ACCOUNT_LOOKUP, ACCOUNT_CD)
            SELECT
                cercurr.BUSINESS_UNIT AS BUSINESS_UNIT,
                case
when cercurr.EVENT_TYP not in ('DAC_CC_CONS_ADJUST', 'CONSOL_DAC_AMORT', 'CONSOL_CC_CAP_DEF')
then cercurr.AFFILIATE
else null
end
 AS AFFILIATE_LE_CD,
                trunc(cercurr.ACCOUNTING_DT) AS ACCOUNTING_DT,
                cercurr.POLICY_ACCIDENT_YR AS ACCIDENT_YR,
                cercurr.POLICY_UNDERWRITING_YR AS UNDERWRITING_YR,
                cercurr.POLICY_ID AS POLICY_ID,
                cercurr.ULTIMATE_PARENT_LE_CD AS ULTIMATE_PARENT_LE_CD,
                cercurr.TAX_JURISDICTION_CD AS TAX_JURISDICTION_CD,
                cercurr.EVENT_TYP AS EVENT_TYP,
                cercurr.TRANSACTION_CCY AS TRANSACTION_CCY,
                ROUND(NVL(cercurr.TRANSACTION_AMT, 0), 2) AS TRANSACTION_AMT,
                cercurr.BUSINESS_TYP AS BUSINESS_TYP,
                cercurr.POLICY_TYP AS POLICY_TYP,
                case
when cercurr.PREMIUM_TYP = 'M' then 'I'
else cercurr.PREMIUM_TYP
end  AS PREMIUM_TYP,
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
                    WHEN ROUND(NVL(cercurr.TRANSACTION_AMT, 0), 2) > 0 THEN 'POS'
                    WHEN ROUND(NVL(cercurr.TRANSACTION_AMT, 0), 2) < 0 THEN 'NEG'
                    WHEN ROUND(NVL(cercurr.FUNCTIONAL_AMT, 0), 2) > 0 THEN 'POS'
                    WHEN ROUND(NVL(cercurr.FUNCTIONAL_AMT, 0), 2) < 0 THEN 'NEG'
                    WHEN ROUND(NVL(cercurr.REPORTING_AMT, 0), 2) > 0 THEN 'POS'
                    ELSE 'NEG'
                END) AS TRANSACTION_POS_NEG,
                ce_default.SRAE_GL_PERSON_CODE AS SRAE_GL_PERSON_CODE,
                case
when cercurr.EVENT_TYP in ( 'DAC_CC_CAP_DEF'
                          , 'VIECC_DAC_CAP_DEF'
                          , 'VIECD_DAC_CAP_DEF'
                          , 'VIECF_DAC_CAP_DEF' )
then '4001'
else null
end AS DEPT_CD,
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
                ROUND(NVL(cercurr.FUNCTIONAL_AMT, 0), 2) AS FUNCTIONAL_AMT,
                cercurr.REPORTING_CCY AS REPORTING_CCY,
                ROUND(NVL(cercurr.REPORTING_AMT, 0), 2) AS REPORTING_AMT,
                cercurr.BUSINESS_EVENT_TYP AS BUSINESS_EVENT_TYP,
                cercurr.EVENT_SEQ_ID AS EVENT_SEQ_ID,
                cercurr.BASIS_CD AS BASIS_CD,
                'REVERSE_REPOST' AS POSTING_INDICATOR,
                cercurr.ROW_SID AS MESSAGE_ID,
                TO_CHAR(p_step_run_sid) AS PROCESS_ID,
                trunc(LEAST( gp.GP_TODAYS_BUS_DATE , cercurr.ACCOUNTING_DT )) AS EFFECTIVE_DT,
		cercurr.JL_DESCRIPTION,
                case
when exists ( select
                     null
                from
                     fdr.fr_account_lookup fal
               where
                     fal.al_lookup_3 = cercurr.BU_LOOKUP
                 and sysdate between fal.al_valid_from and fal.al_valid_to
             )
then cercurr.BU_LOOKUP
else 'NULL'
end AS BU_ACCOUNT_LOOKUP,
                case
when exists ( select
                     null
                from
                     fdr.fr_account_lookup fal
               where
                     fal.al_lookup_4 = cercurr.BUSINESS_UNIT
                 and sysdate between fal.al_valid_from and fal.al_valid_to
             )
then cercurr.BUSINESS_UNIT
else 'NULL'
end AS VIE_BU_ACCOUNT_LOOKUP,
cercurr.account_cd AS ACCOUNT_CD
            FROM
                CESSION_EVENT_REVERSAL_CURR cercurr
                INNER JOIN CE_DEFAULT ON 1 = 1
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON cercurr.LPG_ID = gp.LPG_ID
            WHERE
                (ROUND(cercurr.TRANSACTION_AMT, 2) <> 0 OR ROUND(cercurr.FUNCTIONAL_AMT, 2) <> 0 OR ROUND(cercurr.REPORTING_AMT, 2) <> 0);
        p_no_pub_rev_curr_records := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed inserting current reversal records into hopper', 'p_no_pub_rev_curr_records', NULL, p_no_pub_rev_curr_records, NULL);
   commit;
    END;

    PROCEDURE pr_cession_event_rval
        (
            p_step_run_sid IN NUMBER
        )
    AS
    BEGIN
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : ce-stream_id', NULL, NULL, NULL, NULL);
        INSERT /*+ APPEND */ INTO CEV_STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, TODAYS_BUSINESS_DT, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                ce.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                TO_CHAR(ce.STREAM_ID) AS ERROR_VALUE,
                ce.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                gp.GP_TODAYS_BUS_DATE AS TODAYS_BUSINESS_DT,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN CEV_IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                LEFT OUTER JOIN fdr.fr_trade ipr ON ce.STREAM_ID = ipr.t_source_tran_no
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                  ce.EVENT_STATUS='U' and
               ipr.t_source_tran_no is null
                    and vdl.VALIDATION_CD = 'ce-stream_id';
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : ce-stream_id', 'sql%rowcount', NULL, sql%rowcount, NULL);
	commit;

        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : ce-basis_cd', NULL, NULL, NULL, NULL);
        INSERT /*+ APPEND */ INTO CEV_STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, TODAYS_BUSINESS_DT, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                ce.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                ce.BASIS_CD AS ERROR_VALUE,
                ce.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                gp.GP_TODAYS_BUS_DATE AS TODAYS_BUSINESS_DT,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN CEV_IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
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
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : ce-basis_cd', 'sql%rowcount', NULL, sql%rowcount, NULL);
commit;


pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : ce-acct_cd', NULL, NULL, NULL, NULL);
        INSERT /*+ APPEND */ INTO CEV_STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, TODAYS_BUSINESS_DT, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                ce.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                ce.ACCOUNT_CD AS ERROR_VALUE,
                ce.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                gp.GP_TODAYS_BUS_DATE AS TODAYS_BUSINESS_DT,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN CEV_IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ce-acct_cd'
and
( ce.ACCOUNT_CD is not NULL AND
not exists (
                   select null
                   from
                          fdr.fr_account_lookup fgal
                    where
                          fgal.al_lookup_5        = ce.ACCOUNT_CD
                                     )
                                     );
pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : ce-acct_cd', 'sql%rowcount', NULL, sql%rowcount, NULL);
commit;

        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : ce-transaction_ccy', NULL, NULL, NULL, NULL);
        INSERT /*+ APPEND */ INTO CEV_STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, TODAYS_BUSINESS_DT, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                ce.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                ce.TRANSACTION_CCY AS ERROR_VALUE,
                ce.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                gp.GP_TODAYS_BUS_DATE AS TODAYS_BUSINESS_DT,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN CEV_IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
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
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : ce-transaction_ccy', 'sql%rowcount', NULL, sql%rowcount, NULL);
commit;

        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : ce-functional_ccy', NULL, NULL, NULL, NULL);
        INSERT /*+ APPEND */ INTO CEV_STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, TODAYS_BUSINESS_DT, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                ce.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                ce.FUNCTIONAL_CCY AS ERROR_VALUE,
                ce.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                gp.GP_TODAYS_BUS_DATE AS TODAYS_BUSINESS_DT,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN CEV_IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
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
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : ce-functional_ccy', 'sql%rowcount', NULL, sql%rowcount, NULL);
commit;

        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : ce-reporting_ccy', NULL, NULL, NULL, NULL);
        INSERT /*+ APPEND */ INTO CEV_STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, TODAYS_BUSINESS_DT, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                ce.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                ce.REPORTING_CCY AS ERROR_VALUE,
                ce.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                gp.GP_TODAYS_BUS_DATE AS TODAYS_BUSINESS_DT,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN CEV_IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
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
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : ce-reporting_ccy', 'sql%rowcount', NULL, sql%rowcount, NULL);
commit;

        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : ce-trans_vs_reporting_amt', NULL, NULL, NULL, NULL);
        INSERT /*+ APPEND */ INTO CEV_STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, TODAYS_BUSINESS_DT, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                ce.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                to_char(ce.TRANSACTION_amt)||' vs '||to_char(ce.REPORTING_amt) AS ERROR_VALUE,
                ce.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                gp.GP_TODAYS_BUS_DATE AS TODAYS_BUSINESS_DT,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN CEV_IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN CE_DEFAULT ced ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ce-trans_vs_reporting_amt'
                and ce.transaction_ccy = ce.reporting_ccy and
                ce.transaction_amt <> ce.reporting_amt and ce.reporting_amt <> 0;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : ce-trans_vs_reporting_amt', 'sql%rowcount', NULL, sql%rowcount, NULL);
commit;

        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : ce-trans_vs_functional_amt', NULL, NULL, NULL, NULL);
        INSERT /*+ APPEND */ INTO CEV_STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, TODAYS_BUSINESS_DT, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                ce.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                to_char(ce.TRANSACTION_amt)||' vs '||to_char(ce.FUNCTIONAL_amt) AS ERROR_VALUE,
                ce.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                gp.GP_TODAYS_BUS_DATE AS TODAYS_BUSINESS_DT,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN CEV_IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN CE_DEFAULT ced ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ce-trans_vs_functional_amt'
                and ce.transaction_ccy = ce.functional_ccy and
                ce.transaction_amt <> ce.functional_amt and ce.functional_amt <> 0;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : ce-trans_vs_functional_amt', 'sql%rowcount', NULL, sql%rowcount, NULL);
commit;

        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : ce-reporting_vs_func_amt', NULL, NULL, NULL, NULL);
        INSERT /*+ APPEND */ INTO CEV_STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, TODAYS_BUSINESS_DT, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                ce.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                to_char(ce.REPORTING_amt)||' vs '||to_char(ce.FUNCTIONAL_amt) AS ERROR_VALUE,
                ce.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                gp.GP_TODAYS_BUS_DATE AS TODAYS_BUSINESS_DT,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN CEV_IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN CE_DEFAULT ced ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ce-reporting_vs_func_amt'
                and ce.reporting_ccy = ce.functional_ccy and
                ce.reporting_amt <> ce.functional_amt and
                 0 <> (case when ce.reporting_ccy = 'USD'
                        then ce.functional_amt
                        else
                        ce.reporting_amt
                        end
                        );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : ce-reporting_vs_func_amt', 'sql%rowcount', NULL, sql%rowcount, NULL);
commit;

        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : ce-event_typ', NULL, NULL, NULL, NULL);
        INSERT /*+ APPEND */ INTO CEV_STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, TODAYS_BUSINESS_DT, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                ce.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                ce.EVENT_TYP AS ERROR_VALUE,
                ce.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                gp.GP_TODAYS_BUS_DATE AS TODAYS_BUSINESS_DT,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN CEV_IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
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
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : ce-event_typ', 'sql%rowcount', NULL, sql%rowcount, NULL);
commit;
	        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : ce-event-hier', NULL, NULL, NULL, NULL);
        INSERT /*+ APPEND */ INTO CEV_STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, TODAYS_BUSINESS_DT, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                ce.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                ce.EVENT_TYP AS ERROR_VALUE,
                ce.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                gp.GP_TODAYS_BUS_DATE AS TODAYS_BUSINESS_DT,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN CEV_IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ce-event_hier'
and not exists (
                   select
                          null
                     from
                          stn.event_hierarchy_reference ehr
                    where
                          ehr.event_typ = ce.EVENT_TYP
               );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : ce-event-hier', 'sql%rowcount', NULL, sql%rowcount, NULL);
commit;

        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : ce-correlation-uuid-dup', NULL, NULL, NULL, NULL);
        INSERT /*+ APPEND */ INTO CEV_STANDARDISATION_LOG
            (TABLE_IN_ERROR_NAME, ROW_IN_ERROR_KEY_ID, ERROR_VALUE, LPG_ID, FIELD_IN_ERROR_NAME, EVENT_TYPE, ERROR_STATUS, CATEGORY_ID, ERROR_TECHNOLOGY, PROCESSING_STAGE, RULE_IDENTITY, TODAYS_BUSINESS_DT, CODE_MODULE_NM, STEP_RUN_SID, EVENT_TEXT, FEED_SID)
            SELECT
                vdl.TABLE_NM AS TABLE_IN_ERROR_NAME,
                ce.ROW_SID AS ROW_IN_ERROR_KEY_ID,
                ce.correlation_uuid AS ERROR_VALUE,
                ce.LPG_ID AS LPG_ID,
                vdl.COLUMN_NM AS FIELD_IN_ERROR_NAME,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_TECHNOLOGY_RESUBMIT AS ERROR_TECHNOLOGY,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                vdl.VALIDATION_CD AS RULE_IDENTITY,
                gp.GP_TODAYS_BUS_DATE AS TODAYS_BUSINESS_DT,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ce.STEP_RUN_SID AS STEP_RUN_SID,
                vdl.VALIDATION_TYP_ERR_MSG AS EVENT_TEXT,
                fd.FEED_SID AS FEED_SID
            FROM
                CESSION_EVENT ce
                INNER JOIN CEV_IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                vdl.VALIDATION_CD = 'ce-correlation_uuid_dup'
                and ce.EVENT_STATUS = 'U'
                and exists (
                   select
                           1
                     from
                          fdr.fr_stan_raw_acc_event hce
                    where
                          hce.srae_client_spare_id14 = ce.correlation_uuid
                          and trunc(hce.srae_value_date,'MONTH') = trunc(ce.accounting_dt,'MONTH')
                          and ce.LPG_ID=hce.lpg_id
                          );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : ce-correlation-uuid-dup', 'sql%rowcount', NULL, sql%rowcount, NULL);
        commit;

        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start validation : ce-correlation_uuid_error', NULL, NULL, NULL, NULL);
        INSERT /*+ APPEND */ INTO CEV_STANDARDISATION_LOG
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
                    INNER JOIN CEV_IDENTIFIED_RECORD idr ON ce.ROW_SID = idr.ROW_SID
                    INNER JOIN FEED fd ON ce.FEED_UUID = fd.FEED_UUID
                    INNER JOIN fdr.FR_GLOBAL_PARAMETER gp ON ce.LPG_ID = gp.LPG_ID
                    INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                    INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                WHERE
                                         ce.EVENT_STATUS='U' and
    vdl.VALIDATION_CD = 'ce-correlation_uuid'
and exists (
       select
              null
         from
              stn.cev_standardisation_log sl
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
              stn.cev_standardisation_log sl3
       where
              ce.ROW_SID = sl3.row_in_error_key_id)) "ce-validate-correlation-uuid";
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : ce-correlation-uuid-error', 'sql%rowcount', NULL, sql%rowcount, NULL);
       commit;

        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Loaded correlated records to stn.cev_standardisation_log', 'sql%rowcount', NULL, sql%rowcount, NULL);
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
                         stn.cev_standardisation_log sl
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
                    stn.cev_identified_record idr
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
        execute immediate 'truncate table STN.CEV_STANDARDISATION_LOG';
        INSERT /*+ APPEND */ INTO CEV_STANDARDISATION_LOG
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
                INNER JOIN CEV_IDENTIFIED_RECORD idr ON cev.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON cev.FEED_UUID = fd.FEED_UUID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN SET_VAL_ERROR_LOG_DEFAULT sveld ON 1 = 1
                INNER JOIN (SELECT
                    cev.FEED_UUID AS FEED_UUID,
                    COUNT(DISTINCT fgl.LK_LOOKUP_VALUE3) AS COUNT_DISTINCT
                FROM
                    CESSION_EVENT cev
                    INNER JOIN fdr.FR_GENERAL_LOOKUP fgl ON cev.EVENT_TYP = fgl.LK_LOOKUP_VALUE1 AND fgl.LK_LKT_LOOKUP_TYPE_CODE = 'EVENT_HIERARCHY'
                GROUP BY
                    cev.FEED_UUID) cevecd ON cev.FEED_UUID = cevecd.FEED_UUID
            WHERE
                vdl.VALIDATION_CD = 'ce-event_class_count' AND cevecd.COUNT_DISTINCT > 1;
    commit;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'End validation : cession-event-validate-event-class', 'sql%rowcount', NULL, sql%rowcount, NULL);
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
        v_no_cev_identified_records NUMBER(38, 9) DEFAULT 0;
        v_no_validated_records NUMBER(38, 9) DEFAULT 0;
        v_no_errored_records NUMBER(38, 9) DEFAULT 0;
        v_no_published_records NUMBER(38, 9) DEFAULT 0;
        v_no_pub_rev_hist_records NUMBER(38, 9) DEFAULT 0;
        v_no_pub_rev_curr_records NUMBER(38, 9) DEFAULT 0;
        v_no_processed_records NUMBER(38, 9) DEFAULT 0;
        v_no_unprocessed_records NUMBER(38, 9) DEFAULT 0;
        pub_val_mismatch EXCEPTION;
        s_exception_name VARCHAR2(80);
        s_proc_name VARCHAR2(80) := 'stn.pk_cev.pr_cession_event_prc';
        gv_ecode     NUMBER := -20001;
        gv_emsg VARCHAR(10000);

    BEGIN
        dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Reset ''V'' event_status to ''U'' from prior failed run' );
        pr_cession_event_res(v_no_reset_event_status);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Reset cession event event_status to U', 'v_no_reset_event_status', NULL, v_no_reset_event_status, NULL);
        dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Identify cession event records' );
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Start identify cession event records', NULL, NULL, NULL, NULL);
        pr_cession_event_idf(p_lpg_id, p_step_run_sid, v_no_cev_identified_records);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Identified cession event records', 'v_no_cev_identified_records', NULL, v_no_cev_identified_records, NULL);
        IF v_no_cev_identified_records > 0 THEN
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set level validate cession event records' );
            pr_cession_event_sval(p_step_run_sid);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed set level validations', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Row level validate cession event records' );
            pr_cession_event_rval(p_step_run_sid);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed row level validations', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set cession event status = "V"' );
            pr_cession_event_svs(p_step_run_sid, v_no_errored_records, v_no_validated_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting validation status', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish log records' );
            pr_publish_log('CEV_STANDARDISATION_LOG');
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
                s_exception_name:='v_no_validated_records != v_no_processed_records';
                raise pub_val_mismatch;
            END IF;
            p_no_processed_records := v_no_processed_records;
            p_no_failed_records    := v_no_errored_records;
        ELSE
            p_no_processed_records := 0;
            p_no_failed_records    := 0;
        END IF;

        EXCEPTION
                WHEN pub_val_mismatch THEN
                    pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : '||s_exception_name, NULL, NULL, NULL, NULL);
                    dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch' );
                    gv_emsg := 'Failure in ' || s_proc_name  || ': '|| sqlerrm;
                    RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg||' '||s_exception_name);
                WHEN OTHERS THEN
                    ROLLBACK;
                    gv_emsg := 'Failure in ' || s_proc_name  || ': '|| sqlerrm;
                    RAISE_APPLICATION_ERROR(gv_ecode, gv_emsg);

    END;
END PK_CEV;
/
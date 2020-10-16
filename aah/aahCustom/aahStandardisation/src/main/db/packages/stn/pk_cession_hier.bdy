create or replace package body stn.pk_cession_hier
as
    function fn_get_cession_hierarchy
    return stn.pk_cession_hier.le_cession_tab pipelined
    as
        v_cession_rec stn.pk_cession_hier.le_cession_rec;

    begin
        for i in (
                        with
                             cession_base
                          as (
                                   select
                                          ip.row_sid     insurance_policy_row_sid
                                        , ip.feed_uuid   feed_uuid
                                        , ip.policy_id   policy_id
                                        , cs.stream_id   child_stream_id
                                        , cs.cession_typ child_cession_typ
                                        , cs.le_id       child_le_id
                                        , null           parent_stream_id
                                        , null           parent_cession_typ
                                        , null           parent_le_id
                                     from
                                               stn.insurance_policy  ip
                                          join stn.identified_record_pol idr on ip.row_sid = idr.row_sid
                                          join stn.cession           cs  on (
                                                                                    ip.policy_id = cs.policy_id
                                                                                and ip.feed_uuid = cs.feed_uuid
                                                                            )
                                    where
                                          not exists (
                                                         select
                                                                null
                                                           from
                                                                stn.cession_link cl
                                                          where
                                                                cl.child_stream_id = cs.stream_id
                                                            and cl.feed_uuid       = cs.feed_uuid
                                                     )
                                union all
                                   select
                                          ip.row_sid          insurance_policy_row_sid
                                        , ip.feed_uuid        feed_uuid
                                        , ip.policy_id        policy_id
                                        , ccs.stream_id       child_stream_id
                                        , ccs.cession_typ     child_cession_typ
                                        , ccs.le_id           child_le_id
                                        , cl.parent_stream_id parent_stream_id
                                        , pcs.cession_typ     parent_cession_typ
                                        , pcs.le_id           parent_le_id
                                     from
                                               stn.insurance_policy  ip
                                          join stn.identified_record_pol idr on ip.row_sid = idr.row_sid
                                          join stn.cession           ccs on (
                                                                                    ip.policy_id = ccs.policy_id
                                                                                and ip.feed_uuid = ccs.feed_uuid
                                                                            )
                                          join stn.cession_link      cl  on (
                                                                                    ccs.stream_id = cl.child_stream_id
                                                                                and ccs.feed_uuid = cl.feed_uuid
                                                                            )
                                          join stn.cession           pcs on (
                                                                                    cl.parent_stream_id = pcs.stream_id
                                                                                and ip.feed_uuid        = pcs.feed_uuid
                                                                            )
                             )
                           , cession_tree
                         as (
                                    select
                                           cb.insurance_policy_row_sid
                                         , cb.feed_uuid
                                         , cb.policy_id
                                         , cb.child_stream_id
                                         , cb.child_cession_typ
                                         , cb.child_le_id
                                         , case when level = 1
                                                then cb.child_stream_id
                                                else cb.parent_stream_id
                                           end                                               parent_stream_id
                                         , case when level = 1
                                                then cb.child_cession_typ
                                                else cb.parent_cession_typ
                                           end                                               parent_cession_typ
                                         , case when level = 1
                                                then cb.child_le_id
                                                else cb.parent_le_id
                                           end                                               parent_le_id
                                         , connect_by_root ( cb.child_stream_id )            ultimate_parent_stream_id
                                         , sys_connect_by_path ( cb.child_stream_id , '/' )  path_to_child_stream
                                         , level                                             hierarchy_level
                                      from
                                           cession_base cb
                                start with
                                           cb.parent_stream_id is null
                                connect by
                                           prior cb.child_stream_id = cb.parent_stream_id
                                       and prior cb.feed_uuid       = cb.feed_uuid
                            )
                          , le_slr_link
                         as (
                                select
                                       to_number ( cfpl.pl_global_id ) child_le_id
                                     , to_number ( pfpl.pl_global_id ) ledger_entity_le_id
                                     , pfpl.pl_party_legal_clicode     ledger_entity_le_cd
                                  from
                                            fdr.fr_party_legal_lookup cfpll
                                       join fdr.fr_party_legal        cfpl  on cfpll.pll_pl_party_legal_id    = cfpl.pl_party_legal_id
                                       join fdr.fr_party_type         cfpt  on cfpl.pl_pt_party_type_id       = cfpt.pt_party_type_id
                                       join fdr.fr_org_network        cfon  on cfpl.pl_party_legal_id         = cfon.on_pl_party_legal_id
                                       join fdr.fr_org_node_structure fons  on cfon.on_org_node_id            = fons.ons_on_child_org_node_id
                                       join fdr.fr_org_hierarchy_type foht  on fons.ons_oht_org_hier_type_id  = foht.oht_org_hier_type_id
                                       join fdr.fr_org_network        pfon  on fons.ons_on_parent_org_node_id = pfon.on_org_node_id
                                       join fdr.fr_party_legal        pfpl  on pfon.on_pl_party_legal_id      = pfpl.pl_party_legal_id
                                       join fdr.fr_party_type         pfpt  on pfpl.pl_pt_party_type_id       = pfpt.pt_party_type_id
                                       join fdr.fr_party_legal_lookup pfpll on pfpl.pl_party_legal_id         = pfpll.pll_pl_party_legal_id
                                 where
                                       cfpt.pt_party_type_name        = 'Internal'
                                   and pfpt.pt_party_type_name        = 'Ledger Entity'
                                   and foht.oht_org_hier_client_code  = 'SLR_LINK'
                            )
                     select
                            ct.insurance_policy_row_sid
                          , ct.feed_uuid
                          , ct.policy_id
                          , ct.child_stream_id
                          , ct.child_cession_typ
                          , ct.child_le_id
                          , ct.parent_stream_id
                          , ct.parent_cession_typ
                          , ct.parent_le_id
                          , coalesce
                            (
                                ledger_entity.ledger_entity_le_id
                            ,   internal_le.ledger_entity_le_id
                            ,   external_le.ledger_entity_le_id
                            )                                       ledger_entity_le_id
                          , coalesce
                            (
                                ledger_entity.ledger_entity_le_cd
                            ,   internal_le.ledger_entity_le_cd
                            ,   external_le.ledger_entity_le_cd
                            )                                       ledger_entity_le_cd
                          , ct.ultimate_parent_stream_id
                          , ct.path_to_child_stream
                          , ct.hierarchy_level
                       from
                                      cession_tree ct
                            left join (
                                          select
                                                 to_number ( fpl.pl_global_id ) ledger_entity_le_id
                                               , fpl.pl_party_legal_clicode     ledger_entity_le_cd
                                            from
                                                      fdr.fr_party_legal_lookup fpll
                                                 join fdr.fr_party_legal        fpl  on fpll.pll_pl_party_legal_id = fpl.pl_party_legal_id
                                                 join fdr.fr_party_type         fpt  on fpl.pl_pt_party_type_id    = fpt.pt_party_type_id
                                           where
                                                 fpt.pt_party_type_name = 'Ledger Entity'
                                      )
                                                   ledger_entity on        ct.child_le_id       = ledger_entity.ledger_entity_le_id
                            left join le_slr_link  internal_le   on        ct.child_le_id       = internal_le.child_le_id
                            left join le_slr_link  external_le   on        ct.parent_le_id      = external_le.child_le_id
                 )
        loop

            v_cession_rec.insurance_policy_row_sid  := i.insurance_policy_row_sid;
            v_cession_rec.feed_uuid                 := i.feed_uuid;
            v_cession_rec.policy_id                 := i.policy_id;
            v_cession_rec.child_stream_id           := i.child_stream_id;
            v_cession_rec.child_cession_typ         := i.child_cession_typ;
            v_cession_rec.child_le_id               := i.child_le_id;
            v_cession_rec.parent_stream_id          := i.parent_stream_id;
            v_cession_rec.parent_cession_typ        := i.parent_cession_typ;
            v_cession_rec.parent_le_id              := i.parent_le_id;
            v_cession_rec.ledger_entity_le_cd       := i.ledger_entity_le_cd;
            v_cession_rec.ultimate_parent_stream_id := i.ultimate_parent_stream_id;
            v_cession_rec.path_to_child_stream      := i.path_to_child_stream;
            v_cession_rec.hierarchy_level           := i.hierarchy_level;
            v_cession_rec.ceding_stream_id          := i.parent_stream_id;
            v_cession_rec.ledger_entity_le_id       := i.ledger_entity_le_id;

            if v_cession_rec.ledger_entity_le_id is not null then
                pipe row ( v_cession_rec );
            end if;
        end loop;
    end fn_get_cession_hierarchy;

    procedure pr_gen_cession_hierarchy
    is
    begin
        insert
          into
               stn.cession_hierarchy
             (
               insurance_policy_row_sid
             , feed_uuid
             , policy_id
             , child_stream_id
             , child_cession_typ
             , child_le_id
             , parent_stream_id
             , parent_cession_typ
             , parent_le_id
             , ceding_stream_id
             , ledger_entity_le_id
             , ledger_entity_le_cd
             , ultimate_parent_stream_id
             , path_to_child_stream
             , hierarchy_level
             )
        select
               insurance_policy_row_sid
             , feed_uuid
             , policy_id
             , child_stream_id
             , child_cession_typ
             , child_le_id
             , parent_stream_id
             , parent_cession_typ
             , parent_le_id
             , ceding_stream_id
             , ledger_entity_le_id
             , ledger_entity_le_cd
             , ultimate_parent_stream_id
             , path_to_child_stream
             , hierarchy_level
          from
               table ( stn.pk_cession_hier.fn_get_cession_hierarchy () )
             ;
    end pr_gen_cession_hierarchy;

end pk_cession_hier;
/
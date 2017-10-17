create or replace package body stn.pk_le_hier
as

    function fn_get_elimination_entities
    (
        p_step_run_sid in number default 0
    )
    return stn.pk_le_hier.le_elimination_tab pipelined
    is
        v_elimination_entity_tab stn.pk_le_hier.le_elimination_entity_tab;
        v_elimination_rec        stn.pk_le_hier.le_elimination_rec;

        procedure pr_set_elimination_entity_tab
        as
        begin
              select
                     foht.oht_org_hier_client_code       legal_entity_link_typ
                   , pfpl.pl_party_legal_clicode         elimination_parent_le_cd
                   , min ( cfpl.pl_party_legal_clicode ) elimination_le_cd
                     bulk
                          collect
                                  into
                                       v_elimination_entity_tab
                from
                          fdr.fr_org_node_structure fons
                     join fdr.fr_org_hierarchy_type foht on fons.ons_oht_org_hier_type_id  = foht.oht_org_hier_type_id
                     join fdr.fr_org_network        cfon on fons.ons_on_child_org_node_id  = cfon.on_org_node_id
                     join fdr.fr_org_network        pfon on fons.ons_on_parent_org_node_id = pfon.on_org_node_id
                     join fdr.fr_party_legal        pfpl on pfon.on_pl_party_legal_id      = pfpl.pl_party_legal_id
                     join (
                              select
                                     fpl.pl_party_legal_id
                                   , fpl.pl_party_legal_clicode
                                   , fpl.pl_client_text5   is_interco_elim_entity
                                from
                                     fdr.fr_party_legal fpl
                          ) cfpl
                       on cfon.on_pl_party_legal_id = cfpl.pl_party_legal_id
               where
                     cfpl.is_interco_elim_entity = 'Y'
                 and foht.oht_org_hier_client_code in ( 'GAAP_CONSOLIDATION' , 'STAT_CONSOLIDATION' )
            group by
                     foht.oht_org_hier_client_code
                   , pfpl.pl_party_legal_clicode
                   ;

        end pr_set_elimination_entity_tab;

    begin

        pr_set_elimination_entity_tab;

        for hierarchy_rec in (
                                 with
                                        le_base
                                   as
                                    (
                                           select
                                                  null                           parent_le_cd
                                                , fon.on_org_node_client_code    child_le_cd
                                                , foht.oht_org_hier_client_code  legal_entity_link_typ
                                                , fpl.is_interco_elim_entity
                                             from
                                                             fdr.fr_org_network        fon
                                                  cross join fdr.fr_org_hierarchy_type foht
                                                        join (
                                                                 select
                                                                        pl_party_legal_id
                                                                      , pl_client_text5           is_interco_elim_entity
                                                                   from
                                                                        fdr.fr_party_legal
                                                             ) fpl
                                                          on fon.on_pl_party_legal_id = fpl.pl_party_legal_id
                                            where
                                                      exists (
                                                                 select
                                                                        null
                                                                   from
                                                                             fdr.fr_org_node_structure pfons
                                                                        join fdr.fr_org_network        pfon  on pfons.ons_on_parent_org_node_id = pfon.on_org_node_id
                                                                  where
                                                                        pfon.on_org_node_client_code   = fon.on_org_node_client_code
                                                                    and pfons.ons_oht_org_hier_type_id = foht.oht_org_hier_type_id
                                                             )
                                              and not exists (
                                                                 select
                                                                        null
                                                                   from
                                                                             fdr.fr_org_node_structure cfons
                                                                        join fdr.fr_org_network        cfon  on cfons.ons_on_child_org_node_id = cfon.on_org_node_id
                                                                  where
                                                                        cfon.on_org_node_client_code   = fon.on_org_node_client_code
                                                                    and cfons.ons_oht_org_hier_type_id = foht.oht_org_hier_type_id
                                                             )

                                        union all

                                           select
                                                  pfon.on_org_node_client_code  parent_le_cd
                                                , cfon.on_org_node_client_code  child_le_cd
                                                , foht.oht_org_hier_client_code legal_entity_link_typ
                                                , fpl.is_interco_elim_entity
                                             from
                                                       fdr.fr_org_node_structure fons
                                                  join fdr.fr_org_hierarchy_type foht on fons.ons_oht_org_hier_type_id  = foht.oht_org_hier_type_id
                                                  join fdr.fr_org_network        pfon on fons.ons_on_parent_org_node_id = pfon.on_org_node_id
                                                  join fdr.fr_org_network        cfon on fons.ons_on_child_org_node_id  = cfon.on_org_node_id
                                                  join (
                                                           select
                                                                  pl_party_legal_id
                                                                , pl_client_text5           is_interco_elim_entity
                                                             from
                                                                  fdr.fr_party_legal
                                                       ) fpl
                                                    on cfon.on_pl_party_legal_id = fpl.pl_party_legal_id
                                            where
                                                  fpl.is_interco_elim_entity = 'N'
                                    )
                                    ,
                                         le_hier
                                   as
                                    (
                                                   select
                                                          d.child_le_cd                               le_cd
                                                        , d.legal_entity_link_typ                                 legal_entity_link_typ
                                                        , sys_connect_by_path ( d.child_le_cd , '/' ) path_to_le
                                                        , d.is_interco_elim_entity
                                                     from
                                                          le_base d
                                               start with
                                                          d.parent_le_cd is null
                                               connect by
                                                          prior d.child_le_cd = d.parent_le_cd
                                                      and prior d.legal_entity_link_typ   = d.legal_entity_link_typ
                                        order siblings by
                                                          d.child_le_cd asc
                                    )
                                        select
                                               le1.le_cd       le_1_cd
                                             , le2.le_cd       le_2_cd
                                             , le1.legal_entity_link_typ   legal_entity_link_typ
                                             , le1.path_to_le  path_to_le_1
                                             , le2.path_to_le  path_to_le_2
                                          from
                                                    le_hier le1
                                               join le_hier le2 on le1.legal_entity_link_typ = le2.legal_entity_link_typ
                                         where
                                               le1.le_cd > le2.le_cd
                             ) loop

            v_elimination_rec.le_1_cd             := hierarchy_rec.le_1_cd;
            v_elimination_rec.le_2_cd             := hierarchy_rec.le_2_cd;
            v_elimination_rec.basis_typ           := hierarchy_rec.legal_entity_link_typ;
            v_elimination_rec.path_to_le_1        := hierarchy_rec.path_to_le_1;
            v_elimination_rec.path_to_le_2        := hierarchy_rec.path_to_le_2;
            v_elimination_rec.elimination_le_cd   := null;
            v_elimination_rec.common_parent_le_cd := null;

            begin
                with
                     common_parent
                  as (
                             select
                                    level                                                                            lvl
                                  , regexp_substr ( hierarchy_rec.path_to_le_1 , '[^/]+' , 1 , level )               path_segment_le_cd
                               from
                                    dual
                         connect by
                                    regexp_substr ( hierarchy_rec.path_to_le_1 , '[^/]+' , 1 , level ) is not null
                          intersect
                             select
                                    level                                                                            lvl
                                  , regexp_substr ( hierarchy_rec.path_to_le_2 , '[^/]+' , 1 , level )               path_segment_le_cd
                               from
                                    dual
                         connect by
                                    regexp_substr ( hierarchy_rec.path_to_le_2 , '[^/]+' , 1 , level ) is not null
                     )
                select
                       elimination_parent_le_cd
                     , elimination_le_cd
                       into
                       v_elimination_rec.common_parent_le_cd
                     , v_elimination_rec.elimination_le_cd
                  from (
                           select
                                  cp.lvl                              lvl
                                , max ( lvl ) over ( order by null )  mxlvl
                                , cp.path_segment_le_cd               elimination_parent_le_cd
                                , eet.elimination_le_cd               elimination_le_cd
                             from
                                       common_parent                      cp
                                  join table ( v_elimination_entity_tab ) eet on (
                                                                                         cp.path_segment_le_cd = eet.elimination_parent_le_cd
                                                                                     and eet.basis_typ         = hierarchy_rec.legal_entity_link_typ
                                                                                 )
                       )
                 where
                       lvl = mxlvl
                     ;
            exception
                when no_data_found then
                    continue;
                when too_many_rows then
                    /*
                     * Only one match to an elimination entity should be made.
                     * If we've got here, something has gone wrong.
                     */
                    stn.pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'exception : too_many_rows', 'path_to_le_1' , null , null , hierarchy_rec.path_to_le_1 );
                    stn.pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'exception : too_many_rows', 'path_to_le_2' , null , null , hierarchy_rec.path_to_le_2 );
                    raise;
            end;

            pipe row ( v_elimination_rec );

            v_elimination_rec.le_1_cd      := hierarchy_rec.le_2_cd;
            v_elimination_rec.le_2_cd      := hierarchy_rec.le_1_cd;
            v_elimination_rec.path_to_le_1 := hierarchy_rec.path_to_le_2;
            v_elimination_rec.path_to_le_2 := hierarchy_rec.path_to_le_1;

            pipe row ( v_elimination_rec );

        end loop;
    end fn_get_elimination_entities;

    procedure pr_gen_interco
    (
        p_step_run_sid in number
    )
    is
        v_old_step_run_sid stn.step_run.step_run_sid%type;

        function fn_does_data_exist
        return boolean
        is
            v_cnt number ( 38 , 0 );
        begin

            select
                   count ( * )
                   into
                   v_cnt
              from
                   stn.elimination_legal_entity
                 ;

            return ( v_cnt > 0 );

        end fn_does_data_exist;

        procedure pr_set_step_run_sid
        is
        begin
            select
                   step_run_sid
                   into
                   v_old_step_run_sid
              from (
                       select
                              sr.step_run_sid                                             step_run_sid
                            , srse.step_run_state_start_ts                                ts
                            , max ( srse.step_run_state_start_ts ) over ( order by null ) maxts
                         from
                                   stn.step_run        sr
                              join stn.step_run_state  srse on sr.step_run_sid         = srse.step_run_sid
                              join stn.step_run_status srsu on srse.step_run_status_id = srsu.step_run_status_id
                        where
                              srsu.step_run_status_cd = 'S'
                          and exists (
                                         select
                                                null
                                           from
                                                stn.elimination_legal_entity leie
                                          where
                                                leie.step_run_sid = sr.step_run_sid
                                     )
                    )
             where
                   ts = maxts
                 ;

        end pr_set_step_run_sid;

        procedure pr_load_data
        is
        begin
            insert
              into
                   stn.elimination_legal_entity
                 (
                     step_run_sid
                 ,   legal_entity_link_typ
                 ,   le_1_cd
                 ,   le_2_cd
                 ,   elimination_le_cd
                 ,   path_to_le_1
                 ,   path_to_le_2
                 ,   common_parent_le_cd
                 )
            select
                     p_step_run_sid
                 ,   basis_typ
                 ,   le_1_cd
                 ,   le_2_cd
                 ,   elimination_le_cd
                 ,   path_to_le_1
                 ,   path_to_le_2
                 ,   common_parent_le_cd
              from
                   table ( stn.pk_le_hier.fn_get_elimination_entities ( p_step_run_sid ) )
                 ;

            pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'Intercompany elimination entity data loaded' , 'sql%rowcount' , null , sql%rowcount , null );

        end pr_load_data;

        function fn_is_old_new_data_identical
        return boolean
        is
            v_cnt number ( 38 , 0 );
        begin

            select
                   sum ( cnt )
                   into
                   v_cnt
              from (
                          select
                                 count(*) cnt
                            from (
                                     select
                                            legal_entity_link_typ
                                          , le_1_cd
                                          , le_2_cd
                                          , elimination_le_cd
                                          , path_to_le_1
                                          , path_to_le_2
                                          , common_parent_le_cd
                                       from
                                            stn.elimination_legal_entity
                                      where
                                            step_run_sid = v_old_step_run_sid
                                      minus
                                     select
                                            legal_entity_link_typ
                                          , le_1_cd
                                          , le_2_cd
                                          , elimination_le_cd
                                          , path_to_le_1
                                          , path_to_le_2
                                          , common_parent_le_cd
                                       from
                                            stn.elimination_legal_entity
                                      where
                                            step_run_sid = p_step_run_sid
                                 )
                       union all
                          select
                                 count(*) cnt
                            from (
                                     select
                                            legal_entity_link_typ
                                          , le_1_cd
                                          , le_2_cd
                                          , elimination_le_cd
                                          , path_to_le_1
                                          , path_to_le_2
                                          , common_parent_le_cd
                                       from
                                            stn.elimination_legal_entity
                                      where
                                            step_run_sid = p_step_run_sid
                                      minus
                                     select
                                            legal_entity_link_typ
                                          , le_1_cd
                                          , le_2_cd
                                          , elimination_le_cd
                                          , path_to_le_1
                                          , path_to_le_2
                                          , common_parent_le_cd
                                       from
                                            stn.elimination_legal_entity
                                      where
                                            step_run_sid = v_old_step_run_sid
                                 )
                   );

            pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'Number of differences between old and new datasets' , 'v_cnt' , null , v_cnt , null );

            return ( v_cnt = 0 );

        end fn_is_old_new_data_identical;
    begin
        if fn_does_data_exist () then
            pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'Intercompany elimination entity data does exist' , null , null , null , null );
            pr_set_step_run_sid;
            pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'Step run sid of most recent data set' , 'v_old_step_run_sid' , null , v_old_step_run_sid , null );
            pr_load_data;
            if fn_is_old_new_data_identical () then
                delete
                  from
                       stn.elimination_legal_entity
                 where
                       step_run_sid = p_step_run_sid
                     ;
                pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'Number of records deleted' , 'sql%rowcount' , null , sql%rowcount , null );
            end if;
        else
            pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'Intercompany elimination entity data does not exist', null , null , null , null );
            pr_load_data;
        end if;
    end pr_gen_interco;

    function fn_get_vie_entities
    (
        p_step_run_sid in number default 0
    )
    return stn.pk_le_hier.le_vie_tab pipelined
    is

        type segment_tab is table of varchar2 ( 100 char ) index by varchar2 ( 100 char );

        v_vie_rec              stn.pk_le_hier.le_vie_rec;
        v_vie_path_segment_tab stn.pk_le_hier.le_vie_path_segment_tab;
        v_segment_tab          segment_tab;
        v_counter              number ( 38 , 0 ) := 0;

        procedure pr_set_vie_entity_tabs
        as

            vie_segment_key varchar2 ( 500 char );

        begin
            for vie_entity in (
                                  with
                                       le_base
                                    as
                                     (
                                            select
                                                   null                           parent_le_cd
                                                 , fon.on_org_node_client_code    child_le_cd
                                                 , foht.oht_org_hier_client_code  legal_entity_link_typ
                                                 , fpl.is_vie_entity
                                              from
                                                              fdr.fr_org_network        fon
                                                   cross join fdr.fr_org_hierarchy_type foht
                                                         join (
                                                                  select
                                                                         pl_party_legal_id
                                                                       , pl_client_text6           is_vie_entity
                                                                    from
                                                                         fdr.fr_party_legal
                                                              ) fpl
                                                           on fon.on_pl_party_legal_id = fpl.pl_party_legal_id
                                             where
                                                       exists (
                                                                  select
                                                                         null
                                                                    from
                                                                              fdr.fr_org_node_structure pfons
                                                                         join fdr.fr_org_network        pfon  on pfons.ons_on_parent_org_node_id = pfon.on_org_node_id
                                                                   where
                                                                         pfon.on_org_node_client_code   = fon.on_org_node_client_code
                                                                     and pfons.ons_oht_org_hier_type_id = foht.oht_org_hier_type_id
                                                              )
                                               and not exists (
                                                                  select
                                                                         null
                                                                    from
                                                                              fdr.fr_org_node_structure cfons
                                                                         join fdr.fr_org_network        cfon  on cfons.ons_on_child_org_node_id = cfon.on_org_node_id
                                                                   where
                                                                         cfon.on_org_node_client_code   = fon.on_org_node_client_code
                                                                     and cfons.ons_oht_org_hier_type_id = foht.oht_org_hier_type_id
                                                              )
                                                          and foht.oht_org_hier_client_code in ( 'GAAP_CONSOLIDATION' )

                                         union all

                                            select
                                                   pfon.on_org_node_client_code  parent_le_cd
                                                 , cfon.on_org_node_client_code  child_le_cd
                                                 , foht.oht_org_hier_client_code legal_entity_link_typ
                                                 , fpl.is_vie_entity
                                              from
                                                        fdr.fr_org_node_structure fons
                                                   join fdr.fr_org_hierarchy_type foht on fons.ons_oht_org_hier_type_id  = foht.oht_org_hier_type_id
                                                   join fdr.fr_org_network        pfon on fons.ons_on_parent_org_node_id = pfon.on_org_node_id
                                                   join fdr.fr_org_network        cfon on fons.ons_on_child_org_node_id  = cfon.on_org_node_id
                                                   join (
                                                            select
                                                                   pl_party_legal_id
                                                                 , pl_client_text6           is_vie_entity
                                                              from
                                                                   fdr.fr_party_legal
                                                        ) fpl
                                                     on cfon.on_pl_party_legal_id = fpl.pl_party_legal_id
                                             where foht.oht_org_hier_client_code in ( 'GAAP_CONSOLIDATION' )
                                     )
                                                    select
                                                           d.legal_entity_link_typ                                 legal_entity_link_typ
                                                         , d.child_le_cd                               vie_le_cd
                                                         , level                                       vie_le_level
                                                         , sys_connect_by_path ( d.child_le_cd , '/' ) path_to_vie_le_cd
                                                      from
                                                           le_base d
                                                     where
                                                           d.is_vie_entity = 'Y'
                                                start with
                                                           d.parent_le_cd is null
                                                connect by
                                                           prior d.child_le_cd = d.parent_le_cd
                                                       and prior d.legal_entity_link_typ   = d.legal_entity_link_typ
                                         order siblings by
                                                           d.child_le_cd asc
                              )
            loop
                for le_path_segment in (
                                               select
                                                      level                                                                lvl
                                                    , regexp_substr ( vie_entity.path_to_vie_le_cd , '[^/]+' , 1 , level ) path_segment_le_cd
                                                 from
                                                      dual
                                           connect by
                                                      regexp_substr ( vie_entity.path_to_vie_le_cd , '[^/]+' , 1 , level ) is not null
                                       )
                loop
                    vie_segment_key := vie_entity.legal_entity_link_typ || '-' || le_path_segment.path_segment_le_cd || '-' || vie_entity.vie_le_cd;

                    if not v_segment_tab.exists ( vie_segment_key )
                    then
                        v_counter := v_counter + 1;

                        v_segment_tab ( vie_segment_key )                       := vie_segment_key;
                        v_vie_path_segment_tab ( v_counter ).basis_typ          := vie_entity.legal_entity_link_typ;
                        v_vie_path_segment_tab ( v_counter ).vie_le_cd          := vie_entity.vie_le_cd;
                        v_vie_path_segment_tab ( v_counter ).vie_le_level       := vie_entity.vie_le_level;
                        v_vie_path_segment_tab ( v_counter ).segment_lvl        := le_path_segment.lvl;
                        v_vie_path_segment_tab ( v_counter ).path_segment_le_cd := le_path_segment.path_segment_le_cd;
                    end if;
                end loop;
            end loop;

            stn.pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'v_vie_path_segment_tab.count', 'v_vie_path_segment_tab.count' , null , v_vie_path_segment_tab.count , null );

        end pr_set_vie_entity_tabs;

        procedure pr_set_vie_le_cd
        (
            p_basis_typ  in  fdr.fr_org_hierarchy_type.oht_org_hier_client_code%type
        ,   p_path_to_le in  varchar2
        ,   p_vie_le_cd  out fdr.fr_party_legal.pl_party_legal_clicode%type
        )
        is
        begin
            with
                 isect
              as (
                         select
                                /*+ cardinality ( 10 ) */
                                level                                                          segment_lvl
                              , regexp_substr ( p_path_to_le , '[^/]+' , 1 , level )           path_segment_le_cd
                           from
                                dual
                     connect by
                                regexp_substr ( p_path_to_le , '[^/]+' , 1 , level ) is not null
                      intersect
                         select
                                /*+ cardinality ( 10 ) */
                                vpst.segment_lvl
                              , vpst.path_segment_le_cd
                           from
                                table ( v_vie_path_segment_tab ) vpst
                          where
                                vpst.basis_typ = p_basis_typ
                 )
            select
                   vie_le_cd
                   into
                   p_vie_le_cd
              from (
                       select
                              vie_le_cd
                            , min ( vie_le_cd ) over ( order by null ) min_vie_le_cd
                         from (
                                  select
                                         vie_le_cd
                                       , vie_le_level
                                       , min ( vie_le_level ) over ( order by null ) min_vie_le_level
                                    from (
                                             select
                                                    /*+ cardinality ( 10 ) */
                                                    v.vie_le_cd                                   vie_le_cd
                                                  , v.vie_le_level                                vie_le_level
                                                  , v.segment_lvl                                 segment_lvl
                                                  , max ( v.segment_lvl ) over ( order by null )  max_segment_lvl
                                               from      isect                             i
                                                    join table ( v_vie_path_segment_tab )  v
                                                      on (
                                                                 i.segment_lvl        = v.segment_lvl
                                                             and i.path_segment_le_cd = v.path_segment_le_cd
                                                         )
                                              where
                                                    v.basis_typ = p_basis_typ
                                         )
                                   where
                                         segment_lvl = max_segment_lvl
                              )
                        where
                              vie_le_level = min_vie_le_level
                   )
             where
                   vie_le_cd = min_vie_le_cd
                 ;

        exception
            when no_data_found then
                /* No VIE consolidation entity can be found for this legal entity. */
                p_vie_le_cd := null;
            when too_many_rows then
                stn.pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'exception : too_many_rows', 'path_to_le' , null , null , p_path_to_le );
                raise;
        end pr_set_vie_le_cd;

    begin

        pr_set_vie_entity_tabs;

        for hierarchy_rec in (
                                 with
                                        le_base
                                   as
                                    (
                                           select
                                                  null                           parent_le_cd
                                                , fon.on_org_node_client_code    child_le_cd
                                                , foht.oht_org_hier_client_code  legal_entity_link_typ
                                                , fpl.is_vie_entity
                                             from
                                                             fdr.fr_org_network        fon
                                                  cross join fdr.fr_org_hierarchy_type foht
                                                        join (
                                                                 select
                                                                        pl_party_legal_id
                                                                      , pl_client_text6           is_vie_entity
                                                                   from
                                                                        fdr.fr_party_legal
                                                             ) fpl
                                                          on fon.on_pl_party_legal_id = fpl.pl_party_legal_id
                                            where
                                                      exists (
                                                                 select
                                                                        null
                                                                   from
                                                                             fdr.fr_org_node_structure pfons
                                                                        join fdr.fr_org_network        pfon  on pfons.ons_on_parent_org_node_id = pfon.on_org_node_id
                                                                  where
                                                                        pfon.on_org_node_client_code   = fon.on_org_node_client_code
                                                                    and pfons.ons_oht_org_hier_type_id = foht.oht_org_hier_type_id
                                                             )
                                              and not exists (
                                                                 select
                                                                        null
                                                                   from
                                                                             fdr.fr_org_node_structure cfons
                                                                        join fdr.fr_org_network        cfon  on cfons.ons_on_child_org_node_id = cfon.on_org_node_id
                                                                  where
                                                                        cfon.on_org_node_client_code   = fon.on_org_node_client_code
                                                                    and cfons.ons_oht_org_hier_type_id = foht.oht_org_hier_type_id
                                                             )

                                        union all

                                           select
                                                  pfon.on_org_node_client_code  parent_le_cd
                                                , cfon.on_org_node_client_code  child_le_cd
                                                , foht.oht_org_hier_client_code legal_entity_link_typ
                                                , fpl.is_vie_entity
                                             from
                                                       fdr.fr_org_node_structure fons
                                                  join fdr.fr_org_hierarchy_type foht on fons.ons_oht_org_hier_type_id  = foht.oht_org_hier_type_id
                                                  join fdr.fr_org_network        pfon on fons.ons_on_parent_org_node_id = pfon.on_org_node_id
                                                  join fdr.fr_org_network        cfon on fons.ons_on_child_org_node_id  = cfon.on_org_node_id
                                                  join (
                                                           select
                                                                  pl_party_legal_id
                                                                , pl_client_text6           is_vie_entity
                                                             from
                                                                  fdr.fr_party_legal
                                                       ) fpl
                                                    on cfon.on_pl_party_legal_id = fpl.pl_party_legal_id
                                            where
                                                  fpl.is_vie_entity = 'N'
                                    )
                                                   select
                                                          d.child_le_cd                               le_cd
                                                        , d.legal_entity_link_typ                                 legal_entity_link_typ
                                                        , sys_connect_by_path ( d.child_le_cd , '/' ) path_to_le
                                                     from
                                                          le_base d
                                               start with
                                                          d.parent_le_cd is null
                                               connect by
                                                          prior d.child_le_cd = d.parent_le_cd
                                                      and prior d.legal_entity_link_typ   = d.legal_entity_link_typ
                                        order siblings by
                                                          d.child_le_cd asc
                             ) loop

            v_vie_rec.le_cd      := hierarchy_rec.le_cd;
            v_vie_rec.basis_typ  := hierarchy_rec.legal_entity_link_typ;
            v_vie_rec.path_to_le := hierarchy_rec.path_to_le;
            v_vie_rec.vie_le_cd  := null;

            pr_set_vie_le_cd ( hierarchy_rec.legal_entity_link_typ , hierarchy_rec.path_to_le , v_vie_rec.vie_le_cd );

            if ( v_vie_rec.vie_le_cd is not null )
            then
                pipe row ( v_vie_rec );
            end if;

        end loop;

    end fn_get_vie_entities;

    procedure pr_gen_vie
    (
        p_step_run_sid in number
    )
    is
        v_old_step_run_sid stn.step_run.step_run_sid%type;

        function fn_does_data_exist
        return boolean
        is
            v_cnt number ( 38 , 0 );
        begin

            select
                   count ( * )
                   into
                   v_cnt
              from
                   stn.vie_legal_entity
                 ;

            return ( v_cnt > 0 );

        end fn_does_data_exist;

        procedure pr_set_step_run_sid
        is
        begin
            select
                   step_run_sid
                   into
                   v_old_step_run_sid
              from (
                       select
                              sr.step_run_sid                                             step_run_sid
                            , srse.step_run_state_start_ts                                ts
                            , max ( srse.step_run_state_start_ts ) over ( order by null ) maxts
                         from
                                   stn.step_run        sr
                              join stn.step_run_state  srse on sr.step_run_sid         = srse.step_run_sid
                              join stn.step_run_status srsu on srse.step_run_status_id = srsu.step_run_status_id
                        where
                              srsu.step_run_status_cd = 'S'
                          and exists (
                                         select
                                                null
                                           from
                                                stn.vie_legal_entity levie
                                          where
                                                levie.step_run_sid = sr.step_run_sid
                                     )
                    )
             where
                   ts = maxts
                 ;

        end pr_set_step_run_sid;

        procedure pr_load_data
        is
        begin
            insert
              into
                   stn.vie_legal_entity
                 (
                   step_run_sid
                 , legal_entity_link_typ
                 , le_cd
                 , vie_le_cd
                 , path_to_le
                 )
            select
                   p_step_run_sid
                 , basis_typ
                 , le_cd
                 , vie_le_cd
                 , path_to_le
              from
                   table ( stn.pk_le_hier.fn_get_vie_entities ( p_step_run_sid ) )
                 ;

            pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'VIE entity data loaded' , 'sql%rowcount' , null , sql%rowcount , null );

        end pr_load_data;

        function fn_is_old_new_data_identical
        return boolean
        is
            v_cnt number ( 38 , 0 );
        begin

            select
                   sum ( cnt )
                   into
                   v_cnt
              from (
                          select
                                 count(*) cnt
                            from (
                                     select
                                            legal_entity_link_typ
                                          , le_cd
                                          , vie_le_cd
                                          , path_to_le
                                       from
                                            stn.vie_legal_entity
                                      where
                                            step_run_sid = v_old_step_run_sid
                                      minus
                                     select
                                            legal_entity_link_typ
                                          , le_cd
                                          , vie_le_cd
                                          , path_to_le
                                       from
                                            stn.vie_legal_entity
                                      where
                                            step_run_sid = p_step_run_sid
                                 )
                       union all
                          select
                                 count(*) cnt
                            from (
                                     select
                                            legal_entity_link_typ
                                          , le_cd
                                          , vie_le_cd
                                          , path_to_le
                                       from
                                            stn.vie_legal_entity
                                      where
                                            step_run_sid = p_step_run_sid
                                      minus
                                     select
                                            legal_entity_link_typ
                                          , le_cd
                                          , vie_le_cd
                                          , path_to_le
                                       from
                                            stn.vie_legal_entity
                                      where
                                            step_run_sid = v_old_step_run_sid
                                 )
                   );

            pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'Number of differences between old and new datasets' , 'v_cnt' , null , v_cnt , null );

            return ( v_cnt = 0 );

        end fn_is_old_new_data_identical;
    begin
        if fn_does_data_exist () then
            pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'VIE legal entity data does exist' , null , null , null , null );
            pr_set_step_run_sid;
            pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'Step run sid of most recent data set' , 'v_old_step_run_sid' , null , v_old_step_run_sid , null );
            pr_load_data;
            if fn_is_old_new_data_identical () then
                delete
                  from
                       stn.vie_legal_entity
                 where
                       step_run_sid = p_step_run_sid
                     ;
                pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'Number of records deleted' , 'sql%rowcount' , null , sql%rowcount , null );
            end if;
        else
            pr_step_run_log ( p_step_run_sid , $$plsql_unit , $$plsql_line , 'VIE legal entity data does not exist', null , null , null , null );
            pr_load_data;
        end if;
    end pr_gen_vie;

end pk_le_hier;
/
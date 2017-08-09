create or replace package body stn.pk_feed_integrity
as

    procedure pr_identify_new_feeds
    (
        p_step_run_sid in stn.step_run.step_run_sid%type
    )
    is
    begin
        insert
          into
               stn.identified_feed
             (
                 feed_sid
             )
        select
               fd.feed_sid
          from
                    stn.feed      fd
               join stn.feed_type ft on fd.feed_typ   = ft.feed_typ
               join stn.step      st on ft.process_id = st.process_id
               join stn.step_run  sr on st.step_id    = sr.step_id
         where
               sr.step_run_sid     = p_step_run_sid
           and not exists (
                              select
                                     null
                                from
                                     stn.broken_feed bf
                               where
                                     bf.feed_sid = fd.feed_sid
                          )
           and not exists (
                              select
                                     null
                                from
                                     stn.superseded_feed sf
                               where
                                     sf.superseded_feed_sid = fd.feed_sid
                          )
           and not exists (
                              select
                                     null
                                from
                                     stn.feed_record_count frc
                               where
                                     frc.feed_uuid         = fd.feed_uuid
                                 and frc.actual_record_cnt is not null
                          )
             ;

        stn.pr_step_run_log ( p_step_run_sid , $$PLSQL_UNIT , $$PLSQL_LINE , 'Number of new feeds identified' ,  'sql%rowcount' , null , sql%rowcount , null );

    end pr_identify_new_feeds;

    procedure pr_identify_superceded_feeds
    (
        p_step_run_sid in stn.step_run.step_run_sid%type
    )
    is
    begin
        insert
          into
               stn.superseded_feed
             (
                 superseding_feed_sid
             ,   superseded_feed_sid
             ,   step_run_sid
             )
        select
               superseding.feed_sid superseding_feed_sid
             , superseded.feed_sid  superseded_feed_sid
             , p_step_run_sid
          from      (
                        select
                               fd.feed_sid
                             , data.feed_typ
                             , data.effective_dt
                          from
                                    stn.feed fd
                               join (
                                          select
                                                 fd.feed_typ
                                               , fd.effective_dt
                                               , max ( fd.loaded_ts ) loaded_ts
                                            from
                                                      stn.feed                fd
                                                 join stn.feed_type           ftpy on fd.feed_typ                 = ftpy.feed_typ
                                                 join stn.step                st   on ftpy.process_id             = st.process_id
                                                 join stn.step_run            sr   on st.step_id                  = sr.step_id
                                                 join stn.supersession_method sm   on ftpy.supersession_method_id = sm.supersession_method_id
                                           where
                                                 sm.supersession_method_cd = 'GLTSEED'
                                             and sr.step_run_sid           = p_step_run_sid
                                        group by
                                                 fd.feed_typ
                                               , fd.effective_dt
                                    )
                                    data
                                 on (
                                            fd.feed_typ     = data.feed_typ
                                        and fd.effective_dt = data.effective_dt
                                        and fd.loaded_ts    = data.loaded_ts
                                    )
                    ) superseding
               join (
                        select
                               data.feed_sid
                             , data.feed_typ
                             , data.effective_dt
                          from (
                                   select
                                          fd.feed_sid
                                        , fd.feed_typ
                                        , fd.effective_dt
                                        , row_number () over ( partition by fd.feed_typ , fd.effective_dt order by fd.loaded_ts desc ) rn
                                     from
                                               stn.feed                fd
                                          join stn.feed_type           ftpy on fd.feed_typ                 = ftpy.feed_typ
                                          join stn.step                st   on ftpy.process_id             = st.process_id
                                          join stn.step_run            sr   on st.step_id                  = sr.step_id
                                          join stn.supersession_method sm   on ftpy.supersession_method_id = sm.supersession_method_id
                                    where
                                          sm.supersession_method_cd = 'GLTSEED'
                                      and sr.step_run_sid           = p_step_run_sid
                                      and not exists (
                                                         select
                                                                null
                                                           from
                                                                stn.superseded_feed sf
                                                          where
                                                                sf.superseded_feed_sid = fd.feed_sid
                                                     )
                               )
                               data
                         where
                               rn != 1
                    ) superseded
                 on (
                            superseding.feed_typ     = superseded.feed_typ
                        and superseding.effective_dt = superseded.effective_dt
                    );

        stn.pr_step_run_log ( p_step_run_sid , $$PLSQL_UNIT , $$PLSQL_LINE , 'Number of superseded feeds identified - GLTSEED' ,  'sql%rowcount' , null , sql%rowcount , null );

        insert
          into
               stn.superseded_feed
             (
                 superseding_feed_sid
             ,   superseded_feed_sid
             ,   step_run_sid
             )
        select
               superseding.feed_sid superseding_feed_sid
             , superseded.feed_sid  superseded_feed_sid
             , p_step_run_sid
          from      (
                        select
                               data.feed_sid
                             , data.feed_typ
                          from (
                                   select
                                          fd.feed_sid
                                        , fd.feed_typ
                                        , row_number () over ( partition by fd.feed_typ order by fd.effective_dt desc , fd.loaded_ts desc ) rn
                                     from
                                               stn.feed                fd
                                          join stn.feed_type           ftpy on fd.feed_typ                 = ftpy.feed_typ
                                          join stn.step                st   on ftpy.process_id             = st.process_id
                                          join stn.step_run            sr   on st.step_id                  = sr.step_id
                                          join stn.supersession_method sm   on ftpy.supersession_method_id = sm.supersession_method_id
                                    where
                                          sm.supersession_method_cd = 'GLTSGED'
                                      and sr.step_run_sid           = p_step_run_sid
                                ) data
                         where
                               data.rn = 1
                     ) superseding
                join (
                        select
                               data.feed_sid
                             , data.feed_typ
                          from (
                                   select
                                          fd.feed_sid
                                        , fd.feed_typ
                                        , row_number () over ( partition by fd.feed_typ order by fd.effective_dt desc , fd.loaded_ts desc ) rn
                                     from
                                               stn.feed                fd
                                          join stn.feed_type           ftpy on fd.feed_typ                 = ftpy.feed_typ
                                          join stn.step                st   on ftpy.process_id             = st.process_id
                                          join stn.step_run            sr   on st.step_id                  = sr.step_id
                                          join stn.supersession_method sm   on ftpy.supersession_method_id = sm.supersession_method_id
                                    where
                                          sm.supersession_method_cd = 'GLTSGED'
                                      and sr.step_run_sid           = p_step_run_sid
                                      and not exists (
                                                         select
                                                                null
                                                           from
                                                                stn.superseded_feed sf
                                                          where
                                                                sf.superseded_feed_sid = fd.feed_sid
                                                     )
                                ) data
                         where
                               data.rn != 1
                     )
                     superseded
                  on (
                         superseding.feed_typ = superseded.feed_typ
                     )
             ;

        stn.pr_step_run_log ( p_step_run_sid , $$PLSQL_UNIT , $$PLSQL_LINE , 'Number of superseded feeds identified - GLTSGED' ,  'sql%rowcount' , null , sql%rowcount , null );
    end;

    procedure pr_confirm_record_counts
    (
        p_step_run_sid in stn.step_run.step_run_sid%type
    )
    is
    begin
        insert
          into
               stn.broken_feed
             (
                 feed_sid
             ,   step_run_sid
             )
        select
               distinct
                        fmrc.feed_sid
                      , p_step_run_sid
          from
                    stn.feed_missing_record_count fmrc
               join stn.identified_feed           ifd  on fmrc.feed_sid = ifd.feed_sid
               join stn.feed                      fd   on fmrc.feed_sid = fd.feed_sid
               join stn.feed_type                 ft   on fd.feed_typ   = ft.feed_typ
               join stn.process                   pr   on ft.process_id = pr.process_id
             ;

        stn.pr_step_run_log ( p_step_run_sid , $$PLSQL_UNIT , $$PLSQL_LINE , 'Number of broken feeds identified [missing feed_record_count]' ,  'sql%rowcount' , null , sql%rowcount , null );

    end pr_confirm_record_counts;

    procedure pr_confirm_stated_amounts
    (
        p_step_run_sid in stn.step_run.step_run_sid%type
    )
    is
    begin
        for dbtab in (
                         select
                                dbt.db_nm
                              , dbt.table_nm
                           from
                                     stn.feed_type         ft
                                join stn.step              st   on ft.process_id = st.process_id
                                join stn.step_run          sr   on st.step_id    = sr.step_id
                                join stn.feed_type_payload ftpl on ft.feed_typ   = ftpl.feed_typ
                                join stn.db_table          dbt  on ftpl.dbt_id   = dbt.dbt_id
                          where
                                sr.step_run_sid = p_step_run_sid
                     )
        loop

            execute immediate    ' merge '
                              || '  into '
                              || '       stn.feed_record_count frc '
                              || ' using ( '
                              || '            select '
                              || '                   fd.feed_uuid '
                              || '                 , coalesce ( data.actual_record_cnt , 0 )   actual_record_cnt '
                              || '              from '
                              || '                             stn.feed            fd '
                              || '                        join stn.identified_feed idf on fd.feed_sid = idf.feed_sid '
                              || '                   left join ( '
                              || '                                   select '
                              || '                                          fd.feed_uuid '
                              || '                                        , count (*)    actual_record_cnt '
                              || '                                     from '
                              || '                                               stn.feed                                                                           fd '
                              || '                                          join stn.identified_feed                                                                idf   on fd.feed_sid  = idf.feed_sid '
                              || '                                          join ' || sys.dbms_assert.sql_object_name ( dbtab.db_nm || '.' || dbtab.table_nm ) || ' alias on fd.feed_uuid = alias.feed_uuid '
                              || '                                 group by '
                              || '                                          fd.feed_uuid '
                              || '                             ) data '
                              || '                          on ( '
                              || '                                 fd.feed_uuid = data.feed_uuid '
                              || '                             ) '
                              || '       ) data '
                              || '    on ( '
                              || '               frc.feed_uuid          = data.feed_uuid '
                              || '           and upper ( frc.db_nm )    = upper ( :1 )'
                              || '           and upper ( frc.table_nm ) = upper ( :2 )'
                              || '       ) '
                              || '  when matched then update '
                              || '                       set '
                              || '                           actual_record_cnt = data.actual_record_cnt '
                        using
                              dbtab.db_nm
                            , dbtab.table_nm
                            ;

            stn.pr_step_run_log ( p_step_run_sid , $$PLSQL_UNIT , $$PLSQL_LINE , 'Number of records updated with an actual record count - "' || dbtab.db_nm || '.' || dbtab.table_nm || '"' ,  'sql%rowcount' , null , sql%rowcount , null );

        end loop;

    end pr_confirm_stated_amounts;

    procedure pr_identify_broken_feeds
    (
        p_step_run_sid in stn.step_run.step_run_sid%type
    )
    is
    begin
        insert
          into
               stn.broken_feed
             (
                 feed_sid
             ,   step_run_sid
             )
        select
               idf.feed_sid
             , p_step_run_sid
          from
               stn.identified_feed idf
         where
               not exists (
                              select
                                     null
                                from
                                     stn.broken_feed bf
                               where
                                     idf.feed_sid = bf.feed_sid
                          )
           and (
                      not exists (
                                     select
                                            null
                                       from
                                                 stn.feed              fd
                                            join stn.feed_record_count frc on fd.feed_uuid = frc.feed_uuid
                                      where
                                            idf.feed_sid = fd.feed_sid
                                 )
                   or     exists (
                                     select
                                            null
                                       from
                                                 stn.feed              fd
                                            join stn.feed_record_count frc on fd.feed_uuid = frc.feed_uuid
                                      where
                                            idf.feed_sid          =  fd.feed_sid
                                        and frc.actual_record_cnt <> frc.stated_record_cnt
                                 )
               );

        stn.pr_step_run_log ( p_step_run_sid , $$PLSQL_UNIT , $$PLSQL_LINE , 'Number of broken feeds identified [malformed feed_record_count]' ,  'sql%rowcount' , null , sql%rowcount , null );

    end;

    procedure pr_cancel_broken_feeds
    (
        p_step_run_sid in stn.step_run.step_run_sid%type
    )
    is
    begin
        for dbtab in (
                         select
                                dbt.db_nm
                              , dbt.table_nm
                           from
                                     stn.feed_type         ft
                                join stn.step              st   on ft.process_id = st.process_id
                                join stn.step_run          sr   on st.step_id    = sr.step_id
                                join stn.feed_type_payload ftpl on ft.feed_typ   = ftpl.feed_typ
                                join stn.db_table          dbt  on ftpl.dbt_id   = dbt.dbt_id
                          where
                                sr.step_run_sid = p_step_run_sid
                     )
        loop
            execute immediate    ' update '
                              ||          sys.dbms_assert.sql_object_name ( dbtab.db_nm || '.' || dbtab.table_nm ) || ' alias '
                              || '    set '
                              || '        event_status = ''X'' '
                              || '      , step_run_sid = :p_step_run_sid '
                              || '  where '
                              || '        event_status != ''X'' '
                              || '    and ( '
                              || '               not exists ( '
                              || '                              select '
                              || '                                     null '
                              || '                                from '
                              || '                                     stn.feed fd '
                              || '                               where '
                              || '                                     alias.feed_uuid = fd.feed_uuid '
                              || '                          ) '
                              || '            or     exists ( '
                              || '                              select '
                              || '                                     null '
                              || '                                from '
                              || '                                          stn.feed            fd '
                              || '                                     join stn.broken_feed     bf  on fd.feed_sid = bf.feed_sid '
                              || '                                     join stn.identified_feed idf on bf.feed_sid = idf.feed_sid '
                              || '                               where '
                              || '                                     alias.feed_uuid = fd.feed_uuid '
                              || '                          ) '
                              || '            or     exists ( '
                              || '                              select '
                              || '                                     null '
                              || '                                from '
                              || '                                          stn.feed            fd '
                              || '                                     join stn.superseded_feed sf  on fd.feed_sid            = sf.superseded_feed_sid '
                              || '                                     join stn.identified_feed idf on sf.superseded_feed_sid = idf.feed_sid '
                              || '                               where '
                              || '                                     alias.feed_uuid = fd.feed_uuid '
                              || '                          ) '
                              || '        ) '
                        using
                              p_step_run_sid
                              ;

            stn.pr_step_run_log ( p_step_run_sid , $$PLSQL_UNIT , $$PLSQL_LINE , 'Number of records updated [belonging to a broken feed] in "' || dbtab.db_nm || '.' || dbtab.table_nm || '"' ,  'sql%rowcount' , null , sql%rowcount , null );

        end loop;
    end;

    procedure pr_verify
    (
        p_step_run_sid in stn.step_run.step_run_sid%type
    )
    is
    begin
        pr_identify_new_feeds        ( p_step_run_sid );
        pr_identify_superceded_feeds ( p_step_run_sid );
        pr_confirm_record_counts     ( p_step_run_sid );
        pr_confirm_stated_amounts    ( p_step_run_sid );
        pr_identify_broken_feeds     ( p_step_run_sid );
        pr_cancel_broken_feeds       ( p_step_run_sid );
    end pr_verify;

end pk_feed_integrity;
/
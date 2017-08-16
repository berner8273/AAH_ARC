create or replace view stn.feed_missing_record_count
as
select
       fd.feed_sid
     , dbt.db_nm
     , dbt.table_nm
  from
            stn.feed              fd
       join stn.feed_type_payload ftpl on fd.feed_typ = ftpl.feed_typ
       join stn.db_table          dbt  on ftpl.dbt_id = dbt.dbt_id
 where
          exists (
                      select
                             null
                        from
                                  stn.feed_type_payload ftpl_il
                             join stn.db_table          dbt_il  on ftpl_il.dbt_id = dbt_il.dbt_id
                       where
                             ftpl_il.feed_typ = fd.feed_typ
                         and not exists (
                                            select
                                                   null
                                              from
                                                   stn.feed_record_count frc
                                             where
                                                   frc.feed_uuid = fd.feed_uuid
                                               and trim ( lower ( dbt_il.db_nm ) )    = trim ( lower ( frc.db_nm ) )
                                               and trim ( lower ( dbt_il.table_nm ) ) = trim ( lower ( frc.table_nm ) )
                                        )
                  )
   and not exists (
                      select
                             null
                        from
                             stn.feed_record_count frc
                       where
                             frc.feed_uuid = fd.feed_uuid
                         and trim ( lower ( frc.db_nm ) )    = trim ( lower ( dbt.db_nm ) )
                         and trim ( lower ( frc.table_nm ) ) = trim ( lower ( dbt.table_nm ) )
                  );
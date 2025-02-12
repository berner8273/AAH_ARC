begin
    for i in (
                 select
                        'grant ' || case when lower ( object_type ) in ( 'table' , 'view' ) then 'select' else 'debug' end ||
                        ' on ' || lower ( owner ) || '.' || lower ( object_name ) || ' to aah_read_only' grant_stmt
                   from
                        dba_objects
                  where
                        lower ( owner )       in (
                                                   'stn'
                                                 , 'fdr'
                                                 , 'slr'
                                                 , 'rdr'
                                                 , 'gui'
                                                 )
                    and lower ( object_type ) in (
                                                   'table'
                                                 , 'view'
                                                 , 'package'
                                                 , 'procedure'
                                                 , 'function'
                                                 )
             )
    loop
        execute immediate i.grant_stmt;
    end loop;
end;
/

begin
    for i in (
                 select
                        'grant ' || case when lower ( object_type ) in ( 'table' , 'view' ) then 'select' else 'debug' end ||
                        ' on ' || lower ( owner ) || '.' || lower ( object_name ) || ' to aah_rdr' grant_stmt
                   from
                        dba_objects
                  where
                        lower ( owner )       in (
                                                   'rdr'
                                                 )
                    and lower ( object_type ) in (
                                                   'table'
                                                 , 'view'
                                                 )
             )
    loop
        execute immediate i.grant_stmt;
    end loop;
end;
/
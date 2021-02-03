DECLARE
  v_column_exists number := 0;  
BEGIN
    Select count(*) into v_column_exists
    from all_tab_cols
    where lower(table_name) = 'bak_slr_jrnl_headers'
      and upper(column_name) = 'JH_JRNL_ID_NEW'
      and owner = 'SLR';

  if (v_column_exists = 0) then
      execute immediate 'alter table slr.bak_slr_jrnl_headers add (JH_JRNL_ID_NEW CHAR(32 BYTE))';
  end if;
end;
/

DECLARE
  v_mapping_exists number := 0; 
  stmt varchar2(2000);
BEGIN
    Select count(*) into v_mapping_exists
    from slr.bak_slr_jrnl_headers
    where  JH_JRNL_ID_NEW IS NULL;

  if (v_mapping_exists > 0) then
      stmt := 'update slr.bak_slr_jrnl_headers b set jh_jrnl_id_new = standard_hash(to_char(b.jh_jrnl_id), ''MD5'')';
      execute immediate stmt;
      commit;
  end if;
end;
/
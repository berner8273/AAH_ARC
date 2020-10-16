DECLARE
  v_column_exists number := 0;  
BEGIN
  -- add column to cession_event
  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'RECLASS_ENTITY'
      and upper(table_name) = 'CESSION_EVENT'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cession_event add (RECLASS_ENTITY VARCHAR2(20))';
      commit;
  end if;

-- add account_cd
  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'ACCOUNT_CD'
      and upper(table_name) = 'CESSION_EVENT'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cession_event add (ACCOUNT_CD VARCHAR2(20))';
      commit;
  end if;

  -- add column to cev_valid
  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'RECLASS_ENTITY'
      and upper(table_name) = 'CEV_VALID'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cev_valid add (RECLASS_ENTITY VARCHAR2(20))';
      commit;
  end if; 
END;
/

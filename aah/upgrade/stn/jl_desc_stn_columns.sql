DECLARE
  v_column_exists number := 0;  
BEGIN
  -- add column to cession_event
  
  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'JL_DESCRIPTION'
      and upper(table_name) = 'CESSION_EVENT'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cession_event add (JL_DESCRIPTION VARCHAR2(100 byte))';
      commit;
  end if;

  -- add column to cev_vie_data
  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'JL_DESCRIPTION'
      and upper(table_name) = 'CEV_VIE_DATA'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cev_vie_data add (JL_DESCRIPTION VARCHAR2(100 byte))';
      commit;
  end if;

  -- add column to cev_intercompany_data
  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'JL_DESCRIPTION'
      and upper(table_name) = 'CEV_INTERCOMPANY_DATA'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cev_intercompany_data add (JL_DESCRIPTION VARCHAR2(100 byte))';
      commit;
  end if;

  -- add column to cev_non_intercompany_data
  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'JL_DESCRIPTION'
      and upper(table_name) = 'CEV_NON_INTERCOMPANY_DATA'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cev_non_intercompany_data add (JL_DESCRIPTION VARCHAR2(100 byte))';
      commit;
  end if;

  -- add column to cev_valid
  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'JL_DESCRIPTION'
      and upper(table_name) = 'CEV_VALID'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cev_valid add (JL_DESCRIPTION VARCHAR2(100 byte))';
      commit;
  end if;

-- add column to cev_mtm_data
  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'JL_DESCRIPTION'
      and upper(table_name) = 'CEV_MTM_DATA'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cev_mtm_data add (JL_DESCRIPTION VARCHAR2(100 byte))';
      commit;
  end if;        

-- add column to cev_gaap_fut_accts_data
  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'JL_DESCRIPTION'
      and upper(table_name) = 'CEV_GAAP_FUT_ACCTS_DATA'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cev_gaap_fut_accts_data add (JL_DESCRIPTION VARCHAR2(100 byte))';
      commit;
  end if;        

-- add column to cev_data
  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'JL_DESCRIPTION'
      and upper(table_name) = 'CEV_DATA'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cev_data add (JL_DESCRIPTION VARCHAR2(100 byte))';
      commit;
  end if;        


END;
/

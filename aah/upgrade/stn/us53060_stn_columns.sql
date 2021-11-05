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

  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'CHARTFIELD_1'
      and upper(table_name) = 'CESSION_EVENT'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cession_event add (CHARTFIELD_1 VARCHAR2(50))';
      commit;
  end if;

  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'JL_DESCRIPTION'
      and upper(table_name) = 'CESSION_EVENT'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cession_event add (JL_DESCRIPTION VARCHAR2(100 byte))';
      commit;
  end if;

  -- add column to posting_account_derivation
  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'VIE_BUSINESS_UNIT'
      and upper(table_name) = 'POSTING_ACCOUNT_DERIVATION'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.posting_account_derivation add (VIE_BUSINESS_UNIT VARCHAR2(50))';
      commit;
  end if;

  -- add column to posting_account_derivation
  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'ACCOUNT_CD'
      and upper(table_name) = 'POSTING_ACCOUNT_DERIVATION'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.posting_account_derivation add (ACCOUNT_CD VARCHAR2(20))';
      commit;
  end if;

  -- add column to vie_posting_account_derivation
  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'ACCOUNT_CD'
      and upper(table_name) = 'VIE_POSTING_ACCOUNT_DERIVATION'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.vie_posting_account_derivation add (ACCOUNT_CD VARCHAR2(20))';
      commit;
  end if;

  -- add column to cev_vie_data
  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'ACCOUNT_CD'
      and upper(table_name) = 'CEV_VIE_DATA'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cev_vie_data add (ACCOUNT_CD VARCHAR2(20))';
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
    where upper(column_name) = 'ACCOUNT_CD'
      and upper(table_name) = 'CEV_INTERCOMPANY_DATA'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cev_intercompany_data add (ACCOUNT_CD VARCHAR2(20))';
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
    where upper(column_name) = 'ACCOUNT_CD'
      and upper(table_name) = 'CEV_NON_INTERCOMPANY_DATA'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cev_non_intercompany_data add (ACCOUNT_CD VARCHAR2(20))';
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

  -- add column to load_fr_account_lookup
  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'AL_LOOKUP_5'
      and upper(table_name) = 'LOAD_FR_ACCOUNT_LOOKUP'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.load_fr_account_lookup add (AL_LOOKUP_5 VARCHAR2(20))';
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
  
-- add column to cev_valid
  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'ACCOUNT_CD'
      and upper(table_name) = 'CEV_VALID'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cev_valid add (ACCOUNT_CD VARCHAR2(20))';
      commit;
  end if;        

-- add column to cev_valid
  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'CHARTFIELD_1'
      and upper(table_name) = 'CEV_VALID'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cev_valid add (CHARTFIELD_1 VARCHAR2(50))';
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
    where upper(column_name) = 'ACCOUNT_CD'
      and upper(table_name) = 'CEV_MTM_DATA'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cev_mtm_data add (ACCOUNT_CD VARCHAR2(20))';
      commit;
  end if;        

-- add column to cev_mtm_data
  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'CHARTFIELD_1'
      and upper(table_name) = 'CEV_MTM_DATA'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cev_mtm_data add (CHARTFIELD_1 VARCHAR2(50))';
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
    where upper(column_name) = 'ACCOUNT_CD'
      and upper(table_name) = 'CEV_GAAP_FUT_ACCTS_DATA'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cev_gaap_fut_accts_data add (ACCOUNT_CD VARCHAR2(20))';
      commit;
  end if;        

-- add column to cev_gaap_fut_accts_data
  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'CHARTFIELD_1'
      and upper(table_name) = 'CEV_GAAP_FUT_ACCTS_DATA'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cev_gaap_fut_accts_data add (CHARTFIELD_1 VARCHAR2(20))';
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
    where upper(column_name) = 'ACCOUNT_CD'
      and upper(table_name) = 'CEV_DATA'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cev_data add (ACCOUNT_CD VARCHAR2(20))';
      commit;
  end if;        

-- add column to cev_data
  Select count(*) into v_column_exists
    from ALL_TAB_COLUMNS
    where upper(column_name) = 'CHARTFIELD_1'
      and upper(table_name) = 'CEV_DATA'
      and owner = 'STN' ;

  if (v_column_exists = 0) then
      execute immediate 'alter table stn.cev_data add (CHARTFIELD_1 VARCHAR2(100 byte))';
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

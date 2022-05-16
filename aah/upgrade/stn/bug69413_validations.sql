declare

nCount number:=0;

begin

select count(*) into nCount from STN.VALIDATION where validation_id = 87;
IF NOT nCount > 0 THEN
    Insert into STN.VALIDATION
    (VALIDATION_ID, VALIDATION_CD, CODE_MODULE_ID, VALIDATION_TYP_ID, VALIDATION_LEVEL_ID)
    Values
    (87, 'ce-acct_cd', 12, 5, 1);
END IF;

select count(*) into nCount from stn.db_tab_column where dtc_id = 291;
IF NOT nCount > 0 THEN
    INSERT INTO STN.DB_TAB_COLUMN (
    DTC_ID, DBT_ID, COLUMN_NM) 
    VALUES (291,7,'account_cd');
END IF;

select count(*) into nCount from STN.VALIDATION_COLUMN where validation_id = 87;
IF NOT nCount > 0 THEN
    Insert into STN.VALIDATION_COLUMN
    (VALIDATION_ID, DTC_ID)
    Values
    (87, 291);
END IF;
commit;   
END;
/
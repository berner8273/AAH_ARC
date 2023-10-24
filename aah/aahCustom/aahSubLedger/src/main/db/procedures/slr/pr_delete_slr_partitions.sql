CREATE OR REPLACE PROCEDURE SLR.pr_delete_slr_partitions IS

/******************************************************************************
   NAME:       pr_delete_slr_partitions
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/18/2023   aheavey       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     pr_delete_slr_partitions
      Sysdate:         10/18/2023
      Date and Time:   10/18/2023, 1:33:30 PM, and 10/18/2023 1:33:30 PM
      Username:        jberner (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/


   sSql varchar(1000);


--get all partitions that have zero rows and are earlier than the earliest date in each table.  Don't want to delete current or future partitions
cursor cur is
WITH 
-- get the earliest date in each table
min_date_tab as(
    select 'SLR_JRNL_HEADERS' tab_name,min(jh_jrnl_date) min_date from slr.slr_jrnl_headers
    union all 
    select 'SLR_JRNL_LINES' tab_name,min(jl_effective_date) min_date from slr.slr_jrnl_lines
    union all 
    select 'SLR_FAK_DAILY_BALANCES' tab_name,min(fdb_balance_date) min_date from slr.slr_fak_daily_balances
    union all 
    select 'SLR_EBA_DAILY_BALANCES' tab_name,min(edb_balance_date) min_date from slr.slr_eba_daily_balances),
t1 AS (
-- determine if partitions have any rows
SELECT
    mdt.*, 
    table_owner,
    table_name,
    partition_name,
    partition_position,
    high_value,
    TO_NUMBER (EXTRACTVALUE (XMLTYPE (DBMS_XMLGEN.getxml ('SELECT COUNT(*) AS rows_exist FROM '
                                                             || DBMS_ASSERT.enquote_name (str => table_owner)
                                                             || '.'
                                                             || DBMS_ASSERT.enquote_name (str => table_name)
                                                             || ' PARTITION ('
                                                             || DBMS_ASSERT.enquote_name (str => partition_name)
                                                             || ') WHERE ROWNUM <= 1'
                                                              )
                                          )
                                , '/ROWSET/ROW/ROWS_EXIST'
                                 )
                   ) AS rows_exist,
    to_date(substr('' || regexp_substr(  extractvalue( 
        dbms_xmlgen.getxmltype('SELECT t2.high_value 
                                    FROM all_tab_partitions t2 
                                    WHERE t2.table_name=''' || 
                                        t.TABLE_NAME || ''' AND
                                        t2.table_owner = ''' || 
                                        t.table_owner || ''' AND 
                                        t2.partition_name = ''' || 
                                        t.partition_name || ''''
                                         ), 
                                    '//text()' ),  '''.*?''') ,2,12) , 'yyyy-mm-dd' )
                                    as part_date                   
FROM 
    all_tab_partitions t,
    min_date_tab mdt
WHERE 
    table_owner = 'SLR' and
    t.table_name = mdt.tab_name and     
    table_name IN ('SLR_JRNL_HEADERS', 'SLR_JRNL_LINES','SLR_FAK_DAILY_BALANCES','SLR_EBA_DAILY_BALANCES')
ORDER BY 
    partition_position,
    table_owner,
    table_name,
    partition_position) -- end t1
select *
FROM t1
where 
    t1.part_date <t1.min_date and 
    rows_exist = 0;    

BEGIN

for rec in cur loop

    sSql := 'alter table '||rec.table_owner||'.'||rec.table_name||' drop partition '||rec.partition_name;
    execute immediate sSql;
end loop;


exception
    when others then
        raise_application_error(-20999,'Error deleting SLR partitions. '|| ' - '||sqlerrm);

END;
/
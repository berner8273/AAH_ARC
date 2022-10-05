DECLARE
  v_sql varchar2(1256);
  v_count_arc integer :=0;
  v_count1 integer :=0;
  v_count2 integer :=0;
  v_count3 number :=0;
  v_count4 number :=0;
  v_lpg_id number;
  bus_date  varchar2(10);
  bus_dateS varchar2(10);
  s_lpg varchar2(100);
  
  CURSOR c_slr
  IS
    SELECT 
        arct_id,arct_table_name t_name,arct_arc_table_name a_name,arct_archive_days a_days,arct_archive_date_column a_date,arct_schema_name schema,arct_archive_where_clause,arct_arc_schema_name,arct_lpg_column_name lpg_col 
    FROM 
        fdr.fr_archive_ctl 
    WHERE
        arct_archive = 'Y' and arct_schema_name = 'SLR';
       
       
BEGIN

dbms_output.put_line(q'['1','2','A','B','C','D','E','F']');
dbms_output.put_line(q'['ID','Group','Table','Schema','Rows Need Archive','Total Rows','Archived','Archive Log']');

  select to_char(gp_todays_bus_date,'mm/dd/yyyy') into bus_date from slr.fr_global_parameter where lpg_id=1;
  select to_char(sysdate,'mm/dd/yyyy') into bus_dateS from dual;

  FOR r_slr IN c_slr
  LOOP    

    IF r_slr.arct_archive_where_clause is null  THEN
        v_sql := 'select count(*) into :v_count1 from slr.'||r_slr.t_name||q'[ where ]'||r_slr.a_date||q'[ <= to_date(']'||bus_date||q'[','mm/dd/yyyy')]'||'  - '||r_slr.a_days;
        s_lpg := R_slr.lpg_col;
    ELSE
        v_sql :=  'select count(*) into :v_count1 from slr.'||r_slr.t_name||' where '||r_slr.arct_archive_where_clause||' and '||r_slr.a_date||q'[ <= to_date(']'||bus_date||q'[','mm/dd/yyyy')]'||'  - '||r_slr.a_days;
        s_lpg := '2';
    END IF;    
                   
    EXECUTE IMMEDIATE v_sql INTO v_count1;
        
    v_sql := 'select count(*) INTO :v_count2 from slr.'||r_slr.t_name;
    EXECUTE IMMEDIATE v_sql INTO v_count2;
  
   v_lpg_id:= 2;
    
   IF r_slr.arct_arc_schema_name <> 'PURGE' THEN
        v_sql := 'select count(*) INTO :v_count3 from SLR.'||r_slr.a_name; --||q'[ where ]'||r_slr.a_date||q'[ <= to_date(']'||bus_date||q'[','mm/dd/yyyy')]'||'  - '||r_slr.a_days;
        EXECUTE IMMEDIATE v_sql INTO v_count3;
    ELSE
        v_count3 :=0;
    END IF;                
        
    BEGIN 
    v_sql := 'select nvl(FL.ARL_RECORDS_ARCHIVED,0) INTO :v_count4 from fdr.fr_archive_ctl fc, fdr.fr_archive_log fl, fdr.fr_archive_log_header fh where FC.ARCT_ID = fl.arl_arct_id and fc.arct_table_name = '||''''||r_slr.t_name||''''||' and fl.arl_arlh_id = FH.ARLH_ID'
            ||' and fl.arl_arlh_id = FH.ARLH_ID and fl.arl_arlh_id in (select max(arlh_id) from fdr.fr_archive_log_header flh where flh.arlh_lpg_id = 1)';
    EXECUTE IMMEDIATE v_sql INTO v_count4;

    EXCEPTION WHEN NO_DATA_FOUND THEN
     v_count4:=0;
    END;    
           
   dbms_output.put_line(r_slr.arct_id||','||v_lpg_id||','|| r_slr.t_name||','||r_slr.schema||','||v_count1||','||v_count2||','||v_count3||','||v_count4);
    
  END LOOP;
  

END;
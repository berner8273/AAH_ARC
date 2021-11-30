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
  
  CURSOR c_fdr
  IS
    SELECT 
        arct_id,arct_table_name t_name,arct_arc_table_name a_name,arct_archive_days a_days,arct_archive_date_column a_date,arct_schema_name schema,arct_archive_where_clause,arct_arc_schema_name,arct_lpg_column_name lpg_col 
    FROM 
        fdr.fr_archive_ctl 
    WHERE
        arct_archive = 'Y' and arct_schema_name = 'FDR'; 
        
  CURSOR c_stn
  IS
    SELECT 
        arct_id,arct_table_name t_name,arct_arc_table_name a_name,arct_archive_days a_days,arct_archive_date_column a_date,arct_archive_where_clause wc,arct_schema_name schema
    FROM 
        fdr.fr_archive_ctl 
    WHERE
        arct_archive = 'Y' and arct_schema_name = 'STN';                        
       
BEGIN

dbms_output.put_line(q'['1','2','A','B','C','D','E','F']');
dbms_output.put_line(q'['ID','Group','Table','Schema','Rows Need Archive','Total Rows','Archived','Archive Log']');

  select to_char(gp_todays_bus_date,'mm/dd/yyyy') into bus_date from fdr.fr_global_parameter where lpg_id=1;
  select to_char(sysdate,'mm/dd/yyyy') into bus_dateS from dual;

  FOR r_fdr IN c_fdr
  LOOP    

    IF r_fdr.arct_arc_schema_name <> 'FDR' THEN
        v_sql := 'select count(*) into :v_count1 from fdr.'||r_fdr.t_name||q'[ where event_status in ('P','E') and ]'||r_fdr.a_date||q'[ <= to_date(']'||bus_date||q'[','mm/dd/yyyy')]'||'  - '||r_fdr.a_days;
    ELSE
        v_sql :=  'select count(*) into :v_count1 from fdr.'||r_fdr.t_name||' where '||r_fdr.arct_archive_where_clause;
    END IF;               
    EXECUTE IMMEDIATE v_sql INTO v_count1;
        
    v_sql := 'select count(*) INTO :v_count2 from fdr.'||r_fdr.t_name;
    EXECUTE IMMEDIATE v_sql INTO v_count2;
    
    v_sql:= 'select count(*) into :v_count_arc from all_tables where owner = ''ARC'' and table_name = '||''''||r_fdr.a_name||'''';
    EXECUTE IMMEDIATE v_sql INTO v_count_arc;                
  
    v_sql:= 'select '||r_fdr.lpg_col||' into :v_lpg_id from fdr.'||r_fdr.t_name||' where ROWNUM = 1';
    EXECUTE IMMEDIATE v_sql INTO v_lpg_id;                

    
   IF v_count_arc > 0 THEN
        v_sql := 'select count(*) INTO :v_count3 from ARC.'||r_fdr.a_name||q'[ where event_status in ('P','E') and ]'||r_fdr.a_date||q'[ <= to_date(']'||bus_date||q'[','mm/dd/yyyy')]'||'  - '||r_fdr.a_days;
        EXECUTE IMMEDIATE v_sql INTO v_count3;
    ELSE
        v_count3 :=0;
    END IF;                
        
    BEGIN 
    v_sql := 'select nvl(FL.ARL_RECORDS_ARCHIVED,0) INTO :v_count4 from fdr.fr_archive_ctl fc, fdr.fr_archive_log fl, fdr.fr_archive_log_header fh where FC.ARCT_ID = fl.arl_arct_id and fc.arct_table_name = '||''''||r_fdr.t_name||''''||' and fl.arl_arlh_id = FH.ARLH_ID'
            ||' and fl.arl_arlh_id = FH.ARLH_ID and fl.arl_arlh_id in (select max(arlh_id) from fdr.fr_archive_log_header flh where flh.arlh_lpg_id in (select '||r_fdr.lpg_col||' from fdr.'||r_fdr.t_name||' where rownum = 1))';
    
    EXECUTE IMMEDIATE v_sql INTO v_count4;

    EXCEPTION WHEN NO_DATA_FOUND THEN
     v_count4:=0;
    END;    
           
   dbms_output.put_line(r_fdr.arct_id||','||v_lpg_id||','|| r_fdr.t_name||','||r_fdr.schema||','||v_count1||','||v_count2||','||v_count3||','||v_count4);
    
  END LOOP;
  
  FOR r_stn IN c_stn
  LOOP    
   
   v_sql:= 'SELECT count(*) FROM STN.'||r_stn.t_name||q'[ t JOIN STN.FEED f ON t.feed_uuid = f.feed_uuid WHERE t.event_status in ('P','E','X') and f.loaded_ts <= to_date(']'||bus_dateS||q'[','mm/dd/yyyy')]'||'  - '||r_stn.a_days;  
   EXECUTE IMMEDIATE v_sql INTO v_count1;

   v_sql := 'select count(*) from stn.'||r_stn.t_name;
   EXECUTE IMMEDIATE v_sql INTO v_count2; 

   v_sql:= 'select count(*) into :v_lpg_id from stn.'||r_stn.t_name||' where ROWNUM = 1';
   EXECUTE IMMEDIATE v_sql INTO v_lpg_id;
   
   IF v_lpg_id > 0 THEN        
    v_sql:= 'select lpg_id into :v_lpg_id from stn.'||r_stn.t_name||' where ROWNUM = 1';
    EXECUTE IMMEDIATE v_sql INTO v_lpg_id;                
   END IF;
       
    BEGIN 
        v_sql := 'select FL.ARL_RECORDS_ARCHIVED INTO :v_count4 from fdr.fr_archive_ctl fc, fdr.fr_archive_log fl where FC.ARCT_ID = fl.arl_arct_id  and fc.arct_table_name = '||''''||r_stn.t_name||''''||' and fl.arl_arlh_id = (select max(arl_arlh_id) from fdr.fr_archive_log)';
        EXECUTE IMMEDIATE v_sql INTO v_count4;
        
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_count4:=0;
    END;    
    
    v_count3:=0;
                
   dbms_output.put_line(r_stn.arct_id||','||v_lpg_id||','|| r_stn.t_name||','||r_stn.schema||' '||','||v_count1||','||v_count2||','||v_count3||','||v_count4);    
    
 END LOOP;    

END;
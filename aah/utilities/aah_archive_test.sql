DECLARE
  v_sql varchar2(1256);
  v_count_arc integer:=0;
  v_count1 integer :=0;
  v_count2 integer :=0;
  v_count3 number :=0;
  v_count4 number :=0;
  
  CURSOR c_fdr
  IS
    SELECT 
        arct_table_name t_name,arct_arc_table_name a_name,arct_archive_days a_days,arct_archive_date_column a_date,arct_schema_name schema
    FROM 
        fdr.fr_archive_ctl 
    WHERE
        arct_archive = 'Y' and arct_schema_name = 'FDR'; 
        
  CURSOR c_stn
  IS
    SELECT 
        arct_table_name t_name,arct_arc_table_name a_name,arct_archive_days a_days,arct_archive_date_column a_date,arct_archive_where_clause wc,arct_schema_name schema
    FROM 
        fdr.fr_archive_ctl 
    WHERE
        arct_archive = 'Y' and arct_schema_name = 'STN'; 
                        
       
BEGIN

dbms_output.put_line(q'['A','B','C','D','E','F']');
dbms_output.put_line(q'['Table','Schema','Rows Need Archive','Total Rows','Archive Exists','Archive Log']');
  
  FOR r_fdr IN c_fdr
  LOOP    

    v_sql := 'select count(*) into :v_count1 from fdr.'||r_fdr.t_name||q'[ where event_status in ('P','E') and ]'||r_fdr.a_date||' <= sysdate - '||r_fdr.a_days;       

    EXECUTE IMMEDIATE v_sql INTO v_count1;
        
    v_sql := 'select count(*) INTO :v_count2 from fdr.'||r_fdr.t_name;
    EXECUTE IMMEDIATE v_sql INTO v_count2;
    
    v_sql:= 'select count(*) into :v_count_arc from dba_tables where owner = ''ARC'' and table_name = '||r_fdr.t_name;
    
    IF v_count_arc > 0 THEN
        v_sql := 'select count(*) INTO :v_count3 from ARC.'||r_fdr.a_name||q'[ where event_status in ('P','E') and ]'||r_fdr.a_date||' <= sysdate - '||r_fdr.a_days;   
        EXECUTE IMMEDIATE v_sql INTO v_count3;
    ELSE
        v_count3 :=0;
    END IF;                
  
    BEGIN 
    v_sql := 'select nvl(FL.ARL_RECORDS_ARCHIVED,0) INTO :v_count4 from fdr.fr_archive_ctl fc, fdr.fr_archive_log fl where FC.ARCT_ID = fl.arl_arct_id and fc.arct_table_name = '||''''||r_fdr.t_name||''''||' and fl.arl_archive_end = (select max(arl_archive_end) from fdr.fr_archive_log)';
    EXECUTE IMMEDIATE v_sql INTO v_count4;

    EXCEPTION WHEN NO_DATA_FOUND THEN
     v_count4:=0;
    END;    
           
   dbms_output.put_line( r_fdr.t_name||','||r_fdr.schema||','||v_count1||','||v_count2||','||v_count3||','||v_count4);
  
  END LOOP;
  
  FOR r_stn IN c_stn
  LOOP    
    
    v_sql:= 'SELECT count(*) FROM STN.'||r_stn.t_name||' t JOIN STN.FEED f ON t.feed_uuid = f.feed_uuid WHERE f.loaded_ts  <= sysdate - 182';  
    EXECUTE IMMEDIATE v_sql INTO v_count1;

   v_sql := 'select count(*) from stn.'||r_stn.t_name;
    EXECUTE IMMEDIATE v_sql INTO v_count2;
   
    BEGIN 
        v_sql := 'select sum(FL.ARL_RECORDS_ARCHIVED) INTO :v_count4 from fdr.fr_archive_ctl fc, fdr.fr_archive_log fl where FC.ARCT_ID = fl.arl_arct_id and trunc(sysdate-1)=trunc(fl.arl_archive_end) and fc.arct_table_name = '||''''||r_stn.t_name||'''';
        EXECUTE IMMEDIATE v_sql INTO v_count4;
        
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_count4:=0;
    END;    
    
    v_count3:=0;
                
   dbms_output.put_line( r_stn.t_name||','||r_stn.schema||' '||','||v_count1||','||v_count2||','||v_count3||','||v_count4);
    
    
 END LOOP;    
  
END;
commit;

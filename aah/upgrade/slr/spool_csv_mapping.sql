DECLARE  
 CURSOR c_get_mapping IS  
    SELECT distinct delrdd delrdd  
    from table1;  
  
 CURSOR c_extract(p_delrdd in date) IS  
    SELECT col1,  
           col2,  
           col3,  
           col4,  
           col5  
      FROM table1  
       WHERE trunc(delrdd) = p_delrdd;  
  
BEGIN  
    
  FOR date_rec IN c_get_dates LOOP  
  
 -------------------------------------------------------------------  
  --text_io.put_line(file_id,  
  dbms_output.put_line('hdr1' || ',' || 'hdr2 || ',' || 'hdr3' || ',' ||'hdr4' || ',' ||'hdr5');  
  
  
  FOR r_d IN c_extract(date_rec.delrdd) LOOP  
   BEGIN  
     --text_io.put_line(file_id,  
      dbms_output.put_line(r_d.col1 || ',' || r_d.col2 || ',' ||r_d.col3 || ',' || r_d.col4 || ',' ||r_d.col5);  
      
      EXCEPTION  
        --output data line  
        WHEN OTHERS THEN  
          null;  
      END; --output data line  
    END LOOP;  
--spool off;  
    END LOOP;  
  
EXCEPTION  
WHEN OTHERS THEN  
    dbms_output.put_line (SQLERRM);
END;   
/   
spool off;  
exit;  
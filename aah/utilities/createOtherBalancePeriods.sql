declare  
    in_start_date varchar2(10) :='2017-12-01';
    in_end_date varchar2(10) := '2019-04-30';
    display_date date;
    i number;
    nMonths number;
begin
    delete from fdr.fr_general_lookup where lk_lkt_lookup_type_code = 'EVENT_CLASS_PERIOD' and lk_match_key1 = 'BALANCE_OTHERS';
    --select months_between(to_date(in_end_date,'yyyy-mm-dd'),to_date(in_start_date,'yyyy-mm-dd')) into :nMonths from dual;
    display_date := add_months(to_date(in_start_date,'yyyy/mm/dd'),-1);
    for i in 1..months_between(to_date(in_end_date,'yyyy-mm-dd'),to_date(in_start_date,'yyyy-mm-dd')) loop
    display_date := last_day(add_months(display_date,1));    
    insert into fdr.fr_general_lookup ( lk_lkt_lookup_type_code , lk_match_key1 , lk_match_key2 , lk_match_key3 , lk_match_key4 , lk_lookup_value1 , lk_lookup_value2 , lk_lookup_value3 , lk_lookup_value5 , lk_lookup_value10 ) 
    VALUES ('EVENT_CLASS_PERIOD' , 'BALANCE_OTHERS' , to_char(display_date , 'yyyy') ,  to_char(display_date , 'mm')  ,to_char(display_date , 'yyyy-mm')  , 'O', '01-'||upper(to_char(display_date , 'mon-yyyy')), upper(to_char(display_date , 'dd-mon-yyyy')), 'N' , '8000');
    end loop;
end;

commit;

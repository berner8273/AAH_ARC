declare
  count_records integer;
begin
    select count(*) into count_records
    from fdr.fr_gaap
    where FGA_GAAP_ID = 'NVS';


if count_records = 0 then

    insert into fdr.fr_gaap ("FGA_GAAP_ID","FGA_GAAP_NAME","FGA_VALID_FROM","FGA_VALID_TO","FGA_ACTIVE","FGA_ACTION","FGA_INPUT_BY","FGA_INPUT_TIME","FGA_DELETE_TIME","FGA_AUTH_BY","FGA_AUTH_STATUS")
      VALUES ('NVS','NVS',TO_DATE('2000/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS'),TO_DATE('2999/12/31 23:59:59','YYYY/MM/DD HH24:MI:SS'),'A','I','CUST',sysdate,NULL,'CUST','A');
    commit;

end if;  
end;
/    
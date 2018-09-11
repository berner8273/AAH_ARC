declare
   c int;
begin
   select count(*) into c from all_views where view_name = upper('rrv_ag_slr_jrnl_lines');
   if c = 1 then
      execute immediate 'drop view rrv_ag_slr_jrnl_lines';
   end if;
end;
/
commit;

@@../aahCustom/aahRDR/src/main/db/views/rdr/rrv_ag_slr_jrnl_lines.sql

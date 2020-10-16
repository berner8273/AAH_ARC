update slr.SLR_HINTS_SETS 
set hs_hint = null
where HS_STATEMENT = 'IMPORT_INSERT_UNPOSTED';
commit;
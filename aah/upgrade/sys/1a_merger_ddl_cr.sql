declare

nCnt number;
sSQL varchar(5000);
begin

sSQL := 'grant delete on fdr.fr_general_lookup to stn';
execute immediate sSQL;

sSQL := 'grant select on fdr.fr_instrument to stn';
execute immediate sSQL;

sSQL := 'grant select on fdr.fr_instr_insure_extend to stn';
execute immediate sSQL;

sSQL := 'grant select on fdr.fr_trade to stn';
execute immediate sSQL;

sSQL := 'grant select on slr.SLR_EBA_DAILY_BALANCES to stn';
execute immediate sSQL;

sSQL := 'grant select on slr.SLR_LAST_BALANCE_HELPER to stn';
execute immediate sSQL;

sSQL := 'grant select on slr.slr_last_balances to stn';
execute immediate sSQL;

sSQL := 'grant select on rdr.rrv_ag_insurance_policy to stn';
execute immediate sSQL;

select count(*) into nCnt from all_tables where lower(table_name) = 'temp_stn_journal_line';
IF nCnt = 1 THEN 
    sSQL :=  'drop table stn.temp_stn_journal_line';
    execute immediate sSQL;
END IF;    

sSQL := 'create table stn.temp_stn_journal_line as select * from stn.journal_line where 1=2';
execute immediate sSQL;

sSQL := 'alter table stn.temp_stn_journal_line add  scenerio varchar(5)';
execute immediate sSQL;

sSQL := 'alter table stn.temp_stn_journal_line add  balance_type varchar(5)';
execute immediate sSQL;

sSQL := 'alter table stn.temp_stn_journal_line add  entry_type varchar(5)';
execute immediate sSQL;

sSQL := 'alter table stn.temp_stn_journal_line add  eba_id char(32)';
execute immediate sSQL;

sSQL := 'alter table stn.temp_stn_journal_line add  processed varchar(1)';
execute immediate sSQL;

sSQL := 'alter table stn.temp_stn_journal_line modify event_Typ varchar(23)';
execute immediate sSQL;



sSQL := 'create index stn.idx_temp_stn_journal_line on stn.temp_stn_journal_line (eba_id)';
execute immediate sSQL;
 

select count(*) into nCnt from all_indexes where lower(index_name) = 'ajh_temp_db';
IF nCnt = 0 THEN
    sSQL := 'CREATE INDEX SLR.AJH_TEMP_DB ON SLR.SLR_EBA_DAILY_BALANCES (EDB_EBA_ID)';
    Execute immediate sSQL;
END IF;    

---select count(*) into nCnt from all_indexes where lower(index_name) = 'ajh_temp_lb';
--IF nCnt = 0 THEN
--    sSQL := 'CREATE INDEX SLR.AJH_TEMP_LB ON SLR.SLR_LAST_BALANCES (LB_EBA_ID)';
--    execute immediate sSQL;
--END IF;


select count(*) into nCnt from all_indexes where lower(index_name) = 'ajh_temp_slr_jl_eba_id'; 
IF nCnt = 0 THEN
    sSql := 'CREATE INDEX SLR.AJH_TEMP_SLR_JL_EBA_ID ON SLR.SLR_JRNL_LINES (JL_EBA_ID)';
    execute immediate sSQL;
END IF ;   

select count(*) into nCnt from all_tables where lower(table_name) = 'merger_balances';
IF nCnt = 1 THEN
    sSQL := 'drop table stn.merger_balances';
    execute immediate sSQL;
END IF;    

-- business event type
sSQL := 'alter table stn.journal_line disable constraint fk_be_jl';
execute immediate sSQL;

-- combo edit requires affiliate. balances exist without affiliate
update fdr.fr_general_codes
set gc_active = 'I'
where gc_client_code = '14400330';



sSQL := 
'create table stn.merger_balances                           '||  
'(                                                          '||    
'  eab_fak_id                char(32 byte)       not null,  '||
'  eab_eba_id                char(32 byte)       not null,  '||
'  eab_balance_date          date                not null,  '||
'  eab_balance_type          number(2)           not null,  '||
'  eab_tran_daily_movement   number(38,3)        not null,  '||
'  eab_tran_mtd_balance      number(38,3)        not null,  '||
'  eab_tran_ytd_balance      number(38,3)        not null,  '||
'  eab_tran_ltd_balance      number(38,3)        not null,  '||
'  eab_base_daily_movement   number(38,3)        not null,  '||
'  eab_base_mtd_balance      number(38,3)        not null,  '||
'  eab_base_ytd_balance      number(38,3)        not null,  '||
'  eab_base_ltd_balance      number(38,3)        not null,  '||
'  eab_local_daily_movement  number(38,3)        not null,  '||
'  eab_local_mtd_balance     number(38,3)        not null,  '||
'  eab_local_ytd_balance     number(38,3)        not null,  '||
'  eab_local_ltd_balance     number(38,3)        not null,  '||
'  eab_entity                varchar2(20 byte)   not null,  '||
'  eab_epg_id                varchar2(18 byte)   not null,  '||
'  eab_period_month          number(2)           not null,  '||
'  eab_period_year           number(4)           not null,  '||
'  eab_period_ltd            number(4)           not null   '||
')                                                          '||    
'tablespace stn_data';

execute immediate sSQL;

sSQL := 'create index stn.merger_balances_idx on stn.merger_balances (eab_eba_id)';
execute immediate sSQL;

end;
/
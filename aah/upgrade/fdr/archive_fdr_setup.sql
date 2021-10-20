declare
nCount1  NUMBER;

begin

SELECT count(*) into nCount1 FROM dba_tables where upper(table_name) = 'FR_INSTR_INSURE_EXTEND_KEEP';

IF nCount1 = 0  THEN  
   execute immediate 'create table fr_instr_insure_extend_keep as select * from fr_instr_insure_extend where 1 = 2';
ELSE
    execute immediate 'truncate table fr_instr_insure_extend_keep';
END IF;

END;
/

declare
nCount  NUMBER;
nSavedCount NUMBER;

begin

select count(*) into nSavedCount from (
select * from fdr.fr_instr_insure_extend k
where k.iie_instrument_id IN  
    (select t1.t_i_instrument_id 
    from fdr.fr_trade t1 
    where 
        t1.t_source_tran_no = 1 OR 
        t1.t_fdr_ver_no = (select max(t2.t_fdr_ver_no) from fdr.fr_trade t2 where t1.t_source_tran_no = t2.t_source_tran_no)) 
);

execute immediate 'insert into fdr.fr_instr_insure_extend_keep (select * from fdr.fr_instr_insure_extend k where k.iie_instrument_id IN (select t1.t_i_instrument_id from fdr.fr_trade t1 where t1.t_source_tran_no = 1 OR t1.t_fdr_ver_no = (select max(t2.t_fdr_ver_no) from fdr.fr_trade t2 where t1.t_source_tran_no = t2.t_source_tran_no)))';

select count(*) into nCount from fdr.fr_instr_insure_extend_keep;
IF nCount = nSavedCount THEN
 execute immediate 'truncate table fr_instr_insure_extend';
 execute immediate 'insert /*+APPEND*/ into fr_instr_insure_extend (select * from fr_instr_insure_extend_keep)';
END IF;  

end;
/

declare
nCount1  NUMBER;

begin

SELECT count(*) into nCount1 FROM dba_tables where upper(table_name) = 'FR_INSTRUMENT_KEEP';

IF nCount1 = 0  THEN  
   execute immediate 'create table fr_instrument_keep as select * from fr_instrument where 1 = 2';
ELSE
    execute immediate 'truncate table fr_instrument_keep';
END IF;

END;
/

-- disable the constraints to allow table truncate
begin
    for i in (
    select 'alter table '||b.table_name||' disable constraint ' ||b.constraint_name grant_stmt
from
    dba_constraints a, dba_constraints b, dba_cons_columns c
    where a.owner=b.r_owner
        and b.owner=c.owner
        and b.table_name=c.table_name
        and b.constraint_name=c.constraint_name
        and a.constraint_name=b.r_constraint_name
        and b.constraint_type='R'
        and a.table_name in ('FR_INSTRUMENT','FR_TRADE')
        and a.CONSTRAINT_TYPE='P'             
             )
    loop
        execute immediate i.grant_stmt;
    end loop;
end;
/

declare
nCount  NUMBER;
nSavedCount NUMBER;

begin

select count(*) into nSavedCount from (
select * from fdr.fr_instrument k 
where
    k.i_instrument_id IN ('1','INSURANCE_POLICY') OR 
    k.i_instrument_id in (select t1.t_i_instrument_id from fdr.fr_trade t1 where  t1.t_source_tran_no <> 1 and t1.t_fdr_ver_no = (select max(t2.t_fdr_ver_no) from fdr.fr_trade t2 where t1.t_source_tran_no = t2.t_source_tran_no))
);

execute immediate 'insert into fdr.fr_instrument_keep '||q'[(select * from fdr.fr_instrument k where k.i_instrument_id IN ('1','INSURANCE_POLICY') OR k.i_instrument_id in (select t1.t_i_instrument_id from fdr.fr_trade t1 where  t1.t_source_tran_no <> 1 and t1.t_fdr_ver_no = (select max(t2.t_fdr_ver_no) from fdr.fr_trade t2 where t1.t_source_tran_no = t2.t_source_tran_no)))]';          

select count(*) into nCount from fr_instrument_keep;
IF nCount = nSavedCount THEN
 
 execute immediate 'truncate table fr_instrument';
 execute immediate 'insert /*+APPEND*/ into fr_instrument (select * from fr_instrument_keep)';

END IF;  

end;
/

declare
nCount1  NUMBER;

begin

SELECT count(*) into nCount1 FROM dba_tables where upper(table_name) = 'FR_TRADE_KEEP';

IF nCount1 = 0  THEN  
   execute immediate 'create table fr_trade_keep as select * from fr_trade where 1 = 2';
ELSE
    execute immediate 'truncate table fr_trade_keep';
END IF;

END;
/

declare
nCount  NUMBER;
nSavedCount NUMBER;

begin

select count(*) into nSavedCount from (
select * from fdr.fr_trade k where
k.t_trade_id in (
    select t1.t_trade_id 
    from fdr.fr_trade t1 
    where t1.t_source_tran_no = 1 OR
    t1.t_fdr_ver_no = (select max(t2.t_fdr_ver_no) from fdr.fr_trade t2 where t1.t_source_tran_no = t2.t_source_tran_no))
);

execute immediate 'insert into fdr.fr_trade_keep '||q'[select * from fdr.fr_trade k where k.t_trade_id in (select t1.t_trade_id from fdr.fr_trade t1 where t1.t_source_tran_no = 1 OR t1.t_fdr_ver_no = (select max(t2.t_fdr_ver_no) from fdr.fr_trade t2 where t1.t_source_tran_no = t2.t_source_tran_no))]';          

select count(*) into nCount from fr_trade_keep;
IF nCount = nSavedCount THEN
 
 execute immediate 'truncate table fr_trade';
 execute immediate 'insert /*+APPEND*/ into fr_trade (select * from fr_trade_keep)';

END IF;  

-- enable the constraints back
FOR i in (
    select 'alter table '||b.table_name||' enable constraint ' ||b.constraint_name grant_stmt
from
    dba_constraints a, dba_constraints b, dba_cons_columns c
    where a.owner=b.r_owner
        and b.owner=c.owner
        and b.table_name=c.table_name
        and b.constraint_name=c.constraint_name
        and a.constraint_name=b.r_constraint_name
        and b.constraint_type='R'
        and a.table_name in ('FR_INSTRUMENT','FR_TRADE')
        and a.CONSTRAINT_TYPE='P'             
             )
    loop
        execute immediate i.grant_stmt;
    end loop;


commit;

execute immediate 'drop table fr_instr_insure_extend_keep';
execute immediate 'drop table fr_instrument_keep';
execute immediate 'drop table fr_trade_keep';


end;
/
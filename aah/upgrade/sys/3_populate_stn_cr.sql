-- move from temp table to stn.journal_line
declare 
nCnt number;
Ssql varchar(200);

begin

stn.temp_pkg_merger_EA010.pInsertJournalLine(1);
stn.temp_pkg_merger_EA010.pInsertJournalLine(2);
stn.temp_pkg_merger_EA010.pInsertJournalLine(3);
stn.temp_pkg_merger_EA010.pInsertJournalLine(4);
stn.temp_pkg_merger_EA010.pInsertJournalLine(5);
stn.temp_pkg_merger_EA010.pInsertJournalLine(6);
stn.temp_pkg_merger_EA010.pInsertJournalLine(7);
stn.temp_pkg_merger_EA010.pInsertJournalLine(8);
stn.temp_pkg_merger_EA010.pInsertJournalLine(9);
stn.temp_pkg_merger_EA010.pInsertJournalLine(10);
stn.temp_pkg_merger_EA010.pInsertJournalLine(11);
commit;


select count(*) into nCnt from all_indexes where lower(index_name) = 'ajh_temp_db';
IF nCnt = 1 THEN
    sSQL := 'DROP INDEX SLR.AJH_TEMP_DB';
    Execute immediate sSQL;
END IF;    



select count(*) into nCnt from all_indexes where lower(index_name) = 'ajh_temp_slr_jl_eba_id'; 
IF nCnt = 1 THEN
    sSql := 'DROP INDEX SLR.AJH_TEMP_SLR_JL_EBA_ID';
    execute immediate sSQL;
END IF ;   


end;
/

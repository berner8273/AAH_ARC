-- move from temp table to stn.journal_line
begin
stn.temp_pkg_merger.pInsertJournalLine(1);
stn.temp_pkg_merger.pInsertJournalLine(2);
stn.temp_pkg_merger.pInsertJournalLine(3);
stn.temp_pkg_merger.pInsertJournalLine(4);
stn.temp_pkg_merger.pInsertJournalLine(5);
stn.temp_pkg_merger.pInsertJournalLine(6);
stn.temp_pkg_merger.pInsertJournalLine(7);
stn.temp_pkg_merger.pInsertJournalLine(8);
stn.temp_pkg_merger.pInsertJournalLine(9);
stn.temp_pkg_merger.pInsertJournalLine(10);
stn.temp_pkg_merger.pInsertJournalLine(11);
commit;
end;
/
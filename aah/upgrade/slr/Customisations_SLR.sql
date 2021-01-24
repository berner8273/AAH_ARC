spool Customisations_SLR.log
set echo on

-- drop and rebuild the FAK_BOP_AMOUNTS GTTs
drop table SLR.SLR_FAK_BOP_AMOUNTS_TMP;
drop table SLR.SLR_FAK_BOP_AMOUNTS_TMP2;
drop table SLR.SLR_FAK_BOP_AMOUNTS_TMP3;
@@001_SLR_FAK_BOP_AMOUNTS_TMP.sql;
@@002_SLR_FAK_BOP_AMOUNTS_TMP2.sql;
@@003_SLR_FAK_BOP_AMOUNTS_TMP3.sql;

-- drop and rebuild the EBA_BOP_AMOUNTS GTTs
drop table SLR.SLR_EBA_BOP_AMOUNTS_TMP;
drop table SLR.SLR_EBA_BOP_AMOUNTS_TMP2;
drop table SLR.SLR_EBA_BOP_AMOUNTS_TMP3;
@@011_SLR_EBA_BOP_AMOUNTS_TMP.sql;
@@012_SLR_EBA_BOP_AMOUNTS_TMP2.sql;
@@013_SLR_EBA_BOP_AMOUNTS_TMP3.sql;

-- Reload the views - make sure we have the QTD and QTR values in them.
--@@020_V_SLR_JRNL_LINES_UNPOSTED_JT.sql
--@@021_V_SLR_JOURNAL_LINES.sql
@@../aahCustom/aahSubLedger/src/main/db/views/slr/v_slr_jrnl_lines_unposted_jt.sql
@@../aahCustom/aahSubLedger/src/main/db/views/slr/v_slr_journal_lines.sql

-- Load the SLR packages

@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_balance_movement_pkg.hdr
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_balance_movement_pkg.bdy
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_client_procedures_pkg.hdr
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_client_procedures_pkg.bdy
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_post_journals_pkg.hdr
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_post_journals_pkg.bdy
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_translate_journals_pkg.hdr
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_translate_journals_pkg.bdy
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_validate_journals_pkg.hdr
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_validate_journals_pkg.bdy
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_pkg.hdr
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_pkg.bdy

show errors


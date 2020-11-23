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
@@020_V_SLR_JRNL_LINES_UNPOSTED_JT.sql
@@021_V_SLR_JOURNAL_LINES.sql

-- Load the SLR packages
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_BALANCE_MOVEMENT_PKG.hdr
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_BALANCE_MOVEMENT_PKG.bdy
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_CLIENT_PROCEDURES_PKG.hdr
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_CLIENT_PROCEDURES_PKG.bdy
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_PKG.hdr
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_PKG.bdy
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_POST_JOURNALS_PKG.hdr
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_POST_JOURNALS_PKG.bdy
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_TRANSLATE_JOURNALS_PKG.hdr
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_TRANSLATE_JOURNALS_PKG.bdy
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_VALIDATE_JOURNALS_PKG.hdr
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_VALIDATE_JOURNALS_PKG.bdy

show errors

exit
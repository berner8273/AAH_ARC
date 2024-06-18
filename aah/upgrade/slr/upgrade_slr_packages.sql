@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_PKG.hdr;
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_PKG.bdy;
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_UTILITIES_PKG.hdr;
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_UTILITIES_PKG.bdy;
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_VALIDATE_JOURNALS_PKG.hdr;
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_VALIDATE_JOURNALS_PKG.bdy;
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_POST_JOURNALS_PKG.hdr;
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_POST_JOURNALS_PKG.bdy;
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_BALANCE_MOVEMENT_PKG.hdr;
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/SLR_BALANCE_MOVEMENT_PKG.bdy;

Insert into SLR_HINTS_SETS
   (HS_SET, HS_STATEMENT, HS_HINT, HS_DESCRIPTION)
 Values
   ('DEFAULT', 'MERGE_EBA_EXISTS', '/*+ no_parallel */', 'Added in 24.1.1');
COMMIT;
/
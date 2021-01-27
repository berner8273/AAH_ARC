--spool Customisations_SLR.log
--set echo on

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
@@../aahCustom/aahSubLedger/src/main/db/views/slr/v_slr_jrnl_lines_unposted_jt.sql;
@@../aahCustom/aahSubLedger/src/main/db/views/slr/v_slr_journal_lines.sql;

-- Load the SLR packages

@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_balance_movement_pkg.hdr;
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_balance_movement_pkg.bdy;
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_client_procedures_pkg.hdr;
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_client_procedures_pkg.bdy;
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_post_journals_pkg.hdr;
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_post_journals_pkg.bdy;
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_translate_journals_pkg.hdr;
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_translate_journals_pkg.bdy;
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_validate_journals_pkg.hdr;
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_validate_journals_pkg.bdy;
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_pkg.hdr;
@@../aahCustom/aahSubLedger/src/main/db/packages/slr/slr_pkg.bdy;

DECLARE
    i INTEGER;
BEGIN

    SELECT COUNT(*) INTO i FROM user_indexes WHERE index_name= 'IDX_JL_SOURCE_JRNL_ID' and table_name = 'BAK_SLR_JRNL_LINES';
    IF i = 1 THEN
        EXECUTE IMMEDIATE 'ALTER INDEX IDX_JL_SOURCE_JRNL_ID RENAME TO BAK_IDX_JL_SOURCE_JRNL_ID';        
    END IF;
    
        SELECT COUNT(*) INTO i FROM user_indexes WHERE index_name= 'IDX_JRNL_LINES_SLRPROCESS' and table_name = 'BAK_SLR_JRNL_LINES';
    IF i = 1 THEN
        EXECUTE IMMEDIATE 'ALTER INDEX IDX_JRNL_LINES_SLRPROCESS RENAME TO BAK_IDX_JRNL_LINES_SLRPROCESS';        
    END IF;
    
        SELECT COUNT(*) INTO i FROM user_indexes WHERE index_name= 'IDX_JL_SOURCE_JRNL_ID' and table_name = 'SLR_JRNL_LINES';
    IF i = 0 THEN
        EXECUTE IMMEDIATE 'CREATE INDEX SLR.IDX_JL_SOURCE_JRNL_ID ON SLR.SLR_JRNL_LINES (JL_SOURCE_JRNL_ID)';        
    END IF;
    
        SELECT COUNT(*) INTO i FROM user_indexes WHERE index_name= 'IDX_JRNL_LINES_SLRPROCESS' and table_name = 'SLR_JRNL_LINES';
    IF i = 0 THEN
        EXECUTE IMMEDIATE 'CREATE INDEX SLR.IDX_JRNL_LINES_SLRPROCESS ON SLR.SLR_JRNL_LINES (JL_EFFECTIVE_DATE, JL_EPG_ID, JL_JRNL_HDR_ID)';        
    END IF;
END;
/
DECLARE
    i INTEGER;
BEGIN

    --RENAME INDEX
    SELECT COUNT(*) INTO i FROM user_indexes WHERE index_name= 'PK_JRNL_HDR_P' and table_name = 'BAK_SLR_JRNL_HEADERS';
    IF i = 1 THEN
        EXECUTE IMMEDIATE 'ALTER INDEX PK_JRNL_HDR_P RENAME TO BAK_PK_JRNL_HDR_P';        
    END IF;    
    --RENAME CONSTRANT
    SELECT COUNT(*) INTO i FROM USER_CONSTRAINTS WHERE CONSTRAINT_NAME = 'PK_JRNL_HDR_P' and table_name = 'BAK_SLR_JRNL_HEADERS';
    IF i = 1 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE BAK_SLR_JRNL_HEADERS RENAME CONSTRAINT PK_JRNL_HDR_P TO BAK_PK_JRNL_HDR_P';        
    END IF;    
    --ADD CONSTRAINT    
  
    SELECT COUNT(*) INTO i FROM USER_CONSTRAINTS WHERE CONSTRAINT_NAME= 'PK_JRNL_HDR_P' and table_name = 'SLR_JRNL_HEADERS';
    IF i = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE SLR.SLR_JRNL_HEADERS ADD CONSTRAINT PK_JRNL_HDR_P PRIMARY KEY (JH_JRNL_ID)';        
    END IF;
        
    --* RENAME AND CREATE IDX_JH_JRNL_INTPRD_FLAG
    SELECT COUNT(*) INTO i FROM user_indexes WHERE index_name= 'IDX_JRNL_LINES_SLRPROCESS' and table_name = 'BAK_SLR_JRNL_HEADERS';
    IF i = 1 THEN
        EXECUTE IMMEDIATE 'ALTER INDEX IDX_JH_JRNL_INTPRD_FLAG RENAME TO BAK_IDX_JH_JRNL_INTPRD_FLAG';        
    END IF;
    
    SELECT COUNT(*) INTO i FROM user_indexes WHERE index_name= 'IDX_JH_JRNL_INTPRD_FLAG' and table_name = 'SLR_JRNL_HEADERS';
    IF i = 0 THEN
        EXECUTE IMMEDIATE 'CREATE INDEX SLR.IDX_JH_JRNL_INTPRD_FLAG ON SLR.SLR_JRNL_HEADERS (JH_JRNL_INTERNAL_PERIOD_FLAG)';        
    END IF;
    
END; 


spool Customisations_RDR.log
set echo on

-- Migrate GLINT tables with journal header IDs in them...
@@101_migrate_RR_GLINT_TO_SLR_AG.sql
@@102_migrate_RR_GLINT_JOURNAL_LINE.sql
@@102_2_migrate_rr_glint_journal_line.sql

-- Recreate the temp tables with columns updated
@@103_RR_GLINT_TEMP_JOURNAL.sql
@@104_RR_GLINT_TEMP_JOURNAL_LINE.sql

-- Migrate journal mappings
@@106_migrate_RR_GLINT_JOURNAL_MAPPING.sql

-- fix glint views that the upgrade causes problems for (types changed by hashing)

--@@../aahCustom/aahRDR/src/main/db/views/rdr/rrv_ag_slr_jrnl_headers.sql
--@@../aahCustom/aahRDR/src/main/db/views/rdr/rrv_ag_slr_jrnl_lines.sql


show errors


CREATE OR REPLACE PACKAGE SLR.SLR_POST_JOURNALS_PKG AS
-- -------------------------------------------------------------------------------
-- 124
-- Id:          $Id: slr_post_journals_pkg.sql,v 1.10 2005/05/31 07:48:14 pfrench Exp $
--
-- Description:
--
-- MHC 24-NOV-2004 BASELINE CODE FOR RELEASE 2
-- ASH 26-JAN-2005 COMPLETE CODE FOR RELEASE 2
-- PDF 10-MAY-2005 TTP90 - Replacing the use of dates with logical integers in balances
-- BJP 17-AUG-2007 Amend logic for back-dated postings over business year end
-- KFM 03-OCT-2008 Added ENT_APPLY_FX_TRANSLATION to FX Translation processes
-- JE  19-OCT-2009 Amended fUpdateDailyBalancesEBA step 2, update to SLR_EBA_DAILY_BALANCES ref TTP 652 and advice from JP.
-- RM  05-APR-2011 TTP1032 (related to TTP1014) v2.26 Fix to prevent partially validated journal from posting
-- RM  05-APR-2011 TTP1038 v2.26 performance. Specifically to cope with large number of entities (200+)
--                 on smaller spec Oracle server.  Making use of new SLR_[FAK|EBA]_JLU_SUMMARY_TMP tables,
--                 MERGE and "WITH SELECT" syntax (to simplify queries) and FORALL cursors to speed up inserts.
--                 Additionally using variable pNumLinesTrigParallel to determine whether or not to use parallel processing.
-- RM  09-JUL-2012 RM MAH v2.26 to MAHv3.05 upgrade.  This is now to be treated as a core package - but
--                 read the next comment.
-- RM  09-JUL-2012 RM Missing attribute in SLR_ENTITIES to enable/disable core p&L cleardown in fUpdateDailyBalancesFAK|EBA
--                 Contacted Microgen, Ref F0001721.  The change would be to add a new column in SLR_ENTITIES called
--                 ENT_APPLY_YEAR_END_CLEARDOWN that by defauly is set to 'Y'. To disable core processing the flag
--                 would be set to 'N'.
-- RM  09-JUL-2012 RM Improve logic to set gBusDate global to prevent the posting from erroring if the FDR.FR_LPG_CONFIG
--                 table is not populated.  Contact Microgen Ref. F0000824
-- RM  09-AUG-2012 Fix cleardown insert criteria in fUpdateDailyBalancesFAK|EBA. Restrict to PnL accounts. Ref. F0001923
-- RM  11-AUG-2012 Comment out inserts/deletes to/from SLR_FAK|EBA_LAST_BALANCE_TMP as not used. Ref. F0001923 (2nd part)
-- RM  17-AUG-2012 Large vs Small re-implement from v2.26 (do not run parallel from small no of journals) Ref. F0001923
-- RM  18-AUG-2012 Added attributes entity and last_balance_date_id to global temp tables SLR_FAK|EBA_JLU_SUMMARY_TMP
--                 used as follows:
--                 (1) fAggregateJrnlLinesUnposted - populate entity from JLU and set last bal date as default 1970010100
--                 (2) fUpdateBckDtdDailyBalancesFAK|EBA.  update last balance date, will help exclude new combinations form the merge
--                                                         make use of entity in the join
--                                                         formed cartesian of all fak|eba balance records in the select part of merge
--                                                         removed the leading hint - main performance inmprovement got from this.
--                 (3) fInsertBckDtdDailyBalancesFAK|EBA   fixed join criteria mainly join between jlu summary tmp and last balance
-- MCY 21-FEB-2013 fInsNonBckDtdDailyBalances queries rewritten to EXECUTE IMMEDIATE to force generating new query plan for each Entity.
-- MCY 07-MAR-2013 fInsertBckDtdDailyBalances queries rewritten to UNION ALL form to distinguish whether a previous balance exists or not
--                 and to EXECUTE IMMEDIATE to force generating new query plan for each Entity.
-- -------------------------------------------------------------------------------
    gp_process_id  NUMBER:=0; 
	gp_business_date date;
    gp_rate_set slr_entities.ent_rate_set%TYPE;
    /* Declare public procedures                                                */
    PROCEDURE pPostJournals
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER,
        p_status IN CHAR := 'U',
        p_UseHeaders IN BOOLEAN := FALSE,
		p_rate_set IN slr_entities.ent_rate_set%TYPE
    );

    PROCEDURE pSetEbaIndexes(p_local BOOLEAN, p_global BOOLEAN);

    PROCEDURE pSetFakIndexes(p_local BOOLEAN, p_global BOOLEAN);


    -- mode: 1 - using DDL (exchange partitions); 2 - using MERGE
    -- default mode is 2
    -- 2nd mode is better for small number of journal lines and has better support for transactions
    PROCEDURE pEbaBalancesGenerationMode(p_mode INT);
    PROCEDURE pFakBalancesGenerationMode(p_mode INT);

    -- If p_generate is true then pGenerateLastBalances will be called at the end of posting
    -- to generate last balances for the Business Date. By default - does not generate.
    PROCEDURE pStatusGenLastBalForBD(p_generate BOOLEAN);


    PROCEDURE pGenerateLastBalances
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER,
        p_day DATE -- last balances will be generated for this day
    );

     PROCEDURE pCreate_reversing_journal
    (jrnl_id_list varchar2, entity_proc_group VARCHAR2, status CHAR, process_id number);

  PROCEDURE pCreate_rev_journal_batch
    (orignal_jrnl_id VARCHAR2, entity_proc_group VARCHAR2, status CHAR, process_id number);

  PROCEDURE pCreate_reversing_journal_madj
    (jrnl_id_list varchar2, entity_proc_group VARCHAR2, status CHAR, process_id number);

  PROCEDURE pGenerateFAKLastBalances
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER,
        p_day DATE -- last balances will be generated for this day
    );

  PROCEDURE pUpdateJournal(p_part_process     IN VARCHAR2,
                           p_start_row       IN NUMBER,
                           p_end_row         IN NUMBER,
                           p_bulk_processing IN VARCHAR2,
                           p_epg_id          IN VARCHAR2,
                           p_part_epg        IN VARCHAR2,
                           p_alert           in VARCHAR2,
                           p_rollback        in VARCHAR2);

END SLR_POST_JOURNALS_PKG;
/
CREATE OR REPLACE PACKAGE BODY GUI."PGUI_MANUAL_JOURNAL"
AS
   /******************************************************************************************
   Declare private processes
   ******************************************************************************************/

   FUNCTION fnui_validate_journal_header
      RETURN CHAR;

   FUNCTION fnui_validate_journal_line (clear_errors BOOLEAN DEFAULT TRUE)
      RETURN CHAR;

   FUNCTION fnui_resync_journal_lines
      RETURN BOOLEAN;

   FUNCTION fnui_validate_header_dates
      RETURN BOOLEAN;

   FUNCTION fnui_validate_line_dates
      RETURN BOOLEAN;

   FUNCTION fnui_validate_balances
      RETURN BOOLEAN;

   FUNCTION fnui_validate_account
      RETURN BOOLEAN;

   FUNCTION fnui_validate_ledger
      RETURN BOOLEAN;

   FUNCTION fnui_validate_periods
      RETURN BOOLEAN;

   FUNCTION fnui_check_currencies
      RETURN BOOLEAN;

   FUNCTION fnui_get_journal_type
      RETURN BOOLEAN;

   FUNCTION fnui_get_entity
      RETURN BOOLEAN;

   FUNCTION fnui_get_fak_definitions
      RETURN BOOLEAN;

   FUNCTION fnui_get_eba_definitions
      RETURN BOOLEAN;

   FUNCTION fnui_check_month_end_limits
      RETURN BOOLEAN;

   FUNCTION fnui_validate_segment_n (segment_no IN NUMBER)
      RETURN BOOLEAN;

   FUNCTION fnui_validate_attribute_n (attribute_no IN NUMBER)
      RETURN BOOLEAN;

   FUNCTION fnui_requires_authorisation
      RETURN BOOLEAN;

   FUNCTION fnui_check_copy_journal
      RETURN BOOLEAN;

   FUNCTION fnui_check_quick_reversal
      RETURN BOOLEAN;

   FUNCTION fnui_check_deletion (journal_id NUMBER)
      RETURN BOOLEAN;

   FUNCTION fnui_check_copy_line (journal_id NUMBER, line_number NUMBER)
      RETURN BOOLEAN;

   FUNCTION fnui_check_delete_line (journal_id NUMBER, line_number NUMBER)
      RETURN BOOLEAN;

   FUNCTION fnui_check_header_definitions
      RETURN BOOLEAN;

   FUNCTION fnui_check_line_definitions
      RETURN BOOLEAN;

   FUNCTION fnui_journal_edit_permission (owner VARCHAR2, editor VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION fnui_does_journal_exist (journal_id NUMBER)
      RETURN BOOLEAN;

   FUNCTION fnui_does_line_exist (journal_id NUMBER, line_no NUMBER)
      RETURN BOOLEAN;

   FUNCTION fnui_merge_header
      RETURN BOOLEAN;

   FUNCTION fnui_merge_lines
      RETURN BOOLEAN;

   FUNCTION fnui_decode_journal_lines
      RETURN BOOLEAN;

   FUNCTION fnui_any_errors (journal_id NUMBER)
      RETURN BOOLEAN;

   FUNCTION fnui_create_copy_journal (original_jrnl_id NUMBER)
      RETURN BOOLEAN;

   FUNCTION fnui_create_reversing_journal (orignal_jrnl_id      NUMBER,
                                           reversing_date       DATE,
                                           entity_proc_group    VARCHAR2,
                                           status               CHAR)
      RETURN BOOLEAN;

   FUNCTION fnui_check_calendar
      RETURN BOOLEAN;

   FUNCTION fnui_get_reversing_journal (journal_id IN NUMBER)
      RETURN NUMBER;

   FUNCTION fnui_get_adjustment_journal (journal_id IN NUMBER)
      RETURN NUMBER;

   FUNCTION fnui_check_ent_proc_group_conf
      RETURN BOOLEAN;


   PROCEDURE prui_process_param_list (list_string    IN     VARCHAR2,
                                      return_array      OUT array_list,
                                      array_count       OUT NUMBER);

   PROCEDURE prui_set_status (journal_id NUMBER, status CHAR);

   /*PROCEDURE prui_post_to_sub_ledger
   (
       ent_proc_group VARCHAR2,
       journal_id NUMBER,
       pProcessId NUMBER,
       status VARCHAR2,
       pUpdatedBy in SLR_JRNL_HEADERS.JH_AMENDED_BY%TYPE := USER
   );*/
   PROCEDURE prui_write_errors_to_database (journal_id NUMBER DEFAULT NULL);

   PROCEDURE prui_update_header_stats (journal_id IN NUMBER);

   PROCEDURE prui_reorder_journal_lines (journal_id NUMBER);

   PROCEDURE prui_populate_header (
      session_id          IN VARCHAR2,
      journal_id          IN SLR_JRNL_HEADERS.JH_JRNL_ID%TYPE,
      journal_type        IN SLR_JRNL_HEADERS.JH_JRNL_TYPE%TYPE DEFAULT NULL,
      entity              IN SLR_JRNL_HEADERS.JH_JRNL_ENTITY%TYPE DEFAULT NULL,
      source_system       IN SLR_JRNL_HEADERS.JH_JRNL_SOURCE%TYPE DEFAULT NULL,
      effective_date      IN SLR_JRNL_HEADERS.JH_JRNL_DATE%TYPE DEFAULT NULL,
      reversing_date      IN DATE DEFAULT NULL, --SLR_JRNL_HEADERS.JH_JRNL_REV_DATE%TYPE       DEFAULT NULL,
      description         IN VARCHAR2 DEFAULT NULL,
      coding_convention   IN SLR_JRNL_HEADERS_UNPOSTED.JHU_JRNL_PREF_STATIC_SRC%TYPE DEFAULT NULL,
      updated_by          IN SLR_JRNL_HEADERS.JH_CREATED_BY%TYPE DEFAULT 'SYSTEM',
      overwrite_details   IN CHAR DEFAULT 'Y');

   PROCEDURE prui_populate_line (
      session_id          IN VARCHAR2,
      journal_id          IN SLR_JRNL_LINES.JL_JRNL_HDR_ID%TYPE,
      line_number         IN SLR_JRNL_LINES.JL_JRNL_LINE_NUMBER%TYPE,
      account             IN SLR_JRNL_LINES.JL_ACCOUNT%TYPE DEFAULT NULL,
      entity              IN SLR_JRNL_LINES.JL_ENTITY%TYPE DEFAULT NULL,
      effective_date      IN SLR_JRNL_LINES.JL_EFFECTIVE_DATE%TYPE DEFAULT NULL,
      value_date          IN SLR_JRNL_LINES.JL_VALUE_DATE%TYPE DEFAULT NULL,
      segment_1           IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_1%TYPE DEFAULT NULL,
      segment_2           IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_2%TYPE DEFAULT NULL,
      segment_3           IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_3%TYPE DEFAULT NULL,
      segment_4           IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_4%TYPE DEFAULT NULL,
      segment_5           IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_5%TYPE DEFAULT NULL,
      segment_6           IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_6%TYPE DEFAULT NULL,
      segment_7           IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_7%TYPE DEFAULT NULL,
      segment_8           IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_8%TYPE DEFAULT NULL,
      segment_9           IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_9%TYPE DEFAULT NULL,
      segment_10          IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_10%TYPE DEFAULT NULL,
      attribute_1         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_ATTRIBUTE_1%TYPE DEFAULT NULL,
      attribute_2         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_ATTRIBUTE_2%TYPE DEFAULT NULL,
      attribute_3         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_ATTRIBUTE_3%TYPE DEFAULT NULL,
      attribute_4         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_ATTRIBUTE_4%TYPE DEFAULT 'MANUAL_ADJ',
      attribute_5         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_ATTRIBUTE_5%TYPE DEFAULT NULL,
      reference_1         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_1%TYPE DEFAULT NULL,
      reference_2         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_2%TYPE DEFAULT NULL,
      reference_3         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_3%TYPE DEFAULT NULL,
      reference_4         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_4%TYPE DEFAULT NULL,
      reference_5         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_5%TYPE DEFAULT NULL,
      reference_6         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_6%TYPE DEFAULT NULL,
      reference_7         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_7%TYPE DEFAULT NULL,
      reference_8         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_8%TYPE DEFAULT NULL,
      reference_9         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_9%TYPE DEFAULT NULL,
      reference_10        IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_10%TYPE DEFAULT NULL,
      description         IN VARCHAR2 DEFAULT NULL,
      tran_currency       IN SLR_JRNL_LINES.JL_TRAN_CCY%TYPE DEFAULT NULL,
      tran_amount         IN SLR_JRNL_LINES.JL_TRAN_AMOUNT%TYPE DEFAULT NULL,
      base_currency       IN SLR_JRNL_LINES.JL_BASE_CCY%TYPE DEFAULT NULL,
      base_rate           IN SLR_JRNL_LINES.JL_BASE_RATE%TYPE DEFAULT NULL,
      base_amount         IN SLR_JRNL_LINES.JL_BASE_AMOUNT%TYPE DEFAULT NULL,
      local_currency      IN SLR_JRNL_LINES.JL_LOCAL_CCY%TYPE DEFAULT NULL,
      local_rate          IN SLR_JRNL_LINES.JL_LOCAL_RATE%TYPE DEFAULT NULL,
      local_amount        IN SLR_JRNL_LINES.JL_LOCAL_AMOUNT%TYPE DEFAULT NULL,
      -- entity_proc_group IN SLR_JRNL_LINES.JL_EPG_ID%TYPE    DEFAULT NULL,
      updated_by          IN SLR_JRNL_LINES.JL_CREATED_BY%TYPE DEFAULT 'SYSTEM',
      overwrite_details   IN CHAR DEFAULT 'Y');

   PROCEDURE prui_clear_errors (
      journal_id    IN SLR_JRNL_LINES.JL_JRNL_HDR_ID%TYPE,
      line_number   IN SLR_JRNL_LINES.JL_JRNL_LINE_NUMBER%TYPE DEFAULT 0);

   FUNCTION fGetEntityProcGroup (
      pJrnlHdrID   IN SLR_JRNL_HEADERS_UNPOSTED.JHU_JRNL_ID%TYPE,
      session_id   IN VARCHAR2)
      RETURN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE;

   FUNCTION fnui_validate_jrnl_type
      RETURN BOOLEAN;

   PROCEDURE prui_increment_journal_version (
      journal_id   IN NUMBER,
      updated_by   IN SLR_JRNL_HEADERS.JH_CREATED_BY%TYPE);

   PROCEDURE prui_calculate_journal_rates (journal_id IN NUMBER);

   PROCEDURE prui_add_jrnl_to_posting_queue (journal_id          IN NUMBER,
                                             epg_id              IN VARCHAR2,
                                             jrnl_num_of_lines   IN NUMBER);

   PROCEDURE prui_create_reversing_journal (epg_id            IN VARCHAR2,
                                            journal_id_list   IN VARCHAR2,
                                            process_id           NUMBER,
                                            status            IN CHAR);

   PROCEDURE prui_set_gui_jrnls_status (journal_id_list   IN VARCHAR2,
                                        status            IN CHAR);

   FUNCTION fnui_anything_to_post (journal_id_list VARCHAR2, status CHAR)
      RETURN BOOLEAN;

   PROCEDURE prui_mark_future_dated_jrnls (epg_id            IN VARCHAR2,
                                           journal_id_list   IN VARCHAR2,
                                           status               CHAR);

   PROCEDURE prui_lock_journal (journal_id IN NUMBER, locked_by IN VARCHAR2);

   PROCEDURE prui_unlock_journal (journal_id   IN NUMBER,
                                  locked_by    IN VARCHAR2);

   PROCEDURE prui_check_journal_version (journal_id        IN NUMBER,
                                         journal_version   IN NUMBER);

   PROCEDURE prui_log_posting_error (epg_id            IN VARCHAR2,
                                     journal_id_list   IN VARCHAR2,
                                     error_message     IN VARCHAR2);



   /******************************************************************************************
   Declare private global variables
   ******************************************************************************************/

   gJournalHeader               SLR_JRNL_HEADERS_UNPOSTED%ROWTYPE;
   gSessionId                   VARCHAR2 (50) := NULL;
   gJournalLineNumber           NUMBER (12) := -1;

   gBulkSubmission              BOOLEAN := FALSE;

   gFAKDefinitions              SLR_FAK_DEFINITIONS%ROWTYPE;
   gEBADefinitions              SLR_EBA_DEFINITIONS%ROWTYPE;
   gEntityConfiguration         SLR_ENTITIES%ROWTYPE;
   gJournalType                 UIV_JOURNAL_TYPES%ROWTYPE;

   -- Sub Ledger setting
   gvSubLedgerGenLastBalForBD   BOOLEAN := FALSE;

   -- Journal Status Constants
   gSTATUS_MANUAL               CHAR (1) := 'M';
   gSTATUS_ERROR                CHAR (1) := 'I';
   gSTATUS_AUTHORISE            CHAR (1) := 'R';
   gSTATUS_REJECT               CHAR (1) := 'F';
   gSTATUS_POSTED               CHAR (1) := 'P';
   gSTATUS_UNPOSTED             CHAR (1) := 'U';
   gSTATUS_WAITING              CHAR (1) := 'W'; -- waiting status mark MADJ journals which are unposted and are waiting for the date when should be posted in batch
   gSTATUS_VALIDATED            CHAR (1) := 'V'; -- Validated in the new Sub Leder version means journals from MADJ to be posted from GUI
   gSTATUS_VALIDATING           CHAR (1) := 'v';
   gSTATUS_CRITICAL             CHAR (1) := 'X';
   gSTATUS_QUEUED_FOR_POSTING   CHAR (1) := 'Q';

   gSTATE_CRITICAL              CHAR (1) := 'C';
   gSTATE_ERRORED               CHAR (1) := 'I';
   gSTATE_OK                    CHAR (1) := 'P';

   gCLIENT_STATIC               VARCHAR2 (20) := 'CLIENT STATIC';

   -- Journal Type Constants
   gJOURNAL_TYPE_PERC           VARCHAR2 (10) := 'PERC';             --'PERC';
   gJOURNAL_TYPE_PERB           VARCHAR2 (10) := 'PERB';             --'PERB';
   gJOURNAL_TYPE_PERF           VARCHAR2 (10) := 'PERM';             --'PERF';
   gJOURNAL_TYPE_DREV           VARCHAR2 (10) := 'DREV';             --'DREV';
   gJOURNAL_TYPE_MPERC          VARCHAR2 (10) := 'MADJPERC';        --'MPREC';
   gJOURNAL_TYPE_MPERB          VARCHAR2 (10) := 'MADJPERB';        --'MPERB';
   gJOURNAL_TYPE_MPERF          VARCHAR2 (10) := 'MADJPERM';        --'MPERF';
   gJOURNAL_TYPE_MPERL          VARCHAR2 (10) := 'MADJPERL';        --'MPERL';
   gJOURNAL_TYPE_MDREV          VARCHAR2 (10) := 'MADJDREV';        --'MDREV';
   gJOURNAL_TYPE_MMREV          VARCHAR2 (10) := 'MADJMREV';        --'MMREV';
   gJOURNAL_TYPE_MDAYR          VARCHAR2 (10) := 'MADJDAYR';        --'MDAYR';
   gJOURNAL_TYPE_BDAT           VARCHAR2 (10) := 'MADJBDAT';
   gJOURNAL_TYPE_BDME           VARCHAR2 (10) := 'MADJBDME'; -- Perm Back Dated Prev Month End
   gJOURNAL_TYPE_BDPD           VARCHAR2 (10) := 'MADJBDPD'; -- Perm Back Dated Prev Day
   gJOURNAL_TYPE_BREV           VARCHAR2 (10) := 'MADJBREV'; -- Reversing Back Dated Prev Day

   -- TTP 775
   gJOURNAL_TYPE_BDBD           VARCHAR2 (10) := 'MADJBDBD'; -- Perm Back Dated prior to (SLR) next business day (by Effective date)
   gJOURNAL_TYPE_BDBR           VARCHAR2 (10) := 'MADJBDBR'; -- Reversing Back Dated prior to (SLR) next business day (by Effective date)
   gJOURNAL_TYPE_MDRV           VARCHAR2 (10) := 'MADJMDRV'; -- Reversing Daily Reversing (by Effective date)

   gPackageName                 VARCHAR2 (32) := 'pgui_manual_journal';

   gJrnlEntityProcGroup         VARCHAR2 (60) := NULL;
   gJournalVersion              NUMBER (5, 0) := NULL;

   journal_locked_exeption      EXCEPTION;
   stale_journal_exception      EXCEPTION;



   /******************************************************************************************
   Processing
   ******************************************************************************************/

   -- For use with R2 code base
   PROCEDURE prui_search_headers (
      journal_id       IN     SLR_JRNL_HEADERS.JH_JRNL_ID%TYPE,
      journal_type     IN     SLR_JRNL_HEADERS.JH_JRNL_TYPE%TYPE,
      entity           IN     SLR_JRNL_HEADERS.JH_JRNL_ENTITY%TYPE,
      source_system    IN     SLR_JRNL_HEADERS.JH_JRNL_SOURCE%TYPE,
      effective_date   IN     VARCHAR2,
      reversing_date   IN     VARCHAR2,
      description      IN     SLR_JRNL_HEADERS.JH_JRNL_DESCRIPTION%TYPE,
      created_by       IN     SLR_JRNL_HEADERS.JH_CREATED_BY%TYPE,
      created_on       IN     VARCHAR2,
      updated_by       IN     SLR_JRNL_HEADERS.JH_AMENDED_BY%TYPE,
      updated_on       IN     VARCHAR2,
      posted_by        IN     SLR_JRNL_HEADERS.JH_JRNL_POSTED_BY%TYPE,
      posted_on        IN     VARCHAR2,
      authorised_by    IN     SLR_JRNL_HEADERS.JH_JRNL_AUTHORISED_BY%TYPE,
      authorised_on    IN     VARCHAR2,
      entity_list      IN     VARCHAR2,
      user_id          IN     VARCHAR2,
      resultset           OUT global_ref_cursor)
   IS
      lv_sql_statement   VARCHAR2 (32000);
      lv_head_prefix     VARCHAR2 (10);
      lv_line_prefix     VARCHAR2 (10);
      lv_max_no_rows     NUMBER;
   BEGIN
      -- Get max number of rows
      lv_max_no_rows := 2000;

      -- Determine whether to read from
      -- slr_jrnl_headers_unposted/slr_jrnl_lines_unposted
      -- or slr_jrnl_headers/slr_jrnl_lines
      IF journal_type != gSTATUS_POSTED
      THEN
         lv_head_prefix := 'sjhu.jhu';
         lv_line_prefix := 'sjlu.jlu';
      ELSE
         lv_head_prefix := 'sjhu.jh';
         lv_line_prefix := 'sjlu.jl';
      END IF;

      -- start statement
      lv_sql_statement :=
            'SELECT '
         || lv_head_prefix
         || '_jrnl_id,'
         || lv_head_prefix
         || '_jrnl_entity,'
         || lv_head_prefix
         || '_jrnl_type,'
         || lv_head_prefix
         || '_jrnl_source,'
         || lv_head_prefix
         || '_jrnl_date,'
         || lv_head_prefix
         || '_jrnl_rev_date, '
         || lv_head_prefix
         || '_created_by,'
         || lv_head_prefix
         || '_created_on,'
         || lv_head_prefix
         || '_amended_by,'
         || lv_head_prefix
         || '_amended_on,'
         || lv_head_prefix
         || '_jrnl_authorised_by,'
         || lv_head_prefix
         || '_jrnl_authorised_on,'
         || lv_head_prefix
         || '_jrnl_total_lines,'
         || lv_head_prefix
         || '_jrnl_status, '
         || lv_head_prefix
         || '_jrnl_status_text, '
         || lv_head_prefix
         || '_jrnl_validated_by, '
         || lv_head_prefix
         || '_jrnl_validated_on, '
         || lv_head_prefix
         || '_jrnl_posted_by, '
         || lv_head_prefix
         || '_jrnl_posted_on, '
         || 'SUM(SIGN('
         || lv_line_prefix
         || '_base_amount),-1,'
         || lv_line_prefix
         || '_base_amount,0)) as base_credits,'
         || 'SUM(SIGN('
         || lv_line_prefix
         || '_base_amount),1,'
         || lv_line_prefix
         || '_base_amount,0)) as base_debits,'
         || 'SUM(SIGN('
         || lv_line_prefix
         || '_local_amount),-1,'
         || lv_line_prefix
         || '_local_amount,0)) as local_credits,'
         || 'SUM(SIGN('
         || lv_line_prefix
         || '_amount),1,'
         || lv_line_prefix
         || '_local_amount,0)) as local_debits,'
         || 'SUM(SIGN('
         || lv_line_prefix
         || '_tran_amount),-1,'
         || lv_line_prefix
         || '_tran_amount,0)) as tran_credits,'
         || 'SUM(SIGN('
         || lv_line_prefix
         || '_tran_amount),1,'
         || lv_line_prefix
         || '_tran_amount,0)) as tran_debits,'
         || 'SUM('
         || lv_line_prefix
         || '_base_amount) as total_base,'
         || 'SUM('
         || lv_line_prefix
         || '_local_amount) as total_local, '
         || 'SUM('
         || lv_line_prefix
         || '_tran_amount) as total_tran, '
         || 'MAX('
         || lv_line_prefix
         || '_base_currency) as base_currency, '
         || 'MAX('
         || lv_line_prefix
         || '_local_currency) as local_currency, '
         || 'DECODE('''
         || UPPER (user_id)
         || ''',UPPER(amended_by), 1, '
         || 'UPPER(created_by), 1, UPPER(validated_by), 1, UPPER(posted_by), 1,0) as authorisable'
         || 'FROM ';

      IF journal_type != gSTATUS_POSTED
      THEN
         lv_sql_statement :=
               lv_sql_statement
            || 'slr_jrnl_headers_unposted sjhu, '
            || 'slr_jrnl_lines_unposted sjlu ';
      ELSE
         lv_sql_statement :=
               lv_sql_statement
            || 'slr_jrnl_headers sjhu, '
            || 'slr_jrnl_lines sjlu ';
      END IF;

      lv_sql_statement :=
            lv_sql_statement
         || 'WHERE '
         || lv_head_prefix
         || '_jrnl_id = '
         || lv_line_prefix
         || '_jrnl_hdr_id(+) '
         || 'AND '
         || lv_head_prefix
         || '_jrnl_entity IN ('''
         || REPLACE (entity_list, ',', ''',''')
         || ''') '
         || 'AND '
         || lv_head_prefix
         || '_created_by IN ' -- Restrict user to view journals in their groups or sub-groups
         || '(	SELECT child.mmg_user_id '
         || '		FROM   ui_meta_user_groups child '
         || '			   		INNER JOIN ui_meta_user_groups parent '
         || '						  ON child.mmg_group_id = parent.mmg_group_id '
         || '		WHERE  child.mmg_user_id = sjhu.jhu_created_by '
         || '		AND	   parent.mmg_user_id = '''
         || user_id
         || ''' '
         || '		UNION '
         || '		SELECT child.mmg_user_id '
         || '		FROM   ui_meta_group_hierarchy '
         || '					INNER JOIN ui_meta_user_groups parent '
         || '						  ON mgh_parent_id = parent.mmg_group_id '
         || '					INNER JOIN ui_meta_user_groups child '
         || '						  ON mgh_child_id = child.mmg_group_id '
         || '		WHERE  child.mmg_user_id = sjhu.jhu_created_by '
         || '		AND	   parent.mmg_user_id = '''
         || user_id
         || ''' ) ';

      -- build dynamic list
      IF journal_id IS NOT NULL
      THEN
         lv_sql_statement :=
               lv_sql_statement
            || ' AND '
            || lv_head_prefix
            || '_jrnl_id = '
            || TO_CHAR (journal_id);
      END IF;

      IF journal_type IS NOT NULL AND journal_type != gSTATUS_POSTED
      THEN
         lv_sql_statement :=
               lv_sql_statement
            || ' AND '
            || lv_head_prefix
            || '_jrnl_type = '''
            || journal_type
            || ''' ';
      END IF;

      IF entity IS NOT NULL
      THEN
         lv_sql_statement :=
               lv_sql_statement
            || ' AND '
            || lv_head_prefix
            || '_jrnl_entity = '''
            || entity
            || ''' ';
      END IF;

      IF source_system IS NOT NULL
      THEN
         lv_sql_statement :=
               lv_sql_statement
            || ' AND '
            || lv_head_prefix
            || '_jrnl_source = '''
            || source_system
            || ''' ';
      END IF;

      IF effective_date IS NOT NULL
      THEN
         lv_sql_statement :=
               lv_sql_statement
            || ' AND '
            || lv_head_prefix
            || '_jrnl_date = TO_DATE('''
            || effective_date
            || ''', ''dd-mm-yyyy hh24:mi:ss'') ';
      END IF;

      IF reversing_date IS NOT NULL
      THEN
         lv_sql_statement :=
               lv_sql_statement
            || ' AND '
            || lv_head_prefix
            || '_jrnl_rev_date = TO_DATE('''
            || reversing_date
            || ''', ''DD-MM-YYYY'') ';
      END IF;

      IF description IS NOT NULL
      THEN
         lv_sql_statement :=
               lv_sql_statement
            || ' AND '
            || lv_head_prefix
            || '_jrnl_description LIKE ''%'
            || description
            || '%'' ';
      END IF;

      IF created_by IS NOT NULL
      THEN
         lv_sql_statement :=
               lv_sql_statement
            || ' AND '
            || lv_head_prefix
            || '_created_by LIKE ''%'
            || created_by
            || '%'' ';
      END IF;

      IF created_on IS NOT NULL
      THEN
         lv_sql_statement :=
               lv_sql_statement
            || ' AND '
            || lv_head_prefix
            || '_created_on = TO_DATE('''
            || created_on
            || ''', ''dd-mm-yyyy hh24:mi:ss'') ';
      END IF;

      IF updated_by IS NOT NULL
      THEN
         lv_sql_statement :=
               lv_sql_statement
            || ' AND '
            || lv_head_prefix
            || '_updated_by LIKE ''%'
            || updated_by
            || '%'' ';
      END IF;

      IF updated_on IS NOT NULL
      THEN
         lv_sql_statement :=
               lv_sql_statement
            || ' AND '
            || lv_head_prefix
            || '_updated_on = TO_DATE('''
            || updated_on
            || ''', ''dd-mm-yyyy hh24:mi:ss'') ';
      END IF;

      IF posted_by IS NOT NULL
      THEN
         lv_sql_statement :=
               lv_sql_statement
            || ' AND '
            || lv_head_prefix
            || '_posted_by LIKE ''%'
            || posted_by
            || '%'' ';
      END IF;

      IF posted_on IS NOT NULL
      THEN
         lv_sql_statement :=
               lv_sql_statement
            || ' AND '
            || lv_head_prefix
            || '_jrnl_posted_on = TO_DATE('''
            || posted_on
            || ''', ''dd-mm-yyyy hh24:mi:ss'') ';
      END IF;

      IF authorised_by IS NOT NULL
      THEN
         lv_sql_statement :=
               lv_sql_statement
            || ' AND '
            || lv_head_prefix
            || '_authorised_by LIKE ''%'
            || authorised_by
            || '%'' ';
      END IF;

      IF authorised_on IS NOT NULL
      THEN
         lv_sql_statement :=
               lv_sql_statement
            || ' AND '
            || lv_head_prefix
            || '_jrnl_authorised_on = TO_DATE('''
            || authorised_on
            || ''', ''dd-mm-yyyy hh24:mi:ss'') ';
      END IF;

      -- Limit the max number of row to return
      lv_sql_statement :=
         lv_sql_statement || ' AND rownum < ' || TO_CHAR (lv_max_no_rows);

      -- complete statement
      lv_sql_statement :=
            lv_sql_statement
         || 'GROUP BY '
         || lv_head_prefix
         || '_jrnl_id,'
         || lv_head_prefix
         || '_jrnl_entity,'
         || lv_head_prefix
         || '_jrnl_type,'
         || lv_head_prefix
         || '_jrnl_source,'
         || lv_head_prefix
         || '_jrnl_date,'
         || lv_head_prefix
         || '_jrnl_rev_date, '
         || lv_head_prefix
         || '_created_by,'
         || lv_head_prefix
         || '_created_on,'
         || lv_head_prefix
         || '_amended_by,'
         || lv_head_prefix
         || '_amended_on,'
         || lv_head_prefix
         || '_jrnl_authorised_by,'
         || lv_head_prefix
         || '_jrnl_authorised_on,'
         || lv_head_prefix
         || '_jrnl_total_lines,'
         || lv_head_prefix
         || '_jrnl_status, '
         || lv_head_prefix
         || '_jrnl_status_text, '
         || lv_head_prefix
         || '_jrnl_validated_by, '
         || lv_head_prefix
         || '_jrnl_validated_on, '
         || lv_head_prefix
         || '_jrnl_posted_by, '
         || lv_head_prefix
         || '_jrnl_posted_on '
         || 'ORDER BY '
         || lv_head_prefix
         || '_amended_on desc';

      EXECUTE IMMEDIATE lv_sql_statement INTO resultset;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_search_headers',
                   'slr_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
   END;

   --********************************************************************************

   -- For use with R2 code base
   PROCEDURE prui_get_header (
      journal_id   IN OUT SLR_JRNL_HEADERS.JH_JRNL_ID%TYPE,
      resultset       OUT global_ref_cursor)
   IS
      jrnl_id   NUMBER;
   BEGIN
      -- Get journal header details
      BEGIN
         SELECT *
           INTO gJournalHeader
           FROM slr_jrnl_headers_unposted
          WHERE jhu_jrnl_id = journal_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'prui_get_header',
                      'slr_jrnl_headers_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            RAISE;
      END;

      -- If Reversing journal type and JH_JRNL_REF_ID is not null
      --IF gJournalHeader.jhu_jrnl_ref_id IS NOT NULL AND
      --gJournalHeader.jhu_jrnl_type IN (gJOURNAL_TYPE_DREV,gJOURNAL_TYPE_MMREV, gJOURNAL_TYPE_MDAYR, gJOURNAL_TYPE_MDREV)
      --THEN

      -- This is reversing journal, get the "parent" original journal
      --jrnl_id := fnui_get_reversing_journal(journal_id);

      --ELSE

      -- This is not a reversing journal type or is the "parent" original journal
      jrnl_id := journal_id;

      --END IF;

      -- Open cursor
      OPEN resultset FOR
           SELECT sjhu.jhu_jrnl_id,
                  sjhu.jhu_jrnl_type,
                  sjhu.jhu_jrnl_date,
                  --sjhu.jhu_jrnl_rev_date,
                  sjhu.jhu_jrnl_entity,
                  sjhu.jhu_jrnl_status,
                  sjhu.jhu_jrnl_status_text,
                  sjhu.jhu_jrnl_process_id,
                  sjhu.jhu_jrnl_description,
                  sjhu.jhu_jrnl_source,
                  sjhu.jhu_jrnl_source_jrnl_id,
                  --sjhu.jhu_jrnl_ref_id,
                  sjhu.jhu_jrnl_authorised_by,
                  sjhu.jhu_jrnl_authorised_on,
                  sjhu.jhu_jrnl_validated_by,
                  sjhu.jhu_jrnl_validated_on,
                  sjhu.jhu_jrnl_posted_by,
                  sjhu.jhu_jrnl_posted_on,
                  sjhu.jhu_jrnl_total_lines,
                  sjhu.jhu_created_by,
                  sjhu.jhu_created_on,
                  sjhu.jhu_amended_by,
                  sjhu.jhu_amended_on,
                  sjhu.jhu_jrnl_pref_static_src,
                  SUM (
                     DECODE (SIGN (sjlu.jlu_base_amount),
                             -1, sjlu.jlu_base_amount,
                             0))
                     AS base_credits,
                  SUM (
                     DECODE (SIGN (sjlu.jlu_base_amount),
                             1, sjlu.jlu_base_amount,
                             0))
                     AS base_debits,
                  SUM (
                     DECODE (SIGN (sjlu.jlu_local_amount),
                             -1, sjlu.jlu_local_amount,
                             0))
                     AS local_credits,
                  SUM (
                     DECODE (SIGN (sjlu.jlu_local_amount),
                             1, sjlu.jlu_local_amount,
                             0))
                     AS local_debits,
                  SUM (
                     DECODE (SIGN (sjlu.jlu_tran_amount),
                             -1, sjlu.jlu_tran_amount,
                             0))
                     AS tran_credits,
                  SUM (
                     DECODE (SIGN (sjlu.jlu_tran_amount),
                             1, sjlu.jlu_tran_amount,
                             0))
                     AS tran_debits,
                  SUM (sjlu.jlu_base_amount) AS total_base,
                  SUM (sjlu.jlu_local_amount) AS total_local,
                  SUM (sjlu.jlu_tran_amount) AS total_tran,
                  MAX (sjlu.jlu_base_ccy) AS base_currency,
                  MAX (sjlu.jlu_local_ccy) AS local_currency
             FROM slr_jrnl_headers_unposted sjhu, slr_jrnl_lines_unposted sjlu
            WHERE     sjhu.jhu_jrnl_id = sjlu.jlu_jrnl_hdr_id(+)
                  AND sjhu.jhu_jrnl_id = jrnl_id
         GROUP BY sjhu.jhu_jrnl_id,
                  sjhu.jhu_jrnl_type,
                  sjhu.jhu_jrnl_date,
                  sjhu.jhu_jrnl_entity,
                  sjhu.jhu_jrnl_status,
                  sjhu.jhu_jrnl_status_text,
                  sjhu.jhu_jrnl_process_id,
                  sjhu.jhu_jrnl_description,
                  sjhu.jhu_jrnl_source,
                  sjhu.jhu_jrnl_source_jrnl_id,
                  sjhu.jhu_jrnl_authorised_by,
                  sjhu.jhu_jrnl_authorised_on,
                  sjhu.jhu_jrnl_validated_by,
                  sjhu.jhu_jrnl_validated_on,
                  sjhu.jhu_jrnl_posted_by,
                  sjhu.jhu_jrnl_posted_on,
                  sjhu.jhu_jrnl_total_lines,
                  sjhu.jhu_created_by,
                  sjhu.jhu_created_on,
                  sjhu.jhu_amended_by,
                  sjhu.jhu_amended_on,
                  sjhu.jhu_jrnl_pref_static_src;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_get_header',
                   'slr_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
   END prui_get_header;

   --********************************************************************************

   -- For use with R2 code base
   PROCEDURE prui_get_lines (
      journal_id          IN OUT SLR_JRNL_HEADERS.JH_JRNL_ID%TYPE,
      coding_convention   IN     SLR_JRNL_HEADERS_UNPOSTED.JHU_JRNL_PREF_STATIC_SRC%TYPE,
      resultset              OUT global_ref_cursor)
   IS
   BEGIN
      OPEN resultset FOR
         SELECT sjlu.jlu_local_ccy,
                NVL (sjlu.jlu_local_amount, 0),
                sjlu.jlu_created_by,
                sjlu.jlu_created_on,
                sjlu.jlu_amended_by,
                sjlu.jlu_amended_on,
                sjlu.jlu_jrnl_hdr_id,
                sjlu.jlu_jrnl_line_number,
                sjlu.jlu_fak_id,
                sjlu.jlu_jrnl_status,
                sjlu.jlu_jrnl_status_text,
                sjlu.jlu_jrnl_process_id,
                sjlu.jlu_description,
                sjlu.jlu_source_jrnl_id,
                sjlu.jlu_effective_date,
                sjlu.jlu_value_date,
                sjlu.jlu_entity,
                NVL (sjlu.jlu_account, 0),
                fnui_fdr_to_source ('segment_1',
                                    coding_convention,
                                    sjlu.jlu_segment_1)
                   AS jlu_segment_1,
                fnui_fdr_to_source ('segment_2',
                                    coding_convention,
                                    sjlu.jlu_segment_2)
                   AS jlu_segment_2,
                fnui_fdr_to_source ('segment_3',
                                    coding_convention,
                                    sjlu.jlu_segment_3)
                   AS jlu_segment_3,
                fnui_fdr_to_source ('segment_4',
                                    coding_convention,
                                    sjlu.jlu_segment_4)
                   AS jlu_segment_4,
                fnui_fdr_to_source ('segment_5',
                                    coding_convention,
                                    sjlu.jlu_segment_5)
                   AS jlu_segment_5,
                fnui_fdr_to_source ('segment_6',
                                    coding_convention,
                                    sjlu.jlu_segment_6)
                   AS jlu_segment_6,
                fnui_fdr_to_source ('segment_7',
                                    coding_convention,
                                    sjlu.jlu_segment_7)
                   AS jlu_segment_7,
                fnui_fdr_to_source ('segment_8',
                                    coding_convention,
                                    sjlu.jlu_segment_8)
                   AS jlu_segment_8,
                fnui_fdr_to_source ('segment_9',
                                    coding_convention,
                                    sjlu.jlu_segment_9)
                   AS jlu_segment_9,
                fnui_fdr_to_source ('segment_10',
                                    coding_convention,
                                    sjlu.jlu_segment_10)
                   AS jlu_segment_10,
                fnui_fdr_to_source ('attribute_1',
                                    coding_convention,
                                    sjlu.jlu_attribute_1)
                   AS jlu_attribute_1,
                fnui_fdr_to_source ('attribute_2',
                                    coding_convention,
                                    sjlu.jlu_attribute_2)
                   AS jlu_attribute_2,
                fnui_fdr_to_source ('attribute_3',
                                    coding_convention,
                                    sjlu.jlu_attribute_3)
                   AS jlu_attribute_3,
                fnui_fdr_to_source ('attribute_4',
                                    coding_convention,
                                    sjlu.jlu_attribute_4)
                   AS jlu_attribute_4,
                fnui_fdr_to_source ('attribute_5',
                                    coding_convention,
                                    sjlu.jlu_attribute_5)
                   AS jlu_attribute_5,
                sjlu.jlu_reference_1 AS jlu_reference_1,
                sjlu.jlu_reference_2 AS jlu_reference_2,
                sjlu.jlu_reference_3 AS jlu_reference_3,
                sjlu.jlu_reference_4 AS jlu_reference_4,
                sjlu.jlu_reference_5 AS jlu_reference_5,
                sjlu.jlu_reference_6 AS jlu_reference_6,
                sjlu.jlu_reference_7 AS jlu_reference_7,
                sjlu.jlu_reference_8 AS jlu_reference_8,
                sjlu.jlu_reference_9 AS jlu_reference_9,
                sjlu.jlu_reference_10 AS jlu_reference_10,
                sjlu.jlu_tran_ccy,
                NVL (syuc.cu_digits_after_point, 2),
                NVL (sjlu.jlu_tran_amount, 0),
                NVL (sjlu.jlu_base_rate, 0),
                sjlu.jlu_base_ccy,
                NVL (sjlu.jlu_base_amount, 0),
                CASE WHEN sjlu.jlu_tran_amount < 0 THEN 'D' ELSE 'C' END
                   AS lineType,
                NVL (sjlu.jlu_local_rate, 0),
                sjhu.jhu_jrnl_pref_static_src,
                sjhu.jhu_jrnl_type
           FROM slr_jrnl_lines_unposted sjlu,
                slr_jrnl_headers_unposted sjhu,
                fr_currency syuc
          WHERE     sjlu.jlu_jrnl_hdr_id = sjhu.jhu_jrnl_id
                AND sjlu.jlu_tran_ccy = syuc.cu_currency_id(+)
                AND sjlu.jlu_jrnl_hdr_id = journal_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_get_lines',
                   'slr_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
   END prui_get_lines;

   --********************************************************************************

   -- For use with R2 code base
   PROCEDURE prui_get_line (
      journal_id          IN OUT SLR_JRNL_LINES.JL_JRNL_HDR_ID%TYPE,
      line_no             IN OUT SLR_JRNL_LINES.JL_JRNL_LINE_NUMBER%TYPE,
      coding_convention   IN     SLR_JRNL_HEADERS_UNPOSTED.JHU_JRNL_PREF_STATIC_SRC%TYPE,
      resultset              OUT global_ref_cursor)
   IS
   BEGIN
      OPEN resultset FOR
         SELECT sjlu.jlu_local_ccy,
                NVL (sjlu.jlu_local_amount, 0),
                sjlu.jlu_created_by,
                sjlu.jlu_created_on,
                sjlu.jlu_amended_by,
                sjlu.jlu_amended_on,
                sjlu.jlu_jrnl_hdr_id,
                sjlu.jlu_jrnl_line_number,
                sjlu.jlu_fak_id,
                sjlu.jlu_jrnl_status,
                sjlu.jlu_jrnl_status_text,
                sjlu.jlu_jrnl_process_id,
                sjlu.jlu_description,
                sjlu.jlu_source_jrnl_id,
                sjlu.jlu_effective_date,
                sjlu.jlu_value_date,
                sjlu.jlu_entity,
                NVL (sjlu.jlu_account, 0),
                fnui_fdr_to_source ('segment_1',
                                    coding_convention,
                                    sjlu.jlu_segment_1)
                   AS jlu_segment_1,
                fnui_fdr_to_source ('segment_2',
                                    coding_convention,
                                    sjlu.jlu_segment_2)
                   AS jlu_segment_2,
                fnui_fdr_to_source ('segment_3',
                                    coding_convention,
                                    sjlu.jlu_segment_3)
                   AS jlu_segment_3,
                fnui_fdr_to_source ('segment_4',
                                    coding_convention,
                                    sjlu.jlu_segment_4)
                   AS jlu_segment_4,
                fnui_fdr_to_source ('segment_5',
                                    coding_convention,
                                    sjlu.jlu_segment_5)
                   AS jlu_segment_5,
                fnui_fdr_to_source ('segment_6',
                                    coding_convention,
                                    sjlu.jlu_segment_6)
                   AS jlu_segment_6,
                fnui_fdr_to_source ('segment_7',
                                    coding_convention,
                                    sjlu.jlu_segment_7)
                   AS jlu_segment_7,
                fnui_fdr_to_source ('segment_8',
                                    coding_convention,
                                    sjlu.jlu_segment_8)
                   AS jlu_segment_8,
                fnui_fdr_to_source ('segment_9',
                                    coding_convention,
                                    sjlu.jlu_segment_9)
                   AS jlu_segment_9,
                fnui_fdr_to_source ('segment_10',
                                    coding_convention,
                                    sjlu.jlu_segment_10)
                   AS jlu_segment_10,
                fnui_fdr_to_source ('attribute_1',
                                    coding_convention,
                                    sjlu.jlu_attribute_1)
                   AS jlu_attribute_1,
                fnui_fdr_to_source ('attribute_2',
                                    coding_convention,
                                    sjlu.jlu_attribute_2)
                   AS jlu_attribute_2,
                fnui_fdr_to_source ('attribute_3',
                                    coding_convention,
                                    sjlu.jlu_attribute_3)
                   AS jlu_attribute_3,
                fnui_fdr_to_source ('attribute_4',
                                    coding_convention,
                                    sjlu.jlu_attribute_4)
                   AS jlu_attribute_4,
                fnui_fdr_to_source ('attribute_5',
                                    coding_convention,
                                    sjlu.jlu_attribute_5)
                   AS jlu_attribute_5,
                sjlu.jlu_reference_1 AS jlu_reference_1,
                sjlu.jlu_reference_2 AS jlu_reference_2,
                sjlu.jlu_reference_3 AS jlu_reference_3,
                sjlu.jlu_reference_4 AS jlu_reference_4,
                sjlu.jlu_reference_5 AS jlu_reference_5,
                sjlu.jlu_reference_6 AS jlu_reference_6,
                sjlu.jlu_reference_7 AS jlu_reference_7,
                sjlu.jlu_reference_8 AS jlu_reference_8,
                sjlu.jlu_reference_9 AS jlu_reference_9,
                sjlu.jlu_reference_10 AS jlu_reference_10,
                fnui_fdr_desc ('segment_1', sjlu.jlu_segment_1),
                fnui_fdr_related_val ('segment_1', sjlu.jlu_segment_1),
                fnui_fdr_desc ('segment_2', sjlu.jlu_segment_2),
                fnui_fdr_related_val ('segment_2', sjlu.jlu_segment_2),
                fnui_fdr_desc ('segment_3', sjlu.jlu_segment_3),
                fnui_fdr_related_val ('segment_3', sjlu.jlu_segment_3),
                fnui_fdr_desc ('segment_4', sjlu.jlu_segment_4),
                fnui_fdr_related_val ('segment_4', sjlu.jlu_segment_4),
                fnui_fdr_desc ('segment_5', sjlu.jlu_segment_5),
                fnui_fdr_related_val ('segment_5', sjlu.jlu_segment_5),
                fnui_fdr_desc ('segment_6', sjlu.jlu_segment_6),
                fnui_fdr_related_val ('segment_6', sjlu.jlu_segment_6),
                fnui_fdr_desc ('segment_7', sjlu.jlu_segment_7),
                fnui_fdr_related_val ('segment_7', sjlu.jlu_segment_7),
                fnui_fdr_desc ('segment_8', sjlu.jlu_segment_8),
                fnui_fdr_related_val ('segment_8', sjlu.jlu_segment_8),
                fnui_fdr_desc ('segment_9', sjlu.jlu_segment_9),
                fnui_fdr_related_val ('segment_9', sjlu.jlu_segment_9),
                fnui_fdr_desc ('segment_10', sjlu.jlu_segment_10),
                fnui_fdr_related_val ('segment_10', sjlu.jlu_segment_10),
                fnui_fdr_desc ('attribute_1', sjlu.jlu_attribute_1),
                fnui_fdr_related_val ('attribute_1', sjlu.jlu_attribute_1),
                fnui_fdr_desc ('attribute_2', sjlu.jlu_attribute_2),
                fnui_fdr_related_val ('attribute_2', sjlu.jlu_attribute_2),
                fnui_fdr_desc ('attribute_3', sjlu.jlu_attribute_3),
                fnui_fdr_related_val ('attribute_3', sjlu.jlu_attribute_3),
                fnui_fdr_desc ('attribute_4', sjlu.jlu_attribute_4),
                fnui_fdr_related_val ('attribute_4', sjlu.jlu_attribute_4),
                fnui_fdr_desc ('attribute_5', sjlu.jlu_attribute_5),
                fnui_fdr_related_val ('attribute_5', sjlu.jlu_attribute_5),
                sjlu.jlu_tran_ccy,
                NVL (syuc.cu_digits_after_point, 2),
                NVL (sjlu.jlu_tran_amount, 0),
                NVL (sjlu.jlu_base_rate, 0),
                sjlu.jlu_base_ccy,
                NVL (sjlu.jlu_base_amount, 0),
                CASE WHEN sjlu.jlu_tran_amount < 0 THEN 'C' ELSE 'D' END
                   AS lineType,
                NVL (sjlu.jlu_local_rate, 0),
                sjhu.jhu_jrnl_pref_static_src,
                sjhu.jhu_jrnl_type
           FROM slr_jrnl_lines_unposted sjlu,
                slr_jrnl_headers_unposted sjhu,
                fr_currency syuc
          WHERE     sjlu.jlu_jrnl_hdr_id = sjhu.jhu_jrnl_id
                AND sjlu.jlu_tran_ccy = syuc.cu_currency_id(+)
                AND sjlu.jlu_jrnl_hdr_id = journal_id
                AND jlu_jrnl_line_number = line_no;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_get_line',
                   'slr_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
   END prui_get_line;

   --********************************************************************************

   PROCEDURE prui_upsert_header (
      session_id            IN     VARCHAR2,
      journal_id            IN     SLR_JRNL_HEADERS.JH_JRNL_ID%TYPE,
      journal_type          IN     SLR_JRNL_HEADERS.JH_JRNL_TYPE%TYPE,
      entity                IN     SLR_JRNL_HEADERS.JH_JRNL_ENTITY%TYPE,
      source_system         IN     SLR_JRNL_HEADERS.JH_JRNL_SOURCE%TYPE,
      effective_date        IN     VARCHAR2,
      reversing_date        IN     VARCHAR2,
      description           IN     VARCHAR2,
      coding_convention     IN     SLR_JRNL_HEADERS_UNPOSTED.JHU_JRNL_PREF_STATIC_SRC%TYPE,
      updated_by            IN     SLR_JRNL_HEADERS.JH_CREATED_BY%TYPE,
      no_validate           IN     CHAR DEFAULT 'N', -- use 'Y' for bulk upload
      status                IN     CHAR DEFAULT NULL,
      journal_version       IN     gui_jrnl_headers_unposted.jhu_version%TYPE,
      journal_id_out           OUT SLR_JRNL_HEADERS.JH_JRNL_ID%TYPE,
      journal_version_out      OUT gui_jrnl_headers_unposted.jhu_version%TYPE,
      success                  OUT CHAR)
   IS
      lvValidateState   CHAR (1);
   BEGIN
      success := 'S';
      journal_id_out := journal_id;

      IF session_id IS NULL
      THEN
         raise_application_error (-20101, 'Missing session id.');
      END IF;

      gSessionId := session_id;
      gJournalVersion := NVL (journal_version, 0);

      IF NVL (journal_id, -1) > 0
      THEN
         BEGIN
            /* lock journal so only one user can edit it. Procedure commits changes, signals journal_locked_exeption if journal already locked */
            prui_lock_journal (journal_id, updated_by);

            /* check journal version in case there were any changes since journal was displayed on the screen. Signals stale_journal_exception if journal version is different*/
            prui_check_journal_version (journal_id, gJournalVersion);
         EXCEPTION
            WHEN journal_locked_exeption
            THEN
               prui_log_error (
                  journal_id,
                  0,
                  6699,
                  'Journal is already locked by another user. Cannot proceed.');
               success := 'L';
               journal_version_out := gJournalVersion;
               RETURN;
            WHEN stale_journal_exception
            THEN
               prui_log_error (
                  journal_id,
                  0,
                  6698,
                  'Journal does not exist or was modified by another user. Cannot proceed.');

               /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
               prui_unlock_journal (journal_id, updated_by);
               success := 'V';
               journal_version_out := gJournalVersion;
               RETURN;
            WHEN OTHERS
            THEN
               RAISE;
         END;
      END IF;


      prui_populate_header (
         session_id,
         journal_id,
         journal_type,
         entity,
         source_system,
         TO_DATE (effective_date, 'dd-mm-yyyy hh24:mi:ss'),
         TO_DATE (reversing_date, 'dd-mm-yyyy hh24:mi:ss'),
         description,
         coding_convention,
         updated_by);

      journal_id_out := gJournalHeader.jhu_jrnl_id;

      IF NOT fnui_resync_journal_lines
      THEN
         prui_log_error (
            gJournalHeader.jhu_jrnl_id,
            0,
            1090,
            'Failed to synchronise Journal reference data in lines');
         success := 'F';
         journal_version_out := gJournalVersion;
         RETURN;
      END IF;

      -- no validation required then cannot update
      IF no_validate = 'N'
      THEN
         lvValidateState := fnui_validate_journal_header;

         IF lvValidateState IN (gSTATE_CRITICAL)
         THEN
            success := 'F';
         END IF;

         -- Save changes
         IF lvValidateState IN (gSTATE_OK, gSTATE_ERRORED)
         THEN
            IF NOT fnui_merge_header
            THEN
               success := 'F';
            END IF;

            journal_id_out := gJournalHeader.jhu_jrnl_id;
         END IF;

         -- Persist errors in database
         prui_write_errors_to_database (journal_id);

         -- Execute any custom processes
         pgui_jrnl_custom.prui_upsert_header (journal_id);

         COMMIT;
      END IF;

      journal_version_out := gJournalVersion;
      /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
      prui_unlock_journal (journal_id, updated_by);
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_upsert_header',
                   'gui_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);

         /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
         prui_unlock_journal (journal_id, updated_by);
         journal_version_out := gJournalVersion;
         success := 'F';
   END prui_upsert_header;

   --********************************************************************************

   PROCEDURE prui_upsert_line (
      session_id            IN     VARCHAR2,
      journal_id            IN     SLR_JRNL_LINES.JL_JRNL_HDR_ID%TYPE,
      line_number           IN     SLR_JRNL_LINES.JL_JRNL_LINE_NUMBER%TYPE,
      description           IN     VARCHAR2,
      account               IN     SLR_JRNL_LINES.JL_ACCOUNT%TYPE,
      entity                IN     SLR_JRNL_LINES.JL_ENTITY%TYPE,
      effective_date        IN     VARCHAR2,
      value_date            IN     VARCHAR2,
      segment_1             IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_1%TYPE,
      segment_2             IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_2%TYPE,
      segment_3             IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_3%TYPE,
      segment_4             IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_4%TYPE,
      segment_5             IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_5%TYPE,
      segment_6             IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_6%TYPE,
      segment_7             IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_7%TYPE,
      segment_8             IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_8%TYPE,
      segment_9             IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_9%TYPE,
      segment_10            IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_10%TYPE,
      attribute_1           IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_ATTRIBUTE_1%TYPE,
      attribute_2           IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_ATTRIBUTE_2%TYPE,
      attribute_3           IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_ATTRIBUTE_3%TYPE,
      attribute_4           IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_ATTRIBUTE_4%TYPE,
      attribute_5           IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_ATTRIBUTE_5%TYPE,
      reference_1           IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_1%TYPE,
      reference_2           IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_2%TYPE,
      reference_3           IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_3%TYPE,
      reference_4           IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_4%TYPE,
      reference_5           IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_5%TYPE,
      reference_6           IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_6%TYPE,
      reference_7           IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_7%TYPE,
      reference_8           IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_8%TYPE,
      reference_9           IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_9%TYPE,
      reference_10          IN     TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_10%TYPE,
      tran_currency         IN     SLR_JRNL_LINES.JL_TRAN_CCY%TYPE,
      tran_amount           IN     SLR_JRNL_LINES.JL_TRAN_AMOUNT%TYPE,
      base_currency         IN     SLR_JRNL_LINES.JL_BASE_CCY%TYPE,
      base_rate             IN     SLR_JRNL_LINES.JL_BASE_RATE%TYPE,
      base_amount           IN     SLR_JRNL_LINES.JL_BASE_AMOUNT%TYPE,
      local_currency        IN     SLR_JRNL_LINES.JL_LOCAL_CCY%TYPE,
      local_rate            IN     SLR_JRNL_LINES.JL_LOCAL_RATE%TYPE,
      local_amount          IN     SLR_JRNL_LINES.JL_LOCAL_AMOUNT%TYPE,
      updated_by            IN     SLR_JRNL_LINES.JL_CREATED_BY%TYPE,
      no_validate           IN     CHAR DEFAULT 'N', -- use 'Y' for bulk upload
      journal_version       IN     gui_jrnl_headers_unposted.jhu_version%TYPE,
      journal_line_out         OUT NUMBER,
      journal_version_out      OUT gui_jrnl_headers_unposted.jhu_version%TYPE,
      success                  OUT CHAR)
   IS
      lvValidateState   CHAR (1);
   BEGIN
      success := 'S';

      IF session_id IS NULL
      THEN
         raise_application_error (-20101, 'Missing session id.');
      END IF;

      IF journal_version IS NULL
      THEN
         raise_application_error (-20102, 'Missing journal version.');
      END IF;

      gSessionId := session_id;
      gJournalVersion := journal_version;

      IF NVL (journal_id, -1) > 0
      THEN
         BEGIN
            /* lock journal so only one user can edit it. Procedure commits changes, signals journal_locked_exeption if journal already locked */
            prui_lock_journal (journal_id, updated_by);

            /* check journal version in case there were any changes since journal was displayed on the screen. Signals stale_journal_exception if journal version is different*/
            prui_check_journal_version (journal_id, gJournalVersion);
         EXCEPTION
            WHEN journal_locked_exeption
            THEN
               prui_log_error (
                  journal_id,
                  0,
                  6699,
                  'Journal is already locked by another user. Cannot proceed.');
               success := 'L';
               journal_version_out := gJournalVersion;
               RETURN;
            WHEN stale_journal_exception
            THEN
               prui_log_error (
                  journal_id,
                  0,
                  6698,
                  'Journal does not exist or was modified by another user. Cannot proceed.');

               /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
               prui_unlock_journal (journal_id, updated_by);
               success := 'V';
               journal_version_out := gJournalVersion;
               RETURN;
            WHEN OTHERS
            THEN
               RAISE;
         END;
      END IF;

      -- Only get the header details if inserting a single journal line
      IF no_validate = 'N'
      THEN
         prui_populate_header (session_id          => session_id,
                               journal_id          => journal_id,
                               overwrite_details   => 'N');
      END IF;

      -- populate the temp table
      prui_populate_line (session_id,
                          journal_id,
                          line_number,
                          account,
                          entity,
                          TO_DATE (effective_date, 'dd-mm-yyyy hh24:mi:ss'),
                          TO_DATE (value_date, 'dd-mm-yyyy hh24:mi:ss'),
                          segment_1,
                          segment_2,
                          segment_3,
                          segment_4,
                          segment_5,
                          segment_6,
                          segment_7,
                          segment_8,
                          segment_9,
                          segment_10,
                          attribute_1,
                          attribute_2,
                          attribute_3,
                          attribute_4,
                          attribute_5,
                          reference_1,
                          reference_2,
                          reference_3,
                          reference_4,
                          reference_5,
                          reference_6,
                          reference_7,
                          reference_8,
                          reference_9,
                          reference_10,
                          description,
                          tran_currency,
                          tran_amount,
                          base_currency,
                          base_rate,
                          base_amount,
                          local_currency,
                          local_rate,
                          local_amount,
                          updated_by);

      journal_line_out := gJournalLineNumber;

      -- If no validation required then do not update SLR
      IF no_validate = 'N'
      THEN
         lvValidateState := fnui_validate_journal_line;

         IF lvValidateState IN (gSTATE_CRITICAL)
         THEN
            success := 'F';
         END IF;

         -- Save changes
         IF lvValidateState IN (gSTATE_OK, gSTATE_ERRORED)
         THEN
            IF fnui_merge_lines
            THEN
               -- Execute any custom processes
               pgui_jrnl_custom.prui_upsert_line (journal_id, line_number);
            ELSE
               success := 'F';
            END IF;
         END IF;

         -- Persist errors in database
         prui_write_errors_to_database (journal_id);

         -- Update header balances, etc.
         prui_update_header_stats (journal_id);

         COMMIT;
      END IF;

      journal_version_out := gJournalVersion;
      /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
      prui_unlock_journal (journal_id, updated_by);
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_upsert_line',
                   'gui_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);

         /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
         prui_unlock_journal (journal_id, updated_by);

         journal_version_out := gJournalVersion;
         success := 'F';
   END prui_upsert_line;

   --********************************************************************************

   -- Need to use prui_upsert_header / prui_upsert_line
   PROCEDURE prui_bulk_submission (
      session_id       IN     VARCHAR2,
      journal_id       IN     SLR_JRNL_LINES.JL_JRNL_HDR_ID%TYPE,
      updated_by       IN     SLR_JRNL_LINES.JL_AMENDED_BY%TYPE,
      journal_id_out      OUT NUMBER,
      success             OUT CHAR)
   IS
      lvValidateState   CHAR (1);
   BEGIN
      success := 'S';
      journal_id_out := -1;
      gSessionId := session_id;
      gJournalVersion := 0;

      -- Insert header in gJournalHeader
      BEGIN
         SELECT jhu_jrnl_id,
                jhu_jrnl_type,
                jhu_jrnl_date,
                jhu_jrnl_entity,
                jhu_epg_id,
                jhu_jrnl_status,
                jhu_jrnl_status_text,
                jhu_jrnl_process_id,
                jhu_jrnl_description,
                jhu_jrnl_source,
                jhu_jrnl_source_jrnl_id,
                jhu_jrnl_authorised_by,
                jhu_jrnl_authorised_on,
                jhu_jrnl_validated_by,
                jhu_jrnl_validated_on,
                jhu_jrnl_posted_by,
                jhu_jrnl_posted_on,
                jhu_jrnl_total_hash_debit,
                jhu_jrnl_total_hash_credit,
                jhu_jrnl_total_lines,
                jhu_created_by,
                jhu_created_on,
                jhu_amended_by,
                jhu_amended_on,
                jhu_jrnl_pref_static_src,
                jhu_jrnl_ref_id,
                jhu_jrnl_rev_date,
                'Y'
           INTO gJournalHeader
           FROM temp_gui_jrnl_headers_unposted
          WHERE     jhu_jrnl_id = NVL (journal_id, -1)
                AND user_session_id = session_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'prui_bulk_submission',
                      'gui_jrnl_headers_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            success := 'F';
            RAISE;
      END;

      -- valid journal journal and journal lines
      lvValidateState := fnui_validate_journal_header;

      IF lvValidateState IN (gSTATE_CRITICAL)
      THEN
         success := 'F';
      END IF;

      -- Save changes
      IF lvValidateState IN (gSTATE_OK, gSTATE_ERRORED)
      THEN
         -- Save header
         IF fnui_merge_header
         THEN
            journal_id_out := gJournalHeader.jhu_jrnl_id;

            -- Do custom updates for header
            pgui_jrnl_custom.prui_upsert_header (gJournalHeader.jhu_jrnl_id);

            -- Saved header, now save lines
            IF fnui_merge_lines
            THEN
               -- Do custom updates for lines
               pgui_jrnl_custom.prui_upsert_lines (
                  gJournalHeader.jhu_jrnl_id);
            ELSE
               -- failed to merge lines
               success := 'F';
            END IF;
         ELSE
            -- failed to merge header
            success := 'F';
         END IF;

         -- Persist errors in database
         prui_write_errors_to_database (gJournalHeader.jhu_jrnl_id);
      END IF;

      -- Update Header Stats
      prui_update_header_stats (gJournalHeader.jhu_jrnl_id);

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_bulk_submission',
                   'gui_jrnl_headers_unposted/gui_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         success := 'F';
   END prui_bulk_submission;

   --********************************************************************************

   PROCEDURE prui_delete_journal (
      session_id        IN     VARCHAR2,
      journal_id        IN     SLR_JRNL_HEADERS.JH_JRNL_ID%TYPE,
      updated_by        IN     SLR_JRNL_HEADERS.JH_CREATED_BY%TYPE,
      journal_version   IN     gui_jrnl_headers_unposted.jhu_version%TYPE,
      success              OUT CHAR)
   IS
   BEGIN
      success := 'S';

      IF session_id IS NULL
      THEN
         raise_application_error (-20101, 'Missing session id.');
      END IF;

      IF journal_version IS NULL
      THEN
         raise_application_error (-20102, 'Missing journal version.');
      END IF;

      gSessionId := session_id;
      gJournalVersion := journal_version;

      BEGIN
         /* lock journal so only one user can edit it. Procedure commits changes, signals journal_locked_exeption if journal already locked */
         prui_lock_journal (journal_id, updated_by);

         /* check journal version in case there were any changes since journal was displayed on the screen. Signals stale_journal_exception if journal version is different*/
         prui_check_journal_version (journal_id, gJournalVersion);
      EXCEPTION
         WHEN journal_locked_exeption
         THEN
            prui_log_error (
               journal_id,
               0,
               6699,
               'Journal is already locked by another user. Cannot proceed.');
            success := 'L';
            RETURN;
         WHEN stale_journal_exception
         THEN
            prui_log_error (
               journal_id,
               0,
               6698,
               'Journal does not exist or was modified by another user. Cannot proceed.');

            /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
            prui_unlock_journal (journal_id, updated_by);
            success := 'V';
            RETURN;
         WHEN OTHERS
         THEN
            RAISE;
      END;


      -- Delete journal (if action valid)
      IF fnui_check_deletion (journal_id)
      THEN
         BEGIN
            SAVEPOINT prui_delete_journal;

            -- Delete all lines
            DELETE FROM gui_jrnl_lines_unposted
                  WHERE jlu_jrnl_hdr_id = journal_id;

            -- Delete header
            DELETE FROM gui_jrnl_headers_unposted
                  WHERE jhu_jrnl_id = journal_id;

            -- Remove errors for this journal
            prui_clear_errors (journal_id);

            -- Execute any custom processes
            pgui_jrnl_custom.prui_delete_journal (journal_id);
         EXCEPTION
            WHEN OTHERS
            THEN
               ROLLBACK TO SAVEPOINT prui_delete_journal;
               prui_log_error (journal_id,
                               0,
                               1070,
                               'Unable to delete Journal');
               pr_error (1,
                         SQLERRM,
                         0,
                         'prui_delete_journal',
                         'gui_jrnl_headers_unposted',
                         NULL,
                         NULL,
                         gPackageName,
                         'PL/SQL',
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL);
               success := 'F';
         END;
      ELSE
         success := 'F';
      END IF;

      -- Persist errors in database
      prui_write_errors_to_database (journal_id);

      /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
      prui_unlock_journal (journal_id, updated_by);

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_delete_journal',
                   'gui_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);

         /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
         prui_unlock_journal (journal_id, updated_by);
         success := 'F';
   END prui_delete_journal;

   --********************************************************************************

   PROCEDURE prui_delete_journals (
      session_id         IN     VARCHAR2,
      journal_id_list    IN     VARCHAR2,
      updated_by         IN     SLR_JRNL_HEADERS.JH_CREATED_BY%TYPE,
      success               OUT CHAR,
      failed_jrnl_list      OUT VARCHAR2)
   IS
      journal_list            array_list := array_list ();
      list_count              NUMBER (12);
      loop_count              NUMBER (12);
      journal_list_in_error   VARCHAR2 (32700) := NULL;
      lv_success              CHAR (1);
      lv_failed_count         NUMBER (5) := 0;
      lv_journal_id           NUMBER (12, 0);
      lv_journal_version      NUMBER (5, 0);
   BEGIN
      success := 'S';
      gSessionId := session_id;

      prui_process_param_list (journal_id_list, journal_list, list_count);

      FOR loop_count IN 1 .. list_count
      LOOP
         lv_journal_id :=
            SUBSTR (journal_list (loop_count),
                    0,
                    INSTR (journal_list (loop_count), '~') - 1);
         lv_journal_version :=
            SUBSTR (journal_list (loop_count),
                    INSTR (journal_list (loop_count), '~') + 1);

         prui_delete_journal (gSessionId,
                              lv_journal_id,
                              updated_by,
                              lv_journal_version,
                              lv_success);

         IF lv_success <> 'S'
         THEN
            lv_failed_count := lv_failed_count + 1;

            IF journal_list_in_error IS NOT NULL
            THEN
               journal_list_in_error :=
                  journal_list_in_error || ',' || TO_CHAR (lv_journal_id);
            ELSE
               journal_list_in_error := TO_CHAR (lv_journal_id);
            END IF;
         END IF;
      END LOOP;

      IF lv_failed_count = 0
      THEN
         success := 'S';
      ELSIF lv_failed_count < list_count
      THEN
         success := 'P';
      ELSE
         success := 'F';
      END IF;

      failed_jrnl_list := journal_list_in_error;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_delete_journal',
                   'gui_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         success := 'F';
   END prui_delete_journals;

   --********************************************************************************

   PROCEDURE prui_delete_lines (
      session_id         IN     VARCHAR2,
      journal_id         IN     SLR_JRNL_LINES.JL_JRNL_HDR_ID%TYPE,
      line_number_list   IN     VARCHAR2,
      updated_by         IN     SLR_JRNL_LINES.JL_CREATED_BY%TYPE,
      journal_version    IN     gui_jrnl_headers_unposted.jhu_version%TYPE,
      success               OUT CHAR)
   IS
      line_no           NUMBER;
      line_list         array_list := array_list ();
      line_count        NUMBER (12);
      loop_count        NUMBER (12);
      lvSavePoint       VARCHAR2 (20);
      lvValidateState   CHAR (1);
   BEGIN
      success := 'S';

      IF session_id IS NULL
      THEN
         raise_application_error (-20101, 'Missing session id.');
      END IF;

      IF journal_version IS NULL
      THEN
         raise_application_error (-20102, 'Missing journal version.');
      END IF;

      gSessionId := session_id;
      gJournalVersion := journal_version;

      BEGIN
         /* lock journal so only one user can edit it. Procedure commits changes, signals journal_locked_exeption if journal already locked */
         prui_lock_journal (journal_id, updated_by);

         /* check journal version in case there were any changes since journal was displayed on the screen. Signals stale_journal_exception if journal version is different*/
         prui_check_journal_version (journal_id, gJournalVersion);
      EXCEPTION
         WHEN journal_locked_exeption
         THEN
            prui_log_error (
               journal_id,
               0,
               6699,
               'Journal is already locked by another user. Cannot proceed.');
            success := 'L';
            RETURN;
         WHEN stale_journal_exception
         THEN
            prui_log_error (
               journal_id,
               0,
               6698,
               'Journal does not exist or was modified by another user. Cannot proceed.');

            /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
            prui_unlock_journal (journal_id, updated_by);
            success := 'V';
            RETURN;
         WHEN OTHERS
         THEN
            RAISE;
      END;

      -- Populate journal in temporary tables
      prui_populate_header (session_id          => session_id,
                            journal_id          => journal_id,
                            overwrite_details   => 'N');

      -- Convert pipe delimited list into array
      prui_process_param_list (line_number_list, line_list, line_count);

      -- Loop through list and delete
      FOR loop_count IN 1 .. line_count
      LOOP
         -- Delete line (if action valid)
         IF fnui_check_delete_line (journal_id,
                                    TO_NUMBER (line_list (loop_count))) =
               TRUE
         THEN
            BEGIN
               lvSavePoint := 'DelLine' || TO_CHAR (line_list (loop_count));
               SAVEPOINT lvSavePoint;

               -- Delete line
               DELETE FROM gui_jrnl_lines_unposted
                     WHERE     jlu_jrnl_hdr_id = journal_id
                           AND jlu_jrnl_line_number = line_list (loop_count);

               DELETE FROM temp_gui_jrnl_lines_unposted
                     WHERE     jlu_jrnl_hdr_id = journal_id
                           AND jlu_jrnl_line_number = line_list (loop_count)
                           AND user_session_id = gSessionId;
            EXCEPTION
               WHEN OTHERS
               THEN
                  ROLLBACK TO SAVEPOINT lvSavePoint;
                  prui_log_error (journal_id,
                                  line_list (loop_count),
                                  1070,
                                  'Unable to delete Journal Line');
                  pr_error (1,
                            SQLERRM,
                            0,
                            'prui_delete_line',
                            'gui_jrnl_lines_unposted',
                            NULL,
                            NULL,
                            gPackageName,
                            'PL/SQL',
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL);
                  success := 'F';
            END;
         ELSE
            success := 'F';
         END IF;
      END LOOP;

      prui_increment_journal_version (journal_id, updated_by);
      /**
       * Uncomment the prui_reorder_journal_lines statement
       * to re-order journal lines after removing journal lines.
       *
       * This will ensure that the line number reported in
       * error messages do not get out of step with those
       * displayed in the Journal Headers screen
       **/

      -- Re-order journal lines
      -- prui_reorder_journal_lines(journal_id);

      -- Re-validate after changes
      lvValidateState := fnui_validate_journal_header;

      IF lvValidateState IN (gSTATE_CRITICAL)
      THEN
         success := 'F';
      END IF;

      -- Persist errors in database
      prui_write_errors_to_database (journal_id);

      -- Execute any custom processes
      pgui_jrnl_custom.prui_delete_line (journal_id, line_list);

      -- Update Header Stats
      prui_update_header_stats (journal_id);

      /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
      prui_unlock_journal (journal_id, updated_by);
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_delete_line',
                   'gui_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);

         /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
         prui_unlock_journal (journal_id, updated_by);
         success := 'F';
   END prui_delete_lines;

   --********************************************************************************

   PROCEDURE prui_reverse_journal (
      session_id       IN     VARCHAR2,
      journal_id       IN     SLR_JRNL_HEADERS.JH_JRNL_ID%TYPE,
      reversing_date   IN     VARCHAR2,
      updated_by       IN     SLR_JRNL_HEADERS.JH_CREATED_BY%TYPE,
      new_jrnl_id         OUT SLR_JRNL_HEADERS.JH_JRNL_ID%TYPE,
      success             OUT CHAR)
   IS
   BEGIN
      success := 'Y';

      -- Note the gJournalHeader should not be treated as a complete, validate record.
      -- It is used as a global parameter list
      prui_populate_header (
         session_id       => session_id,
         journal_id       => journal_id,
         reversing_date   => TO_DATE (reversing_date, 'dd-mm-yyyy hh24:mi:ss'),
         updated_by       => updated_by);

      IF fnui_check_quick_reversal
      THEN
         IF NOT fnui_create_reversing_journal (journal_id,
                                               reversing_date,
                                               NULL,
                                               NULL)
         THEN
            success := 'N';
         ELSE
            new_jrnl_id := gJournalHeader.jhu_jrnl_id;
         END IF;
      ELSE
         success := 'N';
      END IF;

      -- Execute any custom processes
      pgui_jrnl_custom.prui_reverse_journal (journal_id, new_jrnl_id);

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_reverse_line',
                   'slr_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         success := 'N';
   END prui_reverse_journal;

   --********************************************************************************

   -- For use with R2 code base
   PROCEDURE prui_copy_journal (
      session_id       IN     VARCHAR2,
      journal_id       IN     SLR_JRNL_HEADERS.JH_JRNL_ID%TYPE,
      effective_date   IN     SLR_JRNL_HEADERS.JH_JRNL_DATE%TYPE,
      reversing_date   IN     SLR_JRNL_HEADERS.JH_JRNL_REV_DATE%TYPE,
      updated_by       IN     SLR_JRNL_HEADERS.JH_AMENDED_BY%TYPE,
      new_jrnl_id         OUT SLR_JRNL_HEADERS.JH_JRNL_ID%TYPE,
      success             OUT CHAR)
   IS
   BEGIN
      success := 'Y';

      -- Note the gJournalHeader should not be treated as a complete, validate record.
      -- It is used as a global parameter list
      prui_populate_header (
         session_id       => session_id,
         journal_id       => journal_id,
         reversing_date   => TO_DATE (reversing_date, 'dd-mm-yyyy hh24:mi:ss'),
         updated_by       => updated_by);

      IF fnui_check_copy_journal
      THEN
         IF NOT fnui_create_copy_journal (journal_id)
         THEN
            success := 'N';
         ELSE
            new_jrnl_id := gJournalHeader.jhu_jrnl_id;
         END IF;
      ELSE
         success := 'N';
      END IF;

      -- Execute any custom processes
      pgui_jrnl_custom.prui_copy_journal (journal_id, new_jrnl_id);

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_copy_journal',
                   'slr_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         success := 'N';
   END prui_copy_journal;

   --********************************************************************************

   PROCEDURE prui_post_journals (
      session_id         IN     VARCHAR2,
      journal_id_list    IN     VARCHAR2,
      updated_by         IN     SLR_JRNL_HEADERS.JH_CREATED_BY%TYPE,
      success               OUT CHAR,
      failed_jrnl_list      OUT VARCHAR2)
   IS
      journal_list            array_list := array_list ();
      list_count              NUMBER (12);
      loop_count              NUMBER (12);
      journal_list_in_error   VARCHAR2 (32700) := '';

      lv_success              CHAR (1);
      lv_failed_count         NUMBER (5) := 0;
      lv_journal_id           NUMBER (12, 0);
      lv_journal_version      NUMBER (5, 0);
   BEGIN
      success := 'S';
      gSessionId := session_id;
      gBulkSubmission := TRUE;
      prui_process_param_list (journal_id_list, journal_list, list_count);

      FOR loop_count IN 1 .. list_count
      LOOP
         lv_journal_id :=
            SUBSTR (journal_list (loop_count),
                    0,
                    INSTR (journal_list (loop_count), '~') - 1);
         lv_journal_version :=
            SUBSTR (journal_list (loop_count),
                    INSTR (journal_list (loop_count), '~') + 1);

         prui_post_journal (gSessionId,
                            lv_journal_id,
                            updated_by,
                            lv_journal_version,
                            lv_success);

         IF lv_success <> 'S'
         THEN
            lv_failed_count := lv_failed_count + 1;

            IF journal_list_in_error IS NOT NULL
            THEN
               journal_list_in_error :=
                  journal_list_in_error || ',' || TO_CHAR (lv_journal_id);
            ELSE
               journal_list_in_error := TO_CHAR (lv_journal_id);
            END IF;
         END IF;
      END LOOP;

      IF lv_failed_count = 0
      THEN
         success := 'S';
      ELSIF lv_failed_count < list_count
      THEN
         success := 'P';
      ELSE
         success := 'F';
      END IF;

      failed_jrnl_list := journal_list_in_error;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_post_journals',
                   'gui_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         success := 'F';
   END prui_post_journals;

   --********************************************************************************

   PROCEDURE prui_post_journal (
      session_id        IN     VARCHAR2,
      journal_id        IN     SLR_JRNL_HEADERS.JH_JRNL_ID%TYPE,
      updated_by        IN     SLR_JRNL_HEADERS.JH_AMENDED_BY%TYPE,
      journal_version   IN     gui_jrnl_headers_unposted.jhu_version%TYPE,
      success              OUT CHAR)
   IS
      vEntityProcGroupName   VARCHAR2 (20);
      lvValidateState        CHAR (1);
      lvReversingDate        DATE;
      v_jrnl_num_of_lines    NUMBER (10, 0);
   BEGIN
      success := 'S';

      IF session_id IS NULL
      THEN
         raise_application_error (-20101, 'Missing session id.');
      END IF;

      IF journal_version IS NULL
      THEN
         raise_application_error (-20102, 'Missing journal version.');
      END IF;

      gSessionId := session_id;
      gJournalVersion := journal_version;

      BEGIN
         /* lock journal so only one user can edit it. Procedure commits changes, signals journal_locked_exeption if journal already locked */
         prui_lock_journal (journal_id, updated_by);

         /* check journal version in case there were any changes since journal was displayed on the screen. Signals stale_journal_exception if journal version is different*/
         prui_check_journal_version (journal_id, gJournalVersion);
      EXCEPTION
         WHEN journal_locked_exeption
         THEN
            prui_log_error (
               journal_id,
               0,
               6699,
               'Journal is already locked by another user. Cannot proceed.');
            success := 'L';
            RETURN;
         WHEN stale_journal_exception
         THEN
            prui_log_error (
               journal_id,
               0,
               6698,
               'Journal does not exist or was modified by another user. Cannot proceed.');

            /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
            prui_unlock_journal (journal_id, updated_by);
            success := 'V';
            RETURN;
         WHEN OTHERS
         THEN
            RAISE;
      END;



      SELECT JHU_EPG_ID, jhu_jrnl_total_lines
        INTO vEntityProcGroupName, v_jrnl_num_of_lines
        FROM gui_JRNL_HEADERS_UNPOSTED
       WHERE JHU_JRNL_ID = journal_id;


      prui_populate_header (session_id          => session_id,
                            journal_id          => journal_id,
                            overwrite_details   => 'N');

      --prui_clear_errors(journal_id);

      -- Validate journal use gui core validation
      /* do not validate as it's redundant with upsert header
   BEGIN

        lvValidateState := fnui_validate_journal_header;
        IF lvValidateState not IN (gSTATE_OK) THEN
            success := 'F';
        END IF;


       EXCEPTION
          WHEN OTHERS THEN
              pr_error(1, SQLERRM, 0, 'prui_post_journal', 'gui_jrnl_headers_unposted', NULL, NULL, gPackageName, 'PL/SQL', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
              success := 'F';
      END; */

      IF NOT fnui_get_journal_type
      THEN
         success := 'F';
      END IF;

      IF NOT fnui_get_entity
      THEN
         success := 'F';
      END IF;

      -- Exit if errors
      IF (success = 'F' OR fnui_any_errors (journal_id))
      THEN
         prui_log_error (journal_id,
                         0,
                         1031,
                         'Journal failed validation. Unable to post journal');

         -- Persist errors in database
         prui_write_errors_to_database (journal_id);

         success := 'F';

         /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
         prui_unlock_journal (journal_id, updated_by);
         COMMIT;
         RETURN;
      END IF;


      --update rates in lines, does not raise exceptions
      prui_calculate_journal_rates (journal_id);

      -- Update audit section
      UPDATE gui_jrnl_headers_unposted
         SET jhu_jrnl_validated_by = updated_by,
             jhu_jrnl_validated_on = SYSDATE,
             jhu_jrnl_posted_by = updated_by,
             jhu_jrnl_posted_on = SYSDATE
       WHERE jhu_jrnl_id = journal_id;



      -- Check if authorisation is required on
      -- this journal type
      IF fnui_requires_authorisation
      THEN
         prui_set_status (journal_id, gSTATUS_AUTHORISE);

         -- Execute any custom processes
         pgui_jrnl_custom.prui_pending_auth (journal_id);
      ELSE
         -- reorder lines
         prui_reorder_journal_lines (journal_id);

         -- Execute any custom processes
         pgui_jrnl_custom.prui_post_journal (journal_id);

         BEGIN
            SAVEPOINT add_jrnl_to_posting_queue;

            UPDATE gui_jrnl_headers_unposted
               SET jhu_jrnl_authorised_by = updated_by,
                   jhu_jrnl_authorised_on = SYSDATE
             WHERE jhu_jrnl_id = journal_id;

            --add journal to posting queue
            prui_add_jrnl_to_posting_queue (journal_id,
                                            vEntityProcGroupName,
                                            v_jrnl_num_of_lines);
         EXCEPTION
            WHEN OTHERS
            THEN
               ROLLBACK TO SAVEPOINT add_jrnl_to_posting_queue;
               prui_log_error (journal_id,
                               0,
                               9999,
                               'Failed to add journal to the posting queue.');
               prui_write_errors_to_database (journal_id);
               --commit;
               RAISE;
         END;
      END IF;

      -- Persist errors in database
      prui_write_errors_to_database (journal_id);


      /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
      prui_unlock_journal (journal_id, updated_by);

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_post_journal',
                   'gui_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);

         /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
         prui_unlock_journal (journal_id, updated_by);
         success := 'F';
   END prui_post_journal;

   --********************************************************************************

   PROCEDURE prui_copy_lines (
      session_id         IN     VARCHAR2,
      journal_id         IN     SLR_JRNL_LINES.JL_JRNL_HDR_ID%TYPE,
      line_number_list   IN     VARCHAR2,
      updated_by         IN     SLR_JRNL_LINES.JL_CREATED_BY%TYPE,
      journal_version    IN     gui_jrnl_headers_unposted.jhu_version%TYPE,
      success               OUT CHAR)
   IS
      line_no           NUMBER;
      line_list         array_list := array_list ();
      line_count        NUMBER (12);
      loop_count        NUMBER (12);
      new_line          NUMBER (10);
      lvValidateState   CHAR (1);
   BEGIN
      success := 'S';

      IF session_id IS NULL
      THEN
         raise_application_error (-20101, 'Missing session id.');
      END IF;

      IF journal_version IS NULL
      THEN
         raise_application_error (-20102, 'Missing journal version.');
      END IF;

      gSessionId := session_id;
      gJournalVersion := journal_version;

      BEGIN
         /* lock journal so only one user can edit it. Procedure commits changes, signals journal_locked_exeption if journal already locked */
         prui_lock_journal (journal_id, updated_by);

         /* check journal version in case there were any changes since journal was displayed on the screen. Signals stale_journal_exception if journal version is different*/
         prui_check_journal_version (journal_id, gJournalVersion);
      EXCEPTION
         WHEN journal_locked_exeption
         THEN
            prui_log_error (
               journal_id,
               0,
               6699,
               'Journal is already locked by another user. Cannot proceed.');
            success := 'L';
            RETURN;
         WHEN stale_journal_exception
         THEN
            prui_log_error (
               journal_id,
               0,
               6698,
               'Journal does not exist or was modified by another user. Cannot proceed.');

            /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
            prui_unlock_journal (journal_id, updated_by);
            success := 'V';
            RETURN;
         WHEN OTHERS
         THEN
            RAISE;
      END;


      -- retrieve the whole of the journal
      prui_populate_header (session_id          => session_id,
                            journal_id          => journal_id,
                            overwrite_details   => 'N');

      -- Convert pipe delimited list into array
      prui_process_param_list (line_number_list, line_list, line_count);

      FOR loop_count IN 1 .. line_count
      LOOP
         -- Check if line exists
         IF fnui_check_copy_line (journal_id,
                                  TO_NUMBER (line_list (loop_count)))
         THEN
            BEGIN
               -- Get next available line in journal
               SELECT NVL (MAX (jlu_jrnl_line_number) + 1, 1)
                 INTO new_line
                 FROM temp_gui_jrnl_lines_unposted
                WHERE jlu_jrnl_hdr_id = journal_id;

               -- Copy line
               INSERT INTO temp_gui_jrnl_lines_unposted (
                              user_session_id,
                              jlu_jrnl_hdr_id,
                              jlu_jrnl_line_number,
                              jlu_fak_id,
                              jlu_eba_id,
                              jlu_jrnl_status,
                              jlu_jrnl_status_text,
                              jlu_jrnl_process_id,
                              jlu_description,
                              jlu_source_jrnl_id,
                              jlu_effective_date,
                              jlu_value_date,
                              jlu_entity,
                              jlu_account,
                              jlu_segment_1,
                              jlu_segment_2,
                              jlu_segment_3,
                              jlu_segment_4,
                              jlu_segment_5,
                              jlu_segment_6,
                              jlu_segment_7,
                              jlu_segment_8,
                              jlu_segment_9,
                              jlu_segment_10,
                              jlu_attribute_1,
                              jlu_attribute_2,
                              jlu_attribute_3,
                              jlu_attribute_4,
                              jlu_attribute_5,
                              jlu_reference_1,
                              jlu_reference_2,
                              jlu_reference_3,
                              jlu_reference_4,
                              jlu_reference_5,
                              jlu_reference_6,
                              jlu_reference_7,
                              jlu_reference_8,
                              jlu_reference_9,
                              jlu_reference_10,
                              jlu_tran_ccy,
                              jlu_tran_amount,
                              jlu_base_rate,
                              jlu_base_ccy,
                              jlu_base_amount,
                              jlu_local_rate,
                              jlu_local_ccy,
                              jlu_local_amount,
                              jlu_created_by,
                              jlu_created_on,
                              jlu_amended_by,
                              jlu_amended_on,
                              db_state,
                              jlu_epg_id,
                              jlu_period_month,
                              jlu_period_year,
                              jlu_period_ltd)
                  SELECT                                 /* user_session_id */
                        gSessionId,
                         /* jlu_jrnl_hdr_id */
                         jlu_jrnl_hdr_id,
                         /* jlu_jrnl_line_number */
                         new_line,
                         /* jlu_fak_id */
                         jlu_fak_id,
                         /* jlu_eba_id */
                         jlu_eba_id,
                         /* jlu_jrnl_status */
                         jlu_jrnl_status,
                         /* jlu_jrnl_status_text */
                         jlu_jrnl_status_text,
                         /* jlu_jrnl_process_id */
                         jlu_jrnl_process_id,
                         /* jlu_description */
                         jlu_description,
                         /* jlu_source_jrnl_id */
                         jlu_source_jrnl_id,
                         /* jlu_effective_date */
                         jlu_effective_date,
                         /* jlu_value_date */
                         jlu_value_date,
                         /* jlu_entity */
                         jlu_entity,
                         /* jlu_account */
                         jlu_account,
                         /* jlu_segment_1 */
                         jlu_segment_1,
                         /* jlu_segment_2 */
                         jlu_segment_2,
                         /* jlu_segment_3 */
                         jlu_segment_3,
                         /* jlu_segment_4 */
                         jlu_segment_4,
                         /* jlu_segment_5 */
                         jlu_segment_5,
                         /* jlu_segment_6 */
                         jlu_segment_6,
                         /* jlu_segment_7 */
                         jlu_segment_7,
                         /* jlu_segment_8 */
                         jlu_segment_8,
                         /* jlu_segment_9 */
                         jlu_segment_9,
                         /* jlu_segment_10 */
                         jlu_segment_10,
                         /* jlu_attribute_1 */
                         jlu_attribute_1,
                         /* jlu_attribute_2 */
                         jlu_attribute_2,
                         /* jlu_attribute_3 */
                         jlu_attribute_3,
                         /* jlu_attribute_4 */
                         jlu_attribute_4,
                         /* jlu_attribute_5 */
                         jlu_attribute_5,
                         /* jlu_reference_1 */
                         jlu_reference_1,
                         /* jlu_reference_2 */
                         jlu_reference_2,
                         /* jlu_reference_3 */
                         jlu_reference_3,
                         /* jlu_reference_4 */
                         jlu_reference_4,
                         /* jlu_reference_5 */
                         jlu_reference_5,
                         /* jlu_reference_6 */
                         jlu_reference_6,
                         /* jlu_reference_7 */
                         jlu_reference_7,
                         /* jlu_reference_8 */
                         jlu_reference_8,
                         /* jlu_reference_9 */
                         jlu_reference_9,
                         /* jlu_reference_10 */
                         jlu_reference_10,
                         /* jlu_tran_ccy */
                         jlu_tran_ccy,
                         /* jlu_tran_amount */
                         jlu_tran_amount,
                         /* jlu_base_rate */
                         jlu_base_rate,
                         /* jlu_base_ccy */
                         DECODE (NVL (jlu_base_amount, 0),
                                 0, NULL,
                                 jlu_base_ccy),
                         /* jlu_base_amount */
                         DECODE (NVL (jlu_base_amount, 0),
                                 0, NULL,
                                 jlu_base_amount),
                         /* jlu_local_rate */
                         jlu_local_rate,
                         /* jlu_local_ccy */
                         DECODE (NVL (jlu_local_amount, 0),
                                 0, NULL,
                                 jlu_local_ccy),
                         /* jlu_local_amount */
                         DECODE (NVL (jlu_local_amount, 0),
                                 0, NULL,
                                 jlu_local_amount),
                         /* jlu_created_by */
                         updated_by,
                         /* jlu_created_on */
                         SYSDATE,
                         /* jlu_amended_by */
                         updated_by,
                         /* jlu_amended_on */
                         SYSDATE,
                         /* db_state */
                         'I',
                         /* jlu_epg_id */
                         jlu_epg_id,
                         /* jlu_period_month */
                         jlu_period_month,
                         /* jlu_period_year */
                         jlu_period_year,
                         /* jlu_period_ltd */
                         jlu_period_ltd
                    FROM gui_jrnl_lines_unposted
                   WHERE     jlu_jrnl_hdr_id = journal_id
                         AND jlu_jrnl_line_number = line_list (loop_count);
            EXCEPTION
               WHEN OTHERS
               THEN
                  pr_error (1,
                            SQLERRM,
                            0,
                            'prui_copy_lines.1',
                            'gui_jrnl_lines_unposted',
                            NULL,
                            NULL,
                            gPackageName,
                            'PL/SQL',
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL);
                  success := 'F';
            END;
         ELSE
            success := 'F';
         END IF;
      END LOOP;

      -- Validate new lines
      lvValidateState := fnui_validate_journal_line;

      IF lvValidateState IN (gSTATE_CRITICAL)
      THEN
         success := 'F';
      END IF;

      -- Save changes
      IF lvValidateState IN (gSTATE_OK, gSTATE_ERRORED)
      THEN
         IF NOT fnui_merge_lines
         THEN
            success := 'F';
         END IF;
      END IF;

      -- Persist errors in database
      prui_write_errors_to_database (journal_id);

      -- Execute any custom processes
      pgui_jrnl_custom.prui_upsert_lines (journal_id);

      -- Update Header Stats
      prui_update_header_stats (journal_id);

      /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
      prui_unlock_journal (journal_id, updated_by);

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_copy_lines',
                   'gui_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);

         /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
         prui_unlock_journal (journal_id, updated_by);
         success := 'F';
   END prui_copy_lines;

   --********************************************************************************

   PROCEDURE prui_authorise_journals (
      session_id         IN     VARCHAR2,
      journal_id_list    IN     VARCHAR2,
      updated_by         IN     SLR_JRNL_HEADERS.JH_AMENDED_BY%TYPE,
      success               OUT CHAR,
      failed_jrnl_list      OUT VARCHAR2)
   IS
      loop_count              NUMBER;
      journal_list            array_list := array_list ();
      list_count              NUMBER;
      journal_list_in_error   VARCHAR2 (32700) := NULL;

      lv_success              CHAR (1);
      lv_failed_count         NUMBER (5) := 0;
      lv_journal_id           NUMBER (12, 0);
      lv_journal_version      NUMBER (5, 0);
   BEGIN
      success := 'S';
      gSessionId := session_id;
      gBulkSubmission := TRUE;
      prui_process_param_list (journal_id_list, journal_list, list_count);


      FOR loop_count IN 1 .. list_count
      LOOP
         lv_journal_id :=
            SUBSTR (journal_list (loop_count),
                    0,
                    INSTR (journal_list (loop_count), '~') - 1);
         lv_journal_version :=
            SUBSTR (journal_list (loop_count),
                    INSTR (journal_list (loop_count), '~') + 1);

         prui_authorise_journal (gSessionId,
                                 lv_journal_id,
                                 updated_by,
                                 lv_journal_version,
                                 lv_success);

         IF lv_success <> 'S'
         THEN
            lv_failed_count := lv_failed_count + 1;

            IF journal_list_in_error IS NOT NULL
            THEN
               journal_list_in_error :=
                  journal_list_in_error || ',' || TO_CHAR (lv_journal_id);
            ELSE
               journal_list_in_error := TO_CHAR (lv_journal_id);
            END IF;
         END IF;
      END LOOP;

      IF lv_failed_count = 0
      THEN
         success := 'S';
      ELSIF lv_failed_count < list_count
      THEN
         success := 'P';
      ELSE
         success := 'F';
      END IF;

      failed_jrnl_list := journal_list_in_error;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_authorise_journals',
                   'gui_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         success := 'F';
   END prui_authorise_journals;

   --********************************************************************************

   /* PROCEDURE prui_post_to_sub_ledger
    (
        ent_proc_group VARCHAR2,
        journal_id NUMBER,
        pProcessId NUMBER,
        status VARCHAR2,
        pUpdatedBy in SLR_JRNL_HEADERS.JH_AMENDED_BY%TYPE := USER
    )
    IS
      lvReversingDate DATE;
    BEGIN
        -- Update base and local rates
        BEGIN



         UPDATE slr_jrnl_lines_unposted
   SET  jlu_base_rate =
    CASE
     WHEN jlu_tran_amount = 0
     THEN 0
     WHEN LENGTH(ABS(trunc(ROUND(jlu_base_amount/jlu_tran_amount, 9)))) > 9
     THEN 0
     ELSE ROUND(jlu_base_amount/jlu_tran_amount, 9)
     END
    , jlu_local_rate =
    CASE
     WHEN jlu_tran_amount = 0
     THEN 0
     WHEN LENGTH(ABS(trunc(ROUND(jlu_local_amount/jlu_tran_amount, 9)))) > 9
     THEN 0
     ELSE ROUND(jlu_local_amount/jlu_tran_amount, 9)
     END
   WHERE jlu_jrnl_hdr_id = journal_id;

        EXCEPTION
           WHEN OTHERS THEN
             prui_log_error(journal_id, 0, 9999, 'Failed to update base and local rates for journal '||TO_CHAR(journal_id));
        END;

         -- Re-allocate line numbers to all journal lines (as these may not be sequential)
         -- Do not want to do this until this point in case more than 1 user is accessing
         -- the journal
         prui_reorder_journal_lines(journal_id, ent_proc_group, status);

         -- Execute any custom processes
         pgui_jrnl_custom.prui_post_journal(journal_id);

         -- Before posting create any reversal journals
   -- TTP 775 -New journal types BDBR and MDRV included in condition
         IF gJournalHeader.jhu_jrnl_type IN (gJOURNAL_TYPE_MDREV, gJOURNAL_TYPE_MMREV, gJOURNAL_TYPE_MDAYR, gJOURNAL_TYPE_BREV, gJOURNAL_TYPE_BDBR, gJOURNAL_TYPE_MDRV)THEN

            IF gJournalHeader.jhu_jrnl_type IN (gJOURNAL_TYPE_MDREV, gJOURNAL_TYPE_MMREV, gJOURNAL_TYPE_MDAYR, gJOURNAL_TYPE_BREV) THEN

               BEGIN
                     SELECT MIN(ed_date)
                     INTO lvReversingDate
                     FROM SLR_ENTITY_DAYS
                     WHERE ed_date      > gJournalHeader.jhu_jrnl_date
                     AND ed_entity_set = gEntityConfiguration.ent_periods_and_days_set
                     AND ed_status   = 'O';
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    prui_log_error(journal_id, 0, 9999, 'Unable to reversing date for journal');
                    RAISE;
                 WHEN OTHERS THEN
                    pr_error(1, SQLERRM, 0, 'prui_post_to_sub_ledger', 'slr_entity_periods', NULL, NULL, gPackageName, 'PL/SQL', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
                    RAISE;
               END;

            END IF;

      -- TTP 775 - New reversing date lookup to fit new journal types BDBR and MDRV
             IF gJournalHeader.jhu_jrnl_type IN (gJOURNAL_TYPE_MDRV, gJOURNAL_TYPE_BDBR) THEN

               BEGIN
                     SELECT MIN(ed_date)
                     INTO    lvReversingDate
                     FROM    SLR_ENTITY_DAYS
                     WHERE    ed_date      > gJournalHeader.jhu_jrnl_date
                     AND    ed_entity_set = gEntityConfiguration.ent_periods_and_days_set
                     AND    ed_status      = 'O';
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     prui_log_error(journal_id, 0, 9999, 'Unable to reversing date for journal');
                    RAISE;
                 WHEN OTHERS THEN
                     pr_error(1, SQLERRM, 0, 'prui_post_to_sub_ledger', 'slr_entity_periods', NULL, NULL, gPackageName, 'PL/SQL', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
                     RAISE;
               END;

            END IF;

            IF NOT fnui_create_reversing_journal(journal_id, lvReversingDate, ent_proc_group, status) THEN
               prui_log_error(journal_id, 0, 9999, 'Unable to create reversing journal for journal '||TO_CHAR(journal_id));
               RETURN;
            END IF;

         END IF;

         -- Do Sub Ledger posting if journal is effective from today or earlier
         IF TRUNC(gJournalHeader.jhu_jrnl_date) <= TRUNC(gEntityConfiguration.ent_business_date) THEN

            -- Set the flag used for Generating Last Balances for the current Bussiness date
            syn_ui_post_journals_pkg.pStatusGenLastBalForBD(gvSubLedgerGenLastBalForBD);


   syn_ui_post_journals_pkg.pPostJournals(ent_proc_group, pProcessId, status, TRUE);
         ELSE

            -- Set journal to U (will wait for effective date to be reached
            prui_set_status(journal_id, gSTATUS_WAITING);

         END IF;

    END prui_post_to_sub_ledger; */

   --********************************************************************************



   PROCEDURE prui_reject_journals (
      session_id           IN     VARCHAR2,
      journal_id_list      IN     VARCHAR2,
      reason_description   IN     VARCHAR2,
      updated_by           IN     SLR_JRNL_HEADERS.JH_AMENDED_BY%TYPE,
      success                 OUT CHAR,
      failed_jrnl_list        OUT VARCHAR2)
   IS
      loop_count              NUMBER;
      journal_list            array_list := array_list ();
      list_count              NUMBER;
      journal_list_in_error   VARCHAR2 (32700) := NULL;
      lv_success              CHAR (1);
      lv_failed_count         NUMBER (5) := 0;
      lv_journal_id           NUMBER (12, 0);
      lv_journal_version      NUMBER (5, 0);
   BEGIN
      success := 'S';
      gSessionId := session_id;

      prui_process_param_list (journal_id_list, journal_list, list_count);

      FOR loop_count IN 1 .. list_count
      LOOP
         lv_journal_id :=
            SUBSTR (journal_list (loop_count),
                    0,
                    INSTR (journal_list (loop_count), '~') - 1);
         lv_journal_version :=
            SUBSTR (journal_list (loop_count),
                    INSTR (journal_list (loop_count), '~') + 1);

         prui_reject_journal (gSessionId,
                              lv_journal_id,
                              reason_description,
                              updated_by,
                              lv_journal_version,
                              lv_success);

         IF lv_success <> 'S'
         THEN
            lv_failed_count := lv_failed_count + 1;

            IF journal_list_in_error IS NOT NULL
            THEN
               journal_list_in_error :=
                  journal_list_in_error || ',' || TO_CHAR (lv_journal_id);
            ELSE
               journal_list_in_error := TO_CHAR (lv_journal_id);
            END IF;
         END IF;
      END LOOP;

      IF lv_failed_count = 0
      THEN
         success := 'S';
      ELSIF lv_failed_count < list_count
      THEN
         success := 'P';
      ELSE
         success := 'F';
      END IF;

      failed_jrnl_list := journal_list_in_error;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_reject_journals',
                   'gui_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         success := 'F';
   END prui_reject_journals;

   PROCEDURE prui_reject_journal (
      session_id           IN     VARCHAR2,
      journal_id           IN     NUMBER,
      reason_description   IN     VARCHAR2,
      updated_by           IN     SLR_JRNL_HEADERS.JH_AMENDED_BY%TYPE,
      journal_version      IN     gui_jrnl_headers_unposted.jhu_version%TYPE,
      success                 OUT CHAR)
   IS
   BEGIN
      success := 'S';

      IF session_id IS NULL
      THEN
         raise_application_error (-20101, 'Missing session id.');
      END IF;

      IF journal_version IS NULL
      THEN
         raise_application_error (-20102, 'Missing journal version.');
      END IF;

      gSessionId := session_id;
      gJournalVersion := journal_version;

      BEGIN
         /* lock journal so only one user can edit it. Procedure commits changes, signals journal_locked_exeption if journal already locked */
         prui_lock_journal (journal_id, updated_by);

         /* check journal version in case there were any changes since journal was displayed on the screen. Signals stale_journal_exception if journal version is different*/
         prui_check_journal_version (journal_id, gJournalVersion);
      EXCEPTION
         WHEN journal_locked_exeption
         THEN
            prui_log_error (
               journal_id,
               0,
               6699,
               'Journal is already locked by another user. Cannot proceed.');
            success := 'L';
            RETURN;
         WHEN stale_journal_exception
         THEN
            prui_log_error (
               journal_id,
               0,
               6698,
               'Journal does not exist or was modified by another user. Cannot proceed.');

            /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
            prui_unlock_journal (journal_id, updated_by);
            success := 'V';
            RETURN;
         WHEN OTHERS
         THEN
            RAISE;
      END;

      UPDATE gui_jrnl_headers_unposted
         SET jhu_amended_by = updated_by, jhu_amended_on = SYSDATE
       WHERE jhu_jrnl_id = journal_id;

      prui_clear_errors (journal_id);
      prui_log_error (journal_id,
                      0,
                      1040,
                      'Journal rejected: ' || reason_description);
      prui_set_status (journal_id, gSTATUS_REJECT);

      -- Persist errors in database
      prui_write_errors_to_database (journal_id);

      -- Execute any custom processes
      pgui_jrnl_custom.prui_reject_journal (journal_id);

      /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
      prui_unlock_journal (journal_id, updated_by);

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_reject_journal',
                   'gui_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);

         /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
         prui_unlock_journal (journal_id, updated_by);
         success := 'F';
   END;

   --********************************************************************************

   -- For use with R2 code base
   PROCEDURE prui_get_journal_errors (
      session_id    IN     VARCHAR2,
      journal_id    IN     SLR_JRNL_HEADERS.JH_JRNL_ID%TYPE,
      line_number   IN     SLR_JRNL_LINES.JL_JRNL_LINE_NUMBER%TYPE,
      errorList        OUT global_ref_cursor)
   IS
   BEGIN
      gSessionId := session_id;

      OPEN errorList FOR
         SELECT *
           FROM temp_gui_jrnl_line_errors
          WHERE     jle_jrnl_hdr_id = journal_id
                AND user_session_id = gSessionId
                AND jle_jrnl_line_number = line_number;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN;
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_get_journal_errors',
                   'slr_jrnl_line_errors',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
   END prui_get_journal_errors;

   --********************************************************************************

   PROCEDURE prui_validate_journal (session_id   IN     VARCHAR2,
                                    journal_id   IN     NUMBER,
                                    user_id      IN     VARCHAR2,
                                    success         OUT CHAR)
   --errorList   OUT gJournalLineErrors )
   IS
      no_lines          NUMBER := 0;
      lvValidateState   CHAR (1);
   BEGIN
      success := 'Y';

      prui_populate_header (session_id          => session_id,
                            journal_id          => journal_id,
                            overwrite_details   => 'N');

      -- Validate journal header and each journal line
      lvValidateState := fnui_validate_journal_header;

      IF lvValidateState IN (gSTATE_CRITICAL, gSTATE_ERRORED)
      THEN
         success := 'N';
      END IF;

      -- Persist errors in database
      prui_write_errors_to_database (journal_id);

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_validate_journal',
                   'slr_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         success := 'N';
   END prui_validate_journal;

   --********************************************************************************

   /*
     Step  1: Check and fetch Entity data
     Step  2: Check and fetch Journal Type
     Step  3: Check header definitions (these are hardcoded)
     Step  4: Check Effective Date and Entity Day
     Step  5: Check Entity Period
     Step  6: Check Month End Limits
   */
   FUNCTION fnui_validate_journal_header
      RETURN CHAR
   IS
      lvSuccess   CHAR;
      lvCount     NUMBER;
   BEGIN
      lvSuccess := gSTATE_OK;

      IF gSessionId IS NULL
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_validate_journal_header',
                   'temp_gui_jrnl_line_errors',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         raise_application_error (-9001, 'Missing session id');
      END IF;

      --NOT USED, no point in calling
      -- Check if user can amend this journal
      --        IF NOT fnui_journal_edit_permission(gJournalHeader.jhu_created_by, gJournalHeader.jhu_amended_by) THEN
      --           RETURN gSTATE_CRITICAL;
      --        END IF;

      -- Remove previous errors from the error table
      prui_clear_errors (gJournalHeader.jhu_jrnl_id);

      IF NOT fnui_get_entity
      THEN
         lvSuccess := gSTATE_CRITICAL;
      END IF;

      IF NOT fnui_get_journal_type
      THEN
         lvSuccess := gSTATE_CRITICAL;
      END IF;

      IF NOT fnui_check_calendar
      THEN
         lvSuccess := gSTATE_CRITICAL;
      END IF;

      -- Exit if not successful at this point
      IF lvSuccess IN (gSTATE_CRITICAL)
      THEN
         prui_log_error (
            gJournalHeader.jhu_jrnl_id,
            0,
            1001,
            'Failed to initialise validation. Please check configuration');
         RETURN gSTATE_CRITICAL;
      END IF;

      -- Check mandatory fields
      IF NOT fnui_check_header_definitions
      THEN
         lvSuccess := gSTATE_CRITICAL;
      END IF;

      -- Exit if not successful at this point
      IF lvSuccess IN (gSTATE_CRITICAL)
      THEN
         prui_log_error (
            gJournalHeader.jhu_jrnl_id,
            0,
            1001,
            'Failed to complete all the checks on the journal header');
         RETURN gSTATE_CRITICAL;
      END IF;

      BEGIN
         SELECT COUNT (*)
           INTO gJournalHeader.jhu_jrnl_total_lines
           FROM temp_gui_jrnl_lines_unposted
          WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;


      IF NOT fnui_validate_header_dates
      THEN
         lvSuccess := gSTATE_ERRORED;
      END IF;

      IF NOT fnui_validate_periods
      THEN
         lvSuccess := gSTATE_ERRORED;
      END IF;

      IF NOT fnui_validate_balances
      THEN
         lvSuccess := gSTATE_ERRORED;
      END IF;

      --not used - no point in calling
      --        IF NOT fnui_check_month_end_limits THEN
      --            lvSuccess := gSTATE_ERRORED;
      --        END IF;

      IF NOT fnui_validate_jrnl_type
      THEN
         lvSuccess := gSTATE_ERRORED;
      END IF;

      --check if all journal lines (if any) belong to the same entity group
      --and whether entity group has been defined properly
      /*IF NOT fnui_check_ent_proc_group_conf THEN
       lvSuccess  := gSTATE_CRITICAL;
      END IF;*/

      -- Execute any custom validation
      IF NOT pgui_jrnl_custom.fnui_validate_header (
                gJournalHeader.jhu_jrnl_id,
                gSessionId)
      THEN
         lvSuccess := gSTATE_ERRORED;
      END IF;

      -- Validate journal lines (if there are any)
      BEGIN
         /* SELECT count(*)
         INTO   lvCount
         FROM   temp_gui_jrnl_lines_unposted
         WHERE jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
         AND user_session_id = gSessionId; */

         lvCount := gJournalHeader.jhu_jrnl_total_lines;

         IF lvCount > 0
         THEN
            IF fnui_validate_journal_line (FALSE) IN (gSTATE_CRITICAL)
            THEN
               lvSuccess := gSTATE_CRITICAL;
            END IF;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;                                                -- do nothing
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_validate_journal_header.1',
                      'gui_jrnl_headers_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
      END;

      RETURN lvSuccess;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_validate_journal_header',
                   'gui_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN gSTATE_CRITICAL;
   END fnui_validate_journal_header;

   --********************************************************************************

   /*
     This validates all lines for the journal. The validation performed is:
     Step  1: Check FAK and EBA definitions
     Step  2: Check Effective and Value Dates anD Entity Day
     Step  3: Check Entity Period
     Step  4: Check Account
     Step  5: Check Currencies
     Step  6: Check Segments
     Step  7: Check Attributes

     Note: References are not validated
   */
   FUNCTION fnui_validate_journal_line (clear_errors BOOLEAN DEFAULT TRUE)
      RETURN CHAR
   IS
      v_epg_id        SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE;
      lv_process_id   NUMBER (30) := 0;

      lvSuccess       CHAR;


      CURSOR cur_lines
      IS
         SELECT jlu_created_by, jlu_amended_by
           FROM TEMP_GUI_JRNL_LINES_UNPOSTED
          WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId;
   BEGIN
      lvSuccess := gSTATE_OK;

      FOR i IN (SELECT DISTINCT ENT.ENT_RATE_SET, ENT_PG.EPG_ID
                  FROM SLR_ENTITIES ENT, SLR_ENTITY_PROC_GROUP ENT_PG
                 WHERE ENT.ENT_ENTITY = ENT_PG.EPG_ENTITY)
      LOOP
         v_epg_id := i.epg_id;

         ----------------------------------------
         -- Set processId for whole processing
         ----------------------------------------
         SELECT SEQ_PROCESS_NUMBER.NEXTVAL INTO lv_process_id FROM DUAL;


         IF gSessionId IS NULL
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'prui_clear_errors',
                      'fnui_validate_journal_line',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            raise_application_error (-9001, 'Missing session id');
         END IF;

         --not used - no point in calling
         -- Check if user can amend this journal
         --        FOR rec IN cur_lines LOOP
         --            IF NOT fnui_journal_edit_permission(rec.jlu_created_by, rec.jlu_amended_by) THEN
         --               RETURN gSTATE_CRITICAL;
         --            END IF;
         --        END LOOP;

         -- Remove previous errors from the error table
         IF clear_errors = TRUE
         THEN
            prui_clear_errors (gJournalHeader.jhu_jrnl_id);
         END IF;

         -- Combo Edit Check
         pCombinationCheck_GJLU (v_epg_id, lv_process_id, 'M');

         IF NOT fnui_get_entity
         THEN
            lvSuccess := gSTATE_CRITICAL;
         END IF;

         IF NOT fnui_get_journal_type
         THEN
            lvSuccess := gSTATE_CRITICAL;
         END IF;

         IF NOT fnui_get_fak_definitions
         THEN
            lvSuccess := gSTATE_CRITICAL;
         END IF;

         IF NOT fnui_get_eba_definitions
         THEN
            lvSuccess := gSTATE_CRITICAL;
         END IF;

         IF NOT fnui_check_calendar
         THEN
            lvSuccess := gSTATE_CRITICAL;
         END IF;

         -- Exit if not successful at this point
         IF lvSuccess IN (gSTATE_CRITICAL)
         THEN
            prui_log_error (
               gJournalHeader.jhu_jrnl_id,
               0,
               1001,
               'Failed to initialise validation. Please check configuration');
            RETURN gSTATE_CRITICAL;
         END IF;

         -- Convert codes using coding convention
         IF NOT fnui_decode_journal_lines
         THEN
            prui_log_error (
               gJournalHeader.jhu_jrnl_id,
               0,
               1001,
               'Could not translate source system codes. Please check configuration');
            RETURN gSTATE_CRITICAL;
         END IF;


         -- Check mandatory fields
         IF NOT fnui_check_line_definitions
         THEN
            lvSuccess := gSTATE_CRITICAL;
         END IF;

         -- Exit if not successful at this point
         IF lvSuccess IN (gSTATE_CRITICAL)
         THEN
            prui_log_error (
               gJournalHeader.jhu_jrnl_id,
               0,
               1001,
               'Failed to complete all the validation checks on the journal lines');
            RETURN gSTATE_CRITICAL;
         END IF;

         -- Validate Processing Entity Group
         IF NOT fnui_check_ent_proc_group_conf
         THEN
            prui_log_error (
               gJournalHeader.jhu_jrnl_id,
               0,
               1001,
               'Failed to validate entity processing group settings. Please check configuration.');
            lvSuccess := gSTATE_ERRORED;
         END IF;

         IF NOT fnui_validate_line_dates
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         IF NOT fnui_validate_periods
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         IF NOT fnui_validate_account
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         IF NOT fnui_validate_ledger
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         IF NOT fnui_check_currencies
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         IF NOT fnui_validate_segment_n (1)
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         IF NOT fnui_validate_segment_n (2)
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         IF NOT fnui_validate_segment_n (3)
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         IF NOT fnui_validate_segment_n (4)
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         IF NOT fnui_validate_segment_n (5)
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         IF NOT fnui_validate_segment_n (6)
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         IF NOT fnui_validate_segment_n (7)
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         IF NOT fnui_validate_segment_n (8)
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         IF NOT fnui_validate_segment_n (9)
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         IF NOT fnui_validate_segment_n (10)
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         IF NOT fnui_validate_attribute_n (1)
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         IF NOT fnui_validate_attribute_n (2)
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         IF NOT fnui_validate_attribute_n (3)
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         IF NOT fnui_validate_attribute_n (4)
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         IF NOT fnui_validate_attribute_n (5)
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         -- Validate balances
         IF NOT fnui_validate_balances
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         -- Execute any custom validation
         IF NOT pgui_jrnl_custom.fnui_validate_jrnl_line (
                   gJournalHeader.jhu_jrnl_id,
                   gSessionId)
         THEN
            lvSuccess := gSTATE_ERRORED;
         END IF;

         RETURN lvSuccess;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_validate_journal_line',
                   'gui_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN gSTATE_CRITICAL;
   END fnui_validate_journal_line;

   --********************************************************************************

   PROCEDURE prui_set_status (journal_id NUMBER, status CHAR)
   IS
      STATUS_TEXT   VARCHAR2 (20) := NULL;
   BEGIN
      IF status = gSTATUS_MANUAL
      THEN
         STATUS_TEXT := 'Manual';
      END IF;

      IF status = gSTATUS_ERROR
      THEN
         STATUS_TEXT := 'Invalid';
      END IF;

      IF status = gSTATUS_AUTHORISE
      THEN
         STATUS_TEXT := 'Require Authoris.';
      END IF;

      IF status = gSTATUS_REJECT
      THEN
         STATUS_TEXT := 'Failed';
      END IF;

      IF status = gSTATUS_POSTED
      THEN
         STATUS_TEXT := 'Posted';
      END IF;

      IF status = gSTATUS_VALIDATED
      THEN
         STATUS_TEXT := 'Unposted';
      END IF;

      IF status = gSTATUS_VALIDATING
      THEN
         STATUS_TEXT := 'Validating';
      END IF;

      IF status = gSTATUS_WAITING
      THEN
         STATUS_TEXT := 'Unposted';
      END IF;

      IF status = gSTATUS_QUEUED_FOR_POSTING
      THEN
         STATUS_TEXT := 'Queued For Posting';
      END IF;

      IF status = 'E'
      THEN
         STATUS_TEXT := 'Error';
      END IF;

      UPDATE gui_jrnl_headers_unposted
         SET jhu_jrnl_status = status,
             JHU_JRNL_STATUS_TEXT = STATUS_TEXT,
             jhu_version = jhu_version + 1
       WHERE jhu_jrnl_id = journal_id;

      UPDATE gui_jrnl_lines_unposted
         SET jlu_jrnl_status = status, JLU_JRNL_STATUS_TEXT = STATUS_TEXT
       WHERE jlu_jrnl_hdr_Id = journal_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_set_status',
                   'gui_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
   END prui_set_status;

   --********************************************************************************


   FUNCTION fnui_any_errors (journal_id NUMBER)
      RETURN BOOLEAN
   IS
      lvFound   NUMBER;
   BEGIN
      -- See if there are any errors

      SELECT 1
        INTO lvFound
        FROM gui_jrnl_line_errors a, temp_gui_jrnl_line_errors b
       WHERE     (   a.jle_jrnl_hdr_id = journal_id
                  OR (    b.jle_jrnl_hdr_id = journal_id
                      AND user_session_id = gSessionId))
             AND ROWNUM < 2;


      /*SELECT  1
      INTO lvFound
      FROM gui_jrnl_line_errors
      WHERE jle_jrnl_hdr_id = journal_id
      AND  rownum < 2;*/

      -- Errors exist
      RETURN TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         --No errors exist
         RETURN FALSE;
   END fnui_any_errors;



   --********************************************************************************

   FUNCTION fnui_check_header_definitions
      RETURN BOOLEAN
   IS
      lvSuccess   BOOLEAN;
   BEGIN
      lvSuccess := TRUE;

      -- Mandatory field checks
      IF gJournalHeader.jhu_jrnl_entity IS NULL
      THEN
         prui_log_error (gJournalHeader.jhu_jrnl_id,
                         0,
                         1050,
                         'Entity is required');
         lvSuccess := FALSE;
      END IF;

      IF gJournalHeader.jhu_jrnl_description IS NULL
      THEN
         prui_log_error (gJournalHeader.jhu_jrnl_id,
                         0,
                         1050,
                         'Description is required');
         lvSuccess := FALSE;
      END IF;

      IF gJournalHeader.jhu_jrnl_date IS NULL
      THEN
         prui_log_error (gJournalHeader.jhu_jrnl_id,
                         0,
                         1050,
                         'Effective Date is required');
         lvSuccess := FALSE;
      END IF;

      IF gJournalHeader.jhu_jrnl_source IS NULL
      THEN
         prui_log_error (gJournalHeader.jhu_jrnl_id,
                         0,
                         1050,
                         'Source System is required');
         lvSuccess := FALSE;
      END IF;

      IF gJournalHeader.jhu_jrnl_type IS NULL
      THEN
         prui_log_error (gJournalHeader.jhu_jrnl_id,
                         0,
                         1050,
                         'Journal Type is required');
         lvSuccess := FALSE;
      END IF;

      -- Size checks
      IF LENGTH (gJournalHeader.jhu_jrnl_description) > 100
      THEN
         prui_log_error (gJournalHeader.jhu_jrnl_id,
                         0,
                         1060,
                         'Description is too long');
         lvSuccess := FALSE;
      END IF;

      RETURN lvSuccess;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_check_header_definitions',
                   'gui_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_check_header_definitions;

   --********************************************************************************

   FUNCTION fnui_check_line_definitions
      RETURN BOOLEAN
   IS
      lvSuccess   BOOLEAN;
      lvFound     NUMBER := NULL;
   BEGIN
      lvSuccess := TRUE;

      -- Check Entity
      INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                             user_session_id,
                                             jle_jrnl_hdr_id,
                                             jle_jrnl_line_number,
                                             jle_error_code,
                                             jle_error_string,
                                             jle_created_by,
                                             jle_created_on,
                                             jle_amended_by,
                                             jle_amended_on)
         SELECT                                      /* jle_jrnl_process_id */
               0,
                /* user_session_id */
                gSessionId,
                /* jle_jrnl_hdr_id */
                jlu_jrnl_hdr_id,
                /* jle_jrnl_line_number */
                jlu_jrnl_line_number,
                /* jle_error_code */
                'MADJ-1051',
                /* jle_error_string */
                'Entity is required.',
                /* jle_created_by */
                'SYSTEM',
                /* jle_created_on */
                SYSDATE,
                /* jle_amended_by */
                'SYSTEM',
                /* jle_amended_on */
                SYSDATE
           FROM temp_gui_jrnl_lines_unposted
          WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId
                AND jlu_entity IS NULL;

      -- Check Account
      INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                             user_session_id,
                                             jle_jrnl_hdr_id,
                                             jle_jrnl_line_number,
                                             jle_error_code,
                                             jle_error_string,
                                             jle_created_by,
                                             jle_created_on,
                                             jle_amended_by,
                                             jle_amended_on)
         SELECT                                      /* jle_jrnl_process_id */
               0,
                /* user_session_id */
                gSessionId,
                /* jle_jrnl_hdr_id */
                jlu_jrnl_hdr_id,
                /* jle_jrnl_line_number */
                jlu_jrnl_line_number,
                /* jle_error_code */
                'MADJ-1051',
                /* jle_error_string */
                'Account is required.',
                /* jle_created_by */
                'SYSTEM',
                /* jle_created_on */
                SYSDATE,
                /* jle_amended_by */
                'SYSTEM',
                /* jle_amended_on */
                SYSDATE
           FROM temp_gui_jrnl_lines_unposted
          WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId
                AND jlu_account IS NULL;

      -- Check Effective Date
      INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                             user_session_id,
                                             jle_jrnl_hdr_id,
                                             jle_jrnl_line_number,
                                             jle_error_code,
                                             jle_error_string,
                                             jle_created_by,
                                             jle_created_on,
                                             jle_amended_by,
                                             jle_amended_on)
         SELECT                                      /* jle_jrnl_process_id */
               0,
                /* user_session_id */
                gSessionId,
                /* jle_jrnl_hdr_id */
                jlu_jrnl_hdr_id,
                /* jle_jrnl_line_number */
                jlu_jrnl_line_number,
                /* jle_error_code */
                'MADJ-1051',
                /* jle_error_string */
                'Effective Date is required.',
                /* jle_created_by */
                'SYSTEM',
                /* jle_created_on */
                SYSDATE,
                /* jle_amended_by */
                'SYSTEM',
                /* jle_amended_on */
                SYSDATE
           FROM temp_gui_jrnl_lines_unposted
          WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId
                AND jlu_effective_date IS NULL;

      -- Check Value Date
      INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                             user_session_id,
                                             jle_jrnl_hdr_id,
                                             jle_jrnl_line_number,
                                             jle_error_code,
                                             jle_error_string,
                                             jle_created_by,
                                             jle_created_on,
                                             jle_amended_by,
                                             jle_amended_on)
         SELECT                                      /* jle_jrnl_process_id */
               0,
                /* user_session_id */
                gSessionId,
                /* jle_jrnl_hdr_id */
                jlu_jrnl_hdr_id,
                /* jle_jrnl_line_number */
                jlu_jrnl_line_number,
                /* jle_error_code */
                'MADJ-1051',
                /* jle_error_string */
                'Value Date is required.',
                /* jle_created_by */
                'SYSTEM',
                /* jle_created_on */
                SYSDATE,
                /* jle_amended_by */
                'SYSTEM',
                /* jle_amended_on */
                SYSDATE
           FROM temp_gui_jrnl_lines_unposted
          WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId
                AND jlu_value_date IS NULL;

      -- Check Tran Currency
      INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                             user_session_id,
                                             jle_jrnl_hdr_id,
                                             jle_jrnl_line_number,
                                             jle_error_code,
                                             jle_error_string,
                                             jle_created_by,
                                             jle_created_on,
                                             jle_amended_by,
                                             jle_amended_on)
         SELECT                                      /* jle_jrnl_process_id */
               0,
                /* user_session_id */
                gSessionId,
                /* jle_jrnl_hdr_id */
                jlu_jrnl_hdr_id,
                /* jle_jrnl_line_number */
                jlu_jrnl_line_number,
                /* jle_error_code */
                'MADJ-1051',
                /* jle_error_string */
                'Transaction Currency is required.',
                /* jle_created_by */
                'SYSTEM',
                /* jle_created_on */
                SYSDATE,
                /* jle_amended_by */
                'SYSTEM',
                /* jle_amended_on */
                SYSDATE
           FROM temp_gui_jrnl_lines_unposted
          WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId
                AND jlu_tran_ccy IS NULL;


      -- Check base Currency
      INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                             user_session_id,
                                             jle_jrnl_hdr_id,
                                             jle_jrnl_line_number,
                                             jle_error_code,
                                             jle_error_string,
                                             jle_created_by,
                                             jle_created_on,
                                             jle_amended_by,
                                             jle_amended_on)
         SELECT                                      /* jle_jrnl_process_id */
               0,
                /* user_session_id */
                gSessionId,
                /* jle_jrnl_hdr_id */
                jlu_jrnl_hdr_id,
                /* jle_jrnl_line_number */
                jlu_jrnl_line_number,
                /* jle_error_code */
                'MADJ-1051',
                /* jle_error_string */
                'Base Currency is required.',
                /* jle_created_by */
                'SYSTEM',
                /* jle_created_on */
                SYSDATE,
                /* jle_amended_by */
                'SYSTEM',
                /* jle_amended_on */
                SYSDATE
           FROM temp_gui_jrnl_lines_unposted
          WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId
                AND jlu_base_ccy IS NULL;


      -- Check local Currency
      INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                             user_session_id,
                                             jle_jrnl_hdr_id,
                                             jle_jrnl_line_number,
                                             jle_error_code,
                                             jle_error_string,
                                             jle_created_by,
                                             jle_created_on,
                                             jle_amended_by,
                                             jle_amended_on)
         SELECT                                      /* jle_jrnl_process_id */
               0,
                /* user_session_id */
                gSessionId,
                /* jle_jrnl_hdr_id */
                jlu_jrnl_hdr_id,
                /* jle_jrnl_line_number */
                jlu_jrnl_line_number,
                /* jle_error_code */
                'MADJ-1051',
                /* jle_error_string */
                'Local Currency is required.',
                /* jle_created_by */
                'SYSTEM',
                /* jle_created_on */
                SYSDATE,
                /* jle_amended_by */
                'SYSTEM',
                /* jle_amended_on */
                SYSDATE
           FROM temp_gui_jrnl_lines_unposted
          WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId
                AND jlu_local_ccy IS NULL;

      -- Check Tran Amount

      /* external ttp 796 - allow jlu_tran_amount = 0 do not check!*/

      -- Check Base Amount
      --- removed

      -- Check Local Amount
      --- removed

      -- Check FAK Segments
      IF gFAKDefinitions.fd_segment_1_type = 'M'
      THEN
         INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                user_session_id,
                                                jle_jrnl_hdr_id,
                                                jle_jrnl_line_number,
                                                jle_error_code,
                                                jle_error_string,
                                                jle_created_by,
                                                jle_created_on,
                                                jle_amended_by,
                                                jle_amended_on)
            SELECT                                   /* jle_jrnl_process_id */
                  0,
                   /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jle_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jle_error_code */
                   'MADJ-1051',
                   /* jle_error_string */
                   gFAKDefinitions.fd_segment_1_name || ' is required.',
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE
              FROM temp_gui_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND user_session_id = gSessionId
                   AND jlu_segment_1 IS NULL;
      END IF;

      IF gFAKDefinitions.fd_segment_2_type = 'M'
      THEN
         INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                user_session_id,
                                                jle_jrnl_hdr_id,
                                                jle_jrnl_line_number,
                                                jle_error_code,
                                                jle_error_string,
                                                jle_created_by,
                                                jle_created_on,
                                                jle_amended_by,
                                                jle_amended_on)
            SELECT                                   /* jle_jrnl_process_id */
                  0,
                   /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jle_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jle_error_code */
                   'MADJ-1051',
                   /* jle_error_string */
                   gFAKDefinitions.fd_segment_2_name || ' is required.',
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE
              FROM temp_gui_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND user_session_id = gSessionId
                   AND jlu_segment_2 IS NULL;
      END IF;

      IF gFAKDefinitions.fd_segment_3_type = 'M'
      THEN
         INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                user_session_id,
                                                jle_jrnl_hdr_id,
                                                jle_jrnl_line_number,
                                                jle_error_code,
                                                jle_error_string,
                                                jle_created_by,
                                                jle_created_on,
                                                jle_amended_by,
                                                jle_amended_on)
            SELECT                                   /* jle_jrnl_process_id */
                  0,
                   /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jle_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jle_error_code */
                   'MADJ-1051',
                   /* jle_error_string */
                   gFAKDefinitions.fd_segment_3_name || ' is required.',
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE
              FROM temp_gui_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND user_session_id = gSessionId
                   AND jlu_segment_3 IS NULL;
      END IF;

      IF gFAKDefinitions.fd_segment_4_type = 'M'
      THEN
         INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                user_session_id,
                                                jle_jrnl_hdr_id,
                                                jle_jrnl_line_number,
                                                jle_error_code,
                                                jle_error_string,
                                                jle_created_by,
                                                jle_created_on,
                                                jle_amended_by,
                                                jle_amended_on)
            SELECT                                   /* jle_jrnl_process_id */
                  0,
                   /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jle_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jle_error_code */
                   'MADJ-1051',
                   /* jle_error_string */
                   gFAKDefinitions.fd_segment_4_name || ' is required.',
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE
              FROM temp_gui_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND user_session_id = gSessionId
                   AND jlu_segment_4 IS NULL;
      END IF;

      IF gFAKDefinitions.fd_segment_5_type = 'M'
      THEN
         INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                user_session_id,
                                                jle_jrnl_hdr_id,
                                                jle_jrnl_line_number,
                                                jle_error_code,
                                                jle_error_string,
                                                jle_created_by,
                                                jle_created_on,
                                                jle_amended_by,
                                                jle_amended_on)
            SELECT                                   /* jle_jrnl_process_id */
                  0,
                   /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jle_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jle_error_code */
                   'MADJ-1051',
                   /* jle_error_string */
                   gFAKDefinitions.fd_segment_5_name || ' is required.',
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE
              FROM temp_gui_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND user_session_id = gSessionId
                   AND jlu_segment_5 IS NULL;
      END IF;

      IF gFAKDefinitions.fd_segment_6_type = 'M'
      THEN
         INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                user_session_id,
                                                jle_jrnl_hdr_id,
                                                jle_jrnl_line_number,
                                                jle_error_code,
                                                jle_error_string,
                                                jle_created_by,
                                                jle_created_on,
                                                jle_amended_by,
                                                jle_amended_on)
            SELECT                                   /* jle_jrnl_process_id */
                  0,
                   /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jle_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jle_error_code */
                   'MADJ-1051',
                   /* jle_error_string */
                   gFAKDefinitions.fd_segment_6_name || ' is required.',
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE
              FROM temp_gui_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND user_session_id = gSessionId
                   AND jlu_segment_6 IS NULL;
      END IF;

      IF gFAKDefinitions.fd_segment_7_type = 'M'
      THEN
         INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                user_session_id,
                                                jle_jrnl_hdr_id,
                                                jle_jrnl_line_number,
                                                jle_error_code,
                                                jle_error_string,
                                                jle_created_by,
                                                jle_created_on,
                                                jle_amended_by,
                                                jle_amended_on)
            SELECT                                   /* jle_jrnl_process_id */
                  0,
                   /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jle_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jle_error_code */
                   'MADJ-1051',
                   /* jle_error_string */
                   gFAKDefinitions.fd_segment_7_name || ' is required.',
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE
              FROM temp_gui_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND user_session_id = gSessionId
                   AND jlu_segment_7 IS NULL;
      END IF;

      IF gFAKDefinitions.fd_segment_8_type = 'M'
      THEN
         INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                user_session_id,
                                                jle_jrnl_hdr_id,
                                                jle_jrnl_line_number,
                                                jle_error_code,
                                                jle_error_string,
                                                jle_created_by,
                                                jle_created_on,
                                                jle_amended_by,
                                                jle_amended_on)
            SELECT                                   /* jle_jrnl_process_id */
                  0,
                   /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jle_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jle_error_code */
                   'MADJ-1051',
                   /* jle_error_string */
                   gFAKDefinitions.fd_segment_8_name || ' is required.',
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE
              FROM temp_gui_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND user_session_id = gSessionId
                   AND jlu_segment_8 IS NULL;
      END IF;

      IF gFAKDefinitions.fd_segment_9_type = 'M'
      THEN
         INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                user_session_id,
                                                jle_jrnl_hdr_id,
                                                jle_jrnl_line_number,
                                                jle_error_code,
                                                jle_error_string,
                                                jle_created_by,
                                                jle_created_on,
                                                jle_amended_by,
                                                jle_amended_on)
            SELECT                                   /* jle_jrnl_process_id */
                  0,
                   /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jle_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jle_error_code */
                   'MADJ-1051',
                   /* jle_error_string */
                   gFAKDefinitions.fd_segment_9_name || ' is required.',
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE
              FROM temp_gui_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND user_session_id = gSessionId
                   AND jlu_segment_9 IS NULL;
      END IF;

      IF gFAKDefinitions.fd_segment_10_type = 'M'
      THEN
         INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                user_session_id,
                                                jle_jrnl_hdr_id,
                                                jle_jrnl_line_number,
                                                jle_error_code,
                                                jle_error_string,
                                                jle_created_by,
                                                jle_created_on,
                                                jle_amended_by,
                                                jle_amended_on)
            SELECT                                   /* jle_jrnl_process_id */
                  0,
                   /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jle_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jle_error_code */
                   'MADJ-1051',
                   /* jle_error_string */
                   gFAKDefinitions.fd_segment_10_name || ' is required.',
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE
              FROM temp_gui_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND user_session_id = gSessionId
                   AND jlu_segment_10 IS NULL;
      END IF;

      /*
          TODO: Add checks for attributes

          This is not possible until R1.2
      */

      INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                             user_session_id,
                                             jle_jrnl_hdr_id,
                                             jle_jrnl_line_number,
                                             jle_error_code,
                                             jle_error_string,
                                             jle_created_by,
                                             jle_created_on,
                                             jle_amended_by,
                                             jle_amended_on)
         SELECT                                      /* jle_jrnl_process_id */
               0,
                /* user_session_id */
                gSessionId,
                /* jle_jrnl_hdr_id */
                jlu_jrnl_hdr_id,
                /* jle_jrnl_line_number */
                jlu_jrnl_line_number,
                /* jle_error_code */
                'MADJ-1061',
                /* jle_error_string */
                'Description is required',
                /* jle_created_by */
                'SYSTEM',
                /* jle_created_on */
                SYSDATE,
                /* jle_amended_by */
                'SYSTEM',
                /* jle_amended_on */
                SYSDATE
           FROM temp_gui_jrnl_lines_unposted
          WHERE        jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND user_session_id = gSessionId
                   AND jlu_description IS NULL
                OR LENGTH (jlu_description) = 0;

      -- Size checks
      INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                             user_session_id,
                                             jle_jrnl_hdr_id,
                                             jle_jrnl_line_number,
                                             jle_error_code,
                                             jle_error_string,
                                             jle_created_by,
                                             jle_created_on,
                                             jle_amended_by,
                                             jle_amended_on)
         SELECT                                      /* jle_jrnl_process_id */
               0,
                /* user_session_id */
                gSessionId,
                /* jle_jrnl_hdr_id */
                jlu_jrnl_hdr_id,
                /* jle_jrnl_line_number */
                jlu_jrnl_line_number,
                /* jle_error_code */
                'MADJ-1061',
                /* jle_error_string */
                'Description is too long',
                /* jle_created_by */
                'SYSTEM',
                /* jle_created_on */
                SYSDATE,
                /* jle_amended_by */
                'SYSTEM',
                /* jle_amended_on */
                SYSDATE
           FROM temp_gui_jrnl_lines_unposted
          WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId
                AND LENGTH (jlu_description) > 100;

      --How many errors were found
      BEGIN
         SELECT COUNT (*)
           INTO lvFound
           FROM temp_gui_jrnl_line_errors
          WHERE     jle_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId
                AND jle_error_code IN ('MADJ-1051', 'MADJ-1061');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;                                                -- do nothing
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_check_line_definitions.1',
                      'temp_gui_jrnl_line_errors',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
      END;

      IF lvFound > 0
      THEN
         lvSuccess := FALSE;
      END IF;

      RETURN lvSuccess;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_check_line_definitions',
                   'gui_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_check_line_definitions;

   --********************************************************************************

   FUNCTION fnui_validate_header_dates
      RETURN BOOLEAN
   IS
      lvFound                    NUMBER;
      lvSuccess                  BOOLEAN;
      vCounter                   NUMBER;

      lvPeriodStartDate          DATE;
      lvPeriodEndDate            DATE;
      lvPrevBusDate              DATE;
      lvNextBusDate              DATE;
      lvNextPeriodEndDate        DATE;
      lvPrevPeriodEndDate        DATE;
      lvPrevPeriodStartDate      DATE;
      v_jhu_jrnl_id              DECIMAL (10, 0);
      v_jhu_jrnl_type            VARCHAR (40);
      v_jhu_jrnl_entity          VARCHAR (20);
      v_entity_code              VARCHAR (20);
      v_ent_periods_and_days_    VARCHAR (20);
      v_ent_business_date        DATE;
      v_ent_next_business_date   DATE;
      vFDRBusinessDate           DATE;
      -- o_lvSuccess decimal(1, 0);
      v_prior_next_both          VARCHAR (1);
      v_period_day               VARCHAR (1);
      v_compare_date             DATE;
      v_compare_start_date       DATE;
      v_compare_end_date         DATE;
      v_rul_typ                  VARCHAR (30);
      lvNextPeriodStartDate      DATE;
      v_err_msg                  VARCHAR (100);
      v_rev_rul_typ              VARCHAR (30);
      v_rev_prior_next_both      VARCHAR (1);
      v_rev_period_day           VARCHAR (1);
      v_rev_err_msg              VARCHAR (100);
      v_ejt_jt_type              VARCHAR (12);
      v_rev_compare_date         DATE;
      v_rev_compare_start_date   DATE;
      v_rev_compare_end_date     DATE;
      v_rev_validation_flag      CHAR (1);
   BEGIN
      lvSuccess := TRUE;

      -- Check effective date is valid
      BEGIN
         SELECT 1
           INTO lvFound
           FROM slr_entity_days
          WHERE     ed_entity_set =
                       gEntityConfiguration.ent_periods_and_days_set
                AND ed_date = gJournalHeader.jhu_jrnl_date
                --and  ed_balance_type = 50
                AND ed_status = 'O';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            prui_log_error (gJournalHeader.jhu_jrnl_id,
                            0,
                            9999,
                            'Effective Date is not a valid business date');
            lvSuccess := FALSE;
         WHEN OTHERS
         THEN
            RETURN FALSE;
      END;

      BEGIN
         SELECT COUNT (GP_TODAYS_BUS_DATE)
           INTO vCounter
           FROM FDR.FR_LPG_CONFIG
                LEFT JOIN FDR.FR_GLOBAL_PARAMETER ON LC_LPG_ID = LPG_ID
          WHERE LC_GRP_CODE = gJournalHeader.jhu_jrnl_entity;

         IF vCounter > 0
         THEN
            SELECT GP_TODAYS_BUS_DATE
              INTO vFDRBusinessDate
              FROM FDR.FR_LPG_CONFIG
                   LEFT JOIN FDR.FR_GLOBAL_PARAMETER ON LC_LPG_ID = LPG_ID
             WHERE LC_GRP_CODE = gJournalHeader.jhu_jrnl_entity;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN FALSE;
      END;

      SELECT COALESCE (par.pl_party_legal_clicode, head.jhu_jrnl_entity),
             rul.ejtr_type,
             rul.ejtr_prior_next_current,
             rul.ejtr_period_date,
             mes.EM_ERROR_MESSAGE,
             rev_rul.ejtr_type,
             rev_rul.ejtr_prior_next_current,
             rev_rul.ejtr_period_date,
             ext.ejt_rev_validation_flag,
             rev_mes.EM_ERROR_MESSAGE,
             ext.ejt_jt_type
        INTO v_entity_code,
             v_rul_typ,
             v_prior_next_both,
             v_period_day,
             v_err_msg,
             v_rev_rul_typ,
             v_rev_prior_next_both,
             v_rev_period_day,
             v_rev_validation_flag,
             v_rev_err_msg,
             v_ejt_jt_type
        FROM temp_gui_jrnl_headers_unposted head
             LEFT OUTER JOIN fdr.FR_PARTY_LEGAL par
                ON (head.jhu_jrnl_entity = par.pl_party_legal_id)
             JOIN slr.SLR_EXT_JRNL_TYPES ext
                ON (ext.ejt_type = head.jhu_jrnl_type)
             JOIN slr.SLR_EXT_JRNL_TYPE_RULE rul
                ON (rul.ejtr_code = ext.ejt_eff_ejtr_code)
             JOIN slr.SLR_EXT_JRNL_TYPE_RULE rev_rul
                ON (rev_rul.ejtr_code = ext.ejt_rev_ejtr_code)
             JOIN slr.SLR_ERROR_MESSAGE mes
                ON (mes.EM_ERROR_CODE = rul.ejtr_em_error_code)
             JOIN slr.SLR_ERROR_MESSAGE rev_mes
                ON (rev_mes.EM_ERROR_CODE = rev_rul.ejtr_em_error_code)
       WHERE     jhu_jrnl_id = gJournalHeader.jhu_jrnl_id
             AND user_session_id = gSessionId;

      -- Get the calendar details for the current business date
      prui_get_calendar_details (
         gEntityConfiguration.ent_business_date,
         gEntityConfiguration.ent_periods_and_days_set,
         gJournalHeader.jhu_jrnl_entity,
         lvPrevPeriodStartDate,
         lvPrevPeriodEndDate,
         lvPeriodStartDate,
         lvPrevBusDate,
         lvNextBusDate,
         lvPeriodEndDate,
         lvNextPeriodEndDate,
         lvNextPeriodStartDate);

      -- Check that calendar details are present
      IF    lvPeriodStartDate IS NULL
         OR lvPeriodEndDate IS NULL
         OR lvPrevBusDate IS NULL
         OR lvNextBusDate IS NULL
         OR lvNextPeriodEndDate IS NULL
         OR lvPrevPeriodEndDate IS NULL
         OR lvNextPeriodStartDate IS NULL
      THEN
         prui_log_error (
            gJournalHeader.jhu_jrnl_id,
            0,
            9999,
            'No Entity Period data for current business date. Cannot check Effective Date');
         RETURN FALSE;
      END IF;

      -- Check rules for effective date and journal type


      v_err_msg := REPLACE (v_err_msg, '%1', 'Effective date');
      v_err_msg := REPLACE (v_err_msg, '%2', 'current business day');


      IF v_prior_next_both IS NOT NULL AND v_period_day IS NOT NULL
      THEN
         IF v_prior_next_both = 'P'
         THEN
            v_compare_start_date := lvPrevPeriodStartDate;
            v_compare_end_date := lvPrevPeriodEndDate;
         ELSIF v_prior_next_both = 'C'
         THEN
            v_compare_start_date := lvPeriodStartDate;
            v_compare_end_date := lvPeriodEndDate;
         ELSIF v_prior_next_both = 'N'
         THEN
            v_compare_end_date := lvNextPeriodEndDate;
         END IF;

         IF v_period_day = 'S'
         THEN
            IF     v_rul_typ = '='
               AND gJournalHeader.jhu_jrnl_date <> v_compare_start_date
            THEN
               prui_log_error (gJournalHeader.jhu_jrnl_id,
                               0,
                               9999,
                               v_err_msg);
               lvSuccess := FALSE;
            ELSIF     v_rul_typ = '>'
                  AND gJournalHeader.jhu_jrnl_date <= v_compare_start_date
            THEN
               prui_log_error (gJournalHeader.jhu_jrnl_id,
                               0,
                               9999,
                               v_err_msg);
               lvSuccess := FALSE;
            ELSIF     v_rul_typ = '<'
                  AND gJournalHeader.jhu_jrnl_date >= v_compare_start_date
            THEN
               prui_log_error (gJournalHeader.jhu_jrnl_id,
                               0,
                               9999,
                               v_err_msg);
               lvSuccess := FALSE;
            END IF;
         ELSIF v_period_day = 'E'
         THEN
            IF     v_rul_typ = '='
               AND gJournalHeader.jhu_jrnl_date <> v_compare_end_date
            THEN
               prui_log_error (gJournalHeader.jhu_jrnl_id,
                               0,
                               9999,
                               v_err_msg);
               lvSuccess := FALSE;
            ELSIF     v_rul_typ = '>'
                  AND gJournalHeader.jhu_jrnl_date <= v_compare_end_date
            THEN
               prui_log_error (gJournalHeader.jhu_jrnl_id,
                               0,
                               9999,
                               v_err_msg);
               lvSuccess := FALSE;
            ELSIF     v_rul_typ = '<'
                  AND gJournalHeader.jhu_jrnl_date >= v_compare_end_date
            THEN
               prui_log_error (gJournalHeader.jhu_jrnl_id,
                               0,
                               9999,
                               v_err_msg);
               lvSuccess := FALSE;
            END IF;
         ELSIF v_period_day = 'B'
         THEN
            IF     v_rul_typ = 'BETWEEN'
               AND NOT gJournalHeader.jhu_jrnl_date BETWEEN v_compare_start_date
                                                        AND v_compare_end_date
            THEN
               prui_log_error (gJournalHeader.jhu_jrnl_id,
                               0,
                               9999,
                               v_err_msg);
               lvSuccess := FALSE;
            END IF;
         END IF;
      ELSIF v_prior_next_both IS NOT NULL AND v_period_day IS NULL
      THEN
         IF v_prior_next_both = 'P'
         THEN
            v_compare_date := lvPrevBusDate;

            IF     v_rul_typ = '='
               AND gJournalHeader.jhu_jrnl_date <> v_compare_date
            THEN
               prui_log_error (gJournalHeader.jhu_jrnl_id,
                               0,
                               9999,
                               v_err_msg);
               lvSuccess := FALSE;
            ELSIF     v_rul_typ = '>'
                  AND gJournalHeader.jhu_jrnl_date <= v_compare_date
            THEN
               prui_log_error (gJournalHeader.jhu_jrnl_id,
                               0,
                               9999,
                               v_err_msg);
               lvSuccess := FALSE;
            ELSIF     v_rul_typ = '<'
                  AND gJournalHeader.jhu_jrnl_date >= v_compare_date
            THEN
               prui_log_error (gJournalHeader.jhu_jrnl_id,
                               0,
                               9999,
                               v_err_msg);
               lvSuccess := FALSE;
            END IF;
         ELSIF v_prior_next_both = 'C'
         THEN
            v_compare_date := gEntityConfiguration.ent_business_date;

            IF     v_rul_typ = '='
               AND gJournalHeader.jhu_jrnl_date <> v_compare_date
            THEN
               prui_log_error (gJournalHeader.jhu_jrnl_id,
                               0,
                               9999,
                               v_err_msg);
               lvSuccess := FALSE;
            ELSIF     v_rul_typ = '>'
                  AND gJournalHeader.jhu_jrnl_date <= v_compare_date
            THEN
               prui_log_error (gJournalHeader.jhu_jrnl_id,
                               0,
                               9999,
                               v_err_msg);
               lvSuccess := FALSE;
            ELSIF     v_rul_typ = '<'
                  AND gJournalHeader.jhu_jrnl_date >= v_compare_date
            THEN
               prui_log_error (gJournalHeader.jhu_jrnl_id,
                               0,
                               9999,
                               v_err_msg);
               lvSuccess := FALSE;
            END IF;
         ELSIF v_prior_next_both = 'N'
         THEN
            v_compare_date := lvNextBusDate;

            IF     v_rul_typ = '='
               AND gJournalHeader.jhu_jrnl_date <> v_compare_date
            THEN
               prui_log_error (gJournalHeader.jhu_jrnl_id,
                               0,
                               9999,
                               v_err_msg);
               lvSuccess := FALSE;
            ELSIF     v_rul_typ = '>'
                  AND gJournalHeader.jhu_jrnl_date <= v_compare_date
            THEN
               prui_log_error (gJournalHeader.jhu_jrnl_id,
                               0,
                               9999,
                               v_err_msg);
               lvSuccess := FALSE;
            ELSIF     v_rul_typ = '<'
                  AND gJournalHeader.jhu_jrnl_date >= v_compare_date
            THEN
               prui_log_error (gJournalHeader.jhu_jrnl_id,
                               0,
                               9999,
                               v_err_msg);
               lvSuccess := FALSE;
            END IF;
         END IF;
      ELSE
         v_compare_date := gEntityConfiguration.ent_business_date;

         IF     v_rul_typ = '='
            AND gJournalHeader.jhu_jrnl_date <> v_compare_date
         THEN
            prui_log_error (gJournalHeader.jhu_jrnl_id,
                            0,
                            9999,
                            v_err_msg);
            lvSuccess := FALSE;
         ELSIF     v_rul_typ = '>'
               AND gJournalHeader.jhu_jrnl_date <= v_compare_date
         THEN
            prui_log_error (gJournalHeader.jhu_jrnl_id,
                            0,
                            9999,
                            v_err_msg);
            lvSuccess := FALSE;
         ELSIF     v_rul_typ = '<'
               AND gJournalHeader.jhu_jrnl_date >= v_compare_date
         THEN
            prui_log_error (gJournalHeader.jhu_jrnl_id,
                            0,
                            9999,
                            v_err_msg);
            lvSuccess := FALSE;
         END IF;
      END IF;


      lvPrevPeriodStartDate := NULL;
      lvPrevPeriodEndDate := NULL;
      lvPeriodStartDate := NULL;
      lvPrevBusDate := NULL;
      lvNextBusDate := NULL;
      lvPeriodEndDate := NULL;
      lvNextPeriodEndDate := NULL;
      lvNextPeriodStartDate := NULL;

      IF lvSuccess = TRUE
      THEN
         prui_get_calendar_details (
            gJournalHeader.jhu_jrnl_date,
            gEntityConfiguration.ent_periods_and_days_set,
            gJournalHeader.jhu_jrnl_entity,
            lvPrevPeriodStartDate,
            lvPrevPeriodEndDate,
            lvPeriodStartDate,
            lvPrevBusDate,
            lvNextBusDate,
            lvPeriodEndDate,
            lvNextPeriodEndDate,
            lvNextPeriodStartDate);

         v_rev_err_msg := REPLACE (v_rev_err_msg, '%1', 'Reversing date');
         v_rev_err_msg :=
            REPLACE (v_rev_err_msg, '%2', 'current business day');

         IF (v_ejt_jt_type = 'Reversing')
         THEN
            -- check Reversing Date is valid

            BEGIN
               SELECT 1
                 INTO lvFound
                 FROM slr_entity_days
                WHERE     ed_entity_set =
                             gEntityConfiguration.ent_periods_and_days_set
                      AND ed_date = gJournalHeader.jhu_jrnl_rev_date
                      AND ed_status = 'O';
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  prui_log_error (
                     gJournalHeader.jhu_jrnl_id,
                     0,
                     9999,
                     'Reversing Date is not a valid business date');
                  lvSuccess := FALSE;
               WHEN OTHERS
               THEN
                  RETURN FALSE;
            END;



            IF (    v_rev_validation_flag = 'Y'
                AND gJournalHeader.jhu_jrnl_rev_date IS NOT NULL)
            THEN
               IF     v_rev_prior_next_both IS NOT NULL
                  AND v_rev_period_day IS NOT NULL
               THEN
                  IF v_rev_prior_next_both = 'P'
                  THEN
                     v_rev_compare_start_date := lvPrevPeriodStartDate;
                     v_rev_compare_end_date := lvPrevPeriodEndDate;
                  ELSIF v_rev_prior_next_both = 'C'
                  THEN
                     v_rev_compare_start_date := lvPeriodStartDate;
                     v_rev_compare_end_date := lvPeriodEndDate;
                  ELSIF v_rev_prior_next_both = 'N'
                  THEN
                     v_rev_compare_start_date := lvNextPeriodStartDate;
                     v_rev_compare_end_date := lvNextPeriodEndDate;
                  END IF;

                  IF v_rev_period_day = 'S'
                  THEN
                     IF     v_rev_rul_typ = '='
                        AND gJournalHeader.jhu_jrnl_rev_date <>
                               v_rev_compare_start_date
                     THEN
                        prui_log_error (gJournalHeader.jhu_jrnl_id,
                                        0,
                                        9999,
                                        v_rev_err_msg);
                        lvSuccess := FALSE;
                     ELSIF     v_rev_rul_typ = '>'
                           AND gJournalHeader.jhu_jrnl_rev_date <=
                                  v_rev_compare_start_date
                     THEN
                        prui_log_error (gJournalHeader.jhu_jrnl_id,
                                        0,
                                        9999,
                                        v_rev_err_msg);
                        lvSuccess := FALSE;
                     ELSIF     v_rev_rul_typ = '<'
                           AND gJournalHeader.jhu_jrnl_rev_date >=
                                  v_rev_compare_start_date
                     THEN
                        prui_log_error (gJournalHeader.jhu_jrnl_id,
                                        0,
                                        9999,
                                        v_rev_err_msg);
                        lvSuccess := FALSE;
                     END IF;
                  ELSIF v_rev_period_day = 'E'
                  THEN
                     IF     v_rev_rul_typ = '='
                        AND gJournalHeader.jhu_jrnl_rev_date <>
                               v_rev_compare_end_date
                     THEN
                        prui_log_error (gJournalHeader.jhu_jrnl_id,
                                        0,
                                        9999,
                                        v_rev_err_msg);
                        lvSuccess := FALSE;
                     ELSIF     v_rev_rul_typ = '>'
                           AND gJournalHeader.jhu_jrnl_rev_date <=
                                  v_rev_compare_end_date
                     THEN
                        prui_log_error (gJournalHeader.jhu_jrnl_id,
                                        0,
                                        9999,
                                        v_rev_err_msg);
                        lvSuccess := FALSE;
                     ELSIF     v_rev_rul_typ = '<'
                           AND gJournalHeader.jhu_jrnl_rev_date >=
                                  v_rev_compare_end_date
                     THEN
                        prui_log_error (gJournalHeader.jhu_jrnl_id,
                                        0,
                                        9999,
                                        v_rev_err_msg);
                        lvSuccess := FALSE;
                     END IF;
                  ELSIF v_rev_period_day = 'B'
                  THEN
                     IF     v_rev_rul_typ = 'BETWEEN'
                        AND NOT gJournalHeader.jhu_jrnl_rev_date BETWEEN v_rev_compare_start_date
                                                                     AND v_rev_compare_end_date
                     THEN
                        prui_log_error (gJournalHeader.jhu_jrnl_id,
                                        0,
                                        9999,
                                        v_rev_err_msg);
                        lvSuccess := FALSE;
                     END IF;
                  END IF;
               ELSIF     v_rev_prior_next_both IS NOT NULL
                     AND v_rev_period_day IS NULL
               THEN
                  IF v_rev_prior_next_both = 'P'
                  THEN
                     v_rev_compare_date := lvPrevBusDate;

                     IF     v_rev_rul_typ = '='
                        AND gJournalHeader.jhu_jrnl_rev_date <>
                               v_rev_compare_date
                     THEN
                        prui_log_error (gJournalHeader.jhu_jrnl_id,
                                        0,
                                        9999,
                                        v_rev_err_msg);
                        lvSuccess := FALSE;
                     ELSIF     v_rev_rul_typ = '>'
                           AND gJournalHeader.jhu_jrnl_rev_date <=
                                  v_rev_compare_date
                     THEN
                        prui_log_error (gJournalHeader.jhu_jrnl_id,
                                        0,
                                        9999,
                                        v_rev_err_msg);
                        lvSuccess := FALSE;
                     ELSIF     v_rev_rul_typ = '<'
                           AND gJournalHeader.jhu_jrnl_rev_date >=
                                  v_rev_compare_date
                     THEN
                        prui_log_error (gJournalHeader.jhu_jrnl_id,
                                        0,
                                        9999,
                                        v_rev_err_msg);
                        lvSuccess := FALSE;
                     END IF;
                  ELSIF v_rev_prior_next_both = 'C'
                  THEN
                     v_rev_compare_date :=
                        gEntityConfiguration.ent_business_date;

                     IF     v_rev_rul_typ = '='
                        AND gJournalHeader.jhu_jrnl_rev_date <>
                               v_rev_compare_date
                     THEN
                        prui_log_error (gJournalHeader.jhu_jrnl_id,
                                        0,
                                        9999,
                                        v_rev_err_msg);
                        lvSuccess := FALSE;
                     ELSIF     v_rev_rul_typ = '>'
                           AND gJournalHeader.jhu_jrnl_rev_date <=
                                  v_rev_compare_date
                     THEN
                        prui_log_error (gJournalHeader.jhu_jrnl_id,
                                        0,
                                        9999,
                                        v_rev_err_msg);
                        lvSuccess := FALSE;
                     ELSIF     v_rev_rul_typ = '<'
                           AND gJournalHeader.jhu_jrnl_rev_date >=
                                  v_rev_compare_date
                     THEN
                        prui_log_error (gJournalHeader.jhu_jrnl_id,
                                        0,
                                        9999,
                                        v_rev_err_msg);
                        lvSuccess := FALSE;
                     END IF;
                  ELSIF v_rev_prior_next_both = 'N'
                  THEN
                     v_rev_compare_date := lvNextBusDate;

                     IF     v_rev_rul_typ = '='
                        AND gJournalHeader.jhu_jrnl_rev_date <>
                               v_rev_compare_date
                     THEN
                        prui_log_error (gJournalHeader.jhu_jrnl_id,
                                        0,
                                        9999,
                                        v_rev_err_msg);
                        lvSuccess := FALSE;
                     ELSIF     v_rev_rul_typ = '>'
                           AND gJournalHeader.jhu_jrnl_rev_date <=
                                  v_rev_compare_date
                     THEN
                        prui_log_error (gJournalHeader.jhu_jrnl_id,
                                        0,
                                        9999,
                                        v_rev_err_msg);
                        lvSuccess := FALSE;
                     ELSIF     v_rev_rul_typ = '<'
                           AND gJournalHeader.jhu_jrnl_rev_date >=
                                  v_rev_compare_date
                     THEN
                        prui_log_error (gJournalHeader.jhu_jrnl_id,
                                        0,
                                        9999,
                                        v_rev_err_msg);
                        lvSuccess := FALSE;
                     END IF;
                  END IF;
               ELSE
                  v_rev_compare_date := gEntityConfiguration.ent_business_date;

                  IF     v_rev_rul_typ = '='
                     AND gJournalHeader.jhu_jrnl_rev_date <>
                            v_rev_compare_date
                  THEN
                     prui_log_error (gJournalHeader.jhu_jrnl_id,
                                     0,
                                     9999,
                                     v_rev_err_msg);
                     lvSuccess := FALSE;
                  ELSIF     v_rev_rul_typ = '>'
                        AND gJournalHeader.jhu_jrnl_rev_date <=
                               v_rev_compare_date
                  THEN
                     prui_log_error (gJournalHeader.jhu_jrnl_id,
                                     0,
                                     9999,
                                     v_rev_err_msg);
                     lvSuccess := FALSE;
                  ELSIF     v_rev_rul_typ = '<'
                        AND gJournalHeader.jhu_jrnl_rev_date >=
                               v_rev_compare_date
                  THEN
                     prui_log_error (gJournalHeader.jhu_jrnl_id,
                                     0,
                                     9999,
                                     v_rev_err_msg);
                     lvSuccess := FALSE;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;

      COMMIT;

      RETURN lvSuccess;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_validate_header_dates',
                   'gui_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_validate_header_dates;

   --********************************************************************************

   FUNCTION fnui_validate_line_dates
      RETURN BOOLEAN
   IS
      lvFound                 NUMBER := NULL;
      lvSuccess               BOOLEAN;
      lvPeriodStartDate       DATE;
      lvPeriodEndDate         DATE;
      lvPrevBusDate           DATE;
      lvNextBusDate           DATE;
      lvNextPeriodEndDate     DATE;
      lvPrevPeriodEndDate     DATE;
      lvPrevPeriodStartDate   DATE;
      lvPostValueDateFlag     CHAR;
   BEGIN
      lvSuccess := TRUE;

      -- Check effective date is valid and open
      BEGIN
         INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                user_session_id,
                                                jle_jrnl_hdr_id,
                                                jle_jrnl_line_number,
                                                jle_error_code,
                                                jle_error_string,
                                                jle_created_by,
                                                jle_created_on,
                                                jle_amended_by,
                                                jle_amended_on)
            SELECT                                   /* jle_jrnl_process_id */
                  0,
                   /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jle_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jle_error_code */
                   'MADJ-1014',
                   /* jle_error_string */
                   'Effective Date is invalid or is not open',
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE
              FROM temp_gui_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND user_session_id = gSessionId
                   AND NOT EXISTS
                              (SELECT 1
                                 FROM slr_entity_days
                                WHERE     ed_entity_set =
                                             gEntityConfiguration.ent_periods_and_days_set
                                      AND ed_date = jlu_effective_date
                                      AND ed_status = 'O');
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_validate_line_dates.1',
                      'temp_gui_jrnl_lines_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            RETURN FALSE;
      END;

      -- Check effective dates are the same as header journal date
      BEGIN
         INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                user_session_id,
                                                jle_jrnl_hdr_id,
                                                jle_jrnl_line_number,
                                                jle_error_code,
                                                jle_error_string,
                                                jle_created_by,
                                                jle_created_on,
                                                jle_amended_by,
                                                jle_amended_on)
            SELECT                                   /* jle_jrnl_process_id */
                  0,
                   /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jle_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jle_error_code */
                   'MADJ-1016',
                   /* jle_error_string */
                   'Effective Date on header is not equal to the Effective Date on the line',
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE
              FROM temp_gui_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND user_session_id = gSessionId
                   AND jlu_effective_date != gJournalHeader.jhu_jrnl_date;
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_validate_line_dates.2',
                      'temp_gui_jrnl_lines_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            RETURN FALSE;
      END;

      -- Check value date is valid and open (but only if this validation is required)
      BEGIN
         SELECT ent_post_val_date
           INTO lvPostValueDateFlag
           FROM slr_entities
          WHERE ent_entity = gJournalHeader.jhu_jrnl_entity;

         IF lvPostValueDateFlag = 'Y'
         THEN
            INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                   user_session_id,
                                                   jle_jrnl_hdr_id,
                                                   jle_jrnl_line_number,
                                                   jle_error_code,
                                                   jle_error_string,
                                                   jle_created_by,
                                                   jle_created_on,
                                                   jle_amended_by,
                                                   jle_amended_on)
               SELECT                                /* jle_jrnl_process_id */
                     0,
                      /* user_session_id */
                      gSessionId,
                      /* jle_jrnl_hdr_id */
                      jlu_jrnl_hdr_id,
                      /* jle_jrnl_line_number */
                      jlu_jrnl_line_number,
                      /* jle_error_code */
                      'MADJ-1015',
                      /* jle_error_string */
                      'Value Date is invalid or is not open',
                      /* jle_created_by */
                      'SYSTEM',
                      /* jle_created_on */
                      SYSDATE,
                      /* jle_amended_by */
                      'SYSTEM',
                      /* jle_amended_on */
                      SYSDATE
                 FROM temp_gui_jrnl_lines_unposted
                WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                      AND user_session_id = gSessionId
                      AND NOT EXISTS
                                 (SELECT 1
                                    FROM slr_entity_days
                                   WHERE     ed_entity_set =
                                                gEntityConfiguration.ent_periods_and_days_set
                                         AND ed_date = jlu_value_date
                                         AND ed_status = 'O');
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_validate_line_dates.3',
                      'temp_gui_jrnl_lines_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            RETURN FALSE;
      END;

      --How many errors were found
      -- TTP 775 - MADJ-1025 error code added to condition so that errors for new journal type validation will be caught
      BEGIN
         SELECT COUNT (*)
           INTO lvFound
           FROM temp_gui_jrnl_line_errors
          WHERE     jle_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId
                AND jle_error_code IN ('MADJ-1014',
                                       'MADJ-1015',
                                       'MADJ-1016',
                                       'MADJ-1021',
                                       'MADJ-1022',
                                       'MADJ-1025');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;                                                -- do nothing
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_validate_line_dates.4',
                      'temp_gui_jrnl_line_errors',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
      END;

      IF lvFound > 0
      THEN
         lvSuccess := FALSE;
      END IF;

      RETURN lvSuccess;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_validate_line_dates',
                   'gui_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_validate_line_dates;

   --********************************************************************************

   FUNCTION fnui_validate_balances
      RETURN BOOLEAN
   IS
      -- Determines if optional field should be used
      -- in balance validation
      CURSOR cur_meta_data
      IS
           SELECT COLUMN_SCREEN_LABEL,
                  COLUMN_NAME,
                  COLUMN_USED_IN_BALANCE,
                  CASE UPPER (COLUMN_NAME)
                     WHEN 'SEGMENT_1' THEN FD_SEGMENT_1_BALANCE_CHECK
                     WHEN 'SEGMENT_2' THEN FD_SEGMENT_2_BALANCE_CHECK
                     WHEN 'SEGMENT_3' THEN FD_SEGMENT_3_BALANCE_CHECK
                     WHEN 'SEGMENT_4' THEN FD_SEGMENT_4_BALANCE_CHECK
                     WHEN 'SEGMENT_5' THEN FD_SEGMENT_5_BALANCE_CHECK
                     WHEN 'SEGMENT_6' THEN FD_SEGMENT_6_BALANCE_CHECK
                     WHEN 'SEGMENT_7' THEN FD_SEGMENT_7_BALANCE_CHECK
                     WHEN 'SEGMENT_8' THEN FD_SEGMENT_8_BALANCE_CHECK
                     WHEN 'SEGMENT_9' THEN FD_SEGMENT_9_BALANCE_CHECK
                     WHEN 'SEGMENT_10' THEN FD_SEGMENT_10_BALANCE_CHECK
                     ELSE 'N'
                  END
                     AS FD_BALANCE_CHECK
             FROM GUI.T_UI_JRNL_LINE_META
                  LEFT JOIN
                  (SELECT FD_SEGMENT_1_BALANCE_CHECK,
                          FD_SEGMENT_2_BALANCE_CHECK,
                          FD_SEGMENT_3_BALANCE_CHECK,
                          FD_SEGMENT_4_BALANCE_CHECK,
                          FD_SEGMENT_5_BALANCE_CHECK,
                          FD_SEGMENT_6_BALANCE_CHECK,
                          FD_SEGMENT_7_BALANCE_CHECK,
                          FD_SEGMENT_8_BALANCE_CHECK,
                          FD_SEGMENT_9_BALANCE_CHECK,
                          FD_SEGMENT_10_BALANCE_CHECK
                     FROM slr.SLR_FAK_DEFINITIONS
                    WHERE fd_entity = gEntityConfiguration.ent_entity) fd
                     ON (1 = 1)
            WHERE COLUMN_TYPE = 'L'
         ORDER BY COLUMN_NAME;

      CURSOR cur_complex_balance_check
      IS
         SELECT 'Y'
           FROM gui.temp_gui_jrnl_lines_unposted
          WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId
                AND (   jlu_base_amount IS NOT NULL
                     OR jlu_local_amount IS NOT NULL);

      lvTemplateMessage   VARCHAR2 (1000);
      lvMessage           VARCHAR2 (1000);
      lvComplexCheck      VARCHAR2 (1);
      lvCount             NUMBER (10);
      lvSuccess           BOOLEAN;
      lv_sql_template     VARCHAR2 (32000);
      lv_sql_statement    VARCHAR2 (32000);
   BEGIN
      -- Assume journal balances
      lvSuccess := TRUE;

      -- Only check balance if there are journal lines
      IF    gJournalHeader.jhu_jrnl_total_lines IS NULL
         OR gJournalHeader.jhu_jrnl_total_lines = 0
      THEN
         RETURN lvSuccess;
      END IF;

      -- Generate template sql statement
      BEGIN
         lv_sql_template :=
               'SELECT COUNT(*) '
            || ' FROM (SELECT SUM(##NAME##) '
            || ' 	    FROM temp_gui_jrnl_lines_unposted '
            || '        WHERE jlu_jrnl_hdr_id = '
            || gJournalHeader.jhu_jrnl_id
            || '          AND user_session_id = '''
            || gSessionId
            || ''''
            || '		   GROUP BY jlu_jrnl_hdr_id, jlu_effective_date, '
            || '  	            jlu_value_date, jlu_tran_ccy ';

         lvTemplateMessage := 'The journal doesn''t balance by ##NAME##, ';

         -- Append optional fields to group by clause
         -- (This will cause the field to become part of the balance check and message)
         FOR rec IN cur_meta_data
         LOOP
            -- Only add the field if its COLUMN_USED_IN_BALANCE is set to Y
            IF    UPPER (rec.COLUMN_USED_IN_BALANCE) = 'Y'
               OR NVL (UPPER (rec.FD_BALANCE_CHECK), 'N') = 'Y'
            THEN
               lv_sql_template :=
                  lv_sql_template || ', jlu_' || LOWER (rec.COLUMN_NAME);
               lvTemplateMessage :=
                     lvTemplateMessage
                  || LOWER (rec.COLUMN_SCREEN_LABEL)
                  || ', ';
            END IF;
         END LOOP;

         lv_sql_template := lv_sql_template || ' HAVING SUM(##NAME##) != 0) ';
         lvTemplateMessage :=
            lvTemplateMessage || ' ccy, effective and value dates';
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_validate_balances.1',
                      'gui_jrnl_lines_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            RETURN FALSE;
      END;

      -- Simple balance check (transaction) only
      BEGIN
         lv_sql_statement :=
            REPLACE (lv_sql_template, '##NAME##', 'jlu_tran_amount');

         -- Execute the statement and return the count into lvFound
         EXECUTE IMMEDIATE lv_sql_statement INTO lvCount;

         -- If it does not balance
         IF lvCount > 0
         THEN
            lvMessage := REPLACE (lvTemplateMessage, '##NAME##', 'trans amt');
            prui_log_error (gJournalHeader.jhu_jrnl_id,
                            0,
                            1013,
                            SUBSTR (lvMessage, 1, 1000));
            lvSuccess := FALSE;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_validate_balances.2',
                      'gui_jrnl_lines_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            prui_log_error (gJournalHeader.jhu_jrnl_id,
                            0,
                            9999,
                            'Failed journal balance check');
            lvSuccess := FALSE;
      END;

      -- More complex balance check of local and base currencies
      OPEN cur_complex_balance_check;

      FETCH cur_complex_balance_check INTO lvComplexCheck;

      CLOSE cur_complex_balance_check;

      IF NVL (lvComplexCheck, 'N') = 'Y'
      THEN
         BEGIN
            lv_sql_statement :=
               REPLACE (lv_sql_template, '##NAME##', 'jlu_base_amount');

            -- Execute the statement and return the count into lvFound
            EXECUTE IMMEDIATE lv_sql_statement INTO lvCount;

            -- If it does not balance
            IF lvCount > 0
            THEN
               lvMessage :=
                  REPLACE (lvTemplateMessage, '##NAME##', 'base amt');
               prui_log_error (gJournalHeader.jhu_jrnl_id,
                               0,
                               1013,
                               SUBSTR (lvMessage, 1, 1000));
               lvSuccess := FALSE;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               pr_error (1,
                         SQLERRM,
                         0,
                         'fnui_validate_balances.3',
                         'gui_jrnl_lines_unposted',
                         NULL,
                         NULL,
                         gPackageName,
                         'PL/SQL',
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL);
               prui_log_error (gJournalHeader.jhu_jrnl_id,
                               0,
                               9999,
                               'Failed journal balance check');
               lvSuccess := FALSE;
         END;

         BEGIN
            lv_sql_statement :=
               REPLACE (lv_sql_template, '##NAME##', 'jlu_local_amount');

            -- Execute the statement and return the count into lvFound
            EXECUTE IMMEDIATE lv_sql_statement INTO lvCount;

            -- If it does not balance
            IF lvCount > 0
            THEN
               lvMessage :=
                  REPLACE (lvTemplateMessage, '##NAME##', 'local amt');
               prui_log_error (gJournalHeader.jhu_jrnl_id,
                               0,
                               1013,
                               SUBSTR (lvMessage, 1, 1000));
               lvSuccess := FALSE;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               pr_error (1,
                         SQLERRM,
                         0,
                         'fnui_validate_balances.4',
                         'gui_jrnl_lines_unposted',
                         NULL,
                         NULL,
                         gPackageName,
                         'PL/SQL',
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL);
               prui_log_error (gJournalHeader.jhu_jrnl_id,
                               0,
                               9999,
                               'Failed journal balance check');
               lvSuccess := FALSE;
         END;
      END IF;

      RETURN lvSuccess;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_validate_balances.5',
                   'gui_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_validate_balances;

   --********************************************************************************

   FUNCTION fnui_check_ent_proc_group_conf
      RETURN BOOLEAN
   IS
      lvSqlText                    VARCHAR2 (32000);
      lvSuccess                    BOOLEAN;

      vEPG_DIMENSION_column_name   SLR_ENTITY_PROC_GROUP_CONFIG.EPGC_JLU_COLUMN_NAME%TYPE;
      v_entity_proc_group          SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE;
      v_not_configured_entity      INT;
      --v_jrnl_entity_proc_group      SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE;

      vJrnlLinesDimention          VARCHAR2 (1000);
      vJrnlHdrId                   NUMBER;

      NoEntGroupFound              EXCEPTION;
   BEGIN
      vJrnlHdrId := gJournalHeader.jhu_jrnl_id;
      lvSuccess := TRUE;
      v_not_configured_entity := 0;

      BEGIN
         -- check if proper entity processing group configuration exists

         --------------------------------------------------------------------------------------------------
         -- Use vEPG_DIMENSION_column_name to retrieve Entity Processing Group from TEMP_GUI_JRNL_LINES_UNPOSTED.
         -- If vEPG_DIMENSION_column_name is null then skip condition against EPG_DIMENSION.
         --------------------------------------------------------------------------------------------------

         BEGIN
            SELECT MAX (EPGC_JLU_COLUMN_NAME)
              INTO vEPG_DIMENSION_column_name
              FROM SLR_ENTITY_PROC_GROUP_CONFIG;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               -- It is not an error when SLR_ENTITY_PROC_GROUP_CONFIG is empty
               NULL;
         END;

         lvSqltext :=
            ' SELECT  DISTINCT EPG_ID
				FROM    TEMP_GUI_JRNL_LINES_UNPOSTED, SLR_ENTITY_PROC_GROUP
				WHERE
					JLU_JRNL_HDR_ID = :vJrnlHdrId
			     AND USER_SESSION_ID = :gSessionId
				 AND JLU_ENTITY = EPG_ENTITY';

         IF vEPG_DIMENSION_column_name IS NOT NULL
         THEN
            lvSqltext :=
                  lvSqltext
               || ' AND (EPG_DIMENSION IS NULL OR EPG_DIMENSION = '
               || vEPG_DIMENSION_column_name
               || ') ';
         END IF;

         EXECUTE IMMEDIATE lvSqltext
            INTO v_entity_proc_group
            USING vJrnlHdrId, gSessionId;


         -- check if configuration exists for all
         -- lines with group configuration and without in one header
         lvSqltext :=
            ' SELECT  COUNT(*)
				FROM    TEMP_GUI_JRNL_LINES_UNPOSTED LEFT JOIN SLR_ENTITY_PROC_GROUP
						ON JLU_ENTITY = EPG_ENTITY ';

         IF vEPG_DIMENSION_column_name IS NOT NULL
         THEN
            lvSqltext :=
                  lvSqltext
               || ' AND (EPG_DIMENSION IS NULL OR EPG_DIMENSION = '
               || vEPG_DIMENSION_column_name
               || ')';
         END IF;

         lvSqltext := lvSqltext || ' WHERE
					JLU_JRNL_HDR_ID = :vJrnlHdrId
			     AND USER_SESSION_ID = :gSessionId
				 AND EPG_ID IS NULL';


         EXECUTE IMMEDIATE lvSqltext
            INTO v_not_configured_entity
            USING vJrnlHdrId, gSessionId;

         IF (v_not_configured_entity > 0)
         THEN
            RAISE NoEntGroupFound;
         END IF;
      EXCEPTION
         WHEN TOO_MANY_ROWS
         THEN
            pr_error (
               1,
                  SQLERRM
               || ': Too many matching entity processing groups found. Please check your configuration'
               || CASE
                     WHEN vEPG_DIMENSION_column_name IS NOT NULL
                     THEN
                           ' and/or make sure all lines within header have the same value in '
                        || vEPG_DIMENSION_column_name
                        || ' column.'
                     ELSE
                        '.'
                  END,
               0,
               'fnui_check_ent_proc_group_conf.1',
               'gui_jrnl_lines_unposted',
               NULL,
               NULL,
               gPackageName,
               'PL/SQL',
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL);
            RETURN FALSE;
         WHEN NO_DATA_FOUND OR NoEntGroupFound
         THEN
            pr_error (
               1,
                  SQLERRM
               || ': No matching entity processing group found. Please check your configuration.',
               0,
               'fnui_check_ent_proc_group_conf.2',
               'gui_jrnl_lines_unposted',
               NULL,
               NULL,
               gPackageName,
               'PL/SQL',
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL);
            RETURN FALSE;
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_check_ent_proc_group_conf.3',
                      'gui_jrnl_lines_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            RETURN FALSE;
      END;

      gJrnlEntityProcGroup := v_entity_proc_group;

      --set entity processing group for all lines

      UPDATE temp_gui_jrnl_lines_unposted
         SET jlu_epg_id = gJrnlEntityProcGroup
       WHERE jlu_jrnl_hdr_id = vJrnlHdrId AND user_session_id = gSessionId;

      RETURN lvSuccess;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_check_ent_proc_group_conf.4',
                   'gui_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_check_ent_proc_group_conf;

   --********************************************************************************

   FUNCTION fnui_validate_account
      RETURN BOOLEAN
   IS
      lvFound     NUMBER := NULL;
      lvSuccess   BOOLEAN;
   BEGIN
      lvSuccess := TRUE;

      BEGIN
         --Look for errors in account code
         INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                user_session_id,
                                                jle_jrnl_hdr_id,
                                                jle_jrnl_line_number,
                                                jle_error_code,
                                                jle_error_string,
                                                jle_created_by,
                                                jle_created_on,
                                                jle_amended_by,
                                                jle_amended_on)
            SELECT                                   /* jle_jrnl_process_id */
                  0,
                   /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jle_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jle_error_code */
                   'MADJ-1010',
                   /* jle_error_string */
                   'Account is invalid',
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE
              FROM temp_gui_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND user_session_id = gSessionId
                   AND jlu_account NOT IN (SELECT ea_account
                                             FROM SLR_ENTITY_ACCOUNTS
                                            WHERE     ea_entity_set =
                                                         gEntityConfiguration.ent_accounts_set
                                                  AND ea_status = 'A');
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_validate_account',
                      'slr_entity_accounts',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            lvSuccess := FALSE;
      END;

      --How many errors were found
      BEGIN
         SELECT COUNT (*)
           INTO lvFound
           FROM temp_gui_jrnl_line_errors
          WHERE     jle_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId
                AND jle_error_code = 'MADJ-1010';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;                                                -- do nothing
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_validate_account',
                      'temp_gui_jrnl_lines_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
      END;

      IF lvFound > 0
      THEN
         lvSuccess := FALSE;
      END IF;

      RETURN lvSuccess;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_validate_account',
                   'slr_entity_accounts',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_validate_account;

   --********************************************************************************
   --********************************************************************************

   FUNCTION fnui_validate_ledger
      RETURN BOOLEAN
   IS
      lvFound     NUMBER := NULL;
      lvSuccess   BOOLEAN;
   BEGIN
      lvSuccess := TRUE;

      BEGIN
         --Look for errors in ledger code
         INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                user_session_id,
                                                jle_jrnl_hdr_id,
                                                jle_jrnl_line_number,
                                                jle_error_code,
                                                jle_error_string,
                                                jle_created_by,
                                                jle_created_on,
                                                jle_amended_by,
                                                jle_amended_on)
            SELECT                                   /* jle_jrnl_process_id */
                  0,
                   /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jle_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jle_error_code */
                   'MADJ-1110',
                   /* jle_error_string */
                   'Ledger is invalid',
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE
              FROM temp_gui_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND user_session_id = gSessionId
                   AND jlu_segment_1 NOT IN (SELECT ps_posting_schema
                                               FROM fdr.fr_posting_schema
                                              WHERE ps_active = 'A');
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_validate_ledger',
                      'ps_posting_schmema',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            lvSuccess := FALSE;
      END;

      --How many errors were found
      BEGIN
         SELECT COUNT (*)
           INTO lvFound
           FROM temp_gui_jrnl_line_errors
          WHERE     jle_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId
                AND jle_error_code = 'MADJ-1110';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;                                                -- do nothing
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_validate_ledger',
                      'temp_gui_jrnl_lines_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
      END;

      IF lvFound > 0
      THEN
         lvSuccess := FALSE;
      END IF;

      RETURN lvSuccess;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_validate_ledger',
                   'slr_entity_ledger',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_validate_ledger;

   --********************************************************************************


   FUNCTION fnui_validate_periods
      RETURN BOOLEAN
   IS
      lvFound     NUMBER;
      lvSuccess   BOOLEAN;
   BEGIN
      lvSuccess := TRUE;

      -- Check effective date on header and lines
      BEGIN
         SELECT DISTINCT 1
           INTO lvFound
           FROM slr_entity_periods
          --WHERE gJournalHeader.jhu_jrnl_date BETWEEN ep_bus_period_start AND ep_bus_period_end
          --WHERE gJournalHeader.jhu_jrnl_date BETWEEN TO_DATE('01/'||ep_month||'/'||ep_year, 'DD/MM/YYYY') AND ep_month_end
          WHERE     gJournalHeader.jhu_jrnl_date >= ep_cal_period_start --TO_DATE('01/'||ep_month||'/'||ep_year, 'DD/MM/YYYY')
                AND gJournalHeader.jhu_jrnl_date <= ep_cal_period_end --ep_month_end
                AND ep_entity = gJournalHeader.jhu_jrnl_entity -- gEntityConfiguration.ent_periods_and_days_set
                AND ep_status = 'O';                            -- period open
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            prui_log_error (
               gJournalHeader.jhu_jrnl_id,
               0,
               1023,
                  'Invalid period or period is closed for the Effective Date '
               || TO_CHAR (gJournalHeader.jhu_jrnl_date, 'DD-MON-YYYY'));
            lvSuccess := FALSE;
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_validate_periods.1',
                      'slr_entity_periods',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            lvSuccess := FALSE;
      END;

      -- Check value date on line (if exists)
      IF gJournalHeader.jhu_jrnl_total_lines > 0
      THEN
         BEGIN
            INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                   user_session_id,
                                                   jle_jrnl_hdr_id,
                                                   jle_jrnl_line_number,
                                                   jle_error_code,
                                                   jle_error_string,
                                                   jle_created_by,
                                                   jle_created_on,
                                                   jle_amended_by,
                                                   jle_amended_on)
               SELECT                                /* jle_jrnl_process_id */
                     0,
                      /* user_session_id */
                      gSessionId,
                      /* jle_jrnl_hdr_id */
                      jlu_jrnl_hdr_id,
                      /* jle_jrnl_line_number */
                      jlu_jrnl_line_number,
                      /* jle_error_code */
                      'MADJ-1024',
                         /* jle_error_string */
                         'Period containing Value Date '
                      || TO_CHAR (jlu_value_date, 'dd-mon-yyyy')
                      || ' is invalid or is closed',
                      /* jle_created_by */
                      'SYSTEM',
                      /* jle_created_on */
                      SYSDATE,
                      /* jle_amended_by */
                      'SYSTEM',
                      /* jle_amended_on */
                      SYSDATE
                 FROM temp_gui_jrnl_lines_unposted
                WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                      AND user_session_id = gSessionId
                      AND NOT EXISTS
                                 (SELECT 1
                                    FROM slr_entity_periods
                                   --WHERE  jlu_value_date BETWEEN TO_DATE('01/'||ep_month||'/'||ep_year, 'DD/MM/YYYY') AND ep_month_end
                                   WHERE     jlu_value_date >=
                                                ep_bus_period_start --TO_DATE('01/'||ep_month||'/'||ep_year, 'DD/MM/YYYY')
                                         AND jlu_value_date <=
                                                ep_bus_period_end --ep_month_end
                                         AND ep_entity =
                                                gJournalHeader.jhu_jrnl_entity -- gEntityConfiguration.ent_periods_and_days_set
                                         AND ep_status = 'O');
         EXCEPTION
            WHEN OTHERS
            THEN
               pr_error (1,
                         SQLERRM,
                         0,
                         'fnui_validate_periods.2',
                         'slr_entity_periods',
                         NULL,
                         NULL,
                         gPackageName,
                         'PL/SQL',
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL);
               lvSuccess := FALSE;
         END;
      END IF;

      --How many errors were found
      BEGIN
         SELECT COUNT (*)
           INTO lvFound
           FROM temp_gui_jrnl_line_errors
          WHERE     jle_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId
                AND jle_error_code = 'MADJ-1024';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;                                                -- do nothing
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_validate_periods.3',
                      'temp_gui_jrnl_lines_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
      END;

      IF lvFound > 0
      THEN
         lvSuccess := FALSE;
      END IF;

      RETURN lvSuccess;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_validate_periods',
                   'slr_entity_periods',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_validate_periods;

   --********************************************************************************

   FUNCTION fnui_check_currencies
      RETURN BOOLEAN
   IS
      lvFound     NUMBER := NULL;
      lvSuccess   BOOLEAN;
   BEGIN
      lvSuccess := TRUE;

      --Tran currency
      BEGIN
         INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                user_session_id,
                                                jle_jrnl_hdr_id,
                                                jle_jrnl_line_number,
                                                jle_error_code,
                                                jle_error_string,
                                                jle_created_by,
                                                jle_created_on,
                                                jle_amended_by,
                                                jle_amended_on)
            SELECT                                   /* jle_jrnl_process_id */
                  0,
                   /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jle_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jle_error_code */
                   'MADJ-1011',
                   /* jle_error_string */
                   'Transaction currency does not exist or is not active.',
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE
              FROM temp_gui_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND user_session_id = gSessionId
                   AND TRIM (jlu_tran_ccy) NOT IN (SELECT TRIM (ec_ccy)
                                                     FROM slr_entity_currencies
                                                    WHERE     ec_entity_set =
                                                                 gEntityConfiguration.ent_currency_set
                                                          AND ec_status = 'A');
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_check_currencies.1',
                      'slr_entity_currencies',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            lvSuccess := FALSE;
      END;

      -- Check Tran Amount decimal places
      BEGIN
         INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                user_session_id,
                                                jle_jrnl_hdr_id,
                                                jle_jrnl_line_number,
                                                jle_error_code,
                                                jle_error_string,
                                                jle_created_by,
                                                jle_created_on,
                                                jle_amended_by,
                                                jle_amended_on)
            SELECT                                   /* jle_jrnl_process_id */
                  0,
                   /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jle_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jle_error_code */
                   'MADJ-1061',
                      /* jle_error_string */
                      'Currency '
                   || jlu_tran_ccy
                   || ' contains too many decimal places',
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE
              FROM temp_gui_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND user_session_id = gSessionId
                   AND EXISTS
                          (SELECT 1
                             FROM fr_currency
                            WHERE     cu_currency_id = jlu_tran_ccy
                                  AND cu_digits_after_point <
                                           LENGTH (TO_CHAR (jlu_tran_amount))
                                         - DECODE (
                                              INSTR (
                                                 TO_CHAR (jlu_tran_amount),
                                                 '.'),
                                              0, LENGTH (
                                                    TO_CHAR (jlu_tran_amount)),
                                              INSTR (
                                                 TO_CHAR (jlu_tran_amount),
                                                 '.')));
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_check_currencies.2',
                      'slr_entity_currencies',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            lvSuccess := FALSE;
      END;

      --Base currency
      BEGIN
         INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                user_session_id,
                                                jle_jrnl_hdr_id,
                                                jle_jrnl_line_number,
                                                jle_error_code,
                                                jle_error_string,
                                                jle_created_by,
                                                jle_created_on,
                                                jle_amended_by,
                                                jle_amended_on)
            SELECT                                   /* jle_jrnl_process_id */
                  0,
                   /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jle_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jle_error_code */
                   'MADJ-1011',
                   /* jle_error_string */
                   'Base currency does not exist or is not active.',
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE
              FROM temp_gui_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND user_session_id = gSessionId
                   AND NVL (jlu_base_amount, 0) != 0
                   AND TRIM (jlu_base_ccy) NOT IN (SELECT TRIM (ec_ccy)
                                                     FROM slr_entity_currencies
                                                    WHERE     ec_entity_set =
                                                                 gEntityConfiguration.ent_currency_set
                                                          AND ec_status = 'A');
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_check_currencies.3',
                      'slr_entity_currencies',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            lvSuccess := FALSE;
      END;

      -- Check Base Amount decimal places
      BEGIN
         INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                user_session_id,
                                                jle_jrnl_hdr_id,
                                                jle_jrnl_line_number,
                                                jle_error_code,
                                                jle_error_string,
                                                jle_created_by,
                                                jle_created_on,
                                                jle_amended_by,
                                                jle_amended_on)
            SELECT                                   /* jle_jrnl_process_id */
                  0,
                   /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jle_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jle_error_code */
                   'MADJ-1061',
                      /* jle_error_string */
                      'Currency '
                   || jlu_base_ccy
                   || ' contains too many decimal places',
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE
              FROM temp_gui_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND user_session_id = gSessionId
                   AND NVL (jlu_base_amount, 0) != 0
                   AND EXISTS
                          (SELECT 1
                             FROM fr_currency
                            WHERE     cu_currency_id = jlu_base_ccy
                                  AND cu_digits_after_point <
                                           LENGTH (TO_CHAR (jlu_base_amount))
                                         - DECODE (
                                              INSTR (
                                                 TO_CHAR (jlu_base_amount),
                                                 '.'),
                                              0, LENGTH (
                                                    TO_CHAR (jlu_base_amount)),
                                              INSTR (
                                                 TO_CHAR (jlu_base_amount),
                                                 '.')));
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_check_currencies.4',
                      'slr_entity_currencies',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            lvSuccess := FALSE;
      END;

      --Local currency
      BEGIN
         INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                user_session_id,
                                                jle_jrnl_hdr_id,
                                                jle_jrnl_line_number,
                                                jle_error_code,
                                                jle_error_string,
                                                jle_created_by,
                                                jle_created_on,
                                                jle_amended_by,
                                                jle_amended_on)
            SELECT                                   /* jle_jrnl_process_id */
                  0,
                   /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jle_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jle_error_code */
                   'MADJ-1011',
                   /* jle_error_string */
                   'Local currency does not exist or is not active.',
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE
              FROM temp_gui_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND user_session_id = gSessionId
                   AND NVL (jlu_local_amount, 0) != 0
                   AND TRIM (jlu_local_ccy) NOT IN (SELECT TRIM (ec_ccy)
                                                      FROM slr_entity_currencies
                                                     WHERE     ec_entity_set =
                                                                  gEntityConfiguration.ent_currency_set
                                                           AND ec_status =
                                                                  'A');
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_check_currencies.5',
                      'slr_entity_currencies',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            lvSuccess := FALSE;
      END;

      -- Check Local Amount decimal places
      BEGIN
         INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                user_session_id,
                                                jle_jrnl_hdr_id,
                                                jle_jrnl_line_number,
                                                jle_error_code,
                                                jle_error_string,
                                                jle_created_by,
                                                jle_created_on,
                                                jle_amended_by,
                                                jle_amended_on)
            SELECT                                   /* jle_jrnl_process_id */
                  0,
                   /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jle_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jle_error_code */
                   'MADJ-1061',
                      /* jle_error_string */
                      'Currency '
                   || jlu_local_ccy
                   || ' contains too many decimal places',
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE
              FROM temp_gui_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND user_session_id = gSessionId
                   AND NVL (jlu_local_amount, 0) != 0
                   AND EXISTS
                          (SELECT 1
                             FROM fr_currency
                            WHERE     cu_currency_id = jlu_local_ccy
                                  AND cu_digits_after_point <
                                           LENGTH (
                                              TO_CHAR (jlu_local_amount))
                                         - DECODE (
                                              INSTR (
                                                 TO_CHAR (jlu_local_amount),
                                                 '.'),
                                              0, LENGTH (
                                                    TO_CHAR (
                                                       jlu_local_amount)),
                                              INSTR (
                                                 TO_CHAR (jlu_local_amount),
                                                 '.')));
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_check_currencies.6',
                      'slr_entity_currencies',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            lvSuccess := FALSE;
      END;

      -- Check that local and base currency is used consistently across all journal lines
      BEGIN
         INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                user_session_id,
                                                jle_jrnl_hdr_id,
                                                jle_jrnl_line_number,
                                                jle_error_code,
                                                jle_error_string,
                                                jle_created_by,
                                                jle_created_on,
                                                jle_amended_by,
                                                jle_amended_on)
            SELECT                                   /* jle_jrnl_process_id */
                  0,
                   /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jle_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jle_error_code */
                   'MADJ-1062',
                      /* jle_error_string */
                      'Journal uses local and base amounts but values missing for line '
                   || jlu_jrnl_line_number,
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE
              FROM temp_gui_jrnl_lines_unposted tsjlu
             WHERE     tsjlu.jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND tsjlu.user_session_id = gSessionId
                   AND (   tsjlu.jlu_base_amount IS NULL
                        OR tsjlu.jlu_local_amount IS NULL)
                   AND EXISTS
                          (SELECT 1
                             FROM gui_jrnl_lines_unposted sjlu
                            WHERE     sjlu.jlu_jrnl_hdr_id =
                                         tsjlu.jlu_jrnl_hdr_id
                                  AND NVL (sjlu.jlu_base_amount, 0) != 0
                                  AND NVL (sjlu.jlu_local_amount, 0) != 0);
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_check_currencies.6',
                      'slr_entity_currencies',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            lvSuccess := FALSE;
      END;


      --check fx rates for local and base ccy only if apply fx translation flag equals 'Y' and journal date is <= entity business date
      IF (    gEntityConfiguration.ENT_APPLY_FX_TRANSLATION = 'Y'
          AND gJournalHeader.jhu_jrnl_date <=
                 gEntityConfiguration.ENT_BUSINESS_DATE)
      THEN
         BEGIN
            --local ccy
            INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                   user_session_id,
                                                   jle_jrnl_hdr_id,
                                                   jle_jrnl_line_number,
                                                   jle_error_code,
                                                   jle_error_string,
                                                   jle_created_by,
                                                   jle_created_on,
                                                   jle_amended_by,
                                                   jle_amended_on)
               SELECT                                /* jle_jrnl_process_id */
                     0,
                      /* user_session_id */
                      gSessionId,
                      /* jle_jrnl_hdr_id */
                      jlu_jrnl_hdr_id,
                      /* jle_jrnl_line_number */
                      jlu_jrnl_line_number,
                      /* jle_error_code */
                      'MADJ-1066',
                         /* jle_error_string */
                         'No local FX Rate for source currency ['
                      || tjlu.JLU_TRAN_CCY
                      || '] and entity ['
                      || gEntityConfiguration.ent_entity
                      || ']',
                      /* jle_created_by */
                      'SYSTEM',
                      /* jle_created_on */
                      SYSDATE,
                      /* jle_amended_by */
                      'SYSTEM',
                      /* jle_amended_on */
                      SYSDATE
                 FROM temp_gui_jrnl_lines_unposted tjlu
                WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                      AND user_session_id = gSessionId
                      AND NOT EXISTS
                                 (SELECT 1
                                    FROM SLR_ENTITY_RATES
                                   WHERE     ER_ENTITY_SET =
                                                gEntityConfiguration.ENT_RATE_SET
                                         AND ER_CCY_FROM = tjlu.JLU_TRAN_CCY
                                         AND ER_CCY_TO =
                                                gEntityConfiguration.ENT_LOCAL_CCY
                                         AND ER_DATE =
                                                gJournalHeader.jhu_jrnl_date
                                         AND ER_RATE > 0);
         EXCEPTION
            WHEN OTHERS
            THEN
               pr_error (1,
                         SQLERRM,
                         0,
                         'fnui_check_currencies.7',
                         'slr_entity_rates',
                         NULL,
                         NULL,
                         gPackageName,
                         'PL/SQL',
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL);
               lvSuccess := FALSE;
         END;

         BEGIN
            --base ccy
            INSERT INTO temp_gui_jrnl_line_errors (jle_jrnl_process_id,
                                                   user_session_id,
                                                   jle_jrnl_hdr_id,
                                                   jle_jrnl_line_number,
                                                   jle_error_code,
                                                   jle_error_string,
                                                   jle_created_by,
                                                   jle_created_on,
                                                   jle_amended_by,
                                                   jle_amended_on)
               SELECT                                /* jle_jrnl_process_id */
                     0,
                      /* user_session_id */
                      gSessionId,
                      /* jle_jrnl_hdr_id */
                      jlu_jrnl_hdr_id,
                      /* jle_jrnl_line_number */
                      jlu_jrnl_line_number,
                      /* jle_error_code */
                      'MADJ-1066',
                         /* jle_error_string */
                         'No base FX Rate for source currency ['
                      || tjlu.JLU_TRAN_CCY
                      || '] and entity ['
                      || gEntityConfiguration.ent_entity
                      || ']',
                      /* jle_created_by */
                      'SYSTEM',
                      /* jle_created_on */
                      SYSDATE,
                      /* jle_amended_by */
                      'SYSTEM',
                      /* jle_amended_on */
                      SYSDATE
                 FROM temp_gui_jrnl_lines_unposted tjlu
                WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                      AND user_session_id = gSessionId
                      AND NOT EXISTS
                                 (SELECT 1
                                    FROM SLR_ENTITY_RATES
                                   WHERE     ER_ENTITY_SET =
                                                gEntityConfiguration.ENT_RATE_SET
                                         AND ER_CCY_FROM = tjlu.JLU_TRAN_CCY
                                         AND ER_CCY_TO =
                                                gEntityConfiguration.ENT_BASE_CCY
                                         AND ER_DATE =
                                                gJournalHeader.jhu_jrnl_date
                                         AND ER_RATE > 0);
         EXCEPTION
            WHEN OTHERS
            THEN
               pr_error (1,
                         SQLERRM,
                         0,
                         'fnui_check_currencies.8',
                         'slr_entity_rates',
                         NULL,
                         NULL,
                         gPackageName,
                         'PL/SQL',
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL);
               lvSuccess := FALSE;
         END;
      END IF;

      --How many errors were found
      BEGIN
         SELECT COUNT (*)
           INTO lvFound
           FROM temp_gui_jrnl_line_errors
          WHERE     jle_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId
                AND jle_error_code IN ('MADJ-1011', 'MADJ-1061', 'MADJ-1066');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_check_currencies.9',
                      'temp_gui_jrnl_lines_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
      END;

      IF lvFound > 0
      THEN
         lvSuccess := FALSE;
      END IF;

      RETURN lvSuccess;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_check_currencies',
                   'slr_entity_currencies',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_check_currencies;

   --********************************************************************************

   FUNCTION fnui_get_journal_type
      RETURN BOOLEAN
   IS
      lvFound     NUMBER;
      lvSuccess   BOOLEAN;
   BEGIN
      lvSuccess := TRUE;

      -- Fetch journal type
      BEGIN
         /* Removed 1.2 functionality for 1.1
         SELECT *
         INTO   gJournalType
         FROM   SLR_EXT_JRNL_TYPES
         WHERE  ejt_journal_type = gJournalHeader.jhu_jrnl_type
         AND    ejt_status = 'A';*/

         SELECT *
           INTO gJournalType
           FROM uiv_journal_types
          WHERE     jt_type = TRIM (gJournalHeader.jhu_jrnl_type)
                AND jt_status = 'A';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            prui_log_error (
               gJournalHeader.jhu_jrnl_id,
               0,
               9999,
                  'Journal Type '
               || gJournalHeader.jhu_jrnl_type
               || ' does not exist or is not activated');
            lvSuccess := FALSE;
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_get_journal_type.1',
                      'slr_jrnl_types',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            lvSuccess := FALSE;
      END;

      -- Check that this is a manual journal type or
      -- it is a system journal type that is being updated
      BEGIN
         SELECT 1
           INTO lvFound
           FROM uiv_journal_types, temp_gui_jrnl_headers_unposted
          WHERE     jt_type = jhu_jrnl_type
                AND user_session_id = gSessionId
                AND jt_madj_ind != 'Y'
                AND db_state != 'U';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            lvFound := 0;                                        -- no matches
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_get_journal_type.2',
                      'slr_jrnl_types',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            lvFound := NULL;
      END;

      IF lvFound > 0
      THEN
         prui_log_error (
            gJournalHeader.jhu_jrnl_id,
            0,
            1035,
               'This action is not permitted for Journal Type '
            || gJournalHeader.jhu_jrnl_type);
         lvSuccess := FALSE;
      END IF;

      -- Check if journal type is accessable by user
      /* Removed 1.2 functionality for 1.2
       BEGIN
          SELECT  1
          INTO lvFound
          FROM SLR_EXT_JRNL_TYPES sljt
                      INNER JOIN UI_META_GROUP_JOURNAL_TYPES mgjt
                          ON sljt.ejt_journal_type = mgjt.gjt_journal_type
                      INNER JOIN UI_META_USER_GROUPS umug
                          ON mgjt.gjt_group_id = umug.mmg_group_id
          WHERE sljt.ejt_journal_type = gJournalHeader.jhu_jrnl_type
          AND  umug.mmg_user_id = gJournalHeader.jhu_amended_by;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
               prui_log_error(gJournalLine.jlu_jrnl_hdr_id, 0, 9999,
                                      'Journal Type '||gJournalHeader.jhu_jrnl_type||' is not accessable to user '||gJournalHeader.jhu_amended_by);
               lvSuccess := FALSE;
          WHEN OTHERS THEN
               pr_error(1, SQLERRM, 0, 'fnui_get_journal_type', 'slr_jrnl_types', NULL, NULL, gPackageName, 'PL/SQL', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
               lvSuccess := FALSE;
       END; */

      RETURN lvSuccess;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_get_journal_type',
                   'slr_jrnl_types',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_get_journal_type;

   --********************************************************************************

   FUNCTION fnui_get_fak_definitions
      RETURN BOOLEAN
   IS
      lvSuccess   BOOLEAN;
   BEGIN
      lvSuccess := TRUE;

      BEGIN
         SELECT *
           INTO gFAKDefinitions
           FROM SLR_FAK_DEFINITIONS
          WHERE fd_entity = gJournalHeader.jhu_jrnl_entity;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            prui_log_error (
               gJournalHeader.jhu_jrnl_id,
               0,
               9999,
                  'FAK Definitions for entity '
               || gJournalHeader.jhu_jrnl_entity
               || ' does not exist');
            lvSuccess := FALSE;
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_get_fak_definitions',
                      'slr_fak_definitions',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            lvSuccess := FALSE;
      END;

      RETURN lvSuccess;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_get_fak_definitions',
                   'slr_fak_definitions',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_get_fak_definitions;

   --********************************************************************************

   FUNCTION fnui_get_eba_definitions
      RETURN BOOLEAN
   IS
      lvSuccess   BOOLEAN;
   BEGIN
      lvSuccess := TRUE;

      BEGIN
         SELECT *
           INTO gEBADefinitions
           FROM SLR_EBA_DEFINITIONS
          WHERE ed_entity = gJournalHeader.jhu_jrnl_entity;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            prui_log_error (
               gJournalHeader.jhu_jrnl_id,
               0,
               9999,
                  'EBA Definitions for entity '
               || gJournalHeader.jhu_jrnl_entity
               || ' does not exist');
            lvSuccess := FALSE;
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_get_eba_definitions',
                      'slr_eba_definitions',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            lvSuccess := FALSE;
      END;

      RETURN lvSuccess;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_get_eba_definitions',
                   'slr_eba_definitions',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_get_eba_definitions;

   --********************************************************************************

   FUNCTION fnui_get_entity
      RETURN BOOLEAN
   IS
      lvSuccess   BOOLEAN;
   BEGIN
      lvSuccess := TRUE;

      BEGIN
         SELECT *
           INTO gEntityConfiguration
           FROM SLR_ENTITIES se
          WHERE     se.ent_entity = gJournalHeader.jhu_jrnl_entity
                AND ent_status = 'A'
                AND EXISTS
                       (SELECT NULL
                          FROM FDR.FR_PARTY_LEGAL pl
                         WHERE     PL.PL_PARTY_LEGAL_ID = se.ENT_ENTITY
                               AND PL.PL_CLIENT_TEXT7 = 'Y');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            prui_log_error (
               gJournalHeader.jhu_jrnl_id,
               0,
               9999,
                  'Entity '
               || gJournalHeader.jhu_jrnl_entity
               || ' does not exist or is not activated or is not a standalone insurance co');
            lvSuccess := FALSE;
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_get_entity',
                      'slr_entities',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            lvSuccess := FALSE;
      END;

      RETURN lvSuccess;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_get_entity',
                   'slr_entities',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_get_entity;

   --********************************************************************************



   FUNCTION fnui_validate_segment_n (segment_no IN NUMBER)
      RETURN BOOLEAN
   IS
      lvFound                 NUMBER := NULL;
      lvSuccess               BOOLEAN;

      lv_sql_statement        VARCHAR2 (8000);

      fak_type                CHAR (1);
      fak_table               VARCHAR2 (40);
      fak_field               VARCHAR2 (40);
      fak_name                SLR_FAK_DEFINITIONS.FD_SEGMENT_1_NAME%TYPE;
      fak_set_name            SLR_ENTITIES.ENT_SEGMENT_1_SET%TYPE;

      v_screen_segment_name   T_UI_JRNL_LINE_META.COLUMN_SCREEN_LABEL%TYPE;
      v_column_screen_label   T_UI_JRNL_LINE_META.COLUMN_NAME%TYPE;
   BEGIN
      lvSuccess := TRUE;
      fak_table := 'SLR_FAK_SEGMENT_' || TO_CHAR (segment_no);

      BEGIN
         --get screen label for given segment
         v_screen_segment_name := 'SEGMENT_' || segment_no;

         SELECT column_screen_label
           INTO v_column_screen_label
           FROM gui.T_UI_JRNL_LINE_META
          WHERE column_name = v_screen_segment_name AND column_type = 'L';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_column_screen_label := NULL;
      END;

      IF segment_no = 1
      THEN
         fak_type := gFAKDefinitions.fd_segment_1_type;
         fak_name := v_column_screen_label;
         fak_set_name := gEntityConfiguration.ent_segment_1_set;
      ELSIF segment_no = 2
      THEN
         fak_type := gFAKDefinitions.fd_segment_2_type;
         fak_name := v_column_screen_label;
         fak_set_name := gEntityConfiguration.ent_segment_2_set;
      ELSIF segment_no = 3
      THEN
         fak_type := gFAKDefinitions.fd_segment_3_type;
         fak_name := v_column_screen_label;
         fak_set_name := gEntityConfiguration.ent_segment_3_set;
      ELSIF segment_no = 4
      THEN
         fak_type := gFAKDefinitions.fd_segment_4_type;
         fak_name := v_column_screen_label;
         fak_set_name := gEntityConfiguration.ent_segment_4_set;
      ELSIF segment_no = 5
      THEN
         fak_type := gFAKDefinitions.fd_segment_5_type;
         fak_name := v_column_screen_label;
         fak_set_name := gEntityConfiguration.ent_segment_5_set;
      ELSIF segment_no = 6
      THEN
         fak_type := gFAKDefinitions.fd_segment_6_type;
         fak_name := v_column_screen_label;
         fak_set_name := gEntityConfiguration.ent_segment_6_set;
      ELSIF segment_no = 7
      THEN
         fak_type := gFAKDefinitions.fd_segment_7_type;
         fak_name := v_column_screen_label;
         fak_set_name := gEntityConfiguration.ent_segment_7_set;
      ELSIF segment_no = 8
      THEN
         fak_type := gFAKDefinitions.fd_segment_8_type;
         fak_name := v_column_screen_label;
         fak_set_name := gEntityConfiguration.ent_segment_8_set;
      ELSIF segment_no = 9
      THEN
         fak_type := gFAKDefinitions.fd_segment_9_type;
         fak_name := v_column_screen_label;
         fak_set_name := gEntityConfiguration.ent_segment_9_set;
      ELSIF segment_no = 10
      THEN
         fak_type := gFAKDefinitions.fd_segment_10_type;
         fak_name := v_column_screen_label;
         fak_set_name := gEntityConfiguration.ent_segment_10_set;
      ELSE
         prui_log_error (
            gJournalHeader.jhu_jrnl_id,
            0,
            9999,
            'FAK Definition not found for segment ' || TO_CHAR (segment_no));
         lvSuccess := FALSE;
      END IF;

      -- Check field sizes (always do this regardless of validation required)
      -- TTP: 1804 all segments sizes extended to 100 characters
      BEGIN
         lv_sql_statement :=
               'INSERT INTO temp_gui_jrnl_line_errors ( '
            || '	jle_jrnl_process_id, user_session_id, jle_jrnl_hdr_id, jle_jrnl_line_number, '
            || '	jle_error_code, jle_error_string, jle_created_by, jle_created_on, '
            || '	jle_amended_by, jle_amended_on '
            || ' ) '
            || ' SELECT /* jle_jrnl_process_id */	 	0, '
            || '/* user_session_id */			'''
            || gSessionId
            || ''', '
            || '/* jle_jrnl_hdr_id */	 	 	jlu_jrnl_hdr_id, '
            || '/* jle_jrnl_line_number */	jlu_jrnl_line_number, '
            || '/* jle_error_code */	  		''MADJ-1013'', '
            || '/* jle_error_string */		'''
            || fak_name
            || ' is greater than 100 characters.'', '
            || '/* jle_created_by */			''SYSTEM'', '
            || '/* jle_created_on */			SYSDATE, '
            || '/* jle_amended_by */			''SYSTEM'', '
            || '/* jle_amended_on */	 		SYSDATE '
            || ' FROM temp_gui_jrnl_lines_unposted '
            || ' WHERE jlu_jrnl_hdr_id = '
            || gJournalHeader.jhu_jrnl_id
            || ' AND user_session_id = '''
            || gSessionId
            || ''' '
            || ' AND LENGTH(jlu_segment_'
            || TO_CHAR (segment_no)
            || ') > 100 ';

         EXECUTE IMMEDIATE lv_sql_statement;
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM || ' ' || lv_sql_statement,
                      0,
                      'fnui_validate_segment_n',
                      'slr_fak_segment_' || TO_CHAR (segment_no),
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            lvSuccess := FALSE;
            lvFound := NULL;
      END;

      -- Check if validation required
      IF fak_type IN ('C', 'M')
      THEN
         BEGIN
            IF fak_type = 'C'
            THEN
               lv_sql_statement :=
                     'INSERT INTO temp_gui_jrnl_line_errors ( '
                  || '	jle_jrnl_process_id, user_session_id, jle_jrnl_hdr_id, jle_jrnl_line_number, '
                  || '	jle_error_code, jle_error_string, jle_created_by, jle_created_on, '
                  || '	jle_amended_by, jle_amended_on '
                  || ' ) '
                  || ' SELECT /* jle_jrnl_process_id */	 	0, '
                  || '/* user_session_id */			'''
                  || gSessionId
                  || ''', '
                  || '/* jle_jrnl_hdr_id */	 	 	jlu_jrnl_hdr_id, '
                  || '/* jle_jrnl_line_number */	jlu_jrnl_line_number, '
                  || '/* jle_error_code */	  		''MADJ-1012'', '
                  || '/* jle_error_string */		''Value for '
                  || fak_name
                  || ' is invalid.'', '
                  || '/* jle_created_by */			''SYSTEM'', '
                  || '/* jle_created_on */			SYSDATE, '
                  || '/* jle_amended_by */			''SYSTEM'', '
                  || '/* jle_amended_on */	 		SYSDATE '
                  || ' FROM temp_gui_jrnl_lines_unposted '
                  || ' WHERE jlu_jrnl_hdr_id = '
                  || gJournalHeader.jhu_jrnl_id
                  || ' AND user_session_id = '''
                  || gSessionId
                  || ''' '
                  || ' AND NVL(jlu_segment_'
                  || TO_CHAR (segment_no)
                  || ',''NVS'') != ''NVS'' '
                  || ' AND jlu_segment_'
                  || TO_CHAR (segment_no)
                  || ' NOT IN '
                  || ' (SELECT fs'
                  || TO_CHAR (segment_no)
                  || '_segment_value '
                  || '  FROM '
                  || fak_table
                  || '  WHERE fs'
                  || TO_CHAR (segment_no)
                  || '_entity_set = '''
                  || fak_set_name
                  || ''' '
                  || '  AND   fs'
                  || TO_CHAR (segment_no)
                  || '_status = ''A'') ';
            ELSE
               lv_sql_statement :=
                     'INSERT INTO temp_gui_jrnl_line_errors ( '
                  || '	jle_jrnl_process_id, user_session_id, jle_jrnl_hdr_id, jle_jrnl_line_number, '
                  || '	jle_error_code, jle_error_string, jle_created_by, jle_created_on, '
                  || '	jle_amended_by, jle_amended_on '
                  || ' ) '
                  || ' SELECT /* jle_jrnl_process_id */	 	0, '
                  || '/* user_session_id */			'''
                  || gSessionId
                  || ''', '
                  || '/* jle_jrnl_hdr_id */	 	 	jlu_jrnl_hdr_id, '
                  || '/* jle_jrnl_line_number */	jlu_jrnl_line_number, '
                  || '/* jle_error_code */	  		''MADJ-1012'', '
                  || '/* jle_error_string */		''Value for '
                  || fak_name
                  || ' is invalid.'', '
                  || '/* jle_created_by */			''SYSTEM'', '
                  || '/* jle_created_on */			SYSDATE, '
                  || '/* jle_amended_by */			''SYSTEM'', '
                  || '/* jle_amended_on */	 		SYSDATE '
                  || ' FROM temp_gui_jrnl_lines_unposted '
                  || ' WHERE jlu_jrnl_hdr_id = '
                  || gJournalHeader.jhu_jrnl_id
                  || ' AND   user_session_id = '''
                  || gSessionId
                  || ''' '
                  || ' AND jlu_segment_'
                  || TO_CHAR (segment_no)
                  || ' NOT IN '
                  || ' (SELECT fs'
                  || TO_CHAR (segment_no)
                  || '_segment_value '
                  || '  FROM '
                  || fak_table
                  || '  WHERE fs'
                  || TO_CHAR (segment_no)
                  || '_entity_set = '''
                  || fak_set_name
                  || ''' '
                  || '  AND   fs'
                  || TO_CHAR (segment_no)
                  || '_status = ''A'') ';
            END IF;

            EXECUTE IMMEDIATE lv_sql_statement;
         EXCEPTION
            WHEN OTHERS
            THEN
               pr_error (1,
                         SQLERRM || ' ' || lv_sql_statement,
                         0,
                         'fnui_validate_segment_n',
                         'slr_fak_segment_' || TO_CHAR (segment_no),
                         NULL,
                         NULL,
                         gPackageName,
                         'PL/SQL',
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL);
               lvSuccess := FALSE;
               lvFound := NULL;
         END;
      END IF;

      --How many errors were found
      BEGIN
         SELECT COUNT (*)
           INTO lvFound
           FROM temp_gui_jrnl_line_errors
          WHERE     jle_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId
                AND jle_error_code IN ('MADJ-1012', 'MADJ-1013');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;                                                -- do nothing
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_validate_segment_n',
                      'temp_gui_jrnl_lines_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
      END;

      IF lvFound > 0
      THEN
         lvSuccess := FALSE;
      END IF;

      RETURN lvSuccess;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_validate_segment_n',
                   'slr_fak_segment_' || TO_CHAR (segment_no),
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_validate_segment_n;

   --********************************************************************************

   FUNCTION fnui_validate_attribute_n (attribute_no IN NUMBER)
      RETURN BOOLEAN
   IS
      lvFound            NUMBER;
      lvSuccess          BOOLEAN;

      lv_sql_statement   VARCHAR2 (32000);

      eba_type           CHAR (1);
      eba_table          VARCHAR2 (40);
      eba_name           SLR_EBA_DEFINITIONS.ED_ATTRIBUTE_1_NAME%TYPE;
      eba_set_name       SLR_ENTITIES.ENT_SEGMENT_1_SET%TYPE;
   BEGIN
      lvSuccess := TRUE;

      eba_table := 'SLR_EBA_ATTRIBUTE_' || TO_CHAR (attribute_no);

      IF attribute_no = 1
      THEN
         eba_type := gEBADefinitions.ed_attribute_1_type;
         eba_name := gEBADefinitions.ed_attribute_1_name;
         eba_set_name := gEntityConfiguration.ent_segment_1_set;
      ELSIF attribute_no = 2
      THEN
         eba_type := gEBADefinitions.ed_attribute_2_type;
         eba_name := gEBADefinitions.ed_attribute_2_name;
         eba_set_name := gEntityConfiguration.ent_segment_2_set;
      ELSIF attribute_no = 3
      THEN
         eba_type := gEBADefinitions.ed_attribute_3_type;
         eba_name := gEBADefinitions.ed_attribute_3_name;
         eba_set_name := gEntityConfiguration.ent_segment_3_set;
      ELSIF attribute_no = 4
      THEN
         eba_type := gEBADefinitions.ed_attribute_4_type;
         eba_name := gEBADefinitions.ed_attribute_4_name;
         eba_set_name := gEntityConfiguration.ent_segment_4_set;
      ELSIF attribute_no = 5
      THEN
         eba_type := gEBADefinitions.ed_attribute_5_type;
         eba_name := gEBADefinitions.ed_attribute_5_name;
         eba_set_name := gEntityConfiguration.ent_segment_5_set;
      ELSE
         prui_log_error (
            gJournalHeader.jhu_jrnl_id,
            0,
            9999,
               'EBA Definition not found for attribute '
            || TO_CHAR (attribute_no));
         lvSuccess := FALSE;
      END IF;

      -- Check field sizes (always do this regardless of validation required)
      -- TTP675 KT 19/11/2009 EBA attribute 1 extended to 80 characters
      -- TTP: 1804 all attributes sizes extended to 100 characters
      BEGIN
         lv_sql_statement :=
               'INSERT INTO temp_gui_jrnl_line_errors ( '
            || '	jle_jrnl_process_id, user_session_id, jle_jrnl_hdr_id, jle_jrnl_line_number, '
            || '	jle_error_code, jle_error_string, jle_created_by, jle_created_on, '
            || '	jle_amended_by, jle_amended_on '
            || ' ) '
            || ' SELECT /* jle_jrnl_process_id */	 	0, '
            || '/* user_session_id */			'''
            || gSessionId
            || ''', '
            || '/* jle_jrnl_hdr_id */	 	 	jlu_jrnl_hdr_id, '
            || '/* jle_jrnl_line_number */	jlu_jrnl_line_number, '
            || '/* jle_error_code */	  		''MADJ-1013'', '
            || '/* jle_error_string */		'''
            || eba_name
            || ' is greater than 100 characters.'', '
            || '/* jle_created_by */			''SYSTEM'', '
            || '/* jle_created_on */			SYSDATE, '
            || '/* jle_amended_by */			''SYSTEM'', '
            || '/* jle_amended_on */	 		SYSDATE '
            || ' FROM temp_gui_jrnl_lines_unposted '
            || ' WHERE jlu_jrnl_hdr_id = '
            || gJournalHeader.jhu_jrnl_id
            || ' AND user_session_id = '''
            || gSessionId
            || ''' '
            || ' AND LENGTH(jlu_attribute_'
            || TO_CHAR (attribute_no)
            || ') > 100 ';

         EXECUTE IMMEDIATE lv_sql_statement;
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM || ' ' || lv_sql_statement,
                      0,
                      'fnui_validate_attribute_n',
                      'slr_attribute_' || TO_CHAR (attribute_no),
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            lvSuccess := FALSE;
            lvFound := NULL;
      END;

      -- Check if validation required
      IF eba_type IN ('C', 'M')
      THEN
         BEGIN
            IF eba_type = 'C'
            THEN
               lv_sql_statement :=
                     'INSERT INTO temp_gui_jrnl_line_errors ( '
                  || '	jle_jrnl_process_id, user_session_id, jle_jrnl_hdr_id, jle_jrnl_line_number, '
                  || '	jle_error_code, jle_error_string, jle_created_by, jle_created_on, '
                  || '	jle_amended_by, jle_amended_on '
                  || ' ) '
                  || ' SELECT /* jle_jrnl_process_id */	 	0, '
                  || '/* user_session_id */			'''
                  || gSessionId
                  || ''', '
                  || '/* jle_jrnl_hdr_id */	 	 	jlu_jrnl_hdr_id, '
                  || '/* jle_jrnl_line_number */	jlu_jrnl_line_number, '
                  || '/* jle_error_code */	  		''MADJ-1012'', '
                  || '/* jle_error_string */		''Value for '
                  || eba_name
                  || ' is missing.'', '
                  || '/* jle_created_by */			''SYSTEM'', '
                  || '/* jle_created_on */			SYSDATE, '
                  || '/* jle_amended_by */			''SYSTEM'', '
                  || '/* jle_amended_on */	 		SYSDATE '
                  || ' FROM temp_gui_jrnl_lines_unposted '
                  || ' WHERE jlu_jrnl_hdr_id = '
                  || gJournalHeader.jhu_jrnl_id
                  || ' AND user_session_id = '''
                  || gSessionId
                  || ''' '
                  || ' AND jlu_attribute_'
                  || TO_CHAR (attribute_no)
                  || ' != ''NVS'' '
                  || ' AND jlu_attribute_'
                  || TO_CHAR (attribute_no)
                  || ' IS NULL ';
            ELSE
               lv_sql_statement :=
                     'INSERT INTO temp_gui_jrnl_line_errors ( '
                  || '	jle_jrnl_process_id, user_session_id, jle_jrnl_hdr_id, jle_jrnl_line_number, '
                  || '	jle_error_code, jle_error_string, jle_created_by, jle_created_on, '
                  || '	jle_amended_by, jle_amended_on '
                  || ' ) '
                  || ' SELECT /* jle_jrnl_process_id */	 	0, '
                  || '/* user_session_id */			'''
                  || gSessionId
                  || ''', '
                  || '/* jle_jrnl_hdr_id */	 	 	jlu_jrnl_hdr_id, '
                  || '/* jle_jrnl_line_number */	jlu_jrnl_line_number, '
                  || '/* jle_error_code */	  		''MADJ-1012'', '
                  || '/* jle_error_string */		''Value for '
                  || eba_name
                  || ' is missing.'', '
                  || '/* jle_created_by */			''SYSTEM'', '
                  || '/* jle_created_on */			SYSDATE, '
                  || '/* jle_amended_by */			''SYSTEM'', '
                  || '/* jle_amended_on */	 		SYSDATE '
                  || ' FROM temp_gui_jrnl_lines_unposted '
                  || ' WHERE jlu_jrnl_hdr_id = '
                  || gJournalHeader.jhu_jrnl_id
                  || ' AND   user_session_id = '''
                  || gSessionId
                  || ''' '
                  || ' AND   jlu_attribute_'
                  || TO_CHAR (attribute_no)
                  || ' = ''NVS'' ';
            END IF;

            EXECUTE IMMEDIATE lv_sql_statement;
         EXCEPTION
            WHEN OTHERS
            THEN
               pr_error (1,
                         SQLERRM || ' ' || lv_sql_statement,
                         0,
                         'fnui_validate_attribute_n',
                         'slr_attribute_' || TO_CHAR (attribute_no),
                         NULL,
                         NULL,
                         gPackageName,
                         'PL/SQL',
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL);
               lvSuccess := FALSE;
               lvFound := NULL;
         END;
      END IF;

      --How many errors were found
      BEGIN
         SELECT COUNT (*)
           INTO lvFound
           FROM temp_gui_jrnl_line_errors
          WHERE     jle_jRnl_hdr_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId
                AND jle_error_code IN ('MADJ-1012', 'MADJ-1013');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;                                                -- do nothing
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_validate_attribute_n',
                      'temp_gui_jrnl_lines_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
      END;

      IF lvFound > 0
      THEN
         lvSuccess := FALSE;
      END IF;

      RETURN lvSuccess;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_validate_attribute_n',
                   'slr_eba_attribute_' || TO_CHAR (attribute_no),
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_validate_attribute_n;

   --********************************************************************************

   -- For use with R2 code base
   FUNCTION fnui_check_month_end_limits
      RETURN BOOLEAN
   IS
      lvFound     NUMBER;
      lvSuccess   BOOLEAN;
   BEGIN
      lvSuccess := TRUE;

      /*
         TODO: Add the rules here.  The is a proposed solution to change the
         SLR_GRACE_DAYS table by adding a LEVEL column.  At this point no
         decision has been taken on the modification,

         This functionality is required for Release 1.2
      */

      RETURN lvSuccess;
   END fnui_check_month_end_limits;

   --********************************************************************************

   PROCEDURE prui_log_error (
      journal_id   IN SLR_JRNL_LINES.JL_JRNL_HDR_ID%TYPE,
      line_no      IN SLR_JRNL_LINES.JL_JRNL_LINE_NUMBER%TYPE,
      error_no     IN NUMBER,
      MESSAGE      IN VARCHAR2)
   IS
   BEGIN
      INSERT INTO temp_gui_jrnl_line_errors (user_session_id,
                                             jle_jrnl_process_id,
                                             jle_jrnl_hdr_id,
                                             jle_jrnl_line_number,
                                             jle_error_code,
                                             jle_error_string,
                                             jle_created_by,
                                             jle_created_on,
                                             jle_amended_by,
                                             jle_amended_on)
           VALUES (                                      /* user_session_id */
                   gSessionId,
                   /* jle_jrnl_process_id */
                   0,
                   /* jle_jrnl_hdr_id */
                   journal_id,
                   /* jle_jrnl_line_number */
                   line_no,
                   /* jle_error_code */
                   'MADJ-' || error_no,
                   /* jle_error_string */
                   MESSAGE,
                   /* jle_created_by */
                   'SYSTEM',
                   /* jle_created_on */
                   SYSDATE,
                   /* jle_amended_by */
                   'SYSTEM',
                   /* jle_amended_on */
                   SYSDATE);
   END prui_log_error;

   --********************************************************************************

   PROCEDURE prui_write_errors_to_database (journal_id NUMBER DEFAULT NULL)
   IS
   BEGIN
      IF gSessionId IS NULL
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_write_errors_to_database',
                   'temp_gui_jrnl_line_errors',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         raise_application_error (-9001, 'Missing session id');
      END IF;

      IF journal_id IS NULL
      THEN
         INSERT INTO gui_jrnl_line_errors (jle_jrnl_process_id,
                                           jle_jrnl_hdr_id,
                                           jle_jrnl_line_number,
                                           jle_error_code,
                                           jle_error_string,
                                           jle_created_by,
                                           jle_created_on,
                                           jle_amended_by,
                                           jle_amended_on)
            SELECT jle_jrnl_process_id,
                   jle_jrnl_hdr_id,
                   jle_jrnl_line_number,
                   jle_error_code,
                   jle_error_string,
                   jle_created_by,
                   jle_created_on,
                   jle_amended_by,
                   jle_amended_on
              FROM temp_gui_jrnl_line_errors
             WHERE user_session_id = gSessionId;
      ELSE
         INSERT INTO gui_jrnl_line_errors (jle_jrnl_process_id,
                                           jle_jrnl_hdr_id,
                                           jle_jrnl_line_number,
                                           jle_error_code,
                                           jle_error_string,
                                           jle_created_by,
                                           jle_created_on,
                                           jle_amended_by,
                                           jle_amended_on)
            SELECT jle_jrnl_process_id,
                   jle_jrnl_hdr_id,
                   jle_jrnl_line_number,
                   jle_error_code,
                   jle_error_string,
                   jle_created_by,
                   jle_created_on,
                   jle_amended_by,
                   jle_amended_on
              FROM temp_gui_jrnl_line_errors
             WHERE     user_session_id = gSessionId
                   AND jle_jrnl_hdr_id = journal_id;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_write_errors_to_database',
                   NULL,
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RAISE;
   END prui_write_errors_to_database;

   --********************************************************************************

   PROCEDURE prui_clear_errors (
      journal_id    IN SLR_JRNL_LINES.JL_JRNL_HDR_ID%TYPE,
      line_number   IN SLR_JRNL_LINES.JL_JRNL_LINE_NUMBER%TYPE DEFAULT 0)
   IS
   BEGIN
      IF gSessionId IS NULL
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_clear_errors',
                   'temp_gui_jrnl_line_errors',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         raise_application_error (-9001, 'Missing session id');
      END IF;

      IF line_number = 0
      THEN
         -- Purge everything from temporary table
         DELETE FROM temp_gui_jrnl_line_errors
               WHERE     user_session_id = gSessionId
                     AND jle_jrnl_hdr_id = journal_id;

         -- Purge everything in SLR
         DELETE FROM gui_jrnl_line_errors
               WHERE jle_jrnl_hdr_id = journal_id;
      ELSE
         -- Purge everything from temporary table
         DELETE FROM temp_gui_jrnl_line_errors
               WHERE     jle_jrnl_hdr_id = journal_id
                     AND jle_jrnl_line_number = line_number
                     AND user_session_id = gSessionId;

         -- Purge everything in SLR
         DELETE FROM gui_jrnl_line_errors
               WHERE     jle_jrnl_hdr_id = journal_id
                     AND jle_jrnl_line_number = line_number;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;         -- do nothing (worse case end up with duplicate errors)
   END prui_clear_errors;

   --********************************************************************************

   FUNCTION fnui_requires_authorisation
      RETURN BOOLEAN
   IS
      lvSuccess   BOOLEAN;
   BEGIN
      lvSuccess := TRUE;

      --IF gJournalType.EJT_REQUIRES_AUTHORISATION != 'Y' THEN
      IF     gJournalType.jt_requires_authorisation != 'Y'
         AND gJournalType.jt_madj_ind = 'Y'
      THEN
         lvSuccess := FALSE;
      END IF;

      RETURN lvSuccess;
   END fnui_requires_authorisation;

   --********************************************************************************

   FUNCTION fnui_check_copy_journal
      RETURN BOOLEAN
   IS
      lvFound     NUMBER;
      lvSuccess   BOOLEAN;
   BEGIN
      lvSuccess := TRUE;

      -- Check if journal exists
      IF NOT fnui_does_journal_exist (gJournalHeader.jhu_jrnl_id)
      THEN
         lvSuccess := FALSE;
         prui_log_error (
            gJournalHeader.jhu_jrnl_id,
            0,
            9999,
            'Journal ' || gJournalHeader.jhu_jrnl_id || ' does not exist');
      END IF;

      -- Check effective date is valid
      BEGIN
         SELECT 1
           INTO lvFound
           FROM slr_entity_days
          WHERE     ed_entity_set =
                       gEntityConfiguration.ent_periods_and_days_set
                AND ed_date = gJournalHeader.jhu_jrnl_date
                AND ed_status = 'O';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            prui_log_error (gJournalHeader.jhu_jrnl_id,
                            0,
                            9999,
                            'Effective Date is not a valid business date');
            lvSuccess := FALSE;
         WHEN OTHERS
         THEN
            RETURN FALSE;
      END;

      -- If reversing journal check reversing date
      /* Removed 1.2 functionality for 1.1
      IF gJournalHeader.jhu_jrnl_type IN (gJOURNAL_TYPE_DREV, gJOURNAL_TYPE_MDREV, gJOURNAL_TYPE_MMREV, gJOURNAL_TYPE_MDAYR) THEN

         BEGIN

              SELECT 1
              INTO lvFound
              FROM slr_entity_days
              WHERE ed_entity_set  = gEntityConfiguration.ent_periods_and_days_set
              AND ed_date     = gJournalHeader.jhu_jrnl_rev_date
              AND ed_status    = 'O';

         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  prui_log_error(gJournalHeader.jhu_jrnl_id, 0, 9999, 'Reversing Date is not a valid business date');
                  lvSuccess := FALSE;
             WHEN OTHERS THEN
                  RETURN FALSE;
         END;

      END IF; */

      RETURN lvSuccess;
   END fnui_check_copy_journal;

   --********************************************************************************

   FUNCTION fnui_check_quick_reversal
      RETURN BOOLEAN
   IS
      lvFound     NUMBER;
      lvSuccess   BOOLEAN;
   BEGIN
      lvSuccess := TRUE;

      -- Check if journal exists
      IF NOT fnui_does_journal_exist (gJournalHeader.jhu_jrnl_id)
      THEN
         lvSuccess := FALSE;
         prui_log_error (
            gJournalHeader.jhu_jrnl_id,
            0,
            9999,
            'Journal ' || gJournalHeader.jhu_jrnl_id || ' does not exist');
      END IF;

      -- Check effective date is valid
      BEGIN
         SELECT 1
           INTO lvFound
           FROM slr_entity_days
          WHERE     ed_entity_set =
                       gEntityConfiguration.ent_periods_and_days_set
                AND ed_date = gJournalHeader.jhu_jrnl_date
                AND ed_status = 'O';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            prui_log_error (gJournalHeader.jhu_jrnl_id,
                            0,
                            9999,
                            'Effective Date is not a valid business date');
            lvSuccess := FALSE;
         WHEN OTHERS
         THEN
            RETURN FALSE;
      END;

      -- If reversing journal check reversing date
      /* Remove 1.2 functionality for 1.1
      IF gJournalHeader.jhu_jrnl_type IN (gJOURNAL_TYPE_DREV, gJOURNAL_TYPE_MDREV, gJOURNAL_TYPE_MMREV, gJOURNAL_TYPE_MDAYR) THEN

         BEGIN

              SELECT 1
              INTO lvFound
              FROM slr_entity_days
              WHERE ed_entity_set  = gEntityConfiguration.ent_periods_and_days_set
              AND ed_date     = gJournalHeader.jhu_jrnl_rev_date
              AND ed_status    = 'O';

         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  prui_log_error(gJournalHeader.jhu_jrnl_id, 0, 9999, 'Reversing Date is not a valid business date');
                  lvSuccess := FALSE;
             WHEN OTHERS THEN
                  RETURN FALSE;
         END;

      END IF; */

      RETURN lvSuccess;
   END fnui_check_quick_reversal;

   --********************************************************************************

   FUNCTION fnui_check_deletion (journal_id NUMBER)
      RETURN BOOLEAN
   IS
      lvFound        NUMBER;
      lvSuccess      BOOLEAN;
      lvJrnlStatus   CHAR (1);
   BEGIN
      lvSuccess := TRUE;

      -- Check if journal exists
      IF NOT fnui_does_journal_exist (journal_id)
      THEN
         lvSuccess := FALSE;
         prui_log_error (journal_id,
                         0,
                         9999,
                         'Journal ' || journal_id || ' does not exist');
      ELSE
         SELECT JHU_JRNL_STATUS
           INTO lvJrnlStatus
           FROM GUI_JRNL_HEADERS_UNPOSTED
          WHERE jhu_jrnl_id = journal_id;

         IF (lvJrnlStatus = 'V')
         THEN
            lvSuccess := FALSE;
            prui_log_error (
               journal_id,
               0,
               9999,
                  'Journal '
               || journal_id
               || ' is currently processed. Cannot delete running journal.');
         END IF;
      END IF;

      IF gJournalType.jt_madj_ind != 'Y'
      THEN
         prui_log_error (journal_id,
                         0,
                         9999,
                         'Only manual journals can be deleted');
         lvSuccess := FALSE;
      END IF;

      RETURN lvSuccess;
   END fnui_check_deletion;

   --********************************************************************************

   FUNCTION fnui_check_copy_line (journal_id NUMBER, line_number NUMBER)
      RETURN BOOLEAN
   IS
      lvFound     NUMBER;
      lvSuccess   BOOLEAN;
   BEGIN
      lvSuccess := TRUE;

      -- Check if journal line exists
      IF NOT fnui_does_line_exist (gJournalHeader.jhu_jrnl_id, line_number)
      THEN
         lvSuccess := FALSE;
         prui_log_error (
            gJournalHeader.jhu_jrnl_id,
            line_number,
            9999,
               'Line'
            || line_number
            || ' of journal '
            || gJournalHeader.jhu_jrnl_id
            || ' does not exist');
      END IF;

      RETURN lvSuccess;
   END fnui_check_copy_line;

   --********************************************************************************

   FUNCTION fnui_check_delete_line (journal_id NUMBER, line_number NUMBER)
      RETURN BOOLEAN
   IS
      lvFound     NUMBER;
      lvSuccess   BOOLEAN;
   BEGIN
      lvSuccess := TRUE;

      -- Check if journal line exists
      IF NOT fnui_does_line_exist (journal_id, line_number)
      THEN
         lvSuccess := FALSE;
         prui_log_error (
            journal_id,
            line_number,
            9999,
               'Line'
            || line_number
            || ' of journal '
            || journal_id
            || ' does not exist');
      END IF;

      RETURN lvSuccess;
   END fnui_check_delete_line;

   --********************************************************************************

   FUNCTION fnui_decode_journal_lines
      RETURN BOOLEAN
   IS
      lvSuccess   BOOLEAN;
      lvCount     NUMBER;
   BEGIN
      lvSuccess := TRUE;

      -- Exit if the coding convention is client static
      IF UPPER (gJournalHeader.JHU_JRNL_PREF_STATIC_SRC) = gCLIENT_STATIC
      THEN
         RETURN lvSuccess;
      END IF;

      -- Convert source system codes to FDR codes using correlated query
      UPDATE temp_gui_jrnl_lines_unposted tsjlu
         SET (jlu_segment_1,
              jlu_segment_2,
              jlu_segment_3,
              jlu_segment_4,
              jlu_segment_5,
              jlu_segment_6,
              jlu_segment_7,
              jlu_segment_8,
              jlu_segment_9,
              jlu_segment_10,
              jlu_attribute_1,
              jlu_attribute_2,
              jlu_attribute_3,
              jlu_attribute_4,
              jlu_attribute_5) =
                (  SELECT MAX (segment_1) AS segment_1,
                          MAX (segment_2) AS segment_2,
                          MAX (segment_3) AS segment_3,
                          MAX (segment_4) AS segment_4,
                          MAX (segment_5) AS segment_5,
                          MAX (segment_6) AS segment_6,
                          MAX (segment_7) AS segment_7,
                          MAX (segment_8) AS segment_8,
                          MAX (segment_9) AS segment_9,
                          MAX (segment_10) AS segment_10,
                          MAX (attribute_1) AS attribute_1,
                          MAX (attribute_2) AS attribute_2,
                          MAX (attribute_3) AS attribute_3,
                          MAX (attribute_4) AS attribute_4,
                          MAX (attribute_5) AS attribute_5
                     FROM (SELECT jlu_jrnl_hdr_id,
                                  jlu_jrnl_line_number,
                                  DECODE (column_order, 1, fdr_code)
                                     AS segment_1,
                                  DECODE (column_order, 2, fdr_code)
                                     AS segment_2,
                                  DECODE (column_order, 3, fdr_code)
                                     AS segment_3,
                                  DECODE (column_order, 4, fdr_code)
                                     AS segment_4,
                                  DECODE (column_order, 5, fdr_code)
                                     AS segment_5,
                                  DECODE (column_order, 6, fdr_code)
                                     AS segment_6,
                                  DECODE (column_order, 7, fdr_code)
                                     AS segment_7,
                                  DECODE (column_order, 8, fdr_code)
                                     AS segment_8,
                                  DECODE (column_order, 9, fdr_code)
                                     AS segment_9,
                                  DECODE (column_order, 10, fdr_code)
                                     AS segment_10,
                                  DECODE (column_order, 11, fdr_code)
                                     AS attribute_1,
                                  DECODE (column_order, 12, fdr_code)
                                     AS attribute_2,
                                  DECODE (column_order, 13, fdr_code)
                                     AS attribute_3,
                                  DECODE (column_order, 14, fdr_code)
                                     AS attribute_4,
                                  DECODE (column_order, 15, fdr_code)
                                     AS attribute_5
                             FROM (SELECT 1 AS column_order,
                                          tsjlu.jlu_jrnl_hdr_id,
                                          tsjlu.jlu_jrnl_line_number,
                                          NVL (vug1.fdr_code, jlu_segment_1)
                                             AS fdr_code
                                     FROM temp_gui_jrnl_lines_unposted tsjlu
                                          LEFT OUTER JOIN vw_ui_segment_1 vug1
                                             ON     tsjlu.jlu_segment_1 =
                                                       vug1.lookup_key
                                                AND vug1.source_system_id =
                                                       gJournalHeader.jhu_jrnl_pref_static_src
                                    WHERE     tsjlu.jlu_jrnl_hdr_id =
                                                 gJournalHeader.jhu_jrnl_id
                                          AND tsjlu.user_session_id =
                                                 gSessionId
                                   UNION ALL
                                   SELECT 2 AS column_order,
                                          tsjlu.jlu_jrnl_hdr_id,
                                          tsjlu.jlu_jrnl_line_number,
                                          NVL (vug2.fdr_code, jlu_segment_2)
                                             AS fdr_code
                                     FROM temp_gui_jrnl_lines_unposted tsjlu
                                          LEFT OUTER JOIN vw_ui_segment_2 vug2
                                             ON     tsjlu.jlu_segment_2 =
                                                       vug2.lookup_key
                                                AND vug2.source_system_id =
                                                       gJournalHeader.jhu_jrnl_pref_static_src
                                    WHERE     tsjlu.jlu_jrnl_hdr_id =
                                                 gJournalHeader.jhu_jrnl_id
                                          AND tsjlu.user_session_id =
                                                 gSessionId
                                   UNION ALL
                                   SELECT 3 AS column_order,
                                          tsjlu.jlu_jrnl_hdr_id,
                                          tsjlu.jlu_jrnl_line_number,
                                          NVL (vug3.fdr_code, jlu_segment_3)
                                             AS fdr_code
                                     FROM temp_gui_jrnl_lines_unposted tsjlu
                                          LEFT OUTER JOIN vw_ui_segment_3 vug3
                                             ON     tsjlu.jlu_segment_3 =
                                                       vug3.lookup_key
                                                AND vug3.source_system_id =
                                                       gJournalHeader.jhu_jrnl_pref_static_src
                                    WHERE     tsjlu.jlu_jrnl_hdr_id =
                                                 gJournalHeader.jhu_jrnl_id
                                          AND tsjlu.user_session_id =
                                                 gSessionId
                                   UNION ALL
                                   SELECT 4 AS column_order,
                                          tsjlu.jlu_jrnl_hdr_id,
                                          tsjlu.jlu_jrnl_line_number,
                                          NVL (vug4.fdr_code, jlu_segment_4)
                                             AS fdr_code
                                     FROM temp_gui_jrnl_lines_unposted tsjlu
                                          LEFT OUTER JOIN vw_ui_segment_4 vug4
                                             ON     tsjlu.jlu_segment_4 =
                                                       vug4.lookup_key
                                                AND vug4.source_system_id =
                                                       gJournalHeader.jhu_jrnl_pref_static_src
                                    WHERE     tsjlu.jlu_jrnl_hdr_id =
                                                 gJournalHeader.jhu_jrnl_id
                                          AND tsjlu.user_session_id =
                                                 gSessionId
                                   UNION ALL
                                   SELECT 5 AS column_order,
                                          tsjlu.jlu_jrnl_hdr_id,
                                          tsjlu.jlu_jrnl_line_number,
                                          NVL (vug5.fdr_code, jlu_segment_5)
                                             AS fdr_code
                                     FROM temp_gui_jrnl_lines_unposted tsjlu
                                          LEFT OUTER JOIN vw_ui_segment_5 vug5
                                             ON     tsjlu.jlu_segment_5 =
                                                       vug5.lookup_key
                                                AND vug5.source_system_id =
                                                       gJournalHeader.jhu_jrnl_pref_static_src
                                    WHERE     tsjlu.jlu_jrnl_hdr_id =
                                                 gJournalHeader.jhu_jrnl_id
                                          AND tsjlu.user_session_id =
                                                 gSessionId
                                   UNION ALL
                                   SELECT 6 AS column_order,
                                          tsjlu.jlu_jrnl_hdr_id,
                                          tsjlu.jlu_jrnl_line_number,
                                          NVL (vug6.fdr_code, jlu_segment_6)
                                             AS fdr_code
                                     FROM temp_gui_jrnl_lines_unposted tsjlu
                                          LEFT OUTER JOIN vw_ui_segment_6 vug6
                                             ON     tsjlu.jlu_segment_6 =
                                                       vug6.lookup_key
                                                AND vug6.source_system_id =
                                                       gJournalHeader.jhu_jrnl_pref_static_src
                                    WHERE     tsjlu.jlu_jrnl_hdr_id =
                                                 gJournalHeader.jhu_jrnl_id
                                          AND tsjlu.user_session_id =
                                                 gSessionId
                                   UNION ALL
                                   SELECT 7 AS column_order,
                                          tsjlu.jlu_jrnl_hdr_id,
                                          tsjlu.jlu_jrnl_line_number,
                                          NVL (vug7.fdr_code, jlu_segment_7)
                                             AS fdr_code
                                     FROM temp_gui_jrnl_lines_unposted tsjlu
                                          LEFT OUTER JOIN vw_ui_segment_7 vug7
                                             ON     tsjlu.jlu_segment_7 =
                                                       vug7.lookup_key
                                                AND vug7.source_system_id =
                                                       gJournalHeader.jhu_jrnl_pref_static_src
                                    WHERE     tsjlu.jlu_jrnl_hdr_id =
                                                 gJournalHeader.jhu_jrnl_id
                                          AND tsjlu.user_session_id =
                                                 gSessionId
                                   UNION ALL
                                   SELECT 8 AS column_order,
                                          tsjlu.jlu_jrnl_hdr_id,
                                          tsjlu.jlu_jrnl_line_number,
                                          NVL (vug8.fdr_code, jlu_segment_8)
                                             AS fdr_code
                                     FROM temp_gui_jrnl_lines_unposted tsjlu
                                          LEFT OUTER JOIN vw_ui_segment_8 vug8
                                             ON     tsjlu.jlu_segment_8 =
                                                       vug8.lookup_key
                                                AND vug8.source_system_id =
                                                       gJournalHeader.jhu_jrnl_pref_static_src
                                    WHERE     tsjlu.jlu_jrnl_hdr_id =
                                                 gJournalHeader.jhu_jrnl_id
                                          AND tsjlu.user_session_id =
                                                 gSessionId
                                   UNION ALL
                                   SELECT 9 AS column_order,
                                          tsjlu.jlu_jrnl_hdr_id,
                                          tsjlu.jlu_jrnl_line_number,
                                          NVL (vug9.fdr_code, jlu_segment_9)
                                             AS fdr_code
                                     FROM temp_gui_jrnl_lines_unposted tsjlu
                                          LEFT OUTER JOIN vw_ui_segment_9 vug9
                                             ON     tsjlu.jlu_segment_9 =
                                                       vug9.lookup_key
                                                AND vug9.source_system_id =
                                                       gJournalHeader.jhu_jrnl_pref_static_src
                                    WHERE     tsjlu.jlu_jrnl_hdr_id =
                                                 gJournalHeader.jhu_jrnl_id
                                          AND tsjlu.user_session_id =
                                                 gSessionId
                                   UNION ALL
                                   SELECT 10 AS column_order,
                                          tsjlu.jlu_jrnl_hdr_id,
                                          tsjlu.jlu_jrnl_line_number,
                                          NVL (vug10.fdr_code, jlu_segment_10)
                                             AS fdr_code
                                     FROM temp_gui_jrnl_lines_unposted tsjlu
                                          LEFT OUTER JOIN
                                          vw_ui_segment_10 vug10
                                             ON     tsjlu.jlu_segment_10 =
                                                       vug10.lookup_key
                                                AND vug10.source_system_id =
                                                       gJournalHeader.jhu_jrnl_pref_static_src
                                    WHERE     tsjlu.jlu_jrnl_hdr_id =
                                                 gJournalHeader.jhu_jrnl_id
                                          AND tsjlu.user_session_id =
                                                 gSessionId
                                   UNION ALL
                                   SELECT 11 AS column_order,
                                          tsjlu.jlu_jrnl_hdr_id,
                                          tsjlu.jlu_jrnl_line_number,
                                          NVL (vua1.fdr_code, jlu_attribute_1)
                                             AS fdr_code
                                     FROM temp_gui_jrnl_lines_unposted tsjlu
                                          LEFT OUTER JOIN
                                          vw_ui_attribute_1 vua1
                                             ON     tsjlu.jlu_attribute_1 =
                                                       vua1.lookup_key
                                                AND vua1.source_system_id =
                                                       gJournalHeader.jhu_jrnl_pref_static_src
                                    WHERE     tsjlu.jlu_jrnl_hdr_id =
                                                 gJournalHeader.jhu_jrnl_id
                                          AND tsjlu.user_session_id =
                                                 gSessionId
                                   UNION ALL
                                   SELECT 12 AS column_order,
                                          tsjlu.jlu_jrnl_hdr_id,
                                          tsjlu.jlu_jrnl_line_number,
                                          NVL (vua2.fdr_code, jlu_attribute_2)
                                             AS fdr_code
                                     FROM temp_gui_jrnl_lines_unposted tsjlu
                                          LEFT OUTER JOIN
                                          vw_ui_attribute_2 vua2
                                             ON     tsjlu.jlu_attribute_2 =
                                                       vua2.lookup_key
                                                AND vua2.source_system_id =
                                                       gJournalHeader.jhu_jrnl_pref_static_src
                                    WHERE     tsjlu.jlu_jrnl_hdr_id =
                                                 gJournalHeader.jhu_jrnl_id
                                          AND tsjlu.user_session_id =
                                                 gSessionId
                                   UNION ALL
                                   SELECT 13 AS column_order,
                                          tsjlu.jlu_jrnl_hdr_id,
                                          tsjlu.jlu_jrnl_line_number,
                                          NVL (vua3.fdr_code, jlu_attribute_3)
                                             AS fdr_code
                                     FROM temp_gui_jrnl_lines_unposted tsjlu
                                          LEFT OUTER JOIN
                                          vw_ui_attribute_3 vua3
                                             ON     tsjlu.jlu_attribute_3 =
                                                       vua3.lookup_key
                                                AND vua3.source_system_id =
                                                       gJournalHeader.jhu_jrnl_pref_static_src
                                    WHERE     tsjlu.jlu_jrnl_hdr_id =
                                                 gJournalHeader.jhu_jrnl_id
                                          AND tsjlu.user_session_id =
                                                 gSessionId
                                   UNION ALL
                                   SELECT 14 AS column_order,
                                          tsjlu.jlu_jrnl_hdr_id,
                                          tsjlu.jlu_jrnl_line_number,
                                          NVL (vua4.fdr_code, jlu_attribute_4)
                                             AS fdr_code
                                     FROM temp_gui_jrnl_lines_unposted tsjlu
                                          LEFT OUTER JOIN
                                          vw_ui_attribute_4 vua4
                                             ON     tsjlu.jlu_attribute_4 =
                                                       vua4.lookup_key
                                                AND vua4.source_system_id =
                                                       gJournalHeader.jhu_jrnl_pref_static_src
                                    WHERE     tsjlu.jlu_jrnl_hdr_id =
                                                 gJournalHeader.jhu_jrnl_id
                                          AND tsjlu.user_session_id =
                                                 gSessionId
                                   UNION ALL
                                   SELECT 15 AS column_order,
                                          tsjlu.jlu_jrnl_hdr_id,
                                          tsjlu.jlu_jrnl_line_number,
                                          NVL (vua5.fdr_code, jlu_attribute_5)
                                             AS fdr_code
                                     FROM temp_gui_jrnl_lines_unposted tsjlu
                                          LEFT OUTER JOIN
                                          vw_ui_attribute_5 vua5
                                             ON     tsjlu.jlu_attribute_5 =
                                                       vua5.lookup_key
                                                AND vua5.source_system_id =
                                                       gJournalHeader.jhu_jrnl_pref_static_src
                                    WHERE     tsjlu.jlu_jrnl_hdr_id =
                                                 gJournalHeader.jhu_jrnl_id
                                          AND tsjlu.user_session_id =
                                                 gSessionId)) coltmp
                    WHERE     coltmp.jlu_jrnl_hdr_id = tsjlu.jlu_jrnl_hdr_id
                          AND coltmp.jlu_jrnl_line_number =
                                 tsjlu.jlu_jrnl_line_number
                 GROUP BY jlu_jrnl_hdr_id, jlu_jrnl_line_number)
       WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
             AND user_session_id = gSessionId;

      IF SQL%ROWCOUNT < 1
      THEN
         lvSuccess := FALSE;
      END IF;

      RETURN lvSuccess;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN FALSE;
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_decode_journal_lines',
                   'gui_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_decode_journal_lines;

   --********************************************************************************

   PROCEDURE prui_populate_header (
      session_id          IN VARCHAR2,
      journal_id          IN SLR_JRNL_HEADERS.JH_JRNL_ID%TYPE,
      journal_type        IN SLR_JRNL_HEADERS.JH_JRNL_TYPE%TYPE DEFAULT NULL,
      entity              IN SLR_JRNL_HEADERS.JH_JRNL_ENTITY%TYPE DEFAULT NULL,
      source_system       IN SLR_JRNL_HEADERS.JH_JRNL_SOURCE%TYPE DEFAULT NULL,
      effective_date      IN SLR_JRNL_HEADERS.JH_JRNL_DATE%TYPE DEFAULT NULL,
      reversing_date      IN DATE DEFAULT NULL, --SLR_JRNL_HEADERS.JH_JRNL_REV_DATE%TYPE       DEFAULT NULL,
      description         IN VARCHAR2 DEFAULT NULL,
      coding_convention   IN SLR_JRNL_HEADERS_UNPOSTED.JHU_JRNL_PREF_STATIC_SRC%TYPE DEFAULT NULL,
      updated_by          IN SLR_JRNL_HEADERS.JH_CREATED_BY%TYPE DEFAULT 'SYSTEM',
      overwrite_details   IN CHAR DEFAULT 'Y' --pEntityProcGroup IN  VARCHAR2             DEFAULT NULL
                                             )
   IS
      lvJournalId         NUMBER := NULL;
      lvEntityProcGroup   SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE;
   BEGIN
      gSessionId := session_id;

      IF gSessionId IS NULL
      THEN
         pr_error (1,
                   'Missing session id',
                   0,
                   'prui_populate_header',
                   'temp_gui_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         raise_application_error (-20101, 'Missing session id');
      END IF;

      IF NOT gBulkSubmission
      THEN
         -- Clear previous journals
         prui_cleardown_session_data (session_id);
      ELSE
         --bulk submitted, clear only data concerning this journal
         prui_cleardown_session_data (session_id, journal_id);
      END IF;

      -- Fetch details (with changes applied)
      BEGIN
         INSERT INTO temp_gui_jrnl_headers_unposted (
                        user_session_id,
                        jhu_jrnl_id,
                        jhu_jrnl_type,
                        jhu_jrnl_date,
                        jhu_jrnl_entity,
                        jhu_jrnl_status,
                        jhu_jrnl_status_text,
                        jhu_jrnl_process_id,
                        jhu_jrnl_description,
                        jhu_jrnl_source,
                        jhu_jrnl_source_jrnl_id,
                        jhu_jrnl_authorised_by,
                        jhu_jrnl_authorised_on,
                        jhu_jrnl_validated_by,
                        jhu_jrnl_validated_on,
                        jhu_jrnl_posted_by,
                        jhu_jrnl_posted_on,
                        jhu_jrnl_total_hash_debit,
                        jhu_jrnl_total_hash_credit,
                        jhu_jrnl_total_lines,
                        jhu_created_by,
                        jhu_created_on,
                        jhu_amended_by,
                        jhu_amended_on,
                        jhu_jrnl_pref_static_src,
                        db_state,
                        jhu_epg_id,
                        jhu_jrnl_rev_date)
            SELECT                                       /* user_session_id */
                  session_id,
                   /* jhu_jrnl_id */
                   jhu_jrnl_id,
                   /* jhu_jrnl_type */
                   DECODE (overwrite_details,
                           'Y', journal_type,
                           jhu_jrnl_type),
                   /* jhu_jrnl_date */
                   DECODE (overwrite_details,
                           'Y', effective_date,
                           jhu_jrnl_date),
                   /* jhu_jrnl_entity */
                   DECODE (overwrite_details, 'Y', entity, jhu_jrnl_entity),
                   /* jhu_jrnl_status */
                   jhu_jrnl_status,
                   /* jhu_jrnl_status_text */
                   jhu_jrnl_status_text,
                   /* jhu_jrnl_process_id */
                   jhu_jrnl_process_id,
                   /* jhu_jrnl_description */
                   DECODE (overwrite_details,
                           'Y', description,
                           jhu_jrnl_description),
                   /* jhu_jrnl_source */
                   DECODE (overwrite_details,
                           'Y', source_system,
                           jhu_jrnl_source),
                   /* jhu_jrnl_source_jrnl_id */
                   jhu_jrnl_source_jrnl_id,
                   /* jhu_jrnl_authorised_by */
                   jhu_jrnl_authorised_by,
                   /* jhu_jrnl_authorised_on */
                   jhu_jrnl_authorised_on,
                   /* jhu_jrnl_validated_by */
                   jhu_jrnl_validated_by,
                   /* jhu_jrnl_validated_on */
                   jhu_jrnl_validated_on,
                   /* jhu_jrnl_posted_by */
                   jhu_jrnl_posted_by,
                   /* jhu_jrnl_posted_on */
                   jhu_jrnl_posted_on,
                   /* jhu_jrnl_total_hash_debit */
                   jhu_jrnl_total_hash_debit,
                   /* jhu_jrnl_total_hash_credit */
                   jhu_jrnl_total_hash_credit,
                   /* jhu_jrnl_total_lines */
                   jhu_jrnl_total_lines,
                   /* jhu_created_by */
                   jhu_created_by,
                   /* jhu_created_on */
                   jhu_created_on,
                   /* jhu_amended_by */
                   DECODE (overwrite_details,
                           'Y', updated_by,
                           jhu_amended_by),
                   /* jhu_amended_on */
                   DECODE (overwrite_details, 'Y', SYSDATE, jhu_amended_on),
                   /* jhu_jrnl_pref_static_src */
                   DECODE (overwrite_details,
                           'Y', coding_convention,
                           jhu_jrnl_pref_static_src),
                   /* db_state */
                   'U',
                   /* jhu_epg_id */
                   jhu_epg_id,
                   /* jhu_jrnl_rev_date */
                   DECODE (overwrite_details,
                           'Y', reversing_date,
                           jhu_jrnl_rev_date)
              FROM gui_jrnl_headers_unposted
             WHERE jhu_jrnl_id = NVL (journal_id, -1);

         --See if journal inserted
         BEGIN
            SELECT jhu_jrnl_id
              INTO lvJournalId
              FROM temp_gui_jrnl_headers_unposted
             WHERE     jhu_jrnl_id = NVL (journal_id, -1)
                   AND user_session_id = session_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;                                             -- do nothing
         END;

         -- If failed to find it then created it
         IF lvJournalId IS NULL
         THEN
            INSERT
              INTO temp_gui_jrnl_headers_unposted (user_session_id,
                                                   jhu_jrnl_id,
                                                   jhu_jrnl_type,
                                                   jhu_jrnl_date,
                                                   jhu_jrnl_entity,
                                                   jhu_jrnl_status,
                                                   jhu_jrnl_status_text,
                                                   jhu_jrnl_process_id,
                                                   jhu_jrnl_description,
                                                   jhu_jrnl_source,
                                                   jhu_jrnl_source_jrnl_id,
                                                   jhu_jrnl_authorised_by,
                                                   jhu_jrnl_authorised_on,
                                                   jhu_jrnl_validated_by,
                                                   jhu_jrnl_validated_on,
                                                   jhu_jrnl_posted_by,
                                                   jhu_jrnl_posted_on,
                                                   jhu_jrnl_total_hash_debit,
                                                   jhu_jrnl_total_hash_credit,
                                                   jhu_jrnl_total_lines,
                                                   jhu_created_by,
                                                   jhu_created_on,
                                                   jhu_amended_by,
                                                   jhu_amended_on,
                                                   jhu_jrnl_pref_static_src,
                                                   db_state,
                                                   jhu_epg_id,
                                                   jhu_jrnl_rev_date)
            VALUES (                                     /* user_session_id */
                    session_id,
                    /* jhu_jrnl_id */
                    NVL (journal_id, -1),
                    /* jhu_jrnl_type */
                    journal_type,
                    /* jhu_jrnl_date */
                    effective_date,
                    /* jhu_jrnl_entity */
                    entity,
                    /* jhu_jrnl_status */
                    'M',
                    /* jhu_jrnl_status_text */
                    'MANUAL',
                    /* jhu_jrnl_process_id */
                    0,
                    /* jhu_jrnl_description */
                    description,
                    /* jhu_jrnl_source */
                    source_system,
                    /* jhu_jrnl_source_jrnl_id */
                    NULL,
                    /* jhu_jrnl_authorised_by */
                    NULL,
                    /* jhu_jrnl_authorised_on */
                    NULL,
                    /* jhu_jrnl_validated_by */
                    NULL,
                    /* jhu_jrnl_validated_on */
                    NULL,
                    /* jhu_jrnl_posted_by */
                    NULL,
                    /* jhu_jrnl_posted_on */
                    NULL,
                    /* jhu_jrnl_total_hash_debit */
                    0,
                    /* jhu_jrnl_total_hash_credit */
                    0,
                    /* jhu_jrnl_total_lines */
                    0,
                    /* jhu_created_by */
                    updated_by,
                    /* jhu_created_on */
                    SYSDATE,
                    /* jhu_amended_by */
                    updated_by,
                    /* jhu_amended_on */
                    SYSDATE,
                    /* jhu_jrnl_pref_static_src */
                    coding_convention,
                    /* db_state */
                    'I',
                    /* jhu_epg_id */
                    'NULL',
                    /* jhu_jrnl_rev_date */
                    reversing_date);
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'prui_populate_header.1',
                      'gui_jrnl_headers_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            RAISE;
      END;

      -- Try to retrieve previous journal line details from database
      BEGIN
         INSERT INTO temp_gui_jrnl_lines_unposted (user_session_id,
                                                   jlu_jrnl_hdr_id,
                                                   jlu_jrnl_line_number,
                                                   jlu_fak_id,
                                                   jlu_eba_id,
                                                   jlu_jrnl_status,
                                                   jlu_jrnl_status_text,
                                                   jlu_jrnl_process_id,
                                                   jlu_description,
                                                   jlu_source_jrnl_id,
                                                   jlu_effective_date,
                                                   jlu_value_date,
                                                   jlu_entity,
                                                   jlu_account,
                                                   jlu_segment_1,
                                                   jlu_segment_2,
                                                   jlu_segment_3,
                                                   jlu_segment_4,
                                                   jlu_segment_5,
                                                   jlu_segment_6,
                                                   jlu_segment_7,
                                                   jlu_segment_8,
                                                   jlu_segment_9,
                                                   jlu_segment_10,
                                                   jlu_attribute_1,
                                                   jlu_attribute_2,
                                                   jlu_attribute_3,
                                                   jlu_attribute_4,
                                                   jlu_attribute_5,
                                                   jlu_reference_1,
                                                   jlu_reference_2,
                                                   jlu_reference_3,
                                                   jlu_reference_4,
                                                   jlu_reference_5,
                                                   jlu_reference_6,
                                                   jlu_reference_7,
                                                   jlu_reference_8,
                                                   jlu_reference_9,
                                                   jlu_reference_10,
                                                   jlu_tran_ccy,
                                                   jlu_tran_amount,
                                                   jlu_base_rate,
                                                   jlu_base_ccy,
                                                   jlu_base_amount,
                                                   jlu_local_rate,
                                                   jlu_local_ccy,
                                                   jlu_local_amount,
                                                   jlu_created_by,
                                                   jlu_created_on,
                                                   jlu_amended_by,
                                                   jlu_amended_on,
                                                   db_state,
                                                   jlu_epg_id,
                                                   jlu_period_month,
                                                   jlu_period_year,
                                                   jlu_period_ltd)
            SELECT                                       /* user_session_id */
                  session_id,
                   /* jlu_jrnl_hdr_id */
                   jlu_jrnl_hdr_id,
                   /* jlu_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jlu_fak_id */
                   jlu_fak_id,
                   /* jlu_eba_id */
                   jlu_eba_id,
                   /* jlu_jrnl_status */
                   jlu_jrnl_status,
                   /* jlu_jrnl_status_text */
                   jlu_jrnl_status_text,
                   /* jlu_jrnl_process_id */
                   jlu_jrnl_process_id,
                   /* jlu_description */
                   jlu_description,
                   /* jlu_source_jrnl_id */
                   jlu_source_jrnl_id,
                   /* jlu_effective_date */
                   jlu_effective_date,
                   /* jlu_value_date */
                   jlu_value_date,
                   /* jlu_entity */
                   DECODE (overwrite_details, 'Y', entity, jlu_entity),
                   /* jlu_account */
                   jlu_account,
                   /* jlu_segment_1 */
                   jlu_segment_1,
                   /* jlu_segment_2 */
                   jlu_segment_2,
                   /* jlu_segment_3 */
                   jlu_segment_3,
                   /* jlu_segment_4 */
                   jlu_segment_4,
                   /* jlu_segment_5 */
                   jlu_segment_5,
                   /* jlu_segment_6 */
                   jlu_segment_6,
                   /* jlu_segment_7 */
                   jlu_segment_7,
                   /* jlu_segment_8 */
                   jlu_segment_8,
                   /* jlu_segment_9 */
                   jlu_segment_9,
                   /* jlu_segment_10 */
                   jlu_segment_10,
                   /* jlu_attribute_1 */
                   jlu_attribute_1,
                   /* jlu_attribute_2 */
                   jlu_attribute_2,
                   /* jlu_attribute_3 */
                   jlu_attribute_3,
                   /* jlu_attribute_4 */
                   jlu_attribute_4,
                   /* jlu_attribute_5 */
                   jlu_attribute_5,
                   /* jlu_reference_1 */
                   jlu_reference_1,
                   /* jlu_reference_2 */
                   jlu_reference_2,
                   /* jlu_reference_3 */
                   jlu_reference_3,
                   /* jlu_reference_4 */
                   jlu_reference_4,
                   /* jlu_reference_5 */
                   jlu_reference_5,
                   /* jlu_reference_6 */
                   jlu_reference_6,
                   /* jlu_reference_7 */
                   jlu_reference_7,
                   /* jlu_reference_8 */
                   jlu_reference_8,
                   /* jlu_reference_9 */
                   jlu_reference_9,
                   /* jlu_reference_10 */
                   jlu_reference_10,
                   /* jlu_tran_ccy */
                   jlu_tran_ccy,
                   /* jlu_tran_amount */
                   jlu_tran_amount,
                   /* jlu_base_rate */
                   jlu_base_rate,
                   /* jlu_base_ccy */
                   jlu_base_ccy,
                   /* jlu_base_amount */
                   jlu_base_amount,
                   /* jlu_local_rate */
                   jlu_local_rate,
                   /* jlu_local_ccy */
                   jlu_local_ccy,
                   /* jlu_local_amount */
                   jlu_local_amount,
                   /* jlu_created_by */
                   jlu_created_by,
                   /* jlu_created_on */
                   jlu_created_on,
                   /* jlu_amended_by */
                   jlu_amended_by,
                   /* jlu_amended_on */
                   jlu_amended_on,
                   /* db_state */
                   'X',
                   /* jlu_epg_id */
                   jlu_epg_id,
                   /*jlu_period_month */
                   jlu_period_month,
                   /* jlu_period_year */
                   jlu_period_year,
                   /* jlu_period_ltd */
                   jlu_period_ltd
              FROM gui_jrnl_lines_unposted
             WHERE jlu_jrnl_hdr_id = NVL (journal_id, -1);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;                                                -- do nothing
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'prui_populate_header.2',
                      'gui_jrnl_headers_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            RAISE;
      END;

      -- Insert row into global for easy access
      BEGIN
         SELECT jhu_jrnl_id,
                jhu_jrnl_type,
                jhu_jrnl_date,
                jhu_jrnl_entity,
                jhu_EPG_ID,
                jhu_jrnl_status,
                jhu_jrnl_status_text,
                jhu_jrnl_process_id,
                jhu_jrnl_description,
                jhu_jrnl_source,
                jhu_jrnl_source_jrnl_id,
                jhu_jrnl_authorised_by,
                jhu_jrnl_authorised_on,
                jhu_jrnl_validated_by,
                jhu_jrnl_validated_on,
                jhu_jrnl_posted_by,
                jhu_jrnl_posted_on,
                jhu_jrnl_total_hash_debit,
                jhu_jrnl_total_hash_credit,
                jhu_jrnl_total_lines,
                jhu_created_by,
                jhu_created_on,
                jhu_amended_by,
                jhu_amended_on,
                jhu_jrnl_pref_static_src,
                jhu_jrnl_ref_id,
                jhu_jrnl_rev_date,
                'Y'
           INTO gJournalHeader
           FROM temp_gui_jrnl_headers_unposted
          WHERE     jhu_jrnl_id = NVL (journal_id, -1)
                AND user_session_id = session_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'prui_populate_header',
                      'gui_jrnl_headers_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            RAISE;
      END;
   END prui_populate_header;

   --********************************************************************************

   PROCEDURE prui_populate_line (
      session_id          IN VARCHAR2,
      journal_id          IN SLR_JRNL_LINES.JL_JRNL_HDR_ID%TYPE,
      line_number         IN SLR_JRNL_LINES.JL_JRNL_LINE_NUMBER%TYPE,
      account             IN SLR_JRNL_LINES.JL_ACCOUNT%TYPE DEFAULT NULL,
      entity              IN SLR_JRNL_LINES.JL_ENTITY%TYPE DEFAULT NULL,
      effective_date      IN SLR_JRNL_LINES.JL_EFFECTIVE_DATE%TYPE DEFAULT NULL,
      value_date          IN SLR_JRNL_LINES.JL_VALUE_DATE%TYPE DEFAULT NULL,
      segment_1           IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_1%TYPE DEFAULT NULL,
      segment_2           IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_2%TYPE DEFAULT NULL,
      segment_3           IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_3%TYPE DEFAULT NULL,
      segment_4           IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_4%TYPE DEFAULT NULL,
      segment_5           IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_5%TYPE DEFAULT NULL,
      segment_6           IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_6%TYPE DEFAULT NULL,
      segment_7           IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_7%TYPE DEFAULT NULL,
      segment_8           IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_8%TYPE DEFAULT NULL,
      segment_9           IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_9%TYPE DEFAULT NULL,
      segment_10          IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_SEGMENT_10%TYPE DEFAULT NULL,
      attribute_1         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_ATTRIBUTE_1%TYPE DEFAULT NULL,
      attribute_2         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_ATTRIBUTE_2%TYPE DEFAULT NULL,
      attribute_3         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_ATTRIBUTE_3%TYPE DEFAULT NULL,
      attribute_4         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_ATTRIBUTE_4%TYPE DEFAULT 'MANUAL_ADJ',
      attribute_5         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_ATTRIBUTE_5%TYPE DEFAULT NULL,
      reference_1         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_1%TYPE DEFAULT NULL,
      reference_2         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_2%TYPE DEFAULT NULL,
      reference_3         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_3%TYPE DEFAULT NULL,
      reference_4         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_4%TYPE DEFAULT NULL,
      reference_5         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_5%TYPE DEFAULT NULL,
      reference_6         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_6%TYPE DEFAULT NULL,
      reference_7         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_7%TYPE DEFAULT NULL,
      reference_8         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_8%TYPE DEFAULT NULL,
      reference_9         IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_9%TYPE DEFAULT NULL,
      reference_10        IN TEMP_GUI_JRNL_LINES_UNPOSTED.JLU_REFERENCE_10%TYPE DEFAULT NULL,
      description         IN VARCHAR2 DEFAULT NULL,
      tran_currency       IN SLR_JRNL_LINES.JL_TRAN_CCY%TYPE DEFAULT NULL,
      tran_amount         IN SLR_JRNL_LINES.JL_TRAN_AMOUNT%TYPE DEFAULT NULL,
      base_currency       IN SLR_JRNL_LINES.JL_BASE_CCY%TYPE DEFAULT NULL,
      base_rate           IN SLR_JRNL_LINES.JL_BASE_RATE%TYPE DEFAULT NULL,
      base_amount         IN SLR_JRNL_LINES.JL_BASE_AMOUNT%TYPE DEFAULT NULL,
      local_currency      IN SLR_JRNL_LINES.JL_LOCAL_CCY%TYPE DEFAULT NULL,
      local_rate          IN SLR_JRNL_LINES.JL_LOCAL_RATE%TYPE DEFAULT NULL,
      local_amount        IN SLR_JRNL_LINES.JL_LOCAL_AMOUNT%TYPE DEFAULT NULL,
      --entity_proc_group IN SLR_JRNL_LINES.JL_EPG_ID%TYPE    DEFAULT NULL,
      updated_by          IN SLR_JRNL_LINES.JL_CREATED_BY%TYPE DEFAULT 'SYSTEM',
      overwrite_details   IN CHAR DEFAULT 'Y')
   IS
      lvFound         BOOLEAN;
      lvJournalLine   NUMBER;
   BEGIN
      gJournalLineNumber := NVL (line_number, -1);
      gSessionId := session_id;

      IF gSessionId IS NULL
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_populate_line',
                   'temp_gui_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         raise_application_error (-9001, 'Missing session id');
      END IF;

      -- Fetch details (with changes applied)
      BEGIN
         BEGIN
            SELECT jlu_jrnl_line_number
              INTO lvJournalLine
              FROM temp_gui_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = NVL (journal_id, -1)
                   AND jlu_jrnl_line_number = NVL (line_number, -1)
                   AND user_session_id = session_id;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               lvJournalLine := NULL;
            WHEN OTHERS
            THEN
               pr_error (1,
                         SQLERRM,
                         0,
                         'prui_populate_line',
                         'gui_jrnl_lines_unposted',
                         NULL,
                         NULL,
                         gPackageName,
                         'PL/SQL',
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL);
               RAISE;
         END;

         --Check the it exists
         IF lvJournalLine IS NOT NULL
         THEN
               UPDATE temp_gui_jrnl_lines_unposted
                  SET jlu_jrnl_status = 'M',
                      jlu_description =
                         DECODE (overwrite_details,
                                 'Y', description,
                                 jlu_description),
                      jlu_effective_date =
                         DECODE (overwrite_details,
                                 'Y', effective_date,
                                 jlu_effective_date),
                      jlu_value_date =
                         DECODE (overwrite_details,
                                 'Y', value_date,
                                 jlu_value_date),
                      jlu_entity =
                         DECODE (overwrite_details, 'Y', entity, jlu_entity),
                      jlu_account =
                         DECODE (overwrite_details, 'Y', account, jlu_account),
                      jlu_segment_1 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', segment_1,
                                    jlu_segment_1),
                            'NVS'),
                      jlu_segment_2 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', segment_2,
                                    jlu_segment_2),
                            'NVS'),
                      jlu_segment_3 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', segment_3,
                                    jlu_segment_3),
                            'NVS'),
                      jlu_segment_4 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', segment_4,
                                    jlu_segment_4),
                            'NVS'),
                      jlu_segment_5 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', segment_5,
                                    jlu_segment_5),
                            'NVS'),
                      jlu_segment_6 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', segment_6,
                                    jlu_segment_6),
                            'NVS'),
                      jlu_segment_7 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', segment_7,
                                    jlu_segment_7),
                            'NVS'),
                      jlu_segment_8 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', segment_8,
                                    jlu_segment_8),
                            'NVS'),
                      jlu_segment_9 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', segment_9,
                                    jlu_segment_9),
                            'NVS'),
                      jlu_segment_10 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', segment_10,
                                    jlu_segment_10),
                            'NVS'),
                      jlu_attribute_1 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', attribute_1,
                                    jlu_attribute_1),
                            'NVS'),
                      jlu_attribute_2 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', attribute_2,
                                    jlu_attribute_2),
                            'NVS'),
                      jlu_attribute_3 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', attribute_3,
                                    jlu_attribute_3),
                            'NVS'),
                      jlu_attribute_4 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', attribute_4,
                                    jlu_attribute_4),
                            'NVS'),
                      jlu_attribute_5 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', attribute_5,
                                    jlu_attribute_5),
                            'NVS'),
                      jlu_reference_1 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', reference_1,
                                    jlu_reference_1),
                            'NVS'),
                      jlu_reference_2 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', reference_2,
                                    jlu_reference_2),
                            'NVS'),
                      jlu_reference_3 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', reference_3,
                                    jlu_reference_3),
                            'NVS'),
                      jlu_reference_4 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', reference_4,
                                    jlu_reference_4),
                            'NVS'),
                      jlu_reference_5 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', reference_5,
                                    jlu_reference_5),
                            'NVS'),
                      jlu_reference_6 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', reference_6,
                                    jlu_reference_6),
                            'NVS'),
                      jlu_reference_7 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', reference_7,
                                    jlu_reference_7),
                            'NVS'),
                      jlu_reference_8 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', reference_8,
                                    jlu_reference_8),
                            'NVS'),
                      jlu_reference_9 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', reference_9,
                                    jlu_reference_9),
                            'NVS'),
                      jlu_reference_10 =
                         NVL (
                            DECODE (overwrite_details,
                                    'Y', reference_10,
                                    jlu_reference_10),
                            'NVS'),
                      jlu_tran_ccy =
                         DECODE (overwrite_details,
                                 'Y', tran_currency,
                                 jlu_tran_ccy),
                      jlu_tran_amount =
                         DECODE (overwrite_details,
                                 'Y', tran_amount,
                                 jlu_tran_amount),
                      jlu_base_rate =
                         DECODE (overwrite_details,
                                 'Y', base_rate,
                                 jlu_base_rate),
                      jlu_base_ccy =
                         DECODE (overwrite_details,
                                 'Y', base_currency,
                                 jlu_base_ccy),
                      jlu_base_amount =
                         DECODE (
                            overwrite_details,
                            'Y', DECODE (NVL (base_amount, 0),
                                         0, NULL,
                                         base_amount),
                            DECODE (NVL (jlu_base_amount, 0),
                                    0, NULL,
                                    jlu_base_amount)),
                      jlu_local_rate =
                         DECODE (overwrite_details,
                                 'Y', local_rate,
                                 jlu_local_rate),
                      Jlu_local_ccy =
                         DECODE (overwrite_details,
                                 'Y', local_currency,
                                 jlu_local_ccy),
                      jlu_local_amount =
                         DECODE (
                            overwrite_details,
                            'Y', DECODE (NVL (local_amount, 0),
                                         0, NULL,
                                         local_amount),
                            DECODE (NVL (jlu_local_amount, 0),
                                    0, NULL,
                                    jlu_local_amount)),
                      jlu_amended_by =
                         DECODE (overwrite_details,
                                 'Y', updated_by,
                                 jlu_amended_by),
                      jlu_amended_on =
                         DECODE (overwrite_details,
                                 'Y', SYSDATE,
                                 jlu_amended_on),
                      db_state = 'U',
                      jlu_epg_id =
                         DECODE (overwrite_details, 'Y', 'NULL', jlu_epg_id),
                      jlu_period_month = 0,
                      jlu_period_year = 0,
                      jlu_period_ltd = 0
                WHERE     jlu_jrnl_hdr_id = journal_id
                      AND jlu_jrnl_line_number = line_number
                      AND user_session_id = session_id
            RETURNING jlu_jrnl_line_number
                 INTO gJournalLineNumber;
         ELSE
            INSERT INTO temp_gui_jrnl_lines_unposted (user_session_id,
                                                      jlu_jrnl_hdr_id,
                                                      jlu_jrnl_line_number,
                                                      jlu_fak_id,
                                                      jlu_eba_id,
                                                      jlu_jrnl_status,
                                                      jlu_jrnl_status_text,
                                                      jlu_jrnl_process_id,
                                                      jlu_description,
                                                      jlu_source_jrnl_id,
                                                      jlu_effective_date,
                                                      jlu_value_date,
                                                      jlu_entity,
                                                      jlu_account,
                                                      jlu_segment_1,
                                                      jlu_segment_2,
                                                      jlu_segment_3,
                                                      jlu_segment_4,
                                                      jlu_segment_5,
                                                      jlu_segment_6,
                                                      jlu_segment_7,
                                                      jlu_segment_8,
                                                      jlu_segment_9,
                                                      jlu_segment_10,
                                                      jlu_attribute_1,
                                                      jlu_attribute_2,
                                                      jlu_attribute_3,
                                                      jlu_attribute_4,
                                                      jlu_attribute_5,
                                                      jlu_reference_1,
                                                      jlu_reference_2,
                                                      jlu_reference_3,
                                                      jlu_reference_4,
                                                      jlu_reference_5,
                                                      jlu_reference_6,
                                                      jlu_reference_7,
                                                      jlu_reference_8,
                                                      jlu_reference_9,
                                                      jlu_reference_10,
                                                      jlu_tran_ccy,
                                                      jlu_tran_amount,
                                                      jlu_base_rate,
                                                      jlu_base_ccy,
                                                      jlu_base_amount,
                                                      jlu_local_rate,
                                                      jlu_local_ccy,
                                                      jlu_local_amount,
                                                      jlu_created_by,
                                                      jlu_created_on,
                                                      jlu_amended_by,
                                                      jlu_amended_on,
                                                      db_state,
                                                      jlu_epg_id,
                                                      jlu_period_month,
                                                      jlu_period_year,
                                                      jlu_period_ltd)
                    VALUES (
                              /* user_session_id */
                              session_id,
                              /* jlu_jrnl_hdr_id */
                              NVL (journal_id, -1),
                              /* jlu_jrnl_line_number */
                              DECODE (
                                 NVL (line_number, -1),
                                 -1, NVL (
                                        (SELECT   MAX (jlu_jrnl_line_number)
                                                + 1
                                           FROM temp_gui_jrnl_lines_unposted
                                          WHERE     jlu_jrnl_hdr_id =
                                                       NVL (journal_id, -1)
                                                AND user_session_id =
                                                       gSessionId),
                                        1),
                                 line_number),
                              /* jlu_fak_id */
                              NULL,
                              /* jlu_eba_id */
                              NULL,
                              /* jlu_jrnl_status */
                              'M',
                              /* jlu_jrnl_status_text */
                              'MANUAL',
                              /* jlu_jrnl_process_id */
                              0,
                              /* jlu_description */
                              description,
                              /* jlu_source_jrnl_id */
                              NVL (journal_id, -1),
                              /* jlu_effective_date */
                              effective_date,
                              /* jlu_value_date */
                              value_date,
                              /* jlu_entity */
                              entity,
                              /* jlu_account */
                              account,
                              /* jlu_segment_1 */
                              NVL (segment_1, 'NVS'),
                              /* jlu_segment_2 */
                              NVL (segment_2, 'NVS'),
                              /* jlu_segment_3 */
                              NVL (segment_3, 'NVS'),
                              /* jlu_segment_4 */
                              NVL (segment_4, 'NVS'),
                              /* jlu_segment_5 */
                              NVL (segment_5, 'NVS'),
                              /* jlu_segment_6 */
                              NVL (segment_6, 'NVS'),
                              /* jlu_segment_7 */
                              NVL (segment_7, 'NVS'),
                              /* jlu_segment_8 */
                              NVL (segment_8, 'NVS'),
                              /* jlu_segment_9 */
                              NVL (segment_9, 'NVS'),
                              /* jlu_segment_10 */
                              NVL (segment_10, 'NVS'),
                              /* jlu_attribute_1 */
                              NVL (attribute_1, 'NVS'),
                              /* jlu_attribute_2 */
                              NVL (attribute_2, 'NVS'),
                              /* jlu_attribute_3 */
                              NVL (attribute_3, 'NVS'),
                              /* jlu_attribute_4 */
                              NVL (attribute_4, 'MANUAL_ADJ'),
                              /* jlu_attribute_5 */
                              NVL (attribute_5, 'NVS'),
                              /* jlu_reference_1 */
                              NVL (reference_1, 'NVS'),
                              /* jlu_reference_2 */
                              NVL (reference_2, 'NVS'),
                              /* jlu_reference_3 */
                              NVL (reference_3, 'NVS'),
                              /* jlu_reference_4 */
                              NVL (reference_4, 'NVS'),
                              /* jlu_reference_5 */
                              NVL (reference_5, 'NVS'),
                              /* jlu_reference_6 */
                              NVL (reference_6, 'NVS'),
                              /* jlu_reference_7 */
                              NVL (reference_7, 'NVS'),
                              /* jlu_reference_8 */
                              NVL (reference_8, 'NVS'),
                              /* jlu_reference_9 */
                              NVL (reference_9, 'NVS'),
                              /* jlu_reference_10 */
                              NVL (reference_10, 'NVS'),
                              /* jlu_tran_ccy */
                              tran_currency,
                              /* jlu_tran_amount */
                              tran_amount,
                              /* jlu_base_rate */
                              NULL,
                              /* jlu_base_ccy */
                              DECODE (NVL (base_amount, 0),
                                      0, NULL,
                                      base_currency),
                              /* jlu_base_amount */
                              DECODE (NVL (base_amount, 0),
                                      0, NULL,
                                      base_amount),
                              /* jlu_local_rate */
                              NULL,
                              /* jlu_local_ccy */
                              DECODE (NVL (local_amount, 0),
                                      0, NULL,
                                      local_currency),
                              /* jlu_local_amount */
                              DECODE (NVL (local_amount, 0),
                                      0, NULL,
                                      local_amount),
                              /* jlu_created_by */
                              updated_by,
                              /* jlu_created_on */
                              SYSDATE,
                              /* jlu_amended_by */
                              updated_by,
                              /* jlu_amended_on */
                              SYSDATE,
                              /* db_state */
                              'I',
                              /* jlu_epg_id */
                              'NULL',
                              /* jlu_period_month */
                              0,
                              /* jlu_period_year */
                              0,
                              /* jlu_period_ltd */
                              0)
              RETURNING jlu_jrnl_line_number
                   INTO gJournalLineNumber;
         END IF;
      --try to find and set entity processing group base on the line details
      /*
      **TODO
      */
      --gJrnlEntityProcGroup := fGetEntityProcGroup( NVL(journal_id,-1),gJournalLineNumber,session_id);

      /*IF gJrnlEntityProcGroup <> 'NULL'
      THEN

       UPDATE TEMP_GUI_JRNL_LINES_UNPOSTED
       SET jlu_epg_id = gJrnlEntityProcGroup
       WHERE jlu_jrnl_hdr_id = Nvl(journal_id,-1)
                    AND jlu_jrnl_line_number = gJournalLineNumber
                    AND user_session_id = session_id;

      END IF;*/

      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'prui_populate_line',
                      'gui_jrnl_lines_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            RAISE;
      END;
   END prui_populate_line;

   --********************************************************************************

   FUNCTION fnui_source_to_fdr (field_name    VARCHAR2,
                                src_sys_id    VARCHAR2,
                                src_code      VARCHAR2)
      RETURN VARCHAR2
   IS
      fdr_code    VARCHAR2 (40);
      sql_stmnt   VARCHAR2 (500);
   BEGIN
      sql_stmnt :=
            'SELECT DISTINCT fdr_code FROM vw_ui_'
         || field_name
         || ' WHERE source_system_id = '''
         || src_sys_id
         || ''' AND lookup_key ='''
         || src_code
         || '''';

      EXECUTE IMMEDIATE sql_stmnt INTO fdr_code;

      RETURN fdr_code;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN src_code;
      WHEN TOO_MANY_ROWS
      THEN
         --log the error
         pr_error (
            1,
               'More than one FDR Code found in view uiv_'
            || field_name
            || ' for source_system_id = '''
            || src_sys_id
            || ''' and lookup_key ='''
            || src_code
            || '''',
            0,
            'fnui_source_to_fdr',
            'uiv_' || field_name,
            NULL,
            NULL,
            gPackageName,
            'PL/SQL',
            NULL,
            NULL,
            NULL,
            NULL,
            src_sys_id,
            src_code,
            NULL);
         RETURN src_code;
      WHEN OTHERS
      THEN
         -- Don't create log entry for 'Table or view not found' error...
         IF SQLCODE = -942
         THEN
            --RETURN fdr_code; ASH 22-SEP-2004
            RETURN src_code;
         ELSE
            --log the error
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_source_to_fdr',
                      'uiv_' || field_name,
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      src_sys_id,
                      src_code,
                      NULL);
            RETURN fdr_code;
         END IF;
   END fnui_source_to_fdr;

   --********************************************************************************

   FUNCTION fnui_fdr_to_source (field_name    VARCHAR2,
                                src_sys_id    VARCHAR2,
                                fdr_code      VARCHAR2)
      RETURN VARCHAR2
   IS
      src_code    VARCHAR2 (40);
      sql_stmnt   VARCHAR2 (500);
   BEGIN
      sql_stmnt :=
            'SELECT DISTINCT lookup_key FROM vw_ui_'
         || field_name
         || ' WHERE source_system_id = '''
         || src_sys_id
         || ''' AND fdr_code ='''
         || fdr_code
         || ''' AND ROWNUM < 2';

      EXECUTE IMMEDIATE sql_stmnt INTO src_code;

      RETURN src_code;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN fdr_code;
      WHEN TOO_MANY_ROWS
      THEN
         --log the error
         pr_error (
            1,
               'More than One Source Code found in view vw_ui_'
            || field_name
            || ' for source_system_id = '''
            || src_sys_id
            || ''' and fdr_id ='''
            || fdr_code
            || '''',
            0,
            'fnui_fdr_to_source',
            'vw_ui_' || field_name,
            NULL,
            NULL,
            gPackageName,
            'PL/SQL',
            NULL,
            NULL,
            NULL,
            NULL,
            src_sys_id,
            fdr_code,
            NULL);
         RETURN fdr_code;
      WHEN OTHERS
      THEN
         -- Don't create log entry for 'Table or view not found' error...
         IF SQLCODE = -942
         THEN
            RETURN fdr_code;
         ELSE
            --log the error
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_fdr_to_source',
                      'vw_ui_' || field_name,
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      src_sys_id,
                      fdr_code,
                      NULL);
            RETURN fdr_code;
         END IF;
   END fnui_fdr_to_source;

   --********************************************************************************

   FUNCTION fnui_fdr_related_val (field_name VARCHAR2, fdr_code VARCHAR2)
      RETURN VARCHAR2
   IS
      related_value   VARCHAR2 (4000);
      sql_stmnt       VARCHAR2 (4000);
   BEGIN
      sql_stmnt :=
            'SELECT DISTINCT lookup_value FROM vw_ui_'
         || field_name
         || '_rel_value WHERE fdr_code = '''
         || fdr_code
         || ''' ';

      EXECUTE IMMEDIATE sql_stmnt INTO related_value;

      RETURN related_value;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
      WHEN TOO_MANY_ROWS
      THEN
         --log the error
         pr_error (
            1,
               'More than one related value FOUND IN VIEW vw_ui_'
            || field_name
            || '_rel_value FOR fdr_code ='''
            || fdr_code
            || '''',
            0,
            'fnui_fdr_related_value',
            'vw_ui_' || field_name,
            NULL,
            NULL,
            gPackageName,
            'PL/SQL',
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            fdr_code,
            NULL);
         RETURN NULL;
      WHEN OTHERS
      THEN
         -- Don't create log entry for 'Table or view not found' error...
         IF SQLCODE = -942
         THEN
            RETURN NULL;
         ELSE
            --log the error
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_fdr_related_value',
                      'vw_ui_' || field_name || '_rel_value',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      fdr_code,
                      NULL);
            RETURN NULL;
         END IF;
   END fnui_fdr_related_val;

   --********************************************************************************

   FUNCTION fnui_fdr_desc (field_name VARCHAR2, fdr_code VARCHAR2)
      RETURN VARCHAR2
   IS
      fdr_description   VARCHAR2 (2000);
      sql_stmnt         VARCHAR2 (2000);
   BEGIN
      sql_stmnt :=
            'SELECT DISTINCT fdr_description FROM vw_ui_'
         || field_name
         || ' WHERE source_system_id = ''Client Static'' and fdr_code = '''
         || fdr_code
         || '''';

      EXECUTE IMMEDIATE sql_stmnt INTO fdr_description;

      RETURN fdr_description;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
      WHEN TOO_MANY_ROWS
      THEN
         --log the error
         pr_error (
            1,
               'More than one FDR Description FOUND IN VIEW vw_ui_'
            || field_name
            || ' FOR fdr_code ='''
            || fdr_code
            || '''',
            0,
            'fnui_fdr_desc',
            'vw_ui_' || field_name,
            NULL,
            NULL,
            gPackageName,
            'PL/SQL',
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            fdr_code,
            NULL);
         RETURN NULL;
      WHEN OTHERS
      THEN
         -- Don't create log entry for 'Table or view not found' error...
         IF SQLCODE = -942
         THEN
            RETURN fdr_code;
         ELSE
            --log the error
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_fdr_desc',
                      'vw_ui_' || field_name,
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      fdr_code,
                      NULL);
            RETURN NULL;
         END IF;
   END fnui_fdr_desc;

   --********************************************************************************

   FUNCTION fnui_create_reversing_journal (orignal_jrnl_id      NUMBER,
                                           reversing_date       DATE,
                                           entity_proc_group    VARCHAR2,
                                           status               CHAR)
      RETURN BOOLEAN
   IS
      lvID   NUMBER;
   BEGIN
      lvId := fnui_get_next_journal_id;

      SAVEPOINT fnui_create_reversing_journal;

      -- Create new journal header
      INSERT INTO slr_jrnl_headers_unposted (jhu_jrnl_id,
                                             jhu_jrnl_type,
                                             jhu_jrnl_date,
                                             jhu_jrnl_entity,
                                             jhu_jrnl_status,
                                             jhu_jrnl_status_text,
                                             jhu_jrnl_process_id,
                                             jhu_jrnl_description,
                                             jhu_jrnl_source,
                                             jhu_jrnl_source_jrnl_id,
                                             jhu_jrnl_authorised_by,
                                             jhu_jrnl_authorised_on,
                                             jhu_jrnl_validated_by,
                                             jhu_jrnl_validated_on,
                                             jhu_jrnl_posted_by,
                                             jhu_jrnl_posted_on,
                                             jhu_jrnl_total_hash_debit,
                                             jhu_jrnl_total_hash_credit,
                                             jhu_jrnl_total_lines,
                                             jhu_created_by,
                                             jhu_created_on,
                                             jhu_amended_by,
                                             jhu_amended_on,
                                             jhu_jrnl_pref_static_src,
                                             jhu_manual_flag,
                                             jhu_epg_id)
         SELECT                                              /* jhu_jrnl_id */
               lvId,
                /* jhu_jrnl_type */
                jhu_jrnl_type,
                /* jhu_jrnl_date */
                reversing_date,
                /* jhu_jrnl_entity */
                jhu_jrnl_entity,
                /* jhu_jrnl_status */
                'W',
                /* jhu_jrnl_status_text */
                'Unposted',
                /* jhu_jrnl_process_id */
                0,
                /* jhu_jrnl_description */
                jhu_jrnl_description,
                /* jhu_jrnl_source */
                jhu_jrnl_source,
                /* jhu_jrnl_source_jrnl_id */
                jhu_jrnl_id,
                /* jhu_jrnl_authorised_by */
                jhu_jrnl_authorised_by,
                /* jhu_jrnl_authorised_on */
                jhu_jrnl_authorised_on,
                /* jhu_jrnl_validated_by */
                jhu_jrnl_validated_by,
                /* jhu_jrnl_validated_on */
                jhu_jrnl_validated_on,
                /* jhu_jrnl_posted_by */
                jhu_jrnl_posted_by,
                /* jhu_jrnl_posted_on */
                jhu_jrnl_posted_on,
                /* jhu_jrnl_total_hash_debit */
                jhu_jrnl_total_hash_credit,
                /* jhu_jrnl_total_hash_credit */
                jhu_jrnl_total_hash_debit,
                /* jhu_jrnl_total_lines */
                jhu_jrnl_total_lines,
                /* jhu_created_by */
                gJournalHeader.jhu_amended_by,
                /* jhu_created_on */
                SYSDATE,
                /* jhu_amended_by */
                gJournalHeader.jhu_amended_by,
                /* jhu_amended_on */
                SYSDATE,
                /* jhu_jrnl_pref_static_src */
                jhu_jrnl_pref_static_src,
                /* jhu_manual_flag */
                'Y',
                /* jhu_epg_id */
                jhu_epg_id
           FROM slr_jrnl_headers_unposted
          WHERE jhu_jrnl_id = orignal_jrnl_id;

      IF entity_proc_group IS NOT NULL AND status IS NOT NULL
      THEN
         -- Create new journal headers
         --use information about status and processing group (if present) to speed up process of finding the data
         INSERT INTO slr_jrnl_lines_unposted (jlu_jrnl_hdr_id,
                                              jlu_jrnl_line_number,
                                              jlu_fak_id,
                                              jlu_eba_id,
                                              jlu_jrnl_status,
                                              jlu_jrnl_status_text,
                                              jlu_jrnl_process_id,
                                              jlu_description,
                                              jlu_source_jrnl_id,
                                              jlu_effective_date,
                                              jlu_value_date,
                                              jlu_entity,
                                              jlu_account,
                                              jlu_segment_1,
                                              jlu_segment_2,
                                              jlu_segment_3,
                                              jlu_segment_4,
                                              jlu_segment_5,
                                              jlu_segment_6,
                                              jlu_segment_7,
                                              jlu_segment_8,
                                              jlu_segment_9,
                                              jlu_segment_10,
                                              jlu_attribute_1,
                                              jlu_attribute_2,
                                              jlu_attribute_3,
                                              jlu_attribute_4,
                                              jlu_attribute_5,
                                              jlu_reference_1,
                                              jlu_reference_2,
                                              jlu_reference_3,
                                              jlu_reference_4,
                                              jlu_reference_5,
                                              jlu_reference_6,
                                              jlu_reference_7,
                                              jlu_reference_8,
                                              jlu_reference_9,
                                              jlu_reference_10,
                                              jlu_tran_ccy,
                                              jlu_tran_amount,
                                              jlu_base_rate,
                                              jlu_base_ccy,
                                              jlu_base_amount,
                                              jlu_local_rate,
                                              jlu_local_ccy,
                                              jlu_local_amount,
                                              jlu_created_by,
                                              jlu_created_on,
                                              jlu_amended_by,
                                              jlu_amended_on,
                                              jlu_epg_id,
                                              jlu_period_month,
                                              jlu_period_year,
                                              jlu_period_ltd)
            SELECT                                       /* jlu_jrnl_hdr_id */
                  lvId,
                   /* jlu_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jlu_fak_id */
                   jlu_fak_id,
                   /* jlu_eba_id */
                   jlu_eba_id,
                   /* jlu_jrnl_status */
                   'W',
                   /* jlu_jrnl_status_text */
                   'Unposted',
                   /* jlu_jrnl_process_id */
                   0,
                   /* jlu_description */
                   jlu_description,
                   /* jlu_source_jrnl_id */
                   jlu_jrnl_hdr_id,
                   /* jlu_effective_date */
                   reversing_date,
                   /* jlu_value_date */
                   jlu_value_date,
                   /* jlu_entity */
                   jlu_entity,
                   /* jlu_account */
                   jlu_account,
                   /* jlu_segment_1 */
                   NVL (jlu_segment_1, 'NVS'),
                   /* jlu_segment_2 */
                   NVL (jlu_segment_2, 'NVS'),
                   /* jlu_segment_3 */
                   NVL (jlu_segment_3, 'NVS'),
                   /* jlu_segment_4 */
                   NVL (jlu_segment_4, 'NVS'),
                   /* jlu_segment_5 */
                   NVL (jlu_segment_5, 'NVS'),
                   /* jlu_segment_6 */
                   NVL (jlu_segment_6, 'NVS'),
                   /* jlu_segment_7 */
                   NVL (jlu_segment_7, 'NVS'),
                   /* jlu_segment_8 */
                   NVL (jlu_segment_8, 'NVS'),
                   /* jlu_segment_9 */
                   NVL (jlu_segment_9, 'NVS'),
                   /* jlu_segment_10 */
                   NVL (jlu_segment_10, 'NVS'),
                   /* jlu_attribute_1 */
                   NVL (jlu_attribute_1, 'NVS'),
                   /* jlu_attribute_2 */
                   NVL (jlu_attribute_2, 'NVS'),
                   /* jlu_attribute_3 */
                   NVL (jlu_attribute_3, 'NVS'),
                   /* jlu_attribute_4 */
                   NVL (jlu_attribute_4, 'MANUAL_ADJ'),
                   /* jlu_attribute_5 */
                   NVL (jlu_attribute_5, 'NVS'),
                   /* jlu_reference_1 */
                   jlu_reference_1,
                   /* jlu_reference_2 */
                   jlu_reference_2,
                   /* jlu_reference_3 */
                   jlu_reference_3,
                   /* jlu_reference_4 */
                   jlu_reference_4,
                   /* jlu_reference_5 */
                   jlu_reference_5,
                   /* jlu_reference_6 */
                   jlu_reference_6,
                   /* jlu_reference_7 */
                   jlu_reference_7,
                   /* jlu_reference_8 */
                   jlu_reference_8,
                   /* jlu_reference_9 */
                   jlu_reference_9,
                   /* jlu_reference_10 */
                   jlu_reference_10,
                   /* jlu_tran_ccy */
                   jlu_tran_ccy,
                   /* jlu_tran_amount */
                   -jlu_tran_amount,
                   /* jlu_base_rate */
                   jlu_base_rate,
                   /* jlu_base_ccy */
                   jlu_base_ccy,
                   /* jlu_base_amount */
                   -jlu_base_amount,
                   /* jlu_local_rate */
                   jlu_local_rate,
                   /* jlu_local_ccy */
                   jlu_local_ccy,
                   /* jlu_local_amount */
                   -jlu_local_amount,
                   /* jlu_created_by */
                   gJournalHeader.jhu_amended_by,
                   /* jlu_created_on */
                   SYSDATE,
                   /* jlu_amended_by */
                   gJournalHeader.jhu_amended_by,
                   /* jlu_amended_on */
                   SYSDATE,
                   /* jlu_epg_id */
                   jlu_epg_id,
                   /* jlu_period_month */
                   0,
                   /* jlu_period_year */
                   0,
                   /* jlu_period_ltd */
                   0
              FROM slr_jrnl_lines_unposted
             WHERE     jlu_jrnl_hdr_id = orignal_jrnl_id
                   AND jlu_jrnl_status = status
                   AND jlu_epg_id = entity_proc_group;
      ELSE /*TODO: Not sure when this can be executed.
           (Only procedure prui_reverse_journal can call this statement but there is no execution of this procedure in core code)
           */
         -- Create new journal headers
         INSERT INTO slr_jrnl_lines_unposted (jlu_jrnl_hdr_id,
                                              jlu_jrnl_line_number,
                                              jlu_fak_id,
                                              jlu_eba_id,
                                              jlu_jrnl_status,
                                              jlu_jrnl_status_text,
                                              jlu_jrnl_process_id,
                                              jlu_description,
                                              jlu_source_jrnl_id,
                                              jlu_effective_date,
                                              jlu_value_date,
                                              jlu_entity,
                                              jlu_account,
                                              jlu_segment_1,
                                              jlu_segment_2,
                                              jlu_segment_3,
                                              jlu_segment_4,
                                              jlu_segment_5,
                                              jlu_segment_6,
                                              jlu_segment_7,
                                              jlu_segment_8,
                                              jlu_segment_9,
                                              jlu_segment_10,
                                              jlu_attribute_1,
                                              jlu_attribute_2,
                                              jlu_attribute_3,
                                              jlu_attribute_4,
                                              jlu_attribute_5,
                                              jlu_reference_1,
                                              jlu_reference_2,
                                              jlu_reference_3,
                                              jlu_reference_4,
                                              jlu_reference_5,
                                              jlu_reference_6,
                                              jlu_reference_7,
                                              jlu_reference_8,
                                              jlu_reference_9,
                                              jlu_reference_10,
                                              jlu_tran_ccy,
                                              jlu_tran_amount,
                                              jlu_base_rate,
                                              jlu_base_ccy,
                                              jlu_base_amount,
                                              jlu_local_rate,
                                              jlu_local_ccy,
                                              jlu_local_amount,
                                              jlu_created_by,
                                              jlu_created_on,
                                              jlu_amended_by,
                                              jlu_amended_on,
                                              jlu_epg_id,
                                              jlu_period_month,
                                              jlu_period_year,
                                              jlu_period_ltd)
            SELECT                                       /* jlu_jrnl_hdr_id */
                  lvId,
                   /* jlu_jrnl_line_number */
                   jlu_jrnl_line_number,
                   /* jlu_fak_id */
                   jlu_fak_id,
                   /* jlu_eba_id */
                   jlu_eba_id,
                   /* jlu_jrnl_status */
                   'U',
                   /* jlu_jrnl_status_text */
                   'Unposted',
                   /* jlu_jrnl_process_id */
                   0,
                   /* jlu_description */
                   jlu_description,
                   /* jlu_source_jrnl_id */
                   jlu_jrnl_hdr_id,
                   /* jlu_effective_date */
                   reversing_date,
                   /* jlu_value_date */
                   jlu_value_date,
                   /* jlu_entity */
                   jlu_entity,
                   /* jlu_account */
                   jlu_account,
                   /* jlu_segment_1 */
                   NVL (jlu_segment_1, 'NVS'),
                   /* jlu_segment_2 */
                   NVL (jlu_segment_2, 'NVS'),
                   /* jlu_segment_3 */
                   NVL (jlu_segment_3, 'NVS'),
                   /* jlu_segment_4 */
                   NVL (jlu_segment_4, 'NVS'),
                   /* jlu_segment_5 */
                   NVL (jlu_segment_5, 'NVS'),
                   /* jlu_segment_6 */
                   NVL (jlu_segment_6, 'NVS'),
                   /* jlu_segment_7 */
                   NVL (jlu_segment_7, 'NVS'),
                   /* jlu_segment_8 */
                   NVL (jlu_segment_8, 'NVS'),
                   /* jlu_segment_9 */
                   NVL (jlu_segment_9, 'NVS'),
                   /* jlu_segment_10 */
                   NVL (jlu_segment_10, 'NVS'),
                   /* jlu_attribute_1 */
                   NVL (jlu_attribute_1, 'NVS'),
                   /* jlu_attribute_2 */
                   NVL (jlu_attribute_2, 'NVS'),
                   /* jlu_attribute_3 */
                   NVL (jlu_attribute_3, 'NVS'),
                   /* jlu_attribute_4 */
                   NVL (jlu_attribute_4, 'MANUAL_ADJ'),
                   /* jlu_attribute_5 */
                   NVL (jlu_attribute_5, 'NVS'),
                   /* jlu_reference_1 */
                   jlu_reference_1,
                   /* jlu_reference_2 */
                   jlu_reference_2,
                   /* jlu_reference_3 */
                   jlu_reference_3,
                   /* jlu_reference_4 */
                   jlu_reference_4,
                   /* jlu_reference_5 */
                   jlu_reference_5,
                   /* jlu_reference_6 */
                   jlu_reference_6,
                   /* jlu_reference_7 */
                   jlu_reference_7,
                   /* jlu_reference_8 */
                   jlu_reference_8,
                   /* jlu_reference_9 */
                   jlu_reference_9,
                   /* jlu_reference_10 */
                   jlu_reference_10,
                   /* jlu_tran_ccy */
                   jlu_tran_ccy,
                   /* jlu_tran_amount */
                   -jlu_tran_amount,
                   /* jlu_base_rate */
                   jlu_base_rate,
                   /* jlu_base_ccy */
                   jlu_base_ccy,
                   /* jlu_base_amount */
                   -jlu_base_amount,
                   /* jlu_local_rate */
                   jlu_local_rate,
                   /* jlu_local_ccy */
                   jlu_local_ccy,
                   /* jlu_local_amount */
                   -jlu_local_amount,
                   /* jlu_created_by */
                   gJournalHeader.jhu_amended_by,
                   /* jlu_created_on */
                   SYSDATE,
                   /* jlu_amended_by */
                   gJournalHeader.jhu_amended_by,
                   /* jlu_amended_on */
                   SYSDATE,
                   /* jlu_epg_id */
                   jlu_epg_id,
                   /* jlu_period_month */
                   0,
                   /* jlu_period_year */
                   0,
                   /* jlu_period_ltd */
                   0
              FROM slr_jrnl_lines_unposted
             WHERE jlu_jrnl_hdr_id = orignal_jrnl_id;
      END IF;

      -- Succeeded
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK TO SAVEPOINT fnui_create_reversing_journal;
         prui_set_status (orignal_jrnl_id, gSTATUS_ERROR);
         prui_log_error (
            orignal_jrnl_id,
            0,
            1030,
               'Failed to create reversing journal for '
            || reversing_date
            || '.');

         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_create_reversing_journal',
                   'slr_jrnl_headers_unposted/slr_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_create_reversing_journal;

   --********************************************************************************

   -- For use with R2 code base
   FUNCTION fnui_create_copy_journal (original_jrnl_id NUMBER)
      RETURN BOOLEAN
   IS
   BEGIN
      -- Succeeded
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_create_copy_journal',
                   'slr_jrnl_headers_unposted/slr_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_create_copy_journal;

   --********************************************************************************

   FUNCTION fnui_resync_journal_lines
      RETURN BOOLEAN
   IS
   BEGIN
      -- Update lines with changes to effective date, entity, etc

      gJournalHeader.jhu_epg_id :=
         fGetEntityProcGroup (gJournalHeader.jhu_jrnl_id, gSessionId);

      IF gJournalHeader.jhu_jrnl_id <> -1
      THEN
         BEGIN
            SAVEPOINT resync_journal_lines;

            UPDATE gui_jrnl_lines_unposted
               SET jlu_effective_date = gJournalHeader.jhu_jrnl_date,
                   jlu_entity = gJournalHeader.jhu_jrnl_entity,
                   jlu_fak_id = 0,
                   jlu_eba_id = 0,
                   jlu_jrnl_status = 'M',
                   jlu_jrnl_status_text = 'MANUAL',
                   JLU_EPG_ID = gJournalHeader.jhu_epg_id
             WHERE jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id;

            IF SQL%ROWCOUNT > 0
            THEN
               /* increment journal version since change on core table has been made */
               prui_increment_journal_version (gJournalHeader.jhu_jrnl_id,
                                               gJournalHeader.jhu_amended_by);
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               ROLLBACK TO SAVEPOINT resync_journal_lines;
               pr_error (1,
                         SQLERRM,
                         0,
                         'fnui_resync_journal_lines.1',
                         'gui_jrnl_headers_unposted',
                         NULL,
                         NULL,
                         gPackageName,
                         'PL/SQL',
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL);
               RETURN FALSE;
         END;
      END IF;

      BEGIN
         UPDATE temp_gui_jrnl_lines_unposted
            SET jlu_effective_date = gJournalHeader.jhu_jrnl_date,
                jlu_entity = gJournalHeader.jhu_jrnl_entity,
                jlu_fak_id = 0,
                jlu_eba_id = 0,
                jlu_jrnl_status = 'M',
                jlu_jrnl_status_text = 'MANUAL',
                JLU_EPG_ID = gJournalHeader.jhu_epg_id
          WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId;
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_resync_journal_lines.2',
                      'gui_jrnl_headers_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            RETURN FALSE;
      END;

      RETURN TRUE;
   END fnui_resync_journal_lines;

   --********************************************************************************

   FUNCTION fnui_merge_header
      RETURN BOOLEAN
   IS
      lvDebits            NUMBER;
      lvCredits           NUMBER;
      lvLines             NUMBER;
      lvId                NUMBER;
      lvEntityProcGroup   VARCHAR2 (60);
   BEGIN
      -- Do final update of stats
      BEGIN
         SELECT COUNT (*) AS total_lines,
                SUM (DECODE (SIGN (jlu_tran_amount), -1, jlu_tran_amount, 0))
                   AS total_hash_credit,
                SUM (DECODE (SIGN (jlu_tran_amount), 1, jlu_tran_amount, 0))
                   AS total_hash_debit,
                MAX (jlu_epg_id) AS entity_proc_group
           INTO lvLines,
                lvCredits,
                lvDebits,
                lvEntityProcGroup
           FROM temp_gui_jrnl_lines_unposted
          WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId;
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_merge_header.1',
                      'gui_jrnl_headers_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            RETURN FALSE;
      END;

      BEGIN
         UPDATE temp_gui_jrnl_headers_unposted
            SET jhu_jrnl_total_hash_debit = lvDebits,
                jhu_jrnl_total_hash_credit = lvCredits,
                jhu_jrnl_total_lines = lvLines,
                --set entity group for header base on journal lines
                jhu_epg_id = lvEntityProcGroup
          WHERE     jhu_jrnl_id = gJournalHeader.jhu_jrnl_id
                AND user_session_id = gSessionId;
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_merge_header.2',
                      'gui_jrnl_headers_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            RETURN FALSE;
      END;

      -- Merge the header
      BEGIN
         IF NOT fnui_does_journal_exist (gJournalHeader.jhu_jrnl_id)
         THEN
            lvId := fnui_get_next_journal_id;

            INSERT INTO gui_jrnl_headers_unposted (
                           jhu_jrnl_id,
                           jhu_jrnl_type,
                           jhu_jrnl_date,
                           jhu_jrnl_entity,
                           jhu_jrnl_status,
                           jhu_jrnl_status_text,
                           jhu_jrnl_process_id,
                           jhu_jrnl_description,
                           jhu_jrnl_source,
                           jhu_jrnl_source_jrnl_id,
                           jhu_jrnl_authorised_by,
                           jhu_jrnl_authorised_on,
                           jhu_jrnl_validated_by,
                           jhu_jrnl_validated_on,
                           jhu_jrnl_posted_by,
                           jhu_jrnl_posted_on,
                           jhu_jrnl_total_hash_debit,
                           jhu_jrnl_total_hash_credit,
                           jhu_jrnl_total_lines,
                           jhu_created_by,
                           jhu_created_on,
                           jhu_amended_by,
                           jhu_amended_on,
                           jhu_jrnl_pref_static_src,
                           jhu_manual_flag,
                           jhu_epg_id,
                           jhu_version,
                           jhu_jrnl_rev_date)
               SELECT                                        /* jhu_jrnl_id */
                     lvId,
                      /* jhu_jrnl_type */
                      tsjhu.jhu_jrnl_type,
                      /* jhu_jrnl_date */
                      tsjhu.jhu_jrnl_date,
                      /* jhu_jrnl_entity */
                      tsjhu.jhu_jrnl_entity,
                      /* jhu_jrnl_status */
                      'M',
                      /* jhu_jrnl_status_text */
                      'MANUAL',
                      /* jhu_jrnl_process_id */
                      tsjhu.jhu_jrnl_process_id,
                      /* jhu_jrnl_description */
                      tsjhu.jhu_jrnl_description,
                      /* jhu_jrnl_source */
                      tsjhu.jhu_jrnl_source,
                      /* jhu_jrnl_source_jrnl_id */
                      lvId,
                      /* jhu_jrnl_authorised_by */
                      tsjhu.jhu_jrnl_authorised_by,
                      /* jhu_jrnl_authorised_on */
                      tsjhu.jhu_jrnl_authorised_on,
                      /* jhu_jrnl_validated_by */
                      tsjhu.jhu_jrnl_validated_by,
                      /* jhu_jrnl_validated_on */
                      tsjhu.jhu_jrnl_validated_on,
                      /* jhu_jrnl_posted_by */
                      tsjhu.jhu_jrnl_posted_by,
                      /* jhu_jrnl_posted_on */
                      tsjhu.jhu_jrnl_posted_on,
                      /* jhu_jrnl_total_hash_debit */
                      NVL (tsjhu.jhu_jrnl_total_hash_debit, 0),
                      /* jhu_jrnl_total_hash_credit */
                      NVL (tsjhu.jhu_jrnl_total_hash_credit, 0),
                      /* jhu_jrnl_total_lines */
                      NVL (tsjhu.jhu_jrnl_total_lines, 0),
                      /* jhu_created_by */
                      tsjhu.jhu_created_by,
                      /* jhu_created_on */
                      tsjhu.jhu_created_on,
                      /* jhu_amended_by */
                      tsjhu.jhu_amended_by,
                      /* jhu_amended_on */
                      tsjhu.jhu_amended_on,
                      /* jhu_jrnl_pref_static_src */
                      tsjhu.jhu_jrnl_pref_static_src,
                      /* jhu_manual_flag */
                      'Y',
                      /* jhu_epg_id */
                      tsjhu.jhu_epg_id,
                      /* jhu_version */
                      1,
                      /* jhu_jrnl_rev_date */
                      tsjhu.jhu_jrnl_rev_date
                 FROM temp_gui_jrnl_headers_unposted tsjhu
                WHERE     tsjhu.jhu_jrnl_id = -1
                      AND tsjhu.user_session_id = gSessionId;

            -- Update temporary tables
            UPDATE temp_gui_jrnl_headers_unposted
               SET jhu_jrnl_id = lvId
             WHERE jhu_jrnl_id = -1 AND user_session_id = gSessionId;

            UPDATE temp_gui_jrnl_lines_unposted
               SET jlu_jrnl_hdr_id = lvId
             WHERE jlu_jrnl_hdr_id = -1 AND user_session_id = gSessionId;

            UPDATE temp_gui_jrnl_line_errors
               SET jle_jrnl_hdr_id = lvId
             WHERE jle_jrnl_hdr_id = -1 AND user_session_id = gSessionId;

            gJournalVersion := 1;
         ELSE
            UPDATE gui_jrnl_headers_unposted sjhu
               SET (jhu_jrnl_type,
                    jhu_jrnl_date,
                    jhu_jrnl_entity,
                    jhu_jrnl_status,
                    jhu_jrnl_description,
                    jhu_jrnl_source,
                    jhu_jrnl_total_hash_debit,
                    jhu_jrnl_total_hash_credit,
                    jhu_jrnl_total_lines,
                    jhu_amended_by,
                    jhu_amended_on,
                    jhu_epg_id,
                    jhu_version,
                    jhu_jrnl_rev_date) =
                      (SELECT tsjhu.jhu_jrnl_type,
                              tsjhu.jhu_jrnl_date,
                              tsjhu.jhu_jrnl_entity,
                              'M',
                              tsjhu.jhu_jrnl_description,
                              tsjhu.jhu_jrnl_source,
                              NVL (tsjhu.jhu_jrnl_total_hash_debit, 0),
                              NVL (tsjhu.jhu_jrnl_total_hash_credit, 0),
                              NVL (tsjhu.jhu_jrnl_total_lines, 0),
                              tsjhu.jhu_amended_by,
                              tsjhu.jhu_amended_on,
                              tsjhu.jhu_epg_id,
                              gJournalVersion + 1,
                              tsjhu.jhu_jrnl_rev_date
                         FROM temp_gui_jrnl_headers_unposted tsjhu
                        WHERE     tsjhu.jhu_jrnl_id = sjhu.jhu_jrnl_id
                              AND tsjhu.user_session_id = gSessionId)
             WHERE sjhu.jhu_jrnl_id = gJournalHeader.jhu_jrnl_id;

            gJournalVersion := gJournalVersion + 1;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_merge_header.5',
                      'gui_jrnl_headers_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            RETURN FALSE;
      END;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_merge_header',
                   'gui_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_merge_header;

   --********************************************************************************

   FUNCTION fnui_merge_lines
      RETURN BOOLEAN
   IS
   BEGIN
      -- Update rows that exists
      BEGIN
         UPDATE gui_jrnl_lines_unposted sjlu
            SET (jlu_fak_id,
                 jlu_eba_id,
                 jlu_jrnl_status,
                 jlu_jrnl_status_text,
                 jlu_jrnl_process_id,
                 jlu_description,
                 jlu_source_jrnl_id,
                 jlu_effective_date,
                 jlu_value_date,
                 jlu_entity,
                 jlu_account,
                 jlu_segment_1,
                 jlu_segment_2,
                 jlu_segment_3,
                 jlu_segment_4,
                 jlu_segment_5,
                 jlu_segment_6,
                 jlu_segment_7,
                 jlu_segment_8,
                 jlu_segment_9,
                 jlu_segment_10,
                 jlu_attribute_1,
                 jlu_attribute_2,
                 jlu_attribute_3,
                 jlu_attribute_4,
                 jlu_attribute_5,
                 jlu_reference_1,
                 jlu_reference_2,
                 jlu_reference_3,
                 jlu_reference_4,
                 jlu_reference_5,
                 jlu_reference_6,
                 jlu_reference_7,
                 jlu_reference_8,
                 jlu_reference_9,
                 jlu_reference_10,
                 jlu_tran_ccy,
                 jlu_tran_amount,
                 jlu_base_rate,
                 jlu_base_ccy,
                 jlu_base_amount,
                 jlu_local_rate,
                 jlu_local_ccy,
                 jlu_local_amount,
                 jlu_created_by,
                 jlu_created_on,
                 jlu_amended_by,
                 jlu_amended_on,
                 jlu_epg_id,
                 jlu_period_month,
                 jlu_period_year,
                 jlu_period_ltd) =
                   (SELECT 0,       -- ensure FAK_ID are cleared for all lines
                           0,       -- ensure EBA_ID are cleared for all lines
                           'M',
                           'MANUAL',
                           tsjlu.jlu_jrnl_process_id,
                           tsjlu.jlu_description,
                           tsjlu.jlu_source_jrnl_id,
                           tsjlu.jlu_effective_date,
                           tsjlu.jlu_value_date,
                           tsjlu.jlu_entity,
                           tsjlu.jlu_account,
                           NVL (tsjlu.jlu_segment_1, 'NVS'),
                           NVL (tsjlu.jlu_segment_2, 'NVS'),
                           NVL (tsjlu.jlu_segment_3, 'NVS'),
                           NVL (tsjlu.jlu_segment_4, 'NVS'),
                           NVL (tsjlu.jlu_segment_5, 'NVS'),
                           NVL (tsjlu.jlu_segment_6, 'NVS'),
                           NVL (tsjlu.jlu_segment_7, 'NVS'),
                           NVL (tsjlu.jlu_segment_8, 'NVS'),
                           NVL (tsjlu.jlu_segment_9, 'NVS'),
                           NVL (tsjlu.jlu_segment_10, 'NVS'),
                           NVL (tsjlu.jlu_attribute_1, 'NVS'),
                           NVL (tsjlu.jlu_attribute_2, 'NVS'),
                           NVL (tsjlu.jlu_attribute_3, 'NVS'),
                           NVL (tsjlu.jlu_attribute_4, 'MANUAL_ADJ'),
                           NVL (tsjlu.jlu_attribute_5, 'NVS'),
                           tsjlu.jlu_reference_1,
                           tsjlu.jlu_reference_2,
                           tsjlu.jlu_reference_3,
                           tsjlu.jlu_reference_4,
                           tsjlu.jlu_reference_5,
                           tsjlu.jlu_reference_6,
                           tsjlu.jlu_reference_7,
                           tsjlu.jlu_reference_8,
                           tsjlu.jlu_reference_9,
                           tsjlu.jlu_reference_10,
                           tsjlu.jlu_tran_ccy,
                           tsjlu.jlu_tran_amount,
                           tsjlu.jlu_base_rate,
                           tsjlu.jlu_base_ccy,
                           tsjlu.jlu_base_amount,
                           tsjlu.jlu_local_rate,
                           tsjlu.jlu_local_ccy,
                           tsjlu.jlu_local_amount,
                           tsjlu.jlu_created_by,
                           tsjlu.jlu_created_on,
                           tsjlu.jlu_amended_by,
                           tsjlu.jlu_amended_on,
                           tsjlu.jlu_epg_id,
                           NVL (tsjlu.jlu_period_month, 0),
                           NVL (tsjlu.jlu_period_year, 0),
                           NVL (tsjlu.jlu_period_ltd, 0)
                      FROM temp_gui_jrnl_lines_unposted tsjlu
                     WHERE     sjlu.jlu_jrnl_hdr_id = tsjlu.jlu_jrnl_hdr_id
                           AND sjlu.jlu_jrnl_line_number =
                                  tsjlu.jlu_jrnl_line_number
                           AND tsjlu.user_session_id = gSessionId)
          WHERE sjlu.jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;                                                -- do nothing
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_merge_lines.1',
                      'gui_jrnl_lines_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            RETURN FALSE;
      END;

      -- Insert new rows
      BEGIN
         INSERT INTO gui_jrnl_lines_unposted (jlu_jrnl_hdr_id,
                                              jlu_jrnl_line_number,
                                              jlu_fak_id,
                                              jlu_eba_id,
                                              jlu_jrnl_status,
                                              jlu_jrnl_status_text,
                                              jlu_jrnl_process_id,
                                              jlu_description,
                                              jlu_source_jrnl_id,
                                              jlu_effective_date,
                                              jlu_value_date,
                                              jlu_entity,
                                              jlu_account,
                                              jlu_segment_1,
                                              jlu_segment_2,
                                              jlu_segment_3,
                                              jlu_segment_4,
                                              jlu_segment_5,
                                              jlu_segment_6,
                                              jlu_segment_7,
                                              jlu_segment_8,
                                              jlu_segment_9,
                                              jlu_segment_10,
                                              jlu_attribute_1,
                                              jlu_attribute_2,
                                              jlu_attribute_3,
                                              jlu_attribute_4,
                                              jlu_attribute_5,
                                              jlu_reference_1,
                                              jlu_reference_2,
                                              jlu_reference_3,
                                              jlu_reference_4,
                                              jlu_reference_5,
                                              jlu_reference_6,
                                              jlu_reference_7,
                                              jlu_reference_8,
                                              jlu_reference_9,
                                              jlu_reference_10,
                                              jlu_tran_ccy,
                                              jlu_tran_amount,
                                              jlu_base_rate,
                                              jlu_base_ccy,
                                              jlu_base_amount,
                                              jlu_local_rate,
                                              jlu_local_ccy,
                                              jlu_local_amount,
                                              jlu_created_by,
                                              jlu_created_on,
                                              jlu_amended_by,
                                              jlu_amended_on,
                                              jlu_epg_id,
                                              jlu_period_month,
                                              jlu_period_year,
                                              jlu_period_ltd)
            SELECT                                       /* jlu_jrnl_hdr_id */
                  gJournalHeader.jhu_jrnl_id,
                   /* jlu_jrnl_line_number */
                   tsjlu.jlu_jrnl_line_number,
                   /* jlu_fak_id */
                   0,
                   /* jlu_eba_id */
                   0,
                   /* jlu_jrnl_status */
                   'M',
                   /* jlu_jrnl_status_text */
                   'MANUAL',
                   /* jlu_jrnl_process_id */
                   tsjlu.jlu_jrnl_process_id,
                   /* jlu_description */
                   tsjlu.jlu_description,
                   /* jlu_source_jrnl_id */
                   gJournalHeader.jhu_jrnl_id,
                   /* jlu_effective_date */
                   tsjlu.jlu_effective_date,
                   /* jlu_value_date */
                   tsjlu.jlu_value_date,
                   /* jlu_entity */
                   tsjlu.jlu_entity,
                   /* jlu_account */
                   tsjlu.jlu_account,
                   /* jlu_segment_1 */
                   NVL (tsjlu.jlu_segment_1, 'NVS'),
                   /* jlu_segment_2 */
                   NVL (tsjlu.jlu_segment_2, 'NVS'),
                   /* jlu_segment_3 */
                   NVL (tsjlu.jlu_segment_3, 'NVS'),
                   /* jlu_segment_4 */
                   NVL (tsjlu.jlu_segment_4, 'NVS'),
                   /* jlu_segment_5 */
                   NVL (tsjlu.jlu_segment_5, 'NVS'),
                   /* jlu_segment_6 */
                   NVL (tsjlu.jlu_segment_6, 'NVS'),
                   /* jlu_segment_7 */
                   NVL (tsjlu.jlu_segment_7, 'NVS'),
                   /* jlu_segment_8 */
                   NVL (tsjlu.jlu_segment_8, 'NVS'),
                   /* jlu_segment_9 */
                   NVL (tsjlu.jlu_segment_9, 'NVS'),
                   /* jlu_segment_10 */
                   NVL (tsjlu.jlu_segment_10, 'NVS'),
                   /* jlu_attribute_1 */
                   NVL (tsjlu.jlu_attribute_1, 'NVS'),
                   /* jlu_attribute_2 */
                   NVL (tsjlu.jlu_attribute_2, 'NVS'),
                   /* jlu_attribute_3 */
                   NVL (tsjlu.jlu_attribute_3, 'NVS'),
                   /* jlu_attribute_4 */
                   NVL (tsjlu.jlu_attribute_4, 'MANUAL_ADJ'),
                   /* jlu_attribute_5 */
                   NVL (tsjlu.jlu_attribute_5, 'NVS'),
                   /* jlu_reference_1 */
                   tsjlu.jlu_reference_1,
                   /* jlu_reference_2 */
                   tsjlu.jlu_reference_2,
                   /* jlu_reference_3 */
                   tsjlu.jlu_reference_3,
                   /* jlu_reference_4 */
                   tsjlu.jlu_reference_4,
                   /* jlu_reference_5 */
                   tsjlu.jlu_reference_5,
                   /* jlu_reference_6 */
                   tsjlu.jlu_reference_6,
                   /* jlu_reference_7 */
                   tsjlu.jlu_reference_7,
                   /* jlu_reference_8 */
                   tsjlu.jlu_reference_8,
                   /* jlu_reference_9 */
                   tsjlu.jlu_reference_9,
                   /* jlu_reference_10 */
                   tsjlu.jlu_reference_10,
                   /* jlu_tran_ccy */
                   tsjlu.jlu_tran_ccy,
                   /* jlu_tran_amount */
                   tsjlu.jlu_tran_amount,
                   /* jlu_base_rate */
                   tsjlu.jlu_base_rate,
                   /* jlu_base_ccy */
                   tsjlu.jlu_base_ccy,
                   /* jlu_base_amount */
                   tsjlu.jlu_base_amount,
                   /* jlu_local_rate */
                   tsjlu.jlu_local_rate,
                   /* jlu_local_ccy */
                   tsjlu.jlu_local_ccy,
                   /* jlu_local_amount */
                   tsjlu.jlu_local_amount,
                   /* jlu_created_by */
                   tsjlu.jlu_created_by,
                   /* jlu_created_on */
                   tsjlu.jlu_created_on,
                   /* jlu_amended_by */
                   tsjlu.jlu_amended_by,
                   /* jlu_amended_on */
                   tsjlu.jlu_amended_on,
                   /* jlu_epg_id */
                   tsjlu.jlu_epg_id,
                   /* jlu_period_month */
                   NVL (tsjlu.jlu_period_month, 0),
                   /* jlu_period_year */
                   NVL (tsjlu.jlu_period_year, 0),
                   /* jlu_period_ltd */
                   NVL (tsjlu.jlu_period_ltd, 0)
              FROM temp_gui_jrnl_lines_unposted tsjlu
             WHERE     tsjlu.jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
                   AND tsjlu.user_session_id = gSessionId
                   AND NOT EXISTS
                              (SELECT 1
                                 FROM gui_jrnl_lines_unposted sjlu
                                WHERE     sjlu.jlu_jrnl_hdr_id =
                                             tsjlu.jlu_jrnl_hdr_id
                                      AND sjlu.jlu_jrnl_line_number =
                                             tsjlu.jlu_jrnl_line_number
                                      AND sjlu.JLU_EPG_ID = tsjlu.JLU_EPG_ID);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;                                                -- do nothing
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_merge_lines.2',
                      'gui_jrnl_lines_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            RETURN FALSE;
      END;

      /* increment journal version since change on core table has been made */
      prui_increment_journal_version (gJournalHeader.jhu_jrnl_id,
                                      gJournalHeader.jhu_amended_by);

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_merge_lines',
                   'gui_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_merge_lines;

   --********************************************************************************

   FUNCTION fnui_get_reversing_journal (journal_id IN NUMBER)
      RETURN NUMBER
   IS
      lv_jrnl_id   NUMBER := NULL;
   BEGIN
      BEGIN
         SELECT NULL                                         --jhu_jrnl_ref_id
           INTO lv_jrnl_id
           FROM slr_jrnl_headers_unposted
          WHERE jhu_jrnl_id = journal_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'fnui_get_reversing_journal',
                      'slr_jrnl_headers_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            RAISE;
      END;

      RETURN lv_jrnl_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_get_reversing_journal',
                   'slr_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN -1;
   END fnui_get_reversing_journal;

   --********************************************************************************

   FUNCTION fnui_get_adjustment_journal (journal_id IN NUMBER)
      RETURN NUMBER
   IS
      lv_jrnl_id   NUMBER := NULL;
   BEGIN
      /* Removed 1.2 functionality for 1.1
      BEGIN
         SELECT jhu_jrnl_id
         INTO   lv_jrnl_id
         FROM   slr_jrnl_headers_unposted
         WHERE  jhu_jrnl_ref_id = journal_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              NULL;
         WHEN OTHERS THEN
              pr_error(1, SQLERRM, 0, 'fnui_get_adjustment_journal', 'slr_jrnl_headers_unposted', NULL, NULL, gPackageName, 'PL/SQL', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
              RAISE;
      END; */

      RETURN lv_jrnl_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_get_adjustment_journal',
                   'slr_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN -1;
   END fnui_get_adjustment_journal;

   --********************************************************************************

   FUNCTION fnui_journal_edit_permission (owner VARCHAR2, editor VARCHAR2)
      RETURN BOOLEAN
   IS
      lvFound     NUMBER;
      lvSuccess   BOOLEAN;
   BEGIN
      lvSuccess := TRUE;

      /* Removed 1.2 functionality for 1.1
      -- If owner is null then assume that journal does not exists
      -- and therefore allow the user to create the journal
      IF owner IS NULL THEN
         RETURN lvSuccess;
      END IF;

      -- If the owner and editor are the same automatically allow
      -- the upsert of the journal
      IF UPPER(owner) = UPPER(editor) THEN
         RETURN lvSuccess;
      END IF;

      -- Restrict user to view journals in their groups or sub-groups
      BEGIN
          SELECT  1
          INTO lvFound
          FROM
          ( SELECT 1
              FROM   ui_meta_user_groups child
                          INNER JOIN ui_meta_user_groups parent
                                ON child.mmg_group_id = parent.mmg_group_id
              WHERE  child.mmg_user_id = owner
              AND    parent.mmg_user_id = editor
              UNION
              SELECT 1
              FROM   ui_meta_group_hierarchy
                          INNER JOIN ui_meta_user_groups parent
                                ON mgh_parent_id = parent.mmg_group_id
                          INNER JOIN ui_meta_user_groups child
                                ON mgh_child_id = child.mmg_group_id
              WHERE  child.mmg_user_id = owner
              AND    parent.mmg_user_id = editor ) tmp;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
              prui_log_error(gJournalLine.jlu_jrnl_hdr_id, gJournalLine.jlu_jrnl_line_number, 9999,
                                      gJournalHeader.jhu_amended_by||' is not allowed to access journals created by '||gJournalHeader.jhu_created_by);
              lvSuccess := FALSE;
          WHEN OTHERS THEN
              pr_error(1, SQLERRM, 0, 'fnui_journal_edit_permission', 'ui_meta_group_hierarchy', NULL, NULL, gPackageName, 'PL/SQL', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
              lvSuccess := FALSE;
      END; */

      RETURN lvSuccess;
   END fnui_journal_edit_permission;

   --********************************************************************************

   FUNCTION fnui_get_next_journal_id
      RETURN NUMBER
   IS
      lvSeq   NUMBER;
   BEGIN
      /*SELECT SEQ_SLR_JRNL_HEADERS_ID.NEXTVAL
      INTO lvSeq
      FROM DUAL;
*/
      -- sequence replace with function
      -- to get header id in the similar way as in Import process it is done
      lvSeq := FNSLR_GETHEADERID;

      gJournalHeader.jhu_jrnl_id := lvSeq;

      RETURN lvSeq;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_get_next_journal_id',
                   'seq_slr_jrnl_headers_id',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RAISE;
   END fnui_get_next_journal_id;

   --********************************************************************************

   FUNCTION fnui_get_next_line_no
      RETURN NUMBER
   IS
      lvSeq   NUMBER;
   BEGIN
      SELECT MAX (jlu_jrnl_line_number) + 1
        INTO lvSeq
        FROM temp_gui_jrnl_lines_unposted
       WHERE     jlu_jrnl_hdr_id = gJournalHeader.jhu_jrnl_id
             AND user_session_id = gSessionId;

      RETURN lvSeq;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         lvSeq := 1;
         RETURN lvSeq;
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_get_next_line_no',
                   'gui_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN -1;
   END fnui_get_next_line_no;

   --********************************************************************************

   FUNCTION fnui_does_journal_exist (journal_id NUMBER)
      RETURN BOOLEAN
   IS
      lvFound     NUMBER := 0;
      lvSuccess   BOOLEAN;
   BEGIN
      lvSuccess := FALSE;

      SELECT 1
        INTO lvFound
        FROM gui_jrnl_headers_unposted
       WHERE jhu_jrnl_id = journal_id;

      IF lvFound > 0
      THEN
         lvSuccess := TRUE;
      END IF;

      RETURN lvSuccess;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN FALSE;
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_does_journal_exist',
                   'gui_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_does_journal_exist;

   --********************************************************************************

   FUNCTION fnui_does_line_exist (journal_id NUMBER, line_no NUMBER)
      RETURN BOOLEAN
   IS
      lvFound     NUMBER;
      lvSuccess   BOOLEAN;
   BEGIN
      lvSuccess := FALSE;

      SELECT 1
        INTO lvFound
        FROM gui_jrnl_lines_unposted
       WHERE jlu_jrnl_hdr_id = journal_id AND jlu_jrnl_line_number = line_no;

      lvSuccess := (lvFound = 1);

      RETURN lvSuccess;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN FALSE;
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_does_line_exist',
                   'gui_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_does_line_exist;

   --********************************************************************************

   PROCEDURE prui_process_param_list (list_string    IN     VARCHAR2,
                                      return_array      OUT array_list,
                                      array_count       OUT NUMBER)
   IS
      NEXT_ITEM    VARCHAR2 (2000);
      loop_count   NUMBER (12);
   BEGIN
      return_array := array_list ();

      array_count := 1;

      -- Build error_ids collection based on the error_list parameter
      FOR loop_count IN 1 .. LENGTH (list_string)
      LOOP
         IF SUBSTR (list_string, loop_count, 1) = '|'
         THEN
            -- Add to collection
            return_array.EXTEND;
            return_array (array_count) := TRIM (NEXT_ITEM);
            NEXT_ITEM := '';

            -- Increment collection count (as long as it is not end of list)
            IF loop_count < LENGTH (list_string)
            THEN
               array_count := array_count + 1;
            END IF;
         ELSIF loop_count = LENGTH (list_string)
         THEN
            -- Add last character onto string
            NEXT_ITEM := NEXT_ITEM || SUBSTR (list_string, loop_count, 1);

            -- Add to collection
            return_array.EXTEND;
            return_array (array_count) := TRIM (NEXT_ITEM);
            NEXT_ITEM := '';
         ELSE
            -- Build string for error collection from parameter
            NEXT_ITEM := NEXT_ITEM || SUBSTR (list_string, loop_count, 1);
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_process_param_list',
                   NULL,
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
   END prui_process_param_list;

   PROCEDURE prui_update_header_stats (journal_id IN NUMBER)
   IS
      lvDebits            NUMBER (38, 3);
      lvCredits           NUMBER (38, 3);
      lvLines             NUMBER (38);
      lvEntityProcGroup   VARCHAR2 (60);
   BEGIN
      -- Get new stats
      SELECT COUNT (*) AS total_lines,
             SUM (DECODE (SIGN (jlu_tran_amount), -1, jlu_tran_amount, 0))
                AS total_hash_credit,
             SUM (DECODE (SIGN (jlu_tran_amount), 1, jlu_tran_amount, 0))
                AS total_hash_debit,
             MAX (jlu_epg_id) AS entity_proc_group
        INTO lvLines,
             lvCredits,
             lvDebits,
             lvEntityProcGroup
        FROM gui_jrnl_lines_unposted
       WHERE jlu_jrnl_hdr_id = journal_id;

      -- Update journal header
      UPDATE gui_jrnl_headers_unposted
         SET jhu_jrnl_total_hash_debit = NVL (lvDebits, 0),
             jhu_jrnl_total_hash_credit = NVL (lvCredits, 0),
             jhu_jrnl_total_lines = NVL (lvLines, 0),
             --set entity group for header base on journal lines
             jhu_epg_id = lvEntityProcGroup,
             jhu_version = gJournalVersion + 1
       WHERE jhu_jrnl_id = journal_id;

      gJournalVersion := gJournalVersion + 1;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_update_header_stats',
                   NULL,
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
   END prui_update_header_stats;

   --********************************************************************************

   PROCEDURE prui_reorder_journal_lines (journal_id NUMBER)
   IS
      CURSOR cur_journal_lines (jrnl_id NUMBER)
      IS
           SELECT jlu_jrnl_line_number
             FROM gui_jrnl_lines_unposted
            WHERE jlu_jrnl_hdr_id = jrnl_id
         ORDER BY jlu_jrnl_line_number ASC;

      line_number        NUMBER;
      next_line_number   NUMBER := 1;
   BEGIN
      SAVEPOINT prui_reorder_journal_lines;


      FOR rec IN cur_journal_lines (journal_id)
      LOOP
         UPDATE gui_jrnl_lines_unposted
            SET jlu_jrnl_line_number = next_line_number
          WHERE     jlu_jrnl_hdr_id = journal_id
                AND jlu_jrnl_line_number = rec.jlu_jrnl_line_number
                AND jlu_jrnl_line_number <> next_line_number;

         next_line_number := next_line_number + 1;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK TO SAVEPOINT prui_reorder_journal_lines;
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_reorder_journal_lines',
                   NULL,
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RAISE;
   END prui_reorder_journal_lines;

   --********************************************************************************

   PROCEDURE prui_cleardown_session_data (
      session_id      VARCHAR2,
      journal_id   IN NUMBER DEFAULT NULL)
   IS
   BEGIN
      IF journal_id IS NULL
      THEN
         DELETE FROM temp_gui_jrnl_line_errors
               WHERE user_session_id = session_id;

         DELETE FROM temp_gui_jrnl_lines_unposted
               WHERE user_session_id = session_id;

         DELETE FROM temp_gui_jrnl_headers_unposted
               WHERE user_session_id = session_id;
      ELSE
         DELETE FROM temp_gui_jrnl_line_errors
               WHERE     user_session_id = session_id
                     AND jle_jrnl_hdr_id = journal_id;

         DELETE FROM temp_gui_jrnl_lines_unposted
               WHERE     user_session_id = session_id
                     AND jlu_jrnl_hdr_id = journal_id;

         DELETE FROM temp_gui_jrnl_headers_unposted
               WHERE     user_session_id = session_id
                     AND jhu_jrnl_id = journal_id;
      END IF;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_cleardown_session_data',
                   NULL,
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
   END prui_cleardown_session_data;

   --********************************************************************************

   FUNCTION fnui_check_calendar
      RETURN BOOLEAN
   IS
      lvFound   NUMBER (12);
   BEGIN
      SELECT 1
        INTO lvFound
        FROM SLR_ENTITY_DAYS
       WHERE     ed_entity_set =
                    gEntityConfiguration.ent_periods_and_days_set
             AND ROWNUM = 1;

      RETURN TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         pr_error (
            1,
               'SLR calendar is not configured correctly for entity '
            || gEntityConfiguration.ent_entity,
            0,
            'fnui_check_calendar',
            'slr_entity_days/slr_entity_periods',
            NULL,
            NULL,
            gPackageName,
            'PL/SQL',
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL);
         prui_log_error (
            gJournalHeader.jhu_jrnl_id,
            0,
            1003,
               'SLR calendar is not configured correctly for entity '
            || gEntityConfiguration.ent_entity);
         RETURN FALSE;
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_check_calendar',
                   'slr_entity_days',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_check_calendar;

   --********************************************************************************

   PROCEDURE prui_get_calendar_details (business_date            IN     DATE,
                                        period_days_set          IN     VARCHAR2,
                                        entity                   IN     VARCHAR2,
                                        previous_period_starts      OUT DATE,
                                        previous_period_ends        OUT DATE,
                                        period_starts               OUT DATE,
                                        previous_date               OUT DATE,
                                        next_date                   OUT DATE,
                                        period_ends                 OUT DATE,
                                        next_period_ends            OUT DATE,
                                        next_period_starts          OUT DATE)
   IS
   BEGIN
      SELECT period_start,
             period_end,
             prev_bus_date,
             next_bus_date,
             fist_day_of_prev_mon,
             fist_day_of_next_mon,
             last_day_of_prev_mon,
             last_day_of_next_mon
        INTO period_starts,
             period_ends,
             previous_date,
             next_date,
             previous_period_starts,
             next_period_starts,
             previous_period_ends,
             next_period_ends
        FROM (SELECT ed_date,
                     MIN (
                        ed_date)
                     OVER (
                        PARTITION BY ed_entity_set,
                                     TO_CHAR (ed_date, 'yyyy'),
                                     TO_CHAR (ed_date, 'mm')
                        ORDER BY ed_date, ed_entity_set)
                        AS period_start_monthly,
                     MAX (
                        ed_date)
                     OVER (
                        PARTITION BY ed_entity_set,
                                     TO_CHAR (ed_date, 'yyyy'),
                                     TO_CHAR (ed_date, 'mm')
                        ORDER BY ed_date DESC, ed_entity_set)
                        AS period_end_monthly,
                     LAG (
                        ed_date,
                        1)
                     OVER (PARTITION BY ed_entity_set
                           ORDER BY ed_date, ed_entity_set)
                        AS prev_bus_date,
                     LEAD (
                        ed_date,
                        1)
                     OVER (PARTITION BY ed_entity_set
                           ORDER BY ed_date, ed_entity_set)
                        AS next_bus_date
                FROM SLR_ENTITY_DAYS
               WHERE ed_entity_set = period_days_set AND ed_status = 'O')
             days,
             (SELECT LAG (
                        EP_BUS_PERIOD_START)
                     OVER (PARTITION BY ep_entity
                           ORDER BY EP_BUS_YEAR, EP_BUS_PERIOD, ep_entity)
                        AS fist_day_of_prev_mon,
                     LEAD (
                        EP_BUS_PERIOD_START)
                     OVER (PARTITION BY ep_entity
                           ORDER BY EP_BUS_YEAR, EP_BUS_PERIOD, ep_entity)
                        AS fist_day_of_next_mon,
                     LAG (
                        EP_BUS_PERIOD_END,
                        1)
                     OVER (PARTITION BY ep_entity
                           ORDER BY EP_BUS_YEAR, EP_BUS_PERIOD, ep_entity)
                        AS last_day_of_prev_mon,
                     LEAD (
                        EP_BUS_PERIOD_END,
                        1)
                     OVER (PARTITION BY ep_entity
                           ORDER BY EP_BUS_YEAR, EP_BUS_PERIOD, ep_entity)
                        AS last_day_of_next_mon,
                     ep_cal_period_start period_start,
                     ep_cal_period_end period_end
                FROM SLR_ENTITY_PERIODS
               WHERE ep_entity = entity AND ep_period_type != 0) periods
       WHERE     business_date <= period_end       --periods.ep_cal_period_end
             AND business_date >= period_start   --periods.ep_cal_period_start
             AND TRUNC (ed_date) = TRUNC (business_date);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         pr_error (
            1,
            'SLR calendar is not configured correctly for entity ' || entity,
            0,
            'prui_get_calendar_details',
            'slr_entity_days',
            NULL,
            NULL,
            gPackageName,
            'PL/SQL',
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL);

         IF NVL (gJournalLineNumber, -1) < 1
         THEN
            prui_log_error (
               gJournalHeader.jhu_jrnl_id,
               0,
               1003,
                  'SLR calendar is not configured correctly for entity '
               || entity);
         ELSE
            prui_log_error (
               gJournalHeader.jhu_jrnl_id,
               gJournalLineNumber,
               1003,
                  'SLR calendar is not configured correctly for entity '
               || entity);
         END IF;
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_get_calendar_details',
                   'slr_entity_days',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
   END prui_get_calendar_details;

   --********************************************************************************


   PROCEDURE prui_update_unprocessed_jrnls (status_from   IN     CHAR,
                                            status_to     IN     CHAR,
                                            list_string   IN     VARCHAR2,
                                            success          OUT CHAR)
   IS
      journal_list   array_list := array_list ();
      list_count     NUMBER;
   BEGIN
      success := 'Y';
      prui_process_param_list (list_string, journal_list, list_count);

      FOR loop_count IN 1 .. list_count
      LOOP
         BEGIN
            UPDATE slr_jrnl_headers_unposted
               SET jhu_jrnl_status = status_to
             WHERE     jhu_jrnl_status = status_from
                   AND jhu_jrnl_id = journal_list (loop_count);
         EXCEPTION
            WHEN OTHERS
            THEN
               pr_error (1,
                         SQLERRM,
                         0,
                         'prui_update_unprocessed_jrnls',
                         'slr_jrnl_headers_unposted',
                         NULL,
                         NULL,
                         gPackageName,
                         'PL/SQL',
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL);
               --pr_error(1, 'Update of jhu_jrnl_status field for journal id: '|| journal_list(loop_count)||' from technical status: '||status_from||' to original status: '|| status_to||' failed. Please run manually prui_removed_failed_jrnls procedure to fix status value.' , 0, 'prui_update_unprocessed_jrnls', 'slr_jrnl_headers_unposted', NULL, NULL, gPackageName, 'PL/SQL', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
               success := 'N';
               EXIT;
         END;

         IF success = 'N'
         THEN
            ROLLBACK;
         ELSE
            COMMIT;
         END IF;
      END LOOP;
   END prui_update_unprocessed_jrnls;

   PROCEDURE prui_removed_failed_jrnls (
      status       IN CHAR,
      journal_id   IN SLR_JRNL_HEADERS_UNPOSTED.JHU_JRNL_ID%TYPE)
   IS
   BEGIN
      BEGIN
         UPDATE slr_jrnl_headers_unposted
            SET jhu_jrnl_status = status
          WHERE jhu_jrnl_id = journal_id;

         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            pr_error (1,
                      SQLERRM,
                      0,
                      'prui_removed_failed_jrnls',
                      'slr_jrnl_headers_unposted',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
      END;
   END prui_removed_failed_jrnls;

   --********************************************************************************



   -- ---------------------------------------------------------------------------
   -- Function to retrieve Entity Processing Group for given pJrnlHdrID
   -- Notes:
   --      based on TEMP_GUI_JRNL_LINES_UNPOSTED table
   -- ---------------------------------------------------------------------------
   FUNCTION fGetEntityProcGroup (
      pJrnlHdrID   IN SLR_JRNL_HEADERS_UNPOSTED.JHU_JRNL_ID%TYPE,
      session_id   IN VARCHAR2)
      RETURN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE
   AS
      s_proc_name                  VARCHAR2 (80)
                                      := 'PGUI_MANUAL_JOURNAL.fGetEntityProcGroup';
      s_table_name                 VARCHAR2 (32);
      vEPG_DIMENSION_column_name   SLR_ENTITY_PROC_GROUP_CONFIG.EPGC_JLU_COLUMN_NAME%TYPE;
      v_entity_proc_group          SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE; -- returned
      v_sql                        VARCHAR (1000);
   BEGIN
      ----------------------------------------------------------------------------
      -- Get column name which defines Entity Group mapping.
      -- vEPG_DIMENSION_column_name is a column name of SLR_JRNL_LINES_UNPOSTED table
      -- Assume there is exactly one row, but don't validate it.
      ----------------------------------------------------------------------------
      s_table_name := 'SLR_ENTITY_PROC_GROUP_CONFIG';

      BEGIN
         SELECT MAX (EPGC_JLU_COLUMN_NAME)
           INTO vEPG_DIMENSION_column_name
           FROM SLR_ENTITY_PROC_GROUP_CONFIG;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            -- It is not an error when SLR_ENTITY_PROC_GROUP_CONFIG is empty
            NULL;
      END;

      --------------------------------------------------------------------------------------------------
      -- Use vEPG_DIMENSION_column_name to retrieve Entity Processing Group from TEMP_GUI_JRNL_LINES_UNPOSTED.
      -- If vEPG_DIMENSION_column_name is null then skip condition against EPG_DIMENSION.
      --------------------------------------------------------------------------------------------------
      s_table_name := 'SLR_ENTITY_PROC_GROUP';

      v_sql := ' SELECT  DISTINCT EPG_ID
			FROM    TEMP_GUI_JRNL_LINES_UNPOSTED, SLR_ENTITY_PROC_GROUP
			WHERE
				JLU_JRNL_HDR_ID = :pJrnlHdrID
			AND USER_SESSION_ID = :session_id
			AND JLU_ENTITY = EPG_ENTITY';

      IF vEPG_DIMENSION_column_name IS NOT NULL
      THEN
         v_sql :=
               v_sql
            || ' AND (EPG_DIMENSION IS NULL OR EPG_DIMENSION = '
            || vEPG_DIMENSION_column_name
            || ') ';
      END IF;

      EXECUTE IMMEDIATE v_sql
         INTO v_entity_proc_group
         USING pJrnlHdrID, session_id;

      RETURN v_entity_proc_group;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         -- will be validated and mark as error during further validation phase
         RETURN 'NULL';
      WHEN TOO_MANY_ROWS
      THEN
         -- will be validated and mark as error during further validation phase
         RETURN 'NULL';
      WHEN OTHERS
      THEN
         -- Log message
         pr_error (
            0,
               'Errors during retrieving Entity Processing Group for Jrnl Header: '
            || pJrnlHdrID,
            0,
            s_proc_name,
            s_table_name,
            NULL,
            'Entity',
            'SLR',
            'PL/SQL',
            SQLCODE);
         RAISE;
   END fGetEntityProcGroup;



   PROCEDURE prui_setSubLgrGenLastBalForBD (p_generate IN CHAR DEFAULT 'N')
   AS
      v_generate   BOOLEAN := FALSE;
   BEGIN
      IF UPPER (p_generate) = 'Y'
      THEN
         v_generate := TRUE;
      END IF;

      gvSubLedgerGenLastBalForBD := v_generate;
   END prui_setSubLgrGenLastBalForBD;

   FUNCTION fnui_validate_jrnl_type
      RETURN BOOLEAN
   IS
      lvFound     NUMBER := NULL;
      lvSuccess   BOOLEAN;
   BEGIN
      lvSuccess := TRUE;

      BEGIN
         /* validate journal type against entity configuration */
         IF gEntityConfiguration.ent_adjustment_flag = 'N'
         THEN
            SELECT 1
              INTO lvFound
              FROM slr.slr_ext_jrnl_types
             WHERE     ejt_type = gJournalHeader.jhu_jrnl_type
                   AND (   (    ejt_balance_type_1 = 20
                            AND ejt_balance_type_2 IS NULL)
                        OR (    ejt_balance_type_2 = 20
                            AND ejt_balance_type_1 IS NULL));

            IF lvFound > 0
            THEN
               prui_log_error (
                  gJournalHeader.jhu_jrnl_id,
                  0,
                  1023,
                     'The entity ['
                  || gJournalHeader.jhu_jrnl_entity
                  || '] does not allow adjustments to be processed.');
               lvSuccess := FALSE;
            END IF;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
         WHEN OTHERS
         THEN
            fdr.pr_error (1,
                          NULL,
                          0,
                          'fnui_validate_jrnl_type.1',
                          'temp_gui_jrnl_headers_unposted',
                          NULL,
                          NULL,
                          NULL,
                          'PL/SQL',
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          SQLCODE);
            lvSuccess := FALSE;
      END;


      RETURN lvSuccess;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_validate_jrnl_type',
                   'temp_gui_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RETURN FALSE;
   END fnui_validate_jrnl_type;


   PROCEDURE prui_increment_journal_version (
      journal_id   IN NUMBER,
      updated_by   IN SLR_JRNL_HEADERS.JH_CREATED_BY%TYPE)
   IS
   BEGIN
      UPDATE gui_jrnl_headers_unposted
         SET JHU_VERSION = gJournalVersion + 1,
             jhu_amended_on = SYSDATE,
             jhu_amended_by = updated_by
       --,JHU_LAST_SESSION_ID = session_id
       WHERE jhu_jrnl_id = journal_id AND JHU_VERSION = gJournalVersion;

      IF SQL%ROWCOUNT > 0
      THEN
         gJournalVersion := gJournalVersion + 1;
      ELSE
         raise_application_error (-20015, 'Cannot increment journal version');
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_increment_journal_version',
                   'gui_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RAISE;
   END prui_increment_journal_version;

   PROCEDURE prui_calculate_journal_rates (journal_id IN NUMBER)
   IS
   BEGIN
      UPDATE gui_jrnl_lines_unposted
         SET jlu_base_rate =
                CASE
                   WHEN jlu_tran_amount = 0
                   THEN
                      0
                   WHEN LENGTH (
                           ABS (
                              TRUNC (
                                 ROUND (jlu_base_amount / jlu_tran_amount, 9)))) >
                           9
                   THEN
                      0
                   ELSE
                      ROUND (jlu_base_amount / jlu_tran_amount, 9)
                END,
             jlu_local_rate =
                CASE
                   WHEN jlu_tran_amount = 0
                   THEN
                      0
                   WHEN LENGTH (
                           ABS (
                              TRUNC (
                                 ROUND (jlu_local_amount / jlu_tran_amount,
                                        9)))) > 9
                   THEN
                      0
                   ELSE
                      ROUND (jlu_local_amount / jlu_tran_amount, 9)
                END
       WHERE jlu_jrnl_hdr_id = journal_id;

      -- Execute any custom processes
      pgui_jrnl_custom.prui_update_rates (journal_id);
   EXCEPTION
      WHEN OTHERS
      THEN
         --prui_log_error(journal_id, 0, 9999, 'Failed to update base and local rates for journal '||TO_CHAR(journal_id));
         NULL;
   END prui_calculate_journal_rates;

   PROCEDURE prui_add_jrnl_to_posting_queue (journal_id          IN NUMBER,
                                             epg_id              IN VARCHAR2,
                                             jrnl_num_of_lines   IN NUMBER)
   IS
   BEGIN
      INSERT INTO T_UI_MADJ_POSTING_QUEUE (pq_jrnl_id,
                                           pq_epg_id,
                                           pq_input_time,
                                           pq_jrnl_num_of_lines,
                                           pq_status)
           VALUES (journal_id,
                   epg_id,
                   SYSDATE,
                   jrnl_num_of_lines,
                   'U');

      prui_set_status (journal_id, gSTATUS_QUEUED_FOR_POSTING);
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END prui_add_jrnl_to_posting_queue;

   PROCEDURE prui_authorise_journal (
      session_id        IN     VARCHAR2,
      journal_id        IN     SLR_JRNL_HEADERS.JH_JRNL_ID%TYPE,
      updated_by        IN     SLR_JRNL_HEADERS.JH_AMENDED_BY%TYPE,
      journal_version   IN     gui_jrnl_headers_unposted.jhu_version%TYPE,
      success              OUT CHAR)
   IS
      vEntityProcGroupName   VARCHAR2 (20);
      lvValidateState        CHAR (1);
      lvReversingDate        DATE;
      v_jrnl_num_of_lines    NUMBER (10, 0);
   BEGIN
      success := 'S';

      IF session_id IS NULL
      THEN
         raise_application_error (-20101, 'Missing session id.');
      END IF;

      IF journal_version IS NULL
      THEN
         raise_application_error (-20102, 'Missing journal version.');
      END IF;

      gSessionId := session_id;
      gJournalVersion := journal_version;

      BEGIN
         /* lock journal so only one user can edit it. Procedure commits changes, signals journal_locked_exeption if journal already locked */
         prui_lock_journal (journal_id, updated_by);

         /* check journal version in case there were any changes since journal was displayed on the screen. Signals stale_journal_exception if journal version is different*/
         prui_check_journal_version (journal_id, gJournalVersion);
      EXCEPTION
         WHEN journal_locked_exeption
         THEN
            prui_log_error (
               journal_id,
               0,
               6699,
               'Journal is already locked by another user. Cannot proceed.');
            success := 'L';
            RETURN;
         WHEN stale_journal_exception
         THEN
            prui_log_error (
               journal_id,
               0,
               6698,
               'Journal does not exist or was modified by another user. Cannot proceed.');

            /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
            prui_unlock_journal (journal_id, updated_by);
            success := 'V';
            RETURN;
         WHEN OTHERS
         THEN
            RAISE;
      END;

      prui_populate_header (session_id          => session_id,
                            journal_id          => journal_id,
                            overwrite_details   => 'N');

      --prui_clear_errors(journal_id);

      --validate journal--
      /*  do not validate as it should be ok by now
   BEGIN
         IF fnui_validate_journal_header <> gSTATE_OK THEN
             success := 'F';
         END IF;

       EXCEPTION
           WHEN OTHERS THEN
               pr_error(1, SQLERRM, 0, 'prui_authorise_journal', 'gui_jrnl_headers_unposted', NULL, NULL, gPackageName, 'PL/SQL', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
               success := 'F';
       END; */

      IF NOT fnui_get_journal_type
      THEN
         success := 'F';
      END IF;

      IF NOT fnui_get_entity
      THEN
         success := 'F';
      END IF;

      -- Exit if errors
      IF (success = 'F' OR fnui_any_errors (journal_id))
      THEN
         prui_log_error (
            journal_id,
            0,
            1031,
            'Journal failed validation. Unable to authorise journal');

         -- Persist errors in database
         prui_write_errors_to_database (journal_id);

         --set status to error
         prui_set_status (journal_id, 'E');

         success := 'F';

         /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
         prui_unlock_journal (journal_id, updated_by);


         COMMIT;
         RETURN;
      END IF;

      -- reorder lines
      prui_reorder_journal_lines (journal_id);

      -- Execute any custom processes
      pgui_jrnl_custom.prui_authorise_journal (journal_id);

      SELECT JHU_EPG_ID, jhu_jrnl_total_lines
        INTO vEntityProcGroupName, v_jrnl_num_of_lines
        FROM GUI_JRNL_HEADERS_UNPOSTED
       WHERE JHU_JRNL_ID = journal_id;


      BEGIN
         SAVEPOINT add_jrnl_to_posting_queue;

         UPDATE gui_jrnl_headers_unposted
            SET jhu_jrnl_authorised_by = updated_by,
                jhu_jrnl_authorised_on = SYSDATE
          WHERE jhu_jrnl_id = journal_id;

         --add journal to posting queue
         prui_add_jrnl_to_posting_queue (journal_id,
                                         vEntityProcGroupName,
                                         v_jrnl_num_of_lines);
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK TO SAVEPOINT add_jrnl_to_posting_queue;
            prui_log_error (journal_id,
                            0,
                            9999,
                            'Failed to add journal to the posting queue.');
            prui_write_errors_to_database (journal_id);
            --commit;
            RAISE;
      END;

      -- Persist errors in database
      prui_write_errors_to_database (journal_id);


      /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
      prui_unlock_journal (journal_id, updated_by);
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_authorise_journal',
                   'gui_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);

         /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
         prui_unlock_journal (journal_id, updated_by);
         success := 'F';
   END prui_authorise_journal;

   PROCEDURE prui_upsert_attachment (
      session_id        IN     VARCHAR2,
      journal_id        IN     SLR_JRNL_HEADERS.JH_JRNL_ID%TYPE,
      file_no           IN     gui_jrnl_file.JF_FILE_NO%TYPE,
      file_name         IN     gui_jrnl_file.JF_FILE_NAME%TYPE,
      file_comment      IN     gui_jrnl_file.JF_COMMENT%TYPE,
      mime_type         IN     gui_jrnl_file.jf_mime_type%TYPE,
      attachment        IN     gui_jrnl_file.JF_FILE%TYPE,
      updated_by        IN     SLR_JRNL_HEADERS.JH_AMENDED_BY%TYPE,
      journal_version   IN     gui_jrnl_headers_unposted.jhu_version%TYPE,
      success              OUT CHAR)
   IS
      v_file_no   NUMBER (10);
   BEGIN
      success := 'S';

      IF session_id IS NULL
      THEN
         raise_application_error (-20101, 'Missing session id.');
      END IF;

      IF journal_version IS NULL
      THEN
         raise_application_error (-20102, 'Missing journal version.');
      END IF;

      gSessionId := session_id;
      gJournalVersion := journal_version;

      BEGIN
         /* lock journal so only one user can edit it. Procedure commits changes, signals journal_locked_exeption if journal already locked */
         prui_lock_journal (journal_id, updated_by);

         /* check journal version in case there were any changes since journal was displayed on the screen. Signals stale_journal_exception if journal version is different*/
         prui_check_journal_version (journal_id, gJournalVersion);
      EXCEPTION
         WHEN journal_locked_exeption
         THEN
            prui_log_error (
               journal_id,
               0,
               6699,
               'Journal is already locked by another user. Cannot proceed.');
            success := 'L';
            RETURN;
         WHEN stale_journal_exception
         THEN
            prui_log_error (
               journal_id,
               0,
               6698,
               'Journal does not exist or was modified by another user. Cannot proceed.');

            /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
            prui_unlock_journal (journal_id, updated_by);
            success := 'V';
            RETURN;
         WHEN OTHERS
         THEN
            RAISE;
      END;


      IF NVL (file_no, 0) = 0
      THEN
         SELECT NVL (MAX (JF_FILE_NO), 0) + 1
           INTO v_file_no
           FROM GUI_JRNL_FILE
          WHERE JF_JRNL_HDR_ID = journal_id;

         INSERT INTO GUI_JRNL_FILE (JF_JRNL_HDR_ID,
                                    JF_FILE_NO,
                                    JF_FILE_NAME,
                                    JF_FILE,
                                    JF_COMMENT,
                                    JF_MIME_TYPE,
                                    JF_CREATED_BY,
                                    JF_CREATED_ON,
                                    JF_AMENDED_BY,
                                    JF_AMENDED_ON)
              VALUES (journal_id,
                      v_file_no,
                      file_name,
                      attachment,
                      file_comment,
                      mime_type,
                      updated_by,
                      SYSDATE,
                      updated_by,
                      SYSDATE);
      ELSE
         IF attachment IS NULL
         THEN
            UPDATE GUI_JRNL_FILE
               SET JF_COMMENT = file_comment,
                   JF_AMENDED_BY = updated_by,
                   JF_AMENDED_ON = SYSDATE
             WHERE JF_JRNL_HDR_ID = journal_id AND JF_FILE_NO = file_no;
         ELSE
            DELETE FROM GUI_JRNL_FILE
                  WHERE JF_JRNL_HDR_ID = journal_id AND JF_FILE_NO = file_no;

            INSERT INTO GUI_JRNL_FILE (JF_JRNL_HDR_ID,
                                       JF_FILE_NO,
                                       JF_FILE_NAME,
                                       JF_FILE,
                                       JF_COMMENT,
                                       JF_MIME_TYPE,
                                       JF_CREATED_BY,
                                       JF_CREATED_ON,
                                       JF_AMENDED_BY,
                                       JF_AMENDED_ON)
                 VALUES (journal_id,
                         file_no,
                         file_name,
                         attachment,
                         file_comment,
                         mime_type,
                         updated_by,
                         SYSDATE,
                         updated_by,
                         SYSDATE);
         END IF;
      END IF;

      IF SQL%ROWCOUNT < 1
      THEN
         raise_application_error (-20103, 'Failed to upsert attachment.');
      END IF;

      prui_increment_journal_version (journal_id, updated_by);

      /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
      prui_unlock_journal (journal_id, updated_by);
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_upsert_attachment',
                   'gui_jrnl_file',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);

         /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
         prui_unlock_journal (journal_id, updated_by);
         success := 'F';
   END prui_upsert_attachment;

   PROCEDURE prui_delete_attachments (
      session_id        IN     VARCHAR2,
      journal_id        IN     SLR_JRNL_HEADERS.JH_JRNL_ID%TYPE,
      file_no_list      IN     VARCHAR2,
      updated_by        IN     SLR_JRNL_HEADERS.JH_AMENDED_BY%TYPE,
      journal_version   IN     gui_jrnl_headers_unposted.jhu_version%TYPE,
      success              OUT CHAR)
   IS
      attachment_list   array_list := array_list ();
      list_count        NUMBER (12);
      loop_count        NUMBER (12);
      v_file_no         NUMBER (10);
      v_success_count   NUMBER (5) := 0;
      v_failure_count   NUMBER (5) := 0;
   BEGIN
      success := 'S';

      IF session_id IS NULL
      THEN
         raise_application_error (-20101, 'Missing session id.');
      END IF;

      IF journal_version IS NULL
      THEN
         raise_application_error (-20102, 'Missing journal version.');
      END IF;

      gSessionId := session_id;
      gJournalVersion := journal_version;

      BEGIN
         /* lock journal so only one user can edit it. Procedure commits changes, signals journal_locked_exeption if journal already locked */
         prui_lock_journal (journal_id, updated_by);

         /* check journal version in case there were any changes since journal was displayed on the screen. Signals stale_journal_exception if journal version is different*/
         prui_check_journal_version (journal_id, gJournalVersion);
      EXCEPTION
         WHEN journal_locked_exeption
         THEN
            prui_log_error (
               journal_id,
               0,
               6699,
               'Journal is already locked by another user. Cannot proceed.');
            success := 'L';
            RETURN;
         WHEN stale_journal_exception
         THEN
            prui_log_error (
               journal_id,
               0,
               6698,
               'Journal does not exist or was modified by another user. Cannot proceed.');

            /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
            prui_unlock_journal (journal_id, updated_by);
            success := 'V';
            RETURN;
         WHEN OTHERS
         THEN
            RAISE;
      END;


      prui_process_param_list (file_no_list, attachment_list, list_count);

      FOR loop_count IN 1 .. list_count
      LOOP
         BEGIN
            v_file_no := attachment_list (loop_count);

            DELETE FROM GUI_JRNL_FILE
                  WHERE     JF_JRNL_HDR_ID = journal_id
                        AND JF_FILE_NO = v_file_no;

            IF SQL%ROWCOUNT > 0
            THEN
               v_success_count := v_success_count + 1;
            ELSE
               prui_log_error (
                  journal_id,
                  0,
                  1071,
                  'Journal Attachment ' || v_file_no || ' does not exist');
               v_failure_count := v_failure_count + 1;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_failure_count := v_failure_count + 1;
               pr_error (1,
                         SQLERRM,
                         0,
                         'prui_delete_attachments',
                         'gui_jrnl_file',
                         NULL,
                         NULL,
                         gPackageName,
                         'PL/SQL',
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL);
               prui_log_error (
                  journal_id,
                  0,
                  1070,
                  'Unable to delete Journal Attachment ' || v_file_no);
         END;
      END LOOP;

      /* reorder file numbers */
      FOR jrnl_file_cursor
         IN (  SELECT jf_jrnl_hdr_id,
                      jf_file_no AS old_no,
                      ROW_NUMBER ()
                         OVER (PARTITION BY jf_jrnl_hdr_id ORDER BY jf_file_no)
                         AS new_no
                 FROM gui_jrnl_file
                WHERE jf_jrnl_hdr_id = journal_id
             ORDER BY jf_file_no)
      LOOP
         UPDATE gui_jrnl_file
            SET jf_file_no = jrnl_file_cursor.new_no
          WHERE     jf_jrnl_hdr_id = jrnl_file_cursor.jf_jrnl_hdr_id
                AND jf_file_no = jrnl_file_cursor.old_no;
      END LOOP;

      IF (v_success_count > 0 AND v_failure_count > 0)
      THEN
         success := 'P';
         /* increment journal version since change on core table has been made */
         prui_increment_journal_version (journal_id, updated_by);
      ELSIF v_failure_count > 0
      THEN
         success := 'F';
      ELSE
         success := 'S';
         /* increment journal version since change on core table has been made */
         prui_increment_journal_version (journal_id, updated_by);
      END IF;



      /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
      prui_unlock_journal (journal_id, updated_by);
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_delete_attachments',
                   'gui_jrnl_file',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);

         /* unlock journal so it can be edited again, procedure commits changes, logs but does not raise exceptions */
         prui_unlock_journal (journal_id, updated_by);
         success := 'F';
   END prui_delete_attachments;

   PROCEDURE prui_lock_journal (journal_id IN NUMBER, locked_by IN VARCHAR2)
   IS
   BEGIN
      INSERT INTO GUI_JRNL_EDIT_LOCK (JEL_JRNL_HDR_ID, JEL_LOCKED_BY)
           VALUES (journal_id, locked_by);

      COMMIT;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         RAISE journal_locked_exeption;
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_lock_journal',
                   'gui_jrnl_edit_lock',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RAISE;
   END prui_lock_journal;

   PROCEDURE prui_unlock_journal (journal_id   IN NUMBER,
                                  locked_by    IN VARCHAR2)
   IS
   BEGIN
      DELETE FROM GUI_JRNL_EDIT_LOCK
            WHERE JEL_JRNL_HDR_ID = journal_id AND JEL_LOCKED_BY = locked_by;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_unlock_journal',
                   'gui_jrnl_edit_lock',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
   END prui_unlock_journal;

   PROCEDURE prui_check_journal_version (journal_id        IN NUMBER,
                                         journal_version   IN NUMBER)
   IS
      v_found   INTEGER;
   BEGIN
      SELECT 1
        INTO v_found
        FROM gui_jrnl_headers_unposted
       WHERE jhu_jrnl_id = journal_id AND JHU_VERSION = journal_version;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RAISE stale_journal_exception;
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_check_journal_version',
                   'gui_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RAISE;
   END prui_check_journal_version;


   PROCEDURE prui_copy_journals_to_slr (epg_id            IN VARCHAR2,
                                        journal_id_list   IN VARCHAR2)

   IS
      TYPE jrnl_files_type IS REF CURSOR;

      jrnl_file_cursor              jrnl_files_type;
      jrnl_file_rec                 gui_jrnl_file%ROWTYPE;
      v_file_id                     slr.slr_jrnl_file.JF_FILE_ID%TYPE;

      vSql                          VARCHAR2 (32000);

      gui_jrnls_not_foud_exeption   EXCEPTION;
   BEGIN
      SAVEPOINT copy_journals_to_slr;


      vSql :=
            'INSERT INTO slr_jrnl_headers_unposted (
          jhu_jrnl_id,jhu_jrnl_type,jhu_jrnl_date,jhu_jrnl_entity,jhu_jrnl_status,
          jhu_jrnl_status_text,jhu_jrnl_process_id,jhu_jrnl_description,jhu_jrnl_source,
          jhu_jrnl_source_jrnl_id,jhu_jrnl_authorised_by,jhu_jrnl_authorised_on,
          jhu_jrnl_validated_by,jhu_jrnl_validated_on,jhu_jrnl_posted_by,jhu_jrnl_posted_on,
          jhu_jrnl_total_hash_debit,jhu_jrnl_total_hash_credit,jhu_jrnl_total_lines,
          jhu_created_by,jhu_created_on,jhu_amended_by,jhu_amended_on,jhu_jrnl_pref_static_src,
          jhu_manual_flag,jhu_epg_id,jhu_jrnl_rev_date)
       SELECT
          gjhu.jhu_jrnl_id,
          nvl(gjhu.jhu_jrnl_type,''NVS''),
          gjhu.jhu_jrnl_date,
          gjhu.jhu_jrnl_entity,
          ''V'',
          ''Unposted'',
          gjhu.jhu_jrnl_process_id,
          gjhu.jhu_jrnl_description,
          gjhu.jhu_jrnl_source,
          gjhu.jhu_jrnl_source_jrnl_id,
          gjhu.jhu_jrnl_authorised_by,
          gjhu.jhu_jrnl_authorised_on,
          gjhu.jhu_jrnl_validated_by,
          gjhu.jhu_jrnl_validated_on,
          gjhu.jhu_jrnl_posted_by,
          gjhu.jhu_jrnl_posted_on,
          gjhu.jhu_jrnl_total_hash_debit,
          gjhu.jhu_jrnl_total_hash_credit,
          gjhu.jhu_jrnl_total_lines,
          gjhu.jhu_created_by,
          gjhu.jhu_created_on,
          gjhu.jhu_amended_by,
          gjhu.jhu_amended_on,
          gjhu.jhu_jrnl_pref_static_src,
          ''Y'',
          gjhu.jhu_epg_id,
		  gjhu.jhu_jrnl_rev_date
        FROM gui_jrnl_headers_unposted gjhu
        WHERE gjhu.jhu_jrnl_id IN ('
         || journal_id_list || ')
        and gjhu.jhu_jrnl_status = ''Q''';

      EXECUTE IMMEDIATE vSql;

      IF SQL%ROWCOUNT = 0
      THEN
         RAISE gui_jrnls_not_foud_exeption;
      END IF;

      vSql :=
            'INSERT INTO slr_jrnl_lines_unposted (
            jlu_jrnl_hdr_id, jlu_jrnl_line_number, jlu_fak_id, jlu_eba_id, jlu_jrnl_status,
            jlu_jrnl_status_text, jlu_jrnl_process_id, jlu_description, jlu_source_jrnl_id,
            jlu_effective_date, jlu_value_date, jlu_entity, jlu_account, jlu_segment_1,
            jlu_segment_2, jlu_segment_3, jlu_segment_4, jlu_segment_5, jlu_segment_6,
            jlu_segment_7, jlu_segment_8, jlu_segment_9, jlu_segment_10, jlu_attribute_1,
            jlu_attribute_2, jlu_attribute_3, jlu_attribute_4, jlu_attribute_5, jlu_reference_1,
            jlu_reference_2, jlu_reference_3, jlu_reference_4, jlu_reference_5, jlu_reference_6,
            jlu_reference_7, jlu_reference_8, jlu_reference_9, jlu_reference_10, jlu_tran_ccy,
            jlu_tran_amount, jlu_base_rate, jlu_base_ccy, jlu_base_amount, jlu_local_rate,
            jlu_local_ccy, jlu_local_amount, jlu_created_by, jlu_created_on, jlu_amended_by,
            jlu_amended_on, jlu_epg_id, jlu_period_month, jlu_period_year, jlu_period_ltd)
        SELECT
            gjlu.jlu_jrnl_hdr_id,
            gjlu.jlu_jrnl_line_number,
            0,
            0,
            ''V'',
            ''Unposted'',
            gjlu.jlu_jrnl_process_id,
            gjlu.jlu_description,
            gjlu.jlu_source_jrnl_id,
            gjlu.jlu_effective_date,
            gjlu.jlu_value_date,
            gjlu.jlu_entity,
            gjlu.jlu_account,
            gjlu.jlu_segment_1,
            gjlu.jlu_segment_2,
            gjlu.jlu_segment_3,
            gjlu.jlu_segment_4,
            gjlu.jlu_segment_5,
            gjlu.jlu_segment_6,
            gjlu.jlu_segment_7,
            gjlu.jlu_segment_8,
            gjlu.jlu_segment_9,
            gjlu.jlu_segment_10,
            gjlu.jlu_attribute_1,
            gjlu.jlu_attribute_2,
            gjlu.jlu_attribute_3,
            gjlu.jlu_attribute_4,
            gjlu.jlu_attribute_5,
            gjlu.jlu_reference_1,
            gjlu.jlu_reference_2,
            gjlu.jlu_reference_3,
            gjlu.jlu_reference_4,
            gjlu.jlu_reference_5,
            gjlu.jlu_reference_6,
            gjlu.jlu_reference_7,
            gjlu.jlu_reference_8,
            gjlu.jlu_reference_9,
            gjlu.jlu_reference_10,
            gjlu.jlu_tran_ccy,
            gjlu.jlu_tran_amount,
            gjlu.jlu_base_rate,
            gjlu.jlu_base_ccy,
            gjlu.jlu_base_amount,
            gjlu.jlu_local_rate,
            gjlu.jlu_local_ccy,
            gjlu.jlu_local_amount,
            gjlu.jlu_created_by,
            gjlu.jlu_created_on,
            gjlu.jlu_amended_by,
            gjlu.jlu_amended_on,
            gjlu.jlu_epg_id,
            gjlu.jlu_period_month,
            gjlu.jlu_period_year,
            gjlu.jlu_period_ltd
          FROM  gui_jrnl_lines_unposted gjlu, gui_jrnl_headers_unposted gjhu
          WHERE gjlu.jlu_jrnl_hdr_id = gjhu.jhu_jrnl_id
          and gjhu.jhu_jrnl_id in ('
         || journal_id_list || ')
          and gjhu.jhu_jrnl_status = ''Q''';

      EXECUTE IMMEDIATE vSql;

      vsql :=
            'select gjf.*
        FROM gui_jrnl_file gjf, gui_jrnl_headers_unposted gjhu
        WHERE gjf.jf_jrnl_hdr_id = gjhu.jhu_jrnl_id
        AND gjhu.jhu_jrnl_id IN ('
         || journal_id_list
         || ')
        and gjhu.jhu_jrnl_status = ''Q''';

      OPEN jrnl_file_cursor FOR vsql;

      LOOP
         FETCH jrnl_file_cursor INTO jrnl_file_rec;

         EXIT WHEN jrnl_file_cursor%NOTFOUND;

         INSERT INTO slr.slr_jrnl_file (JF_FILE_NO,
                                        JF_FILE_NAME,
                                        JF_FILE,
                                        JF_COMMENT,
                                        JF_MIME_TYPE,
                                        JF_CREATED_BY,
                                        JF_CREATED_ON,
                                        JF_AMENDED_BY,
                                        JF_AMENDED_ON)
              VALUES (jrnl_file_rec.JF_FILE_NO,
                      jrnl_file_rec.JF_FILE_NAME,
                      jrnl_file_rec.JF_FILE,
                      jrnl_file_rec.JF_COMMENT,
                      jrnl_file_rec.JF_MIME_TYPE,
                      jrnl_file_rec.JF_CREATED_BY,
                      jrnl_file_rec.JF_CREATED_ON,
                      jrnl_file_rec.JF_AMENDED_BY,
                      jrnl_file_rec.JF_AMENDED_ON)
           RETURNING JF_FILE_ID
                INTO v_file_id;

         INSERT
           INTO slr.slr_jrnl_file_attachment (JFA_JH_JRNL_ID, JFA_JF_FILE_ID)
         VALUES (jrnl_file_rec.jf_jrnl_hdr_id, v_file_id);
      END LOOP;

      CLOSE jrnl_file_cursor;
   EXCEPTION
      WHEN gui_jrnls_not_foud_exeption
      THEN
         pr_error (
            1,
               'Journals ('
            || journal_id_list
            || ') not found in gui or not in ''Q'' status',
            0,
            'prui_copy_journals_to_slr',
            'gui_jrnl_headers_unposted',
            NULL,
            NULL,
            gPackageName,
            'PL/SQL',
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL);
         RAISE;
      WHEN OTHERS
      THEN
         ROLLBACK TO SAVEPOINT copy_journals_to_slr;
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_copy_journals_to_slr',
                   'slr_jrnl_headers_unposted/slr_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);

         IF jrnl_file_cursor%ISOPEN
         THEN
            CLOSE jrnl_file_cursor;
         END IF;

         RAISE;
   END prui_copy_journals_to_slr;


   PROCEDURE prui_post_queued_journals (epg_id            IN     VARCHAR2,
                                        journal_id_list   IN     VARCHAR2,
                                        status               OUT CHAR)
   IS
      lv_process_id              NUMBER (32);
      lv_journal_id_list         VARCHAR2 (10000);
      lv_lock_handle             VARCHAR2 (100);
      lv_lock_result             INTEGER;
      lv_header_id_list          VARCHAR2 (10000);
      epg_locked_exception       EXCEPTION;
      batch_critical_exception   EXCEPTION;
   BEGIN
      status := 'S';

      DBMS_LOCK.ALLOCATE_UNIQUE ('MAH_PROCESS_SLR_' || epg_id,
                                 lv_lock_handle);

      lv_lock_result :=
         DBMS_LOCK.REQUEST (lv_lock_handle,
                            DBMS_LOCK.X_MODE,
                            5,
                            FALSE);

      IF lv_lock_result != 0
      THEN
         RAISE epg_locked_exception;
      END IF;

      BEGIN                 
      
        -- process elimination records for each journal header
        pProcessEliminations(journal_id_list,status, lv_header_id_list);

        IF LENGTH(lv_header_id_list) > 1 THEN
            lv_journal_id_list := journal_id_list || ',' || lv_header_id_list;
        ELSE
            lv_journal_id_list := journal_id_list;
        END IF;

         -- add list of elimination line id's for further processing
         lv_journal_id_list := journal_id_list || ',' || lv_header_id_list ;
               
         prui_copy_journals_to_slr (epg_id, lv_journal_id_list);
         
         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            prui_set_gui_jrnls_status (lv_journal_id_list, 'E');
            COMMIT;
            lv_lock_result := DBMS_LOCK.RELEASE (lv_lock_handle);
            RETURN;
      END;

      BEGIN      
                                         
         --assign new processing id and status to all headers and lines for journals from the list
         SLR_UTILITIES_PKG.pAssignNewProcessIdAndStatus (epg_id,
                                                         lv_journal_id_list,
                                                         gSTATUS_VALIDATED,
                                                         gSTATUS_VALIDATED,
                                                         lv_process_id);


         --update journal lines with proper group, period details and other from header
         SLR_UTILITIES_PKG.pUpdateJrnlLinesUnposted (epg_id,
                                                     lv_process_id,
                                                     gSTATUS_VALIDATED);

         --assign FAK/EBA combinations
         SLR_UTILITIES_PKG.pUpdateFakEbaCombinations_Jlu (epg_id,
                                                          lv_process_id,
                                                          gSTATUS_VALIDATED);                                                                                                                  

         COMMIT;

         -- Call the procedure in the subledger that validates the journal (status gets updated to 'E' if validation fails)
         slr_validate_journals_pkg.pValidateJournals (epg_id,
                                                      lv_process_id,
                                                      gSTATUS_VALIDATED,
                                                      TRUE,
                                                      NULL);
                                                     
                                                      
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'prui_post_queued_journals',
                      'preparation_and_validation',
                      NULL,
                      NULL,
                      gPackageName,
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
            RAISE batch_critical_exception;
      END;

      BEGIN
         prui_create_reversing_journal (epg_id,
                                        lv_journal_id_list,
                                        lv_process_id,
                                        gSTATUS_VALIDATED);
         COMMIT;
         --mark future dated journals (set 'W' status)--
         prui_mark_future_dated_jrnls (epg_id,
                                       lv_journal_id_list,
                                       gSTATUS_VALIDATED);
         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            RAISE batch_critical_exception;
      END;


      IF fnui_anything_to_post (lv_journal_id_list, gSTATUS_VALIDATED)
      THEN
         BEGIN
         
            -- Set the flag used for Generating Last Balances for the current Bussiness date
            syn_ui_post_journals_pkg.pStatusGenLastBalForBD (
               gvSubLedgerGenLastBalForBD);

            -- call the procedure in the subledger that posts the journal
            syn_ui_post_journals_pkg.pPostJournals (epg_id,
                                                    lv_process_id,
                                                    gSTATUS_VALIDATED,
                                                    TRUE,
                                                    NULL);

            COMMIT;
         EXCEPTION
            WHEN OTHERS
            THEN
               pr_error (1,
                         SQLERRM,
                         0,
                         'prui_post_queued_journals',
                         'slr_post',
                         NULL,
                         NULL,
                         gPackageName,
                         'PL/SQL',
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL);
         END;
      END IF;

      --delete journals that failed posting from slr unposted tables, update journal status and copy errors to gui.--
      prui_rollback_err_slr_journals (epg_id            => epg_id,
                                      journal_id_list   => journal_id_list,
                                      rollback_all      => FALSE);
      COMMIT;

      --delete successfuly posted or future dated (awaiting posting 'W') journals from gui tables--
      prui_delete_gui_journals (lv_journal_id_list);
--      prui_delete_gui_journals (lv_header_id_list);

      COMMIT;

      BEGIN
         --execute custom procedure after posting--
         PGUI_JRNL_CUSTOM.prui_post_queued_journals (epg_id, lv_journal_id_list);
      EXCEPTION
         WHEN OTHERS
         THEN
            pr_error (1,
                      SQLERRM,
                      0,
                      'prui_post_queued_journals',
                      NULL,
                      NULL,
                      NULL,
                      'PGUI_JRNL_CUSTOM',
                      'PL/SQL',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL);
      --do not raise exception here--
      END;

      COMMIT;

      lv_lock_result := DBMS_LOCK.RELEASE (lv_lock_handle);
   EXCEPTION
      WHEN epg_locked_exception
      THEN
         status := 'L';
      WHEN batch_critical_exception
      THEN
         --delete all copied to slr journals, copy errors to gui--
         prui_rollback_err_slr_journals (epg_id          => epg_id,
                                         journal_id_list => lv_journal_id_list,
                                         rollback_all    => TRUE);
         prui_log_posting_error (
            epg_id            => epg_id,
            journal_id_list   => lv_journal_id_list,
            error_message     => 'There was an unexpected error during post to the subledger. Please inspect fr_log for details.');
         COMMIT;
         lv_lock_result := DBMS_LOCK.RELEASE (lv_lock_handle);
         status := 'S';
      WHEN OTHERS
      THEN
         ROLLBACK;
         lv_lock_result := DBMS_LOCK.RELEASE (lv_lock_handle);
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_post_queued_journals',
                   'unexpected_error',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         prui_log_posting_error (
            epg_id            => epg_id,
            journal_id_list   => lv_journal_id_list,
            error_message     => 'There was an unexpected error during post to the subledger. Please inspect fr_log for details.');
         COMMIT;
         status := 'E';
   END prui_post_queued_journals;

   PROCEDURE prui_create_reversing_journal (epg_id            IN VARCHAR2,
                                            journal_id_list   IN VARCHAR2,
                                            process_id           NUMBER,
                                            status            IN CHAR)
   IS
      vSql            VARCHAR2 (32000);
      vRevJrnlCount   NUMBER (10);
   BEGIN
      vSql :=
            'SELECT count(1)
    FROM slr_jrnl_headers_unposted sjhu,
		 slr.slr_ext_jrnl_types ejt,
		 slr.slr_jrnl_types jt
    WHERE sjhu.jhu_jrnl_id in ('
         || journal_id_list
         || ')
    AND sjhu.jhu_jrnl_status = :status
	and sjhu.jhu_jrnl_type = ejt.ejt_type
	AND jt.jt_type = ejt.ejt_jt_type
	and jt.jt_reverse_flag = ''Y''';

      EXECUTE IMMEDIATE vSql INTO vRevJrnlCount USING status;

      IF vRevJrnlCount > 0
      THEN
         BEGIN
            SAVEPOINT create_reversing_journal;

            --delegate creation of reversing journals to slr_post_journals_pkg
            syn_ui_post_journals_pkg.pCreate_reversing_journal (
               journal_id_list,
               epg_id,
               status,
               process_id);

            --execute custom logic
            pgui_jrnl_custom.prui_create_reversing_journal (epg_id,
                                                            journal_id_list);
         EXCEPTION
            WHEN OTHERS
            THEN
               ROLLBACK TO SAVEPOINT create_reversing_journal;
               pr_error (1,
                         SQLERRM,
                         0,
                         'prui_create_reversing_journal.2',
                         'slr_jrnl_headers_unposted/slr_jrnl_lines_unposted',
                         NULL,
                         NULL,
                         gPackageName,
                         'PL/SQL',
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL);


               EXECUTE IMMEDIATE
                     'INSERT INTO gui_jrnl_line_errors (
			  jle_jrnl_process_id, jle_jrnl_hdr_id, jle_jrnl_line_number,
			  jle_error_code, jle_error_string, jle_created_by, jle_created_on,
			  jle_amended_by, jle_amended_on)
		   select  :process_id, jhu_jrnl_id, 0,
			  ''MADJ-9999'', ''Unable to create reversing journal for journal ''||TO_CHAR(jhu_jrnl_id), user, sysdate, user, sysdate
		   from slr_jrnl_headers_unposted sjhu,
				slr.slr_ext_jrnl_types ejt,
				slr.slr_jrnl_types jt
		   where sjhu.jhu_jrnl_id in ('
                  || journal_id_list
                  || ')
		   AND sjhu.jhu_jrnl_status  = :status
		   and sjhu.jhu_jrnl_type = ejt.ejt_type
		   AND jt.jt_type = ejt.ejt_jt_type
		   and jt.jt_reverse_flag = ''Y'''
                  USING process_id, status;

               EXECUTE IMMEDIATE
                     'update slr_jrnl_lines_unposted sjlu
		   set sjlu.jlu_jrnl_status = ''E''
			  ,sjlu.jlu_jrnl_status_text = ''Error''
		   where sjlu.jlu_jrnl_hdr_id
		   in (select jhu_jrnl_id
			  from slr_jrnl_headers_unposted sjhu,
				   slr.slr_ext_jrnl_types ejt,
				   slr.slr_jrnl_types jt
			  where sjhu.jhu_jrnl_id in ('
                  || journal_id_list
                  || ')
			  AND sjhu.jhu_jrnl_status = :status
			  and sjhu.jhu_jrnl_type = ejt.ejt_type
			  AND jt.jt_type = ejt.ejt_jt_type
			  and jt.jt_reverse_flag = ''Y'')
		   AND sjlu.jlu_jrnl_status = :status
		   AND sjlu.jlu_epg_id = '''
                  || epg_id
                  || ''''
                  USING status, status;

               EXECUTE IMMEDIATE
                     'update (select jhu_jrnl_status, jhu_jrnl_status_text
			from slr_jrnl_headers_unposted,
				 slr.slr_ext_jrnl_types ejt,
				 slr.slr_jrnl_types jt
			where jhu_jrnl_id in ('
                  || journal_id_list
                  || ')
			AND jhu_jrnl_status  = :status
			and jhu_jrnl_type = ejt.ejt_type
			AND jt.jt_type = ejt.ejt_jt_type
			and jt.jt_reverse_flag = ''Y'') sjhu
		  set sjhu.jhu_jrnl_status = ''E''
			 ,sjhu.jhu_jrnl_status_text = ''Error'''
                  USING status;
         END;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_create_reversing_journal',
                   'slr_jrnl_headers_unposted/slr_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RAISE;
   END prui_create_reversing_journal;

   PROCEDURE prui_rollback_err_slr_journals (
      epg_id            IN VARCHAR2,
      journal_id_list   IN VARCHAR2,
      rollback_all      IN BOOLEAN := FALSE)
   IS
      vSql                     VARCHAR2 (32000);
      vErrStatusText           VARCHAR2 (20) := 'Error';
      vErrStatus               CHAR (1) := 'E';

      TYPE file_attachment IS REF CURSOR;

      file_attachment_cursor   file_attachment;
      v_file_id                slr.slr_jrnl_file_attachment.JFA_JF_FILE_ID%TYPE;
      v_file_id_list           VARCHAR2 (30000) := NULL;
   BEGIN
      vSql :=
            'update gui_jrnl_headers_unposted gjhu
      set gjhu.jhu_jrnl_status = :errStatus
          ,gjhu.jhu_jrnl_status_text = :errStatusText
      where gjhu.jhu_jrnl_id in ('
         || journal_id_list
         || ')';

      IF NOT rollback_all
      THEN
         vSql :=
               vSql
            || ' and exists (select 1 from slr_jrnl_headers_unposted sjhu
          where sjhu.jhu_jrnl_id in ('
            || journal_id_list
            || ')
          and sjhu.jhu_jrnl_id = gjhu.jhu_jrnl_id
          and sjhu.jhu_jrnl_status in (''E'',''V''))';
      END IF;

      EXECUTE IMMEDIATE vSql USING vErrStatus, vErrStatusText;

      vSql :=
            'update gui_jrnl_lines_unposted gjlu
      set gjlu.jlu_jrnl_status = :errStatus
         ,gjlu.jlu_jrnl_status_text = :errStatusText
      where gjlu.jlu_jrnl_hdr_id in ('
         || journal_id_list
         || ')';

      IF NOT rollback_all
      THEN
         vSql :=
               vSql
            || ' and exists (select 1 from slr_jrnl_headers_unposted sjhu
          where sjhu.jhu_jrnl_id in ('
            || journal_id_list
            || ')
          and sjhu.jhu_jrnl_id = gjlu.jlu_jrnl_hdr_id
          and sjhu.jhu_jrnl_status in (''E'',''V''))';
      END IF;

      EXECUTE IMMEDIATE vSql USING vErrStatus, vErrStatusText;

      vSql :=
            'INSERT INTO gui_jrnl_line_errors (
        jle_jrnl_process_id, jle_jrnl_hdr_id, jle_jrnl_line_number,
        jle_error_code, jle_error_string, jle_created_by, jle_created_on,
        jle_amended_by, jle_amended_on)
     SELECT jle_jrnl_process_id, jle_jrnl_hdr_id, jle_jrnl_line_number,
            jle_error_code,	jle_error_string, jle_created_by, jle_created_on,
            jle_amended_by,	jle_amended_on
     FROM 	slr_jrnl_line_errors, slr_jrnl_headers_unposted
     WHERE	jle_jrnl_hdr_id = jhu_jrnl_id
     and    jhu_jrnl_id in ('
         || journal_id_list
         || ')';

      IF NOT rollback_all
      THEN
         vSql := vSql || ' and jhu_jrnl_status in (''E'',''V'')';
      END IF;

      EXECUTE IMMEDIATE vSql;


      vSql :=
            'delete from slr_jrnl_lines_unposted
     where jlu_jrnl_hdr_id in ('
         || journal_id_list
         || ')
     and jlu_epg_id = '''
         || epg_id
         || '''';

      IF NOT rollback_all
      THEN
         vSql := vSql || ' and jlu_jrnl_status in (''E'',''V'')';
      END IF;

      EXECUTE IMMEDIATE vSql;

      vSql :=
            'delete from slr_jrnl_line_errors
     where jle_jrnl_hdr_id in (
     select jhu_jrnl_id from slr_jrnl_headers_unposted where jhu_jrnl_id in ('
         || journal_id_list
         || ')';

      IF NOT rollback_all
      THEN
         vSql := vSql || ' and jhu_jrnl_status in (''E'',''V'')';
      END IF;

      vSql := vSql || ')';

      EXECUTE IMMEDIATE vSql;

      --delete also created reversing journals--
      vSql :=
            'delete from slr_jrnl_lines_unposted
     where jlu_jrnl_hdr_id in (select c.jhu_jrnl_id from slr_jrnl_headers_unposted c
     WHERE c.jhu_jrnl_id <> c.jhu_jrnl_ref_id and c.jhu_jrnl_ref_id IN
     (select p.jhu_jrnl_id from slr_jrnl_headers_unposted p where p.jhu_jrnl_id in ('
         || journal_id_list
         || ')';

      IF NOT rollback_all
      THEN
         vSql := vSql || ' and p.jhu_jrnl_status in (''E'',''V'')';
      END IF;

      vSql := vSql || ')) AND jlu_epg_id = ''' || epg_id || '''';



      EXECUTE IMMEDIATE vSql;

      vSql :=
            'delete from slr_jrnl_headers_unposted c
     where c.jhu_jrnl_id <> c.jhu_jrnl_ref_id and c.jhu_jrnl_ref_id in
     (select p.jhu_jrnl_id from slr_jrnl_headers_unposted p where p.jhu_jrnl_id in ('
         || journal_id_list
         || ')';

      IF NOT rollback_all
      THEN
         vSql := vSql || ' and p.jhu_jrnl_status in (''E'',''V'')';
      END IF;

      vSql := vSql || ')';

      EXECUTE IMMEDIATE vSql;

      vSql :=
            'select JFA_JF_FILE_ID
        from slr.slr_jrnl_file_attachment
        where JFA_JH_JRNL_ID in (select jhu_jrnl_id from slr_jrnl_headers_unposted  where jhu_jrnl_id in ('
         || journal_id_list
         || ')';

      IF NOT rollback_all
      THEN
         vSql := vSql || ' and jhu_jrnl_status in (''E'',''V'')';
      END IF;

      vSql := vSql || ')';

      /* build attachment file id list */
      OPEN file_attachment_cursor FOR vSql;

      LOOP
         FETCH file_attachment_cursor INTO v_file_id;

         EXIT WHEN file_attachment_cursor%NOTFOUND;

         IF v_file_id_list IS NOT NULL
         THEN
            v_file_id_list := v_file_id_list || ',' || TO_CHAR (v_file_id);
         ELSE
            v_file_id_list := TO_CHAR (v_file_id);
         END IF;
      END LOOP;

      CLOSE file_attachment_cursor;

      IF v_file_id_list IS NOT NULL
      THEN
         vSql :=
               'delete from slr.slr_jrnl_file_attachment
			where JFA_JF_FILE_ID in ('
            || v_file_id_list
            || ')';

         EXECUTE IMMEDIATE vSql;

         vSql := 'delete from slr.slr_jrnl_file
			where JF_FILE_ID in (' || v_file_id_list || ')';

         EXECUTE IMMEDIATE vSql;
      END IF;

      vSql :=
         'delete from slr_jrnl_headers_unposted
     where jhu_jrnl_id in (' || journal_id_list || ')';

      IF NOT rollback_all
      THEN
         vSql := vSql || ' and jhu_jrnl_status in (''E'',''V'')';
      END IF;

      EXECUTE IMMEDIATE vSql;
   --commit;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_rollback_err_slr_journal',
                   'slr_jrnl_headers_unposted/slr_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);

         IF file_attachment_cursor%ISOPEN
         THEN
            CLOSE file_attachment_cursor;
         END IF;

         RAISE;
   END prui_rollback_err_slr_journals;

   PROCEDURE prui_delete_gui_journals (journal_id_list IN VARCHAR2)
   IS
   BEGIN
      --delete journals posted to slr from gui tables, those will have the 'Q' status as oposed to the failed journals ('E' status).--

      EXECUTE IMMEDIATE
            'delete from gui_jrnl_headers_unposted gjhu
      where gjhu.jhu_jrnl_id in ('
         || journal_id_list
         || ')
      and gjhu.jhu_jrnl_status = ''Q''
      and (exists (select 1 from slr_jrnl_headers_unposted sjhu
            where sjhu.jhu_jrnl_id = gjhu.jhu_jrnl_id
            and   sjhu.jhu_jrnl_status = ''W'')
          or exists (select 1 from slr_jrnl_headers sjh
            where sjh.JH_JRNL_ID = gjhu.jhu_jrnl_id
            and sjh.JH_JRNL_DATE = gjhu.JHU_JRNL_DATE
            and sjh.JH_JRNL_EPG_ID = gjhu.JHU_EPG_ID)
           )';


      EXECUTE IMMEDIATE
            'delete from gui_jrnl_lines_unposted gjlu
       where gjlu.jlu_jrnl_hdr_id in
      ('
         || journal_id_list
         || ')
      and gjlu.jlu_jrnl_status = ''Q''
      and not exists (select 1 from gui_jrnl_headers_unposted gjhu
            where gjhu.jhu_jrnl_id = gjlu.jlu_jrnl_hdr_id)';

      EXECUTE IMMEDIATE
            'delete from gui_jrnl_file gjf
      where gjf.jf_jrnl_hdr_id in ('
         || journal_id_list
         || ')
      and not exists (select 1 from gui_jrnl_headers_unposted gjhu
            where gjhu.jhu_jrnl_id = gjf.jf_jrnl_hdr_id)';

      EXECUTE IMMEDIATE
            'delete from gui_jrnl_line_errors gjle
       where gjle.jle_jrnl_hdr_id in ('
         || journal_id_list
         || ')
       and not exists (select 1 from gui_jrnl_headers_unposted gjhu where gjhu.jhu_jrnl_id in ('
         || journal_id_list
         || ') and gjhu.jhu_jrnl_id = gjle.jle_jrnl_hdr_id )';
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_delete_gui_journals',
                   'gui_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RAISE;
   END prui_delete_gui_journals;


   PROCEDURE prui_set_gui_jrnls_status (journal_id_list   IN VARCHAR2,
                                        status            IN CHAR)
   IS
      vStatusText   VARCHAR2 (20);
      vSql          VARCHAR (32000);
   BEGIN
      IF status = 'E'
      THEN
         vStatusText := 'Error';
      END IF;

      IF status = gSTATUS_MANUAL
      THEN
         vStatusText := 'Manual';
      END IF;

      IF status = gSTATUS_ERROR
      THEN
         vStatusText := 'Invalid';
      END IF;

      IF status = gSTATUS_AUTHORISE
      THEN
         vStatusText := 'Require Authoris.';
      END IF;

      IF status = gSTATUS_REJECT
      THEN
         vStatusText := 'Failed';
      END IF;

      IF status = gSTATUS_POSTED
      THEN
         vStatusText := 'Posted';
      END IF;

      IF status = gSTATUS_VALIDATED
      THEN
         vStatusText := 'Unposted';
      END IF;

      IF status = gSTATUS_VALIDATING
      THEN
         vStatusText := 'Validating';
      END IF;

      IF status = gSTATUS_WAITING
      THEN
         vStatusText := 'Unposted';
      END IF;


      vSql :=
            'update gui_jrnl_headers_unposted gjhu
      set gjhu.jhu_jrnl_status = :status
         ,gjhu.jhu_jrnl_status_text = :status_text
     where gjhu.jhu_jrnl_id in ('
         || journal_id_list
         || ')';

      EXECUTE IMMEDIATE vSql USING status, vStatusText;

      EXECUTE IMMEDIATE
            'update gui_jrnl_lines_unposted gjlu
      set gjlu.jlu_jrnl_status = :status
          ,gjlu.jlu_jrnl_status_text = :status_text
      where gjlu.jlu_jrnl_hdr_id in ('
         || journal_id_list
         || ')'
         USING status, vStatusText;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_set_gui_jrnls_status',
                   'gui_jrnl_headers_unposted/gui_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RAISE;
   END prui_set_gui_jrnls_status;

   FUNCTION fnui_anything_to_post (journal_id_list VARCHAR2, status CHAR)
      RETURN BOOLEAN
   IS
      lvFound   NUMBER := 0;
   BEGIN
      EXECUTE IMMEDIATE
            'SELECT count(1)
       FROM slr_jrnl_headers_unposted sjhu
       WHERE sjhu.jhu_jrnl_id IN ('
         || journal_id_list
         || ')
       AND sjhu.jhu_jrnl_status = :status'
         INTO lvFound
         USING status;

      IF lvFound > 0
      THEN
         RETURN TRUE;
      END IF;

      RETURN FALSE;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'fnui_anything_to_post',
                   'slr_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RAISE;
   END fnui_anything_to_post;

   PROCEDURE prui_mark_future_dated_jrnls (epg_id            IN VARCHAR2,
                                           journal_id_list   IN VARCHAR2,
                                           status               CHAR)
   IS
   BEGIN
      EXECUTE IMMEDIATE
            'UPDATE slr_jrnl_headers_unposted
    SET jhu_jrnl_status = ''W''
    WHERE jhu_jrnl_id IN ('
         || journal_id_list
         || ')
    and jhu_jrnl_status = :status
    and jhu_jrnl_date > :currbusdate'
         USING status, SLR_UTILITIES_PKG.fEntityGroupCurrBusDate (epg_id);

      EXECUTE IMMEDIATE
            'UPDATE SLR_JRNL_LINES_UNPOSTED
    SET JLU_JRNL_STATUS = ''W''
    WHERE JLU_EPG_ID = '''
         || epg_id
         || '''
    and jlu_jrnl_status = :status
    and jlu_jrnl_hdr_id in (select jhu_jrnl_id from slr_jrnl_headers_unposted
      where jhu_jrnl_id in ('
         || journal_id_list
         || ') and jhu_jrnl_status = ''W'')'
         USING status;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_mark_future_dated_jrnls',
                   'slr_jrnl_headers_unposted/slr_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         RAISE;
   END prui_mark_future_dated_jrnls;

   PROCEDURE prui_log_posting_error (epg_id            IN VARCHAR2,
                                     journal_id_list   IN VARCHAR2,
                                     error_message     IN VARCHAR2)
   IS
   BEGIN
      EXECUTE IMMEDIATE
            'INSERT INTO gui_jrnl_line_errors (
        jle_jrnl_process_id, jle_jrnl_hdr_id, jle_jrnl_line_number,
        jle_error_code, jle_error_string, jle_created_by, jle_created_on,
        jle_amended_by, jle_amended_on)
     SELECT 0, jhu_jrnl_id, 0,
            ''MADJ-9999'',	:error_string, user, sysdate ,
            user,	sysdate
     FROM 	gui_jrnl_headers_unposted
     WHERE	jhu_jrnl_id in ('
         || journal_id_list
         || ')'
         USING error_message;
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'prui_log_posting_error',
                   'gui_jrnl_line_errors',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
   END prui_log_posting_error;

   PROCEDURE pCombinationCheck_GJLU (
      pinEPGID       IN slr.slr_entity_proc_group.epg_id%TYPE,
      pinProcessID   IN slr.slr_job_statistics.js_process_id%TYPE,
      pinStatus      IN CHAR)
   AS
      lcUnitName          CONSTANT all_procedures.procedure_name%TYPE
                                      := 'pCombinationCheck_GJLU' ;
      lcViewName          CONSTANT all_views.view_name%TYPE
                                      := 'SCV_COMBINATION_CHECK_GJLU' ;
      lcErrorCode_Combo   CONSTANT slr.slr_error_message.em_error_code%TYPE
                                      := 'JL_COMBO' ;

      v_combo_check_errors         PLS_INTEGER;
   BEGIN
      DBMS_APPLICATION_INFO.set_module (module_name   => lcUnitName,
                                        action_name   => 'Start');
      fdr.PG_COMMON.pLogDebug (
         pinMessage   => 'Start Combo Check - GUI Unposted Journal Lines');

      /* Configure the optimizer hints for Combination Checking. */
      -- fdr.PG_COMBINATION_CHECK.gSQLHint_DeleteComboInput := '';
      -- fdr.PG_COMBINATION_CHECK.gSQLHint_DeleteComboError := '';
      -- fdr.PG_COMBINATION_CHECK.gSQLHint_InsertInput      := '/*+ no_parallel */';
      -- fdr.PG_COMBINATION_CHECK.gSQLHint_SelectInput      := '/*+ parallel */';
      -- fdr.PG_COMBINATION_CHECK.gSQLHint_InsertComboError := '/*+ no_parallel */';
      -- fdr.PG_COMBINATION_CHECK.gSQLHint_SelectComboError := '/*+ parallel */';

      /* Call the Combination Check for those journals that are not in error yet - use the [sub-]partitioning key. */
      fdr.PG_COMBINATION_CHECK.pCombinationCheck (
         pinObjectName     => 'gui.scv_combination_check_gjlu',
         pinFilter         => NULL,
         pinBusinessDate   => NULL,
         poutErrorCount    => v_combo_check_errors);

      IF v_combo_check_errors > 0
      THEN
         DBMS_APPLICATION_INFO.set_action ('Create GUI Journal Line Error');

         INSERT /*+ parallel */
               INTO  gui_jrnl_line_errors (jle_jrnl_process_id,
                                           jle_jrnl_hdr_id,
                                           jle_jrnl_line_number,
                                           jle_error_code,
                                           jle_error_string,
                                           jle_created_by,
                                           jle_created_on,
                                           jle_amended_by,
                                           jle_amended_on)
            SELECT /*+ parallel */
                  pinProcessID AS jle_jrnl_process_id,
                   SUBSTR (ce_input_id, 1, INSTR (ce_input_id, '_') - 1)
                      AS jle_jrnl_hdr_id,
                   SUBSTR (ce_input_id, INSTR (ce_input_id, '_') + 1)
                      AS jle_jrnl_line_number,
                   lcErrorCode_Combo AS jle_error_code,
                   REPLACE (REPLACE (em_error_message, '%1', ce_rule),
                            '%2',
                            ce_attribute_name)
                      AS jle_error_string,
                   USER AS jle_created_by,
                   SYSDATE AS jle_created_on,
                   USER AS jle_amended_by,
                   SYSDATE AS jle_amended_on
              FROM fdr.fr_combination_check_error
                   JOIN slr.slr_error_message ON 1 = 1
             WHERE em_error_code = lcErrorCode_Combo;

         /* Update the corresponding journal line to Error. */
         MERGE /*+ parallel */
              INTO  gui_jrnl_lines_unposted a
              USING (  SELECT /*+ parallel */
                             jlu_jrnl_hdr_id, jlu_jrnl_line_number, jlu_epg_id
                         FROM gui_jrnl_lines_unposted
                              JOIN fdr.fr_combination_check_error
                                 ON     jlu_jrnl_hdr_id =
                                           SUBSTR (
                                              ce_input_id,
                                              1,
                                              INSTR (ce_input_id, '_') - 1)
                                    AND jlu_jrnl_line_number =
                                           SUBSTR (
                                              ce_input_id,
                                              INSTR (ce_input_id, '_') + 1)
                        WHERE     jlu_epg_id = pinEPGID
                              AND jlu_jrnl_status = pinStatus
                     GROUP BY jlu_jrnl_hdr_id,
                              jlu_jrnl_line_number,
                              jlu_epg_id) b
                 ON (    a.jlu_epg_id = b.jlu_epg_id
                     AND a.jlu_jrnl_hdr_id = b.jlu_jrnl_hdr_id
                     AND a.jlu_jrnl_line_number = b.jlu_jrnl_line_number)
         WHEN MATCHED
         THEN
            UPDATE SET a.jlu_jrnl_status = 'E';

         COMMIT;

         DBMS_APPLICATION_INFO.set_action (
            'Create Correlated GUI Journal Line Errors');

         INSERT /*+ parallel */
               INTO  gui_jrnl_line_errors (jle_jrnl_process_id,
                                           jle_jrnl_hdr_id,
                                           jle_jrnl_line_number,
                                           jle_error_code,
                                           jle_error_string,
                                           jle_created_by,
                                           jle_created_on,
                                           jle_amended_by,
                                           jle_amended_on)
            SELECT /*+ parallel */
                  pinProcessID AS jle_jrnl_process_id,
                   JLU.JLU_JRNL_HDR_ID AS jle_jrnl_hdr_id,
                   JLU.JLU_JRNL_LINE_NUMBER AS jle_jrnl_line_number,
                   lcErrorCode_Combo AS jle_error_code,
                   'Correlated GUI Journal Line Error' AS jle_error_string,
                   USER AS jle_created_by,
                   SYSDATE AS jle_created_on,
                   USER AS jle_amended_by,
                   SYSDATE AS jle_amended_on
              FROM (SELECT DISTINCT jle1.jle_jrnl_hdr_id
                      FROM gui.gui_jrnl_line_errors jle1
                     WHERE JLE1.JLE_JRNL_PROCESS_ID = pinProcessID) jle
                   --join slr.slr_error_message on 1 = 1
                   JOIN GUI.GUI_JRNL_LINES_UNPOSTED jlu
                      ON jle.jle_jrnl_hdr_id = JLU.JLU_JRNL_HDR_ID
             --where em_error_code = lcErrorCode_Combo;
             WHERE NOT EXISTS
                          (SELECT NULL
                             FROM slr_jrnl_line_errors jle2
                            WHERE     JLE2.JLE_JRNL_HDR_ID =
                                         JLU.JLU_JRNL_HDR_ID
                                  AND JLE2.JLE_JRNL_LINE_NUMBER =
                                         JLU.JLU_JRNL_LINE_NUMBER
                                  AND JLE2.JLE_JRNL_PROCESS_ID = pinProcessID);

         /* Update the corresponding journal line to Error. */
         MERGE /*+ parallel */
              INTO  gui_jrnl_lines_unposted a
              USING (  SELECT /*+ parallel */
                             jlu_jrnl_hdr_id, jlu_jrnl_line_number, jlu_epg_id
                         FROM gui_jrnl_lines_unposted
                              JOIN GUI.GUI_JRNL_LINE_ERRORS jle
                                 ON     jlu_jrnl_hdr_id = JLE.JLE_JRNL_HDR_ID
                                    AND jlu_jrnl_line_number =
                                           JLE.JLE_JRNL_LINE_NUMBER
                        WHERE     jlu_epg_id = pinEPGID
                              AND jlu_jrnl_status = pinStatus
                     GROUP BY jlu_jrnl_hdr_id,
                              jlu_jrnl_line_number,
                              jlu_epg_id) b
                 ON (    a.jlu_epg_id = b.jlu_epg_id
                     AND a.jlu_jrnl_hdr_id = b.jlu_jrnl_hdr_id
                     AND a.jlu_jrnl_line_number = b.jlu_jrnl_line_number)
         WHEN MATCHED
         THEN
            UPDATE SET a.jlu_jrnl_status = 'E';
      END IF;

      -- SLR.SLR_ADMIN_PKG.PerfInfo( 'Combo Edit Checks. Check Combo failed record count: ' || v_combo_check_errors);
      /* Remove the combination input/error records and commit the journal error records. */
      COMMIT;

      fdr.PG_COMMON.pLogDebug (
         pinMessage   => 'End Combo Check - GUI Unposted Journal Lines');
      DBMS_APPLICATION_INFO.set_module (module_name   => NULL,
                                        action_name   => NULL);
   EXCEPTION
      WHEN OTHERS
      THEN
         /* Log the error. */
         DBMS_APPLICATION_INFO.set_action ('Unhandled Exception');
         fdr.PR_Error (
            a_type            => fdr.PG_COMMON.gcErrorEventType_Error,
            a_text            => DBMS_UTILITY.format_error_backtrace,
            a_category        => fdr.PG_COMMON.gcErrorCategory_Tech,
            a_error_source    => lcUnitName,
            a_error_table     => 'GUI_JRNL_LINES_UNPOSTED',
            a_row             => NULL,
            a_error_field     => NULL,
            a_stage           => USER,
            a_technology      => fdr.PG_COMMON.gcErrorTechnology_PLSQL,
            a_value           => NULL,
            a_entity          => NULL,
            a_book            => NULL,
            a_security        => NULL,
            a_source_system   => NULL,
            a_client_key      => NULL,
            a_client_ver      => NULL,
            a_lpg_id          => NULL);

         /* Raise the error. */
         RAISE;
   END pCombinationCheck_GJLU;


   --********************************************************************************

   PROCEDURE pProcessEliminations (journal_id_list   IN     VARCHAR2,
                                   success              OUT CHAR,
                                  lv_header_id_list IN OUT VARCHAR2 )
   IS
      list_count              NUMBER (12);
      loop_count              NUMBER (12);
      journal_list_in_error   VARCHAR2 (32700) := NULL;
      lv_success              CHAR (1);
      lv_failed_count         NUMBER (5) := 0;
      lv_journal_id           NUMBER (12, 0);
      lv_journal_version      NUMBER (5, 0);
      ncount                  NUMBER;
      vHeaderId               VARCHAR2(20);

      vStartIdx binary_integer;
      vEndIdx   binary_integer;
      vCurValue varchar2(1000);

      cursor v_cur is
        select regexp_substr(journal_id_list,'[^,]+', 1, level) As str from dual
        connect by regexp_substr(journal_id_list, '[^,]+', 1, level) is not null;
      
   BEGIN
      success := 'S';

    for i in v_cur loop
    
    vHeaderId := TO_CHAR (fnui_get_next_journal_id);

    IF LENGTH(lv_header_id_list) > 1 THEN
           lv_header_id_list := lv_header_id_list || ',' || vHeaderId;
    ELSE
           lv_header_id_list := vHeaderId; 
    END IF;       

    pCreateEliminations(i.str,lv_success,vHeaderId);
    
  end loop;

  -- Call proc here for last part (or in case of single element)
       

   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'pProcessEliminations',
                   'gui_jrnl_headers_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         success := 'F';
   END pProcessEliminations;

   --********************************************************************************


   PROCEDURE pCreateEliminations (
      journal_id    IN     SLR_JRNL_HEADERS.JH_JRNL_ID%TYPE,
      success          OUT CHAR,
      vHeaderId     IN VARCHAR2)
   IS
      lvID      NUMBER;
      nCount    NUMBER;
      nrcount   NUMBER;
   BEGIN
      success := 'S';

      SELECT COUNT (*)
        INTO nCount
        FROM gui.gui_jrnl_lines_unposted
       WHERE JLU_JRNL_HDR_ID = journal_id;


      INSERT INTO gui.gui_jrnl_headers_unposted
         SELECT TO_NUMBER (vHeaderId) jhu_jrnl_id,
                jhu_jrnl_type,
                jhu_jrnl_date,
                ce.jlu_entity jhu_jrnl_entity,
                jhu_epg_id,
                jhu_jrnl_status,
                jhu_jrnl_status_text,
                jhu_jrnl_process_id,
                jhu_jrnl_description,
                jhu_jrnl_source,
                jhu_jrnl_source_jrnl_id,
                jhu_jrnl_authorised_by,
                jhu_jrnl_authorised_on,
                jhu_jrnl_validated_by,
                jhu_jrnl_validated_on,
                jhu_jrnl_posted_by,
                jhu_jrnl_posted_on,
                jhu_jrnl_total_hash_debit,
                jhu_jrnl_total_hash_credit,
                jhu_jrnl_total_lines,
                jhu_created_by,
                jhu_created_on,
                jhu_amended_by,
                jhu_amended_on,
                jhu_jrnl_pref_static_src,
                jhu_jrnl_ref_id,
                jhu_jrnl_rev_date,
                jhu_manual_flag,
                jhu_version
           FROM gui.gui_jrnl_headers_unposted gu
                CROSS JOIN
                (SELECT DISTINCT
                        jlu_jrnl_hdr_id jlu_jrnl_hdr_id,
                        COALESCE (PSMRE.REINS_LE_CD, ELE.ELIMINATION_LE_CD)
                           JLU_ENTITY
                   FROM gui.gui_jrnl_lines_unposted jlu
                        JOIN stn.elimination_legal_entity ele
                           ON (    ELE.LE_1_CD = JLU.JLU_ENTITY
                               AND ELE.LE_2_CD = JLU_SEGMENT_4)
                        JOIN STN.POSTING_LEDGER PL
                           ON PL.LEDGER_CD = JLU.JLU_SEGMENT_1
                        JOIN stn.posting_method_derivation_ic pmd
                           ON (    PMD.INPUT_LEDGER_ID = PL.LEDGER_ID
                               AND PMD.LEGAL_ENTITY_LINK_TYP =
                                      ELE.LEGAL_ENTITY_LINK_TYP)
                        LEFT JOIN stn.posting_method_derivation_rein psmre
                           ON (    JLU.JLU_ENTITY = PSMRE.LE_1_CD
                               AND JLU.JLU_SEGMENT_4 = PSMRE.LE_2_CD)
                  WHERE JLU.JLU_SEGMENT_7 IN ('AA', 'CA')) ce
          WHERE     gu.jhu_jrnl_id = ce.jlu_jrnl_hdr_id
                AND gu.jhu_jrnl_id = journal_id;


      INSERT INTO gui.gui_jrnl_lines_unposted gjlu (
                     gjlu.JLU_JRNL_HDR_ID,
                     gjlu.JLU_JRNL_LINE_NUMBER,
                     gjlu.JLU_FAK_ID,
                     gjlu.JLU_EBA_ID,
                     gjlu.JLU_JRNL_STATUS,
                     gjlu.JLU_JRNL_STATUS_TEXT,
                     gjlu.JLU_JRNL_PROCESS_ID,
                     gjlu.JLU_DESCRIPTION,
                     gjlu.JLU_SOURCE_JRNL_ID,
                     gjlu.JLU_EFFECTIVE_DATE,
                     gjlu.JLU_VALUE_DATE,
                     gjlu.JLU_ENTITY,
                     gjlu.JLU_EPG_ID,
                     gjlu.JLU_account,
                     gjlu.JLU_SEGMENT_1,
                     gjlu.JLU_SEGMENT_2,
                     gjlu.JLU_SEGMENT_3,
                     gjlu.JLU_SEGMENT_4,
                     gjlu.JLU_SEGMENT_5,
                     gjlu.JLU_SEGMENT_6,
                     gjlu.JLU_SEGMENT_7,
                     gjlu.JLU_SEGMENT_8,
                     gjlu.JLU_SEGMENT_9,
                     gjlu.JLU_SEGMENT_10,
                     gjlu.JLU_ATTRIBUTE_1,
                     gjlu.JLU_ATTRIBUTE_2,
                     gjlu.JLU_ATTRIBUTE_3,
                     gjlu.JLU_ATTRIBUTE_4,
                     gjlu.JLU_ATTRIBUTE_5,
                     gjlu.JLU_REFERENCE_1,
                     gjlu.JLU_REFERENCE_2,
                     gjlu.JLU_REFERENCE_3,
                     gjlu.JLU_REFERENCE_4,
                     gjlu.JLU_REFERENCE_5,
                     gjlu.JLU_REFERENCE_6,
                     gjlu.JLU_REFERENCE_7,
                     gjlu.JLU_REFERENCE_8,
                     gjlu.JLU_REFERENCE_9,
                     gjlu.JLU_REFERENCE_10,
                     gjlu.JLU_TRAN_CCY,
                     gjlu.JLU_TRAN_AMOUNT,
                     gjlu.JLU_BASE_RATE,
                     gjlu.JLU_BASE_CCY,
                     gjlu.JLU_BASE_AMOUNT,
                     gjlu.JLU_LOCAL_RATE,
                     gjlu.JLU_LOCAL_CCY,
                     gjlu.JLU_LOCAL_AMOUNT,
                     gjlu.JLU_CREATED_BY,
                     gjlu.JLU_CREATED_ON,
                     gjlu.JLU_AMENDED_BY,
                     gjlu.JLU_AMENDED_ON,
                     gjlu.JLU_JRNL_TYPE,
                     gjlu.JLU_JRNL_DATE,
                     gjlu.JLU_JRNL_DESCRIPTION,
                     gjlu.JLU_JRNL_SOURCE,
                     gjlu.JLU_JRNL_SOURCE_JRNL_ID,
                     gjlu.JLU_JRNL_AUTHORISED_BY,
                     gjlu.JLU_JRNL_AUTHORISED_ON,
                     gjlu.JLU_JRNL_VALIDATED_BY,
                     gjlu.JLU_JRNL_VALIDATED_ON,
                     gjlu.JLU_JRNL_POSTED_BY,
                     gjlu.JLU_JRNL_POSTED_ON,
                     gjlu.JLU_JRNL_TOTAL_HASH_DEBIT,
                     gjlu.JLU_JRNL_TOTAL_HASH_CREDIT,
                     gjlu.JLU_JRNL_PREF_STATIC_SRC,
                     gjlu.JLU_JRNL_REF_ID,
                     gjlu.JLU_JRNL_REV_DATE,
                     gjlu.JLU_TRANSLATION_DATE,
                     gjlu.JLU_PERIOD_MONTH,
                     gjlu.JLU_PERIOD_YEAR,
                     gjlu.JLU_PERIOD_LTD)
         SELECT TO_NUMBER (vHeaderId) JLU_JRNL_HDR_ID,
                  (SELECT NVL (MAX (JLU_JRNL_LINE_NUMBER), 0)
                     FROM gui.gui_jrnl_lines_unposted jlu
                    WHERE JLU.JLU_JRNL_HDR_ID = vHeaderId)
                + ROWNUM
                   AS JLU_JRNL_LINE_NUMBER,
                JLU.JLU_FAK_ID,
                JLU.JLU_EBA_ID,
                JLU.JLU_JRNL_STATUS,
                JLU.JLU_JRNL_STATUS_TEXT,
                JLU.JLU_JRNL_PROCESS_ID,
                JLU.JLU_DESCRIPTION,
                JLU.JLU_SOURCE_JRNL_ID,
                JLU.JLU_EFFECTIVE_DATE,
                JLU.JLU_VALUE_DATE,
                COALESCE (PSMRE.REINS_LE_CD, ELE.ELIMINATION_LE_CD)
                   JLU_ENTITY,
                JLU.JLU_EPG_ID,
                JLU.JLU_account,
                pl2.LEDGER_CD AS JLU_SEGMENT_1,                
                JLU.JLU_SEGMENT_2,
                JLU.JLU_SEGMENT_3,
                NVL2 (PSMRE.REINS_LE_CD, 'NVS', JLU.JLU_SEGMENT_4)
                   JLU_SEGMENT_4,
                NVL (PSMRE.CHARTFIELD_CD, 'NVS') JLU_SEGMENT_5,
                JLU.JLU_SEGMENT_6,
                CASE
                   WHEN     JLU.JLU_SEGMENT_4 = 'AGFPI'
                        AND JLU.JLU_SEGMENT_7 = 'AA'
                   THEN
                      'D'
                   ELSE
                      JLU.JLU_SEGMENT_7
                END
                   JLU_SEGMENT_7,
                JLU.JLU_SEGMENT_8,
                JLU.JLU_SEGMENT_9,
                JLU.JLU_SEGMENT_10,
                JLU.JLU_ATTRIBUTE_1,
                JLU.JLU_ATTRIBUTE_2,
                JLU.JLU_ATTRIBUTE_3,
                JLU.JLU_ATTRIBUTE_4,
                JLU.JLU_ATTRIBUTE_5,
                JLU.JLU_REFERENCE_1,
                JLU.JLU_REFERENCE_2,
                JLU.JLU_REFERENCE_3,
                JLU.JLU_REFERENCE_4,
                JLU.JLU_REFERENCE_5,
                JLU.JLU_REFERENCE_6,
                JLU.JLU_REFERENCE_7,
                JLU.JLU_REFERENCE_8,
                JLU.JLU_REFERENCE_9,
                JLU.JLU_REFERENCE_10,
                JLU.JLU_TRAN_CCY,
                JLU.JLU_TRAN_AMOUNT * -1 JLU_TRAN_AMOUNT,
                JLU.JLU_BASE_RATE,
                JLU.JLU_BASE_CCY,
                JLU.JLU_BASE_AMOUNT * -1 JLU_BASE_AMOUNT,
                JLU.JLU_LOCAL_RATE,
                JLU.JLU_LOCAL_CCY,
                JLU.JLU_LOCAL_AMOUNT * -1 JLU_LOCAL_AMOUNT,
                JLU.JLU_CREATED_BY,
                JLU.JLU_CREATED_ON,
                JLU.JLU_AMENDED_BY,
                JLU.JLU_AMENDED_ON,
                JLU_JRNL_TYPE,
                JLU_JRNL_DATE,
                JLU_JRNL_DESCRIPTION,
                JLU_JRNL_SOURCE,
                JLU_JRNL_SOURCE_JRNL_ID,
                JLU_JRNL_AUTHORISED_BY,
                JLU_JRNL_AUTHORISED_ON,
                JLU_JRNL_VALIDATED_BY,
                JLU_JRNL_VALIDATED_ON,
                JLU_JRNL_POSTED_BY,
                JLU_JRNL_POSTED_ON,
                JLU_JRNL_TOTAL_HASH_DEBIT,
                JLU_JRNL_TOTAL_HASH_CREDIT,
                JLU_JRNL_PREF_STATIC_SRC,
                JLU_JRNL_REF_ID,
                JLU_JRNL_REV_DATE,
                JLU_TRANSLATION_DATE,
                JLU_PERIOD_MONTH,
                JLU_PERIOD_YEAR,
                JLU_PERIOD_LTD
           FROM gui.gui_jrnl_lines_unposted jlu
                JOIN stn.elimination_legal_entity ele
                   ON (    ELE.LE_1_CD = JLU.JLU_ENTITY
                       AND ELE.LE_2_CD = JLU_SEGMENT_4)
                JOIN STN.POSTING_LEDGER PL
                   ON PL.LEDGER_CD = JLU.JLU_SEGMENT_1
                JOIN stn.posting_method_derivation_ic pmd
                   ON (    PMD.INPUT_LEDGER_ID = PL.LEDGER_ID
                       AND PMD.LEGAL_ENTITY_LINK_TYP =
                              ELE.LEGAL_ENTITY_LINK_TYP)
                LEFT JOIN stn.posting_method_derivation_rein psmre
                   ON (    JLU.JLU_ENTITY = PSMRE.LE_1_CD
                       AND JLU.JLU_SEGMENT_4 = PSMRE.LE_2_CD)
                LEFT JOIN STN.POSTING_LEDGER pl2 on (
                    pl2.ledger_id = pmd.OUTPUT_LEDGER_ID )                                              
          WHERE     JLU.JLU_SEGMENT_7 IN ('AA', 'CA')
                AND jlu.JLU_JRNL_HDR_ID = journal_id;

      COMMIT;  
   
    return;
    
   EXCEPTION
      WHEN OTHERS
      THEN
         pr_error (1,
                   SQLERRM,
                   0,
                   'pCreateEliminations',
                   'gui_jrnl_lines_unposted',
                   NULL,
                   NULL,
                   gPackageName,
                   'PL/SQL',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL);
         success := 'F';

         RAISE;
   END pCreateEliminations;
END pgui_manual_journal;
/
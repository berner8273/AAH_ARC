CREATE OR REPLACE PACKAGE SLR."SLR_UTILITIES_PKG" AS
/* ******************************************************************************
*
* Id:           $Id: SLR_UTILITIES_PKG.sql,v 1.1 2007/11/21 17:39:06 michalg Exp $
* Description: Sub-ledger utility processes.
*
* Note:        This package should NOT include the following:
*                 - reconciliation
*                 - FDR / SLR interface processing
*                 - site specific processing
*
* History:
* SC  10-MAY-2005 Amended for TTP88 (SLR error reporting).
********************************************************************************/

/*********************************************************************************
* Declare public processes
*********************************************************************************/
    PROCEDURE pRunValidateAndPost
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
		p_rate_set IN slr_entities.ent_rate_set%TYPE,
		pprocess IN Number
    );

    PROCEDURE pCalculateStatistics;

    PROCEDURE pResetFailedJournals
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_process_id IN NUMBER,
        p_use_Headers OUT BOOLEAN
    );

    PROCEDURE pUPDATE_SLR_ENTITY_DAYS      (p_entity_set  in SLR_ENTITY_DAYS.ED_ENTITY_SET%TYPE,
                                            p_start_date  in date,
                                            p_end_date    in date,
                                            p_status      in SLR_ENTITY_DAYS.ED_STATUS%TYPE,
                                            p_calendar_name in FR_HOLIDAY_DATE.HD_CA_CALENDAR_NAME%TYPE := 'DEFAULT',
                                            p_delete_existing_days in CHAR := 'Y');

    PROCEDURE pUPDATE_SLR_ENTITY_PERIODS   (p_entity in SLR_ENTITIES.ENT_ENTITY%TYPE,
                                            p_start_bus_year_month in NUMBER,
                                            p_start_date in date,
                                            p_end_date in date,
                                            p_status in VARCHAR2,
                                            p_delete_existing_periods IN CHAR := 'Y');

    PROCEDURE pUpdateJrnlLinesUnposted
    (
        p_epg_id        IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE
    );
    PROCEDURE pUpdateJrnlLinesUnposted
    (
        p_epg_id 		IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        pProcessId		IN NUMBER,
        pStatus			IN CHAR := 'U',
        pJrnlId SLR_JRNL_HEADERS.JH_JRNL_ID%TYPE := NULL
    );

    -- returns subpartition name P[YYYYMMDD]_S[ENT_GROUP]
    FUNCTION fSubpartitionName
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_date IN DATE
    ) RETURN VARCHAR2;

    FUNCTION fSubpartitionExists
    (
        p_table_name VARCHAR,
        p_subpartition_name VARCHAR
    ) RETURN BOOLEAN;

    FUNCTION fUserSubpartitionExists
    (
        p_user VARCHAR,
        p_table_name VARCHAR,
        p_subpartition_name VARCHAR
    ) RETURN BOOLEAN;

    FUNCTION fHint
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_statement IN SLR_HINTS_SETS.HS_STATEMENT%TYPE
    ) RETURN SLR_HINTS_SETS.HS_HINT%TYPE;

    PROCEDURE pDropTableIfExists
    (
        p_table_name IN VARCHAR2
    );

    FUNCTION fGetEntityProcGroup
    (
        pJrnlHdrID          in SLR_JRNL_HEADERS_UNPOSTED.JHU_JRNL_ID%TYPE
    ) RETURN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE;


    FUNCTION fEntityGroupCurrBusDate
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE
    ) RETURN SLR_ENTITIES.ENT_BUSINESS_DATE%TYPE;

    PROCEDURE pAssignNewProcessIdAndStatus
    (
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_header_id_list IN VARCHAR2,
        p_status_from IN CHAR,
        p_status_to	IN CHAR,
        p_process_id OUT NUMBER
    );

    PROCEDURE pSetDdlLockTimeout(p_timeout INT);

    FUNCTION fGetDdlLockTimeout RETURN INT;

    -- materialises EBA balances denormalized table
    PROCEDURE MAT_EPG_ID_BD_All_EBA_TABLE
    (
        p_epg_id VARCHAR2,
        p_epg_id_alias VARCHAR2
    );


    PROCEDURE pUpdateFakEbaCombinations_Jlu
    (
      p_entity_proc_group IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
      p_process_id IN NUMBER,
      p_status IN CHAR DEFAULT 'U'
    );

    PROCEDURE pInsertFakEbaCombinations_Jlu
  (
      p_entity_proc_group IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
      p_process_id IN NUMBER,
      p_status IN CHAR DEFAULT 'U'
  );

      -- materialises FAK balances denormalized table
    PROCEDURE MAT_EPG_ID_BD_All_FAK_TABLE
    (
        p_epg_id VARCHAR2,
        p_epg_id_alias VARCHAR2
    );

  -- Sequence function

    FUNCTION fSLR_SEQ_EBA_COMBO_ID RETURN NUMBER;

    FUNCTION fSLR_SEQ_FAK_COMBO_ID RETURN NUMBER;

    FUNCTION fSLR_SEQ_PROCESS_ID RETURN NUMBER;

END SLR_UTILITIES_PKG;

/
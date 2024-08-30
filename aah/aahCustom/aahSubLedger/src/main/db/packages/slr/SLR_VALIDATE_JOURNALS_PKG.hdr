
--------------------------------------------------------
--  DDL for Package SLR_VALIDATE_JOURNALS_PKG
--------------------------------------------------------

CREATE OR REPLACE PACKAGE "SLR"."SLR_VALIDATE_JOURNALS_PKG" 
AS
/* ***************************************************************************
*
*  Id:          $Id: SLR_VALIDATE_JOURNALS_PKG.sql,v 1.1 2007/08/14 16:55:59 adrianj Exp $
*
*  Description: Validate journals in the unposted journals table.
*
* ************************************************************************** */

    type rValidationRow is record (
      validation varchar2(200),
      jlu_entity varchar2(200),
      value1 varchar2(200),
      value2 varchar2(200),
      value3 varchar2(200),
      value4 varchar2(200),
      value5 varchar2(200),
      value6 varchar2(200),
      value7 varchar2(200),
      value8 varchar2(200), 
      value9 varchar2(200) 
    );    
    
    type ttValidationTable is table of rValidationRow;

    /**************************************************************************
    * Declare public processes
    **************************************************************************/
    PROCEDURE pValidateJournals
    (
      p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
      p_process_id IN NUMBER,
      p_status IN CHAR := 'U',
      p_UseHeaders IN BOOLEAN := FALSE,
      p_rate_set IN slr_entities.ent_rate_set%TYPE
    );

    PROCEDURE pWriteLineError
    (
      p_entity IN slr_entities.ent_entity%TYPE,
      p_process_id in NUMBER,
      p_status_text in VARCHAR2,
      p_msg in VARCHAR2,
      p_sql in VARCHAR2,
      p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
      p_status IN CHAR := 'U',
      p_UseHeaders IN BOOLEAN := FALSE
    );
/*-----------CUSTOMIZATION FROM 20.2.3 MERGE START-----------*/
    -- AG custom
    PROCEDURE pWriteLineErrorEventClass
    (
         p_fdr_event_class IN FDR.FR_GENERAL_LOOKUP.LK_LOOKUP_VALUE3%TYPE,
        p_process_id in NUMBER,
        p_status_text in VARCHAR2,
        p_msg in VARCHAR2,
        p_sql in VARCHAR2,
        p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
        p_status IN CHAR := 'U',
        p_UseHeaders IN BOOLEAN := FALSE
    );
/*-----------CUSTOMIZATION FROM 20.2.3 MERGE END-----------*/
    PROCEDURE pWriteLogError(  
      p_proc_name     in  VARCHAR2,
      p_table_name    in  VARCHAR2,
      p_msg           in  VARCHAR2,
      p_process_id    in  SLR_JRNL_LINES_UNPOSTED.JLU_JRNL_PROCESS_ID%TYPE,
      p_epg_id        IN  SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
      p_status        IN  CHAR := 'U',
      p_entity        IN  slr_entities.ent_entity%TYPE:=NULL
    );

    PROCEDURE pCheckJournalStatus (p_jrnl_type in SLR_JRNL_HEADERS_UNPOSTED.JHU_JRNL_TYPE%TYPE := 'MADJ');    

    PROCEDURE pInsertFakEbaCombinations (
      p_epg_id IN SLR_ENTITY_PROC_GROUP.EPG_ID%TYPE,
      p_process_id IN NUMBER,
      p_status IN VARCHAR2
    );    

END SLR_VALIDATE_JOURNALS_PKG;

/
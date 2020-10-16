DECLARE
  COUNT_INDEXES INTEGER;
BEGIN

  SELECT COUNT(*) INTO COUNT_INDEXES
    FROM ALL_INDEXES
    WHERE upper(INDEX_NAME) = 'CE_EVENT_STATUS';

  IF COUNT_INDEXES > 0 THEN
    EXECUTE IMMEDIATE 'DROP INDEX CE_EVENT_STATUS';
    
  END IF;
  EXECUTE IMMEDIATE 'create index ce_event_status on stn.cession_event (event_status)';
  
  --IDX_CEV_DATA_COMP1
  SELECT COUNT(*) INTO COUNT_INDEXES
    FROM ALL_INDEXES
    WHERE upper(INDEX_NAME) = 'IDX_CEV_DATA_COMP1';

  IF COUNT_INDEXES > 0 THEN
    EXECUTE IMMEDIATE 'DROP INDEX STN.IDX_CEV_DATA_COMP1';
  END IF;
  
  --IDX_CEV_DATA_COMP2
  SELECT COUNT(*) INTO COUNT_INDEXES
    FROM ALL_INDEXES
    WHERE upper(INDEX_NAME) = 'IDX_CEV_DATA_COMP2';

  IF COUNT_INDEXES > 0 THEN
    EXECUTE IMMEDIATE 'DROP INDEX STN.IDX_CEV_DATA_COMP2';
  END IF;
  

  --I_CEV_DATA
  SELECT COUNT(*) INTO COUNT_INDEXES
    FROM ALL_INDEXES
    WHERE upper(INDEX_NAME) = 'I_CEV_DATA';

  IF COUNT_INDEXES > 0 THEN
    EXECUTE IMMEDIATE 'DROP INDEX STN.I_CEV_DATA';
  END IF;

END;
/
-- drop table "STN"."CEV_DATA";
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE stn.CEV_DATA';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/
-- drop table "STN"."CEV_GAAP_FUT_ACCTS_DATA";
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE stn.CEV_GAAP_FUT_ACCTS_DATA';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/
-- drop table "STN"."CEV_INTERCOMPANY_DATA";
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE stn.CEV_INTERCOMPANY_DATA';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/
-- drop table "STN"."CEV_MTM_DATA";
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE stn.CEV_MTM_DATA';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/
-- drop table "STN"."CEV_NON_INTERCOMPANY_DATA";
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE stn.CEV_NON_INTERCOMPANY_DATA';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/
-- drop table "STN"."CEV_PREMIUM_TYP_OVERRIDE";
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE stn.CEV_PREMIUM_TYP_OVERRIDE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/
-- drop table "STN"."CEV_VIE_DATA";
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE stn.CEV_VIE_DATA';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/
-- drop table "STN"."POSTING_ACCOUNT_DERIVATION";
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE stn.POSTING_ACCOUNT_DERIVATION';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE stn.CEV_STANDARDISATION_LOG';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/
@@../aahCustom/aahStandardisation/src/main/db/tables/stn/cev_data.sql
@@../aahCustom/aahStandardisation/src/main/db/tables/stn/cev_gaap_fut_accts_data.sql
@@../aahCustom/aahStandardisation/src/main/db/tables/stn/cev_intercompany_data.sql
@@../aahCustom/aahStandardisation/src/main/db/tables/stn/cev_mtm_data.sql
@@../aahCustom/aahStandardisation/src/main/db/tables/stn/cev_non_intercompany_data.sql
@@../aahCustom/aahStandardisation/src/main/db/tables/stn/cev_premium_typ_override.sql
@@../aahCustom/aahStandardisation/src/main/db/tables/stn/CEV_STANDARDISATION_LOG.sql
@@../aahCustom/aahStandardisation/src/main/db/tables/stn/cev_vie_data.sql
@@../aahCustom/aahStandardisation/src/main/db/tables/stn/posting_account_derivation.sql
/
@@../aahCustom/aahStandardisation/src/main/db/packages/stn/pk_cev.bdy



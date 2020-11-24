DECLARE
    i INTEGER;
   
BEGIN
    SELECT COUNT(*) INTO i FROM user_indexes WHERE index_name = 'BAK_XPK_GLINT_JOURNAL_MAPPING';
    IF i = 0 THEN
        EXECUTE IMMEDIATE 'ALTER INDEX XPK_GLINT_JOURNAL_MAPPING RENAME TO BAK_XPK_GLINT_JOURNAL_MAPPING';
    END IF;

    SELECT COUNT(*) INTO i FROM user_indexes WHERE index_name = 'BAK_INDEXXIF1GL_INTERFACE_JOURNAL_MAPPI';
    IF i = 0 THEN
        EXECUTE IMMEDIATE 'ALTER INDEX XIF1GL_INTERFACE_JOURNAL_MAPPI RENAME TO BAK_INDEXXIF1GL_INTERFACE_JOURNAL_MAPPI';
    END IF;

    SELECT COUNT(*) INTO i FROM USER_CONSTRAINTS WHERE CONSTRAINT_NAME = 'BAK_XPK_GLINT_JOURNAL_MAPPING';
    IF i = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE RR_GLINT_JOURNAL_MAPPING RENAME CONSTRAINT XPK_GLINT_JOURNAL_MAPPING TO BAK_XPK_GLINT_JOURNAL_MAPPING';
    END IF;

    SELECT COUNT(*) INTO i FROM USER_CONSTRAINTS WHERE CONSTRAINT_NAME = 'BAK_GLINT_BC_JM';
    IF i = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE RR_GLINT_JOURNAL_MAPPING RENAME CONSTRAINT GLINT_BC_JM TO BAK_GLINT_BC_JM';
    END IF;

    SELECT COUNT(*) INTO i FROM USER_CONSTRAINTS WHERE CONSTRAINT_NAME = 'BAK_GLINT_JM_J';
    IF i = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE RR_GLINT_JOURNAL_MAPPING RENAME CONSTRAINT GLINT_JM_J TO BAK_GLINT_JM_J';
    END IF;

    SELECT COUNT(*) INTO i FROM USER_CONSTRAINTS WHERE CONSTRAINT_NAME = 'BAK_GLINT_JM_J';
    IF i = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE RR_GLINT_JOURNAL_MAPPING RENAME CONSTRAINT GLINT_JM_J TO BAK_GLINT_JM_J';
    END IF;

    select COUNT(*) into i from tab where tname = 'BAK_RR_GLINT_JOURNAL_MAPPING';
    IF i = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE RR_GLINT_JOURNAL_MAPPING RENAME TO BAK_RR_GLINT_JOURNAL_MAPPING';
    END IF;

    select COUNT(*) into i from tab where tname = 'RR_GLINT_JOURNAL_MAPPING';
    IF i <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE RR_GLINT_JOURNAL_MAPPING';
    END IF;

END;
/
CREATE TABLE RR_GLINT_JOURNAL_MAPPING (
  RGJM_RGBC_ID NOT NULL,
  RGJM_INPUT_JRNL_ID NOT NULL,
  RGJM_RGJ_ID,
  INPUT_TIME DEFAULT SYSDATE NOT NULL,
  INPUT_USER DEFAULT USER NOT NULL,
  MODIFIED_TIME DEFAULT SYSDATE NOT NULL,
  MODIFIED_USER DEFAULT USER NOT NULL
) AS
SELECT RGJM_RGBC_ID,
       CAST(STANDARD_HASH(TO_CHAR(RGJM_INPUT_JRNL_ID), 'MD5') AS CHAR(32)) AS RGJM_INPUT_JRNL_ID,
       RGJM_RGJ_ID,
       INPUT_TIME,
       INPUT_USER,
       MODIFIED_TIME,
       MODIFIED_USER
FROM BAK_RR_GLINT_JOURNAL_MAPPING;

ALTER TABLE RR_GLINT_JOURNAL_MAPPING ADD CONSTRAINT XPK_GLINT_JOURNAL_MAPPING PRIMARY KEY (RGJM_RGBC_ID, RGJM_INPUT_JRNL_ID);
ALTER TABLE RR_GLINT_JOURNAL_MAPPING ADD CONSTRAINT GLINT_BC_JM FOREIGN KEY (RGJM_RGBC_ID) REFERENCES RDR.RR_GLINT_BATCH_CONTROL (RGBC_ID);
ALTER TABLE RR_GLINT_JOURNAL_MAPPING ADD CONSTRAINT GLINT_JM_J FOREIGN KEY (RGJM_RGBC_ID, RGJM_RGJ_ID) REFERENCES RDR.RR_GLINT_JOURNAL (RGJ_RGBC_ID, RGJ_ID);
CREATE INDEX RDR.XIF1GL_INTERFACE_JOURNAL_MAPPI ON RDR.RR_GLINT_JOURNAL_MAPPING (RGJM_RGBC_ID);
CREATE INDEX RDR.XIF2GL_INTERFACE_JOURNAL_MAPPI ON RDR.RR_GLINT_JOURNAL_MAPPING (RGJM_RGJ_ID, RGJM_RGBC_ID); 

COMMENT ON COLUMN RDR.RR_GLINT_JOURNAL_MAPPING.RGJM_RGBC_ID IS 'The unique batch identifier.';
COMMENT ON COLUMN RDR.RR_GLINT_JOURNAL_MAPPING.RGJM_INPUT_JRNL_ID IS 'The AAH Journal Internal Identifier (SLR_JRNL_HEADERS).';
COMMENT ON COLUMN RDR.RR_GLINT_JOURNAL_MAPPING.RGJM_RGJ_ID IS 'The Journal Identifier as it will appear in the GL. Populated as per the configuration.';
COMMENT ON COLUMN RDR.RR_GLINT_JOURNAL_MAPPING.INPUT_TIME IS 'Date/Time the record was first inserted.';
COMMENT ON COLUMN RDR.RR_GLINT_JOURNAL_MAPPING.INPUT_USER IS 'User/Process that created the record.';
COMMENT ON COLUMN RDR.RR_GLINT_JOURNAL_MAPPING.MODIFIED_TIME IS 'Date/Time the record was last updated.';
COMMENT ON COLUMN RDR.RR_GLINT_JOURNAL_MAPPING.MODIFIED_USER IS 'User/Process that last updated the record.';
COMMENT ON TABLE RDR.RR_GLINT_JOURNAL_MAPPING  IS 'Stores the AAH journal identifiers that were extracted for a particular batch control instance along with their GL journal identifiers. This entity determines which AAH journals have been summarised as a single journal within GL.';

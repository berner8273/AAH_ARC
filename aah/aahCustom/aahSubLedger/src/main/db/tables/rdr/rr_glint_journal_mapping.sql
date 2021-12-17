CREATE TABLE rdr.rr_glint_journal_mapping
(
  RGJM_RGBC_ID        NUMBER(18)                NOT NULL,
  RGJM_INPUT_JRNL_ID  CHAR(32 BYTE)             NOT NULL,
  RGJM_RGJ_ID         VARCHAR2(30 BYTE),
  INPUT_TIME          DATE                      DEFAULT SYSDATE               NOT NULL,
  INPUT_USER          VARCHAR2(30 BYTE)         DEFAULT USER                  NOT NULL,
  MODIFIED_TIME       DATE                      DEFAULT SYSDATE               NOT NULL,
  MODIFIED_USER       VARCHAR2(30 BYTE)         DEFAULT USER                  NOT NULL,
CONSTRAINT  XPK_GLINT_JOURNAL_MAPPING PRIMARY KEY (rgjm_rgbc_id,rgjm_input_jrnl_id),
CONSTRAINT GLINT_BC_JM FOREIGN KEY (rgjm_rgbc_id) REFERENCES RDR.RR_GLINT_BATCH_CONTROL (rgbc_id),
CONSTRAINT GLINT_JM_J FOREIGN KEY (rgjm_rgbc_id, rgjm_rgj_id) REFERENCES RDR.RR_GLINT_JOURNAL (rgj_rgbc_id, rgj_id)
);
COMMENT ON TABLE RDR.RR_GLINT_JOURNAL_MAPPING IS 'Stores the AAH journal identifiers that were extracted for a particular batch control instance along with their GL journal identifiers. This entity determines which AAH journals have been summarised as a single journal within GL.';
COMMENT ON COLUMN RDR.RR_GLINT_JOURNAL_MAPPING.rgjm_rgbc_id IS 'The unique batch identifier.';
COMMENT ON COLUMN RDR.RR_GLINT_JOURNAL_MAPPING.rgjm_input_jrnl_id IS 'The AAH Journal Internal Identifier (SLR_JRNL_HEADERS).';
COMMENT ON COLUMN RDR.RR_GLINT_JOURNAL_MAPPING.rgjm_rgj_id IS 'The Journal Identifier as it will appear in the GL. Populated as per the configuration.';
COMMENT ON COLUMN RDR.RR_GLINT_JOURNAL_MAPPING.input_time IS 'Date/Time the record was first inserted.';
COMMENT ON COLUMN RDR.RR_GLINT_JOURNAL_MAPPING.input_user IS 'User/Process that created the record.';
COMMENT ON COLUMN RDR.RR_GLINT_JOURNAL_MAPPING.modified_time IS 'Date/Time the record was last updated.';
COMMENT ON COLUMN RDR.RR_GLINT_JOURNAL_MAPPING.modified_user IS 'User/Process that last updated the record.';
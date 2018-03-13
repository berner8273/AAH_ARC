CREATE GLOBAL TEMPORARY TABLE rdr.rr_glint_temp_journal
(
	jh_jrnl_id           NUMBER(18) NOT NULL ,
	jh_jrnl_date         DATE NULL ,
	jh_jrnl_entity       VARCHAR2(30) NULL ,
	jh_jrnl_epg_id       VARCHAR2(18) NULL ,
	previous_flag        CHAR(1) NULL ,
	lkt_lookup_type_code VARCHAR2(100) NULL ,
CONSTRAINT  XPKRR_GLINT_TEMP_JOURNAL PRIMARY KEY (jh_jrnl_id)
)	ON COMMIT DELETE ROWS;
COMMENT ON TABLE RDR.RR_GLINT_TEMP_JOURNAL IS 'Temporary table to hold the journals that will be sent to the GL for a particular interface run.';
COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL.jh_jrnl_id IS 'The AAH Journal Internal Identifier (SLR_JRNL_HEADERS).';
COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL.jh_jrnl_date IS 'The Journal Date.';
COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL.jh_jrnl_entity IS 'The Entity of the Journal.';
COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL.jh_jrnl_epg_id IS 'The Entity Processing Group Identifier.';
COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL.previous_flag IS 'Whether the Journal has previously been sent to the GL (Y) or not (N).';
COMMENT ON COLUMN RDR.RR_GLINT_TEMP_JOURNAL.lkt_lookup_type_code IS 'The GLINT configuration type code for the journal.';
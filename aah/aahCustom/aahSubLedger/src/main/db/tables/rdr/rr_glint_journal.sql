CREATE TABLE rdr.rr_glint_journal
(
	rgj_rgbc_id          NUMBER(18) NOT NULL ,
	rgj_id               VARCHAR2(30) NOT NULL ,
	event_status         CHAR(1) DEFAULT  'U'  NOT NULL ,
	input_time           DATE DEFAULT  sysdate  NOT NULL ,
	input_user           VARCHAR2(30) DEFAULT  user  NOT NULL ,
	modified_time        DATE DEFAULT  sysdate  NOT NULL ,
	modified_user        VARCHAR2(30) DEFAULT  user  NOT NULL ,
CONSTRAINT  XPK_GLINT_JOURNAL PRIMARY KEY (rgj_rgbc_id,rgj_id),
CONSTRAINT GLINT_BC_J FOREIGN KEY (rgj_rgbc_id) REFERENCES RDR.RR_GLINT_BATCH_CONTROL (rgbc_id)
);
COMMENT ON TABLE RDR.RR_GLINT_JOURNAL IS 'Stores the GL journals that were extracted for a specific batch. An optional acknowledgment from the  GL updates the status of this entity to denote if the journal succeeded or failed within the GL. For those that failed could be resubmitted in a future interface instance by updating the status accordingly.';
COMMENT ON COLUMN RDR.RR_GLINT_JOURNAL.rgj_rgbc_id IS 'The unique batch identifier.';
COMMENT ON COLUMN RDR.RR_GLINT_JOURNAL.rgj_id IS 'The Journal Identifier as it will appear in the GL. Populated as per the configuration.';
COMMENT ON COLUMN RDR.RR_GLINT_JOURNAL.event_status IS 'The status of the GL journal: ''P''rocessed in AAH (by GL Interface process), ''E''rror in GL (by custom acknowledgment process), ''U''nprocessed (marked for resubmission - either by AAH GUI or custom process) , ''R''esubmitted (journal exists in a prior batch with a ''U'' status - by GL Interface process). Important: This MUST be named "event_status" because the AAH GUI error resubmission process hard-codes the column names (this was originally intended for resubmitting hoppers and so this column shares the same name).';
COMMENT ON COLUMN RDR.RR_GLINT_JOURNAL.input_time IS 'Date/Time the record was first inserted.';
COMMENT ON COLUMN RDR.RR_GLINT_JOURNAL.input_user IS 'User/Process that created the record.';
COMMENT ON COLUMN RDR.RR_GLINT_JOURNAL.modified_time IS 'Date/Time the record was last updated.';
COMMENT ON COLUMN RDR.RR_GLINT_JOURNAL.modified_user IS 'User/Process that last updated the record.';
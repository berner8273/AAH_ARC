CREATE TABLE rdr.rr_glint_batch_control
(
	rgbc_id              NUMBER(18) NOT NULL ,
	rgbc_accounting_date DATE NOT NULL ,
	rgbc_hash_debit_total DECIMAL(38,3) DEFAULT  0  NOT NULL ,
	rgbc_hash_credit_total DECIMAL(38,3) DEFAULT  0  NOT NULL ,
	rgbc_line_count      NUMBER(18) NOT NULL ,
  rgbc_process_type    VARCHAR2(20) NULL ,
	rgbc_load_name       VARCHAR2(100) NOT NULL ,
	rgbc_load_type       VARCHAR2(20) NULL ,
	rgbc_rgic_id         NUMBER(18) NULL ,
	input_time           DATE DEFAULT  sysdate  NOT NULL ,
	input_user           VARCHAR2(30) DEFAULT  user  NOT NULL ,
	modified_time        DATE DEFAULT  sysdate  NOT NULL ,
	modified_user        VARCHAR2(30) DEFAULT  user  NOT NULL ,
CONSTRAINT  XPK_GLINT_BATCH_CONTROL PRIMARY KEY (rgbc_id),
CONSTRAINT GLINT_IC_BC FOREIGN KEY (rgbc_rgic_id) REFERENCES RDR.RR_INTERFACE_CONTROL (rgic_id)
);
COMMENT ON TABLE RDR.RR_GLINT_BATCH_CONTROL IS 'Stores a batch of journals that are to be sent to a General Ledger. This allows for multiple batches to be created within the same run (RR_INTERFACE_CONTROL).';
COMMENT ON COLUMN RDR.RR_GLINT_BATCH_CONTROL.rgbc_id IS 'The unique batch identifier.';
COMMENT ON COLUMN RDR.RR_GLINT_BATCH_CONTROL.rgbc_accounting_date IS 'Business Date of the Batch. Populated as per the configuration.';
COMMENT ON COLUMN RDR.RR_GLINT_BATCH_CONTROL.rgbc_hash_debit_total IS 'The sum of the debits within the batch. Populated as per the configuration.';
COMMENT ON COLUMN RDR.RR_GLINT_BATCH_CONTROL.rgbc_hash_credit_total IS 'The sum of the credits within the batch. Populated as per the configuration.';
COMMENT ON COLUMN RDR.RR_GLINT_BATCH_CONTROL.rgbc_line_count IS 'The number of journal lines with the batch.';
COMMENT ON COLUMN RDR.RR_GLINT_BATCH_CONTROL.rgbc_process_type IS 'The process type of the batch as per the configuration.';
COMMENT ON COLUMN RDR.RR_GLINT_BATCH_CONTROL.rgbc_load_name IS 'The name for the load as derived internally within the GL Interface. Populated as per the configuration.';
COMMENT ON COLUMN RDR.RR_GLINT_BATCH_CONTROL.rgbc_load_type IS 'The load type for the batch. Populated as per the configuration.';
COMMENT ON COLUMN RDR.RR_GLINT_BATCH_CONTROL.rgbc_rgic_id IS 'The GL interface instance identifier.';
COMMENT ON COLUMN RDR.RR_GLINT_BATCH_CONTROL.input_time IS 'Date/Time the record was first inserted.';
COMMENT ON COLUMN RDR.RR_GLINT_BATCH_CONTROL.input_user IS 'User/Process that created the record.';
COMMENT ON COLUMN RDR.RR_GLINT_BATCH_CONTROL.modified_time IS 'Date/Time the record was last updated.';
COMMENT ON COLUMN RDR.RR_GLINT_BATCH_CONTROL.modified_user IS 'User/Process that last updated the record.';
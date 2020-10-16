CREATE TABLE rdr.rr_interface_control
(
	rgic_id              NUMBER(18) NOT NULL ,
	rgic_count           NUMBER(18) DEFAULT  0  NULL ,
	rgic_status_flag     CHAR(1) DEFAULT  'U'  NOT NULL ,
	input_time           DATE DEFAULT  sysdate  NOT NULL ,
	input_user           VARCHAR2(30) DEFAULT  user  NOT NULL ,
	modified_time        DATE DEFAULT  sysdate  NOT NULL ,
	modified_user        VARCHAR2(30) DEFAULT  user  NOT NULL ,
CONSTRAINT  XPKGL_Interface_Control PRIMARY KEY (rgic_id)
);
COMMENT ON TABLE RDR.RR_INTERFACE_CONTROL IS 'Stores the instances of each GL Interface run. Each instance will have one or more batches to send to the GL (in RR_GLINT_BATCH_CONTROL).';
COMMENT ON COLUMN RDR.RR_INTERFACE_CONTROL.rgic_id IS 'The GL interface instance identifier.';
COMMENT ON COLUMN RDR.RR_INTERFACE_CONTROL.rgic_count IS 'The number of AAH journals processed by the interface instance.';
COMMENT ON COLUMN RDR.RR_INTERFACE_CONTROL.rgic_status_flag IS 'Status of the interface instance: ''P''rocessed or ''T''ransmitted to the GL. For an error during processing, then this is set to ''E''.';
COMMENT ON COLUMN RDR.RR_INTERFACE_CONTROL.input_time IS 'Date/Time the record was first inserted.';
COMMENT ON COLUMN RDR.RR_INTERFACE_CONTROL.input_user IS 'User/Process that created the record.';
COMMENT ON COLUMN RDR.RR_INTERFACE_CONTROL.modified_time IS 'Date/Time the record was last updated.';
COMMENT ON COLUMN RDR.RR_INTERFACE_CONTROL.modified_user IS 'User/Process that last updated the record.';
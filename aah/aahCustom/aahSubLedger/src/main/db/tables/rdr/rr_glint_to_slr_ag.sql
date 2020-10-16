CREATE TABLE rdr.rr_glint_to_slr_ag
(
   rgjl_id               NUMBER (18) NOT NULL,
   jl_jrnl_hdr_id        NUMBER (12) NOT NULL,
   jl_jrnl_line_number   NUMBER (12) NOT NULL
);

COMMENT ON TABLE RDR.RR_GLINT_TO_SLR_AG IS 'MAPS SLR JOURNALS TO GLINT JOURNALS';
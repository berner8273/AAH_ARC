CREATE INDEX rdr.idx_rr_glint_to_slr_ag_hdr ON rdr.rr_glint_to_slr_ag (jl_jrnl_hdr_id);
ALTER TABLE rdr.rr_glint_to_slr_ag ADD CONSTRAINT "xpk_rr_glint_to_slr_ag" PRIMARY KEY ("RGJL_ID");
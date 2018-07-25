CREATE INDEX xif1gl_interface_journal_line ON rdr.rr_glint_journal_line (rgjl_rgj_id   ASC,rgjl_rgj_rgbc_id   ASC);
CREATE INDEX idx_ag_glint_je_line01 ON rdr.rr_glint_journal_line (ps_filter);
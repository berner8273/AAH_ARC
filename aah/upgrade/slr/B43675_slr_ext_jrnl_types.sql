update slr.slr_ext_jrnl_types
set  ejt_active_flag = 'A'
where ejt_type in ('FXREVALUE','MADJ_NONREVERSING','MADJ_REVERSING','PERC','PLRETEARNINGS');

commit;
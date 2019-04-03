-- update journal type descriptions for manual journal entries by gui
update slr.slr_ext_jrnl_types set ejt_madj_flag = 'N' where ejt_type not in ('MADJPERB','MADJPERC','MADJPERF','MADJREVD','MADJREVOD', 'MADJ_REVERSING','MADJ_NONREVERSING');
update slr.slr_ext_jrnl_types set ejt_madj_flag = 'Y' where ejt_type in ('MADJPERB','MADJPERC','MADJPERF','MADJREVD','MADJREVOD');
update slr.slr_ext_jrnl_types set ejt_active_flag = 'I' where ejt_type not in ('MADJPERB','MADJPERC','MADJPERF','MADJREVD','MADJREVOD','PERC','FXREVALUE','PLRETEARNINGS','MADJ_NONREVERSING', 'MADJ_REVERSING');
update slr.slr_ext_jrnl_types set ejt_active_flag = 'A' where ejt_type in ('MADJPERB','MADJPERC','MADJPERF','MADJREVD','MADJREVOD','PERC','FXREVALUE','PLRETEARNINGS');
update slr.slr_ext_jrnl_types set ejt_short_desc = 'MADJ Acctng Date < System Date' where ejt_type = 'MADJPERB';
update slr.slr_ext_jrnl_types set ejt_short_desc = 'MADJ Acctng Date = System Date' where ejt_type = 'MADJPERC';
update slr.slr_ext_jrnl_types set ejt_short_desc = 'MADJ Acctng Date > System Date' where ejt_type = 'MADJPERF';
update slr.slr_ext_jrnl_types set ejt_short_desc = 'MADJ Rev AcctDt = System Date'  where ejt_type = 'MADJREVD';
update slr.slr_ext_jrnl_types set ejt_short_desc = 'MADJ Rev AcctDt < System Date' where ejt_type = 'MADJREVOD';
commit;

declare
  count_madj integer;
begin
    select count(*) into count_madj from slr.slr_ext_jrnl_types where ejt_type = 'MADJ_NONREVERSING';
    if count_madj < 1 then
        INSERT INTO slr.slr_ext_jrnl_types (ejt_type, ejt_description, ejt_short_desc, ejt_jt_type, ejt_balance_type_1, ejt_balance_type_2,
            ejt_madj_flag, ejt_requires_authorisation, ejt_eff_ejtr_code, ejt_rev_ejtr_code, ejt_rev_validation_flag, ejt_client_flag1,
            ejt_active_flag, ejt_created_by, ejt_created_on, ejt_amended_by, ejt_amended_on) 
            VALUES ('MADJ_NONREVERSING', 'Non-Reversing Manual JE', 'MADJ non-reversing', 'Permanent', 50, 20, 'Y', 'Y', 'NONE',
            'NONE', 'N', 0, 'A', 'SLR', '03-APR-2019', 'SLR', '03-APR-2019');
    end if;  

    select count(*) into count_madj from slr.slr_ext_jrnl_types where ejt_type = 'MADJ_REVERSING';
    if count_madj < 1 then
        INSERT INTO slr.slr_ext_jrnl_types ( ejt_type, ejt_description,ejt_short_desc, ejt_jt_type, ejt_balance_type_1, ejt_balance_type_2,
            ejt_madj_flag, ejt_requires_authorisation, ejt_eff_ejtr_code, ejt_rev_ejtr_code, ejt_rev_validation_flag, ejt_client_flag1,
            ejt_active_flag, ejt_created_by, ejt_created_on, ejt_amended_by, ejt_amended_on) 
            VALUES ( 'MADJ_REVERSING', 'Auto-Reversing Manual JE', 'MADJ auto-reversing', 'Reversing', 50, 20, 'Y', 'Y', 'NONE',
            'NONE', 'N', 0, 'A', 'SLR', '03-APR-2019','SLR', '03-APR-2019');
    end if;            
end;
/    
commit;
insert into fdr.fr_instr_type_class (itc_instr_type_class_id,itc_instr_type_class_name,itc_itsc_instr_type_super_id,itc_instr_type_class_clicode,itc_active,itc_input_by,itc_auth_by,itc_auth_status,itc_input_time,itc_valid_from,itc_valid_to,itc_delete_time)
  values ('INSURANCE_POLICY','INSURANCE_POLICY','INSURANCE_POLICY','INSURANCE_POLICY','A','CUST','CUST','A',sysdate,TO_DATE('2000/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS'),TO_DATE('2999/12/31 23:59:59','YYYY/MM/DD HH24:MI:SS'),null);
commit;
insert into fdr.fr_instr_type_superclass (itsc_instr_type_superclass_id,itsc_instr_type_super_clicode,itsc_instr_type_super_name,itsc_active,itsc_input_by,itsc_auth_by,itsc_auth_status,itsc_input_time,itsc_valid_from,itsc_valid_to,itsc_delete_time)
  values ('INSURANCE_POLICY','INSURANCE_POLICY','INSURANCE_POLICY','A','CUST','CUST','A',sysdate,TO_DATE('2000/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS'),TO_DATE('2999/12/31 23:59:59','YYYY/MM/DD HH24:MI:SS'),NULL);
commit;
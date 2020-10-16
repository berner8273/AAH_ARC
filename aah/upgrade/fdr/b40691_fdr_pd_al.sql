update fdr.fr_posting_driver 
set pd_posting_code = 'VIEPF_UN_FUT'
where pd_posting_code = 'VIEPF_UN'
and pd_posting_driver_id  in ('1307','961', '873', '407');
commit;

declare
  count_records integer;
begin
  select count(*) into count_records
    from fdr.fr_account_lookup
where al_posting_code = 'VIEPF_UN_FUT';
    
  if count_records = 0 then

Insert into FDR.FR_ACCOUNT_LOOKUP (AL_POSTING_CODE,AL_LOOKUP_1,AL_LOOKUP_2,AL_LOOKUP_3,AL_LOOKUP_4,AL_LOOKUP_5,AL_LOOKUP_6,AL_LOOKUP_7,AL_LOOKUP_8,AL_LOOKUP_9,AL_LOOKUP_10,AL_LOOKUP_11,AL_LOOKUP_12,AL_LOOKUP_13,AL_LOOKUP_14,AL_LOOKUP_15,AL_LOOKUP_16,AL_LOOKUP_17,AL_LOOKUP_18,AL_LOOKUP_19,AL_LOOKUP_20,AL_CCY,AL_ACCOUNT,AL_VALID_FROM,AL_VALID_TO,AL_ACTIVE,AL_ACTION,AL_INPUT_BY,AL_INPUT_TIME,AL_DELETE_TIME,AL_AUTH_BY,AL_AUTH_STATUS,AL_ID) 
values ('VIEPF_UN_FUT','A','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','13300220-01',to_date('01/01/2000 00:00:00','mm/dd/yyyy hh24:mi:ss'),to_date('12/31/2099 00:00:00','mm/dd/yyyy hh24:mi:ss'),'A','I','STN',null,null,null,null,2277);
Insert into FDR.FR_ACCOUNT_LOOKUP (AL_POSTING_CODE,AL_LOOKUP_1,AL_LOOKUP_2,AL_LOOKUP_3,AL_LOOKUP_4,AL_LOOKUP_5,AL_LOOKUP_6,AL_LOOKUP_7,AL_LOOKUP_8,AL_LOOKUP_9,AL_LOOKUP_10,AL_LOOKUP_11,AL_LOOKUP_12,AL_LOOKUP_13,AL_LOOKUP_14,AL_LOOKUP_15,AL_LOOKUP_16,AL_LOOKUP_17,AL_LOOKUP_18,AL_LOOKUP_19,AL_LOOKUP_20,AL_CCY,AL_ACCOUNT,AL_VALID_FROM,AL_VALID_TO,AL_ACTIVE,AL_ACTION,AL_INPUT_BY,AL_INPUT_TIME,AL_DELETE_TIME,AL_AUTH_BY,AL_AUTH_STATUS,AL_ID) 
values ('VIEPF_UN_FUT','D','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','ND~','13200120-01',to_date('01/01/2000 00:00:00','mm/dd/yyyy hh24:mi:ss'),to_date('12/31/2099 00:00:00','mm/dd/yyyy hh24:mi:ss'),'A','I','STN',null,null,null,null,2278);
commit;

  end if;  
end;
/
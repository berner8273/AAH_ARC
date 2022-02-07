delete from stn.validation_column where validation_id = 87;
delete from stn.validation where validation_id = 87;
insert into stn.validation ( validation_id , validation_cd , code_module_id , validation_typ_id , validation_level_id ) values(  87 ,  'ce-acct_cd' ,12,5,1);
insert into stn.validation_column ( validation_id , dtc_id ) values ( 87,13 );
COMMIT;
@@../aahCustom/aahStandardisation/src/main/db/packages/stn/pk_cev.bdy
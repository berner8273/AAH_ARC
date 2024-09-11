--select * from fdr.fr_book_lookup where bol_lookup_key = '0'


begin


delete from fdr.fr_book_lookup where bol_bo_book_id = '0';

delete from fdr.fr_book where bo_book_id = '0';

insert into fdr.fr_book(
bo_book_id,
bo_bs_book_status_id,
bo_ipe_internal_entity_id,
bo_book_clicode,
bo_book_name,
bo_banking_or_trading,
bo_ledger_book_code,
bo_active,
bo_book_usage,
bo_input_by,
bo_associated_funding,
bo_auth_by,
bo_client_text1,
bo_auth_status,
bo_client_text2,
bo_input_time,
bo_client_text3,
bo_valid_from,
bo_client_text4,
bo_valid_to,
bo_client_text5,
bo_delete_time,
bo_sub_account_code,
bo_ias_ind,
bo_client_text6,
bo_client_text7,
bo_client_text8,
bo_client_text9,
bo_client_text10,
bo_pl_ledger_entity_code,
bo_interfaceadj_active,
bo_manadj_active,
bo_associated_fails_book,
bo_fails_funding,
bo_fx_risk_flag,
bo_central_flag
)
select 
0,
bo_bs_book_status_id,
bo_ipe_internal_entity_id,
0, 
bo_book_name,
bo_banking_or_trading,
bo_ledger_book_code,
bo_active,
bo_book_usage,
bo_input_by,
bo_associated_funding,
bo_auth_by,
bo_client_text1,
bo_auth_status,
bo_client_text2,
bo_input_time,
bo_client_text3,
bo_valid_from,
bo_client_text4,
bo_valid_to,
bo_client_text5,
bo_delete_time,
bo_sub_account_code,
bo_ias_ind,
bo_client_text6,
bo_client_text7,
bo_client_text8,
bo_client_text9,
bo_client_text10,
bo_pl_ledger_entity_code,
bo_interfaceadj_active,
bo_manadj_active,
bo_associated_fails_book,
bo_fails_funding,
bo_fx_risk_flag,
bo_central_flag
from fdr.fr_book
where bo_book_id = '4011';
-----------------------------------------------------------------

--32847C3
delete from  fdr.fr_instr_insure_extend where iie_cover_signing_party = '32847C3';
 
insert into fdr.fr_instr_insure_extend i
    (iie_instrument_id,
    iie_movement_type,
    iie_cost_centre,
    iie_co_insured_country_id,
    iie_co_debtor_country_id,
    iie_tax_code1,
    iie_tax_code2,
    iie_tax_code3,
    iie_pbu_party1,
    iie_pbu_party2,
    iie_pbu_party3,
    iie_premium,
    iie_jurisdiction,
    iie_sign_date,
    iie_indemnity,
    iie_benefit_limit,
    iie_cover_note_create_date,
    iie_cover_note_description,
    iie_cover_start_date,
    iie_cover_end_date,
    iie_cover_signature_date,
    iie_cover_signing_party,
    iie_cover_signed)
select 
    '_'||iie_cover_signing_party,
    iie_movement_type,
    iie_cost_centre,
    iie_co_insured_country_id,
    iie_co_debtor_country_id,
    iie_tax_code1,
    iie_tax_code2,
    iie_tax_code3,
    iie_pbu_party1,
    iie_pbu_party2,
    iie_pbu_party3,
    iie_premium,
    iie_jurisdiction,
    iie_sign_date,
    iie_indemnity,
    iie_benefit_limit,
    iie_cover_note_create_date,
    iie_cover_note_description,
    iie_cover_start_date,
    iie_cover_end_date,
    iie_cover_signature_date,
    '32847C3', --iie_cover_signing_party,
    iie_cover_signed
from fdr.fr_instr_insure_extend i
where i.iie_cover_signing_party =  '32847-C3' and i.iie_instrument_id = (select max (p.iie_instrument_id) from fdr.fr_instr_insure_extend p where i.iie_cover_signing_party = p.iie_cover_signing_party);

-----------------------------------------------

--32847C5
delete from  fdr.fr_instr_insure_extend where iie_cover_signing_party = '32847C5';

insert into fdr.fr_instr_insure_extend i
    (iie_instrument_id,
    iie_movement_type,
    iie_cost_centre,
    iie_co_insured_country_id,
    iie_co_debtor_country_id,
    iie_tax_code1,
    iie_tax_code2,
    iie_tax_code3,
    iie_pbu_party1,
    iie_pbu_party2,
    iie_pbu_party3,
    iie_premium,
    iie_jurisdiction,
    iie_sign_date,
    iie_indemnity,
    iie_benefit_limit,
    iie_cover_note_create_date,
    iie_cover_note_description,
    iie_cover_start_date,
    iie_cover_end_date,
    iie_cover_signature_date,
    iie_cover_signing_party,
    iie_cover_signed)
select 
    '_'||iie_cover_signing_party,
    iie_movement_type,
    iie_cost_centre,
    iie_co_insured_country_id,
    iie_co_debtor_country_id,
    iie_tax_code1,
    iie_tax_code2,
    iie_tax_code3,
    iie_pbu_party1,
    iie_pbu_party2,
    iie_pbu_party3,
    iie_premium,
    iie_jurisdiction,
    iie_sign_date,
    iie_indemnity,
    iie_benefit_limit,
    iie_cover_note_create_date,
    iie_cover_note_description,
    iie_cover_start_date,
    iie_cover_end_date,
    iie_cover_signature_date,
    '32847C5', --iie_cover_signing_party,
    iie_cover_signed
from fdr.fr_instr_insure_extend i
where i.iie_cover_signing_party =  '32847-C5' and i.iie_instrument_id = (select max (p.iie_instrument_id) from fdr.fr_instr_insure_extend p where i.iie_cover_signing_party = p.iie_cover_signing_party);
--------------------------------------------------------

--32847C2

delete from  fdr.fr_instr_insure_extend where iie_cover_signing_party = '32847C2';

insert into fdr.fr_instr_insure_extend i
    (iie_instrument_id,
    iie_movement_type,
    iie_cost_centre,
    iie_co_insured_country_id,
    iie_co_debtor_country_id,
    iie_tax_code1,
    iie_tax_code2,
    iie_tax_code3,
    iie_pbu_party1,
    iie_pbu_party2,
    iie_pbu_party3,
    iie_premium,
    iie_jurisdiction,
    iie_sign_date,
    iie_indemnity,
    iie_benefit_limit,
    iie_cover_note_create_date,
    iie_cover_note_description,
    iie_cover_start_date,
    iie_cover_end_date,
    iie_cover_signature_date,
    iie_cover_signing_party,
    iie_cover_signed)
select 
    '_'||iie_cover_signing_party,
    iie_movement_type,
    iie_cost_centre,
    iie_co_insured_country_id,
    iie_co_debtor_country_id,
    iie_tax_code1,
    iie_tax_code2,
    iie_tax_code3,
    iie_pbu_party1,
    iie_pbu_party2,
    iie_pbu_party3,
    iie_premium,
    iie_jurisdiction,
    iie_sign_date,
    iie_indemnity,
    iie_benefit_limit,
    iie_cover_note_create_date,
    iie_cover_note_description,
    iie_cover_start_date,
    iie_cover_end_date,
    iie_cover_signature_date,
    '32847C2', --iie_cover_signing_party,
    iie_cover_signed
from fdr.fr_instr_insure_extend i
where i.iie_cover_signing_party =  '32847-C2' and i.iie_instrument_id = (select max (p.iie_instrument_id) from fdr.fr_instr_insure_extend p where i.iie_cover_signing_party = p.iie_cover_signing_party);


--------------------------

--32847c4
delete from  fdr.fr_instr_insure_extend where iie_cover_signing_party = '32847C4';

insert into fdr.fr_instr_insure_extend i
    (iie_instrument_id,
    iie_movement_type,
    iie_cost_centre,
    iie_co_insured_country_id,
    iie_co_debtor_country_id,
    iie_tax_code1,
    iie_tax_code2,
    iie_tax_code3,
    iie_pbu_party1,
    iie_pbu_party2,
    iie_pbu_party3,
    iie_premium,
    iie_jurisdiction,
    iie_sign_date,
    iie_indemnity,
    iie_benefit_limit,
    iie_cover_note_create_date,
    iie_cover_note_description,
    iie_cover_start_date,
    iie_cover_end_date,
    iie_cover_signature_date,
    iie_cover_signing_party,
    iie_cover_signed)
select 
    '_'||iie_cover_signing_party,
    iie_movement_type,
    iie_cost_centre,
    iie_co_insured_country_id,
    iie_co_debtor_country_id,
    iie_tax_code1,
    iie_tax_code2,
    iie_tax_code3,
    iie_pbu_party1,
    iie_pbu_party2,
    iie_pbu_party3,
    iie_premium,
    iie_jurisdiction,
    iie_sign_date,
    iie_indemnity,
    iie_benefit_limit,
    iie_cover_note_create_date,
    iie_cover_note_description,
    iie_cover_start_date,
    iie_cover_end_date,
    iie_cover_signature_date,
    '32847C4', --iie_cover_signing_party,
    iie_cover_signed
from fdr.fr_instr_insure_extend i
where i.iie_cover_signing_party =  '32847-C4' and i.iie_instrument_id = (select max (p.iie_instrument_id) from fdr.fr_instr_insure_extend p where i.iie_cover_signing_party = p.iie_cover_signing_party);

---------------------------------

--32847C6
delete from  fdr.fr_instr_insure_extend where iie_cover_signing_party = '32847C6';

insert into fdr.fr_instr_insure_extend i
    (iie_instrument_id,
    iie_movement_type,
    iie_cost_centre,
    iie_co_insured_country_id,
    iie_co_debtor_country_id,
    iie_tax_code1,
    iie_tax_code2,
    iie_tax_code3,
    iie_pbu_party1,
    iie_pbu_party2,
    iie_pbu_party3,
    iie_premium,
    iie_jurisdiction,
    iie_sign_date,
    iie_indemnity,
    iie_benefit_limit,
    iie_cover_note_create_date,
    iie_cover_note_description,
    iie_cover_start_date,
    iie_cover_end_date,
    iie_cover_signature_date,
    iie_cover_signing_party,
    iie_cover_signed)
select 
    '_'||iie_cover_signing_party,
    iie_movement_type,
    iie_cost_centre,
    iie_co_insured_country_id,
    iie_co_debtor_country_id,
    iie_tax_code1,
    iie_tax_code2,
    iie_tax_code3,
    iie_pbu_party1,
    iie_pbu_party2,
    iie_pbu_party3,
    iie_premium,
    iie_jurisdiction,
    iie_sign_date,
    iie_indemnity,
    iie_benefit_limit,
    iie_cover_note_create_date,
    iie_cover_note_description,
    iie_cover_start_date,
    iie_cover_end_date,
    iie_cover_signature_date,
    '32847C6', --iie_cover_signing_party,
    iie_cover_signed
from fdr.fr_instr_insure_extend i
where i.iie_cover_signing_party =  '32847-C6' and i.iie_instrument_id = (select max (p.iie_instrument_id) from fdr.fr_instr_insure_extend p where i.iie_cover_signing_party = p.iie_cover_signing_party);


-----------------------

--33584A1

delete from  fdr.fr_instr_insure_extend where iie_cover_signing_party = '33584A1';

insert into fdr.fr_instr_insure_extend i
    (iie_instrument_id,
    iie_movement_type,
    iie_cost_centre,
    iie_co_insured_country_id,
    iie_co_debtor_country_id,
    iie_tax_code1,
    iie_tax_code2,
    iie_tax_code3,
    iie_pbu_party1,
    iie_pbu_party2,
    iie_pbu_party3,
    iie_premium,
    iie_jurisdiction,
    iie_sign_date,
    iie_indemnity,
    iie_benefit_limit,
    iie_cover_note_create_date,
    iie_cover_note_description,
    iie_cover_start_date,
    iie_cover_end_date,
    iie_cover_signature_date,
    iie_cover_signing_party,
    iie_cover_signed)
select 
    '_'||iie_cover_signing_party,
    iie_movement_type,
    iie_cost_centre,
    iie_co_insured_country_id,
    iie_co_debtor_country_id,
    iie_tax_code1,
    iie_tax_code2,
    iie_tax_code3,
    iie_pbu_party1,
    iie_pbu_party2,
    iie_pbu_party3,
    iie_premium,
    iie_jurisdiction,
    iie_sign_date,
    iie_indemnity,
    iie_benefit_limit,
    iie_cover_note_create_date,
    iie_cover_note_description,
    iie_cover_start_date,
    iie_cover_end_date,
    iie_cover_signature_date,
    '33584A1', --iie_cover_signing_party,
    iie_cover_signed
from fdr.fr_instr_insure_extend i
where i.iie_cover_signing_party =  '33584-A1' and i.iie_instrument_id = (select max (p.iie_instrument_id) from fdr.fr_instr_insure_extend p where i.iie_cover_signing_party = p.iie_cover_signing_party);

-----------------------------------------------

--32847C1

delete from  fdr.fr_instr_insure_extend where iie_cover_signing_party = '32847C1';

insert into fdr.fr_instr_insure_extend i
    (iie_instrument_id,
    iie_movement_type,
    iie_cost_centre,
    iie_co_insured_country_id,
    iie_co_debtor_country_id,
    iie_tax_code1,
    iie_tax_code2,
    iie_tax_code3,
    iie_pbu_party1,
    iie_pbu_party2,
    iie_pbu_party3,
    iie_premium,
    iie_jurisdiction,
    iie_sign_date,
    iie_indemnity,
    iie_benefit_limit,
    iie_cover_note_create_date,
    iie_cover_note_description,
    iie_cover_start_date,
    iie_cover_end_date,
    iie_cover_signature_date,
    iie_cover_signing_party,
    iie_cover_signed)
select 
    '_'||iie_cover_signing_party,
    iie_movement_type,
    iie_cost_centre,
    iie_co_insured_country_id,
    iie_co_debtor_country_id,
    iie_tax_code1,
    iie_tax_code2,
    iie_tax_code3,
    iie_pbu_party1,
    iie_pbu_party2,
    iie_pbu_party3,
    iie_premium,
    iie_jurisdiction,
    iie_sign_date,
    iie_indemnity,
    iie_benefit_limit,
    iie_cover_note_create_date,
    iie_cover_note_description,
    iie_cover_start_date,
    iie_cover_end_date,
    iie_cover_signature_date,
    '32847C1', --iie_cover_signing_party,
    iie_cover_signed
from fdr.fr_instr_insure_extend i
where i.iie_cover_signing_party =  '32847-C1' and i.iie_instrument_id = (select max (p.iie_instrument_id) from fdr.fr_instr_insure_extend p where i.iie_cover_signing_party = p.iie_cover_signing_party);

---------------------------------------------------

--32012A1

delete from  fdr.fr_instr_insure_extend where iie_cover_signing_party = '32012A1';

insert into fdr.fr_instr_insure_extend i
    (iie_instrument_id,
    iie_movement_type,
    iie_cost_centre,
    iie_co_insured_country_id,
    iie_co_debtor_country_id,
    iie_tax_code1,
    iie_tax_code2,
    iie_tax_code3,
    iie_pbu_party1,
    iie_pbu_party2,
    iie_pbu_party3,
    iie_premium,
    iie_jurisdiction,
    iie_sign_date,
    iie_indemnity,
    iie_benefit_limit,
    iie_cover_note_create_date,
    iie_cover_note_description,
    iie_cover_start_date,
    iie_cover_end_date,
    iie_cover_signature_date,
    iie_cover_signing_party,
    iie_cover_signed)
select 
    '_'||iie_cover_signing_party,
    iie_movement_type,
    iie_cost_centre,
    iie_co_insured_country_id,
    iie_co_debtor_country_id,
    iie_tax_code1,
    iie_tax_code2,
    iie_tax_code3,
    iie_pbu_party1,
    iie_pbu_party2,
    iie_pbu_party3,
    iie_premium,
    iie_jurisdiction,
    iie_sign_date,
    iie_indemnity,
    iie_benefit_limit,
    iie_cover_note_create_date,
    iie_cover_note_description,
    iie_cover_start_date,
    iie_cover_end_date,
    iie_cover_signature_date,
    '32012A1', --iie_cover_signing_party,
    iie_cover_signed
from fdr.fr_instr_insure_extend i
where i.iie_cover_signing_party =  '32012-A1' and i.iie_instrument_id = (select max (p.iie_instrument_id) from fdr.fr_instr_insure_extend p where i.iie_cover_signing_party = p.iie_cover_signing_party);

-------------------------

--32012D1
delete from  fdr.fr_instr_insure_extend where iie_cover_signing_party = '32012D1';

insert into fdr.fr_instr_insure_extend i
    (iie_instrument_id,
    iie_movement_type,
    iie_cost_centre,
    iie_co_insured_country_id,
    iie_co_debtor_country_id,
    iie_tax_code1,
    iie_tax_code2,
    iie_tax_code3,
    iie_pbu_party1,
    iie_pbu_party2,
    iie_pbu_party3,
    iie_premium,
    iie_jurisdiction,
    iie_sign_date,
    iie_indemnity,
    iie_benefit_limit,
    iie_cover_note_create_date,
    iie_cover_note_description,
    iie_cover_start_date,
    iie_cover_end_date,
    iie_cover_signature_date,
    iie_cover_signing_party,
    iie_cover_signed)
select 
    '_'||iie_cover_signing_party,
    iie_movement_type,
    iie_cost_centre,
    iie_co_insured_country_id,
    iie_co_debtor_country_id,
    iie_tax_code1,
    iie_tax_code2,
    iie_tax_code3,
    iie_pbu_party1,
    iie_pbu_party2,
    iie_pbu_party3,
    iie_premium,
    iie_jurisdiction,
    iie_sign_date,
    iie_indemnity,
    iie_benefit_limit,
    iie_cover_note_create_date,
    iie_cover_note_description,
    iie_cover_start_date,
    iie_cover_end_date,
    iie_cover_signature_date,
    '32012D1', --iie_cover_signing_party,
    iie_cover_signed
from fdr.fr_instr_insure_extend i
where i.iie_cover_signing_party =  '32012-D1' and i.iie_instrument_id = (select max (p.iie_instrument_id) from fdr.fr_instr_insure_extend p where i.iie_cover_signing_party = p.iie_cover_signing_party);

-------------------

--32012E1

delete from  fdr.fr_instr_insure_extend where iie_cover_signing_party = '32012E1';

insert into fdr.fr_instr_insure_extend i
    (iie_instrument_id,
    iie_movement_type,
    iie_cost_centre,
    iie_co_insured_country_id,
    iie_co_debtor_country_id,
    iie_tax_code1,
    iie_tax_code2,
    iie_tax_code3,
    iie_pbu_party1,
    iie_pbu_party2,
    iie_pbu_party3,
    iie_premium,
    iie_jurisdiction,
    iie_sign_date,
    iie_indemnity,
    iie_benefit_limit,
    iie_cover_note_create_date,
    iie_cover_note_description,
    iie_cover_start_date,
    iie_cover_end_date,
    iie_cover_signature_date,
    iie_cover_signing_party,
    iie_cover_signed)
select 
    '_'||iie_cover_signing_party,
    iie_movement_type,
    iie_cost_centre,
    iie_co_insured_country_id,
    iie_co_debtor_country_id,
    iie_tax_code1,
    iie_tax_code2,
    iie_tax_code3,
    iie_pbu_party1,
    iie_pbu_party2,
    iie_pbu_party3,
    iie_premium,
    iie_jurisdiction,
    iie_sign_date,
    iie_indemnity,
    iie_benefit_limit,
    iie_cover_note_create_date,
    iie_cover_note_description,
    iie_cover_start_date,
    iie_cover_end_date,
    iie_cover_signature_date,
    '32012E1', --iie_cover_signing_party,
    iie_cover_signed
from fdr.fr_instr_insure_extend i
where i.iie_cover_signing_party =  '32012-E1' and i.iie_instrument_id = (select max (p.iie_instrument_id) from fdr.fr_instr_insure_extend p where i.iie_cover_signing_party = p.iie_cover_signing_party);

---------------------------------------------------------

update fdr.fr_general_codes
set gc_active = 'I'
where gc_client_code = '14400330';

commit;
end;


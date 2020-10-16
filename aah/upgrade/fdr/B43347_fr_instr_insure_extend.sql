update fdr.fr_instr_insure_extend
set iie_jurisdiction = 'CONSOL', iie_cover_note_create_date = '01-OCT-16', iie_sign_date  = '31-OCT-16'
WHERE iie_instrument_id IN 
(
    select fiie.iie_instrument_id
    FROM fdr.fr_instr_insure_extend fiie
    JOIN fdr.fr_instrument fi ON fiie.iie_instrument_id = fi.i_instrument_id
    JOIN fdr.fr_trade ft ON ft.t_i_instrument_id = fi.i_instrument_id
    where fiie.iie_cover_signing_party in ('70006', '70006-A', '70023', '70023-A')    
    and ft.t_fdr_ver_no = (select max(ft1.t_fdr_ver_no) from fdr.fr_trade ft1 where ft1.t_source_tran_no = ft.t_source_tran_no)
);
commit;

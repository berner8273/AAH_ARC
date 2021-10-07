delete from FDR.FR_INSTRUMENT where  i_instrument_id in (select t1.t_i_instrument_id from fdr.fr_trade t1 where t1.t_source_tran_no <> 1 and t1.t_fdr_ver_no <> (select max(t2.t_fdr_ver_no) from fdr.fr_trade t2 where t1.t_source_tran_no = t2.t_source_tran_no));
commit;


delete from fdr.fr_instr_insure_extend where iie_instrument_id in (select t1.t_i_instrument_id from fdr.fr_trade t1 where t1.t_source_tran_no <> 1 and t1.t_fdr_ver_no <> (select max(t2.t_fdr_ver_no) from fdr.fr_trade t2 where t1.t_source_tran_no = t2.t_source_tran_no)) ;
commit;

delete from fdr.fr_trade where t_i_instrument_id in (select t1.t_i_instrument_id from fdr.fr_trade t1 where t1.t_source_tran_no <> 1 and t1.t_fdr_ver_no <> (select max(t2.t_fdr_ver_no) from fdr.fr_trade t2 where t1.t_source_tran_no = t2.t_source_tran_no));
commit;

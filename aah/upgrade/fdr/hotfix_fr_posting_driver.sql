update fdr.fr_posting_driver set pd_dr_or_cr = 'CR', pd_negate_flag1 = '-1'
where pd_aet_event_type = 'VIECD_AR' and pd_amount_type = 'POS' and pd_posting_code = 'VIE_DECONSOL_DAC';

update fdr.fr_posting_driver set pd_dr_or_cr = 'DR', pd_negate_flag1 = '1'
where pd_aet_event_type = 'VIECD_AR' and pd_amount_type = 'POS' and pd_posting_code = 'VIECD_AR';

update fdr.fr_posting_driver set pd_dr_or_cr = 'DR', pd_negate_flag1 = '-1'
where pd_aet_event_type = 'VIECD_AR' and pd_amount_type = 'NEG' and pd_posting_code = 'VIE_DECONSOL_DAC';

update fdr.fr_posting_driver set pd_dr_or_cr = 'CR', pd_negate_flag1 = '1'
where pd_aet_event_type = 'VIECD_AR' and pd_amount_type = 'NEG' and pd_posting_code = 'VIECD_AR';

commit;




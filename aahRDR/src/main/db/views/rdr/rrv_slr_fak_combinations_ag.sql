create or replace view rdr.rrv_slr_fak_combinations_ag
as
   select fc_fak_id,
          fc_epg_id,
          fc_entity,
          fc_account,
          fc_ccy,
          fc_segment_1 as ledger_cd,
          fc_segment_2 as basis_cd,
          fc_segment_3 as dept_cd,
          fc_segment_4 as affiliate_le_id,
          fc_segment_5 as chartfield_1,
          fc_segment_6 as execution_typ,
          fc_segment_7 as business_typ,
          fc_segment_8 as policy_id
     from slr.slr_fak_combinations
;

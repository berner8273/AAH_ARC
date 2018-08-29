create global temporary table slr.slr_eba_bop_amounts_tmp
(
  edb_fak_id                 number(12)         not null,
  edb_eba_id                 number(12)         not null,
  edb_balance_date           date               not null,
  edb_balance_type           number(3)          not null,
  edb_tran_bop_mtd_balance   number(33,3),
  edb_tran_bop_qtd_balance   number(33,3),
  edb_tran_bop_ytd_balance   number(33,3),
  edb_base_bop_mtd_balance   number(33,3),
  edb_base_bop_qtd_balance   number(33,3),
  edb_base_bop_ytd_balance   number(33,3),
  edb_local_bop_mtd_balance  number(33,3),
  edb_local_bop_qtd_balance  number(33,3),
  edb_local_bop_ytd_balance  number(33,3),
  edb_period_month           number(2)          not null,
  edb_period_qtr             number(1)          not null,
  edb_period_year            number(4)          not null,
  edb_period_ltd             number(2)          not null,
  edb_amended_on             date               not null
)
on commit preserve rows;

create index idx_eba_bop_amounts_tmp_01 on slr.slr_eba_bop_amounts_tmp (edb_fak_id, edb_eba_id, edb_balance_date);
 
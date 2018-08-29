create global temporary table slr.slr_fak_bop_amounts_tmp
(
  fdb_fak_id                 number(12)         not null,
  fdb_balance_date           date               not null,
  fdb_balance_type           number(3)          not null,
  fdb_tran_bop_mtd_balance   number(33,3),
  fdb_tran_bop_qtd_balance   number(33,3),
  fdb_tran_bop_ytd_balance   number(33,3),
  fdb_base_bop_mtd_balance   number(33,3),
  fdb_base_bop_qtd_balance   number(33,3),
  fdb_base_bop_ytd_balance   number(33,3),
  fdb_local_bop_mtd_balance  number(33,3),
  fdb_local_bop_qtd_balance  number(33,3),
  fdb_local_bop_ytd_balance  number(33,3),
  fdb_period_month           number(2)          not null,
  fdb_period_qtr             number(1)          not null,
  fdb_period_year            number(4)          not null,
  fdb_period_ltd             number(2)          not null,
  fdb_amended_on             date               not null
)
on commit preserve rows;

create index idx_fak_bop_amounts_tmp_01 on slr.slr_fak_bop_amounts_tmp (fdb_fak_id, fdb_balance_date);

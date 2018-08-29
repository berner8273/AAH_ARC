create global temporary table slr.slr_fak_bop_amounts_tmp3
(
  fdb_fak_id                number(12)          not null,
  fdb_balance_date          date                not null,
  fdb_balance_type          number(3)           not null,
  fdb_tran_daily_movement   number(33,3),
  fdb_tran_mtd_balance      number(33,3),
  fdb_tran_ytd_balance      number(33,3),
  fdb_tran_ltd_balance      number(33,3),
  fdb_base_daily_movement   number(33,3),
  fdb_base_mtd_balance      number(33,3),
  fdb_base_ytd_balance      number(33,3),
  fdb_base_ltd_balance      number(33,3),
  fdb_local_daily_movement  number(33,3),
  fdb_local_mtd_balance     number(33,3),
  fdb_local_ytd_balance     number(33,3),
  fdb_local_ltd_balance     number(33,3),
  fdb_period_month          number(2)           not null,
  fdb_period_qtr            number(1)           not null,
  fdb_period_year           number(4)           not null,
  fdb_period_ltd            number(2)           not null,
  fdb_process_id            number(30)          not null,
  fdb_amended_on            date                not null,
  fdb_entity                varchar2(20 byte)   not null,
  fdb_epg_id                varchar2(18 byte)   not null,
  fdb_id                    varchar2(100 byte)  not null,
  year_mth                  varchar2(6 byte),
  year_qtr                  varchar2(5 byte),
  year                      varchar2(4 byte),
  last_in_yr                varchar2(2 byte)
)
on commit preserve rows; 

create index idx_fak_bop_amounts_tmp3_01 on slr.slr_fak_bop_amounts_tmp3 (fdb_fak_id, fdb_balance_date, fdb_id, last_in_yr);
create index idx_fak_bop_amounts_tmp3_02 on slr.slr_fak_bop_amounts_tmp3 (fdb_id, fdb_period_month, fdb_period_qtr, fdb_period_year, fdb_period_ltd);


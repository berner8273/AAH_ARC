create global temporary table slr.slr_eba_bop_amounts_tmp3
(
  edb_fak_id                number(12)          not null,
  edb_eba_id                number(12)          not null,
  edb_balance_date          date                not null,
  edb_balance_type          number(3)           not null,
  edb_tran_daily_movement   number(33,3),
  edb_tran_mtd_balance      number(33,3),
  edb_tran_ytd_balance      number(33,3),
  edb_tran_ltd_balance      number(33,3),
  edb_base_daily_movement   number(33,3),
  edb_base_mtd_balance      number(33,3),
  edb_base_ytd_balance      number(33,3),
  edb_base_ltd_balance      number(33,3),
  edb_local_daily_movement  number(33,3),
  edb_local_mtd_balance     number(33,3),
  edb_local_ytd_balance     number(33,3),
  edb_local_ltd_balance     number(33,3),
  edb_period_month          number(2)           not null,
  edb_period_qtr            number(1)           not null,
  edb_period_year           number(4)           not null,
  edb_period_ltd            number(2)           not null,
  edb_process_id            number(30)          not null,
  edb_amended_on            date                not null,
  edb_entity                varchar2(20 byte)   not null,
  edb_epg_id                varchar2(18 byte)   not null,
  edb_id                    varchar2(100 byte)  not null,
  year_mth                  varchar2(6 byte),
  year_qtr                  varchar2(5 byte),
  year                      varchar2(4 byte),
  last_in_yr                varchar2(2 byte)
)
on commit preserve rows;


create index idx_eba_bop_amounts_tmp3_01 on slr.slr_eba_bop_amounts_tmp3 (edb_fak_id, edb_eba_id, edb_balance_date, edb_id, last_in_yr);

create index idx_eba_bop_amounts_tmp3_02 on slr.slr_eba_bop_amounts_tmp3 (edb_id, edb_period_month, edb_period_qtr, edb_period_year, edb_period_ltd);

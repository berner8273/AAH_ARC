create global temporary table slr.slr_fak_bop_amounts_tmp2
(
  fdb_fak_id        number(12)                  not null,
  fdb_balance_date  date                        not null,
  fdb_balance_type  number(2)                   not null,
  fdb_entity        varchar2(20 byte)           not null,
  fdb_epg_id        varchar2(18 byte)           not null,
  fdb_id            varchar2(100 byte)          not null
)
on commit preserve rows;
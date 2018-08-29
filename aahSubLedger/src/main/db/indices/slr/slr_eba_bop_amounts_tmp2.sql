create global temporary table slr.slr_eba_bop_amounts_tmp2
(
  edb_fak_id        number(12)                  not null,
  edb_eba_id        number(12)                  not null,
  edb_balance_date  date                        not null,
  edb_balance_type  number(2)                   not null,
  edb_entity        varchar2(20 byte)           not null,
  edb_epg_id        varchar2(18 byte)           not null,
  edb_id            varchar2(100 byte)          not null
)
on commit preserve rows;

create index idx_eba_bop_amounts_tmp2_01 on slr.slr_eba_bop_amounts_tmp2 (edb_fak_id, edb_eba_id, edb_balance_date);

create role aah_glint;
grant create session                                     to aah_glint;
grant select , update on rdr.rr_glint_journal_line       to aah_glint;
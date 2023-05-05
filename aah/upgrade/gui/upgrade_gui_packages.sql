@@../aahCustom/aahSubLedger/src/main/db/packages/gui/pgui_manual_journal.hdr
@@../aahCustom/aahSubLedger/src/main/db/packages/gui/pgui_manual_journal.bdy

grant select on gui.temp_gui_jrnl_lines_unposted to rdr;
grant insert on gui.temp_gui_jrnl_lines_unposted to rdr;
grant update on gui.temp_gui_jrnl_lines_unposted to rdr;
grant select on gui.gui_jrnl_headers_unposted to rdr;
grant select on gui.gui_jrnl_line_errors to rdr;
grant select on gui.gui_jrnl_headers_unposted to slr;
grant insert on gui.gui_jrnl_headers_unposted to slr;
grant update on gui.gui_jrnl_headers_unposted to slr;
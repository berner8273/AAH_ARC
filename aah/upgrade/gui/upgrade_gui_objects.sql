@@../aahCustom/aahSubLedger/src/main/db/packages/gui/PGUI_MANUAL_JOURNAL.hdr;
@@../aahCustom/aahSubLedger/src/main/db/packages/gui/PGUI_MANUAL_JOURNAL.bdy;


grant select on gui.temp_gui_jrnl_lines_unposted to rdr;
grant insert on gui.temp_gui_jrnl_lines_unposted to rdr;
grant update on gui.temp_gui_jrnl_lines_unposted to rdr;
grant select on gui.gui_jrnl_headers_unposted to rdr;
grant select on gui.gui_jrnl_line_errors to rdr;
grant select on gui.gui_jrnl_headers_unposted to slr;
grant insert on gui.gui_jrnl_headers_unposted to slr;
grant update on gui.gui_jrnl_headers_unposted to slr;
grant select on gui.gui_jrnl_line_errors to rdr with grant option;
grant select on gui.gui_jrnl_lines_unposted to rdr with grant option;
grant select on gui.gui_jrnl_headers_unposted to rdr with grant option;
grant select on gui.gui_jrnl_headers_unposted  to rdr with grant option;

update gui.t_ui_jrnl_line_meta
set column_nullable = 'Y'
where column_name in ('SEGMENT_3','SEGMENT_5');

update gui.t_ui_jrnl_line_meta
set column_nullable = 'Y'
where lower(column_screen_label) = 'spare';

commit;

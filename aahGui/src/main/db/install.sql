-- -----------------------------------------------------------------------------------------
-- filename: install.sql
-- author  : andrew hall
-- purpose : Script to install the objects which are involved in standardisation.
--         :
-- -----------------------------------------------------------------------------------------

whenever sqlerror exit failure

set serveroutput on
set define ~

define tns_alias    = @oracleTnsAlias@

define gui_user     = @guiUsername@
define gui_password = @guiPassword@
define gui_logon    = ~gui_user/~gui_password@~tns_alias

conn ~gui_logon

@@data/gui/t_ui_jrnl_line_meta.sql
@@data/gui/t_ui_roles.sql
@@data/gui/t_ui_role_tasks.sql
@@data/gui/ui_gen_lookup_type_properties.sql
@@data/gui/ui_component.sql
@@data/gui/ui_screen.sql
@@data/gui/ui_section.sql
@@data/gui/ui_field.sql
@@data/gui/ui_input_field_value.sql
@@data/gui/ui_general_lookup.sql
exit
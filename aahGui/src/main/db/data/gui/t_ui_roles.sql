delete from gui.t_ui_roles where role_id not in ( 'role.administrator' , 'role.all.journal.types' , 'role.all.accounts' );

insert into gui.t_ui_roles ( role_id , role_description ) values ( 'role.subledger.configurator'  , 'Subledger Configurator' );
insert into gui.t_ui_roles ( role_id , role_description ) values ( 'role.subledger.administrator' , 'Subledger Administrator' );
insert into gui.t_ui_roles ( role_id , role_description ) values ( 'role.reference.data.user'     , 'Reference Data User' );
insert into gui.t_ui_roles ( role_id , role_description ) values ( 'role.reference.data.approver' , 'Reference Data Approver' );
insert into gui.t_ui_roles ( role_id , role_description ) values ( 'role.subledger.user'          , 'Subledger Accounting User' );
insert into gui.t_ui_roles ( role_id , role_description ) values ( 'role.subledger.manager'       , 'Subledger Accounting Manager' );
insert into gui.t_ui_roles ( role_id , role_description ) values ( 'role.subledger.viewer'        , 'Subledger Accounting Viewer' );
commit;
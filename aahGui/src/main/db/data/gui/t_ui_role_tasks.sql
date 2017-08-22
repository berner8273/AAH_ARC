delete from gui.t_ui_role_tasks where role_id not in ( 'role.administrator' , 'role.all.journal.types' , 'role.all.accounts' );

insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.administrator' , 'task.static.data.licensed.modules.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.administrator' , 'task.usermgt.users.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.administrator' , 'task.usermgt.users.change.password' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.administrator' , 'task.usermgt.users.departments.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.administrator' , 'task.usermgt.users.entities.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.administrator' , 'task.usermgt.users.roles.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.administrator' , 'task.usermgt.users.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.administrator' , 'task.usermgt.users.user.password' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.administrator' , 'task.usermgt.users.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.administrator' , 'task.static.data.ticket.audit.detail.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.administrator' , 'task.static.data.ticket.audit.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.books.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.books.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.calendar.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.calendar.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.fxrates.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.fxrates.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.general.code.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.general.code.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.general.lookups.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.general.lookups.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.gl.account.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.gl.account.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.hierarchies.create' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.hierarchies.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.hierarchytypes.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.hierarchytypes.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.instruments.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.instruments.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.internal.proc.entities.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.internal.proc.entities.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.usermgt.users.change.password' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.party.business.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.party.business.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.party.legal.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.party.legal.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.subledgerperiods.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.user' , 'task.static.data.subledgerperiods.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.approver' , 'task.static.data.authorise.updates' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.reference.data.approver' , 'task.static.data.auths.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.user' , 'task.adjustment.batches.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.user' , 'task.adjustment.batches.execute' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.user' , 'task.adjustment.batches.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.user' , 'task.adjustment.batches.validate' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.user' , 'task.adjustment.groups.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.user' , 'task.adjustment.groups.reset' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.user' , 'task.adjustment.groups.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.user' , 'task.adjustment.pick.lists.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.user' , 'task.adjustment.pick.lists.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.user' , 'task.adjustment.types.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.user' , 'task.adjustment.types.generate.template' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.user' , 'task.adjustment.types.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.user' , 'task.madj.journal.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.user' , 'task.madj.journal.csv.file.upload' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.user' , 'task.madj.journal.line.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.user' , 'task.madj.journal.line.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.user' , 'task.madj.journal.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.user' , 'task.usermgt.users.change.password' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.manager' , 'task.adjustment.batches.authorise' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.manager' , 'task.adjustment.batches.reject' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.manager' , 'task.madj.journal.authorise' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.manager' , 'task.madj.journal.reject' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.adjustment.adjustments.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.adjustment.batches.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.adjustment.browser.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.adjustment.groups.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.adjustment.pick.lists.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.adjustment.summary.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.adjustment.types.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.error.details.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.error.text.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.error.value.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.errors.common.cause.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.errors.transactions.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.errors.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.madj.authorisation.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.madj.journal.line.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.madj.journal.search' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.madj.journal.search.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.madj.journal.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.acc.explorer.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.account.details.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.auths.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.books.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.calendar.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.det.balaces.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.drivers.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.entities.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.fxrates.details.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.fxrates.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.general.code.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.general.lookups.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.journal.line.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.journal.search' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.journal.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.gl.account.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.hierarchies.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.hierarchytypes.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.instruments.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.sum.balaces.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.internal.proc.entities.details.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.internal.proc.entities.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.usermgt.users.change.password' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.lookups.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.parameters.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.party.business.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.party.legal.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.subledgerperiods.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.ticket.audit.detail.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.viewer' , 'task.static.data.ticket.audit.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.accessgroups.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.accessgroups.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.accessgroups.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.adjustments.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.batches.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.batches.authorise' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.batches.execute' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.batches.reject' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.batches.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.batches.validate' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.batches.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.browser.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.groups.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.groups.reset' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.groups.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.groups.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.pick.lists.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.pick.lists.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.pick.lists.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.summary.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.types.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.types.generate.template' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.types.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.adjustment.types.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.error.details.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.error.text.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.error.value.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.errors.common.cause.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.errors.transactions.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.errors.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.madj.authorisation.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.madj.journal.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.madj.journal.authorise' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.madj.journal.csv.file.upload' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.madj.journal.line.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.madj.journal.line.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.madj.journal.line.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.madj.journal.reject' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.madj.journal.search' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.madj.journal.search.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.madj.journal.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.madj.journal.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.acc.explorer.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.account.details.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.authorise.updates' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.auths.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.auths.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.books.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.books.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.books.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.calendar.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.calendar.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.calendar.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.det.balaces.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.drivers.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.drivers.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.drivers.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.entities.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.entities.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.entities.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.fxrates.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.fxrates.details.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.fxrates.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.fxrates.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.general.code.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.general.code.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.general.code.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.general.lookups.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.general.lookups.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.general.lookups.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.journal.line.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.journal.search' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.journal.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.licensed.modules.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.gl.account.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.gl.account.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.gl.account.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.hierarchies.create' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.hierarchies.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.hierarchies.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.hierarchytypes.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.hierarchytypes.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.hierarchytypes.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.instruments.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.instruments.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.instruments.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.internal.proc.entities.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.sum.balaces.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.internal.proc.entities.details.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.internal.proc.entities.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.internal.proc.entities.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.lookups.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.usermgt.users.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.usermgt.users.change.password' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.usermgt.users.departments.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.usermgt.users.entities.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.usermgt.users.roles.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.usermgt.users.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.usermgt.users.user.password' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.usermgt.users.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.lookups.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.lookups.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.parameters.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.party.business.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.party.business.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.party.business.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.party.legal.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.party.legal.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.party.legal.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.subledgerperiods.add' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.subledgerperiods.update' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.subledgerperiods.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.ticket.audit.detail.view' );
insert into gui.t_ui_role_tasks ( role_id , task_id ) values ( 'role.subledger.configurator' , 'task.static.data.ticket.audit.view' );
commit;
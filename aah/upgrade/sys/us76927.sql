-- variables are the user name of the target to give the roles to
-- source is the profile to give the target
--  all     all roles
--  tolson. Tim Olson 
-- manager (ex Vessela or Myrene)  
-- other (ex Raj, John Dean)

declare 
sUserTarget varchar(20) := 'aheavey'; 
sUserSource varchar(20) := 'other';

nUserId number;

begin


select user_id into nUserId from security_core.user_detail where lower(user_name) = lower(sUserTarget);
IF nUserId is null THEN
    raise_application_error(-20101,'Invalid target id');
END IF;    


delete from security_core.user_application where user_id = nUserId;
insert into security_core.user_application select nUserid, application_id from security_core.application;
IF sql%rowcount<> 3 THEN
    raise_application_error(-20102,'wrong number of applications');
END IF;    
    
 
delete from security_core.user_role where user_id = nUserId;
 
IF lower(sUserSource) = 'all' THEN 
    insert into security_core.user_role
    select nUserId,role_id from security_core.role;
ELSIF lower(sUserSource) = 'tolson' THEN
    insert into security_core.user_role
    select nUserId, role_id
    from security_core.role r 
    where r.role_name in ( 
        'role.error.updater',
        'role.all.journal.types',
        'role.all.accounts',
        'role.subledger.configurator',
        'role.reference.data.user',
        'role.reference.data.approver',
        'role.subledger.user',
        'role.subledger.manager',
        'role.subledger.viewer');
ELSIF lower(sUserSource) = 'manager' THEN
    insert into security_core.user_role
    select nUserId, role_id
    from security_core.role r 
    where r.role_name in ( 
        'role.all.journal.types',
        'role.all.accounts',
        'role.reference.data.user',
        'role.reference.data.approver',
        'role.subledger.user',
        'role.subledger.manager',
        'role.subledger.viewer');
ELSIF lower(sUserSource) = 'other' THEN
    insert into security_core.user_role
    select nUserId, role_id
    from security_core.role r 
    where r.role_name in ( 
        'role.all.journal.types',
        'role.all.accounts',
        'role.reference.data.user',
        'role.subledger.user',
        'role.subledger.manager',
        'role.subledger.viewer');
ELSE
    raise_application_error(-20102,'logic fell through in IF');
END IF;

commit;
 
end;
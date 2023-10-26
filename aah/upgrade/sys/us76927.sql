
grant select on security_core.application to AAH_READ_ONLY
/
grant select on security_core.user_application to AAH_READ_ONLY
/

grant select on security_core.role_privilege to AAH_READ_ONLY
/
grant select on security_core.privilege to AAH_READ_ONLY
/

grant select on security_core.role_property to AAH_READ_ONLY
/

grant select on security_core.role to AAH_READ_ONLY
/
grant select on security_core.user_role to AAH_READ_ONLY
/

grant select on security_core.property_type to AAH_READ_ONLY
/
grant select on security_core.user_property to AAH_READ_ONLY
/


create or replace force view security_core.vw_ag_user_detail(
    user_id, 
    user_name,
    first_name,
    last_name,
    active
) BEQUEATH DEFINER AS
select 
    user_id,
    user_name, 
    first_name, 
    last_name, 
    active 
from security_core.user_detail
/

grant select on security_core.vw_ag_user_detail to AAH_READ_ONLY
/
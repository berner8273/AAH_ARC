update security_core.application 
set base_url =
    case sys_context('userenv', 'db_name')
        when 'APTDEV' then 'http://aptitudedev.agl.com/aah'
        when 'APTQA'  then 'http://aptitudedqa.agl.com/aah'       
        when 'APTUAT' then 'http://aptitudeduat.agl.com/aah'
        when 'APT'    then 'http://aptitude.agl.com/aah'
        end
where application_name = 'AAH';

update security_core.application 
set base_url =
    case sys_context('userenv', 'db_name')
        when 'APTDEV' then 'http://aptitudedev.agl.com/scheduler-web'
        when 'APTQA'  then 'http://aptitudedqa.agl.com/scheduler-web'       
        when 'APTUAT' then 'http://aptitudeduat.agl.com/scheduler-web'
        when 'APT'    then 'http://aptitude.agl.com/scheduler-web'
        end
where application_name = 'ASCHED';

update security_core.application 
set base_url =
    case sys_context('userenv', 'db_name')
        when 'APTDEV' then 'http://aptitudedev.agl.com/SECURITY'
        when 'APTQA'  then 'http://aptitudedqa.agl.com/SECURITY'       
        when 'APTUAT' then 'http://aptitudeduat.agl.com/SECURITY'
        when 'APT'    then 'http://aptitude.agl.com/SECURITY'
        end
where application_name = 'ASEC';

commit;
update security_core.application 
set base_url =
    case sys_context('userenv', 'db_name')
        when 'APTDEV' then 'https://aptitudedev.agl.com/aah'
        when 'APTQA'  then 'https://aptitudeqa.agl.com/aah'       
        when 'APTUAT' then 'https://aptitudeuat.agl.com/aah'
        when 'APT'    then 'https://aptitude.agl.com/aah'
        end
where application_name = 'AAH';

update security_core.application 
set base_url =
    case sys_context('userenv', 'db_name')
        when 'APTDEV' then 'https://aptitudedev.agl.com/scheduler-web'
        when 'APTQA'  then 'https://aptitudeqa.agl.com/scheduler-web'       
        when 'APTUAT' then 'https://aptitudeuat.agl.com/scheduler-web'
        when 'APT'    then 'https://aptitude.agl.com/scheduler-web'
        end
where application_name = 'ASCHED';

update security_core.application 
set base_url =
    case sys_context('userenv', 'db_name')
        when 'APTDEV' then 'https://aptitudedev.agl.com/SECURITY'
        when 'APTQA'  then 'https://aptitudeqa.agl.com/SECURITY'       
        when 'APTUAT' then 'https://aptitudeuat.agl.com/SECURITY'
        when 'APT'    then 'https://aptitude.agl.com/SECURITY'
        end
where application_name = 'ASEC';

commit;
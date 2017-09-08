@echo off
if (%1)==() goto :usage
if (%2)==() goto :usage
aptcmd.exe -deploy -project_file_path "C:\Users\ahall\AccountingHub\development\AccountingHub\aah\aahCustom\aahStandardisation\src\main\aptitude\StandardiseReferenceData.brd" -config_file_path "C:\Users\ahall\AccountingHub\development\AccountingHub\aah\aahCustom\aahStandardisation\src\main\aptitude\StandardiseReferenceData.brd.config" -folder "custom" -deployment_type "normal" -redeployment_type "full" -leave_configuration "no" -start_after_deployment "yes" -host "aptitudedev" -port "2500" -login %1 -password %2
goto :end
:usage
echo Usage: StandardiseReferenceData_deploy.bat ^<LOGIN^> ^<PASSWORD^>
:end

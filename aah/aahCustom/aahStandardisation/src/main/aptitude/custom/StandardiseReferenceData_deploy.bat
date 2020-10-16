@echo off
if (%1)==() goto :usage
if (%2)==() goto :usage
if (%3)==() goto :usage
aptcmd.exe -deploy -project_file_path "C:\Users\jberner\Source\Repos\AccountingHub\aah\aahCustom\aahStandardisation\src\main\aptitude\custom\StandardiseReferenceData.brd" -config_file_path "C:\Users\jberner\Source\Repos\AccountingHub\aah\aahCustom\aahStandardisation\src\main\aptitude\custom\StandardiseReferenceData.brd.config" -folder %1 -deployment_type "normal" -redeployment_type "full" -leave_configuration "no" -start_after_deployment "no" -host "127.0.0.1" -port "2000" -login %2 -password %3
goto :end
:usage
echo Usage: StandardiseReferenceData_deploy.bat ^<FOLDER^> ^<LOGIN^> ^<PASSWORD^>
:end

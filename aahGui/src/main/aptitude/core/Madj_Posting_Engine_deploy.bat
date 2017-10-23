@echo off
if (%1)==() goto :usage
if (%2)==() goto :usage
if (%3)==() goto :usage
aptcmd.exe -deploy -project_file_path "C:\Users\ahall\AccountingHub\development\AccountingHub\aah\aahCustom\aahGui\src\main\aptitude\core\Madj_Posting_Engine.brd" -config_file_path "C:\Users\ahall\AccountingHub\development\AccountingHub\aah\aahCustom\aahGui\src\main\aptitude\core\Madj_Posting_Engine.brd.config" -folder %1 -deployment_type "normal" -redeployment_type "full" -leave_configuration "no" -start_after_deployment "no" -host "127.0.0.1" -port "2000" -login %2 -password %3
goto :end
:usage
echo Usage: Madj_Posting_Engine_deploy.bat ^<FOLDER^> ^<LOGIN^> ^<PASSWORD^>
:end

whenever sqlerror exit failure

set serveroutput on
set echo on

--Define Connections
	define 1 = 'FDR/bJGeTSP2PbMikw4d@Oraaptci-bubble1:1521:aptci'
	define 2 = 'GUI/KWDfdtQqoa3A2nE5@Oraaptci-bubble1:1521:aptci'
	define 3 = 'RDR/HuJJnYnTr8LRwJqL@Oraaptci-bubble1:1521:aptci'
	define 4 = ''
	define 5 = 'SLR/xJ4V8iyBJ7UuVSx6@Oraaptci-bubble1:1521:aptci'
	define 6 = 'STN/NZ784FBLUJesbJvA@Oraaptci-bubble1:1521:aptci'
	define 7 = 'SYS/ZMaz8DjieATJoxgM@Oraaptci-bubble1:1521:aptci'
	define 8 = ''


--Uninstall Scripts

	--Running the Custom GUI Uninstall script
		@@aahGui/src/main/db/uninstall.sql
		
	--Running the Custom STN Uninstall script
		@@aahStandardisation/src/main/db/uninstall.sql
		
	--Running the Custom Step Trigger Uninstall script
		@@aahStepTrigger/src/main/db/uninstall.sql
		
	--Running the Custom RDR Uninstall script
		@@aahRDR/src/main/db/uninstall.sql
		
	--Running the Custom SubLedger Uninstall script
		@@aahSubLedger/src/main/db/uninstall.sql
		
	--Running the Custom Step Trigger Install script	
		@@aahETL/src/main/db/uninstall.sql
		

exit

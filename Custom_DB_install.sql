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

--Install Scripts

	--Running the Custom Step Trigger Install script
		@@aahStepTrigger/src/main/db/install.sql
		
	--Running the Custom Step Trigger Install script
		--@@aahStandardisation/src/main/db/install.sql
		
	--Running the Custom Step Trigger Install script
		--@@aahGui/src/main/db/install.sql
		
	--Running the Custom Step Trigger Install script
		--@@aahSubLedger/src/main/db/install.sql
		
	--Running the Custom Step Trigger Install script
		--@@aahRDR/src/main/db/install.sql

exit
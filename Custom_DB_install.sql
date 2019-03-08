whenever sqlerror exit failure

set define on
set serveroutput on
set echo on

--Define Individual instance of User's Bubble
    define b_num = &user_bubble_number


--Define all other Connections
	define 1 = 'FDR/bJGeTSP2PbMikw4d@Oraaptci-bubble&b_num:1521:aptci'
	define 2 = 'GUI/KWDfdtQqoa3A2nE5@Oraaptci-bubble&b_num:1521:aptci'
	define 3 = 'RDR/HuJJnYnTr8LRwJqL@Oraaptci-bubble&b_num:1521:aptci'
	define 4 = ''
	define 5 = 'SLR/xJ4V8iyBJ7UuVSx6@Oraaptci-bubble&b_num:1521:aptci'
	define 6 = 'STN/NZ784FBLUJesbJvA@Oraaptci-bubble&b_num:1521:aptci'
	define 7 = 'SYS/ZMaz8DjieATJoxgM@Oraaptci-bubble&b_num:1521:aptci'
	define 8 = ''

--Install Scripts

	--Running the Custom Step Trigger Install script
		@@aahStepTrigger/src/main/db/install.sql
		
	--Running the Custom Step Trigger Install script
		@@aahStandardisation/src/main/db/install.sql
		
	--Running the Custom Step Trigger Install script
		@@aahGui/src/main/db/install.sql
		
	--Running the Custom Step Trigger Install script
		@@aahSubLedger/src/main/db/install.sql
		
	--Running the Custom Step Trigger Install script
		@@aahRDR/src/main/db/install.sql

set define off		

set define on

--Define Individual instance of User's Bubble
    define eb_num = &user_bubble_number
	
--Define ETL Connections
	define 1 = 'SYS/ZMaz8DjieATJoxgM@Oraaptci-bubble&eb_num:1521:aptci'
	define 2 = 'rzj4rUD5XuG3cMNC'
	define 3 = 'aahReadPassword'
	define 4 = 'oAPnsamjBDWvE6de'
	define 5 = 'hCkT85v3mckVbTwT'
	define 6 = 'STN/NZ784FBLUJesbJvA@Oraaptci-bubble&eb_num:1521:aptci'
	define 8 = ''

	--Running the Custom Step Trigger Install script	
		@@aahETL/src/main/db/install.sql	

set define off
exit
whenever sqlerror exit failure

set define on
set serveroutput on
set echo on

--Define Individual instance of User's Bubble
    --define b_num = &user_bubble_number
	
--Define all other Connections
	define 1 = 'FDR/bJGeTSP2PbMikw4d@Oraaptci-bubble3:1521:aptci'
	define 2 = 'GUI/KWDfdtQqoa3A2nE5@Oraaptci-bubble3:1521:aptci'
	define 3 = 'RDR/HuJJnYnTr8LRwJqL@Oraaptci-bubble3:1521:aptci'
	define 4 = ''
	define 5 = 'SLR/xJ4V8iyBJ7UuVSx6@Oraaptci-bubble3:1521:aptci'
	define 6 = 'STN/NZ784FBLUJesbJvA@Oraaptci-bubble3:1521:aptci'
	define 7 = 'aptitude/iK3BQ8QvbuhSvaAU@Oraaptci-bubble3:1521:aptci'
	define 8 = ''


    @@install.sql




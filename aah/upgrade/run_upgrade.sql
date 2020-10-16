whenever sqlerror exit failure

set define on
set serveroutput on
set echo on

--Define Individual instance of User's Bubble
    --define b_num = &user_bubble_number
	
--Define all other Connections
	define 1 = 'FDR/idiRGdUKmYYbq7WS@Oraaptdev:1521:aptdev'
	define 2 = 'GUI/e25XZu2QDkibRkxG@Oraaptdev:1521:aptdev'
	define 3 = 'RDR/UNbGN24jc33WizYp@Oraaptdev:1521:aptdev'
	define 4 = ''
	define 5 = 'SLR/QzFpQ6vDSsngzPRL@Oraaptdev:1521:aptdev'
	define 6 = 'STN/guYA6b54tQYL5Jco@Oraaptdev:1521:aptdev'
	define 7 = 'aptitude/srz4i2GvnLCzREvV@Oraaptdev:1521:aptdev'
	define 8 = ''


    @@install.sql




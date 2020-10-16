-- Populate "UI_SECTION"
INSERT INTO gui.ui_section ("USEC_ID","USEC_NAME","USEC_TECHNICAL_NAME","USEC_TYPE","USEC_ORDER","USEC_USC_ID")
  VALUES (1,'General Lookup Search','general.lookup.search','F',1,1);
INSERT INTO gui.ui_section ("USEC_ID","USEC_NAME","USEC_TECHNICAL_NAME","USEC_TYPE","USEC_ORDER","USEC_USC_ID")
  VALUES (2,'General Lookup Reference Data','general.lookup.list','F',2,1);
INSERT INTO gui.ui_section ("USEC_ID","USEC_NAME","USEC_TECHNICAL_NAME","USEC_TYPE","USEC_ORDER","USEC_USC_ID")
  VALUES (3,'General Lookup User Reference Data','general.lookup.temp.list','F',3,1);
INSERT INTO gui.ui_section ("USEC_ID","USEC_NAME","USEC_TECHNICAL_NAME","USEC_TYPE","USEC_ORDER","USEC_USC_ID")
  VALUES (4,'General Lookup','general.lookup','U',1,2);
INSERT INTO gui.ui_section ("USEC_ID","USEC_NAME","USEC_TECHNICAL_NAME","USEC_TYPE","USEC_ORDER","USEC_USC_ID")
  VALUES (5,'General Lookup Audit History','general.lookup.audit.list','S',2,2);
commit;
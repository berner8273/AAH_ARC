CREATE OR REPLACE PACKAGE BODY rdr.rdr_pkg
AS
   PROCEDURE pGLINT_CLEANUP
   AS
   
   BEGIN
   
   UPDATE fdr.fr_general_lookup
   SET lk_lookup_value5 = 'N', 
       lk_lookup_value6 = SYSDATE
   WHERE   lk_lkt_lookup_type_code = 'EVENT_CLASS_PERIOD'
   AND     lk_lookup_value5 = 'Y'; 
         
   END pGLINT_CLEANUP;

END rdr_pkg;
/
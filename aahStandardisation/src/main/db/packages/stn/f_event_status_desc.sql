CREATE OR REPLACE FUNCTION STN.F_EVENT_STATUS_DESC 
(
  EVENT_CODE IN VARCHAR2 
) RETURN VARCHAR2 AS 
BEGIN
      RETURN 
        CASE EVENT_CODE 
            WHEN 'P' THEN 'Processed'
            WHEN 'U' THEN 'UnProcessed'
            WHEN 'X' THEN 'Discarded'
            WHEN 'E' THEN 'Error'
            WHEN 'V' THEN 'V'
            ELSE EVENT_CODE
        END;      
END F_EVENT_STATUS_DESC;
/




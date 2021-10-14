
declare

sSql varchar(500);
nNext number;
nExists number;

begin


select max(max_id) + 1
into nNext
from 
   (select 'FDR.FR_STAN_RAW_INSURANCE_POLICY', max(to_number(SRIN_EVENT_AUDIT_ID)) max_id from FDR.FR_STAN_RAW_INSURANCE_POLICY union all
    select 'FDR.FR_STAN_RAW_ACC_EVENT'       , max(to_number(SRAE_ACC_EVENT_ID)) from FDR.FR_STAN_RAW_ACC_EVENT );
   
    
IF length(nNext) > 10 THEN
    raise_application_error(-20999,'nCurrent is too big '||nNext);
END IF;


select count(*) into nExists from all_sequences where sequence_name = 'EVENT_AUD_ID_SEQ';

IF nExists > 0 THEN 
    sSql := 'DROP SEQUENCE FDR.EVENT_AUD_ID_SEQ'; 
    execute immediate sSql;
END IF;

-- incremen by 1 and start with the next number from above
sSql := 'CREATE SEQUENCE FDR.EVENT_AUD_ID_SEQ  START WITH '||nNext||' INCREMENT BY 1 MAXVALUE 9999999999 MINVALUE 1  NOCYCLE  CACHE 1000  NOORDER  NOKEEP  GLOBAL';
execute immediate sSql;
     
END;
/
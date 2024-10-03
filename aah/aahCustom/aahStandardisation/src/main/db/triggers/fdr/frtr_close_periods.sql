CREATE OR REPLACE TRIGGER FRTR_CLOSE_PERIODS
AFTER INSERT OR UPDATE ON FDR.FR_GENERAL_LOOKUP
FOR EACH ROW
DECLARE

dOpen date;
BEGIN

    select gp_todays_bus_date into dOpen from fdr.fr_global_parameter where lpg_id = 1;

    IF :new.LK_LKT_LOOKUP_TYPE_CODE = 'EVENT_CLASS_PERIOD' and (:new.lk_lookup_value1 = 'C' and :old.lk_lookup_value1 = 'O') and to_date(:new.lk_lookup_value3,'DD-MM-YYYY') >= dOpen
    THEN
        RAISE_APPLICATION_ERROR(-20101, 'Can not close future accounting period');
        ROLLBACK;
    END IF;
    
END;
/
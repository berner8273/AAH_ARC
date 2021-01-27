CREATE OR REPLACE TRIGGER FDR.FRTR_GENERAL_LOOKUP_UPDATE_CLOSE_STATUS
  BEFORE UPDATE
  ON FR_GENERAL_LOOKUP
  REFERENCING OLD AS OLD NEW AS NEW
  FOR EACH ROW
--DECLARE act_code CHAR(1);
BEGIN
/*
This is a hack because in version 20.3 THE LK_INPUT_TIME value is not being udpated 
*/
    if :NEW.lk_lkt_lookup_type_code = 'EVENT_CLASS_PERIOD' then
         if :OLD.LK_LOOKUP_VALUE1 = 'O' and :NEW.LK_LOOKUP_VALUE1 = 'C' then
            :NEW.LK_INPUT_TIME := sysdate;
         end if;
    end if;
END;
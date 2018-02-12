CREATE OR REPLACE PACKAGE BODY GUI."PG_UI_ERROR_HANDLER" AS

-----------------------------------------------------------------------
-- $Revision: 1.1 $
-- $Date: 2007/09/18 10:56:50 $
--
-- Contents:        Error Handler Package Body
-- Developer:       Darryl Charman (DAC)
-- Project:         FDR GUI
-- Created:         21st July 2004
-- Language:        PL/SQL
-- Notes:
-- Known problems:  None
-- Portability:     Oracle v9 and above.
--
-- Update Hist\ory (most recent first):
-- ===================================
-- dd/mm/yyyy       Description
-- ----------       -----------
-- 10/09/2004       Added procedure check_resubmitted_errors to check for successful resubmissions
-- 11/08/2004       Changed resubmit_transaction procedure to check metadata schemas for BE/EBE type
-- 30/07/2004       Added ability to pass in multiple comma-delimited values in a parameter
-- 30/07/2004       Added additional error logging
-- 21/07/2004       Package Body Created
--
-----------------------------------------------------------------------

TYPE error_text_rec   IS RECORD (
    error_text     VARCHAR2(280),
    error_value    VARCHAR2(80)
);

TYPE trans_table_rec  IS RECORD (
    transaction_id VARCHAR2(240),
    table_in_error VARCHAR2(80)
);

TYPE error_management_rec   IS RECORD (
    --error_text     VARCHAR2(280),
    error_value    VARCHAR2(240),
    --error_table    VARCHAR2(240),
    error_cli_key_no VARCHAR2(240)
);

TYPE error_ids            IS TABLE OF NUMBER;
TYPE error_texts          IS TABLE OF error_text_rec;
TYPE transaction_ids      IS TABLE OF VARCHAR2(240);
TYPE transaction_tables   IS TABLE OF trans_table_rec;
TYPE error_management     IS TABLE OF error_management_rec;

PROCEDURE log_status_change(
        error_id        IN NUMBER,
        current_status  IN CHAR,
        new_status      IN CHAR,
        owner           IN VARCHAR2,
        date_time_stamp IN DATE
) IS

-- PURPOSE:
--     This function logs any status change for an erorr row in the fr_log table
-- NOTES:
-- (1) The error id (LO_EVENT_ID), the current status, the new status and a timestamp are passed as parameters

BEGIN

    INSERT INTO gui.T_UI_ERROR_AUDIT (LO_EVENT_ID, LO_OLD_STATUS, LO_NEW_STATUS, LO_USER_CHANGE, LO_TIME_CHANGE) VALUES (error_id, current_status, new_status, owner, date_time_stamp);

EXCEPTION

    WHEN OTHERS THEN
        fdr.Pr_Error(2, 'Error occurred logging status change: ' || SUBSTR(SQLERRM, 1, 240), 0, 'pg_ui_error_handler.log_status_change', NULL, NULL, NULL, 'ERROR HANDLER GUI', 'PL/SQL', error_id||'$'||current_status||'$'||new_status, NULL, NULL, NULL, NULL, NULL, NULL);
        RAISE;

END;

PROCEDURE update_status(
        error_list      IN  VARCHAR2,
        new_status      IN  CHAR,
        owner           IN  VARCHAR2,
        success         OUT CHAR
) IS

-- PURPOSE:
--     This function updates the status of a set of error rows in the fr_log table
-- NOTES:
-- (1) The error id (LO_EVENT_ID) and the new status (LO_ERROR_STATUS) are passed as parameters
-- (2) The error_id parameter is passed as multiple pipe-delimited error_id's.
-- (3) A success boolean (ie a CHAR(1)) is passed as an out parameter
-- (4) This is called by the GUI

CURSOR cur_error(err_id VARCHAR2) IS
    SELECT lo_error_status FROM fdr.fr_log WHERE lo_event_id = err_id;

CURSOR cur_error_updater(err_id VARCHAR2) IS
        SELECT * FROM (
            SELECT LO_USER_CHANGE FROM gui.T_UI_ERROR_AUDIT WHERE
            LO_EVENT_ID = err_id
            AND LO_NEW_STATUS = 'U'
            AND LO_OLD_STATUS <> LO_NEW_STATUS
            ORDER BY LO_TIME_CHANGE DESC
            ) WHERE rownum < 2 ;

    work_status      CHAR(1);
    can_be_changed   BOOLEAN := true;
    unauthorise_updater VARCHAR2(20);
    current_status   CHAR(1);
    err_ids          error_ids := error_ids();
    next_err_no      VARCHAR2(40);
    array_count      NUMBER(12) := 1;
    loop_count       NUMBER(12);
    log_code         VARCHAR2(240)  := '';

BEGIN

    success := 'N';

    -- Build error_ids collection based on the error_list parameter
    FOR loop_count IN 1..LENGTH(error_list)
    LOOP
        log_code := 'Building error list array. At location: ' || loop_count;
        IF SUBSTR(error_list, loop_count, 1) = '|' THEN
            -- Add to collection
            err_ids.extend;
            err_ids(array_count) := trim(next_err_no);
            next_err_no := '';
            -- Increment collection count
            array_count := array_count + 1;
        ELSIF loop_count = LENGTH(error_list) THEN
            -- Add last character onto string
            next_err_no := next_err_no || SUBSTR(error_list, loop_count, 1);

            -- Add to collection
            err_ids.extend;
            err_ids(array_count) := trim(next_err_no);
            next_err_no := '';
        ELSE
            -- Build string for error collection from parameter
            next_err_no := next_err_no || SUBSTR(error_list, loop_count, 1);
        END IF;

    END LOOP;

    -- Now loop through array, acting on each error id in turn
    FOR loop_count IN 1..array_count
    LOOP
        log_code := 'Processing error list array. At location: ' || loop_count;

        OPEN cur_error(err_ids(loop_count));
        FETCH cur_error INTO current_status;
        CLOSE cur_error;

        IF current_status NOT IN ('R', 'S') THEN-- only allow non-resubmitted / non-successfully reprocessed errors to be updated.

            IF (new_status = 'U' AND current_status = new_status ) OR --if error is already awaiting for authorization of setting to not for resubmission  ONLY different user then owner can change status to not for resubmission
               current_status = 'U' THEN
                  OPEN cur_error_updater(err_ids(loop_count));
                  FETCH cur_error_updater INTO unauthorise_updater;
                  CLOSE cur_error_updater;
                  IF UPPER(unauthorise_updater) <> UPPER(owner) OR unauthorise_updater IS NULL THEN
                     can_be_changed := true;
                  ELSE
                     success := 'P'; --Partially unsuccessfully
                     can_be_changed := false;
                  END IF;
                  IF (new_status = 'U' AND current_status = new_status ) THEN
                     work_status := 'N';
                  ELSE
                     work_status := new_status;
                  END IF;
            ELSE
               work_status := new_status;
               can_be_changed := true;
            END IF;
            IF can_be_changed = true THEN
               --log to audit table
               log_status_change(err_ids(loop_count), current_status, work_status, owner, SYSDATE);

               UPDATE fdr.fr_log SET lo_error_status = work_status WHERE lo_event_id = err_ids(loop_count);
            END IF;

      END IF;

    END LOOP;

    COMMIT;

    IF success = 'N' THEN
        success := 'Y';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fdr.Pr_Error(2, 'Error occurred updating status: ' || SUBSTR(SQLERRM, 1, 240), 0, 'pg_ui_error_handler.update_status', NULL, NULL, NULL, 'ERROR HANDLER GUI', 'PL/SQL', log_code, NULL, NULL, NULL, NULL, NULL, NULL);
    RAISE;

END;

PROCEDURE update_status_cause(
        error_text_list    IN  VARCHAR2,
        error_value_list   IN  VARCHAR2,
        error_date         IN  VARCHAR2,
        new_status         IN  CHAR,
        owner              IN  VARCHAR2,
        success            OUT CHAR
) IS
-- PURPOSE:
--     This function updates the status of all error messages of particular types and values for a particular day in the fr_log table
-- NOTES:
-- (1) The error_text (LO_EVENT_TEXT), error_value (LO_ERROR_VALUE), error_date (LO_TODAYS_BUS_DATE) and the new status(LO_ERROR_STATUS)
--     are passed as parameters
-- (2) The error text and error value parameters can contain multiple pipe-delimited values
-- (3) The procedure also logs to the error processing audit table
-- (4) A success boolean (ie a CHAR(1)) is passed as an out parameter
-- (5) This is called by the GUI
CURSOR cur_errors(err_text VARCHAR2, err_value VARCHAR2, err_date DATE) IS
    SELECT lo_event_id, lo_error_status AS lo_current_status
    FROM fdr.fr_log
    WHERE
    trim(lo_event_text) = err_text AND
    NVL(DECODE(trim(lo_error_value),'','*',trim(lo_error_value)),'*') = DECODE(err_value,'','*',err_value) AND
    trunc(lo_todays_bus_date) BETWEEN gui.Pg_Ui_System.Fn_Ui_GetPreviousBusinessDay(err_date) AND err_date;

CURSOR cur_error_updater(err_id VARCHAR2) IS
        SELECT * FROM (
            SELECT LO_USER_CHANGE FROM gui.T_UI_ERROR_AUDIT WHERE
            LO_EVENT_ID = err_id
            AND LO_NEW_STATUS = 'U'
            AND LO_OLD_STATUS <> LO_NEW_STATUS
            ORDER BY LO_TIME_CHANGE DESC
            ) WHERE rownum < 2 ;

    work_status      CHAR(1);
    can_be_changed   BOOLEAN := true;
    unauthorise_updater VARCHAR2(20);

    err_texts           error_texts   := error_texts();
    next_err_text       VARCHAR2(2000) := '';
    next_err_value      VARCHAR2(2000)  := '';
    array_count         NUMBER(12)    := 1;
    loop_count          NUMBER(12);
    tmp_error_date      DATE;
    log_code            VARCHAR2(240)  := '';
BEGIN
    success := 'N';
    --temporarily accepting the error_date param as a String and converting it here to a DATE
    tmp_error_date := TO_DATE(error_date,'dd-mon-yyyy');
    -- Build error_ids collection based on the error_list parameter
    FOR loop_count IN 1..LENGTH(error_text_list)
    LOOP
        log_code := 'Build error text list array. At location: ' || loop_count;
        IF SUBSTR(error_text_list, loop_count, 1) = '|' THEN
            -- Add to collection
            err_texts.extend;
            err_texts(array_count).error_text := trim(next_err_text);
            next_err_text := '';
            -- Increment collection count
            array_count := array_count + 1;
        ELSIF loop_count = LENGTH(error_text_list) THEN
            -- Add last character onto string
            next_err_text := next_err_text || SUBSTR(error_text_list, loop_count, 1);
            -- Add to collection
            err_texts.extend;
            err_texts(array_count).error_text := trim(next_err_text);
            next_err_text := '';
        ELSE
            -- Build string for error collection from parameter
            next_err_text := next_err_text || SUBSTR(error_text_list, loop_count, 1);
        END IF;
    END LOOP;
    -- Now update the array with the values from the error_value_list parameter
    array_count := 1;

    FOR loop_count IN 1..NVL(LENGTH(error_value_list),0)
    LOOP
        log_code := 'Build error value list array. At location: ' || loop_count;
        IF SUBSTR(error_value_list, loop_count, 1) = '|' THEN
            -- Update collection
            err_texts(array_count).error_value := trim(next_err_value);
            next_err_value := '';
            -- Increment collection count
            array_count := array_count + 1;
        ELSIF loop_count = LENGTH(error_value_list) THEN
            next_err_value := next_err_value || SUBSTR(error_value_list, loop_count, 1);
            -- Update collection
            err_texts(array_count).error_value := trim(next_err_value);
            next_err_value := '';
        ELSE
            -- Build string for error collection from parameter
            next_err_value := next_err_value || SUBSTR(error_value_list, loop_count, 1);
        END IF;
    END LOOP;
    -- Now loop through array processing each error text/value combination
    FOR loop_count IN 1..array_count
    LOOP
        log_code := 'Processing error list array. At location: ' || loop_count;
        FOR cur_row IN cur_errors(err_texts(loop_count).error_text, err_texts(loop_count).error_value, tmp_error_date)
        LOOP
--dbms_output.put_line(err_texts(loop_count).error_text ||', '|| err_texts(loop_count).error_value);
            IF cur_row.lo_current_status NOT IN ('R', 'S', 'C') THEN   -- only allow non-resubmitted / non-successfully reprocessed errors to be updated.
               IF (new_status = 'U' AND cur_row.lo_current_status = new_status ) OR --if error is already awaiting for authorization of setting to not for resubmission  ONLY different user then owner can change status to not for resubmission
                  cur_row.lo_current_status = 'U' THEN
                     OPEN cur_error_updater(cur_row.lo_event_id);
                     FETCH cur_error_updater INTO unauthorise_updater;
                     CLOSE cur_error_updater;
                     IF UPPER(unauthorise_updater) <> UPPER(owner) OR unauthorise_updater IS NULL THEN
                        can_be_changed := true;
                     ELSE
                        success := 'P'; --Partially unsuccessfully
                        can_be_changed := false;
                     END IF;
                     IF (new_status = 'U' AND cur_row.lo_current_status = new_status ) THEN
                        work_status := 'N';
                     ELSE
                        work_status := new_status;
                     END IF;
               ELSE
                  work_status := new_status;
                  can_be_changed := true;
               END IF;
               IF can_be_changed = true THEN
                   --log to audit table
                   log_status_change(cur_row.lo_event_id, cur_row.lo_current_status, work_status, owner, SYSDATE);
                   --update fr_log table
                   UPDATE fdr.fr_log SET lo_error_status = work_status WHERE lo_event_id = cur_row.lo_event_id;
               END IF;
            END IF;
        END LOOP;
    END LOOP;
    COMMIT;
    IF success = 'N' THEN
        success := 'Y';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fdr.Pr_Error(2, 'Error occurred updating status cause: ' || SUBSTR(SQLERRM, 1, 240), 0, 'pg_ui_error_handler.update_status_cause', NULL, NULL, NULL, 'ERROR HANDLER GUI', 'PL/SQL', log_code, NULL, NULL, NULL, NULL, NULL, NULL);
    RAISE;
END;

PROCEDURE update_status_trans(
        tran_id_list    IN  VARCHAR2,
        error_date      IN  VARCHAR2,
        new_status      IN  CHAR,
        owner           IN  VARCHAR2,
        success         OUT CHAR
) IS

-- PURPOSE:
--     This function updates the status of all error messages of a list of transactions for a particular day in the fr_log table
-- NOTES:
-- (1) The transaction ids (LO_ERROR_CLIENT_KEY_NO), error_date (LO_TODAYS_BUS_DATE) and the new status(LO_ERROR_STATUS) are passed as parameters
-- (2) THe transaction ids are passed as a pipe delimited list eg 12345|34567|98765
-- (3) The procedure also logs to the error processing audit table
-- (4) A success boolean (ie a CHAR(1)) is passed as an out parameter
-- (5) This is called by the GUI

CURSOR cur_errors(tran_id VARCHAR2, error_date DATE) IS
    SELECT lo_event_id, lo_error_status AS lo_current_status
    FROM fdr.fr_log
    WHERE
    lo_error_client_key_no = tran_id AND
    trunc(lo_todays_bus_date) BETWEEN gui.Pg_Ui_System.Fn_Ui_GetPreviousBusinessDay(NVL(error_date, trunc(lo_todays_bus_date))) AND NVL(error_date, trunc(lo_todays_bus_date));

CURSOR cur_error_updater(err_id VARCHAR2) IS
        SELECT * FROM (
            SELECT LO_USER_CHANGE FROM gui.T_UI_ERROR_AUDIT WHERE
            LO_EVENT_ID = err_id
            AND LO_NEW_STATUS = 'U'
            AND LO_OLD_STATUS <> LO_NEW_STATUS
            ORDER BY LO_TIME_CHANGE DESC
            ) WHERE rownum < 2 ;

    work_status      CHAR(1);
    can_be_changed   BOOLEAN := true;
    unauthorise_updater VARCHAR2(20);
    tran_ids            transaction_ids := transaction_ids();
    next_tran_id        VARCHAR2(240);
    array_count         NUMBER(12) := 1;
    loop_count          NUMBER(12);
    tmp_error_date      DATE;

    log_code            VARCHAR2(240)  := '';

BEGIN

    success := 'N';

    --temporarily accepting the error_date param as a String and converting it here to a DATE
    tmp_error_date := TO_DATE(error_date,'dd-mon-yyyy');

    -- Build error_ids collection based on the error_list parameter
    FOR loop_count IN 1..LENGTH(tran_id_list)
    LOOP
        log_code := 'Building transaction id list array. At location: ' || loop_count;
        IF SUBSTR(tran_id_list, loop_count, 1) = '|' THEN
            -- Add to collection
            tran_ids.extend;
            tran_ids(array_count) := trim(next_tran_id);
            next_tran_id := '';
            -- Increment collection count
            array_count := array_count + 1;
        ELSIF loop_count = LENGTH(tran_id_list) THEN -- last character processing
            -- Add last character onto string
            next_tran_id := next_tran_id || SUBSTR(tran_id_list, loop_count, 1);
            -- Add to collection
            tran_ids.extend;
            tran_ids(array_count) := trim(next_tran_id);
            next_tran_id := '';
        ELSE
            -- Build string for error collection from parameter
            next_tran_id := next_tran_id || SUBSTR(tran_id_list, loop_count, 1);
        END IF;

    END LOOP;

    FOR loop_count IN 1..array_count
    LOOP
        log_code := 'Processing transaction id list array. At location: ' || loop_count;

        FOR cur_row IN cur_errors(tran_ids(loop_count), tmp_error_date)
        LOOP

            IF cur_row.lo_current_status NOT IN ('R', 'S') THEN   -- only allow non-resubmitted / non-successfully reprocessed errors to be updated.
               IF (new_status = 'U' AND cur_row.lo_current_status = new_status ) OR --if error is already awaiting for authorization of setting to not for resubmission  ONLY different user then owner can change status to not for resubmission
                  cur_row.lo_current_status = 'U' THEN
                     OPEN cur_error_updater(cur_row.lo_event_id);
                     FETCH cur_error_updater INTO unauthorise_updater;
                     CLOSE cur_error_updater;
                     IF UPPER(unauthorise_updater) <> UPPER(owner) OR unauthorise_updater IS NULL THEN
                        can_be_changed := true;
                     ELSE
                        success := 'P'; --Partially unsuccessfully
                        can_be_changed := false;
                     END IF;
                     IF (new_status = 'U' AND cur_row.lo_current_status = new_status ) THEN
                        work_status := 'N';
                     ELSE
                        work_status := new_status;
                     END IF;
               ELSE
                  work_status := new_status;
                  can_be_changed := true;
               END IF;
               IF can_be_changed = true THEN
                   --log to audit table
                   log_status_change(cur_row.lo_event_id, cur_row.lo_current_status, work_status, owner, SYSDATE);

                   --update fr_log table
                   UPDATE fdr.fr_log SET lo_error_status = work_status WHERE lo_event_id = cur_row.lo_event_id;
               END IF;
            END IF;

        END LOOP;

    END LOOP;

    COMMIT;

    IF success = 'N' THEN
        success := 'Y';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fdr.Pr_Error(2, 'Error occurred updating status transaction: ' || SUBSTR(SQLERRM, 1, 240), 0, 'pg_ui_error_handler.update_status_trans', NULL, NULL, NULL, 'ERROR HANDLER GUI', 'PL/SQL', log_code, NULL, NULL, NULL, NULL, NULL, NULL);
    RAISE;
END;

PROCEDURE update_status_log_management(
        error_text_list    IN  VARCHAR2,
        error_value_list   IN  VARCHAR2,
        error_table_list   IN  VARCHAR2,
        error_client_key_no_list  IN  VARCHAR2,
        new_status         IN  CHAR,
        owner              IN  VARCHAR2,
        success            OUT CHAR
) IS
-- PURPOSE:
--     This function updates the status of all error messages of particular types, values, table names and client key numbers in the fr_log table
-- NOTES:
-- (1) The error_text (LO_EVENT_TEXT), error_value (LO_ERROR_VALUE), error_table (LO_TABLE_IN_ERROR_NAME), error_client_key_no (LO_ERROR_CLIENT_KEY_NO) and the new status(LO_ERROR_STATUS)
--     are passed as parameters
-- (2) The error text and error value parameters can contain multiple pipe-delimited values
-- (3) The procedure also logs to the error processing audit table
-- (4) A success boolean (ie a CHAR(1)) is passed as an out parameter
-- (5) This is called by the GUI
CURSOR cur_errors(err_text VARCHAR2, err_value VARCHAR2, err_table VARCHAR2, err_cli_key_no VARCHAR2) IS
    SELECT lo_event_id, lo_error_status AS lo_current_status
    FROM fdr.fr_log
    WHERE
    DECODE(trim(lo_event_text),'','*',trim(lo_event_text)) = DECODE(err_text,'','*',err_text) AND
    DECODE(trim(lo_error_value),'','*',trim(lo_error_value)) = DECODE(err_value,'','*',err_value) AND
    DECODE(trim(lo_table_in_error_name),'','*',trim(lo_table_in_error_name)) = DECODE(DECODE(err_table,'NULL',null,err_table),'','*',DECODE(err_table,'NULL',null,err_table)) AND
    DECODE(trim(lo_error_client_key_no),'','*',trim(lo_error_client_key_no)) = DECODE(DECODE(err_cli_key_no,'NULL',null,err_cli_key_no),'','*',DECODE(err_cli_key_no,'NULL',null,err_cli_key_no));

CURSOR cur_error_updater(err_id VARCHAR2) IS
        SELECT * FROM (
            SELECT LO_USER_CHANGE, LO_OLD_STATUS FROM gui.T_UI_ERROR_AUDIT WHERE
            LO_EVENT_ID = err_id
            AND LO_NEW_STATUS = 'U'
            AND LO_OLD_STATUS <> LO_NEW_STATUS
            ORDER BY LO_TIME_CHANGE DESC
            ) WHERE rownum < 2 ;

    work_status      CHAR(1);
    can_be_changed   BOOLEAN := true;
    unauthorise_updater VARCHAR2(20);
    prev_err_status  gui.T_UI_ERROR_AUDIT.LO_OLD_STATUS%TYPE;

    err_management      error_management   := error_management();
    next_err_text       VARCHAR2(2000) := '';
    next_err_value      VARCHAR2(2000)  := '';
    next_err_table      VARCHAR2(2000)  := '';
    next_err_cli_key_no VARCHAR2(2000)  := '';
    array_count         NUMBER(12)    := 1;
    loop_count          NUMBER(12);
    log_code            VARCHAR2(240)  := '';
BEGIN
    success := 'N';

   /* -- Build error_ids collection based on the error_list parameter
    FOR loop_count IN 1..LENGTH(error_text_list)
    LOOP
        log_code := 'Build error text list array. At location: ' || loop_count;
        IF SUBSTR(error_text_list, loop_count, 1) = '|' THEN
            -- Add to collection
            err_management.extend;
            err_management(array_count).error_text := trim(next_err_text);
            next_err_text := '';
            -- Increment collection count
            array_count := array_count + 1;
        ELSIF loop_count = LENGTH(error_text_list) THEN
            -- Add last character onto string
            next_err_text := next_err_text || SUBSTR(error_text_list, loop_count, 1);
            -- Add to collection
            err_management.extend;
            err_management(array_count).error_text := trim(next_err_text);
            next_err_text := '';
        ELSE
            -- Build string for error collection from parameter
            next_err_text := next_err_text || SUBSTR(error_text_list, loop_count, 1);
        END IF;
    END LOOP;
    -- Now update the array with the values from the error_value_list parameter
    array_count := 1;*/

    FOR loop_count IN 1..NVL(LENGTH(error_value_list),0)
    LOOP
        log_code := 'Build error value list array. At location: ' || loop_count;
        IF SUBSTR(error_value_list, loop_count, 1) = '|' THEN
            -- add to collection
            err_management.extend;
            err_management(array_count).error_value := trim(next_err_value);
            next_err_value := '';
            -- Increment collection count
            array_count := array_count + 1;
        ELSIF loop_count = LENGTH(error_value_list) THEN
            next_err_value := next_err_value || SUBSTR(error_value_list, loop_count, 1);
            -- add to collection
            err_management.extend;
            err_management(array_count).error_value := trim(next_err_value);
            next_err_value := '';
        ELSE
            -- Build string for error collection from parameter
            next_err_value := next_err_value || SUBSTR(error_value_list, loop_count, 1);
        END IF;
    END LOOP;

  /*  -- Now update the array with the values from the error_table_list parameter
    array_count := 1;

   FOR loop_count IN 1..NVL(LENGTH(error_table_list),0)
    LOOP
        log_code := 'Build error table list array. At location: ' || loop_count;
        IF SUBSTR(error_table_list, loop_count, 1) = '|' THEN
            -- Update collection
            err_management(array_count).error_table := trim(next_err_table);
            next_err_table := '';
            -- Increment collection count
            array_count := array_count + 1;
        ELSIF loop_count = LENGTH(error_table_list) THEN
            next_err_table := next_err_table || SUBSTR(error_table_list, loop_count, 1);
            -- Update collection
            err_management(array_count).error_table := trim(next_err_table);
            next_err_table := '';
        ELSE
            -- Build string for error collection from parameter
            next_err_table := next_err_table || SUBSTR(error_table_list, loop_count, 1);
        END IF;
    END LOOP;*/

    -- Now update the array with the values from the error_client_key_no_list parameter
    array_count := 1;

   FOR loop_count IN 1..NVL(LENGTH(error_client_key_no_list),0)
    LOOP
        log_code := 'Build error table list array. At location: ' || loop_count;
        IF SUBSTR(error_client_key_no_list, loop_count, 1) = '|' THEN
            -- Update collection
            if (error_value_list is null) then
              err_management.extend;
            end if;
            err_management(array_count).error_cli_key_no := trim(next_err_cli_key_no);
            next_err_cli_key_no := '';
            -- Increment collection count
            array_count := array_count + 1;
        ELSIF loop_count = LENGTH(error_client_key_no_list) THEN
            next_err_cli_key_no := next_err_cli_key_no || SUBSTR(error_client_key_no_list, loop_count, 1);
            -- Update collection
            if (error_value_list is null) then
              err_management.extend;
            end if;
            err_management(array_count).error_cli_key_no := trim(next_err_cli_key_no);
            next_err_cli_key_no := '';
        ELSE
            -- Build string for error collection from parameter
            next_err_cli_key_no := next_err_cli_key_no || SUBSTR(error_client_key_no_list, loop_count, 1);
        END IF;
    END LOOP;

    -- Now loop through array processing each error text/value/table/client_key_no combination
    FOR loop_count IN 1..array_count
    LOOP
        log_code := 'Processing error list array. At location: ' || loop_count;
        FOR cur_row IN cur_errors(error_text_list, (case when error_value_list is null then null else err_management(loop_count).error_value end), error_table_list, (case when error_client_key_no_list is null then null else err_management(loop_count).error_cli_key_no end))
        LOOP
--dbms_output.put_line(err_management(loop_count).error_text ||', '|| err_management(loop_count).error_value);
            IF cur_row.lo_current_status NOT IN ('R', 'S', 'C') THEN   -- only allow non-resubmitted / non-successfully reprocessed errors to be updated.
               IF new_status = 'U' OR new_status = 'P' OR new_status = 'N' THEN
                     OPEN cur_error_updater(cur_row.lo_event_id);
                     FETCH cur_error_updater INTO unauthorise_updater, prev_err_status;
                     CLOSE cur_error_updater;
                     IF UPPER(unauthorise_updater) <> UPPER(owner) OR unauthorise_updater IS NULL THEN
                        can_be_changed := true;
                     ELSE
                        success := 'P'; --Partially unsuccessfully
                        can_be_changed := false;
                     END IF;
                     IF (new_status = 'P') then --if new_status equals 'P' then change was rejected and error_status should be updated with previous value
                        work_status := NVL(prev_err_status,'E');
                     ELSE
                        work_status := new_status;
                     END IF;
               ELSE
                  work_status := new_status;
                  can_be_changed := true;
               END IF;
               IF can_be_changed = true THEN
                   --log to audit table
                   log_status_change(cur_row.lo_event_id, cur_row.lo_current_status, work_status, owner, SYSDATE);
                   --update fr_log table
                   UPDATE fdr.fr_log SET lo_error_status = work_status WHERE lo_event_id = cur_row.lo_event_id;
               END IF;
            END IF;
        END LOOP;
    END LOOP;
    COMMIT;
    IF success = 'N' THEN
        success := 'Y';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fdr.Pr_Error(2, 'Error occurred updating status cause: ' || SUBSTR(SQLERRM, 1, 240), 0, 'pg_ui_error_handler.update_status_log_management', NULL, NULL, NULL, 'ERROR HANDLER GUI', 'PL/SQL', log_code, NULL, NULL, NULL, NULL, NULL, NULL);
    RAISE;
END;

PROCEDURE resubmit_transaction(
        tran_id_list          IN  VARCHAR2,
        table_in_error_list   IN  VARCHAR2,
        error_date            IN  VARCHAR2,
        owner                 IN  VARCHAR2,
        success               OUT CHAR
) IS

-- PURPOSE:
--     This function resubmits one or many transactions in error once all the errors against the transaction are fixed
-- NOTES:
-- (1) The transaction id (LO_ERROR_CLIENT_KEY_NO), the table in error (LO_TABLE_IN_ERROR_NAME) and the error date (LO_TODAYS_BUS_DATE)
--     are passed as parameters
-- (2) The transaction_ids and table_in_error parameters can contain many values in a pipe-delimited list - the number of values in each
--     list must match
-- (3) A success boolean (ie a CHAR(1)) is passed as an out parameter
-- (4) This is called by the GUI, NOT by the IntraDay Batch or Batch process

    --cursor to retrieve the current error statuses associated with a particular trade
    CURSOR cur_error_data(t_id VARCHAR2, tab_name VARCHAR2, err_date DATE) IS
        SELECT lo_event_id, lo_error_status, lo_owner, lo_event_type_id FROM fdr.fr_log
        WHERE
        (lo_error_status = 'F' OR lo_error_status = 'R')AND
		lo_error_client_key_no = t_id AND
        UPPER(lo_table_in_error_name) = UPPER(tab_name) AND
        (err_date IS NULL OR trunc(lo_todays_bus_date) BETWEEN gui.Pg_Ui_System.Fn_Ui_GetPreviousBusinessDay(err_date) AND err_date);

    --cursor to retrieve other error information associated with a particular trade
    CURSOR cur_error_details(t_id VARCHAR2, tab_name VARCHAR2, err_date DATE) IS
        SELECT DISTINCT lo_row_in_error_key_id AS row_key_id, lo_owner AS tab_owner, lo_error_technology AS tab_in_err_type FROM fdr.fr_log
        WHERE
        (lo_error_status = 'F' OR lo_error_status = 'R')AND
		lo_error_client_key_no = t_id AND
        UPPER(lo_table_in_error_name) = UPPER(tab_name) AND
        (err_date IS NULL OR trunc(lo_todays_bus_date) BETWEEN gui.Pg_Ui_System.Fn_Ui_GetPreviousBusinessDay(err_date) AND err_date);

    --cursor to retrieve the primary key column for the table_in_error - assumes this will always be a single column
    CURSOR cur_primary_key_col(tab_name VARCHAR2, tab_owner VARCHAR2) IS
        SELECT column_name
        FROM all_cons_columns
        WHERE
        UPPER(table_name) = UPPER(tab_name) AND
		UPPER(owner) = UPPER(tab_owner) AND
        constraint_name = (
            SELECT constraint_name
            FROM all_constraints
            WHERE
            UPPER(table_name) = UPPER(tab_name) AND
			UPPER(owner) = UPPER(tab_owner) AND
            constraint_type = 'P'
            )
         AND column_name != 'LPG_ID';

--    row_key_id          VARCHAR2(80);
    sql_str             VARCHAR2(800);
    pk_col              VARCHAR2(40);
--    tab_in_err_type     VARCHAR2(40);
--    tab_owner           VARCHAR2(20);
    set_clause          VARCHAR2(240) := '';
    unfixed_error       EXCEPTION;
    e_no_pk             EXCEPTION;
    tmp_error_date      DATE;
    tran_tables         transaction_tables := transaction_tables();
    next_transaction_id VARCHAR2(240);
    next_table_in_error VARCHAR2(40);
    array_count         NUMBER(12) := 1;
    loop_count          NUMBER(12);
    v_table             VARCHAR2(80):=NULL;
    v_msg               VARCHAR2(1000);

    log_code            VARCHAR2(240)  := '';

BEGIN

    success := 'N';

    --temporarily accepting the error_date param as a String and converting it here to a DATE
    tmp_error_date := TO_DATE(error_date,'dd-mm-yyyy');

    -- Build error_ids collection based on the error_list parameter
    FOR loop_count IN 1..LENGTH(tran_id_list)
    LOOP
        log_code := 'Building transaction id list array. At location: ' || loop_count;
        IF SUBSTR(tran_id_list, loop_count, 1) = '|' THEN
            -- Add to collection
            tran_tables.extend;
            tran_tables(array_count).transaction_id := trim(next_transaction_id);
            next_transaction_id := '';
            -- Increment collection count
            array_count := array_count + 1;
        ELSIF loop_count = LENGTH(tran_id_list) THEN
            -- Add last character onto string
            next_transaction_id := next_transaction_id || SUBSTR(tran_id_list, loop_count, 1);
            -- Add to collection
            tran_tables.extend;
            tran_tables(array_count).transaction_id := trim(next_transaction_id);
            next_transaction_id := '';
        ELSE
            -- Build string for error collection from parameter
            next_transaction_id := next_transaction_id || SUBSTR(tran_id_list, loop_count, 1);
        END IF;
    END LOOP;

    -- Now update the array with the values from the error_value_list parameter
    array_count := 1;
    FOR loop_count IN 1..LENGTH(table_in_error_list)
    LOOP
        log_code := 'Building table_in_error list array. At location: ' || loop_count;
        IF SUBSTR(table_in_error_list, loop_count, 1) = '|' THEN
            -- Update collection
            tran_tables(array_count).table_in_error := trim(next_table_in_error);
            next_table_in_error := '';
            -- Increment collection count
            array_count := array_count + 1;
        ELSIF loop_count = LENGTH(table_in_error_list) THEN
            next_table_in_error := next_table_in_error || SUBSTR(table_in_error_list, loop_count, 1);
            -- Update collection
            tran_tables(array_count).table_in_error := trim(next_table_in_error);
            next_table_in_error := '';
        ELSE
            -- Build string for error collection from parameter
            next_table_in_error := next_table_in_error || SUBSTR(table_in_error_list, loop_count, 1);
        END IF;
    END LOOP;

    -- Now loop through array processing each error text/value combination
    FOR loop_count IN 1..array_count
    LOOP
        log_code := 'Processing error list array. At location: ' || loop_count;
		v_table := tran_tables(loop_count).table_in_error;
        BEGIN

            -- Now get the row_id and table owner of the hopper row in error

            -- Now get the row_id and table owner of the each hopper row in error
            FOR cur_row_det IN cur_error_details(tran_tables(loop_count).transaction_id, tran_tables(loop_count).table_in_error, tmp_error_date)
            LOOP
				-- And the primary key column name of the hopper in error
				OPEN cur_primary_key_col(tran_tables(loop_count).table_in_error, cur_row_det.tab_owner);
				FETCH cur_primary_key_col INTO pk_col;
				CLOSE cur_primary_key_col;

				IF pk_col IS NULL THEN
				  -- No primary key column retrieved, possible permission problem.
				  v_table := tran_tables(loop_count).table_in_error;
				  RAISE e_no_pk;
				END IF;

            -- Build Set Clause
            IF upper(cur_row_det.tab_in_err_type) = 'APTITUDE' THEN
                set_clause := ' EVENT_STATUS = ''U'' ';
            END IF;

            -- Build and execute SQL to update the event status of the hopper row to 'U' for re-processing
            sql_str := 'UPDATE ' || cur_row_det.tab_owner || '.' || tran_tables(loop_count).table_in_error || ' SET ' || set_clause || ' WHERE ' || pk_col || ' = '''|| cur_row_det.row_key_id || '''';

            log_code := SUBSTR(log_code || ' : ' || sql_str, 1, 240);

            EXECUTE IMMEDIATE sql_str;

            END LOOP;

            --Update the status of each row in the error table (and log the change)
            FOR cur_row IN cur_error_data(tran_tables(loop_count).transaction_id, tran_tables(loop_count).table_in_error, tmp_error_date)
            LOOP
                log_code := SUBSTR(log_code || ' : ' || cur_row.lo_event_id, 1, 240);

                --log changes to audit table
                log_status_change(cur_row.lo_event_id, cur_row.lo_error_status, 'R', owner, SYSDATE);

                -- Update the rows in the fr_log table to show as being re-submitted
                UPDATE fdr.fr_log SET lo_error_status = 'R'
                WHERE
                lo_error_status = 'F' AND
                lo_error_client_key_no = tran_tables(loop_count).transaction_id AND
                UPPER(lo_table_in_error_name) = UPPER(tran_tables(loop_count).table_in_error) AND
                (tmp_error_date IS NULL OR trunc(lo_todays_bus_date) BETWEEN gui.Pg_Ui_System.Fn_Ui_GetPreviousBusinessDay(tmp_error_date) AND tmp_error_date);

            END LOOP;

        EXCEPTION
            WHEN unfixed_error OR e_no_pk THEN
                RAISE;
        END;

    END LOOP;

    COMMIT;

    success := 'Y';

EXCEPTION

    WHEN e_no_pk THEN
        ROLLBACK;
        v_msg := 'No primary key column retrieved for '|| v_table || ', possible permissions problem';
        fdr.Pr_Error(2, v_msg, 0, 'pg_ui_error_handler.resubmit_transaction', v_table, NULL, NULL, 'ERROR HANDLER GUI', 'PL/SQL', log_code, NULL, NULL, NULL, NULL, NULL, NULL);
        RAISE_APPLICATION_ERROR(-20001, 'pg_ui_error_handler.resubmit_transaction: '||v_msg);

    WHEN OTHERS THEN
        ROLLBACK;
        fdr.Pr_Error(2, 'Error occurred resubmitting transaction: '||v_table||' ' || SUBSTR(SQLERRM, 1, 240), 0, 'pg_ui_error_handler.resubmit_transaction', v_table, NULL, NULL,  'ERROR HANDLER GUI', 'PL/SQL', log_code, NULL, NULL, NULL, NULL, NULL, NULL);
        RAISE;

END;

PROCEDURE check_resubmitted_errors(lpg in NUMBER := 1)

IS
-- PURPOSE:
--     This procedure checks all records with status 'R' and sees if the underlying record has
--     been successfully resubmitted. If so, it's status is set to 'S'.  If another error has been generated
--     due to the resubmission, the status is set to 'C'.  If it is any other status, its set to back to 'E'
-- NOTES:
--     (1) This proc should be run at the end of the intra-day batch to check for successful resubmissions of errors
--
    CURSOR get_resubmitted_records IS
        SELECT * FROM FDR.FR_LOG WHERE LO_ERROR_STATUS = 'R' and lpg_id = lpg;  -- R = Resubmitted

    log_code    VARCHAR2(240);
    rec_status  VARCHAR2(20);
    status      NUMBER(3);
    error_count NUMBER(5);

BEGIN

    FOR cur_record IN get_resubmitted_records
    LOOP

        log_code := 'checking the source tables for error resubmission';

        -- check source table
        check_source_table(
            cur_record.lo_event_id,
            cur_record.lo_table_in_error_name,
            cur_record.lo_row_in_error_key_id,
            cur_record.lo_owner,
			lpg,
            rec_status);

            IF rec_status = 'P' THEN
                -- processed successfully from source table
                check_for_new_errors(
                    cur_record.lo_row_in_error_key_id,
                    cur_record.lo_table_in_error_name,
                    cur_record.lo_event_id,
					cur_record.lo_owner,
                    error_count);

                IF error_count = 0 THEN
                    -- no new errors and processed successfully
                    INSERT INTO gui.T_UI_ERROR_AUDIT (
						lo_event_id
						, lo_old_status
						, lo_new_status
						, lo_user_change
						, lo_time_change
					 )
					 SELECT
						cur_record.lo_event_id
						, cur_record.lo_error_status
						, 'S'
						, 'AUTO'
						, SYSDATE
					 FROM
						DUAL;

					UPDATE FDR.FR_LOG SET LO_ERROR_STATUS ='S' WHERE LO_EVENT_ID = cur_record.lo_event_id;
                    COMMIT;
                ELSE
                    -- new errors have been written to fr_log to replace this error
                    -- so close it

					INSERT INTO gui.T_UI_ERROR_AUDIT (
						lo_event_id
						, lo_old_status
						, lo_new_status
						, lo_user_change
						, lo_time_change
					 )
					 SELECT
						cur_record.lo_event_id
						, cur_record.lo_error_status
						, 'C'
						, 'AUTO'
						, SYSDATE
					 FROM
						DUAL;

					UPDATE FDR.FR_LOG SET LO_ERROR_STATUS ='C' WHERE LO_EVENT_ID = cur_record.lo_event_id;
                    COMMIT;
                END IF;
            ELSIF rec_status IN ('U') THEN
                -- exit
                RETURN;
            ELSIF rec_status IN ('E') THEN
                -- still in error so set to C update performed only if explicit aptitude error detected ttp707

				INSERT INTO gui.T_UI_ERROR_AUDIT (
						lo_event_id
						, lo_old_status
						, lo_new_status
						, lo_user_change
						, lo_time_change
					 )
					 SELECT
						cur_record.lo_event_id
						, cur_record.lo_error_status
						, 'C'
						, 'AUTO'
						, SYSDATE
					 FROM
						DUAL;

				UPDATE FDR.FR_LOG SET LO_ERROR_STATUS ='C' WHERE LO_EVENT_ID = cur_record.lo_event_id;
                COMMIT;
            ELSE
                -- Raise technical error reporting unrecognised event_status and report event_status. No updates to status made.
                fdr.Pr_Error(2, 'Unrecognised status: '||NVL(rec_status,'NULL'), 0, 'pg_ui_error_handler.check_resubmitted_errors', cur_record.lo_table_in_error_name, cur_record.lo_row_in_error_key_id, NULL, 'ERROR HANDLER GUI', 'PL/SQL', log_code, NULL, NULL, NULL, NULL, NULL, NULL, lpg);
            END IF;

    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        fdr.Pr_Error(2, 'Error occurred checking resubmitted errors: ' || SUBSTR(SQLERRM, 1, 220), 0, 'pg_ui_error_handler.check_resubmitted_errors', NULL, NULL, NULL, 'ERROR HANDLER GUI', 'PL/SQL', log_code, NULL, NULL, NULL, NULL, NULL, NULL, lpg);
END;

PROCEDURE check_source_table(
    event_id             IN NUMBER,
    table_in_error_name  IN VARCHAR2,
    row_in_error_key_id  IN NUMBER,
    owner     IN VARCHAR2,
	lpg IN NUMBER,
    rec_status           OUT VARCHAR2
) IS
-- PURPOSE:
--     This procedure checks the source table and returns the EVENT_STATUS for an error
-- NOTES:
--

    --cursor to retrieve the primary key column for the table_in_error - assumes this will always be a single column
    CURSOR cur_primary_key_col(tab_name VARCHAR2, tab_owner VARCHAR2) IS
        SELECT column_name
        FROM all_cons_columns
        WHERE
        UPPER(table_name) = UPPER(tab_name) AND
		UPPER(owner) = UPPER(tab_owner) AND
        constraint_name = (
            SELECT constraint_name
            FROM all_constraints
            WHERE
            UPPER(table_name) = UPPER(tab_name) AND
			UPPER(owner) = UPPER(tab_owner) AND
            constraint_type = 'P'
            )
			AND column_name != 'LPG_ID';

    pk_col        VARCHAR2(40);
    sql_str       VARCHAR2(800);
    log_code      VARCHAR2(240) := '';
    e_no_pk       EXCEPTION;
    v_table       VARCHAR2(80);
    v_msg         VARCHAR2(240);

BEGIN

        -- Get the primary key column name of the table in error
        OPEN cur_primary_key_col(table_in_error_name, owner);
        FETCH cur_primary_key_col INTO pk_col;
        CLOSE cur_primary_key_col;

        IF pk_col IS NULL THEN
            -- No primary key column retrieved, possible permission problem.
            -- If this is a standardisation error then it would normally be file based
            -- so in this case just ignore the error
            IF upper(owner) not in ('STN','STANDARDISATION') THEN
                v_table := table_in_error_name;
                RAISE e_no_pk;
            END IF;
        ELSE
            -- Build SQL to retrieve the event status of the EBE/BE row
            sql_str := 'SELECT EVENT_STATUS FROM '|| owner || '.' || table_in_error_name || ' WHERE ' || pk_col || ' = '|| row_in_error_key_id || ' AND LPG_ID = '||lpg;

            log_code := SUBSTR(sql_str, 1, 240);

            BEGIN

                EXECUTE IMMEDIATE sql_str INTO rec_status;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    fdr.Pr_Error(2, 'Error occurred checking source table errors: The resubmitted row data was not found in the table', 0, 'pg_ui_error_handler.check_source_table', table_in_error_name, row_in_error_key_id, NULL, 'ERROR HANDLER GUI', 'PL/SQL', event_id, NULL, NULL, NULL, NULL, NULL, NULL, lpg);
                WHEN OTHERS THEN
                    fdr.Pr_Error(2, 'Error occurred checking source table errors: ' || SUBSTR(SQLERRM, 1, 220), 0, 'pg_ui_error_handler.check_source_table', table_in_error_name, row_in_error_key_id, NULL, 'ERROR HANDLER GUI', 'PL/SQL', log_code, NULL, NULL, NULL, NULL, NULL, NULL, lpg);
            END;

        END IF;

EXCEPTION
    WHEN e_no_pk THEN
        ROLLBACK;
        v_msg := 'No primary key column retrieved for '|| v_table || ', possible permissions problem';
        fdr.Pr_Error(2, v_msg, 0, 'pg_ui_error_handler.check_source_table', table_in_error_name, row_in_error_key_id, NULL, 'ERROR HANDLER GUI', 'PL/SQL', log_code, NULL, NULL, NULL, NULL, NULL, NULL, lpg);
        RAISE_APPLICATION_ERROR(-20001, 'pg_ui_error_handler.check_source_table: '||v_msg);

    WHEN OTHERS THEN
        fdr.Pr_Error(2, 'Error occurred checking source table errors: ' || SUBSTR(SQLERRM, 1, 220), 0, 'pg_ui_error_handler.check_source_table', table_in_error_name, row_in_error_key_id, NULL, 'ERROR HANDLER GUI', 'PL/SQL', log_code, NULL, NULL, NULL, NULL, NULL, NULL, lpg);
END;

PROCEDURE check_for_new_errors(
          row_in_error_key_id  IN NUMBER,
          table_in_error_name  IN VARCHAR2,
          event_id             IN NUMBER,
		  owner     		   IN VARCHAR2,
          new_errors_count     OUT NUMBER
) IS

-- PURPOSE
--  This method checks the FR_LOG table for the occurrence of any new errors
--   triggered by the resubmission of the error with given event_id

    sql_str     VARCHAR2(500);
    log_code    VARCHAR2(240) := '';

BEGIN

    sql_str := 'SELECT COUNT(*) FROM FDR.FR_LOG ' ||
               ' WHERE ' ||
               '  LO_ERROR_STATUS = ''E'' AND ' ||
               ' LO_ROW_IN_ERROR_KEY_ID = '''
               || row_in_error_key_id ||'''AND LO_OWNER = '''|| owner ||''' AND LO_TABLE_IN_ERROR_NAME = ''' || table_in_error_name || ''' AND ' ||
               ' LO_EVENT_ID > ( ' ||
                              ' SELECT MAX(LO_EVENT_ID) FROM FDR.FR_LOG WHERE ' ||
                              ' LO_ERROR_STATUS = ''R'' AND ' ||
                              ' LO_ROW_IN_ERROR_KEY_ID = ''' || row_in_error_key_id || ''' AND ' ||
							  ' LO_OWNER = ''' || owner || ''' AND ' ||
                              ' LO_TABLE_IN_ERROR_NAME = ''' || table_in_error_name || ''' AND ' ||
                              ' LO_EVENT_ID = ' || event_id || ' ) ';

     log_code := substr(sql_str,1,240);

     EXECUTE IMMEDIATE sql_str INTO new_errors_count;

EXCEPTION
    WHEN OTHERS THEN
        fdr.Pr_Error(2, 'Error occurred checking for new errors: ' || SUBSTR(SQLERRM, 1, 220), 0, 'pg_ui_error_handler.check_for_new_errors', table_in_error_name, row_in_error_key_id, NULL, 'ERROR HANDLER GUI', 'PL/SQL', log_code, NULL, NULL, NULL, NULL, NULL, NULL);
END;

PROCEDURE archive(lpg IN NUMBER := 1)
-- PURPOSE:
--     This procedure marks any successfully handled errors (i.e. in LO_ERROR_STATUS of 'F', 'N', 'S')
--     to completed ('C').  Any transactions still in a state of resubmission ('R') should be
--     also marked as completed.
-- NOTES:
--     (1) This proc should be run at the end of the day as part of housekeeping
--     (2) Technical errors (LO_CATEGORY_ID = 0) with a status 'N' will not be marked as completed
--     (3) Transactions with the state 'R' at this stage should be those that have been
--         re-submitted, but failed again.  In this case a new error with status 'E' will be
--         raised, so these rows are redundant.
IS

    CURSOR cur_business_date IS
        SELECT gp_todays_bus_date
        FROM fdr.fr_global_parameter
        WHERE lpg_id = lpg;

    current_business_date    DATE;

BEGIN

    -- get current business date
    OPEN cur_business_date;
    FETCH cur_business_date INTO current_business_date;
    CLOSE cur_business_date;

    -- update fr_log
    UPDATE FDR.FR_LOG
    SET    LO_ERROR_STATUS = 'C'
    WHERE  LO_ERROR_STATUS IN ('N', 'S', 'R')
    AND    TRUNC(LO_TODAYS_BUS_DATE) <= current_business_date
    AND    LO_CATEGORY_ID = 1
    AND    LPG_ID = lpg;

    -- commit changes
    COMMIT;

END;

PROCEDURE autoresubmit_transactions(lpg IN NUMBER := 1, increment_retries IN CHAR := 'N')
-- PURPOSE:
--     This function is for the autoresubmission of transactions that have a status of 'E' or 'I' (Error or UnderInvestigation).
--     This will be called by the Batch process at the start of the Batch run.  The intent is that any transactions that haven't been fixed and resubmitted
--     during the day will be resubmitted by the batch process overnight.
--     If the error conditions still exist, then the transaction will be freshly written to the FR_LOG table for viewing on the
--     next business day.
-- NOTES:
-- (1) The transaction id (LO_ERROR_CLIENT_KEY_NO), the table in error (LO_TABLE_IN_ERROR_NAME) and the error date (LO_TODAYS_BUS_DATE)
--     are passed as parameters
-- (2) A success boolean (ie a CHAR(1)) is passed as an out parameter

-- retrieve all errors that have LO_ERROR_STATUS IN ('E','I', 'F')
-- and have CategoryId not 0 which is a technical error

-- the second parameter of the procedure is ignored (!), retries will not be increased

IS

  -- cursor to retrieve all table names for which is need to resubmit transactions by the batch process
   CURSOR cur_table_list(bus_date DATE) IS
      SELECT
         lo_table_in_error_name
         , lo_owner,
         min(lo_event_id) as min_lo_event_id
      FROM
         fdr.fr_log
      WHERE
         lo_category_id != 0
         AND lo_event_type_id != 0
         AND lo_error_status IN ('E', 'I', 'F')
         AND lo_error_client_key_no IS NOT NULL
         AND UPPER(lo_error_technology) = 'APTITUDE'
         AND lpg_id = lpg
      GROUP BY
         lo_table_in_error_name
         , lo_owner;

   -- cursor to retrieve the primary key column for the table_in_error - assumes this will always be a single column
   CURSOR cur_primary_key_col(tab_name VARCHAR2, tab_owner VARCHAR2) IS
      SELECT
         column_name
      FROM
         all_cons_columns
      WHERE
         UPPER(table_name) = UPPER(tab_name) AND
		 UPPER(owner) = UPPER(tab_owner)
         AND constraint_name = (
            SELECT
               constraint_name
            FROM
               all_constraints
            WHERE
               UPPER(table_name) = UPPER(tab_name) AND
			   UPPER(owner) = UPPER(tab_owner)
               AND constraint_type = 'P'
         )
         AND column_name != 'LPG_ID';

   next_table_in_error FDR.FR_LOG.LO_TABLE_IN_ERROR_NAME%TYPE;

   sql_str             VARCHAR2(2000);
   pk_col              VARCHAR2(40);
   tab_owner           VARCHAR2(20);
   set_clause          VARCHAR2(2000) := '';
   update_conditions   VARCHAR2(2000) := '';
   rows_to_update      VARCHAR2(2000) := '';
   v_drop_errlog       VARCHAR2(50);
   v_create_errlog     VARCHAR2(200);
   v_errlog_table      VARCHAR2(30);
   v_table_check       NUMBER(1,0);
   v_count_errors      NUMBER(18,0);
   min_log_id          NUMBER(18,0);

   log_code            VARCHAR2(2000)  := '';

   bus_date            DATE;

   refCursorValue      SYS_REFCURSOR;
   v_id_val            VARCHAR2(100);
   v_error_msg         VARCHAR2(2000);

   e_bad_lpg_id        EXCEPTION;
   e_no_pk             EXCEPTION;
   v_table             VARCHAR2(80);
   v_msg               VARCHAR2(1000);

BEGIN

   SELECT
      MAX(gp_todays_bus_date)
   INTO
      bus_date
   FROM
      fdr.fr_global_parameter
   WHERE
      lpg_id = lpg;

   IF(bus_date IS NULL) THEN
      RAISE e_bad_lpg_id;
   END IF;

   -- retrive table names with logged errors
   OPEN cur_table_list(bus_date);
   LOOP


      FETCH cur_table_list
      INTO  next_table_in_error, tab_owner, min_log_id;

      EXIT WHEN cur_table_list%NOTFOUND;

      -- and the primary key column name of the hopper in error
      OPEN cur_primary_key_col(next_table_in_error, tab_owner);
         FETCH cur_primary_key_col INTO pk_col;
      CLOSE cur_primary_key_col;

      IF pk_col IS NULL THEN
         --if this is standardisation processing then the source may be a file
         --in this case ignore this error and leave the error unchanged.
         IF UPPER(tab_owner) NOT IN ('STN','STANDARDISATION') THEN
            -- no primary key column retrieved, possible permission problem.
            v_table := next_table_in_error;
            RAISE e_no_pk;
         END IF;
      END IF;

      -- build set clause
      set_clause := ' event_status = ''U'' ';

      -- maximum length of table name is 30
      v_errlog_table := SUBSTR('err$_' || next_table_in_error, 1, 30);
      v_table_check := 0;

      -- check if errlog table alredy exists and then drop
      SELECT COUNT(1) INTO v_table_check FROM user_tables WHERE UPPER(table_name) = UPPER(v_errlog_table);
      IF v_table_check > 0 THEN
         v_drop_errlog := 'drop table '|| v_errlog_table;
         EXECUTE IMMEDIATE v_drop_errlog;
      END IF;

      -- create errlog table
      v_create_errlog := 'begin DBMS_ERRLOG.create_error_log (dml_table_name =>'''|| tab_owner || '.' || next_table_in_error || ''', err_log_table_owner =>''GUI'' ); end;';
      EXECUTE IMMEDIATE v_create_errlog;

      -- build and execute SQL to update the event status of the hopper row to 'U' for re-processing
      sql_str :=
         'MERGE INTO ' || tab_owner || '.' || next_table_in_error || ' USING (
            SELECT
               '|| next_table_in_error || '.' || pk_col || '
            FROM
               ' || tab_owner || '.' || next_table_in_error || '
               JOIN fdr.fr_log ON ' || next_table_in_error || '.' || pk_col || ' = fr_log.lo_row_in_error_key_id  AND ' || next_table_in_error || '.lpg_id = fr_log.lpg_id
            WHERE
               fr_log.lo_event_id >= ' || min_log_id || '
               AND UPPER(fr_log.lo_table_in_error_name) = UPPER(''' || next_table_in_error || ''')
               AND fr_log.lo_category_id != 0
               AND fr_log.lo_event_type_id != 0
               AND fr_log.lo_error_status IN (''E'', ''I'', ''F'')
               AND ' || next_table_in_error || '.event_status = ''E''
               AND fr_log.lo_error_client_key_no IS NOT NULL
               AND UPPER(fr_log.lo_error_technology) = ''APTITUDE''
               AND fr_log.lpg_id = ' || lpg || '
            GROUP BY '
               || next_table_in_error || '.' || pk_col || ') stan_raw
         ON (' || next_table_in_error || '.' || pk_col || ' = stan_raw.' || pk_col || ' AND ' || next_table_in_error || '.lpg_id = ' || lpg || ')
         WHEN MATCHED THEN UPDATE SET ' || next_table_in_error || '.event_status = ''U''
         LOG ERRORS INTO ' || v_errlog_table || '(''MERGE'') REJECT LIMIT UNLIMITED';

      log_code := SUBSTR(' : ' || sql_str, 1, 240);

      IF pk_col IS NOT NULL THEN
         BEGIN
            EXECUTE IMMEDIATE sql_str;
         END;
      END IF;

      -- update the status of ech row in the error table that was succesfully resubmitted (and log the change)
      -- log changes to audit table
      sql_str := '
         INSERT INTO gui.T_UI_ERROR_AUDIT (
            lo_event_id
            , lo_old_status
            , lo_new_status
            , lo_user_change
            , lo_time_change
         )
         SELECT
            lo_event_id
            , lo_error_status
            , ''R''
            , ''AUTO''
            , SYSDATE
         FROM
            fdr.fr_log
            JOIN ' || tab_owner || '.' || next_table_in_error || ' ON fr_log.lo_row_in_error_key_id = '|| next_table_in_error || '.' || pk_col || ' AND ' || next_table_in_error || '.lpg_id = fr_log.lpg_id
         WHERE
            fr_log.lo_event_id >= ' || min_log_id || '
            AND UPPER(fr_log.lo_table_in_error_name) = UPPER(''' || next_table_in_error || ''')
            AND fr_log.lo_category_id != 0
            AND fr_log.lo_event_type_id != 0
            AND fr_log.lo_error_status IN (''E'', ''I'', ''F'')
            AND fr_log.lo_error_client_key_no IS NOT NULL
            AND UPPER(fr_log.lo_error_technology) = ''APTITUDE''
            AND fr_log.lpg_id = ' || lpg || '
            AND ' || next_table_in_error || '.event_status = ''U''';


      EXECUTE IMMEDIATE sql_str;

      -- update succesfully resubmitted rows in the fr_log table
      sql_str := '
         UPDATE (
            SELECT
               fr_log.lo_event_id,
               fr_log.lo_error_status
            FROM
               fdr.fr_log
               JOIN ' || tab_owner || '.' || next_table_in_error || ' ON fr_log.lo_row_in_error_key_id = '|| next_table_in_error || '.' || pk_col || ' AND ' || next_table_in_error || '.lpg_id = fr_log.lpg_id
            WHERE
               fr_log.lo_event_id >= ' || min_log_id || '
               AND UPPER(fr_log.lo_table_in_error_name) = UPPER(''' || next_table_in_error || ''')
               AND fr_log.lo_category_id != 0
               AND fr_log.lo_event_type_id != 0
               AND fr_log.lo_error_status IN (''E'', ''I'', ''F'')
               AND fr_log.lo_error_client_key_no IS NOT NULL
               AND UPPER(fr_log.lo_error_technology) = ''APTITUDE''
               AND fr_log.lpg_id = ' || lpg || '
               AND ' || next_table_in_error || '.event_status = ''U''
            ) log_rows
         SET lo_error_status = DECODE(''' || pk_col || ''', NULL, ''N'', ''R'')';


      EXECUTE IMMEDIATE sql_str;

      -- save errors occured during resubmitting transations
      sql_str := '
         SELECT '
            || pk_col || '  AS id_val,
            ora_err_mesg$ AS error_msg
         FROM '
            || v_errlog_table;

      OPEN refCursorValue FOR sql_str ;
         LOOP
         FETCH refCursorValue INTO v_id_val, v_error_msg;
         EXIT WHEN refCursorValue%NOTFOUND;
            FDR.PR_ERROR(1, 'Error resubmitting transactions in ' || next_table_in_error || ': ' || v_error_msg, 9, 'PG_UI_ERROR_HANDLER.autoresubmit_transactions', next_table_in_error, v_id_val, null, null,'PL/SQL', null, null, null, null, null, null, lpg);
         END LOOP;
      CLOSE refCursorValue;


   END LOOP;

   CLOSE cur_table_list;

   COMMIT;

   EXCEPTION
      WHEN e_bad_lpg_id THEN
         ROLLBACK;
         v_msg := 'LPG_ID not found in FR_GLOBAL_PARAMETER table';
         fdr.Pr_Error(2, v_msg, 0, 'pg_ui_error_handler.autoresubmit_transactions', NULL, NULL, NULL, 'ERROR HANDLER GUI', 'PL/SQL', lpg, NULL, NULL, NULL, NULL, NULL, NULL, lpg);
         RAISE_APPLICATION_ERROR(-20001, 'pg_ui_error_handler.autoresubmit_transactions: '||v_msg);

      WHEN e_no_pk THEN
         ROLLBACK;
         v_msg := 'No primary key column retrieved for '|| v_table || ', possible permissions problem';
         fdr.Pr_Error(2, v_msg, 0, 'pg_ui_error_handler.autoresubmit_transactions', NULL, NULL, NULL, 'ERROR HANDLER GUI', 'PL/SQL', log_code, NULL, NULL, NULL, NULL, NULL, NULL, lpg);
         RAISE_APPLICATION_ERROR(-20001, 'pg_ui_error_handler.autoresubmit_transactions: '||v_msg);

      WHEN OTHERS THEN
         ROLLBACK;
         fdr.Pr_Error(2, 'Error occurred resubmitting transaction: ' || SUBSTR(SQLERRM, 1, 240), 0, 'pg_ui_error_handler.autoresubmit_transactions', NULL, NULL, NULL, 'ERROR HANDLER GUI', 'PL/SQL', log_code, NULL, NULL, NULL, NULL, NULL, NULL, lpg);
         RAISE;

END;

END PG_UI_ERROR_HANDLER;
/
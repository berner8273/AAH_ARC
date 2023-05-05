CREATE OR REPLACE PROCEDURE FDR."PR_STAN_RAW_GENERAL_CODES_LD" (
  a_lpg_id      IN   fr_global_parameter.lpg_id%TYPE := 1,
  a_code_type   IN   fr_stan_raw_general_codes.srgc_gct_code_type_id%TYPE := null,
  a_processed_count OUT NUMBER,
  a_success_count OUT NUMBER,
  a_failed_count OUT NUMBER
)
AS
--
--PR_STAN_RAW_GEN_CODES_LD  (Procedure)
--
--  Dependencies:
--FR_STAN_RAW_GENERAL_CODES(Table)
--
   v_active                 fr_stan_raw_general_codes.srgc_active%TYPE;
   v_general_code_id        fr_general_codes.gc_general_code_id%TYPE;
   v_general_code_type_id   fr_general_codes.gc_gct_code_type_id%TYPE;
   v_sqlcode                NUMBER (12);
   v_sqlerrm                fr_log.lo_event_text%TYPE;
   v_cur_srgc_id            NUMBER (12);
   v_cur_code_type_id        fr_stan_raw_general_codes.srgc_gct_code_type_id%TYPE;
   v_msg                    VARCHAR2 (4000);
   v_event_status           fr_stan_raw_general_codes.event_status%TYPE;
   s_proc_name              VARCHAR2 (30)       := 'PR_STAN_RAW_GENERAL_CODES_LD';
   s_target_table           VARCHAR2 (30)      := 'FR_STAN_RAW_GENERAL_CODES';

   -- Cursor to retrieve ID of record being updated/deleted
   CURSOR cur_gen_code_id (
      p_gc_general_code_id        IN   VARCHAR2,
      p_gc_general_code_type_id   IN   VARCHAR2
   )
   IS
      SELECT p_gc_general_code_id, p_gc_general_code_type_id, gc_active
        FROM fr_general_codes
       WHERE gc_general_code_id = p_gc_general_code_id
         AND gc_gct_code_type_id = p_gc_general_code_type_id;

   -- Cursor to loop around all records to process in the hopper for the specified genral code
   CURSOR cur_process_records
   IS
      SELECT *
        FROM fr_stan_raw_general_codes
       WHERE lpg_id = a_lpg_id
--         AND (srgc_gct_code_type_id = a_code_type OR a_code_type is null)
         AND (srgc_gct_code_type_id like a_code_type||'%')
         AND event_status = 'U';
BEGIN

  a_success_count:=0;
  a_failed_count:=0;
   

   FOR v_process_records IN cur_process_records
   LOOP
   BEGIN
      v_cur_srgc_id := v_process_records.srgc_general_code_id;
      v_cur_code_type_id:=v_process_records.srgc_gct_code_type_id;

      -- Check the flag is set to I, U or D
      IF NOT (   Nvl(v_process_records.srgc_active,' ') = 'A'
              OR Nvl(v_process_records.srgc_active,' ') = 'I'
             )
      THEN
         -- Invalid flag, so raise error
         v_msg := 'Invalid Insert/Update/Delete Flag';
         pr_error (1,
                   v_msg,
                   1,
                   s_proc_name,
                   s_target_table,
                   v_process_records.srgc_general_code_id,
                   'srgc_active',
                   'FDR_STATIC',
                   'PL/SQL',
                   v_process_records.srgc_active,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   a_lpg_id
                  );
         v_event_status := 'E';
         --Custom update begin  on 4/30/2020 to improve performance
          UPDATE fr_stan_raw_general_codes
         SET event_status = v_event_status
       WHERE (srgc_gct_code_type_id = v_cur_code_type_id OR v_cur_code_type_id IS NULL) AND srgc_general_code_id = v_cur_srgc_id;
       commit;
        --Custom update end on 4/30/2020 to improve performance

      -- If the flag is set to 'A' for insert/update then check to see if the record exists.
      -- If it doesn't then insert it in the FDR table.
      -- If it does, update it.
      ELSIF v_process_records.srgc_active = 'A'
      THEN
         -- Check for existence of general code
         IF cur_gen_code_id%isopen THEN
          CLOSE cur_gen_code_id;
         END IF;

         OPEN cur_gen_code_id (v_process_records.srgc_client_code,
                               v_process_records.srgc_gct_code_type_id
                              );

             FETCH cur_gen_code_id
              INTO v_general_code_id, v_general_code_type_id, v_active;

             IF cur_gen_code_id%NOTFOUND
             THEN
                -- Insert the row into the FDR table
                INSERT INTO fr_general_codes
                            (gc_general_code_id,
                             gc_gct_code_type_id,
                             gc_client_code,
                             gc_client_text1,
                             gc_client_text2,
                             gc_client_text3,
                             gc_client_text4,
                             gc_client_text5,
                             gc_client_text6,
                             gc_client_text7,
                             gc_client_text8,
                             gc_client_text9,
                             gc_client_text10,
                             gc_description, gc_active,
                             gc_input_by, gc_auth_by, gc_auth_status,
                             gc_input_time,
                             gc_valid_from,
                             gc_valid_to,
                             gc_delete_time
                            )
                     -- replace clicode with raw id
                VALUES      (v_process_records.srgc_client_code,
                             v_process_records.srgc_gct_code_type_id,
                             v_process_records.srgc_client_code,
                             v_process_records.srgc_client_text1,
                             v_process_records.srgc_client_text2,
                             v_process_records.srgc_client_text3,
                             v_process_records.srgc_client_text4,
                             v_process_records.srgc_client_text5,
                             v_process_records.srgc_client_text6,
                             v_process_records.srgc_client_text7,
                             v_process_records.srgc_client_text8,
                             v_process_records.srgc_client_text9,
                             v_process_records.srgc_client_text10,
                             v_process_records.srgc_description, 'A',
                             NVL(v_process_records.srgc_input_by,'1'),
                             NVL(v_process_records.srgc_auth_by,'1'),
                             NVL(v_process_records.srgc_auth_status,'A'),
                             SYSDATE,
                             NVL (v_process_records.srgc_valid_from, SYSDATE),
                             NVL (v_process_records.srgc_valid_to, TO_DATE('31-12-2099','dd-mm-yyyy')),
                             NULL
                            );
             ELSE
                 -- Update the row in the related FDR table
                 UPDATE fr_general_codes
                    SET gc_client_text1 = v_process_records.srgc_client_text1,
                        gc_client_text2 = v_process_records.srgc_client_text2,
                        gc_client_text3 = v_process_records.srgc_client_text3,
                        gc_client_text4 = v_process_records.srgc_client_text4,
                        gc_client_text5 = v_process_records.srgc_client_text5,
                        gc_client_text6 = v_process_records.srgc_client_text6,
                        gc_client_text7 = v_process_records.srgc_client_text7,
                        gc_client_text8 = v_process_records.srgc_client_text8,
                        gc_client_text9 = v_process_records.srgc_client_text9,
                        gc_client_text10 = v_process_records.srgc_client_text10,
                        gc_description = v_process_records.srgc_description,
                        gc_active = 'A',
                        gc_input_by = NVL(v_process_records.srgc_input_by,'1'),
                        gc_auth_by = NVL(v_process_records.srgc_auth_by,'1'),
                        gc_auth_status = NVL(v_process_records.srgc_auth_status,'A'),
                        gc_input_time = SYSDATE,
                        gc_valid_from =
                                      NVL (v_process_records.srgc_valid_from, SYSDATE),
                        gc_valid_to =
                                  NVL (v_process_records.srgc_valid_to, TO_DATE('31-12-2099','dd-mm-yyyy')),
                        gc_delete_time = NULL
                  WHERE gc_general_code_id = v_process_records.srgc_client_code
                    AND gc_gct_code_type_id = v_process_records.srgc_gct_code_type_id;
             END IF;
             v_event_status := 'P';
         CLOSE cur_gen_code_id;

      ELSIF v_process_records.srgc_active = 'I'
      THEN
         -- Logical Delete
         -- Update the Active column of the row in the FDR table to be 'I' (= 'Inactive')
         UPDATE fr_general_codes
            SET gc_active = 'I',
                gc_input_by = NVL(v_process_records.srgc_input_by,'1'),
                gc_auth_by = NVL(v_process_records.srgc_auth_by,'1'),
                gc_auth_status = NVL(v_process_records.srgc_auth_status,'A'),
                gc_input_time = SYSDATE,
                gc_valid_from =
                              NVL (v_process_records.srgc_valid_from, SYSDATE),
                gc_valid_to =
                          NVL (v_process_records.srgc_valid_to, SYSDATE),
                gc_delete_time = SYSDATE
          WHERE gc_general_code_id = v_process_records.srgc_client_code
            AND gc_gct_code_type_id = v_process_records.srgc_gct_code_type_id;

         v_event_status := 'P';

      END IF;
--Custom update begin  on 4/30/2020 to improve performance
      --UPDATE fr_stan_raw_general_codes
       --  SET event_status = v_event_status
       --WHERE srgc_general_code_id = v_cur_srgc_id;
       --Custom update end  on 4/30/2020 to improve performance
   EXCEPTION
   -- basic exception handler
   WHEN OTHERS
   THEN

      UPDATE fr_stan_raw_general_codes
         SET event_status = 'E'
       WHERE (srgc_gct_code_type_id = v_cur_code_type_id OR v_cur_code_type_id IS NULL) AND srgc_general_code_id = v_cur_srgc_id;

      -- log error to log table
      v_sqlcode := SQLCODE;
      v_sqlerrm := SUBSTR (SQLERRM, 1, 1000);

      INSERT INTO fr_log
                  (lo_event_type_id, lo_error_status, lo_category_id, lo_event_datetime,
                   lo_table_in_error_name, lo_row_in_error_key_id,lo_error_client_key_no,
                   lo_error_value, lo_event_text,LPG_ID, LO_PROCESSING_STAGE
                   ,lo_error_technology,LO_ERROR_RULE_IDENT
                  )
           VALUES (1, 'E', 0, SYSDATE,
                   'FR_STAN_RAW_GENERAL_CODES', v_cur_srgc_id,v_cur_srgc_id || '~' || v_cur_code_type_id,
                   TO_CHAR (v_sqlcode), v_sqlerrm,a_lpg_id,'FDR_STATIC'
                   , 'PL/SQL',s_proc_name
                  );

      v_event_status := 'E';
      COMMIT;
   END;

   IF v_event_status = 'P' THEN
       a_success_count:=a_success_count+1;
    ELSIF
      v_event_status = 'E' THEN
       a_failed_count:=a_failed_count+1;
    END IF;

   END LOOP;
   --Custom update begin  on 4/30/2020 to improve performance
    UPDATE fr_stan_raw_general_codes
         SET event_status = 'P'
       WHERE event_status = 'U' AND srgc_gct_code_type_id like a_code_type||'%';
       
--Custom update end  on 4/30/2020 to improve performance

   a_processed_count := a_success_count + a_failed_count;

   COMMIT;
END;
/
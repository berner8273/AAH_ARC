  CREATE OR REPLACE PROCEDURE "FDR"."PR_STAN_RAW_GENERAL_LOOKUP_LD" (
  a_lpg_id      IN   fr_global_parameter.lpg_id%TYPE := 1,
  a_code_type   IN   fr_stan_raw_general_lookup.srlk_lkt_lookup_type_code%TYPE:= '0',
  a_processed_count OUT NUMBER,
  a_success_count OUT NUMBER,
  a_failed_count OUT NUMBER
)
AS
--
--PR_STAN_RAW_GEN_LOOKUP_LD  (Procedure)
--
--  Dependencies:
--FR_STAN_RAW_GENERAL_LOOKUP (Table)
--
   v_active                     fr_general_lookup.lk_active%TYPE;
   v_match_key1                 fr_general_lookup.lk_match_key1%TYPE;
   v_match_key2                 fr_general_lookup.lk_match_key2%TYPE;
   v_match_key3                 fr_general_lookup.lk_match_key3%TYPE;
   v_match_key4                 fr_general_lookup.lk_match_key4%TYPE;
   v_match_key5                 fr_general_lookup.lk_match_key5%TYPE;
   v_match_key6                 fr_general_lookup.lk_match_key6%TYPE;
   v_match_key7                 fr_general_lookup.lk_match_key7%TYPE;
   v_match_key8                 fr_general_lookup.lk_match_key8%TYPE;
   v_match_key9                 fr_general_lookup.lk_match_key9%TYPE;
   v_match_key10                fr_general_lookup.lk_match_key10%TYPE;
   v_match_key11                 fr_general_lookup.lk_match_key11%TYPE;
   v_match_key12                 fr_general_lookup.lk_match_key12%TYPE;
   v_match_key13                 fr_general_lookup.lk_match_key13%TYPE;
   v_match_key14                 fr_general_lookup.lk_match_key14%TYPE;
   v_match_key15                 fr_general_lookup.lk_match_key15%TYPE;
   v_match_key16                 fr_general_lookup.lk_match_key16%TYPE;
   v_match_key17                 fr_general_lookup.lk_match_key17%TYPE;
   v_match_key18                 fr_general_lookup.lk_match_key18%TYPE;
   v_match_key19                 fr_general_lookup.lk_match_key19%TYPE;
   v_match_key20                fr_general_lookup.lk_match_key20%TYPE;
   v_general_lookup_type_code   fr_general_lookup.lk_lkt_lookup_type_code%TYPE;
   v_general_lookup_key_id      fr_general_lookup.lk_lookup_key_id%TYPE;
   v_sqlcode                    NUMBER (12);
   v_sqlerrm                    fr_log.lo_event_text%TYPE;
   v_cur_srlk_id                NUMBER (12);
   v_msg                        VARCHAR2 (4000);
   v_event_status               fr_stan_raw_general_lookup.event_status%TYPE;
   s_proc_name                  VARCHAR2 (30)
                                           := 'PR_STAN_RAW_GENERAL_LOOKUP_LD';
   s_target_table               VARCHAR2 (30) := 'FR_STAN_RAW_GENERAL_LOOKUP';
    v_owner 					VARCHAR2(20) := 'FDR';



   -- Cursor to retrieve ID of record being updated/deleted
   CURSOR cur_gen_lookup_id (
      p_gl_type_code     IN   VARCHAR2,
      p_gl_match_key1    IN   VARCHAR2,
      p_gl_match_key2    IN   VARCHAR2,
      p_gl_match_key3    IN   VARCHAR2,
      p_gl_match_key4    IN   VARCHAR2,
      p_gl_match_key5    IN   VARCHAR2,
      p_gl_match_key6    IN   VARCHAR2,
      p_gl_match_key7    IN   VARCHAR2,
      p_gl_match_key8    IN   VARCHAR2,
      p_gl_match_key9    IN   VARCHAR2,
      p_gl_match_key10   IN   VARCHAR2,
      p_gl_match_key11    IN   VARCHAR2,
      p_gl_match_key12    IN   VARCHAR2,
      p_gl_match_key13    IN   VARCHAR2,
      p_gl_match_key14    IN   VARCHAR2,
      p_gl_match_key15    IN   VARCHAR2,
      p_gl_match_key16    IN   VARCHAR2,
      p_gl_match_key17    IN   VARCHAR2,
      p_gl_match_key18    IN   VARCHAR2,
      p_gl_match_key19    IN   VARCHAR2,
      p_gl_match_key20   IN   VARCHAR2,
	  p_gl_effective_from IN DATE
   )
   IS
      SELECT lk_lookup_key_id, lk_active
        FROM fr_general_lookup
       WHERE lk_lkt_lookup_type_code = p_gl_type_code
         AND lk_match_key1 = p_gl_match_key1
         AND lk_match_key2 = p_gl_match_key2
         AND lk_match_key3 = p_gl_match_key3
         AND lk_match_key4 = p_gl_match_key4
         AND lk_match_key5 = p_gl_match_key5
         AND lk_match_key6 = p_gl_match_key6
         AND lk_match_key7 = p_gl_match_key7
         AND lk_match_key8 = p_gl_match_key8
         AND lk_match_key9 = p_gl_match_key9
         AND lk_match_key10 = p_gl_match_key10
         AND lk_match_key11 = p_gl_match_key11
         AND lk_match_key12 = p_gl_match_key12
         AND lk_match_key13 = p_gl_match_key13
         AND lk_match_key14 = p_gl_match_key14
         AND lk_match_key15 = p_gl_match_key15
         AND lk_match_key16 = p_gl_match_key16
         AND lk_match_key17 = p_gl_match_key17
         AND lk_match_key18 = p_gl_match_key18
         AND lk_match_key19 = p_gl_match_key19
         AND lk_match_key20 = p_gl_match_key20
		 AND  lk_effective_from =  p_gl_effective_from;

   -- Cursor to loop around all records to process in the hopper for the specified genral code
   CURSOR cur_process_records
   IS
      SELECT 	srlk_raw_lookup_id,
				srlk_lkt_lookup_type_code,
				srlk_match_key1,
				nvl(srlk_match_key2, 'ND~') as srlk_match_key2,  
				nvl(srlk_match_key3, 'ND~') as srlk_match_key3,  
				nvl(srlk_match_key4, 'ND~') as srlk_match_key4,  
				nvl(srlk_match_key5, 'ND~') as srlk_match_key5,  
				nvl(srlk_match_key6, 'ND~') as srlk_match_key6,  
				nvl(srlk_match_key7, 'ND~') as srlk_match_key7,  
				nvl(srlk_match_key8, 'ND~') as srlk_match_key8,  
				nvl(srlk_match_key9, 'ND~') as srlk_match_key9,  
				nvl(srlk_match_key10, 'ND~') as srlk_match_key10,  
				nvl(srlk_match_key11, 'ND~') as srlk_match_key11,  
				nvl(srlk_match_key12, 'ND~') as srlk_match_key12,  
				nvl(srlk_match_key13, 'ND~') as srlk_match_key13,  
				nvl(srlk_match_key14, 'ND~') as srlk_match_key14,  
				nvl(srlk_match_key15, 'ND~') as srlk_match_key15,  
				nvl(srlk_match_key16, 'ND~') as srlk_match_key16,  
				nvl(srlk_match_key17, 'ND~') as srlk_match_key17,  
				nvl(srlk_match_key18, 'ND~') as srlk_match_key18,  
				nvl(srlk_match_key19, 'ND~') as srlk_match_key19,  
				nvl(srlk_match_key20, 'ND~') as srlk_match_key20,  
				srlk_lookup_value1,
				srlk_lookup_value2,
				srlk_lookup_value3,
				srlk_lookup_value4,
				srlk_lookup_value5,
				srlk_lookup_value6,
				srlk_lookup_value7,
				srlk_lookup_value8,
				srlk_lookup_value9,
				srlk_lookup_value10,
				srlk_lookup_value11,
				srlk_lookup_value12,
				srlk_lookup_value13,
				srlk_lookup_value14,
				srlk_lookup_value15,
				srlk_lookup_value16,
				srlk_lookup_value17,
				srlk_lookup_value18,
				srlk_lookup_value19,
				srlk_lookup_value20,
				srlk_one,
				srlk_input_by, 
				srlk_input_time, 
				srlk_lk_auth_by,
				srlk_lk_auth_status,
				srlk_lk_valid_from, 
				srlk_lk_valid_to, 
				srlk_active, 
				arrival_time, 
				srlk_event_date,
				splk_retry_date, 
				event_error_string, 
				event_status, 
				message_id,
				process_id, 
				remitting_system_id, 
				sub_system_id, 
				lpg_id, 
				srlk_effective_from, 
				srlk_effective_to
        FROM fr_stan_raw_general_lookup
       WHERE lpg_id = a_lpg_id
         AND (srlk_lkt_lookup_type_code = a_code_type OR '0' = a_code_type)
         AND event_status = 'U';


BEGIN

  a_success_count:=0;
  a_failed_count:=0;

   FOR v_process_records IN cur_process_records
   LOOP
   BEGIN
      v_cur_srlk_id := v_process_records.srlk_raw_lookup_id;

      -- Check the flag is set to I, U or D
      IF NOT (   NVL (v_process_records.srlk_active, ' ') = 'A'
              OR NVL (v_process_records.srlk_active, ' ') = 'I'
             )
      THEN
         -- Invalid flag, so raise error
         v_msg := 'SRLK_ACTIVE should be either A or I';
         pr_error (
				   1,
                   v_msg,
                   1,
                   s_proc_name,
                   s_target_table,
                   v_process_records.srlk_raw_lookup_id,
                   'SRLK_ACTIVE',
                   'FDR_STATIC',
                   'PL/SQL',
                   v_process_records.srlk_active,
                   NULL,
                   NULL,
                   NULL,
				   NULL,
                   v_process_records.srlk_raw_lookup_id,
                   NULL,
                   a_lpg_id,
                   v_owner
                  );
         v_event_status := 'E';
      -- If the flag is set to 'I' for insert then check to see if the record exists.
      -- If it doesn't then insert it in the FDR table.
      -- If it does, check to see if it is Active - if not then make Active. If it does exist, and is
      -- already marked as active, then report as error.
      -- else if it is set to 'U' for update, then update the FDR table record only.
      ELSIF v_process_records.srlk_active = 'A'
      THEN
         -- Check for existence of general code
         OPEN cur_gen_lookup_id (v_process_records.srlk_lkt_lookup_type_code,
                                 v_process_records.srlk_match_key1,
                                 v_process_records.srlk_match_key2,
                                 v_process_records.srlk_match_key3,
                                 v_process_records.srlk_match_key4,
                                 v_process_records.srlk_match_key5,
                                 v_process_records.srlk_match_key6,
                                 v_process_records.srlk_match_key7,
                                 v_process_records.srlk_match_key8,
                                 v_process_records.srlk_match_key9,
                                 v_process_records.srlk_match_key10,
                                 v_process_records.srlk_match_key11,
                                 v_process_records.srlk_match_key12,
                                 v_process_records.srlk_match_key13,
                                 v_process_records.srlk_match_key14,
                                 v_process_records.srlk_match_key15,
                                 v_process_records.srlk_match_key16,
                                 v_process_records.srlk_match_key17,
                                 v_process_records.srlk_match_key18,
                                 v_process_records.srlk_match_key19,
                                 v_process_records.srlk_match_key20,
								 v_process_records.srlk_effective_from
                                );

         FETCH cur_gen_lookup_id
          INTO v_general_lookup_key_id, v_active;

         IF cur_gen_lookup_id%NOTFOUND
         THEN
            -- Insert the row into the FDR table
            INSERT INTO fr_general_lookup
                        (lk_lookup_key_id,
                         lk_lkt_lookup_type_code,
                         lk_match_key1,
                         lk_match_key2,
                         lk_match_key3,
                         lk_match_key4,
                         lk_match_key5,
                         lk_match_key6,
                         lk_match_key7,
                         lk_match_key8,
                         lk_match_key9,
                         lk_match_key10,
                         lk_match_key11,
                         lk_match_key12,
                         lk_match_key13,
                         lk_match_key14,
                         lk_match_key15,
                         lk_match_key16,
                         lk_match_key17,
                         lk_match_key18,
                         lk_match_key19,
                         lk_match_key20,
                         lk_lookup_value1,
                         lk_lookup_value2,
                         lk_lookup_value3,
                         lk_lookup_value4,
                         lk_lookup_value5,
                         lk_lookup_value6,
                         lk_lookup_value7,
                         lk_lookup_value8,
                         lk_lookup_value9,
                         lk_lookup_value10,
                         lk_lookup_value11,
                         lk_lookup_value12,
                         lk_lookup_value13,
                         lk_lookup_value14,
                         lk_lookup_value15,
                         lk_lookup_value16,
                         lk_lookup_value17,
                         lk_lookup_value18,
                         lk_lookup_value19,
                         lk_lookup_value20, lk_active,
                         lk_input_by, lk_auth_by, lk_auth_status,
                         lk_input_time,
                         lk_valid_from,
                         lk_valid_to,
                         lk_delete_time,
						 lpg_id,
						 lk_effective_from,
                         lk_effective_to,
						 LK_SOURCE_EVENT_ID
                        )
                 -- replace clicode with raw id
            VALUES      (v_process_records.srlk_raw_lookup_id,
                         v_process_records.srlk_lkt_lookup_type_code,
                         v_process_records.srlk_match_key1,
                         v_process_records.srlk_match_key2,
                         v_process_records.srlk_match_key3,
                         v_process_records.srlk_match_key4,
                         v_process_records.srlk_match_key5,
                         v_process_records.srlk_match_key6,
                         v_process_records.srlk_match_key7,
                         v_process_records.srlk_match_key8,
                         v_process_records.srlk_match_key9,
                         v_process_records.srlk_match_key10,
                         v_process_records.srlk_match_key11,
                         v_process_records.srlk_match_key12,
                         v_process_records.srlk_match_key13,
                         v_process_records.srlk_match_key14,
                         v_process_records.srlk_match_key15,
                         v_process_records.srlk_match_key16,
                         v_process_records.srlk_match_key17,
                         v_process_records.srlk_match_key18,
                         v_process_records.srlk_match_key19,
                         v_process_records.srlk_match_key20,
                         v_process_records.srlk_lookup_value1,
                         v_process_records.srlk_lookup_value2,
                         v_process_records.srlk_lookup_value3,
                         v_process_records.srlk_lookup_value4,
                         v_process_records.srlk_lookup_value5,
                         v_process_records.srlk_lookup_value6,
                         v_process_records.srlk_lookup_value7,
                         v_process_records.srlk_lookup_value8,
                         v_process_records.srlk_lookup_value9,
                         v_process_records.srlk_lookup_value10,
                         v_process_records.srlk_lookup_value11,
                         v_process_records.srlk_lookup_value12,
                         v_process_records.srlk_lookup_value13,
                         v_process_records.srlk_lookup_value14,
                         v_process_records.srlk_lookup_value15,
                         v_process_records.srlk_lookup_value16,
                         v_process_records.srlk_lookup_value17,
                         v_process_records.srlk_lookup_value18,
                         v_process_records.srlk_lookup_value19,
                         v_process_records.srlk_lookup_value20, 'A',
						 NVL(v_process_records.srlk_input_by,'Client Static'),
						 NVL(v_process_records.srlk_lk_auth_by,'Client Static'),
						 NVL(v_process_records.srlk_lk_auth_status,'A'),
                         SYSDATE,
                         NVL (v_process_records.srlk_lk_valid_from, SYSDATE),
                         NVL (v_process_records.srlk_lk_valid_to,TO_DATE('31-12-2099','dd-mm-yyyy')),
                         NULL, v_process_records.lpg_id,
						  v_process_records.srlk_effective_from,
                          v_process_records.srlk_effective_to,
						  v_process_records.srlk_raw_lookup_id
                        );

            v_event_status := 'P';
         ELSE
            -- Record does already exist
            -- If the record is currently inactive
               -- update the existing record to be active
                UPDATE fr_general_lookup
				SET lk_lookup_value1 = v_process_records.srlk_lookup_value1,
					lk_lookup_value2 = v_process_records.srlk_lookup_value2,
					lk_lookup_value3 = v_process_records.srlk_lookup_value3,
					lk_lookup_value4 = v_process_records.srlk_lookup_value4,
					lk_lookup_value5 = v_process_records.srlk_lookup_value5,
					lk_lookup_value6 = v_process_records.srlk_lookup_value6,
					lk_lookup_value7 = v_process_records.srlk_lookup_value7,
					lk_lookup_value8 = v_process_records.srlk_lookup_value8,
					lk_lookup_value9 = v_process_records.srlk_lookup_value9,
					lk_lookup_value10 = v_process_records.srlk_lookup_value10,
					lk_lookup_value11 = v_process_records.srlk_lookup_value11,
					lk_lookup_value12 = v_process_records.srlk_lookup_value12,
					lk_lookup_value13 = v_process_records.srlk_lookup_value13,
					lk_lookup_value14 = v_process_records.srlk_lookup_value14,
					lk_lookup_value15 = v_process_records.srlk_lookup_value15,
					lk_lookup_value16 = v_process_records.srlk_lookup_value16,
					lk_lookup_value17 = v_process_records.srlk_lookup_value17,
					lk_lookup_value18 = v_process_records.srlk_lookup_value18,
					lk_lookup_value19 = v_process_records.srlk_lookup_value19,
					lk_lookup_value20 = v_process_records.srlk_lookup_value20,
					lk_active = 'A',
                    lk_input_by = NVL(v_process_records.srlk_input_by,'Client Static'),
                    lk_auth_by = NVL(v_process_records.srlk_lk_auth_by,'Client Static'),
                    lk_auth_status = NVL(v_process_records.srlk_lk_auth_status,'A'),
                    lk_input_time = SYSDATE,
                    lk_valid_from = NVL (v_process_records.srlk_lk_valid_from, SYSDATE),
                    lk_valid_to = NVL (v_process_records.srlk_lk_valid_to,TO_DATE('31-12-2099','dd-mm-yyyy')),
                    lk_delete_time = NULL,
					lk_effective_to = v_process_records.srlk_effective_to,
					LK_SOURCE_EVENT_ID = v_process_records.srlk_raw_lookup_id
                WHERE lk_lookup_key_id = v_general_lookup_key_id;

               v_event_status := 'P';
         END IF;

         CLOSE cur_gen_lookup_id;
      ELSIF v_process_records.srlk_active = 'I'
      THEN

          OPEN cur_gen_lookup_id (v_process_records.srlk_lkt_lookup_type_code,
                                 v_process_records.srlk_match_key1,
                                 v_process_records.srlk_match_key2,
                                 v_process_records.srlk_match_key3,
                                 v_process_records.srlk_match_key4,
                                 v_process_records.srlk_match_key5,
                                 v_process_records.srlk_match_key6,
                                 v_process_records.srlk_match_key7,
                                 v_process_records.srlk_match_key8,
                                 v_process_records.srlk_match_key9,
                                 v_process_records.srlk_match_key10,
                                 v_process_records.srlk_match_key11,
                                 v_process_records.srlk_match_key12,
                                 v_process_records.srlk_match_key13,
                                 v_process_records.srlk_match_key14,
                                 v_process_records.srlk_match_key15,
                                 v_process_records.srlk_match_key16,
                                 v_process_records.srlk_match_key17,
                                 v_process_records.srlk_match_key18,
                                 v_process_records.srlk_match_key19,
                                 v_process_records.srlk_match_key20,
								 v_process_records.srlk_effective_from
                                );

         FETCH cur_gen_lookup_id
          INTO v_general_lookup_key_id, v_active;
          IF cur_gen_lookup_id%FOUND THEN
              -- Logical Delete
              -- Update the Active column of the row in the FDR table to be 'I' (= 'Inactive')
              UPDATE fr_general_lookup
                SET lk_active = 'I',
                    lk_input_by = NVL(v_process_records.srlk_input_by,'Client Static'),
                    lk_auth_by = NVL(v_process_records.srlk_lk_auth_by,'Client Static'),
                    lk_auth_status = NVL(v_process_records.srlk_lk_auth_status,'A'),
                    lk_input_time = SYSDATE,
                    lk_valid_from =
                               NVL (v_process_records.srlk_lk_valid_from, SYSDATE),
                    lk_valid_to =
                           NVL (v_process_records.srlk_lk_valid_to,TO_DATE('31-12-2099','dd-mm-yyyy')),
                    lk_delete_time = SYSDATE,
					lk_effective_to = v_process_records.srlk_effective_to,
					LK_SOURCE_EVENT_ID = v_process_records.srlk_raw_lookup_id
              WHERE lk_lookup_key_id = v_general_lookup_key_id;

          END IF;

         CLOSE cur_gen_lookup_id;

        v_event_status := 'P';
      END IF;

    EXCEPTION
        -- basic exception handler
        WHEN OTHERS THEN

			IF( cur_gen_lookup_id%isopen )
				THEN
				close cur_gen_lookup_id;
			end if;

            v_event_status := 'E';

            -- log error to log table
            v_sqlcode := SQLCODE;
            v_sqlerrm := SUBSTR (SQLERRM, 1, 1000);

           INSERT INTO fr_log
                      (lo_event_type_id, lo_error_status, lo_category_id, lo_event_datetime,
                       lo_table_in_error_name, lo_row_in_error_key_id, lo_error_client_key_no,
                       lo_error_value, lo_event_text, lpg_id,LO_ERROR_RULE_IDENT,
					   lo_error_technology,LO_PROCESSING_STAGE
                      )
               VALUES (1, 'E', 0, SYSDATE,
                       'FR_STAN_RAW_GENERAL_LOOKUP', v_cur_srlk_id,v_cur_srlk_id,
                       TO_CHAR (v_sqlcode), v_sqlerrm, a_lpg_id,'PR_STAN_RAW_GENERAL_LOOKUP_LD',
					   'PL/SQL','FDR_STATIC'
                      );
                      COMMIT;
    END;

    IF v_event_status = 'P' THEN
        a_success_count:=a_success_count+1;
    ELSIF
       v_event_status = 'E' THEN
        a_failed_count:=a_failed_count+1;
    END IF;

    UPDATE fr_stan_raw_general_lookup
       SET event_status = v_event_status
     WHERE srlk_raw_lookup_id = v_process_records.srlk_raw_lookup_id;

   END LOOP;

    a_processed_count := a_success_count + a_failed_count;

   COMMIT;
END;

/

CREATE OR REPLACE PACKAGE BODY stn.PK_USER AS
    PROCEDURE pr_user_detail_idf
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_ud_identified_recs OUT NUMBER,
            p_no_ug_identified_recs OUT NUMBER
        )
    AS
    BEGIN
        INSERT INTO IDENTIFIED_RECORD
            (ROW_SID)
            SELECT
                ud.ROW_SID AS ROW_SID
            FROM
                USER_DETAIL ud
                INNER JOIN FEED ON ud.FEED_UUID = feed.FEED_UUID
            WHERE
                    ud.EVENT_STATUS = 'U'
and ud.LPG_ID       = p_lpg_id
and not exists (
                   select
                          null
                     from
                          stn.broken_feed bf
                    where
                          bf.feed_sid = feed.FEED_SID
               )
and not exists (
                  select
                         null
                    from
                         stn.superseded_feed sf
                   where
                         sf.superseded_feed_sid = feed.FEED_SID
              );
        UPDATE USER_DETAIL ud
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.identified_record idr
            where
                  ud.row_sid = idr.row_sid
       );
        p_no_ud_identified_recs := SQL%ROWCOUNT;
        UPDATE USER_GROUP ug
            SET
                STEP_RUN_SID = p_step_run_sid
            WHERE
                exists (
           select
                  null
             from
                  stn.identified_record idr
             join stn.user_detail       ud on ud.row_sid = idr.row_sid
            where
                  ug.EMPLOYEE_ID   = ud.employee_id
              and ug.feed_uuid = ud.feed_uuid
       );
        p_no_ug_identified_recs := SQL%ROWCOUNT;
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Updated user_detail and user_group step_run_sid', 'sql%rowcount', NULL, sql%rowcount, NULL);
    END;
    
    PROCEDURE pr_user_detail_rval
    AS
    BEGIN
        INSERT INTO STANDARDISATION_LOG
            (CATEGORY_ID, ERROR_STATUS, ERROR_TECHNOLOGY, ERROR_VALUE, EVENT_TEXT, EVENT_TYPE, FIELD_IN_ERROR_NAME, LPG_ID, PROCESSING_STAGE, ROW_IN_ERROR_KEY_ID, TABLE_IN_ERROR_NAME, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, FEED_SID)
            SELECT
                SubQuery.CATEGORY_ID AS CATEGORY_ID,
                SubQuery.ERROR_STATUS AS ERROR_STATUS,
                SubQuery.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                SubQuery.error_value AS ERROR_VALUE,
                SubQuery.event_text AS EVENT_TEXT,
                SubQuery.EVENT_TYPE AS EVENT_TYPE,
                SubQuery.field_in_error_name AS FIELD_IN_ERROR_NAME,
                SubQuery.LPG_ID AS LPG_ID,
                SubQuery.PROCESSING_STAGE AS PROCESSING_STAGE,
                SubQuery.row_in_error_key_id AS ROW_IN_ERROR_KEY_ID,
                SubQuery.table_in_error_name AS TABLE_IN_ERROR_NAME,
                SubQuery.rule_identity AS RULE_IDENTITY,
                SubQuery.CODE_MODULE_NM AS CODE_MODULE_NM,
                SubQuery.STEP_RUN_SID AS STEP_RUN_SID,
                SubQuery.FEED_SID AS FEED_SID
            FROM
                (SELECT
                    vdl.TABLE_NM AS table_in_error_name,
                    ud.ROW_SID AS row_in_error_key_id,
                    ud.DEPT_CD AS error_value,
                    ud.LPG_ID AS LPG_ID,
                    vdl.COLUMN_NM AS field_in_error_name,
                    rveld.EVENT_TYPE AS EVENT_TYPE,
                    rveld.ERROR_STATUS AS ERROR_STATUS,
                    rveld.CATEGORY_ID AS CATEGORY_ID,
                    rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                    rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                    vdl.VALIDATION_CD AS rule_identity,
                    FR_GLOBAL_PARAMETER.GP_TODAYS_BUS_DATE AS todays_business_dt,
                    fd.SYSTEM_CD AS SYSTEM_CD,
                    vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                    ud.STEP_RUN_SID AS STEP_RUN_SID,
                    vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                    fd.FEED_SID AS FEED_SID
                FROM
                    USER_DETAIL ud
                    INNER JOIN IDENTIFIED_RECORD idr ON ud.ROW_SID = idr.ROW_SID
                    INNER JOIN FEED fd ON ud.FEED_UUID = fd.FEED_UUID
                    INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON ud.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                    INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                    INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
                WHERE
                        vdl.VALIDATION_CD = 'ud-dept_cd'
and not exists (
                   select
                          null
                     from
                          gui.t_ui_departments tud
                    where
                          tud.department_id = ud.DEPT_CD
               )) SubQuery;
    END;
    
    PROCEDURE pr_user_detail_sps
        (
            p_no_processed_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE USER_DETAIL ud
            SET
                EVENT_STATUS = 'P'
            WHERE
                    ud.EVENT_STATUS = 'V'
and exists (
           select
                  null
             from
                 fdr.is_user  iu
            where
                 iu.isusr_id = ud.EMPLOYEE_ID
       )
and exists (
           select
                  null
             from
                 gui.t_ui_user_details  tuud
            where
                 tuud.user_id = ud.EMPLOYEE_ID
       );
        p_no_processed_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_user_detail_svs
        (
            p_no_validated_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE USER_DETAIL ud
            SET
                EVENT_STATUS = 'E'
            WHERE
                exists (
           select
                  null
             from
                  stn.standardisation_log sl
            where
                  sl.row_in_error_key_id = ud.ROW_SID
              and sl.table_in_error_name = 'user_detail'
       );
        UPDATE USER_DETAIL ud
            SET
                EVENT_STATUS = 'V'
            WHERE
                    not exists (
                   select
                          null
                     from
                          stn.standardisation_log sl
                    where
                          sl.row_in_error_key_id = ud.ROW_SID
                      and sl.table_in_error_name = 'user_detail'
               )
and     exists (
                   select
                          null
                     from
                          stn.identified_record idr
                    where
                          ud.ROW_SID = idr.row_sid
               );
        p_no_validated_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_user_group_rval
    AS
    BEGIN
        INSERT INTO STANDARDISATION_LOG
            (CATEGORY_ID, ERROR_STATUS, ERROR_TECHNOLOGY, ERROR_VALUE, EVENT_TEXT, EVENT_TYPE, FIELD_IN_ERROR_NAME, LPG_ID, PROCESSING_STAGE, ROW_IN_ERROR_KEY_ID, TABLE_IN_ERROR_NAME, RULE_IDENTITY, CODE_MODULE_NM, STEP_RUN_SID, FEED_SID)
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                ug.GROUP_NM AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                ug.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                ug.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ug.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                USER_GROUP ug
                INNER JOIN USER_DETAIL ud ON ug.EMPLOYEE_ID = ud.EMPLOYEE_ID AND ug.FEED_UUID = ud.FEED_UUID
                INNER JOIN IDENTIFIED_RECORD idr ON ud.ROW_SID = idr.ROW_SID
                INNER JOIN FEED fd ON ug.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON ug.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ug-group_nm'
and not exists (
                   select
                          null
                     from
                          gui.t_ui_roles tur
                    where
                          tur.role_id = ug.GROUP_NM
               )
            UNION
            SELECT
                rveld.CATEGORY_ID AS CATEGORY_ID,
                rveld.ERROR_STATUS AS ERROR_STATUS,
                rveld.ERROR_TECHNOLOGY AS ERROR_TECHNOLOGY,
                TO_CHAR(ug.EMPLOYEE_ID) AS error_value,
                vdl.VALIDATION_TYP_ERR_MSG AS event_text,
                rveld.EVENT_TYPE AS EVENT_TYPE,
                vdl.COLUMN_NM AS field_in_error_name,
                ug.LPG_ID AS LPG_ID,
                rveld.PROCESSING_STAGE AS PROCESSING_STAGE,
                ug.ROW_SID AS row_in_error_key_id,
                vdl.TABLE_NM AS table_in_error_name,
                vdl.VALIDATION_CD AS rule_identity,
                vdl.CODE_MODULE_NM AS CODE_MODULE_NM,
                ug.STEP_RUN_SID AS STEP_RUN_SID,
                fd.FEED_SID AS FEED_SID
            FROM
                USER_GROUP ug
                INNER JOIN FEED fd ON ug.FEED_UUID = fd.FEED_UUID
                INNER JOIN fdr.FR_GLOBAL_PARAMETER FR_GLOBAL_PARAMETER ON ug.LPG_ID = FR_GLOBAL_PARAMETER.LPG_ID
                INNER JOIN VALIDATION_DETAIL vdl ON 1 = 1
                INNER JOIN ROW_VAL_ERROR_LOG_DEFAULT rveld ON 1 = 1
            WHERE
                    vdl.VALIDATION_CD = 'ug-employee_id'
and exists (
                   select
                          null
                     from
                          stn.user_detail ud
                     join stn.standardisation_log sl
                              on sl.row_in_error_key_id = ud.row_sid
                    where
                          ug.EMPLOYEE_ID  = ud.employee_id
                      and ug.FEED_UUID    = ud.feed_uuid
               );
    END;
    
    PROCEDURE pr_user_group_sps
        (
            p_no_processed_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE USER_GROUP ug
            SET
                EVENT_STATUS = 'P'
            WHERE
                    ug.EVENT_STATUS = 'V'
and exists (
           select
                  null
             from
                  gui.t_ui_user_roles  tuur
            where
                 tuur.role_id = ug.GROUP_NM
             and tuur.user_id = ug.EMPLOYEE_ID
       );
        p_no_processed_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_user_group_svs
        (
            p_no_validated_records OUT NUMBER
        )
    AS
    BEGIN
        UPDATE USER_GROUP ug
            SET
                EVENT_STATUS = 'E'
            WHERE
                exists (
           select
                  null
             from
                  stn.standardisation_log sl
            where
                  sl.row_in_error_key_id = ug.ROW_SID
              and sl.table_in_error_name = 'user_group'
       );
        UPDATE USER_GROUP ug
            SET
                EVENT_STATUS = 'V'
            WHERE
                    not exists (
                   select
                          null
                     from
                          stn.standardisation_log sl
                    where
                          sl.row_in_error_key_id = ug.ROW_SID
                      and sl.table_in_error_name = 'user_group'
               )
and     exists (
                   select
                          null
                     from
                          stn.identified_record idr
                        , stn.user_detail ud
                    where
                          ud.row_sid     = idr.row_sid
                      and ud.employee_id = ug.EMPLOYEE_ID
                      and ud.feed_uuid   = ug.feed_uuid
               );
        p_no_validated_records := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_user_group_pub
        (
            p_step_run_sid IN NUMBER,
            p_no_is_user_pub OUT NUMBER,
            p_no_is_groupuser_pub OUT NUMBER,
            p_no_t_ui_user_details_pub OUT NUMBER,
            p_no_t_ui_user_depts_pub OUT NUMBER,
            p_no_t_ui_user_roles_pub OUT NUMBER,
            p_no_t_ui_user_entities_pub OUT NUMBER,
            p_no_t_ui_user_roles_del OUT NUMBER
        )
    AS
    BEGIN
        MERGE INTO fdr.IS_USER IS_USER
            USING
                (SELECT
                    ud.EMPLOYEE_ID AS EMPLOYEE_ID,
                    ud.USER_NM AS USER_NM,
                    USER_DEFAULT.DEFAULT_PW AS DEFAULT_PW
                FROM
                    USER_DETAIL ud
                    INNER JOIN IDENTIFIED_RECORD idr ON ud.ROW_SID = idr.ROW_SID
                    INNER JOIN USER_DEFAULT ON 1 = 1
                WHERE
                    ud.EVENT_STATUS = 'V') stn_user
            ON (IS_USER.ISUSR_ID = stn_user.EMPLOYEE_ID)
            WHEN MATCHED THEN
                UPDATE SET
                    ISUSR_NAME = stn_user.USER_NM
            WHEN NOT MATCHED THEN
                INSERT
                    (ISUSR_ID, ISUSR_NAME, ISUSR_LOCK, ISUSR_PASSWD)
                    VALUES
                    (stn_user.EMPLOYEE_ID, stn_user.USER_NM, 0, stn_user.DEFAULT_PW);
        p_no_is_user_pub := SQL%ROWCOUNT;
        MERGE INTO fdr.IS_GROUPUSER IS_GROUPUSER
            USING
                (SELECT
                    iu.ISUSR_ID AS USR_REF,
                    IS_GROUP.ISGRP_ID AS GRP_REF
                FROM
                    USER_DETAIL ud
                    INNER JOIN IDENTIFIED_RECORD idr ON ud.ROW_SID = idr.ROW_SID
                    INNER JOIN fdr.IS_USER iu ON iu.ISUSR_NAME = ud.USER_NM
                    INNER JOIN USER_DEFAULT ON 1 = 1
                    INNER JOIN fdr.IS_GROUP IS_GROUP ON USER_DEFAULT.GROUP_NAME = IS_GROUP.ISGRP_NAME
                WHERE
                    ud.EVENT_STATUS = 'V') stn_user
            ON (IS_GROUPUSER.ISGU_USR_REF = stn_user.USR_REF)
            WHEN MATCHED THEN
                UPDATE SET
                    ISGU_GRP_REF = stn_user.GRP_REF
            WHEN NOT MATCHED THEN
                INSERT
                    (ISGU_USR_REF, ISGU_GRP_REF)
                    VALUES
                    (stn_user.USR_REF, stn_user.GRP_REF);
        p_no_is_groupuser_pub := SQL%ROWCOUNT;
        MERGE INTO gui.T_UI_USER_DETAILS T_UI_USER_DETAILS
            USING
                (SELECT
                    ud.EMPLOYEE_ID AS EMPLOYEE_ID,
                    ud.USER_NM AS USER_NM,
                    ud.FIRST_NM AS FIRST_NM,
                    ud.LAST_NM AS LAST_NM,
                    ud.EMAIL_ADDRESS AS EMAIL_ADDRESS,
                    ud.DEPT_CD AS DEPT_CD,
                    USER_DEFAULT.ENTITY_ID AS ENTITY_ID
                FROM
                    USER_DETAIL ud
                    INNER JOIN IDENTIFIED_RECORD idr ON ud.ROW_SID = idr.ROW_SID
                    INNER JOIN USER_DEFAULT ON 1 = 1
                WHERE
                    ud.EVENT_STATUS = 'V') stn_user
            ON (T_UI_USER_DETAILS.USER_ID = stn_user.EMPLOYEE_ID)
            WHEN MATCHED THEN
                UPDATE SET
                    USER_NAME = stn_user.USER_NM,
                    USER_FIRST_NAME = stn_user.FIRST_NM,
                    USER_LAST_NAME = stn_user.LAST_NM,
                    USER_DEPARTMENT = stn_user.DEPT_CD,
                    USER_EMAIL_ADDRESS = stn_user.EMAIL_ADDRESS,
                    USER_ENTITY = stn_user.ENTITY_ID
            WHEN NOT MATCHED THEN
                INSERT
                    (USER_ID, USER_NAME, USER_FIRST_NAME, USER_LAST_NAME, USER_DEPARTMENT, USER_EMAIL_ADDRESS, USER_ENTITY)
                    VALUES
                    (stn_user.EMPLOYEE_ID, stn_user.USER_NM, stn_user.FIRST_NM, stn_user.LAST_NM, stn_user.DEPT_CD, stn_user.EMAIL_ADDRESS, stn_user.ENTITY_ID);
        p_no_t_ui_user_details_pub := SQL%ROWCOUNT;
        MERGE INTO gui.T_UI_USER_DEPARTMENTS T_UI_USER_DEPARTMENTS
            USING
                (SELECT
                    ud.EMPLOYEE_ID AS EMPLOYEE_ID,
                    ud.DEPT_CD AS DEPT_CD
                FROM
                    USER_DETAIL ud
                    INNER JOIN IDENTIFIED_RECORD idr ON ud.ROW_SID = idr.ROW_SID
                    INNER JOIN USER_DEFAULT ON 1 = 1
                WHERE
                    ud.EVENT_STATUS = 'V') stn_user
            ON (T_UI_USER_DEPARTMENTS.USER_ID = stn_user.EMPLOYEE_ID)
            WHEN MATCHED THEN
                UPDATE SET
                    DEPARTMENT_ID = stn_user.DEPT_CD
            WHEN NOT MATCHED THEN
                INSERT
                    (USER_ID, DEPARTMENT_ID)
                    VALUES
                    (stn_user.EMPLOYEE_ID, stn_user.DEPT_CD);
        p_no_t_ui_user_depts_pub := SQL%ROWCOUNT;
        MERGE INTO gui.T_UI_USER_ROLES T_UI_USER_ROLES
            USING
                (SELECT
                    ug.EMPLOYEE_ID AS EMPLOYEE_ID,
                    ug.GROUP_NM AS GROUP_NM
                FROM
                    USER_DETAIL ud
                    INNER JOIN IDENTIFIED_RECORD idr ON ud.ROW_SID = idr.ROW_SID
                    INNER JOIN USER_GROUP ug ON ud.EMPLOYEE_ID = ug.EMPLOYEE_ID AND ud.FEED_UUID = ug.FEED_UUID
                    INNER JOIN USER_DEFAULT ON 1 = 1
                WHERE
                    ug.EVENT_STATUS = 'V') stn_user
            ON (T_UI_USER_ROLES.USER_ID = stn_user.EMPLOYEE_ID AND T_UI_USER_ROLES.ROLE_ID = stn_user.GROUP_NM)
            WHEN NOT MATCHED THEN
                INSERT
                    (USER_ID, ROLE_ID)
                    VALUES
                    (stn_user.EMPLOYEE_ID, stn_user.GROUP_NM);
        p_no_t_ui_user_roles_pub := SQL%ROWCOUNT;
        MERGE INTO gui.T_UI_USER_ENTITIES T_UI_USER_ENTITIES
            USING
                (SELECT
                    ud.EMPLOYEE_ID AS EMPLOYEE_ID,
                    USER_DEFAULT.ENTITY_ID AS ENTITY_ID
                FROM
                    USER_DETAIL ud
                    INNER JOIN IDENTIFIED_RECORD idr ON ud.ROW_SID = idr.ROW_SID
                    INNER JOIN USER_DEFAULT ON 1 = 1
                WHERE
                    ud.EVENT_STATUS = 'V') stn_user
            ON (T_UI_USER_ENTITIES.USER_ID = stn_user.EMPLOYEE_ID AND T_UI_USER_ENTITIES.ENTITY_ID = stn_user.ENTITY_ID)
            WHEN NOT MATCHED THEN
                INSERT
                    (USER_ID, ENTITY_ID)
                    VALUES
                    (stn_user.EMPLOYEE_ID, stn_user.ENTITY_ID);
        p_no_t_ui_user_entities_pub := SQL%ROWCOUNT;
        DELETE FROM
            gui.T_UI_USER_ROLES T_UI_USER_ROLES
        WHERE
            (T_UI_USER_ROLES.USER_ID, T_UI_USER_ROLES.ROLE_ID) IN (SELECT
                tuur.USER_ID,
                tuur.ROLE_ID
            FROM
                gui.T_UI_USER_ROLES tuur
                LEFT OUTER JOIN (SELECT
                    ug.EMPLOYEE_ID AS EMPLOYEE_ID,
                    ug.GROUP_NM AS GROUP_NM
                FROM
                    USER_DETAIL ud
                    INNER JOIN IDENTIFIED_RECORD idr ON ud.ROW_SID = idr.ROW_SID
                    INNER JOIN USER_GROUP ug ON ud.EMPLOYEE_ID = ug.EMPLOYEE_ID AND ud.FEED_UUID = ug.FEED_UUID
                    INNER JOIN USER_DEFAULT ON 1 = 1
                WHERE
                    ug.EVENT_STATUS = 'V') stn_user ON tuur.USER_ID = stn_user.EMPLOYEE_ID AND tuur.ROLE_ID = stn_user.GROUP_NM
            WHERE
                stn_user.EMPLOYEE_ID IS NULL AND stn_user.GROUP_NM IS NULL AND tuur.USER_ID <> 3);
        p_no_t_ui_user_roles_del := SQL%ROWCOUNT;
    END;
    
    PROCEDURE pr_user_prc
        (
            p_step_run_sid IN NUMBER,
            p_lpg_id IN NUMBER,
            p_no_processed_records OUT NUMBER,
            p_no_failed_records OUT NUMBER
        )
    AS
        v_no_ud_identified_records NUMBER(38, 9) DEFAULT 0;
        v_no_ug_identified_records NUMBER(38, 9) DEFAULT 0;
        v_no_ud_validated_records NUMBER(38, 9) DEFAULT 0;
        v_no_ug_validated_records NUMBER(38, 9) DEFAULT 0;
        v_no_ud_processed_records NUMBER(38, 9) DEFAULT 0;
        v_no_ug_processed_records NUMBER(38, 9) DEFAULT 0;
        v_no_fdr_users_published NUMBER(38, 9) DEFAULT 0;
        v_no_fdr_groups_published NUMBER(38, 9) DEFAULT 0;
        v_no_gui_details_published NUMBER(38, 9) DEFAULT 0;
        v_no_gui_departments_published NUMBER(38, 9) DEFAULT 0;
        v_no_gui_roles_published NUMBER(38, 9) DEFAULT 0;
        v_no_gui_entities_published NUMBER(38, 9) DEFAULT 0;
        v_no_gui_roles_removed NUMBER(38, 9) DEFAULT 0;
        pub_val_mismatch EXCEPTION;
    BEGIN
        dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Identify user detail records' );
        pr_user_detail_idf(p_step_run_sid, p_lpg_id, v_no_ud_identified_records, v_no_ug_identified_records);
        pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Identified records', 'v_no_identified_records', NULL, v_no_ud_identified_records + v_no_ug_identified_records, NULL);
        IF v_no_ud_identified_records > 0 THEN
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Row level validate user detail records' );
            pr_user_detail_rval;
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed row level validations for user detail', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Row level validate user group records' );
            pr_user_group_rval;
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed row level validations for user group', NULL, NULL, NULL, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set user detail status = "V"' );
            pr_user_detail_svs(v_no_ud_validated_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting validated status for user detailt', 'v_no_ud_validated_records', NULL, v_no_ud_validated_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set user group status = "V"' );
            pr_user_group_svs(v_no_ug_validated_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting validated status for user group', 'v_no_ug_validated_records', NULL, v_no_ug_validated_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish user records' );
            pr_user_group_pub(p_step_run_sid, v_no_fdr_users_published, v_no_fdr_groups_published, v_no_gui_details_published, v_no_gui_departments_published, v_no_gui_roles_published, v_no_gui_entities_published, v_no_gui_roles_removed);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing fdr.is_user records', 'v_no_fdr_users_published', NULL, v_no_fdr_users_published, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing fdr.is_groupuser records', 'v_no_fdr_groups_published', NULL, v_no_fdr_groups_published, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing gui.t_ui_user_details records', 'v_no_gui_details_published', NULL, v_no_gui_details_published, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing gui.t_ui_user_departments records', 'v_no_gui_departments_published', NULL, v_no_gui_departments_published, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing gui.t_ui_user_roles records', 'v_no_gui_roles_published', NULL, v_no_gui_roles_published, NULL);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed publishing gui.t_ui_user_entities records', 'v_no_gui_entities_published', NULL, v_no_gui_entities_published, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Publish user standardise log records' );
            pr_publish_log;
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set user detail status = "P"' );
            pr_user_detail_sps(v_no_ud_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status for user detail records', 'v_no_ud_processed_records', NULL, v_no_ud_processed_records, NULL);
            dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Set user group process status = "P"' );
            pr_user_group_sps(v_no_ug_processed_records);
            pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Completed setting published status for user group records', 'v_no_ug_processed_records', NULL, v_no_ug_processed_records, NULL);
            IF v_no_ud_validated_records <> v_no_ud_processed_records THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_no_ud_validated_records <> v_no_ud_processed_records', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 1' );
                raise pub_val_mismatch;
            END IF;
            IF v_no_ug_validated_records <> v_no_ug_processed_records THEN
                pr_step_run_log(p_step_run_sid, $$plsql_unit, $$plsql_line, 'Exception : v_no_ug_validated_records <> v_no_ug_processed_records', NULL, NULL, NULL, NULL);
                dbms_application_info.set_module ( module_name => $$plsql_unit , action_name => 'Raise pub_val_mismatch - 2' );
                raise pub_val_mismatch;
            END IF;
            p_no_processed_records := v_no_ud_processed_records
                                    + v_no_ug_processed_records;
            p_no_failed_records    := v_no_ud_identified_records
                                    + v_no_ug_identified_records
                                    - v_no_ud_processed_records
                                    - v_no_ug_processed_records;
        ELSE
            p_no_processed_records := 0;
            p_no_failed_records    := 0;
        END IF;
    END;
END PK_USER;
/
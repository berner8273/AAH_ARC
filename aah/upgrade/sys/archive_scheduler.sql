
delete from SCHEDULER_CORE.TASK_PROCESS_PARAMETER_MAPPING where batch = 'ARCHIVE_SLR';
delete from SCHEDULER_CORE.TASK where batch = 'ARCHIVE_SLR';
delete from scheduler_core.batch where batch = 'ARCHIVE_SLR';
delete from SCHEDULER_CORE.SQL_PROCESS where process = 'process_slr_archive';
delete from SCHEDULER_CORE.PROCESS_PARAMETER where process = 'process_slr_archive';
delete from SCHEDULER_CORE.PROCESS where process = 'process_slr_archive';
delete from SCHEDULER_CORE.SYSTEM_PARAMETERS;



-- SYSTEM_PARAMETERS

Insert into SCHEDULER_CORE.SYSTEM_PARAMETERS
   (SCHEDULER, KEY, VALUE)
 Values
   ('DEFAULT', 'APT_BUS_HOST','aice');
Insert into SCHEDULER_CORE.SYSTEM_PARAMETERS
   (SCHEDULER, KEY,VALUE)
 Values
   ('DEFAULT', 'APT_DEPLOY_FOLDER','AG');
Insert into SCHEDULER_CORE.SYSTEM_PARAMETERS
   (SCHEDULER, KEY, VALUE)
 Values
   ('DEFAULT', 'APT_BUS_PORT','2503');
Insert into SCHEDULER_CORE.SYSTEM_PARAMETERS
   (SCHEDULER, KEY,VALUE)
 Values
   ('DEFAULT', 'DB_CONNECTION','jdbc:oracle:thin:@oraaptdev:1521/aptdev');

--process

Insert into SCHEDULER_CORE.PROCESS
   (SCHEDULER, PROCESS, RUNNABLE_GROUP, PROCESS_TYPE, CREATED_DATE, 
    UPDATED_DATE, CREATED_BY, UPDATED_BY, CONCURRENT_EXECUTION_LIMIT)
 Values
   ('DEFAULT', 'process_slr_archive', 'DEFAULT', 'SQL', TO_DATE('11/08/2022 09:08:27', 'MM/DD/YYYY HH24:MI:SS'), 
    TO_DATE('11/08/2022 11:35:10', 'MM/DD/YYYY HH24:MI:SS'), 'jberner', 'jberner', 0);

-- process_parameter

Insert into SCHEDULER_CORE.PROCESS_PARAMETER
   (SCHEDULER, PROCESS, PARAMETER, INPUT, OUTPUT, 
    TYPE, OPTIONAL, CREATED_DATE, UPDATED_DATE, CREATED_BY, 
    UPDATED_BY, NULLABLE)
 Values
   ('DEFAULT', 'process_slr_archive', 'agroup', 1, 0, 
    'LONG', 0, TO_DATE('11/08/2022 10:24:50', 'MM/DD/YYYY HH24:MI:SS'), TO_DATE('11/08/2022 11:35:10', 'MM/DD/YYYY HH24:MI:SS'), 'jberner', 
    'jberner', 0);
Insert into SCHEDULER_CORE.PROCESS_PARAMETER
   (SCHEDULER, PROCESS, PARAMETER, INPUT, OUTPUT, 
    TYPE, OPTIONAL, CREATED_DATE, UPDATED_DATE, CREATED_BY, 
    UPDATED_BY, NULLABLE)
 Values
   ('DEFAULT', 'process_slr_archive', 'batchsize', 1, 0, 
    'LONG', 1, TO_DATE('11/08/2022 10:24:50', 'MM/DD/YYYY HH24:MI:SS'), TO_DATE('11/08/2022 11:35:10', 'MM/DD/YYYY HH24:MI:SS'), 'jberner', 
    'jberner', 0);
Insert into SCHEDULER_CORE.PROCESS_PARAMETER
   (SCHEDULER, PROCESS, PARAMETER, INPUT, OUTPUT, 
    TYPE, OPTIONAL, CREATED_DATE, UPDATED_DATE, CREATED_BY, 
    UPDATED_BY, NULLABLE)
 Values
   ('DEFAULT', 'process_slr_archive', 'lpgid', 1, 0, 
    'LONG', 0, TO_DATE('11/08/2022 10:24:50', 'MM/DD/YYYY HH24:MI:SS'), TO_DATE('11/08/2022 11:35:10', 'MM/DD/YYYY HH24:MI:SS'), 'jberner', 
    'jberner', 0);
Insert into SCHEDULER_CORE.PROCESS_PARAMETER
   (SCHEDULER, PROCESS, PARAMETER, INPUT, OUTPUT, 
    TYPE, OPTIONAL, CREATED_DATE, UPDATED_DATE, CREATED_BY, 
    UPDATED_BY, NULLABLE)
 Values
   ('DEFAULT', 'process_slr_archive', 'processkey', 1, 0, 
    'LONG', 1, TO_DATE('11/08/2022 10:24:50', 'MM/DD/YYYY HH24:MI:SS'), TO_DATE('11/08/2022 11:35:10', 'MM/DD/YYYY HH24:MI:SS'), 'jberner', 
    'jberner', 0);
Insert into SCHEDULER_CORE.PROCESS_PARAMETER
   (SCHEDULER, PROCESS, PARAMETER, INPUT, OUTPUT, 
    TYPE, OPTIONAL, CREATED_DATE, UPDATED_DATE, CREATED_BY, 
    UPDATED_BY, NULLABLE)
 Values
   ('DEFAULT', 'process_slr_archive', 'returncode', 0, 1, 
    'LONG', 0, TO_DATE('11/08/2022 10:24:50', 'MM/DD/YYYY HH24:MI:SS'), TO_DATE('11/08/2022 11:35:10', 'MM/DD/YYYY HH24:MI:SS'), 'jberner', 
    'jberner', 0);

-- SQL_PROCESS
Insert into SCHEDULER_CORE.SQL_PROCESS
   (SCHEDULER, PROCESS, DRIVER, SECRET, CONNECTION_STRING,STATEMENT)
 Values
   ('DEFAULT', 'process_slr_archive', 'oracle.jdbc.OracleDriver', 'FDR', '#{#parameters[''DB_CONNECTION'']}','{call fdr.fdr_archiving_pkg.pArchive(pLPGId=>:{lpgid},pArchiveGroup=>:{agroup},pProcessKey=>:{processkey},pBatchSize=>:{batchsize},pReturnCode=>:{returncode})}');


-- TASK
Insert into SCHEDULER_CORE.TASK
   (SCHEDULER, BATCH, TASK, PROCESS, CREATED_DATE, 
    UPDATED_DATE, CREATED_BY, UPDATED_BY)
 Values
   ('DEFAULT', 'ARCHIVE_SLR', 'archive_slr', 'process_slr_archive', TO_DATE('11/08/2022 10:35:58', 'MM/DD/YYYY HH24:MI:SS'), 
    TO_DATE('11/08/2022 10:37:43', 'MM/DD/YYYY HH24:MI:SS'), 'jberner', 'jberner');


-- TASK_PROCESS_PARAMETER_MAPPING

Insert into SCHEDULER_CORE.TASK_PROCESS_PARAMETER_MAPPING
   (SCHEDULER, BATCH, TASK, PROCESS, PROCESS_PARAMETER, 
    CONSTANT_VALUE, CREATED_DATE, UPDATED_DATE, CREATED_BY, UPDATED_BY)
 Values
   ('DEFAULT', 'ARCHIVE_SLR', 'archive_slr', 'process_slr_archive', 'agroup', 
    '3', TO_DATE('11/08/2022 10:35:58', 'MM/DD/YYYY HH24:MI:SS'), TO_DATE('11/08/2022 10:37:43', 'MM/DD/YYYY HH24:MI:SS'), 'jberner', 'jberner');
Insert into SCHEDULER_CORE.TASK_PROCESS_PARAMETER_MAPPING
   (SCHEDULER, BATCH, TASK, PROCESS, PROCESS_PARAMETER, 
    CREATED_DATE, UPDATED_DATE, CREATED_BY, UPDATED_BY)
 Values
   ('DEFAULT', 'ARCHIVE_SLR', 'archive_slr', 'process_slr_archive', 'batchsize', 
    TO_DATE('11/08/2022 10:35:58', 'MM/DD/YYYY HH24:MI:SS'), TO_DATE('11/08/2022 10:37:43', 'MM/DD/YYYY HH24:MI:SS'), 'jberner', 'jberner');
Insert into SCHEDULER_CORE.TASK_PROCESS_PARAMETER_MAPPING
   (SCHEDULER, BATCH, TASK, PROCESS, PROCESS_PARAMETER, 
    CONSTANT_VALUE, CREATED_DATE, UPDATED_DATE, CREATED_BY, UPDATED_BY)
 Values
   ('DEFAULT', 'ARCHIVE_SLR', 'archive_slr', 'process_slr_archive', 'lpgid', 
    '2', TO_DATE('11/08/2022 10:35:58', 'MM/DD/YYYY HH24:MI:SS'), TO_DATE('11/08/2022 10:37:43', 'MM/DD/YYYY HH24:MI:SS'), 'jberner', 'jberner');
Insert into SCHEDULER_CORE.TASK_PROCESS_PARAMETER_MAPPING
   (SCHEDULER, BATCH, TASK, PROCESS, PROCESS_PARAMETER, 
    CREATED_DATE, UPDATED_DATE, CREATED_BY, UPDATED_BY)
 Values
   ('DEFAULT', 'ARCHIVE_SLR', 'archive_slr', 'process_slr_archive', 'processkey', 
    TO_DATE('11/08/2022 10:35:58', 'MM/DD/YYYY HH24:MI:SS'), TO_DATE('11/08/2022 10:37:43', 'MM/DD/YYYY HH24:MI:SS'), 'jberner', 'jberner');
Insert into SCHEDULER_CORE.TASK_PROCESS_PARAMETER_MAPPING
   (SCHEDULER, BATCH, TASK, PROCESS, PROCESS_PARAMETER, 
    CREATED_DATE, UPDATED_DATE, CREATED_BY, UPDATED_BY)
 Values
   ('DEFAULT', 'ARCHIVE_SLR', 'archive_slr', 'process_slr_archive', 'returncode', 
    TO_DATE('11/08/2022 10:35:58', 'MM/DD/YYYY HH24:MI:SS'), TO_DATE('11/08/2022 10:37:43', 'MM/DD/YYYY HH24:MI:SS'), 'jberner', 'jberner');

-- BATCH
Insert into SCHEDULER_CORE.BATCH
   (SCHEDULER, BATCH, CREATED_DATE, UPDATED_DATE, CREATED_BY, 
    UPDATED_BY, RUNNABLE_GROUP)
 Values
   ('DEFAULT', 'ARCHIVE_SLR', TO_DATE('11/08/2022 10:35:58', 'MM/DD/YYYY HH24:MI:SS'), TO_DATE('11/08/2022 10:37:43', 'MM/DD/YYYY HH24:MI:SS'), 'jberner', 
    'jberner', 'DEFAULT');

COMMIT;
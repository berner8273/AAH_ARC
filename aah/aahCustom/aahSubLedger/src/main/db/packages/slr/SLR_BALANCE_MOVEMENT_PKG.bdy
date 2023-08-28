CREATE OR REPLACE PACKAGE BODY SLR."SLR_BALANCE_MOVEMENT_PKG" AS

  PROCEDURE pBMTraceJob(pDescription IN VARCHAR2, pSQL IN VARCHAR2) AS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO SLR_JOB_TRACE(JT_TRACE_ID,JT_PROCESS_ID, JT_TRACE_DESCRIPTION, JT_TRACE_SQL)
    VALUES(seq_jt_trace_id.nextval ,gProcessID, pDescription, pSQL);
    COMMIT;
  END pBMTraceJob;

    --main procedure--
   procedure pBMRunBalanceMovementProcess( pProcess     IN slr_process.p_process%TYPE
                                         ,pEntProcSet  IN slr_bm_entity_processing_set.bmeps_set_id%TYPE
                                         ,pConfig      IN slr_process_config.pc_config%TYPE
                                         ,pSource      IN slr_process_source.sps_source_name%TYPE
                                         ,pBalanceDate IN DATE
                                         ,pRateSet     IN slr_entity_rates.er_entity_set%type
										 ,gProcId OUT number
                                        ) AS

     vProcName VARCHAR2(30) := 'pBMRunBalanceMovementProcess';
     v_count INTEGER := 0;
	 v_count2 INTEGER := 0;
     v_lines_count INTEGER :=0;
	 v_SID VARCHAR2(256);
	gEND_BLOCK_GETS NUMBER(38);
	gEND_CONSISTENT_GETS NUMBER(38);
	gEND_PHYSICAL_READS NUMBER(38);
	gEND_BLOCK_CHANGES NUMBER(38);
	gEND_CONSISTENT_CHANGES    NUMBER(38);
     CURSOR cEntityProcGroups IS
        SELECT DISTINCT JLU_EPG_ID
        FROM slr_jrnl_lines_unposted
        WHERE jlu_jrnl_process_id = gProcessId;
  BEGIN

		if (pProcess is not null and pProcess not in ('FXREVALUE','FXPLSWEEP','FXPOSITION','FXCLEARDOWN','PLREPATRIATION','PLRETEARNINGS')) then
			RAISE_APPLICATION_ERROR(-20001,'Unsupported process: ' || pProcess ||'. Supported processes: ''FXPLSWEEP'', ''FXREVALUE'', ''FXPOSITION'', ''FXCLEARDOWN'', ''PLREPATRIATION'', ''PLRETEARNINGS''');
		end if;

		/*check for null params*/
		IF (pProcess IS NULL OR pEntProcSet IS NULL OR pConfig IS NULL OR pSource IS NULL )THEN
			RAISE_APPLICATION_ERROR(-20001,'Process, entity processing set, config and source cannot be null');
		END IF;

		--for retained earnings date must be specified
		IF(pBalanceDate IS NULL AND pProcess = 'PLRETEARNINGS') THEN
			RAISE_APPLICATION_ERROR(-20001,'Balance date parameter has not been provided. Balance date must be the last working day of the year');
		end if;
		/*check for null params*/

		/*check entity set*/
    SELECT count(*)
		INTO v_count
		FROM SLR_BM_ENTITY_PROCESSING_SET
		WHERE BMEPS_SET_ID = pEntProcSet;

		IF v_count = 0 THEN
			RAISE_APPLICATION_ERROR(-20001,'Unable to find entity processing set: '||pEntProcSet);
		END IF;
		/*check entity set*/

		/*check config*/
		begin
      SELECT pc_jt_type, pc_fak_eba_flag, PC_AGGREGATION, PC_FX_MANAGE_CCY, PC_CUSTOM_PROCEDURE, PC_METHOD
      INTO  gJournalType, gFakEbaFlag, gWhichAmount, gFxManageCcy, gCustomProcedure, gMethod
      FROM slr_process_config_detail
      INNER JOIN slr_process_config ON (pcd_pc_config = pc_config AND pcd_pc_p_process = pc_p_process)
      WHERE pcd_pc_config = pConfig AND  pcd_pc_p_process = pProcess and rownum < 2;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001,'Unable to find process configuration for config '||pConfig||' and process '||pProcess);

	  END;
	  if gMethod <> 'DEFAULT' then
        RAISE_APPLICATION_ERROR(-20001,'The FAS52 process is no longer supported. Please use the Step by Step Revaluation mode, defined in FX Translation Configuration instead.');
      end if;
		--if process is set on FAK level check that all attributes in config detail are null
		if gFakEbaFlag = 'F' then
			SELECT count(*) into v_count
            FROM slr_process_config_detail
            WHERE pcd_pc_config = pConfig
            AND   pcd_pc_p_process = pProcess
            AND  (pcd_attribute_1 IS NOT NULL OR pcd_attribute_2 IS NOT NULL OR pcd_attribute_3 IS NOT NULL OR pcd_attribute_4 IS NOT NULL OR pcd_attribute_5 IS NOT NULL);

			IF v_count > 0 THEN
				RAISE_APPLICATION_ERROR(-20001,'Process config detail cannot specify attributes (pcd_attribute_1..5) when config FAK_EBA_FLAG equals ''F''.');
			END IF;

		end if;

		/*Validation when: SLR_PROCESS_CONFIG.PC_FAK_EBA_FLAG = 'F' and ENT_POST_FAK_BALANCES = 'N'*/

		if gFakEbaFlag = 'F' then

		SELECT COUNT(*) INTO v_count FROM
		 slr_bm_entity_processing_set, slr_entities
         WHERE
		bmeps_set_id = pEntProcSet AND ent_entity = BMEPS_ENTITY AND ENT_POST_FAK_BALANCES = 'N' ;

		SELECT COUNT(*) INTO v_count2 FROM
		slr_process_config_detail,slr_entities
		WHERE pcd_pc_config = pConfig AND  pcd_pc_p_process = pProcess AND pcd_entity <> '**SOURCE**' AND pcd_entity = ent_entity AND ENT_POST_FAK_BALANCES = 'N'
		;

		IF (v_count > 0 OR v_count2 > 0) THEN
				RAISE_APPLICATION_ERROR(-20001,'Inconsistent setup for FAK balance posting. Check entities in Entity Processing Set: ' || pEntProcSet);
		END IF;

		end if;

		--******************************
    /*check config*/


		/*check source*/
			begin
        SELECT sps_db_object_name, sps_db_object_name2, SPS_FAK_EBA_FLAG, pSource
        INTO gProcessSource.ps_source_obj1, gProcessSource.ps_source_obj2, gProcessSource.ps_fak_eba_flag, gProcessSource.ps_source
        FROM slr_process_source
        WHERE sps_source_name = pSource
        AND sps_active = 'A';

        --check that source and process config fak_eba_flags are the same
        IF(gFakEbaFlag <> gProcessSource.ps_fak_eba_flag) THEN
          RAISE_APPLICATION_ERROR(-20001,'Process config and process source processing level (fak_eba_flag) mismatch.');
        END IF;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001,'Process source '||pSource||' does not exist or is not activated');

      end;
		/*check source*/


		/*check rate set*/
		IF pRateSet IS NOT NULL THEN
          IF (pProcess = 'PLRETEARNINGS' or pProcess = 'FXCLEARDOWN') THEN
            RAISE_APPLICATION_ERROR(-20001,'Rate set parameter ['||pRateSet||'] has been provided.');
          END IF;
		END IF;

		IF (pProcess = 'PLRETEARNINGS' and gWhichAmount <>'L') THEN
			RAISE_APPLICATION_ERROR(-20001,'PLRETEARNINGS can only move LTD. PC_AGGREGATION must be set to L.');
		end if;


		/*check rate set*/


		--for retained earnings last working day of the year must be the same for all entities within entity processing set
		IF(pProcess = 'PLRETEARNINGS') THEN
			BEGIN
        SELECT MAX(c.rnk) into v_count FROM
        (SELECT RANK() OVER (ORDER BY b.ep_bus_period_end) AS rnk FROM
        SLR_BM_ENTITY_PROCESSING_SET LEFT JOIN slr_entity_periods a ON (a.EP_ENTITY = BMEPS_ENTITY)
        LEFT JOIN slr_entity_periods b ON (a.EP_ENTITY = b.EP_ENTITY AND a.EP_BUS_YEAR = b.EP_BUS_YEAR )
        WHERE BMEPS_SET_ID = pEntProcSet
        AND pBalanceDate BETWEEN A.ep_cal_period_start AND A.ep_cal_period_end
        AND b.ep_period_type = 2) c;

        IF v_count > 1 THEN
          RAISE_APPLICATION_ERROR(-20001,'Last working day of the year is not consistent within entity processing set: '||pEntProcSet);
        end if;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        null;

      end;
		end if;

		gBalanceDate := pBalancedate;

		if pBalanceDate is null then

			--check if balance date is the same for all entities within processing set--
			SELECT MAX(a.rnk) into v_count FROM
			(SELECT
				RANK() OVER (ORDER BY ENT_BUSINESS_DATE) AS rnk
				FROM slr_entities where ent_entity in (select BMEPS_ENTITY from SLR_BM_ENTITY_PROCESSING_SET where BMEPS_SET_ID = pEntProcSet)
			) a;

			IF v_count > 1 THEN
				RAISE_APPLICATION_ERROR(-20001,'Entity business date not consistent within entity processing set: '||pEntProcSet);
			end if;

			select ENT_BUSINESS_DATE into gBalanceDate
			from slr_entities,SLR_BM_ENTITY_PROCESSING_SET
			where ent_entity = BMEPS_ENTITY
			AND BMEPS_SET_ID = pEntProcSet
      AND ROWNUM < 2;
    else
			--check if provided date is open for each entity within entity processing set
			SELECT
			count(*) into v_count
			FROM
			SLR_BM_ENTITY_PROCESSING_SET INNER JOIN slr_entities ON (ent_entity = bmeps_entity)
			LEFT JOIN  slr_entity_days a ON (ED_ENTITY_SET = ENT_PERIODS_AND_DAYS_SET)
			LEFT JOIN slr_entity_periods b ON (b.EP_ENTITY = BMEPS_ENTITY)
			WHERE BMEPS_SET_ID = pEntProcSet
			AND ED_DATE =  pBalanceDate
			AND ED_DATE BETWEEN b.ep_cal_period_start AND b.ep_cal_period_end
			AND (nvl(a.ed_status,'C') = 'C' OR nvl(b.ep_status,'C') = 'C')
/*-----------CUSTOMIZATION FROM 20.2.3 MERGE START-----------*/
			AND pProcess <> 'PLRETEARNINGS'  
/*-----------CUSTOMIZATION FROM 20.2.3 MERGE END-----------*/
			;

			if v_count > 0 then
				RAISE_APPLICATION_ERROR(-20001,'Balance date must be a working day for all entities within entity processing set: '||pEntProcSet);
			end if;
		end if;

    gProcess     := pProcess;
    gEntProcSet  := pEntprocset;
    gConfig      := pConfig;
    gSource      := pSource;
    gRateSet     := pRateset;

    --validate that process config explicitly defined segments are in entity processing group dimentions (if defined)
    pBMValidateConfigForEPG;

    SELECT   to_char(SEQ_PROCESS_NUMBER.NEXTVAL)
    INTO     gProcessId
    FROM     DUAL;

	gProcId := gProcessId;
	select sys_context('userenv','SID') SID
	into v_SID
	from DUAL;

    -- Record process in SLR_JOB_STATISTICS
    INSERT INTO SLR_JOB_STATISTICS (
                                  JS_PROCESS_ID,
                                  JS_PROCESS_NAME,
                                  JS_SET_ID,
                                  JS_JRNL_TYPE,
                                  JS_BUSINESS_DATE,
                                  JS_START_TIME,
								  JS_SID
                                  )
                          VALUES (
                                 gProcessId,
                                 gProcess,
                                 gEntProcSet,
                                 gJournalType,
                                 gBalanceDate,
                                 SYSDATE,
								 v_SID
                                 );


        SELECT  i.BLOCK_GETS,CONSISTENT_GETS,PHYSICAL_READS,BLOCK_CHANGES,CONSISTENT_CHANGES
        INTO    gEND_BLOCK_GETS,gEND_CONSISTENT_GETS,gEND_PHYSICAL_READS,gEND_BLOCK_CHANGES,gEND_CONSISTENT_CHANGES
        FROM    V$SESSION s,  V$SESS_IO i
        WHERE s.sid = SYS_CONTEXT('userenv','sid') AND i.SID = s.SID;



        UPDATE SLR_JOB_STATISTICS
        SET     JS_END_TIME         = SYSDATE,
                RESULT_BLOCK_GETS           = gEND_BLOCK_GETS,
                RESULT_CONSISTENT_GETS      = gEND_CONSISTENT_GETS,
                RESULT_PHYSICAL_READS       = gEND_PHYSICAL_READS,
                RESULT_BLOCK_CHANGES        = gEND_BLOCK_CHANGES,
                RESULT_CONSISTENT_CHANGES   = gEND_CONSISTENT_CHANGES
        WHERE   JS_PROCESS_ID = gProcessId
        AND     JS_PROCESS_NAME = gProcess;

		COMMIT;
-----------------------------------------------

    IF pProcess = 'FXREVALUE' THEN
      pBMFxRevaluation(v_lines_count);
    elsif pProcess = 'FXPLSWEEP' THEN
      pBMFxPnLSweep(v_lines_count);
    elsif pProcess = 'FXPOSITION' THEN
      pBMPositionRebalancing(v_lines_count);
    elsif pProcess = 'FXCLEARDOWN' THEN
      pBMFXClearDown(v_lines_count);
    elsif pProcess = 'PLREPATRIATION' THEN
      pBMPLRepatriation(v_lines_count);
    elsif pProcess = 'PLRETEARNINGS' THEN
      pBMPLRetainedEarnings(v_lines_count);
	  ELSE
      RAISE_APPLICATION_ERROR(-20001,'Unsupported process: ' || gProcess);
    end if;

	/*run custom procedure*/
	if gCustomProcedure is not null then
		pBMTraceJob('Custom procedure START', 'call '||gCustomProcedure||'('||gProcessId||')');
		execute immediate 'call '||gCustomProcedure||'('||gProcessId||')';
		pBMTraceJob('Custom procedure END', null);
	end if;

    /*update job statistics record*/
    UPDATE SLR_JOB_STATISTICS
      SET JS_END_TIME = SYSDATE,
          JS_NUMBER_INSERTS = v_lines_count
    WHERE JS_PROCESS_ID = gProcessId;
    /*update job statistics record*/
    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      pr_error(slr_global_pkg.C_MAJERR, null, slr_global_pkg.C_TECHNICAL, vProcName, NULL, NULL, NULL, 'SLR', 'PL/SQL', SQLCODE);
      RAISE_APPLICATION_ERROR(-20001,vProcName||':'||sqlerrm);

  END pBMRunBalanceMovementProcess;


  --helper procedures and functions--
  PROCEDURE pBMProcessError(pEntity in VARCHAR2, pErrorText in VARCHAR2) as
    pragma AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO SLR_PROCESS_ERRORS(SPE_PROCESS_ID, SPE_P_PROCESS, SPE_PC_CONFIG, SPE_SPS_SOURCE_NAME,SPE_BMEPS_SET_ID,SPE_ENTITY, SPE_ERROR_MESSAGE)
    VALUES(gProcessID, gProcess, gConfig, gSource,gEntProcSet, pEntity, pErrorText);
    COMMIT;
  end pBMProcessError;


  PROCEDURE pBMUpdateJLUFakEbaId(pEpgId in slr_jrnl_lines_unposted.jlu_epg_id%type)
  AS
  BEGIN

    SLR_UTILITIES_PKG.pUpdateFakEbaCombinations_Jlu(pEpgId, gProcessId);

  exception
    WHEN others THEN
        IF SQLCODE =-20001 THEN
            RAISE_APPLICATION_ERROR(-20001,'pBMUpdateFakEbaId'||':'||sqlerrm);
        ELSE
            RAISE_APPLICATION_ERROR(-20001,'pBMUpdateFakEbaId'||':'||sqlerrm||';'||dbms_utility.FORMAT_ERROR_STACK||';'||dbms_utility.FORMAT_ERROR_BACKTRACE);
        END IF;

  end pBMUpdateJLUFakEbaId;
  FUNCTION getPeriodMonth (pEntity SLR_ENTITY_PERIODS.EP_ENTITY%type, pEffectiveDate date) RETURN SLR_ENTITY_PERIODS.EP_BUS_PERIOD%type
  AS
    v_period_month SLR_ENTITY_PERIODS.EP_BUS_PERIOD%type;
  BEGIN
    --  dbms_output.put_line('getPeriodMonth called');
      SELECT EP_BUS_PERIOD into v_period_month
      FROM SLR_ENTITY_PERIODS
      WHERE pEffectiveDate BETWEEN EP_CAL_PERIOD_START AND EP_CAL_PERIOD_END
      AND EP_ENTITY = pEntity
      AND EP_PERIOD_TYPE <> 0;

    return v_period_month;
  end getPeriodMonth;

  FUNCTION getPeriodYear (pEntity SLR_ENTITY_PERIODS.EP_ENTITY%type, pEffectiveDate date) RETURN SLR_ENTITY_PERIODS.EP_BUS_YEAR%type
  AS
    v_period_year SLR_ENTITY_PERIODS.EP_BUS_YEAR%type;
  BEGIN
     -- dbms_output.put_line('getPeriodYear called');
      SELECT EP_BUS_YEAR into v_period_year
      FROM SLR_ENTITY_PERIODS
      WHERE pEffectiveDate BETWEEN EP_CAL_PERIOD_START AND EP_CAL_PERIOD_END
      AND EP_ENTITY = pEntity
      AND EP_PERIOD_TYPE <> 0;

    RETURN v_period_year;
  end getPeriodYear;

  FUNCTION getPeriodLTD (pEntity SLR_ENTITY_PERIODS.EP_ENTITY%type, pEffectiveDate date, pAccount slr_entity_accounts.EA_ACCOUNT%type) RETURN SLR_ENTITY_PERIODS.EP_BUS_YEAR%type
  AS
    v_period_ltd SLR_ENTITY_PERIODS.EP_BUS_YEAR%type;
  BEGIN
      --dbms_output.put_line('getPeriodLTD called');
      SELECT CASE WHEN EA_ACCOUNT_TYPE_FLAG = 'P' THEN EP_BUS_YEAR ELSE 1 END into v_period_ltd
      FROM slr_entities,SLR_ENTITY_PERIODS,slr_entity_accounts
      WHERE
          ent_entity = pEntity
      AND pEffectiveDate BETWEEN EP_CAL_PERIOD_START AND EP_CAL_PERIOD_END
      AND EP_ENTITY = ent_entity
      AND EP_PERIOD_TYPE <> 0
      AND EA_ACCOUNT = pAccount
      AND EA_ENTITY_SET = ENT_ACCOUNTS_SET;

    RETURN v_period_ltd;
  end getPeriodLTD;


  PROCEDURE pBMValidateFAKdef AS
      s1bc INTEGER;
      s2bc INTEGER;
      s3bc INTEGER;
      s4bc INTEGER;
      s5bc INTEGER;
      s6bc INTEGER;
      s7bc INTEGER;
      s8bc INTEGER;
      s9bc INTEGER;
      s10bc INTEGER;
      entCount INTEGER;
      msg_txt varchar2(200);
    BEGIN
      --check that fak definitions exist for all entities within processing set--
      INSERT INTO SLR_PROCESS_ERRORS(SPE_PROCESS_ID,SPE_P_PROCESS,SPE_PC_CONFIG,SPE_SPS_SOURCE_NAME,SPE_BMEPS_SET_ID,SPE_ENTITY,SPE_ERROR_MESSAGE)
      select gProcessId,gProcess,gConfig,gSource,gEntProcSet,BMEPS_ENTITY
      ,'FAK definitions do not exist for entity['||BMEPS_ENTITY||']'
      FROM SLR_BM_ENTITY_PROCESSING_SET
      WHERE BMEPS_SET_ID = gEntProcSet
      AND NOT EXISTS (SELECT 1 FROM slr_fak_definitions WHERE fd_entity = BMEPS_ENTITY);

      IF (SQL%ROWCOUNT > 0) THEN
        commit;
        RAISE_APPLICATION_ERROR(-20001,'pBMValidateFAKdef: FAK definitions do not exist for one or more entities within entity processing set ['||gEntProcSet||']');
      END IF;

      --balace check must be the same for all entities within processing set--
      SELECT
       abs(SUM(CASE WHEN FD_SEGMENT_1_BALANCE_CHECK = 'Y' THEN 1 ELSE -1 END)),
       abs(SUM(CASE WHEN FD_SEGMENT_2_BALANCE_CHECK = 'Y' THEN 1 ELSE -1 END)),
       abs(SUM(CASE WHEN FD_SEGMENT_3_BALANCE_CHECK = 'Y' THEN 1 ELSE -1 END)),
       abs(SUM(CASE WHEN FD_SEGMENT_4_BALANCE_CHECK = 'Y' THEN 1 ELSE -1 END)),
       abs(SUM(CASE WHEN FD_SEGMENT_5_BALANCE_CHECK = 'Y' THEN 1 ELSE -1 END)),
       abs(SUM(CASE WHEN FD_SEGMENT_6_BALANCE_CHECK = 'Y' THEN 1 ELSE -1 END)),
       abs(SUM(CASE WHEN FD_SEGMENT_7_BALANCE_CHECK = 'Y' THEN 1 ELSE -1 END)),
       abs(SUM(CASE WHEN FD_SEGMENT_8_BALANCE_CHECK = 'Y' THEN 1 ELSE -1 END)),
       abs(SUM(CASE WHEN FD_SEGMENT_9_BALANCE_CHECK = 'Y' THEN 1 ELSE -1 END)),
       abs(SUM(CASE WHEN FD_SEGMENT_10_BALANCE_CHECK = 'Y' THEN 1 ELSE -1 END)),
       COUNT(fd_entity)
      into  s1bc, s2bc, s3bc, s4bc, s5bc, s6bc, s7bc, s8bc, s9bc, s10bc, entCount
      FROM SLR_FAK_DEFINITIONS
      WHERE fd_entity IN (SELECT BMEPS_ENTITY FROM SLR_BM_ENTITY_PROCESSING_SET WHERE BMEPS_SET_ID = gEntProcSet)
      ;

      IF (s1bc <> entCount OR s2bc <> entCount OR s3bc <> entCount OR s4bc <> entCount OR s5bc <> entCount OR s6bc <> entCount OR s7bc <> entCount OR s8bc <> entCount OR s9bc <> entCount OR s10bc <> entCount) THEN
        msg_txt := 'FAK definitions are not consistent for all entities within entity processing set ['||gEntProcSet||']';
        pBMProcessError(null, msg_txt);

        RAISE_APPLICATION_ERROR(-20001,'pBMValidateFAKdef: '|| msg_txt);
      end if;

    END pBMValidateFAKdef;

  PROCEDURE pBMValidateManagementCcy
  AS
  begin
      INSERT INTO SLR_PROCESS_ERRORS(SPE_PROCESS_ID,SPE_P_PROCESS,SPE_PC_CONFIG,SPE_SPS_SOURCE_NAME,SPE_BMEPS_SET_ID,SPE_ENTITY,SPE_ERROR_MESSAGE)
      SELECT gProcessId,gProcess,gConfig,gSource,gEntProcSet,BMEPS_ENTITY
      ,'Management currency not set for entity['||BMEPS_ENTITY||']'
      FROM SLR_BM_ENTITY_PROCESSING_SET
      where BMEPS_SET_ID = gEntProcSet
      and exists (select 1 from slr_entities where ent_entity = BMEPS_ENTITY and ENT_FX_MANAGE_FLAG is null and gFxManageCcy is null);

    IF (SQL%ROWCOUNT > 0) THEN
       COMMIT;
       RAISE_APPLICATION_ERROR(-20001,'pBMValidateManagementCcy: Management currency not set for one or more entities within entity processing set ['||gEntProcSet||']');
    END IF;

  end pBMValidateManagementCcy;

  FUNCTION fBMGetFakBalanceKey
    RETURN gtFAKBalanceKey AS
      fakBalKey gtFAKBalanceKey;
  BEGIN
    --definitions should be the same for all entities, get balance check for the first one--
    SELECT FD_SEGMENT_1_BALANCE_CHECK,FD_SEGMENT_2_BALANCE_CHECK,FD_SEGMENT_3_BALANCE_CHECK,FD_SEGMENT_4_BALANCE_CHECK,
      FD_SEGMENT_5_BALANCE_CHECK,FD_SEGMENT_6_BALANCE_CHECK,FD_SEGMENT_7_BALANCE_CHECK,FD_SEGMENT_8_BALANCE_CHECK,
      FD_SEGMENT_9_BALANCE_CHECK,FD_SEGMENT_10_BALANCE_CHECK
    INTO  fakBalKey
    FROM SLR_FAK_DEFINITIONS, SLR_BM_ENTITY_PROCESSING_SET
    WHERE FD_ENTITY = BMEPS_ENTITY
    AND BMEPS_SET_ID = gEntProcSet
    and rownum < 2;

    RETURN fakBalKey;
  END fBMGetFakBalanceKey;

  FUNCTION fBMGetProcessConfig(config_type IN VARCHAR2)
    return slr_process_config_detail%rowtype
    AS
    processConfig slr_process_config_detail%rowtype;
  BEGIN

    SELECT slr_process_config_detail.*
    into processConfig
    FROM slr_process_config_detail INNER JOIN slr_process_config ON (pcd_pc_config = pc_config AND pcd_pc_p_process = pc_p_process)
		WHERE pcd_pc_config = gConfig AND  pcd_pc_p_process = gProcess AND  pcd_config_type = config_type;

    return processConfig;

    exception
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001,'fBMGetProcessConfig: Configuration type ['||nvl(config_type,' ')||'] not found');
  end fBMGetProcessConfig;

  FUNCTION fBMGenSelectSQL(processConfig in slr_process_config_detail%rowtype)
    RETURN VARCHAR2 AS
    sql_select varchar2(5000) := '';
  begin

    IF processConfig.pcd_entity = '**SOURCE**' THEN sql_select := sql_select||',FC_ENTITY'; ELSE sql_select := sql_select||', '''||processConfig.pcd_entity||''''; END IF; sql_select := sql_select||' TARGET_ENTITY';
    IF processConfig.pcd_account = '**SOURCE**' THEN sql_select := sql_select||', FC_ACCOUNT'; ELSE sql_select := sql_select||', '''||processConfig.pcd_account||''''; END IF; sql_select := sql_select||' FC_ACCOUNT';
    IF processConfig.pcd_segment_1 IS NOT NULL THEN IF processConfig.pcd_segment_1 = '**SOURCE**' THEN sql_select := sql_select||', FC_SEGMENT_1'; ELSE sql_select := sql_select||', '''||processConfig.pcd_segment_1||''''; END IF; ELSE sql_select := sql_select||', null'; END IF; sql_select := sql_select||' FC_SEGMENT_1';
    IF processConfig.pcd_segment_2 IS NOT NULL THEN IF processConfig.pcd_segment_2 = '**SOURCE**' THEN sql_select := sql_select||', FC_SEGMENT_2'; ELSE sql_select := sql_select||', '''||processConfig.pcd_segment_2||''''; END IF; ELSE sql_select := sql_select||', null'; END IF; sql_select := sql_select||' FC_SEGMENT_2';
    IF processConfig.pcd_segment_3 IS NOT NULL THEN IF processConfig.pcd_segment_3 = '**SOURCE**' THEN sql_select := sql_select||', FC_SEGMENT_3'; ELSE sql_select := sql_select||', '''||processConfig.pcd_segment_3||''''; END IF; ELSE sql_select := sql_select||', null'; END IF; sql_select := sql_select||' FC_SEGMENT_3';
    IF processConfig.pcd_segment_4 IS NOT NULL THEN IF processConfig.pcd_segment_4 = '**SOURCE**' THEN sql_select := sql_select||', FC_SEGMENT_4'; ELSE sql_select := sql_select||', '''||processConfig.pcd_segment_4||''''; END IF; ELSE sql_select := sql_select||', null'; END IF; sql_select := sql_select||' FC_SEGMENT_4';
    IF processConfig.pcd_segment_5 IS NOT NULL THEN IF processConfig.pcd_segment_5 = '**SOURCE**' THEN sql_select := sql_select||', FC_SEGMENT_5'; ELSE sql_select := sql_select||', '''||processConfig.pcd_segment_5||''''; END IF; ELSE sql_select := sql_select||', null'; END IF; sql_select := sql_select||' FC_SEGMENT_5';
    IF processConfig.pcd_segment_6 IS NOT NULL THEN IF processConfig.pcd_segment_6 = '**SOURCE**' THEN sql_select := sql_select||', FC_SEGMENT_6'; ELSE sql_select := sql_select||', '''||processConfig.pcd_segment_6||''''; END IF; ELSE sql_select := sql_select||', null'; END IF; sql_select := sql_select||' FC_SEGMENT_6';
    IF processConfig.pcd_segment_7 IS NOT NULL THEN IF processConfig.pcd_segment_7 = '**SOURCE**' THEN sql_select := sql_select||', FC_SEGMENT_7'; ELSE sql_select := sql_select||', '''||processConfig.pcd_segment_7||''''; END IF; ELSE sql_select := sql_select||', null'; END IF; sql_select := sql_select||' FC_SEGMENT_7';
    IF processConfig.pcd_segment_8 IS NOT NULL THEN IF processConfig.pcd_segment_8 = '**SOURCE**' THEN sql_select := sql_select||', FC_SEGMENT_8'; ELSE sql_select := sql_select||', '''||processConfig.pcd_segment_8||''''; END IF; ELSE sql_select := sql_select||', null'; END IF; sql_select := sql_select||' FC_SEGMENT_8';
    IF processConfig.pcd_segment_9 IS NOT NULL THEN IF processConfig.pcd_segment_9 = '**SOURCE**' THEN sql_select := sql_select||', FC_SEGMENT_9'; ELSE sql_select := sql_select||', '''||processConfig.pcd_segment_9||''''; END IF; ELSE sql_select := sql_select||', null'; END IF; sql_select := sql_select||' FC_SEGMENT_9';
    IF processConfig.pcd_segment_10 IS NOT NULL THEN IF processConfig.pcd_segment_10 = '**SOURCE**' THEN sql_select := sql_select||', FC_SEGMENT_10'; ELSE sql_select := sql_select||', '''||processConfig.pcd_segment_10||''''; END IF; ELSE sql_select := sql_select||', null'; END IF; sql_select := sql_select||' FC_SEGMENT_10';
    IF processConfig.pcd_attribute_1 IS NOT NULL THEN IF processConfig.pcd_attribute_1 = '**SOURCE**' THEN sql_select := sql_select||', EC_ATTRIBUTE_1'; ELSE sql_select := sql_select||', '''||processConfig.pcd_attribute_1||''''; END IF; ELSE sql_select := sql_select||', null'; END IF; sql_select := sql_select||' EC_ATTRIBUTE_1';
    IF processConfig.pcd_attribute_2 IS NOT NULL THEN IF processConfig.pcd_attribute_2 = '**SOURCE**' THEN sql_select := sql_select||', EC_ATTRIBUTE_2'; ELSE sql_select := sql_select||', '''||processConfig.pcd_attribute_2||''''; END IF; ELSE sql_select := sql_select||', null'; END IF; sql_select := sql_select||' EC_ATTRIBUTE_2';
    IF processConfig.pcd_attribute_3 IS NOT NULL THEN IF processConfig.pcd_attribute_3 = '**SOURCE**' THEN sql_select := sql_select||', EC_ATTRIBUTE_3'; ELSE sql_select := sql_select||', '''||processConfig.pcd_attribute_3||''''; END IF; ELSE sql_select := sql_select||', null'; END IF; sql_select := sql_select||' EC_ATTRIBUTE_3';
    IF processConfig.pcd_attribute_4 IS NOT NULL THEN IF processConfig.pcd_attribute_4 = '**SOURCE**' THEN sql_select := sql_select||', EC_ATTRIBUTE_4'; ELSE sql_select := sql_select||', '''||processConfig.pcd_attribute_4||''''; END IF; ELSE sql_select := sql_select||', null'; END IF; sql_select := sql_select||' EC_ATTRIBUTE_4';
    IF processConfig.pcd_attribute_5 IS NOT NULL THEN IF processConfig.pcd_attribute_5 = '**SOURCE**' THEN sql_select := sql_select||', EC_ATTRIBUTE_5'; ELSE sql_select := sql_select||', '''||processConfig.pcd_attribute_5||''''; END IF; ELSE sql_select := sql_select||', null'; END IF; sql_select := sql_select||' EC_ATTRIBUTE_5';

    RETURN sql_select;
  END fBMGenSelectSQL;

  FUNCTION fBMGenSelect2SQL(processConfig in slr_process_config_detail%rowtype)
    RETURN VARCHAR2 AS
    sql_select varchar2(5000) := '';
  begin

    IF processConfig.pcd_entity = '**SOURCE**' THEN sql_select := sql_select||',JL_ENTITY'; ELSE sql_select := sql_select||', '''||processConfig.pcd_entity||''''; END IF;
    IF processConfig.pcd_account = '**SOURCE**' THEN sql_select := sql_select||', JL_ACCOUNT'; ELSE sql_select := sql_select||', '''||processConfig.pcd_account||''''; END IF;
    IF processConfig.pcd_segment_1 IS NOT NULL THEN IF processConfig.pcd_segment_1 = '**SOURCE**' THEN sql_select := sql_select||', JL_SEGMENT_1'; ELSE sql_select := sql_select||', '''||processConfig.pcd_segment_1||''''; END IF; ELSE sql_select := sql_select||', null'; END IF;
    IF processConfig.pcd_segment_2 IS NOT NULL THEN IF processConfig.pcd_segment_2 = '**SOURCE**' THEN sql_select := sql_select||', JL_SEGMENT_2'; ELSE sql_select := sql_select||', '''||processConfig.pcd_segment_2||''''; END IF; ELSE sql_select := sql_select||', null'; END IF;
    IF processConfig.pcd_segment_3 IS NOT NULL THEN IF processConfig.pcd_segment_3 = '**SOURCE**' THEN sql_select := sql_select||', JL_SEGMENT_3'; ELSE sql_select := sql_select||', '''||processConfig.pcd_segment_3||''''; END IF; ELSE sql_select := sql_select||', null'; END IF;
    IF processConfig.pcd_segment_4 IS NOT NULL THEN IF processConfig.pcd_segment_4 = '**SOURCE**' THEN sql_select := sql_select||', JL_SEGMENT_4'; ELSE sql_select := sql_select||', '''||processConfig.pcd_segment_4||''''; END IF; ELSE sql_select := sql_select||', null'; END IF;
    IF processConfig.pcd_segment_5 IS NOT NULL THEN IF processConfig.pcd_segment_5 = '**SOURCE**' THEN sql_select := sql_select||', JL_SEGMENT_5'; ELSE sql_select := sql_select||', '''||processConfig.pcd_segment_5||''''; END IF; ELSE sql_select := sql_select||', null'; END IF;
    IF processConfig.pcd_segment_6 IS NOT NULL THEN IF processConfig.pcd_segment_6 = '**SOURCE**' THEN sql_select := sql_select||', JL_SEGMENT_6'; ELSE sql_select := sql_select||', '''||processConfig.pcd_segment_6||''''; END IF; ELSE sql_select := sql_select||', null'; END IF;
    IF processConfig.pcd_segment_7 IS NOT NULL THEN IF processConfig.pcd_segment_7 = '**SOURCE**' THEN sql_select := sql_select||', JL_SEGMENT_7'; ELSE sql_select := sql_select||', '''||processConfig.pcd_segment_7||''''; END IF; ELSE sql_select := sql_select||', null'; END IF;
    IF processConfig.pcd_segment_8 IS NOT NULL THEN IF processConfig.pcd_segment_8 = '**SOURCE**' THEN sql_select := sql_select||', JL_SEGMENT_8'; ELSE sql_select := sql_select||', '''||processConfig.pcd_segment_8||''''; END IF; ELSE sql_select := sql_select||', null'; END IF;
    IF processConfig.pcd_segment_9 IS NOT NULL THEN IF processConfig.pcd_segment_9 = '**SOURCE**' THEN sql_select := sql_select||', JL_SEGMENT_9'; ELSE sql_select := sql_select||', '''||processConfig.pcd_segment_9||''''; END IF; ELSE sql_select := sql_select||', null'; END IF;
    IF processConfig.pcd_segment_10 IS NOT NULL THEN IF processConfig.pcd_segment_10 = '**SOURCE**' THEN sql_select := sql_select||', JL_SEGMENT_10'; ELSE sql_select := sql_select||', '''||processConfig.pcd_segment_10||''''; END IF; ELSE sql_select := sql_select||', null'; END IF;
    IF processConfig.pcd_attribute_1 IS NOT NULL THEN IF processConfig.pcd_attribute_1 = '**SOURCE**' THEN sql_select := sql_select||', JL_ATTRIBUTE_1'; ELSE sql_select := sql_select||', '''||processConfig.pcd_attribute_1||''''; END IF; ELSE sql_select := sql_select||', null'; END IF;
    IF processConfig.pcd_attribute_2 IS NOT NULL THEN IF processConfig.pcd_attribute_2 = '**SOURCE**' THEN sql_select := sql_select||', JL_ATTRIBUTE_2'; ELSE sql_select := sql_select||', '''||processConfig.pcd_attribute_2||''''; END IF; ELSE sql_select := sql_select||', null'; END IF;
    IF processConfig.pcd_attribute_3 IS NOT NULL THEN IF processConfig.pcd_attribute_3 = '**SOURCE**' THEN sql_select := sql_select||', JL_ATTRIBUTE_3'; ELSE sql_select := sql_select||', '''||processConfig.pcd_attribute_3||''''; END IF; ELSE sql_select := sql_select||', null'; END IF;
    IF processConfig.pcd_attribute_4 IS NOT NULL THEN IF processConfig.pcd_attribute_4 = '**SOURCE**' THEN sql_select := sql_select||', JL_ATTRIBUTE_4'; ELSE sql_select := sql_select||', '''||processConfig.pcd_attribute_4||''''; END IF; ELSE sql_select := sql_select||', null'; END IF;
    IF processConfig.pcd_attribute_5 IS NOT NULL THEN IF processConfig.pcd_attribute_5 = '**SOURCE**' THEN sql_select := sql_select||', JL_ATTRIBUTE_5'; ELSE sql_select := sql_select||', '''||processConfig.pcd_attribute_5||''''; END IF; ELSE sql_select := sql_select||', null'; END IF;

    RETURN sql_select;
  END fBMGenSelect2SQL;


  FUNCTION fBMGenGroupBySQL(processConfig IN slr_process_config_detail%rowtype, pPrefix in varchar2)
    RETURN VARCHAR2 AS
    sql_group_by varchar2(5000) :='';
  BEGIN
    sql_group_by := nvl(pPrefix, 'group by FC_ENTITY, FC_ACCOUNT, FC_CCY');

    IF processConfig.pcd_segment_1 IS NOT NULL THEN sql_group_by := sql_group_by||', FC_SEGMENT_1'; END IF;
    IF processConfig.pcd_segment_2 IS NOT NULL THEN sql_group_by := sql_group_by||', FC_SEGMENT_2'; END IF;
    IF processConfig.pcd_segment_3 IS NOT NULL THEN sql_group_by := sql_group_by||', FC_SEGMENT_3'; END IF;
    IF processConfig.pcd_segment_4 IS NOT NULL THEN sql_group_by := sql_group_by||', FC_SEGMENT_4'; END IF;
    IF processConfig.pcd_segment_5 IS NOT NULL THEN sql_group_by := sql_group_by||', FC_SEGMENT_5'; END IF;
    IF processConfig.pcd_segment_6 IS NOT NULL THEN sql_group_by := sql_group_by||', FC_SEGMENT_6'; END IF;
    IF processConfig.pcd_segment_7 IS NOT NULL THEN sql_group_by := sql_group_by||', FC_SEGMENT_7'; END IF;
    IF processConfig.pcd_segment_8 IS NOT NULL THEN sql_group_by := sql_group_by||', FC_SEGMENT_8'; END IF;
    IF processConfig.pcd_segment_9 IS NOT NULL THEN sql_group_by := sql_group_by||', FC_SEGMENT_9'; END IF;
    IF processConfig.pcd_segment_10 IS NOT NULL THEN sql_group_by := sql_group_by||', FC_SEGMENT_10'; END IF;
    IF processConfig.pcd_attribute_1 IS NOT NULL THEN sql_group_by := sql_group_by||', EC_ATTRIBUTE_1'; END IF;
    IF processConfig.pcd_attribute_2 IS NOT NULL THEN sql_group_by := sql_group_by||', EC_ATTRIBUTE_2'; END IF;
    IF processConfig.pcd_attribute_3 IS NOT NULL THEN sql_group_by := sql_group_by||', EC_ATTRIBUTE_3'; END IF;
    IF processConfig.pcd_attribute_4 IS NOT NULL THEN sql_group_by := sql_group_by||', EC_ATTRIBUTE_4'; END IF;
    IF processConfig.pcd_attribute_5 IS NOT NULL THEN sql_group_by := sql_group_by||', EC_ATTRIBUTE_5'; END IF;

    RETURN sql_group_by;
  END fBMGenGroupBySQL;

  FUNCTION fBMGenGroupBy2SQL(processConfig IN slr_process_config_detail%rowtype)
    RETURN VARCHAR2 AS
    sql_group_by varchar2(5000) :='';
  BEGIN
    sql_group_by := 'group by JL_ENTITY, JL_ACCOUNT, JL_TRAN_CCY';

    IF processConfig.pcd_segment_1 IS NOT NULL THEN sql_group_by := sql_group_by||', JL_SEGMENT_1'; END IF;
    IF processConfig.pcd_segment_2 IS NOT NULL THEN sql_group_by := sql_group_by||', JL_SEGMENT_2'; END IF;
    IF processConfig.pcd_segment_3 IS NOT NULL THEN sql_group_by := sql_group_by||', JL_SEGMENT_3'; END IF;
    IF processConfig.pcd_segment_4 IS NOT NULL THEN sql_group_by := sql_group_by||', JL_SEGMENT_4'; END IF;
    IF processConfig.pcd_segment_5 IS NOT NULL THEN sql_group_by := sql_group_by||', JL_SEGMENT_5'; END IF;
    IF processConfig.pcd_segment_6 IS NOT NULL THEN sql_group_by := sql_group_by||', JL_SEGMENT_6'; END IF;
    IF processConfig.pcd_segment_7 IS NOT NULL THEN sql_group_by := sql_group_by||', JL_SEGMENT_7'; END IF;
    IF processConfig.pcd_segment_8 IS NOT NULL THEN sql_group_by := sql_group_by||', JL_SEGMENT_8'; END IF;
    IF processConfig.pcd_segment_9 IS NOT NULL THEN sql_group_by := sql_group_by||', JL_SEGMENT_9'; END IF;
    IF processConfig.pcd_segment_10 IS NOT NULL THEN sql_group_by := sql_group_by||', JL_SEGMENT_10'; END IF;
    IF processConfig.pcd_attribute_1 IS NOT NULL THEN sql_group_by := sql_group_by||', JL_ATTRIBUTE_1'; END IF;
    IF processConfig.pcd_attribute_2 IS NOT NULL THEN sql_group_by := sql_group_by||', JL_ATTRIBUTE_2'; END IF;
    IF processConfig.pcd_attribute_3 IS NOT NULL THEN sql_group_by := sql_group_by||', JL_ATTRIBUTE_3'; END IF;
    IF processConfig.pcd_attribute_4 IS NOT NULL THEN sql_group_by := sql_group_by||', JL_ATTRIBUTE_4'; END IF;
    IF processConfig.pcd_attribute_5 IS NOT NULL THEN sql_group_by := sql_group_by||', JL_ATTRIBUTE_5'; END IF;

    RETURN sql_group_by;
  END fBMGenGroupBy2SQL;

  PROCEDURE pBMValidateProcessConfig(source_config_type IN VARCHAR2, target_config_type IN VARCHAR2) AS
    sourceConfig slr_process_config_detail%rowtype;
    targetConfig slr_process_config_detail%rowtype;
    fakBalKey gtFAKBalanceKey;
    vBc CHAR(1);
    vEPG_DIMENSION_column_name    SLR_ENTITY_PROC_GROUP_CONFIG.EPGC_JLU_COLUMN_NAME%TYPE;
    vSql VARCHAR2(500);
    vDimention VARCHAR2(30);
    vCount integer := 0;
    vSegment SLR_PROCESS_CONFIG_DETAIL.PCD_SEGMENT_2%TYPE;

  BEGIN

	/*check currency set*/
	IF(gProcess = 'FXCLEARDOWN') THEN
		SELECT count(*) INTO vCount
		FROM slr_process_config
		WHERE pc_config = gConfig
		and pc_fx_manage_ccy is not null;

		IF(vCount > 0)THEN
				RAISE_APPLICATION_ERROR(-20001,'Invalid config: '||gConfig||' FX Management Currency cannot be overridden for FX cleardown');
		end if;
	END IF;

	IF(gProcess = 'PLREPATRIATION' OR gProcess = 'FXPLSWEEP') THEN
		SELECT count(*) INTO vCount
		FROM slr_bm_entity_processing_set, slr_process_config, slr_entities
		WHERE bmeps_set_id = gEntProcSet
		and pc_config = gConfig
		and ent_entity = bmeps_entity
		and pc_fx_manage_ccy is not null
		and not exists(SELECT ent_currency_set FROM slr_entity_currencies WHERE ec_entity_set = ent_currency_set and ec_ccy = pc_fx_manage_ccy);

		IF(vCount > 0)THEN
				RAISE_APPLICATION_ERROR(-20001,'Invalid pc_fx_manage_ccy for config: '|| gConfig);
		end if;
	END IF;

    IF(gProcess = 'FXREVALUE') THEN
        SELECT count(*) INTO vCount
        FROM SLR_PROCESS_CONFIG_DETAIL pcd
            LEFT JOIN SLR_FX_TRANSLATION_CONFIG ftc
                ON (coalesce(pcd.PCD_SEGMENT_2,'NVS') = ftc.FTC_GAAP
                AND ftc.FTC_PROCESS_TYPE = 'FX_REVALUATION')
        WHERE coalesce(pcd.PCD_SEGMENT_2,'NVS') <> '**SOURCE**'
        AND pcd.PCD_CONFIG_TYPE='Adjust'
        AND pcd.PCD_PC_CONFIG = gConfig
        AND pcd.PCD_PC_P_PROCESS = gProcess
        AND ftc.FTC_RATE_TYPE IS NULL;

        IF(vCount > 0) THEN
            RAISE_APPLICATION_ERROR(-20001,'Invalid process configuration: ' || gProcess || ' for ' || gConfig || ' for or missing FX Translation Configuration for given Segment 2');
        END IF;
    END IF;

    IF(gProcess = 'FXPOSITION') THEN
        SELECT count(*) INTO vCount
        FROM SLR_PROCESS_CONFIG_DETAIL pcd
                 LEFT JOIN SLR_FX_TRANSLATION_CONFIG ftc
                           ON (coalesce(pcd.PCD_SEGMENT_2,'NVS') = ftc.FTC_GAAP
                               AND ftc.FTC_PROCESS_TYPE = 'FX_REVALUATION'
                               AND ftc.FTC_TARGET_AMOUNT_TYPE = 'Base')
        WHERE coalesce(pcd.PCD_SEGMENT_2,'NVS') <> '**SOURCE**'
          AND pcd.PCD_CONFIG_TYPE='Adjust'
          AND pcd.PCD_PC_CONFIG = gConfig
          AND pcd.PCD_PC_P_PROCESS = gProcess
          AND ftc.FTC_RATE_TYPE IS NULL;

        IF(vCount > 0) THEN
            RAISE_APPLICATION_ERROR(-20001,'Invalid process configuration: ' || gProcess || ' for ' || gConfig || ' for or missing FX Translation Configuration for given Segment 2');
        END IF;
    END IF;

    /*check currency set*/

	--get source config--
    sourceConfig := fBMGetProcessConfig(source_config_type);

    --get target config--
    targetConfig := fBMGetProcessConfig(target_config_type);

    --validate fak definitions--
    pBMValidateFAKdef;

    --get fak balance key--
    fakBalKey := fBMGetFakBalanceKey;

    IF((fakBalKey.s1_bc = 'Y' AND nvl(targetConfig.pcd_segment_1,'*') <> '**SOURCE**' AND nvl(sourceConfig.pcd_segment_1,'*') <> nvl(targetConfig.pcd_segment_1,'*'))
      OR (fakBalKey.s2_bc = 'Y' AND nvl(targetConfig.pcd_segment_2,'*') <> '**SOURCE**' AND nvl(sourceConfig.pcd_segment_2,'*') <> nvl(targetConfig.pcd_segment_2,'*'))
      OR (fakBalKey.s3_bc = 'Y' AND nvl(targetConfig.pcd_segment_3,'*') <> '**SOURCE**' AND nvl(sourceConfig.pcd_segment_3,'*') <> nvl(targetConfig.pcd_segment_3,'*'))
      OR (fakBalKey.s4_bc = 'Y' AND nvl(targetConfig.pcd_segment_4,'*') <> '**SOURCE**' AND nvl(sourceConfig.pcd_segment_4,'*') <> nvl(targetConfig.pcd_segment_4,'*'))
      OR (fakBalKey.s5_bc = 'Y' AND nvl(targetConfig.pcd_segment_5,'*') <> '**SOURCE**' AND nvl(sourceConfig.pcd_segment_5,'*') <> nvl(targetConfig.pcd_segment_5,'*'))
      OR (fakBalKey.s6_bc = 'Y' AND nvl(targetConfig.pcd_segment_6,'*') <> '**SOURCE**' AND nvl(sourceConfig.pcd_segment_6,'*') <> nvl(targetConfig.pcd_segment_6,'*'))
      OR (fakBalKey.s7_bc = 'Y' AND nvl(targetConfig.pcd_segment_7,'*') <> '**SOURCE**' AND nvl(sourceConfig.pcd_segment_7,'*') <> nvl(targetConfig.pcd_segment_7,'*'))
      OR (fakBalKey.s8_bc = 'Y' AND nvl(targetConfig.pcd_segment_8,'*') <> '**SOURCE**' AND nvl(sourceConfig.pcd_segment_8,'*') <> nvl(targetConfig.pcd_segment_8,'*'))
      OR (fakBalKey.s9_bc = 'Y' AND nvl(targetConfig.pcd_segment_9,'*') <> '**SOURCE**' AND nvl(sourceConfig.pcd_segment_9,'*') <> nvl(targetConfig.pcd_segment_9,'*'))
      OR (fakBalKey.s10_bc = 'Y' AND nvl(targetConfig.pcd_segment_10,'*') <> '**SOURCE**' AND nvl(sourceConfig.pcd_segment_10,'*') <> nvl(targetConfig.pcd_segment_10,'*'))
      ) THEN

      pBMProcessError(null, nvl(target_config_type,' ')||' and '||nvl(source_config_type,' ')||' configuration is not compatible with the balance check setup in the FAK definitions for '||gProcess||' and config '||gConfig);

      RAISE_APPLICATION_ERROR(-20001,nvl(target_config_type,' ')||' and '||nvl(source_config_type,' ')||' not compatible with the FAK definitions');
    END IF;

    begin
        SELECT upper(MAX(EPGC_JLU_COLUMN_NAME))
        into vEPG_DIMENSION_column_name
        FROM SLR_ENTITY_PROC_GROUP_CONFIG;

    exception
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    IF vEPG_DIMENSION_column_name IS NOT NULL THEN
       CASE vEPG_DIMENSION_column_name
          WHEN 'JLU_SEGMENT_1' THEN BEGIN vDimention := 'pcd_segment_1'; vBc := fakBalKey.s1_bc; END;
          WHEN 'JLU_SEGMENT_2' THEN BEGIN vDimention := 'pcd_segment_2'; vBc := fakBalKey.s2_bc; END;
          WHEN 'JLU_SEGMENT_3' THEN BEGIN vDimention := 'pcd_segment_3'; vBc := fakBalKey.s3_bc; END;
          WHEN 'JLU_SEGMENT_4' THEN BEGIN vDimention := 'pcd_segment_4'; vBc := fakBalKey.s4_bc; END;
          WHEN 'JLU_SEGMENT_5' THEN BEGIN vDimention := 'pcd_segment_5'; vBc := fakBalKey.s5_bc; END;
          WHEN 'JLU_SEGMENT_6' THEN BEGIN vDimention := 'pcd_segment_6'; vBc := fakBalKey.s6_bc; END;
          WHEN 'JLU_SEGMENT_7' THEN BEGIN vDimention := 'pcd_segment_7'; vBc := fakBalKey.s7_bc; END;
          WHEN 'JLU_SEGMENT_8' THEN BEGIN vDimention := 'pcd_segment_8'; vBc := fakBalKey.s8_bc; END;
          WHEN 'JLU_SEGMENT_9' THEN BEGIN vDimention := 'pcd_segment_9'; vBc := fakBalKey.s9_bc; END;
          WHEN 'JLU_SEGMENT_10' THEN begin vDimention := 'pcd_segment_10'; vBc := fakBalKey.s10_bc; end;
      END CASE;

      vSql := 'SELECT count(*) FROM slr_process_config_detail '
            ||'WHERE pcd_pc_config = :pConfig AND pcd_pc_p_process = :pProcess '
            ||'and '||vDimention||' is not null '
            ||'and exists('
            ||'SELECT 1 '
            ||'FROM SLR_ENTITY_PROC_GROUP, slr_bm_entity_processing_set '
            ||'WHERE '
            ||'EPG_ENTITY = CASE WHEN PCD_ENTITY = ''**SOURCE**'' THEN BMEPS_ENTITY ELSE PCD_ENTITY END '
            ||'AND BMEPS_SET_ID = :pEntProcSet '
            ||'AND epg_dimension IS NOT NULL) '
            ||'and ''Y'' <> :bc';

      pBMTraceJob('pBMValidateProcessConfig',vSql||'; bindings['||gConfig||','||gProcess||','||gEntProcSet||','||vBc||']');

      execute immediate vSql
      INTO vCount
      using gConfig, gProcess, gEntProcSet, vBc;

      IF vCount > 0 THEN
        RAISE_APPLICATION_ERROR(-20001,'Process Config ['||gConfig||'] for process ['||gProcess||'] defines '
                ||vDimention||' value that is also used as dimension in SLR_ENTITY_PROC_GROUP for at least one entity within entity processing set, but FAK definitions balance check is set to ''N''');
      end if;

    END IF;

    exception
      WHEN others THEN
        IF SQLCODE =-20001 THEN
            RAISE_APPLICATION_ERROR(-20001,'pBMValidateProcessConfig: '||sqlerrm);
        ELSE
            RAISE_APPLICATION_ERROR(-20001,'pBMValidateProcessConfig: '||dbms_utility.FORMAT_ERROR_STACK||';'||dbms_utility.FORMAT_ERROR_BACKTRACE);
        END IF;
  END pBMValidateProcessConfig;

  procedure pBMValidateConfigForEPG
  AS
    vEPG_DIMENSION_column_name    SLR_ENTITY_PROC_GROUP_CONFIG.EPGC_JLU_COLUMN_NAME%TYPE;
    vSql VARCHAR2(500);
    vDimention VARCHAR2(30);
    vCount integer := 0;
  begin
    begin
        SELECT upper(MAX(EPGC_JLU_COLUMN_NAME))
        into vEPG_DIMENSION_column_name
        FROM SLR_ENTITY_PROC_GROUP_CONFIG;

    exception
      WHEN NO_DATA_FOUND THEN
        NULL;
    end;

    if vEPG_DIMENSION_column_name is not null then
      CASE vEPG_DIMENSION_column_name
          WHEN 'JLU_SEGMENT_1' THEN vDimention := 'pcd_segment_1';
          WHEN 'JLU_SEGMENT_2' THEN vDimention := 'pcd_segment_2';
          WHEN 'JLU_SEGMENT_3' THEN vDimention := 'pcd_segment_3';
          WHEN 'JLU_SEGMENT_4' THEN vDimention := 'pcd_segment_4';
          WHEN 'JLU_SEGMENT_5' THEN vDimention := 'pcd_segment_5';
          WHEN 'JLU_SEGMENT_6' THEN vDimention := 'pcd_segment_6';
          WHEN 'JLU_SEGMENT_7' THEN vDimention := 'pcd_segment_7';
          WHEN 'JLU_SEGMENT_8' THEN vDimention := 'pcd_segment_8';
          WHEN 'JLU_SEGMENT_9' THEN vDimention := 'pcd_segment_9';
          WHEN 'JLU_SEGMENT_10' THEN vDimention := 'pcd_segment_10';
      END CASE;

      vSql := 'SELECT count(*) FROM slr_process_config_detail '
           ||'WHERE pcd_pc_config = :pConfig AND  pcd_pc_p_process = :pProcess '
           ||'and nvl('||vDimention||',''**SOURCE**'') <> ''**SOURCE**'' '
           ||'and not exists('
           ||'SELECT 1 '
           ||'FROM SLR_ENTITY_PROC_GROUP, slr_bm_entity_processing_set '
           ||'WHERE '
           ||'EPG_ENTITY = CASE WHEN PCD_ENTITY = ''**SOURCE**'' THEN BMEPS_ENTITY ELSE PCD_ENTITY END '
           ||'AND BMEPS_SET_ID = :pEntProcSet '
           ||'AND (epg_dimension IS NULL OR epg_dimension = '||vDimention||'))';

      EXECUTE IMMEDIATE vSql
      into vCount
      USING gConfig, gProcess, gEntProcSet;

      IF vCount > 0 THEN
        RAISE_APPLICATION_ERROR(-20001,'Process Config ['||gConfig||'] for process ['||gProcess||'] defines '||vDimention||' value that does not exist in SLR_ENTITY_PROC_GROUP');
      end if;
    END IF;

    exception
      WHEN others THEN
          IF SQLCODE =-20001 THEN
              RAISE_APPLICATION_ERROR(-20001,'pBMValidateConfigForEPG: '||sqlerrm);
          ELSE
              RAISE_APPLICATION_ERROR(-20001,'pBMValidateConfigForEPG: '||dbms_utility.FORMAT_ERROR_STACK||';'||dbms_utility.FORMAT_ERROR_BACKTRACE);
          END IF;
  end pBMValidateConfigForEPG;

  PROCEDURE pBMCreateOffset AS
    processConfig slr_process_config_detail%rowtype;
    v_insert_stmt VARCHAR2(1000);
    v_stmt VARCHAR2(6000);
	  v_sel_stmt VARCHAR2(3000);
	  v_from_clause VARCHAR2(1500);
  BEGIN
    --get offset config--
    processConfig := fBMGetProcessConfig('Offset');

    v_insert_stmt := 'insert into SLR_JRNL_LINES_TEMP (jl_description,jl_effective_date,jl_value_date,'
                  ||'jl_tran_ccy,jl_tran_amount,jl_local_ccy,jl_local_amount,jl_local_rate,jl_base_ccy,jl_base_amount,jl_base_rate,jl_jrnl_type,jl_type'
                  ||',jl_jrnl_internal_period_flag,jl_jrnl_ent_rate_set'
                  ||',jl_entity,jl_account,jl_segment_1,jl_segment_2,jl_segment_3,jl_segment_4,jl_segment_5,jl_segment_6,jl_segment_7,'
                  ||'jl_segment_8,jl_segment_9,jl_segment_10,jl_attribute_1,jl_attribute_2,jl_attribute_3,jl_attribute_4,'
                  ||'jl_attribute_5)';

    v_sel_stmt := ' select ';
    v_sel_stmt := v_sel_stmt ||':pcd_description,jl_effective_date,jl_value_date';

    --tran currency--
    v_sel_stmt := v_sel_stmt || ',jl_tran_ccy';

    --tran amount--
    v_sel_stmt := v_sel_stmt ||',jl_tran_amount*(-1)';

    --local currency--
    v_sel_stmt := v_sel_stmt || ',jl_local_ccy';

    ---local amount--
    v_sel_stmt := v_sel_stmt ||',jl_local_amount*(-1)';

    ---local rate--
    v_sel_stmt := v_sel_stmt ||',jl_local_rate';

    --base currency--
    v_sel_stmt := v_sel_stmt || ',jl_base_ccy';

    ---base amount--
    v_sel_stmt := v_sel_stmt ||',jl_base_amount*(-1)';

    ---base rate--
    v_sel_stmt := v_sel_stmt ||',jl_base_rate';

    --jrnl_type
    v_sel_stmt := v_sel_stmt || ',jl_jrnl_type';

    --line_type--
    v_sel_stmt := v_sel_stmt || ',''Offset''';

    v_sel_stmt := v_sel_stmt || ',jl_jrnl_internal_period_flag,jl_jrnl_ent_rate_set';

    v_sel_stmt := v_sel_stmt||fBMGenSelect2SQL(processConfig);

    v_from_clause  := ' from SLR_JRNL_LINES_TEMP ';

    v_stmt := v_insert_stmt || v_sel_stmt||v_from_clause||' where jl_type = ''Adjust''';

    pBMTraceJob('OFFSET',v_stmt||'; bindings['||processConfig.pcd_description||']');
    EXECUTE IMMEDIATE v_stmt USING processConfig.pcd_description;

    exception
      WHEN others THEN
          IF SQLCODE =-20001 THEN
              RAISE_APPLICATION_ERROR(-20001,'pBMCreateOffset: '||sqlerrm);
          ELSE
              RAISE_APPLICATION_ERROR(-20001,'pBMCreateOffset: '||dbms_utility.FORMAT_ERROR_STACK||';'||dbms_utility.FORMAT_ERROR_BACKTRACE);
          END IF;
  END pBMCreateOffset;

  PROCEDURE pBMCreateNostro AS
    processConfig slr_process_config_detail%rowtype;
    v_insert_stmt VARCHAR2(1000);
    v_stmt VARCHAR2(6000);
	  v_sel_stmt VARCHAR2(3000);
	  v_from_clause VARCHAR2(1500);
  BEGIN
    --get offset config--
    processConfig := fBMGetProcessConfig('Nostro');

    v_insert_stmt := 'insert into SLR_JRNL_LINES_TEMP (jl_description,jl_effective_date,jl_value_date,'
                  ||'jl_tran_ccy,jl_tran_amount,jl_local_ccy,jl_local_amount,jl_local_rate,jl_base_ccy,jl_base_amount,jl_base_rate,jl_jrnl_type,jl_type'
                  ||',jl_jrnl_internal_period_flag,jl_jrnl_ent_rate_set'
                  ||',jl_entity,jl_account,jl_segment_1,jl_segment_2,jl_segment_3,jl_segment_4,jl_segment_5,jl_segment_6,jl_segment_7,'
                  ||'jl_segment_8,jl_segment_9,jl_segment_10,jl_attribute_1,jl_attribute_2,jl_attribute_3,jl_attribute_4,'
                  ||'jl_attribute_5)';

    v_sel_stmt := ' select ';
    v_sel_stmt := v_sel_stmt ||':pcd_description,jl_effective_date,jl_value_date';

    --tran currency--
    v_sel_stmt := v_sel_stmt || ',jl_tran_ccy';

    --tran amount--
    v_sel_stmt := v_sel_stmt ||',jl_tran_amount*(-1)';

    --local currency--
    v_sel_stmt := v_sel_stmt || ',jl_local_ccy';

    ---local amount--
    v_sel_stmt := v_sel_stmt ||',jl_local_amount*(-1)';

    ---local rate--
    v_sel_stmt := v_sel_stmt ||',jl_local_rate';

    --base currency--
    v_sel_stmt := v_sel_stmt || ',jl_base_ccy';

    ---base amount--
    v_sel_stmt := v_sel_stmt ||',jl_base_amount*(-1)';

    ---base rate--
    v_sel_stmt := v_sel_stmt ||',jl_base_rate';

    --jrnl_type
    v_sel_stmt := v_sel_stmt || ',jl_jrnl_type';

    --line_type--
    v_sel_stmt := v_sel_stmt || ',''Nostro''';

    v_sel_stmt := v_sel_stmt || ',jl_jrnl_internal_period_flag,jl_jrnl_ent_rate_set';

    v_sel_stmt := v_sel_stmt||fBMGenSelect2SQL(processConfig);

    v_from_clause  := ' from SLR_JRNL_LINES_TEMP ';

    v_stmt := v_insert_stmt || v_sel_stmt||v_from_clause||' where jl_type = ''Post''';

    pBMTraceJob('NOSTRO',v_stmt||'; bindings['||processConfig.pcd_description||']');
    EXECUTE IMMEDIATE v_stmt USING processConfig.pcd_description;

    exception
      WHEN others THEN
          IF SQLCODE =-20001 THEN
              RAISE_APPLICATION_ERROR(-20001,'pBMCreateNostro: '||sqlerrm);
          ELSE
              RAISE_APPLICATION_ERROR(-20001,'pBMCreateNostro: '||dbms_utility.FORMAT_ERROR_STACK||';'||dbms_utility.FORMAT_ERROR_BACKTRACE);
          END IF;
  END pBMCreateNostro;

  FUNCTION fBMGetEPGId(pEntity slr_jrnl_lines_temp.jl_entity%TYPE
                                      ,pS1 slr_jrnl_lines_temp.jl_segment_1%TYPE
                                      ,pS2 slr_jrnl_lines_temp.jl_segment_2%type
                                      ,pS3 slr_jrnl_lines_temp.jl_segment_3%TYPE
                                      ,pS4 slr_jrnl_lines_temp.jl_segment_4%TYPE
                                      ,pS5 slr_jrnl_lines_temp.jl_segment_5%TYPE
                                      ,pS6 slr_jrnl_lines_temp.jl_segment_6%TYPE
                                      ,pS7 slr_jrnl_lines_temp.jl_segment_7%TYPE
                                      ,pS8 slr_jrnl_lines_temp.jl_segment_8%TYPE
                                      ,pS9 slr_jrnl_lines_temp.jl_segment_9%TYPE
                                      ,pS10 slr_jrnl_lines_temp.jl_segment_10%TYPE)
  RETURN slr_jrnl_lines_unposted.jlu_epg_id%TYPE AS
    vEPG_DIMENSION_column_name    SLR_ENTITY_PROC_GROUP_CONFIG.EPGC_JLU_COLUMN_NAME%TYPE;
    vDimentionValue slr_entity_proc_group.epg_dimension%TYPE;
    vSql VARCHAR2(300);
    vEpgId slr_jrnl_lines_unposted.jlu_epg_id%TYPE;
	vMsgError VARCHAR2(200);
  BEGIN
--dbms_output.put_line('fBMGetEPGId called');
    BEGIN
          SELECT upper(max(EPGC_JLU_COLUMN_NAME))
          INTO vEPG_DIMENSION_column_name
          FROM SLR_ENTITY_PROC_GROUP_CONFIG;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
              -- It is not an error when SLR_ENTITY_PROC_GROUP_CONFIG is empty
              NULL;
      END;

      vSql := ' SELECT DISTINCT EPG_ID '
            ||' FROM SLR_ENTITY_PROC_GROUP '
            ||' WHERE '
            ||' EPG_ENTITY = :pEntity ';

      IF vEPG_DIMENSION_column_name IS NOT NULL THEN
          CASE vEPG_DIMENSION_column_name
            WHEN 'JLU_SEGMENT_1' THEN vDimentionValue:=pS1;
            WHEN 'JLU_SEGMENT_2' THEN vDimentionValue:=pS2;
            WHEN 'JLU_SEGMENT_3' THEN vDimentionValue:=pS3;
            WHEN 'JLU_SEGMENT_4' THEN vDimentionValue:=pS4;
            WHEN 'JLU_SEGMENT_5' THEN vDimentionValue:=pS5;
            WHEN 'JLU_SEGMENT_6' THEN vDimentionValue:=pS6;
            WHEN 'JLU_SEGMENT_7' THEN vDimentionValue:=pS7;
            WHEN 'JLU_SEGMENT_8' THEN vDimentionValue:=pS8;
            WHEN 'JLU_SEGMENT_9' THEN vDimentionValue:=pS9;
            WHEN 'JLU_SEGMENT_10' THEN vDimentionValue:=pS10;
          END CASE;

          vSql := vSql || ' AND (EPG_DIMENSION IS NULL OR EPG_DIMENSION = :pDimmention) ';

          EXECUTE IMMEDIATE vSql
          INTO vEpgId
          USING pEntity,vDimentionValue;
      else

          EXECUTE IMMEDIATE vSql
          INTO vEpgId
          USING pEntity;

      end if;

		SELECT DISTINCT EPG_ID
		INTO vEpgId
		FROM SLR_ENTITY_PROC_GROUP
		WHERE EPG_ID = vEpgId;

      RETURN vEpgId;


		EXCEPTION
			WHEN NO_DATA_FOUND THEN

				IF vDimentionValue IS NULL THEN
					vMsgError := 'fBMGetEPGId: Entity Processing Group not found for EPG_ENTITY = ' || pEntity;
				ELSE
					vMsgError := 'fBMGetEPGId: Entity Processing Group not found for EPG_ENTITY = ' || pEntity || ' and EPG_DIMENSION = ' || vDimentionValue;
				END IF;

				RAISE_APPLICATION_ERROR(-20001,vMsgError);

  END fBMGetEPGId;

  PROCEDURE pBMCreateUnpostedJournals(lines_created out integer) AS
    fakBalKey gtFAKBalanceKey;
    v_stmt varchar2(32000);
    v_group_by_clause VARCHAR2(10000);
    v_sel_cur_sql VARCHAR2(10000);
    v_insert_sql VARCHAR2(10000);
  BEGIN
    --get fak balance key--
    fakBalKey := fBMGetFakBalanceKey;

    --get group by from fak definitions to  group temp lines into journals--
    v_group_by_clause := ' jl_entity||jl_tran_ccy';

    IF(fakBalKey.s1_bc = 'Y') THEN
      v_group_by_clause := v_group_by_clause||'||jl_segment_1';
    END IF;
    IF(fakBalKey.s2_bc = 'Y') THEN
      v_group_by_clause := v_group_by_clause||'||jl_segment_2';
    END IF;
    IF(fakBalKey.s3_bc = 'Y') THEN
      v_group_by_clause := v_group_by_clause||'||jl_segment_3';
    END IF;
    IF(fakBalKey.s4_bc = 'Y') THEN
      v_group_by_clause := v_group_by_clause||'||jl_segment_4';
    END IF;
    IF(fakBalKey.s5_bc = 'Y') THEN
      v_group_by_clause := v_group_by_clause||'||jl_segment_5';
    END IF;
    IF(fakBalKey.s6_bc = 'Y') THEN
      v_group_by_clause := v_group_by_clause||'||jl_segment_6';
    END IF;
    IF(fakBalKey.s7_bc = 'Y') THEN
      v_group_by_clause := v_group_by_clause||'||jl_segment_7';
    END IF;
    IF(fakBalKey.s8_bc = 'Y') THEN
      v_group_by_clause := v_group_by_clause||'||jl_segment_8';
    END IF;
    IF(fakBalKey.s9_bc = 'Y') THEN
      v_group_by_clause := v_group_by_clause||'||jl_segment_9';
    END IF;
    IF(fakBalKey.s10_bc = 'Y') THEN
      v_group_by_clause := v_group_by_clause||'||jl_segment_10';
    END IF;

    v_insert_sql := 'INSERT INTO slr_jrnl_lines_unposted
         (jlu_jrnl_hdr_id, jlu_jrnl_line_number, jlu_epg_id, jlu_fak_id, jlu_eba_id,
          jlu_jrnl_status, jlu_jrnl_status_text, jlu_jrnl_process_id, jlu_description,
          jlu_source_jrnl_id, jlu_effective_date, jlu_value_date, jlu_entity, jlu_account,
          jlu_segment_1, jlu_segment_2, jlu_segment_3, jlu_segment_4, jlu_segment_5, jlu_segment_6,
          jlu_segment_7, jlu_segment_8, jlu_segment_9, jlu_segment_10, jlu_attribute_1, jlu_attribute_2,
          jlu_attribute_3, jlu_attribute_4, jlu_attribute_5, jlu_tran_ccy, jlu_tran_amount, jlu_base_ccy,
          jlu_base_amount, jlu_base_rate, jlu_local_ccy, jlu_local_amount, jlu_local_rate, jlu_created_by,
          jlu_created_on, jlu_amended_by, jlu_amended_on, jlu_jrnl_type, jlu_jrnl_date, jlu_jrnl_description,
          jlu_jrnl_authorised_by, jlu_jrnl_authorised_on, jlu_jrnl_source, jlu_jrnl_source_jrnl_id,
          jlu_jrnl_total_hash_debit, jlu_jrnl_total_hash_credit, jlu_jrnl_internal_period_flag, jlu_jrnl_ent_rate_set, jlu_type,
          jlu_period_month, jlu_period_year, jlu_period_ltd
         )';

    v_sel_cur_sql := '
      SELECT
        standard_hash(c.rnk||''-'||to_char(gProcessId)||''', ''MD5'') AS jl_jrnl_hdr_id,
        rowNo,
        epg_id,
        standard_hash(jl_entity||epg_id||jl_account||jl_segment_1||jl_segment_2||jl_segment_3||jl_segment_4||jl_segment_5||jl_segment_6||jl_segment_7||jl_segment_8||jl_segment_9||jl_segment_10||jl_tran_ccy, ''MD5''),
        standard_hash(
            jl_entity||epg_id||jl_account||jl_segment_1||jl_segment_2||jl_segment_3||jl_segment_4||jl_segment_5||jl_segment_6||jl_segment_7||jl_segment_8||jl_segment_9||jl_segment_10||jl_tran_ccy||
            jl_attribute_1||jl_attribute_2||jl_attribute_3||jl_attribute_4||jl_attribute_5, ''MD5''),
            ''U'',''Unposted'',:pProcessId,
            jl_description,
            0,
            jl_effective_date, jl_value_date, jl_entity, jl_account,
            coalesce(jl_segment_1,''NVS''),coalesce(jl_segment_2,''NVS''),coalesce(jl_segment_3,''NVS''),coalesce(jl_segment_4,''NVS''),coalesce(jl_segment_5,''NVS''),coalesce(jl_segment_6,''NVS''),
            coalesce(jl_segment_7,''NVS''),coalesce(jl_segment_8,''NVS''),coalesce(jl_segment_9,''NVS''),coalesce(jl_segment_10,''NVS''),coalesce(jl_attribute_1,''NVS''),coalesce(jl_attribute_2,''NVS''),
            coalesce(jl_attribute_3,''NVS''), coalesce(jl_attribute_4,''NVS''), coalesce(jl_attribute_5,''NVS''), jl_tran_ccy, jl_tran_amount, jl_base_ccy,
            CASE
              WHEN ent_apply_fx_translation = ''Y'' OR jl_base_amount IS NOT NULL THEN
                  jl_base_amount
              ELSE 0
            END AS jl_base_amount,
            jl_base_rate, jl_local_ccy,
            CASE
              WHEN ent_apply_fx_translation = ''Y'' OR jl_local_amount IS NOT NULL THEN
                  jl_local_amount
              ELSE 0
            END AS jl_local_amount,
            jl_local_rate,
            ''SLR'', sysdate, ''SLR'', sysdate, jl_jrnl_type, jl_effective_date, :pProcess,
            ''SLR'', sysdate, :pConfig,
            0,
            totalHashDebit,
            totalHashCredit,
            jl_jrnl_internal_period_flag, jl_jrnl_ent_rate_set, jl_type, ep_bus_period AS jlu_period_month, ep_bus_year AS jlu_period_year,
            CASE WHEN ea_account_type_flag = ''P'' THEN ep_bus_year else 1 END AS jl_period_ltd
        FROM (
          SELECT b.*
          FROM
            (select
              rank() over (order by '||v_group_by_clause||') AS rnk,
              row_number() over (order by null) AS rowNo,
              (select SLR_BALANCE_MOVEMENT_PKG.fBMGetEPGId(jl_entity, jl_segment_1, jl_segment_2, jl_segment_3, jl_segment_4, jl_segment_5, jl_segment_6, jl_segment_7, jl_segment_8, jl_segment_9, jl_segment_10) from dual) AS epg_id,
              0 AS totalHashDebit,
              0 AS totalHashCredit,
              a.* FROM (
                SELECT
                  max(jl_description) AS jl_description,
                  max(jl_effective_date) AS jl_effective_date,
                  max(jl_value_date) AS jl_value_date,
                  jl_entity,
                  jl_account,
                  nvl(jl_segment_1,''NVS'') AS jl_segment_1,
                  nvl(jl_segment_2,''NVS'') AS jl_segment_2,
                  nvl(jl_segment_3,''NVS'') AS jl_segment_3,
                  nvl(jl_segment_4,''NVS'') AS jl_segment_4,
                  nvl(jl_segment_5,''NVS'') AS jl_segment_5,
                  nvl(jl_segment_6,''NVS'') AS jl_segment_6,
                  nvl(jl_segment_7,''NVS'') AS jl_segment_7,
                  nvl(jl_segment_8,''NVS'') AS jl_segment_8,
                  nvl(jl_segment_9,''NVS'') AS jl_segment_9,
                  nvl(jl_segment_10,''NVS'') AS jl_segment_10,
                  nvl(jl_attribute_1,''NVS'') AS jl_attribute_1,
                  nvl(jl_attribute_2,''NVS'') AS jl_attribute_2,
                  nvl(jl_attribute_3,''NVS'') AS jl_attribute_3,
                  nvl(jl_attribute_4,''NVS'') AS jl_attribute_4,
                  nvl(jl_attribute_5,''NVS'') AS jl_attribute_5,
                  jl_tran_ccy,
                  sum(jl_tran_amount) AS jl_tran_amount,
                  max(jl_base_ccy) AS jl_base_ccy,
                  sum(jl_base_amount) AS jl_base_amount,
                  max(jl_base_rate) AS jl_base_rate,
                  max(jl_local_ccy) AS jl_local_ccy,
                  sum(jl_local_amount) AS jl_local_amount,
                  max(jl_local_rate) AS jl_local_rate,
                  max(jl_jrnl_type) AS jl_jrnl_type,
                  jl_type,
                  max(jl_jrnl_internal_period_flag) AS jl_jrnl_internal_period_flag,
                  max(jl_jrnl_ent_rate_set) AS jl_jrnl_ent_rate_set
                FROM slr_jrnl_lines_temp
                GROUP by jl_entity, jl_account, jl_tran_ccy, jl_segment_1, jl_segment_2, jl_segment_3, jl_segment_4, jl_segment_5,
                  jl_segment_6, jl_segment_7, jl_segment_8, jl_segment_9, jl_segment_10, jl_attribute_1, jl_attribute_2,
                  jl_attribute_3, jl_attribute_4, jl_attribute_5, jl_type
                HAVING sum(jl_tran_amount) <> 0 or sum(jl_base_amount) <> 0 or sum(jl_local_amount) <> 0
        ) a) b) c
          LEFT JOIN slr_entity_periods ON jl_effective_date between ep_cal_period_start AND ep_cal_period_end AND ep_entity = jl_entity AND ep_period_type != 0
          LEFT JOIN slr_entities ON ent_entity = jl_entity
          LEFT JOIN slr_entity_accounts ON ea_account = jl_account AND ea_entity_set = ent_accounts_set';

    v_stmt := v_insert_sql||v_sel_cur_sql;


    pBMTraceJob('pBMCreateUnpostedJournals',v_stmt||';bindings ['||gProcessId||','|| gProcess||','||gConfig||']');

    EXECUTE IMMEDIATE v_stmt USING gProcessId, gProcess, gConfig;

    lines_created := sql%rowcount;

    exception
      WHEN others THEN
          IF SQLCODE =-20001 THEN
              RAISE_APPLICATION_ERROR(-20001,'pBMCreateUnpostedJournals: '||sqlerrm);
          ELSE
              RAISE_APPLICATION_ERROR(-20001,'pBMCreateUnpostedJournals: '||dbms_utility.FORMAT_ERROR_STACK||';'||dbms_utility.FORMAT_ERROR_BACKTRACE);
          END IF;
  end pBMCreateUnpostedJournals;



  --processes--
  PROCEDURE pBMFxRevaluation(lines_created out INTEGER) AS
    processConfig slr_process_config_detail%rowtype;
    v_stmt VARCHAR2(10000);
    v_insert_stmt VARCHAR2(1000);
    v_sel_stmt VARCHAR2(4500);
    v_group_by_clause VARCHAR2(500);
    v_from_clause VARCHAR2(2000);
    v_from_clause2 varchar2(2000);
    v_local_amount varchar2(250);


  BEGIN
    pBMTraceJob(gProcess||' START',null);

    pBMTraceJob('pBMValidateProcessConfig','pBMValidateProcessConfig(''Adjust'',''Offset'')');
    pBMValidateProcessConfig('Adjust','Offset');

    pBMTraceJob(gProcess,'truncate table SLR_JRNL_LINES_TEMP');
    execute immediate 'truncate table SLR_JRNL_LINES_TEMP';

    processConfig := fBMGetProcessConfig('Adjust');

    --pBMGetLatestBalance
    pBMGetLatestBalance(gBalanceDate,gEntProcSet);

    IF gFakEbaFlag = 'E' THEN
      v_from_clause := ' from '||coalesce(gProcessSource.ps_source_obj2, 'SLR_BM_LATEST_BAL_TMP')||' edb inner join slr_fak_combinations on (epg_id = fc_epg_id and FAK_ID = fc_fak_id) ';
      --join to eba_combinations only if config specifies attributes--
      IF(processConfig.pcd_attribute_1 IS NOT NULL OR processConfig.pcd_attribute_2 IS NOT NULL OR processConfig.pcd_attribute_3 IS NOT NULL
          OR processConfig.pcd_attribute_4 IS NOT NULL OR processConfig.pcd_attribute_5 IS NOT NULL) THEN
        v_from_clause := v_from_clause||' inner join slr_eba_combinations on (epg_id = ec_epg_id and KEY_ID = ec_eba_id) ';
        v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and ec_fak_id = fc_fak_id and BMEPS_SET_ID = :pEntProcSet)';
      ELSE
        v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and BMEPS_SET_ID = :pEntProcSet)';
      END IF;

    ELSE
      v_from_clause := ' from '||coalesce(gProcessSource.ps_source_obj2, 'SLR_BM_LATEST_BAL_TMP')||' fdb inner join slr_fak_combinations on (epg_id = fc_epg_id and KEY_ID = fc_fak_id) ';

      v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and BMEPS_SET_ID = :pEntProcSet)';
    end if;
    --validate fx translation config--
    v_stmt := 'INSERT INTO SLR_PROCESS_ERRORS(SPE_PROCESS_ID,SPE_P_PROCESS,SPE_PC_CONFIG,SPE_SPS_SOURCE_NAME,SPE_BMEPS_SET_ID,SPE_ENTITY,SPE_ERROR_MESSAGE)'
        ||' SELECT :pProcessId,:pProcess,:pConfig,:pSource,:pEntProcSet,null'
        ||',v_fx_rate_type||'' FX Translation Config not found for SEGMENTS 2 [''||(listagg(coalesce(FC_SEGMENT_2,''NVS''),'','') WITHIN GROUP (ORDER BY FC_SEGMENT_2))||'']'''
        ||' FROM '
        ||' (SELECT distinct coalesce(FC_SEGMENT_2,''NVS'') as FC_SEGMENT_2 '
        ||',''Local'' v_fx_rate_type'
        ||  v_from_clause
        ||' INNER JOIN SLR_ENTITIES on (fc_entity = ent_entity) '
        ||' LEFT JOIN SLR_FX_TRANSLATION_CONFIG on ('
        ||' fc_entity = FTC_ENTITY '
        ||' AND coalesce(FC_SEGMENT_2,''NVS'') = FTC_GAAP '
        ||' AND FTC_PROCESS_TYPE = ''FX_REVALUATION'''
        ||' AND FTC_TARGET_AMOUNT_TYPE = ''Local'')'
        ||' WHERE FTC_FX_RATE_SET IS NULL'
        ||' UNION ALL'
        ||' SELECT distinct coalesce(FC_SEGMENT_2,''NVS'') as FC_SEGMENT_2 '
        ||',''Base'' v_fx_rate_type'
        ||  v_from_clause
        ||' INNER JOIN SLR_ENTITIES on (fc_entity = ent_entity) '
        ||' LEFT JOIN SLR_FX_TRANSLATION_CONFIG on ('
        ||' fc_entity = FTC_ENTITY '
        ||' AND coalesce(FC_SEGMENT_2,''NVS'') = FTC_GAAP '
        ||' AND FTC_PROCESS_TYPE = ''FX_REVALUATION'''
        ||' AND FTC_TARGET_AMOUNT_TYPE = ''Base'')'
        ||' WHERE FTC_FX_RATE_SET IS NULL)'
        ||' GROUP BY v_fx_rate_type';

    pBMTraceJob('validate FX Translation Config',v_stmt||'; bindings['||gProcessId||','||gProcess||','||gConfig||','||gSource||','||gEntProcSet||','||gEntProcSet||','||gEntProcSet||']');
    EXECUTE IMMEDIATE v_stmt using gProcessId, gProcess, gConfig, gSource, gEntProcSet, gEntProcSet, gEntProcSet;

    IF(sql%rowcount > 0) THEN
        COMMIT;
        RAISE_APPLICATION_ERROR(-20001,'FX Translation Config not found');
    END IF;



    --validate rates--
    v_stmt := 'INSERT INTO SLR_PROCESS_ERRORS(SPE_PROCESS_ID,SPE_P_PROCESS,SPE_PC_CONFIG,SPE_SPS_SOURCE_NAME,SPE_BMEPS_SET_ID,SPE_ENTITY,SPE_ERROR_MESSAGE)'
              ||' select :pProcessId,:pProcess,:pConfig,:pSource,:pEntProcSet,null'
              ||',''Local rate not found for rate set [''||FTC_FX_RATE_SET||''] and date ['||to_char(gBalanceDate,'YYYY-MM-DD')||']'
              ||' from currency [''|| FC_CCY ||''] to currency [''|| ENT_LOCAL_CCY ||'']'''
              ||  v_from_clause
              ||' INNER JOIN SLR_ENTITIES ON (FC_ENTITY = ENT_ENTITY) '
              ||' INNER JOIN SLR_FX_TRANSLATION_CONFIG ON ('
              ||' FC_ENTITY = FTC_ENTITY'
              ||' AND coalesce(FC_SEGMENT_2,''NVS'') = FTC_GAAP'
              ||' AND FTC_TARGET_AMOUNT_TYPE = ''Local'' '
              ||' AND FTC_PROCESS_TYPE = ''FX_REVALUATION'')'
              ||' LEFT JOIN SLR_ENTITY_RATES ON ('
              ||' ER_ENTITY_SET = FTC_FX_RATE_SET'
              ||' AND ER_RATE_TYPE = FTC_RATE_TYPE'
              ||' AND ER_DATE = :pBalanceDate'
              ||' AND ER_CCY_FROM = FC_CCY'
              ||' AND ER_CCY_TO = ENT_LOCAL_CCY)'
              ||' WHERE ER_RATE IS NULL '
              ||' AND FC_CCY <> ENT_LOCAL_CCY '
              ||' GROUP BY FTC_FX_RATE_SET, FC_CCY, ENT_LOCAL_CCY'
              ||' union all '
              ||' select :pProcessId,:pProcess,:pConfig,:pSource,:pEntProcSet,null'
              ||',''Base rate not found for rate set [''||FTC_FX_RATE_SET||''] and date ['||to_char(gBalanceDate,'YYYY-MM-DD')||']'
              ||' from currency [''|| (CASE WHEN FTC_FX_MODE = ''Step-by-Step'' THEN ENT_LOCAL_CCY '
              ||' WHEN FTC_FX_MODE = ''Direct'' THEN FC_CCY END) ||''] to currency [''|| ENT_BASE_CCY ||'']'''
              ||  v_from_clause
              ||' INNER JOIN SLR_ENTITIES on (FC_ENTITY = ENT_ENTITY) '
              ||' INNER JOIN SLR_FX_TRANSLATION_CONFIG on ('
              ||' FC_ENTITY = FTC_ENTITY'
              ||' AND coalesce(FC_SEGMENT_2,''NVS'') = FTC_GAAP'
              ||' AND FTC_TARGET_AMOUNT_TYPE = ''Base'''
              ||' AND FTC_PROCESS_TYPE = ''FX_REVALUATION'')'
              ||' LEFT JOIN SLR_ENTITY_RATES ON ('
              ||' ER_ENTITY_SET = FTC_FX_RATE_SET'
              ||' AND ER_RATE_TYPE = FTC_RATE_TYPE'
              ||' AND ER_DATE = :pBalanceDate'
              ||' AND ER_CCY_FROM = '
              ||' (CASE WHEN FTC_FX_MODE = ''Step-by-Step'' THEN ENT_LOCAL_CCY'
              ||'       WHEN FTC_FX_MODE = ''Direct'' THEN FC_CCY END)'
              ||' AND ER_CCY_TO = ENT_BASE_CCY)'
              ||' WHERE ER_RATE IS NULL '
              ||' AND (CASE WHEN FTC_FX_MODE = ''Step-by-Step'' THEN ENT_LOCAL_CCY'
              ||'       WHEN FTC_FX_MODE = ''Direct'' THEN FC_CCY END) <> ENT_BASE_CCY '
              ||' GROUP BY FTC_FX_RATE_SET, FTC_FX_MODE, FC_CCY, ENT_LOCAL_CCY, ENT_BASE_CCY';

    pBMTraceJob('validate FX RATES',v_stmt||'; bindings['||gProcessId||','||gProcess||','||gConfig||','||gSource||','||gEntProcSet||','||gEntProcSet||','||gBalanceDate||','
                                                          ||gProcessId||','||gProcess||','||gConfig||','||gSource||','||gEntProcSet||','||gEntProcSet||','||gBalanceDate||']');
    EXECUTE IMMEDIATE v_stmt
      using gProcessId,gProcess,gConfig,gSource,gEntProcSet,gEntProcSet,gBalanceDate,gProcessId,gProcess,gConfig,gSource,gEntProcSet,gEntProcSet,gBalanceDate;

    IF(sql%rowcount > 0) THEN
      COMMIT;
      RAISE_APPLICATION_ERROR(-20001,'Rates not found');
		END IF;

    --construct adjustment line insert--
    v_insert_stmt := 'insert into SLR_JRNL_LINES_TEMP (jl_description,jl_effective_date,jl_value_date,'
                  ||'jl_tran_ccy,jl_tran_amount,jl_local_ccy,jl_local_amount,jl_local_rate,jl_base_ccy,jl_base_amount,jl_base_rate,jl_jrnl_type,jl_type,'
                  ||'jl_jrnl_internal_period_flag,jl_jrnl_ent_rate_set,'
                  ||'jl_entity,jl_account,jl_segment_1,jl_segment_2,jl_segment_3,jl_segment_4,jl_segment_5,jl_segment_6,jl_segment_7,'
                  ||'jl_segment_8,jl_segment_9,jl_segment_10,jl_attribute_1,jl_attribute_2,jl_attribute_3,jl_attribute_4,'
                  ||'jl_attribute_5)';

    v_from_clause2 := ' inner join slr_entities on (fc_entity = ent_entity) left join SLR_ENTITY_CURRENCIES bec on (bec.EC_ENTITY_SET = ENT_CURRENCY_SET AND bec.EC_CCY = ENT_BASE_CCY AND bec.EC_STATUS = ''A'')'
                  ||' left join SLR_ENTITY_CURRENCIES lec on (lec.EC_ENTITY_SET = ENT_CURRENCY_SET AND lec.EC_CCY = ENT_LOCAL_CCY AND lec.EC_STATUS = ''A'')'
                  ||' INNER JOIN SLR_FX_TRANSLATION_CONFIG lfxtc ON (FC_ENTITY = lfxtc.FTC_ENTITY AND coalesce(FC_SEGMENT_2,''NVS'') = lfxtc.FTC_GAAP)'
                  ||' INNER JOIN SLR_FX_TRANSLATION_CONFIG bfxtc ON (FC_ENTITY = bfxtc.FTC_ENTITY AND coalesce(FC_SEGMENT_2,''NVS'') = bfxtc.FTC_GAAP)'
                  ||' LEFT JOIN SLR_ENTITY_RATES lr ON '
                  ||' (lr.ER_ENTITY_SET = lfxtc.FTC_FX_RATE_SET'
                  ||' AND lr.ER_RATE_TYPE = lfxtc.FTC_RATE_TYPE'
                  ||' AND lr.ER_DATE = :pBalanceDate'
                  ||' AND lr.ER_CCY_FROM = FC_CCY'
                  ||' AND lr.ER_CCY_TO = ENT_LOCAL_CCY)'
                  ||' LEFT JOIN SLR_ENTITY_RATES br ON '
                  ||' (br.ER_ENTITY_SET = bfxtc.FTC_FX_RATE_SET'
                  ||' AND br.ER_RATE_TYPE = bfxtc.FTC_RATE_TYPE'
                  ||' AND br.ER_DATE = :pBalanceDate'
                  ||' AND br.ER_CCY_FROM = '
                  ||' (CASE WHEN bfxtc.FTC_FX_MODE = ''Step-by-Step'' THEN ENT_LOCAL_CCY'
                  ||'       WHEN bfxtc.FTC_FX_MODE = ''Direct'' THEN FC_CCY END)'
                  ||' AND br.ER_CCY_TO = ENT_BASE_CCY)'
                  ||' WHERE'
                  ||' lfxtc.FTC_TARGET_AMOUNT_TYPE  = ''Local'''
                  ||' AND lfxtc.FTC_PROCESS_TYPE = ''FX_REVALUATION'''
                  ||' AND bfxtc.FTC_TARGET_AMOUNT_TYPE  = ''Base'''
                  ||' AND bfxtc.FTC_PROCESS_TYPE = ''FX_REVALUATION''';

    v_sel_stmt := ' select ';
    v_sel_stmt := v_sel_stmt ||':pcd_description,:pBalanceDate,:pBalanceDate';

    --trans currency--
    v_sel_stmt := v_sel_stmt || ',fc_ccy';

    --trans amount--
    v_sel_stmt := v_sel_stmt || ',0';

    --local currency--
    v_sel_stmt := v_sel_stmt || ',max(ENT_LOCAL_CCY)';

    --local amount--
    v_local_amount := 'Round(sum(TRAN_BALANCE) * max(coalesce(lr.ER_RATE,1)),cast(coalesce(max(lec.EC_DIGITS_AFTER_POINT),2) as integer)) - sum(LOCAL_BALANCE)';
    v_sel_stmt := v_sel_stmt || ',' || v_local_amount;

    --local rate--
    v_sel_stmt := v_sel_stmt || ',max(coalesce(lr.ER_RATE,1))';

    --base currency--
    v_sel_stmt := v_sel_stmt || ',max(ENT_BASE_CCY)';

    --base amount--
    v_sel_stmt := v_sel_stmt || ',CASE
                                    WHEN max(bfxtc.ftc_fx_mode) = ''Step-by-Step'' THEN Round((sum(LOCAL_BALANCE) + ' || v_local_amount || ') * max(coalesce(br.ER_RATE,1)),cast(coalesce(max(bec.EC_DIGITS_AFTER_POINT),2) as integer)) - sum(BASE_BALANCE)
                                    WHEN max(bfxtc.ftc_fx_mode) = ''Direct'' THEN Round(sum(TRAN_BALANCE) * max(coalesce(br.ER_RATE,1)),cast(coalesce(max(bec.EC_DIGITS_AFTER_POINT),2) as integer)) - sum(BASE_BALANCE)
                                  END';

    --base rate--
    v_sel_stmt := v_sel_stmt || ',max(coalesce(br.ER_RATE,1))';

    --jrnl_type
    v_sel_stmt := v_sel_stmt || ',:pJournalType';

    --line_type--
    v_sel_stmt := v_sel_stmt || ',''Adjust''';

    --internal period flag--
    v_sel_stmt := v_sel_stmt || ',''N''';

    --rate set--
    v_sel_stmt := v_sel_stmt || ',null';

    v_sel_stmt := v_sel_stmt ||',TARGET_ENTITY,FC_ACCOUNT,MAX(FC_SEGMENT_1),MAX(FC_SEGMENT_2),MAX(FC_SEGMENT_3),MAX(FC_SEGMENT_4),MAX(FC_SEGMENT_5)'
                             ||',MAX(FC_SEGMENT_6),MAX(FC_SEGMENT_7),MAX(FC_SEGMENT_8),MAX(FC_SEGMENT_9),MAX(FC_SEGMENT_10)'
                             ||',MAX(EC_ATTRIBUTE_1),MAX(EC_ATTRIBUTE_2),MAX(EC_ATTRIBUTE_3),MAX(EC_ATTRIBUTE_4),MAX(EC_ATTRIBUTE_5)';

/*-----------CUSTOMIZATION FROM 20.2.3 MERGE START-----------*/
--  v_sel_stmt := v_sel_stmt ||' from (select BASE_BALANCE,LOCAL_BALANCE,TRAN_BALANCE,FC_CCY,FC_ENTITY'||fBMGenSelectSQL(processConfig);
--  Original line above modified with fHint in three lines below
    v_sel_stmt := v_sel_stmt ||' from (select ';
    v_sel_stmt := v_sel_stmt ||  SLR_UTILITIES_PKG.fHint('AG', 'FX_REVALUATION_ADJUST');
    v_sel_stmt := v_sel_stmt ||' BASE_BALANCE,LOCAL_BALANCE,TRAN_BALANCE,FC_CCY,FC_ENTITY'||fBMGenSelectSQL(processConfig);
/*-----------CUSTOMIZATION FROM 20.2.3 MERGE END-----------*/
    v_group_by_clause := fBMGenGroupBySQL(processConfig,' group by TARGET_ENTITY, FC_ACCOUNT, FC_CCY');

    v_stmt := v_insert_stmt || v_sel_stmt||v_from_clause ||') a '||v_from_clause2||v_group_by_clause;

    pBMTraceJob('ADJUSTMENT',v_stmt||'; bindings['||processConfig.pcd_description||','||gBalanceDate||','||gBalanceDate||','||gJournalType||','||gEntProcSet||','||gBalanceDate||','||gBalanceDate||']');
    EXECUTE IMMEDIATE v_stmt
    using processConfig.pcd_description,gBalanceDate,gBalanceDate,gJournalType,gEntProcSet,gBalanceDate,gBalanceDate;

    --create offset--
    pBMCreateOffset;
    commit;

    --create unposted journals--
    pBMCreateUnpostedJournals(lines_created);

    pBMTraceJob(gProcess||' END',null);

    EXCEPTION
      WHEN OTHERS THEN
        pBMTraceJob(gProcess||' STOPPED',null);

        IF SQLCODE =-20001 THEN
            RAISE_APPLICATION_ERROR(-20001,'pBMFxRevaluation: '||sqlerrm);
        ELSE
            RAISE_APPLICATION_ERROR(-20001,'pBMFxRevaluation: '||dbms_utility.FORMAT_ERROR_STACK||';'||dbms_utility.FORMAT_ERROR_BACKTRACE);
        END IF;

  END pBMFxRevaluation;

  PROCEDURE pBMFxPnLSweep(lines_created out INTEGER) AS
    processConfig slr_process_config_detail%rowtype;
    v_stmt VARCHAR2(9000);
    v_insert_stmt VARCHAR2(1000);
    v_sel_stmt VARCHAR2(4500);
    v_group_by_clause VARCHAR2(500);
    v_from_clause VARCHAR2(2000);
    v_from_clause2 VARCHAR2(100);

  BEGIN
    pBMTraceJob(gProcess||' START',null);

    pBMTraceJob('pBMValidateProcessConfig','pBMValidateProcessConfig(''Adjust'',''Offset'')');
    pBMValidateProcessConfig('Adjust','Offset');

    pBMTraceJob('pBMValidateManagementCcy','pBMValidateManagementCcy');
    pBMValidateManagementCcy;

    pBMTraceJob(gProcess,'truncate table SLR_JRNL_LINES_TEMP');
    execute immediate 'truncate table SLR_JRNL_LINES_TEMP';

    processConfig := fBMGetProcessConfig('Adjust');

    --pBMGetLatestBalance
    pBMGetLatestBalance(gBalanceDate,gEntProcSet);

    IF gFakEbaFlag = 'E' THEN
      v_from_clause := ' from '||nvl(gProcessSource.ps_source_obj2, 'SLR_BM_LATEST_BAL_TMP')||' edb inner join slr_fak_combinations on (epg_id = fc_epg_id and FAK_ID = fc_fak_id) ';

      --join to eba_combinations only if config specifies attributes--
      IF(processConfig.pcd_attribute_1 IS NOT NULL OR processConfig.pcd_attribute_2 IS NOT NULL OR processConfig.pcd_attribute_3 IS NOT NULL
          OR processConfig.pcd_attribute_4 IS NOT NULL OR processConfig.pcd_attribute_5 IS NOT NULL) THEN
        v_from_clause := v_from_clause||' inner join slr_eba_combinations on (epg_id = ec_epg_id and KEY_ID = ec_eba_id) ';
        v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and ec_fak_id = fc_fak_id and BMEPS_SET_ID = :pEntProcSet)';
      ELSE
        v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and BMEPS_SET_ID = :pEntProcSet)';
      END IF;

    ELSE
      v_from_clause := ' from '||nvl(gProcessSource.ps_source_obj2, 'SLR_BM_LATEST_BAL_TMP')||' fdb inner join slr_fak_combinations on (epg_id = fc_epg_id and KEY_ID = fc_fak_id) ';
      v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and BMEPS_SET_ID = :pEntProcSet)';
    end if;

    v_from_clause2 := ' inner join slr_entities on (ent_entity = fc_entity) ';

    --construct adjustment line insert--
    v_insert_stmt := 'insert into SLR_JRNL_LINES_TEMP (jl_description,jl_effective_date,jl_value_date,'
                  ||'jl_tran_ccy,jl_tran_amount,jl_base_ccy, jl_local_ccy,jl_jrnl_type, jl_type,jl_jrnl_internal_period_flag,jl_jrnl_ent_rate_set,'
                  ||'jl_entity,jl_account,jl_segment_1,jl_segment_2,jl_segment_3,jl_segment_4,jl_segment_5,jl_segment_6,jl_segment_7,'
                  ||'jl_segment_8,jl_segment_9,jl_segment_10,jl_attribute_1,jl_attribute_2,jl_attribute_3,jl_attribute_4,'
                  ||'jl_attribute_5)';

    v_sel_stmt := ' select ';
    v_sel_stmt := v_sel_stmt ||':pcd_description,:pBalanceDate,:pBalanceDate';

    --trans currency--
    v_sel_stmt := v_sel_stmt || ',fc_ccy';

    --trans amount--
    v_sel_stmt := v_sel_stmt || ',sum(TRAN_BALANCE)*(-1)';

    v_sel_stmt := v_sel_stmt || ',max(ent_base_ccy),max(ent_local_ccy)';

    --jrnl_type
    v_sel_stmt := v_sel_stmt || ',:pJournalType';

    --line_type--
    v_sel_stmt := v_sel_stmt || ',''Adjust''';

    --internal period flag--
    v_sel_stmt := v_sel_stmt || ',''N''';

    --rate set--
    v_sel_stmt := v_sel_stmt || ',null';

    v_sel_stmt := v_sel_stmt ||',TARGET_ENTITY,FC_ACCOUNT,MAX(FC_SEGMENT_1),MAX(FC_SEGMENT_2),MAX(FC_SEGMENT_3),MAX(FC_SEGMENT_4),MAX(FC_SEGMENT_5)'
                             ||',MAX(FC_SEGMENT_6),MAX(FC_SEGMENT_7),MAX(FC_SEGMENT_8),MAX(FC_SEGMENT_9),MAX(FC_SEGMENT_10)'
                             ||',MAX(EC_ATTRIBUTE_1),MAX(EC_ATTRIBUTE_2),MAX(EC_ATTRIBUTE_3),MAX(EC_ATTRIBUTE_4),MAX(EC_ATTRIBUTE_5)';

    v_sel_stmt := v_sel_stmt ||' from (select TRAN_BALANCE,FC_CCY,FC_ENTITY'||fBMGenSelectSQL(processConfig);

    v_group_by_clause := fBMGenGroupBySQL(processConfig,' group by TARGET_ENTITY, FC_ACCOUNT, FC_CCY');

    v_stmt := v_insert_stmt || v_sel_stmt||v_from_clause||') a '||v_from_clause2 ||v_group_by_clause;

    pBMTraceJob('ADJUSTMENT',v_stmt||'; bindings['||processConfig.pcd_description||','||gBalanceDate||','||gBalanceDate||','||gJournalType||','||gEntProcSet||']');
    EXECUTE IMMEDIATE v_stmt
      using processConfig.pcd_description,gBalanceDate,gBalanceDate,gJournalType,gEntProcSet;

    --validate FX Translation Config--
    pBMTraceJob('Validate FX Translation Config', null);
    INSERT INTO SLR_PROCESS_ERRORS(SPE_PROCESS_ID,SPE_P_PROCESS,SPE_PC_CONFIG,SPE_SPS_SOURCE_NAME,SPE_BMEPS_SET_ID,SPE_ENTITY,SPE_ERROR_MESSAGE)
    SELECT gProcessId,gProcess,gConfig,gSource,gEntProcSet,null,
           ftc_target_amount_type || ' FX Translation Config not found for SEGMENTS 2 ['||(listagg(coalesce(JL_SEGMENT_2,'NVS'),',') WITHIN GROUP (ORDER BY JL_SEGMENT_2))||']'
    FROM
    (SELECT distinct coalesce(JL_SEGMENT_2,'NVS') JL_SEGMENT_2, (CASE WHEN ENT_FX_MANAGE_FLAG = 'B' THEN 'Base' ELSE 'Local' END) as ftc_target_amount_type
    FROM SLR_JRNL_LINES_TEMP
    INNER JOIN SLR_ENTITIES on (jl_entity = ent_entity)
    LEFT JOIN SLR_FX_TRANSLATION_CONFIG on (
    jl_entity = FTC_ENTITY
    AND coalesce(JL_SEGMENT_2,'NVS') = FTC_GAAP
    AND ftc_process_type = 'FX_REVALUATION'
    AND ftc_target_amount_type = (CASE WHEN ENT_FX_MANAGE_FLAG = 'B' THEN 'Base' ELSE 'Local' END))
    WHERE ftc_fx_rate_set IS NULL)
    GROUP BY ftc_target_amount_type;

    IF(sql%rowcount > 0) THEN
        COMMIT;
        RAISE_APPLICATION_ERROR(-20001,'FX Translation Config not found');
    END IF;

    pBMTraceJob('Validate rates', null);
    --validate rates--

    INSERT INTO SLR_PROCESS_ERRORS(SPE_PROCESS_ID,SPE_P_PROCESS,SPE_PC_CONFIG,SPE_SPS_SOURCE_NAME,SPE_BMEPS_SET_ID,SPE_ENTITY,SPE_ERROR_MESSAGE)
    select gProcessId, gProcess, gConfig, gSource, gEntProcSet,null,
    'Rate not found for rate set ['||FTC_FX_RATE_SET||'] and date ['||to_char(gBalanceDate,'YYYY-MM-DD')||'] from currency ['|| JL_TRAN_CCY ||'] to currency ['|| FX_MANAGE_CCY ||']'
    from (
    select FTC_FX_RATE_SET, JL_TRAN_CCY, (CASE when gFxManageCcy is not null then gFxManageCcy WHEN ENT_FX_MANAGE_FLAG = 'B' THEN ENT_BASE_CCY ELSE ENT_LOCAL_CCY END) as FX_MANAGE_CCY
    FROM SLR_JRNL_LINES_TEMP
    INNER JOIN SLR_ENTITIES on (JL_ENTITY = ENT_ENTITY)
    LEFT JOIN SLR_ENTITY_CURRENCIES on (
    EC_ENTITY_SET = ENT_CURRENCY_SET
    AND EC_CCY = ENT_BASE_CCY
    AND EC_STATUS = 'A')
    INNER JOIN SLR_FX_TRANSLATION_CONFIG on (
    JL_ENTITY = FTC_ENTITY
    AND coalesce(JL_SEGMENT_2,'NVS') = FTC_GAAP
    AND FTC_TARGET_AMOUNT_TYPE  = (CASE WHEN ENT_FX_MANAGE_FLAG = 'B' THEN 'Base' ELSE 'Local' END)
    AND FTC_PROCESS_TYPE = 'FX_REVALUATION')
    LEFT JOIN SLR_ENTITY_RATES ON (
    ER_ENTITY_SET = FTC_FX_RATE_SET
    AND ER_RATE_TYPE = FTC_RATE_TYPE
    AND ER_DATE = gBalanceDate
    AND ER_CCY_FROM = JL_TRAN_CCY
    AND ER_CCY_TO = (CASE when gFxManageCcy is not null then gFxManageCcy WHEN ENT_FX_MANAGE_FLAG = 'B' THEN ENT_BASE_CCY ELSE ENT_LOCAL_CCY END))
    WHERE ER_RATE IS NULL
    AND JL_TRAN_CCY <> (CASE when gFxManageCcy is not null then gFxManageCcy WHEN ENT_FX_MANAGE_FLAG = 'B' THEN ENT_BASE_CCY ELSE ENT_LOCAL_CCY END)) missing_rates
    GROUP BY FTC_FX_RATE_SET, JL_TRAN_CCY, FX_MANAGE_CCY;

    IF(sql%rowcount > 0) THEN
        COMMIT;
        RAISE_APPLICATION_ERROR(-20001,'Rates not found');
    END IF;

    --begin create adjustments in management ccy--
    pBMTraceJob('ADJUSTMENT in management ccy', null);

    INSERT INTO SLR_JRNL_LINES_TEMP (JL_DESCRIPTION,JL_EFFECTIVE_DATE,JL_VALUE_DATE,JL_TRAN_CCY,JL_TRAN_AMOUNT,jl_base_ccy, jl_local_ccy
              ,JL_JRNL_TYPE, JL_TYPE,JL_JRNL_INTERNAL_PERIOD_FLAG,JL_JRNL_ENT_RATE_SET,JL_ENTITY,JL_ACCOUNT,JL_SEGMENT_1,JL_SEGMENT_2,JL_SEGMENT_3,JL_SEGMENT_4,JL_SEGMENT_5,JL_SEGMENT_6
              ,JL_SEGMENT_7,JL_SEGMENT_8,JL_SEGMENT_9,JL_SEGMENT_10,JL_ATTRIBUTE_1,JL_ATTRIBUTE_2,JL_ATTRIBUTE_3,JL_ATTRIBUTE_4,JL_ATTRIBUTE_5)
    SELECT JL_DESCRIPTION,JL_EFFECTIVE_DATE,JL_VALUE_DATE,CASE when gFxManageCcy is not null then gFxManageCcy WHEN ENT_FX_MANAGE_FLAG = 'B' THEN ENT_BASE_CCY ELSE ENT_LOCAL_CCY END,
              (-1)*Round(JL_TRAN_AMOUNT * coalesce(ER_RATE,1),cast(nvl(EC_DIGITS_AFTER_POINT,2) as INTEGER)),jl_base_ccy, jl_local_ccy
              ,JL_JRNL_TYPE, JL_TYPE,JL_JRNL_INTERNAL_PERIOD_FLAG,JL_JRNL_ENT_RATE_SET,JL_ENTITY,JL_ACCOUNT,JL_SEGMENT_1,JL_SEGMENT_2,JL_SEGMENT_3,JL_SEGMENT_4,JL_SEGMENT_5,JL_SEGMENT_6
              ,JL_SEGMENT_7,JL_SEGMENT_8,JL_SEGMENT_9,JL_SEGMENT_10,JL_ATTRIBUTE_1,JL_ATTRIBUTE_2,JL_ATTRIBUTE_3,JL_ATTRIBUTE_4,JL_ATTRIBUTE_5
    FROM SLR_JRNL_LINES_TEMP
    INNER JOIN SLR_ENTITIES ON (JL_ENTITY = ENT_ENTITY)
    INNER JOIN SLR_FX_TRANSLATION_CONFIG ON (
                FTC_ENTITY = JL_ENTITY
            AND FTC_GAAP = coalesce(JL_SEGMENT_2,'NVS')
            AND FTC_TARGET_AMOUNT_TYPE = (CASE WHEN ENT_FX_MANAGE_FLAG = 'B' THEN 'Base' ELSE 'Local' END)
            AND FTC_PROCESS_TYPE = 'FX_REVALUATION')
    LEFT JOIN SLR_ENTITY_RATES ON (
        ER_ENTITY_SET = FTC_FX_RATE_SET
        AND ER_RATE_TYPE = FTC_RATE_TYPE
        AND ER_DATE = gBalanceDate
        AND ER_CCY_FROM = JL_TRAN_CCY
        AND ER_CCY_TO = (CASE when gFxManageCcy is not null then gFxManageCcy WHEN ENT_FX_MANAGE_FLAG = 'B' THEN ENT_BASE_CCY ELSE ENT_LOCAL_CCY END))
    LEFT JOIN SLR_ENTITY_CURRENCIES on (
      EC_ENTITY_SET = FTC_FX_RATE_SET
      AND EC_CCY = (CASE when gFxManageCcy is not null then gFxManageCcy WHEN ENT_FX_MANAGE_FLAG = 'B' THEN ENT_BASE_CCY ELSE ENT_LOCAL_CCY END)
      AND EC_STATUS = 'A');

    --create offset--
    pBMCreateOffset;
    commit;

    --create unposted journals--
    pBMCreateUnpostedJournals(lines_created);

    pBMTraceJob(gProcess||' END',null);

    exception
      WHEN OTHERS THEN
        pBMTraceJob(gProcess||' STOPPED',null);
        IF SQLCODE =-20001 THEN
            RAISE_APPLICATION_ERROR(-20001,'pBMFxPnLSweep: '||sqlerrm);
        ELSE
            RAISE_APPLICATION_ERROR(-20001,'pBMFxPnLSweep: '||dbms_utility.FORMAT_ERROR_STACK||';'||dbms_utility.FORMAT_ERROR_BACKTRACE);
        END IF;

  END pBMFxPnLSweep;


  PROCEDURE pBMPositionRebalancing(lines_created out INTEGER) AS
    processConfig slr_process_config_detail%rowtype;
    v_stmt VARCHAR2(12000);
    v_insert_stmt VARCHAR2(1000);
    v_sel_stmt VARCHAR2(3500);
    v_sel_stmt2 VARCHAR2(3500);
    v_group_by_clause VARCHAR2(500);
    v_from_clause VARCHAR2(2000);
    v_from_clause2 VARCHAR2(2000);
    v_sel_cols VARCHAR2(2000);

  BEGIN
    pBMTraceJob(gProcess||' START',null);

    pBMTraceJob('pBMValidateProcessConfig','pBMValidateProcessConfig(''Adjust'',''Offset'')');
    pBMValidateProcessConfig('Adjust','Offset');

    pBMTraceJob(gProcess,'truncate table SLR_JRNL_LINES_TEMP');
    execute immediate 'truncate table SLR_JRNL_LINES_TEMP';

    processConfig := fBMGetProcessConfig('Adjust');

    --pBMGetLatestBalance
    pBMGetLatestBalance(gBalanceDate,gEntProcSet);

    IF gFakEbaFlag = 'E' THEN
      v_from_clause := ' from '||nvl(gProcessSource.ps_source_obj2, 'SLR_BM_LATEST_BAL_TMP')||' edb inner join slr_fak_combinations on (epg_id = fc_epg_id and FAK_ID = fc_fak_id) ';

      --join to eba_combinations only if config specifies attributes--
      IF(processConfig.pcd_attribute_1 IS NOT NULL OR processConfig.pcd_attribute_2 IS NOT NULL OR processConfig.pcd_attribute_3 IS NOT NULL
          OR processConfig.pcd_attribute_4 IS NOT NULL OR processConfig.pcd_attribute_5 IS NOT NULL) THEN
        v_from_clause := v_from_clause||' inner join slr_eba_combinations on (epg_id = ec_epg_id and KEY_ID = ec_eba_id) ';
        v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and ec_fak_id = fc_fak_id and BMEPS_SET_ID = :pEntProcSet)';
      ELSE
        v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and BMEPS_SET_ID = :pEntProcSet)';
      END IF;

    ELSE
      v_from_clause := ' from '||nvl(gProcessSource.ps_source_obj2, 'SLR_BM_LATEST_BAL_TMP')||' fdb inner join slr_fak_combinations on (epg_id = fc_epg_id and KEY_ID = fc_fak_id) ';
      v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and BMEPS_SET_ID = :pEntProcSet)';
    end if;

    --validate fx translation config--
    v_stmt := 'INSERT INTO SLR_PROCESS_ERRORS(SPE_PROCESS_ID,SPE_P_PROCESS,SPE_PC_CONFIG,SPE_SPS_SOURCE_NAME,SPE_BMEPS_SET_ID,SPE_ENTITY,SPE_ERROR_MESSAGE)'
        ||' SELECT :pProcessId,:pProcess,:pConfig,:pSource,:pEntProcSet,null'
        ||',FTC_TARGET_AMOUNT_TYPE || ''FX Translation Config not found for SEGMENTS 2 [''||(listagg(coalesce(FC_SEGMENT_2,''NVS''),'','') WITHIN GROUP (ORDER BY FC_SEGMENT_2))||'']'''
        ||' FROM '
        ||' (SELECT distinct coalesce(FC_SEGMENT_2,''NVS'') as FC_SEGMENT_2, ''Base'' FTC_TARGET_AMOUNT_TYPE '
        ||  v_from_clause
        ||' INNER JOIN SLR_ENTITIES on (fc_entity = ent_entity) '
        ||' LEFT JOIN SLR_FX_TRANSLATION_CONFIG on ('
        ||' fc_entity = FTC_ENTITY '
        ||' AND coalesce(FC_SEGMENT_2,''NVS'') = FTC_GAAP '
        ||' AND ftc_process_type = ''FX_REVALUATION'''
        ||' AND FTC_TARGET_AMOUNT_TYPE  = ''Base'')'
        ||' WHERE ftc_fx_rate_set IS NULL)'
        ||' GROUP BY FTC_TARGET_AMOUNT_TYPE';

    pBMTraceJob('validate FX Translation Config',v_stmt||'; bindings['||gProcessId||','||gProcess||','||gConfig||','||gSource||','||gEntProcSet||','||gEntProcSet||']');
    EXECUTE IMMEDIATE v_stmt using gProcessId, gProcess, gConfig, gSource, gEntProcSet, gEntProcSet;

    IF(sql%rowcount > 0) THEN
        COMMIT;
        RAISE_APPLICATION_ERROR(-20001,'FX Translation Config not found');
    END IF;

    --validate rates--
    v_stmt := 'INSERT INTO SLR_PROCESS_ERRORS(SPE_PROCESS_ID,SPE_P_PROCESS,SPE_PC_CONFIG,SPE_SPS_SOURCE_NAME,SPE_BMEPS_SET_ID,SPE_ENTITY,SPE_ERROR_MESSAGE)'
        ||' select :pProcessId,:pProcess,:pConfig,:pSource,:pEntProcSet,null'
        ||',''Base rate not found for rate set [''||FTC_FX_RATE_SET||''] and date ['||to_char(gBalanceDate,'YYYY-MM-DD')||']'
        ||' from currency [''|| ENT_LOCAL_CCY ||''] to currency [''|| ENT_BASE_CCY ||'']'''
        ||  v_from_clause
        ||' INNER JOIN SLR_ENTITIES on (FC_ENTITY = ENT_ENTITY) '
        ||' left join SLR_ENTITY_CURRENCIES on ('
        ||' EC_ENTITY_SET = ENT_CURRENCY_SET '
        ||' AND EC_CCY = ENT_BASE_CCY '
        ||' AND EC_STATUS = ''A'')'
        ||' INNER JOIN SLR_FX_TRANSLATION_CONFIG on ('
        ||' FC_ENTITY = FTC_ENTITY '
        ||' AND coalesce(FC_SEGMENT_2,''NVS'') = FTC_GAAP '
        ||' AND FTC_TARGET_AMOUNT_TYPE = ''Base'' '
        ||' AND FTC_PROCESS_TYPE = ''FX_REVALUATION'')'
        ||' LEFT JOIN SLR_ENTITY_RATES ON ('
        ||' ER_ENTITY_SET = FTC_FX_RATE_SET'
        ||' AND ER_RATE_TYPE = FTC_RATE_TYPE'
        ||' AND ER_DATE = :pBalanceDate'
        ||' AND ER_CCY_FROM = ENT_LOCAL_CCY'
        ||' AND ER_CCY_TO = ENT_BASE_CCY)'
        ||' WHERE ER_RATE IS NULL '
        ||' AND ENT_LOCAL_CCY <> ENT_BASE_CCY '
        ||' GROUP BY FTC_FX_RATE_SET, ENT_LOCAL_CCY, ENT_BASE_CCY';

    pBMTraceJob('validate FX RATES',v_stmt||'; bindings['||gProcessId||','||gProcess||','||gConfig||','||gSource||','||gEntProcSet||','||gEntProcSet||','||gBalanceDate||']');
    EXECUTE IMMEDIATE v_stmt
        using gProcessId,gProcess,gConfig,gSource,gEntProcSet,gEntProcSet,gBalanceDate;

    IF(sql%rowcount > 0) THEN
        COMMIT;
        RAISE_APPLICATION_ERROR(-20001,'Rates not found');
    END IF;

    --construct adjustment line insert--
    v_insert_stmt := 'insert into SLR_JRNL_LINES_TEMP (jl_description,jl_effective_date,jl_value_date,'
                  ||'jl_tran_ccy,jl_tran_amount,jl_local_ccy,jl_local_amount,jl_local_rate,jl_base_ccy,jl_base_amount,jl_base_rate,jl_jrnl_type,jl_type'
                  ||',jl_jrnl_internal_period_flag,jl_jrnl_ent_rate_set'
                  ||',jl_entity,jl_account,jl_segment_1,jl_segment_2,jl_segment_3,jl_segment_4,jl_segment_5,jl_segment_6,jl_segment_7,'
                  ||'jl_segment_8,jl_segment_9,jl_segment_10,jl_attribute_1,jl_attribute_2,jl_attribute_3,jl_attribute_4,'
                  ||'jl_attribute_5)';

    v_from_clause2 := ' inner join SLR_ENTITIES ON (ENT_ENTITY = FC_ENTITY)'
                  ||' left join SLR_ENTITY_CURRENCIES on (EC_ENTITY_SET = ENT_CURRENCY_SET AND EC_CCY = ENT_BASE_CCY AND EC_STATUS = ''A'')'
                  ||' inner join SLR_FX_TRANSLATION_CONFIG on ('
                  ||' FTC_ENTITY = FC_ENTITY '
                  ||' AND FTC_GAAP = coalesce(FC_SEGMENT_2,''NVS'') '
                  ||' AND FTC_TARGET_AMOUNT_TYPE = ''Base'' '
                  ||' AND FTC_PROCESS_TYPE = ''FX_REVALUATION'') '
                  ||' left join SLR_ENTITY_RATES on'
                  ||' (ER_ENTITY_SET = FTC_FX_RATE_SET'
                  ||' AND ER_RATE_TYPE = FTC_RATE_TYPE'
                  ||' AND ER_DATE = :pBalanceDate'
                  ||' AND ER_CCY_FROM = ENT_LOCAL_CCY'
                  ||' AND ER_CCY_TO = ENT_BASE_CCY) ';

    v_sel_stmt := ' select ';
    v_sel_stmt := v_sel_stmt ||':pcd_description,:pBalanceDate,:pBalanceDate';

    --trans currency--
    v_sel_stmt2 := v_sel_stmt || ',max(ENT_BASE_CCY)';
    v_sel_stmt := v_sel_stmt || ',max(ENT_LOCAL_CCY)';

    --trans amount--
    v_sel_stmt := v_sel_stmt || ',0';
    v_sel_stmt2 := v_sel_stmt2 || ',0';

    --local currency--
    v_sel_stmt := v_sel_stmt || ',max(ENT_LOCAL_CCY)';
    v_sel_stmt2 := v_sel_stmt2 || ',max(ENT_LOCAL_CCY)';

    --local amount--
    v_sel_stmt := v_sel_stmt || ',sum(LOCAL_BALANCE)*(-1)';
    v_sel_stmt2 := v_sel_stmt2 || ',0';

    --local rate--
    v_sel_stmt := v_sel_stmt ||',null';
    v_sel_stmt2 := v_sel_stmt2 ||',null';

    --base currency--
    v_sel_stmt := v_sel_stmt || ',max(ENT_BASE_CCY)';
    v_sel_stmt2 := v_sel_stmt2 || ',max(ENT_BASE_CCY)';

    --base amount--
    v_sel_stmt := v_sel_stmt || ',(-1)*Round(sum(LOCAL_BALANCE)*max(coalesce(ER_RATE,1)),cast(nvl(max(EC_DIGITS_AFTER_POINT),2) as INTEGER))';
    v_sel_stmt2 := v_sel_stmt2 || ',(-1)*sum(BASE_BALANCE) + Round(sum(LOCAL_BALANCE)*max(coalesce(ER_RATE,1)),cast(nvl(max(EC_DIGITS_AFTER_POINT),2) as INTEGER))';

    --base rate--
    v_sel_stmt := v_sel_stmt ||',max(coalesce(ER_RATE,1))';
    v_sel_stmt2 := v_sel_stmt2 ||',null';

    --jrnl_type
    v_sel_stmt := v_sel_stmt || ',:pJournalType';
    v_sel_stmt2 := v_sel_stmt2 || ',:pJournalType';

    --line_type--
    v_sel_stmt := v_sel_stmt || ',''Adjust''';
    v_sel_stmt2 := v_sel_stmt2 || ',''Adjust''';

    --internal period flag--
    v_sel_stmt := v_sel_stmt || ',''N''';
    v_sel_stmt2 := v_sel_stmt2 || ',''N''';

    --rate set--
    v_sel_stmt := v_sel_stmt || ', null';
    v_sel_stmt2 := v_sel_stmt2 || ', null';

    v_sel_stmt := v_sel_stmt ||',TARGET_ENTITY,FC_ACCOUNT,MAX(FC_SEGMENT_1),MAX(FC_SEGMENT_2),MAX(FC_SEGMENT_3),MAX(FC_SEGMENT_4),MAX(FC_SEGMENT_5)'
                             ||',MAX(FC_SEGMENT_6),MAX(FC_SEGMENT_7),MAX(FC_SEGMENT_8),MAX(FC_SEGMENT_9),MAX(FC_SEGMENT_10)'
                             ||',MAX(EC_ATTRIBUTE_1),MAX(EC_ATTRIBUTE_2),MAX(EC_ATTRIBUTE_3),MAX(EC_ATTRIBUTE_4),MAX(EC_ATTRIBUTE_5)';

    v_sel_stmt2 := v_sel_stmt2 ||',TARGET_ENTITY,FC_ACCOUNT,MAX(FC_SEGMENT_1),MAX(FC_SEGMENT_2),MAX(FC_SEGMENT_3),MAX(FC_SEGMENT_4),MAX(FC_SEGMENT_5)'
                             ||',MAX(FC_SEGMENT_6),MAX(FC_SEGMENT_7),MAX(FC_SEGMENT_8),MAX(FC_SEGMENT_9),MAX(FC_SEGMENT_10)'
                             ||',MAX(EC_ATTRIBUTE_1),MAX(EC_ATTRIBUTE_2),MAX(EC_ATTRIBUTE_3),MAX(EC_ATTRIBUTE_4),MAX(EC_ATTRIBUTE_5)';

    v_sel_cols := fBMGenSelectSQL(processConfig);

    v_sel_stmt := v_sel_stmt ||' from (select LOCAL_BALANCE,FC_ENTITY'||v_sel_cols;
    v_sel_stmt2 := v_sel_stmt2 ||' from (select LOCAL_BALANCE, BASE_BALANCE,FC_ENTITY'||v_sel_cols;

    v_group_by_clause := fBMGenGroupBySQL(processConfig,' group by TARGET_ENTITY,fc_account');

    v_stmt := v_insert_stmt || v_sel_stmt||v_from_clause ||') a '||v_from_clause2||v_group_by_clause||' UNION ALL '||v_sel_stmt2||v_from_clause ||') b '||v_from_clause2||v_group_by_clause;

    pBMTraceJob('ADJUSTMENT',v_stmt||'; bindings['||processConfig.pcd_description||','||gBalanceDate||','||gBalanceDate||','||gJournalType||','||gEntProcSet||','||gBalanceDate||','
                                                  ||processConfig.pcd_description||','||gBalanceDate||','||gBalanceDate||','||gJournalType||','||gEntProcSet||','||gBalanceDate||']');
    EXECUTE IMMEDIATE v_stmt
      USING processConfig.pcd_description,gBalanceDate,gBalanceDate,gJournalType,gEntProcSet,gBalanceDate
            ,processConfig.pcd_description,gBalanceDate,gBalanceDate,gJournalType,gEntProcSet,gBalanceDate;

    --create offset--
    pBMCreateOffset;
    commit;

    --create unposted journals--
    pBMCreateUnpostedJournals(lines_created);

    pBMTraceJob(gProcess||' END',null);

    exception
      WHEN OTHERS THEN
        pBMTraceJob(gProcess||' STOPPED',null);
        IF SQLCODE =-20001 THEN
            RAISE_APPLICATION_ERROR(-20001,'pBMPositionRebalancing: '||sqlerrm);
        ELSE
            RAISE_APPLICATION_ERROR(-20001,'pBMPositionRebalancing: '||dbms_utility.FORMAT_ERROR_STACK||';'||dbms_utility.FORMAT_ERROR_BACKTRACE);
        END IF;

  END pBMPositionRebalancing;

-------------------------------------------------------------------------------------------------------------------------------------------

  PROCEDURE pBMFXClearDown(lines_created out INTEGER) AS
    processConfig slr_process_config_detail%rowtype;
    v_stmt VARCHAR2(10000);
    v_insert_stmt VARCHAR2(1000);
    v_sel_stmt VARCHAR2(3500);
    v_group_by_clause VARCHAR2(500);
    v_from_clause VARCHAR2(2000);
    v_sel_cols VARCHAR2(2000);

  BEGIN
    pBMTraceJob(gProcess||' START',null);

    pBMTraceJob('pBMValidateProcessConfig','pBMValidateProcessConfig(''Adjust'',''Offset'')');
    pBMValidateProcessConfig('Adjust','Offset');

    pBMTraceJob('pBMValidateProcessConfig','pBMValidateProcessConfig(''Post'',''Nostro'')');
    pBMValidateProcessConfig('Post','Nostro');

    pBMTraceJob('pBMValidateManagementCcy','pBMValidateManagementCcy');
    pBMValidateManagementCcy;

    pBMTraceJob(gProcess,'truncate table SLR_JRNL_LINES_TEMP');
    EXECUTE IMMEDIATE 'truncate table SLR_JRNL_LINES_TEMP';

    processConfig := fBMGetProcessConfig('Adjust');

    --pBMGetLatestBalance
    pBMGetLatestBalance(gBalanceDate,gEntProcSet);

    IF gFakEbaFlag = 'E' THEN
      v_from_clause := ' from '||nvl(gProcessSource.ps_source_obj2, 'SLR_BM_LATEST_BAL_TMP')||' edb inner join slr_fak_combinations on (epg_id = fc_epg_id and FAK_ID = fc_fak_id) ';

      --join to eba_combinations only if config specifies attributes--
      IF(processConfig.pcd_attribute_1 IS NOT NULL OR processConfig.pcd_attribute_2 IS NOT NULL OR processConfig.pcd_attribute_3 IS NOT NULL
          OR processConfig.pcd_attribute_4 IS NOT NULL OR processConfig.pcd_attribute_5 IS NOT NULL) THEN
        v_from_clause := v_from_clause||' inner join slr_eba_combinations on (epg_id = ec_epg_id and KEY_ID = ec_eba_id) ';
        v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and ec_fak_id = fc_fak_id and BMEPS_SET_ID = :pEntProcSet)';
      ELSE
        v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and BMEPS_SET_ID = :pEntProcSet)';
      END IF;

    ELSE
      v_from_clause := ' from '||nvl(gProcessSource.ps_source_obj2, 'SLR_BM_LATEST_BAL_TMP')||' fdb inner join slr_fak_combinations on (epg_id = fc_epg_id and KEY_ID = fc_fak_id) ';
      v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and BMEPS_SET_ID = :pEntProcSet)';
    END IF;

      v_from_clause := v_from_clause||' inner join SLR_ENTITIES ON (ENT_ENTITY = FC_ENTITY)';

    --adjustment--
    v_insert_stmt := 'insert into SLR_JRNL_LINES_TEMP (jl_description,jl_effective_date,jl_value_date,'
                  ||'jl_tran_ccy,jl_tran_amount,jl_local_ccy,jl_local_amount,jl_local_rate,jl_base_ccy,jl_base_amount,jl_base_rate,jl_jrnl_type,jl_type'
                  ||',jl_jrnl_internal_period_flag,jl_jrnl_ent_rate_set'
                  ||',jl_entity,jl_account,jl_segment_1,jl_segment_2,jl_segment_3,jl_segment_4,jl_segment_5,jl_segment_6,jl_segment_7,'
                  ||'jl_segment_8,jl_segment_9,jl_segment_10,jl_attribute_1,jl_attribute_2,jl_attribute_3,jl_attribute_4,'
                  ||'jl_attribute_5)';

    v_sel_stmt := ' select ';
    v_sel_stmt := v_sel_stmt ||':pcd_description,:pBalanceDate,:pBalanceDate';

    --trans currency--
    v_sel_stmt := v_sel_stmt || ',fc_ccy';
    --trans amount--
    v_sel_stmt := v_sel_stmt || ',sum(TRAN_BALANCE)*(-1)';

    --local ccy
    v_sel_stmt := v_sel_stmt || ',max(ent_local_ccy)';
    --local amount--
    v_sel_stmt := v_sel_stmt || ',sum(LOCAL_BALANCE)*(-1)';
    --local rate
    v_sel_stmt := v_sel_stmt ||',null';

    --base ccy
    v_sel_stmt := v_sel_stmt || ',max(ent_base_ccy)';
    --base amount--
    v_sel_stmt := v_sel_stmt || ',sum(BASE_BALANCE)*(-1)';
    --base rate
    v_sel_stmt := v_sel_stmt ||',null';

    --jrnl_type
    v_sel_stmt := v_sel_stmt || ',:pJournalType';

    --line_type--
    v_sel_stmt := v_sel_stmt || ',''Adjust''';

    --internal period flag--
    v_sel_stmt := v_sel_stmt || ',''N''';

    --rate set--
    v_sel_stmt := v_sel_stmt || ',null';

    v_sel_cols := fBMGenSelectSQL(processConfig);

    v_group_by_clause := fBMGenGroupBySQL(processConfig,null);

    v_stmt := v_insert_stmt||v_sel_stmt||v_sel_cols||v_from_clause||v_group_by_clause;

    pBMTraceJob('ADJUSTMENT',v_stmt||'; bindings['||processConfig.pcd_description||','||gBalanceDate||','||gBalanceDate||','||gJournalType||','||gEntProcSet||']');
    EXECUTE IMMEDIATE v_stmt
      USING processConfig.pcd_description,gBalanceDate,gBalanceDate,gJournalType,gEntProcSet;

    --adjustments in management ccy--
    pBMTraceJob('ADJUSTMENT in management ccy', null);

    insert into SLR_JRNL_LINES_TEMP (jl_description,jl_effective_date,jl_value_date,
                  jl_tran_ccy,jl_tran_amount,jl_local_ccy,jl_local_amount,jl_local_rate,jl_base_ccy,jl_base_amount,jl_base_rate,jl_jrnl_type,jl_type
                  ,jl_jrnl_internal_period_flag,jl_jrnl_ent_rate_set
                  ,jl_entity,jl_account,jl_segment_1,jl_segment_2,jl_segment_3,jl_segment_4,jl_segment_5,jl_segment_6,jl_segment_7,
                  jl_segment_8,jl_segment_9,jl_segment_10,jl_attribute_1,jl_attribute_2,jl_attribute_3,jl_attribute_4,
                  jl_attribute_5)
    SELECT JL_DESCRIPTION,JL_EFFECTIVE_DATE,JL_VALUE_DATE,CASE WHEN ENT_FX_MANAGE_FLAG = 'B' THEN ENT_BASE_CCY ELSE ENT_LOCAL_CCY END,
           CASE WHEN ENT_FX_MANAGE_FLAG = 'B' THEN JL_BASE_AMOUNT*(-1) ELSE JL_LOCAL_AMOUNT*(-1) END,jl_local_ccy, JL_LOCAL_AMOUNT*(-1),NULL,jl_base_ccy, JL_BASE_AMOUNT*(-1),NULL
           ,JL_JRNL_TYPE, JL_TYPE,JL_JRNL_INTERNAL_PERIOD_FLAG,JL_JRNL_ENT_RATE_SET,JL_ENTITY,JL_ACCOUNT,JL_SEGMENT_1,JL_SEGMENT_2,JL_SEGMENT_3,JL_SEGMENT_4,JL_SEGMENT_5,JL_SEGMENT_6
           ,JL_SEGMENT_7,JL_SEGMENT_8,JL_SEGMENT_9,JL_SEGMENT_10,JL_ATTRIBUTE_1,JL_ATTRIBUTE_2,JL_ATTRIBUTE_3,JL_ATTRIBUTE_4,JL_ATTRIBUTE_5
    FROM SLR_JRNL_LINES_TEMP
    INNER JOIN SLR_ENTITIES ON (JL_ENTITY = ENT_ENTITY);

    --post--
    processConfig := fBMGetProcessConfig('Post');

    IF gFakEbaFlag = 'E' THEN
      v_from_clause := ' from '||nvl(gProcessSource.ps_source_obj2, 'SLR_BM_LATEST_BAL_TMP')||' edb inner join slr_fak_combinations on (epg_id = fc_epg_id and FAK_ID = fc_fak_id) ';

      --join to eba_combinations only if config specifies attributes--
      IF(processConfig.pcd_attribute_1 IS NOT NULL OR processConfig.pcd_attribute_2 IS NOT NULL OR processConfig.pcd_attribute_3 IS NOT NULL
          OR processConfig.pcd_attribute_4 IS NOT NULL OR processConfig.pcd_attribute_5 IS NOT NULL) THEN
        v_from_clause := v_from_clause||' inner join slr_eba_combinations on (epg_id = ec_epg_id and KEY_ID = ec_eba_id) ';
        v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and ec_fak_id = fc_fak_id and BMEPS_SET_ID = :pEntProcSet)';
      ELSE
        v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and BMEPS_SET_ID = :pEntProcSet)';
      END IF;

    ELSE
      v_from_clause := ' from '||nvl(gProcessSource.ps_source_obj2, 'SLR_BM_LATEST_BAL_TMP')||' fdb inner join slr_fak_combinations on (epg_id = fc_epg_id and KEY_ID = fc_fak_id) ';
      v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and BMEPS_SET_ID = :pEntProcSet)';
    END IF;

    v_from_clause := v_from_clause||' inner join SLR_ENTITIES ON (ENT_ENTITY = FC_ENTITY)';

    v_sel_stmt := ' select ';
    v_sel_stmt := v_sel_stmt ||':pcd_description,:pBalanceDate,:pBalanceDate';

    --trans currency--
    v_sel_stmt := v_sel_stmt || ',fc_ccy';
    --trans amount--
    v_sel_stmt := v_sel_stmt || ',sum(TRAN_BALANCE)';

    --local ccy
    v_sel_stmt := v_sel_stmt || ',max(ent_local_ccy)';
    --local amount--
    v_sel_stmt := v_sel_stmt || ',sum(LOCAL_BALANCE)';
    --local rate
    v_sel_stmt := v_sel_stmt ||',null';

    --base ccy
    v_sel_stmt := v_sel_stmt || ',max(ent_base_ccy)';
    --base amount--
    v_sel_stmt := v_sel_stmt || ',sum(BASE_BALANCE)';
    --base rate
    v_sel_stmt := v_sel_stmt ||',null';

    --jrnl_type
    v_sel_stmt := v_sel_stmt || ',:pJournalType';

    --line_type--
    v_sel_stmt := v_sel_stmt || ',''Post''';

    --internal period flag--
    v_sel_stmt := v_sel_stmt || ',''N''';

    --rate set--
    v_sel_stmt := v_sel_stmt || ',null';

    v_sel_cols := fBMGenSelectSQL(processConfig);

    v_group_by_clause := fBMGenGroupBySQL(processConfig,null);

    v_stmt := v_insert_stmt||v_sel_stmt||v_sel_cols||v_from_clause||v_group_by_clause;

    pBMTraceJob('POST',v_stmt||'; bindings['||processConfig.pcd_description||','||gBalanceDate||','||gBalanceDate||','||gJournalType||','||gEntProcSet||']');
    EXECUTE IMMEDIATE v_stmt
      USING processConfig.pcd_description,gBalanceDate,gBalanceDate,gJournalType,gEntProcSet;

   --post in management ccy--
    pBMTraceJob('POST in management ccy', null);

    insert into SLR_JRNL_LINES_TEMP (jl_description,jl_effective_date,jl_value_date,
                  jl_tran_ccy,jl_tran_amount,jl_local_ccy,jl_local_amount,jl_local_rate,jl_base_ccy,jl_base_amount,jl_base_rate,jl_jrnl_type,jl_type
                  ,jl_jrnl_internal_period_flag,jl_jrnl_ent_rate_set
                  ,jl_entity,jl_account,jl_segment_1,jl_segment_2,jl_segment_3,jl_segment_4,jl_segment_5,jl_segment_6,jl_segment_7,
                  jl_segment_8,jl_segment_9,jl_segment_10,jl_attribute_1,jl_attribute_2,jl_attribute_3,jl_attribute_4,
                  jl_attribute_5)
    SELECT JL_DESCRIPTION,JL_EFFECTIVE_DATE,JL_VALUE_DATE,CASE WHEN ENT_FX_MANAGE_FLAG = 'B' THEN ENT_BASE_CCY ELSE ENT_LOCAL_CCY END,
           CASE WHEN ENT_FX_MANAGE_FLAG = 'B' THEN JL_BASE_AMOUNT*(-1) ELSE JL_LOCAL_AMOUNT*(-1) END,jl_local_ccy, JL_LOCAL_AMOUNT*(-1),NULL,jl_base_ccy, JL_BASE_AMOUNT*(-1),NULL
           ,JL_JRNL_TYPE, JL_TYPE,JL_JRNL_INTERNAL_PERIOD_FLAG,JL_JRNL_ENT_RATE_SET,JL_ENTITY,JL_ACCOUNT,JL_SEGMENT_1,JL_SEGMENT_2,JL_SEGMENT_3,JL_SEGMENT_4,JL_SEGMENT_5,JL_SEGMENT_6
           ,JL_SEGMENT_7,JL_SEGMENT_8,JL_SEGMENT_9,JL_SEGMENT_10,JL_ATTRIBUTE_1,JL_ATTRIBUTE_2,JL_ATTRIBUTE_3,JL_ATTRIBUTE_4,JL_ATTRIBUTE_5
    FROM SLR_JRNL_LINES_TEMP
    INNER JOIN SLR_ENTITIES ON (JL_ENTITY = ENT_ENTITY)
    WHERE JL_TYPE = 'Post';

   --offset--
   pBMCreateOffset;

   --nostro--
   pBMCreateNostro;
   commit;

   --create unposted journals--
   pBMCreateUnpostedJournals(lines_created);

   pBMTraceJob(gProcess||' END',null);

   exception
      WHEN OTHERS THEN
        pBMTraceJob(gProcess||' STOPPED',null);
        IF SQLCODE =-20001 THEN
            RAISE_APPLICATION_ERROR(-20001,'pBMFXClearDown: '||sqlerrm);
        ELSE
            RAISE_APPLICATION_ERROR(-20001,'pBMFXClearDown: '||dbms_utility.FORMAT_ERROR_STACK||';'||dbms_utility.FORMAT_ERROR_BACKTRACE);
        END IF;

  END pBMFXClearDown;

-------------------------------------------------------------------------------------------------------------------------------------------

  PROCEDURE pBMPLRepatriation(lines_created out INTEGER) AS
    processConfig slr_process_config_detail%rowtype;
    v_stmt VARCHAR2(10000);
    v_insert_stmt VARCHAR2(1000);
    v_sel_stmt VARCHAR2(3500);
    v_group_by_clause VARCHAR2(500);
    v_from_clause VARCHAR2(2000);
    v_from_clause2 VARCHAR2(1000);

  BEGIN
    pBMTraceJob(gProcess||' START',null);

    pBMTraceJob('pBMValidateProcessConfig','pBMValidateProcessConfig(''Adjust'',''Offset'')');
    pBMValidateProcessConfig('Adjust','Offset');

    pBMTraceJob('pBMValidateProcessConfig','pBMValidateProcessConfig(''Post'',''Nostro'')');
    pBMValidateProcessConfig('Post','Nostro');

    pBMTraceJob('pBMValidateManagementCcy','pBMValidateManagementCcy');
    pBMValidateManagementCcy;

    pBMTraceJob(gProcess,'truncate table SLR_JRNL_LINES_TEMP');
    EXECUTE IMMEDIATE 'truncate table SLR_JRNL_LINES_TEMP';

    processConfig := fBMGetProcessConfig('Adjust');

    --pBMGetLatestBalance
    pBMGetLatestBalance(gBalanceDate,gEntProcSet);

    IF gFakEbaFlag = 'E' THEN
      v_from_clause := ' from '||nvl(gProcessSource.ps_source_obj2, 'SLR_BM_LATEST_BAL_TMP')||' edb inner join slr_fak_combinations on (epg_id = fc_epg_id and FAK_ID = fc_fak_id) ';

      --join to eba_combinations only if config specifies attributes--
      IF(processConfig.pcd_attribute_1 IS NOT NULL OR processConfig.pcd_attribute_2 IS NOT NULL OR processConfig.pcd_attribute_3 IS NOT NULL
          OR processConfig.pcd_attribute_4 IS NOT NULL OR processConfig.pcd_attribute_5 IS NOT NULL) THEN
        v_from_clause := v_from_clause||' inner join slr_eba_combinations on (epg_id = ec_epg_id and KEY_ID = ec_eba_id) ';
        v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and ec_fak_id = fc_fak_id and BMEPS_SET_ID = :pEntProcSet)';
      ELSE
        v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and BMEPS_SET_ID = :pEntProcSet)';
      END IF;

    ELSE
      v_from_clause := ' from '||nvl(gProcessSource.ps_source_obj2, 'SLR_BM_LATEST_BAL_TMP')||' fdb inner join slr_fak_combinations on (epg_id = fc_epg_id and KEY_ID = fc_fak_id) ';
      v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and BMEPS_SET_ID = :pEntProcSet)';
    END IF;

    --validate fx translation config--
    v_stmt := 'INSERT INTO SLR_PROCESS_ERRORS(SPE_PROCESS_ID,SPE_P_PROCESS,SPE_PC_CONFIG,SPE_SPS_SOURCE_NAME,SPE_BMEPS_SET_ID,SPE_ENTITY,SPE_ERROR_MESSAGE)'
        ||' SELECT :pProcessId,:pProcess,:pConfig,:pSource,:pEntProcSet,null'
        ||',FTC_TARGET_AMOUNT_TYPE || '' FX Translation Config not found for SEGMENTS 2 [''||(listagg(coalesce(FC_SEGMENT_2,''NVS''),'','') WITHIN GROUP (ORDER BY FC_SEGMENT_2))||'']'''
        ||' FROM '
        ||' (SELECT distinct coalesce(FC_SEGMENT_2,''NVS'') as FC_SEGMENT_2, (CASE WHEN ENT_FX_MANAGE_FLAG = ''B'' THEN ''Base'' ELSE ''Local'' END) as FTC_TARGET_AMOUNT_TYPE '
        ||  v_from_clause
        ||' INNER JOIN SLR_ENTITIES on (fc_entity = ent_entity) '
        ||' LEFT JOIN SLR_FX_TRANSLATION_CONFIG on ('
        ||' fc_entity = FTC_ENTITY '
        ||' AND coalesce(FC_SEGMENT_2,''NVS'') = FTC_GAAP '
        ||' AND ftc_process_type = ''FX_REVALUATION'''
        ||' AND FTC_TARGET_AMOUNT_TYPE = (CASE WHEN ENT_FX_MANAGE_FLAG = ''B'' THEN ''Base'' ELSE ''Local'' END)'
        ||' )'
        ||' WHERE ftc_fx_rate_set IS NULL)'
        ||' GROUP BY FTC_TARGET_AMOUNT_TYPE';

    pBMTraceJob('validate FX Translation Config',v_stmt||'; bindings['||gProcessId||','||gProcess||','||gConfig||','||gSource||','||gEntProcSet||','||gEntProcSet||']');
    EXECUTE IMMEDIATE v_stmt using gProcessId, gProcess, gConfig, gSource, gEntProcSet, gEntProcSet;

    IF(sql%rowcount > 0) THEN
        COMMIT;
        RAISE_APPLICATION_ERROR(-20001,'FX Translation Config not found');
    END IF;

    --validate rates--
    v_stmt := 'INSERT INTO SLR_PROCESS_ERRORS(SPE_PROCESS_ID,SPE_P_PROCESS,SPE_PC_CONFIG,SPE_SPS_SOURCE_NAME,SPE_BMEPS_SET_ID,SPE_ENTITY,SPE_ERROR_MESSAGE)'
              ||' select :pProcessId,:pProcess,:pConfig,:pSource,:pEntProcSet,null'
              ||',''Rate not found for rate set [''||FTC_FX_RATE_SET||''] and date ['|| to_char(gBalanceDate,'YYYY-MM-DD')|| ']'
              ||' from currency [''||fc_ccy||''] to currency [''||CASE when '|| NVL(gFxManageCcy, 'NULL')|| ' is not null then '
              || case when gFxManageCcy is not null then '''' || gFxManageCcy|| '''' else 'NULL' end
              ||' when ENT_FX_MANAGE_FLAG = ''B'' THEN ENT_BASE_CCY ELSE ENT_LOCAL_CCY END||'']'''
              || v_from_clause|| ' inner join SLR_ENTITIES ON (ENT_ENTITY = FC_ENTITY)'
              ||' INNER JOIN SLR_FX_TRANSLATION_CONFIG ON ('
              ||' FTC_ENTITY = FC_ENTITY'
              ||' AND FTC_GAAP = coalesce(FC_SEGMENT_2,''NVS'')'
              ||' AND FTC_TARGET_AMOUNT_TYPE = (CASE WHEN ENT_FX_MANAGE_FLAG = ''B'' THEN ''Base'' ELSE ''Local'' END)'
              ||' AND FTC_PROCESS_TYPE = ''FX_REVALUATION'')'
              ||' LEFT JOIN SLR_ENTITY_RATES ON ('
              ||' ER_ENTITY_SET = FTC_FX_RATE_SET'
              ||' AND ER_RATE_TYPE = FTC_RATE_TYPE'
              ||' AND ER_DATE = :pBalanceDate'
              ||' AND ER_CCY_FROM = fc_ccy'
              ||' AND ER_CCY_TO = (CASE when '|| NVL(gFxManageCcy, 'NULL')|| ' is not null then '
              || case when gFxManageCcy is not null then '''' || gFxManageCcy|| '''' else 'NULL' end
              ||' when ENT_FX_MANAGE_FLAG = ''B'' THEN ENT_BASE_CCY ELSE ENT_LOCAL_CCY END))'
              ||' WHERE ER_RATE IS NULL '
              ||' AND fc_ccy <> (CASE when '|| NVL(gFxManageCcy, 'NULL')|| ' is not null then '
              || case when gFxManageCcy is not null then '''' || gFxManageCcy|| '''' else 'NULL' end
              ||' when ENT_FX_MANAGE_FLAG = ''B'' THEN ENT_BASE_CCY ELSE ENT_LOCAL_CCY END)'
              ||' group by ftc_fx_rate_set, fc_ccy'
              ||',(CASE when '|| NVL(gFxManageCcy, 'NULL')|| ' is not null then '
              || case when gFxManageCcy is not null then '''' || gFxManageCcy || '''' else 'NULL' end
              ||' when ENT_FX_MANAGE_FLAG = ''B'' THEN ENT_BASE_CCY ELSE ENT_LOCAL_CCY END)';


    pBMTraceJob('validate FX RATES',v_stmt||'; bindings['||gProcessId||','||gProcess||','||gConfig||','||gSource||','||gEntProcSet||','||gEntProcSet||','||gBalanceDate||']');
    EXECUTE IMMEDIATE v_stmt
      using gProcessId,gProcess,gConfig,gSource,gEntProcSet,gEntProcSet,gBalanceDate;

    IF(sql%rowcount > 0) THEN
      COMMIT;
      RAISE_APPLICATION_ERROR(-20001,'Rates not found');
		END IF;

    --construct adjustment line insert--
    v_insert_stmt := 'insert into SLR_JRNL_LINES_TEMP (jl_description,jl_effective_date,jl_value_date,'
                  ||'jl_tran_ccy,jl_tran_amount,jl_local_ccy,jl_local_amount,jl_local_rate,jl_base_ccy,jl_base_amount,jl_base_rate,jl_jrnl_type,jl_type,'
                  ||'jl_jrnl_internal_period_flag,jl_jrnl_ent_rate_set,'
                  ||'jl_entity,jl_account,jl_segment_1,jl_segment_2,jl_segment_3,jl_segment_4,jl_segment_5,jl_segment_6,jl_segment_7,'
                  ||'jl_segment_8,jl_segment_9,jl_segment_10,jl_attribute_1,jl_attribute_2,jl_attribute_3,jl_attribute_4,'
                  ||'jl_attribute_5)';

    v_from_clause2 := ' INNER JOIN slr_entities on (fc_entity = ent_entity)'
                  ||' INNER JOIN SLR_FX_TRANSLATION_CONFIG ON ('
                  ||' FTC_ENTITY = FC_ENTITY'
                  ||' AND FTC_GAAP = coalesce(FC_SEGMENT_2,''NVS'')'
                  ||' AND FTC_TARGET_AMOUNT_TYPE = (CASE WHEN ENT_FX_MANAGE_FLAG = ''B'' THEN ''Base'' ELSE ''Local'' END)'
                  ||' AND FTC_PROCESS_TYPE = ''FX_REVALUATION'')'
                  ||' LEFT JOIN SLR_ENTITY_CURRENCIES on (EC_ENTITY_SET = ENT_CURRENCY_SET AND EC_CCY = (CASE when '|| NVL(gFxManageCcy, 'NULL')|| ' is not null then '
				  ||  case when gFxManageCcy is not null then ''''|| gFxManageCcy||'''' else 'NULL' end|| ' WHEN ENT_FX_MANAGE_FLAG = ''B'' THEN ENT_BASE_CCY ELSE ENT_LOCAL_CCY END) AND EC_STATUS = ''A'')'
                  ||' LEFT JOIN SLR_ENTITY_RATES ON ('
                  ||' ER_ENTITY_SET = FTC_FX_RATE_SET'
                  ||' AND ER_RATE_TYPE = FTC_RATE_TYPE'
                  ||' AND ER_DATE = :pBalanceDate'
                  ||' AND ER_CCY_FROM = fc_ccy'
                  ||' AND ER_CCY_TO = (CASE when '|| NVL(gFxManageCcy, 'NULL')|| ' is not null then '
                  || case when gFxManageCcy is not null then ''''|| gFxManageCcy||'''' else 'NULL' end
                  ||' WHEN ENT_FX_MANAGE_FLAG = ''B'' THEN ENT_BASE_CCY ELSE ENT_LOCAL_CCY END))';

/*-----------CUSTOMIZATION FROM 20.2.3 MERGE START-----------*/
--  v_sel_stmt := ' select ';
--  Original line above modified with fHint in one line below
    v_sel_stmt := ' select ' || SLR_UTILITIES_PKG.fHint('AG', 'PL_REPATRIATION') || ' ';
/*-----------CUSTOMIZATION FROM 20.2.3 MERGE END-----------*/
    v_sel_stmt := v_sel_stmt ||':pcd_description,:pBalanceDate,:pBalanceDate';

    --trans currency--
    v_sel_stmt := v_sel_stmt || ',(CASE when '|| NVL(gFxManageCcy, 'NULL')|| ' is not null then '|| case when gFxManageCcy is not null
                                                                                                             then ''''|| gFxManageCcy||'''' else 'NULL' end|| ' WHEN ENT_FX_MANAGE_FLAG = ''B'' THEN ENT_BASE_CCY ELSE ENT_LOCAL_CCY END)';
    --trans amount--
    v_sel_stmt := v_sel_stmt || ',(-1)*Round(sum(TRAN_BALANCE)*max(coalesce(ER_RATE,1)),cast(nvl(max(EC_DIGITS_AFTER_POINT),2) as integer))';

    --local currency--
    v_sel_stmt := v_sel_stmt || ',max(ENT_LOCAL_CCY)';
    --local amount--
    v_sel_stmt := v_sel_stmt ||',null';
    --local rate--
    v_sel_stmt := v_sel_stmt ||',null';

    --base currency--
    v_sel_stmt := v_sel_stmt || ',max(ENT_BASE_CCY)';
    --base amount--
    v_sel_stmt := v_sel_stmt ||',null';
    --base rate--
    v_sel_stmt := v_sel_stmt ||',null';

    --jrnl_type
    v_sel_stmt := v_sel_stmt || ',:pJournalType';

    --line_type--
    v_sel_stmt := v_sel_stmt || ',''Adjust''';

    --internal period flag--
    v_sel_stmt := v_sel_stmt || ',''N''';

    --rate set--
    v_sel_stmt := v_sel_stmt || ',null';


    v_sel_stmt := v_sel_stmt ||',TARGET_ENTITY,FC_ACCOUNT,MAX(FC_SEGMENT_1),MAX(FC_SEGMENT_2),MAX(FC_SEGMENT_3),MAX(FC_SEGMENT_4),MAX(FC_SEGMENT_5)'
                             ||',MAX(FC_SEGMENT_6),MAX(FC_SEGMENT_7),MAX(FC_SEGMENT_8),MAX(FC_SEGMENT_9),MAX(FC_SEGMENT_10)'
                             ||',MAX(EC_ATTRIBUTE_1),MAX(EC_ATTRIBUTE_2),MAX(EC_ATTRIBUTE_3),MAX(EC_ATTRIBUTE_4),MAX(EC_ATTRIBUTE_5)';


    v_sel_stmt := v_sel_stmt ||' from (select TRAN_BALANCE,FC_CCY,FC_ENTITY'||fBMGenSelectSQL(processConfig);


    v_group_by_clause := fBMGenGroupBySQL(processConfig, ' group by TARGET_ENTITY, FC_ACCOUNT, FC_CCY, (CASE when '|| NVL(gFxManageCcy, 'NULL')|| ' is not null then '|| case when gFxManageCcy is not null
                                                                                                                                                                                  then ''''|| gFxManageCcy||'''' else 'NULL' end|| ' WHEN ENT_FX_MANAGE_FLAG = ''B'' THEN ENT_BASE_CCY ELSE ENT_LOCAL_CCY END)');

    v_stmt := v_insert_stmt || v_sel_stmt||v_from_clause ||') a '||v_from_clause2||v_group_by_clause;

    pBMTraceJob('ADJUSTMENT',v_stmt||'; bindings['||processConfig.pcd_description||','||gBalanceDate||','||gBalanceDate||','||gJournalType||','||gEntProcSet||','||gBalanceDate||']');
    EXECUTE IMMEDIATE v_stmt
      using processConfig.pcd_description,gBalanceDate,gBalanceDate,gJournalType,gEntProcSet,gBalanceDate;


    --post--
    processConfig := fBMGetProcessConfig('Post');

    IF gFakEbaFlag = 'E' THEN
      v_from_clause := ' from '||nvl(gProcessSource.ps_source_obj2, 'SLR_BM_LATEST_BAL_TMP')||' edb inner join slr_fak_combinations on (epg_id = fc_epg_id and FAK_ID = fc_fak_id) ';

      --join to eba_combinations only if config specifies attributes--
      IF(processConfig.pcd_attribute_1 IS NOT NULL OR processConfig.pcd_attribute_2 IS NOT NULL OR processConfig.pcd_attribute_3 IS NOT NULL
          OR processConfig.pcd_attribute_4 IS NOT NULL OR processConfig.pcd_attribute_5 IS NOT NULL) THEN
        v_from_clause := v_from_clause||' inner join slr_eba_combinations on (epg_id = ec_epg_id and KEY_ID = ec_eba_id) ';
        v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and ec_fak_id = fc_fak_id and BMEPS_SET_ID = :pEntProcSet)';
      ELSE
        v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and BMEPS_SET_ID = :pEntProcSet)';
      END IF;

    ELSE
      v_from_clause := ' from '||nvl(gProcessSource.ps_source_obj2, 'SLR_BM_LATEST_BAL_TMP')||' fdb inner join slr_fak_combinations on (epg_id = fc_epg_id and KEY_ID = fc_fak_id) ';
      v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and BMEPS_SET_ID = :pEntProcSet)';
    END IF;

    v_sel_stmt := ' select ';
    v_sel_stmt := v_sel_stmt ||':pcd_description,:pBalanceDate,:pBalanceDate';

    --trans currency--
    v_sel_stmt := v_sel_stmt || ',(CASE when '|| NVL(gFxManageCcy, 'NULL')|| ' is not null then '|| case when gFxManageCcy is not null
                                                                                                             then ''''|| gFxManageCcy||'''' else 'NULL' end|| ' WHEN se.ENT_FX_MANAGE_FLAG = ''B'' THEN se.ENT_BASE_CCY ELSE se.ENT_LOCAL_CCY END)';
    --trans amount--
    v_sel_stmt := v_sel_stmt || ',Round(sum(TRAN_BALANCE)*max(coalesce(ER_RATE,1)),cast(nvl(max(EC_DIGITS_AFTER_POINT),2) as integer))';

    --local currency--
    v_sel_stmt := v_sel_stmt || ',max(te.ENT_LOCAL_CCY)';
    --local amount--
    v_sel_stmt := v_sel_stmt ||',null';
    --local rate--
    v_sel_stmt := v_sel_stmt ||',null';

    --base currency--
    v_sel_stmt := v_sel_stmt || ',max(te.ENT_BASE_CCY)';
    --base amount--
    v_sel_stmt := v_sel_stmt ||',null';
    --base rate--
    v_sel_stmt := v_sel_stmt ||',null';

    --jrnl_type
    v_sel_stmt := v_sel_stmt || ',:pJournalType';

    --line_type--
    v_sel_stmt := v_sel_stmt || ',''Post''';

    --internal period flag--
    v_sel_stmt := v_sel_stmt || ',''N''';

    --rate set--
    v_sel_stmt := v_sel_stmt || ',null';


    v_sel_stmt := v_sel_stmt ||',TARGET_ENTITY,FC_ACCOUNT,MAX(FC_SEGMENT_1),MAX(FC_SEGMENT_2),MAX(FC_SEGMENT_3),MAX(FC_SEGMENT_4),MAX(FC_SEGMENT_5)'
                             ||',MAX(FC_SEGMENT_6),MAX(FC_SEGMENT_7),MAX(FC_SEGMENT_8),MAX(FC_SEGMENT_9),MAX(FC_SEGMENT_10)'
                             ||',MAX(EC_ATTRIBUTE_1),MAX(EC_ATTRIBUTE_2),MAX(EC_ATTRIBUTE_3),MAX(EC_ATTRIBUTE_4),MAX(EC_ATTRIBUTE_5)';


    v_sel_stmt := v_sel_stmt ||' from (select TRAN_BALANCE,FC_CCY,FC_ENTITY'||fBMGenSelectSQL(processConfig);

    v_from_clause2 := ' inner join slr_entities se on (fc_entity = se.ent_entity)'
              || ' left join slr_entities te on (te.ent_entity = TARGET_ENTITY)'
              ||' INNER JOIN SLR_FX_TRANSLATION_CONFIG ON ('
              ||' FTC_ENTITY = FC_ENTITY'
              ||' AND FTC_GAAP = coalesce(FC_SEGMENT_2,''NVS'')'
              ||' AND FTC_TARGET_AMOUNT_TYPE = (CASE WHEN se.ENT_FX_MANAGE_FLAG = ''B'' THEN ''Base'' ELSE ''Local'' END)'
              ||' AND FTC_PROCESS_TYPE = ''FX_REVALUATION'')'
              ||' left join SLR_ENTITY_CURRENCIES on (EC_ENTITY_SET = te.ENT_CURRENCY_SET AND EC_CCY = (CASE when '|| NVL(gFxManageCcy, 'NULL')|| ' is not null then '
              ||  case when gFxManageCcy is not null then ''''|| gFxManageCcy||'''' else 'NULL' end|| ' WHEN se.ENT_FX_MANAGE_FLAG = ''B'' THEN se.ENT_BASE_CCY ELSE se.ENT_LOCAL_CCY END) AND EC_STATUS = ''A'')'
              ||' LEFT JOIN SLR_ENTITY_RATES ON ('
              ||' ER_ENTITY_SET = FTC_FX_RATE_SET'
              ||' AND ER_RATE_TYPE = FTC_RATE_TYPE'
              ||' AND ER_DATE = :pBalanceDate'
              ||' AND ER_CCY_FROM = fc_ccy'
              ||' AND ER_CCY_TO = (CASE when '|| NVL(gFxManageCcy, 'NULL') || ' is not null then '
              ||  case when gFxManageCcy is not null then ''''|| gFxManageCcy||'''' else 'NULL' end
              ||' WHEN se.ENT_FX_MANAGE_FLAG = ''B'' THEN se.ENT_BASE_CCY ELSE se.ENT_LOCAL_CCY END))';


    v_group_by_clause := fBMGenGroupBySQL(processConfig, ' group by TARGET_ENTITY, FC_ACCOUNT, FC_CCY,(CASE when '|| NVL(gFxManageCcy, 'NULL')|| ' is not null then '|| case when gFxManageCcy is not null
                                                                                                                                                                                 then ''''|| gFxManageCcy||'''' else 'NULL' end|| ' WHEN se.ENT_FX_MANAGE_FLAG = ''B'' THEN se.ENT_BASE_CCY ELSE se.ENT_LOCAL_CCY END)');

    v_stmt := v_insert_stmt || v_sel_stmt||v_from_clause ||') a '||v_from_clause2||v_group_by_clause;

    pBMTraceJob('POST',v_stmt||'; bindings['||processConfig.pcd_description||','||gBalanceDate||','||gBalanceDate||','||gJournalType||','||gEntProcSet||','||gBalanceDate||']');
    EXECUTE IMMEDIATE v_stmt
      using processConfig.pcd_description,gBalanceDate,gBalanceDate,gJournalType,gEntProcSet,gBalanceDate;

   --offset--
   pBMCreateOffset;

   --nostro--
   pBMCreateNostro;
   commit;

   --create unposted journals--
   pBMCreateUnpostedJournals(lines_created);

   pBMTraceJob(gProcess||' END',null);

   exception
      WHEN OTHERS THEN
        pBMTraceJob(gProcess||' STOPPED',null);
        IF SQLCODE =-20001 THEN
            RAISE_APPLICATION_ERROR(-20001,'pBMPLRepatriation: '||sqlerrm);
        ELSE
            RAISE_APPLICATION_ERROR(-20001,'pBMPLRepatriation: '||dbms_utility.FORMAT_ERROR_STACK||';'||dbms_utility.FORMAT_ERROR_BACKTRACE);
        END IF;

  END pBMPLRepatriation;

  PROCEDURE pBMPLRetainedEarnings(lines_created out INTEGER) AS
    processConfig slr_process_config_detail%rowtype;
    v_stmt VARCHAR2(13000);
    v_insert_stmt VARCHAR2(1000);
    v_sel_stmt VARCHAR2(3500);
    v_sel_stmt2 VARCHAR2(3500);
    v_group_by_clause VARCHAR2(500);
    v_group_by_clause2 VARCHAR2(500);
    v_from_clause VARCHAR2(2000);
    v_from_clause2 VARCHAR2(2000);

  BEGIN
    pBMTraceJob(gProcess||' START',null);

    pBMTraceJob('pBMValidateProcessConfig','pBMValidateProcessConfig(''Adjust'',''Offset'')');
    pBMValidateProcessConfig('Adjust','Offset');

    pBMTraceJob(gProcess,'truncate table SLR_JRNL_LINES_TEMP');
    EXECUTE IMMEDIATE 'truncate table SLR_JRNL_LINES_TEMP';

    --validate balance date is equal to the last working day of the year
    INSERT INTO SLR_PROCESS_ERRORS(SPE_PROCESS_ID, SPE_P_PROCESS, SPE_PC_CONFIG, SPE_SPS_SOURCE_NAME,SPE_BMEPS_SET_ID,SPE_ENTITY, SPE_ERROR_MESSAGE)
    SELECT gProcessId, gProcess, gConfig, gSource, gEntProcSet, BMEPS_ENTITY
          ,'Provided balance date ['||to_char(gBalanceDate,'YYYY-MM-DD')||'] is not equal to the last working day of the year ['||to_char(b.ep_bus_period_end,'YYYY-MM-DD')||']'
    FROM
    SLR_BM_ENTITY_PROCESSING_SET
    LEFT JOIN slr_entity_periods a ON (a.EP_ENTITY = BMEPS_ENTITY)
    LEFT JOIN slr_entity_periods b ON (a.EP_ENTITY = b.EP_ENTITY AND a.EP_BUS_YEAR = b.EP_BUS_YEAR )
    WHERE
      BMEPS_SET_ID = gEntProcSet
      AND	gBalanceDate BETWEEN  A.ep_cal_period_start AND A.ep_cal_period_end
      and (gBalanceDate <> a.ep_bus_period_end OR a.ep_period_type <> 2)
      and  b.ep_period_type = 2;

    IF(sql%rowcount > 0) THEN
      commit;
      RAISE_APPLICATION_ERROR(-20001,'Provided balance date is not equal to the last working day of the year');
    end if;

    insert into SLR_PROCESS_ERRORS(SPE_PROCESS_ID, SPE_P_PROCESS, SPE_PC_CONFIG, SPE_SPS_SOURCE_NAME,SPE_BMEPS_SET_ID,SPE_ENTITY, SPE_ERROR_MESSAGE)
    SELECT gProcessId, gProcess, gConfig, gSource, gEntProcSet, BMEPS_ENTITY
           ,'No period found in SLR_ENTITY_PERIODS; EP_ENTITY:'||BMEPS_ENTITY||'; DATE:'||to_char(gBalanceDate,'YYYY-MM-DD')
    FROM SLR_BM_ENTITY_PROCESSING_SET
    left join SLR_ENTITY_PERIODS on (EP_ENTITY = BMEPS_ENTITY and gBalanceDate between EP_CAL_PERIOD_START and EP_CAL_PERIOD_END)
    WHERE BMEPS_SET_ID = gEntProcSet AND EP_ENTITY IS NULL;

    IF(sql%rowcount > 0) THEN
      commit;
      RAISE_APPLICATION_ERROR(-20001,'No period found.');
    end if;

    insert into SLR_PROCESS_ERRORS(SPE_PROCESS_ID, SPE_P_PROCESS, SPE_PC_CONFIG, SPE_SPS_SOURCE_NAME,SPE_BMEPS_SET_ID,SPE_ENTITY, SPE_ERROR_MESSAGE)
    SELECT gProcessId, gProcess, gConfig, gSource, gEntProcSet, p1.EP_ENTITY
           ,'No period found in SLR_ENTITY_PERIODS; EP_ENTITY:'||p1.EP_ENTITY||'; EP_BUS_PERIOD:1; EP_BUS_YEAR:'||(p1.EP_BUS_YEAR+1)
    FROM SLR_ENTITY_PERIODS p1
    left join SLR_ENTITY_PERIODS p2 on (p2.EP_ENTITY = p1.EP_ENTITY and p2.EP_BUS_YEAR = p1.EP_BUS_YEAR+1 and p2.EP_BUS_PERIOD = 1)
    where p1.EP_ENTITY in (select BMEPS_ENTITY from SLR_BM_ENTITY_PROCESSING_SET where BMEPS_SET_ID = gEntProcSet)
    and gBalanceDate between p1.EP_CAL_PERIOD_START and p1.EP_CAL_PERIOD_END
    AND p2.EP_BUS_PERIOD_START IS NULL;

    IF(sql%rowcount > 0) THEN
      commit;
      RAISE_APPLICATION_ERROR(-20001,'No period found.');
    end if;


    processConfig := fBMGetProcessConfig('Adjust');

    --pBMGetLatestBalance
    pBMGetLatestBalance(gBalanceDate,gEntProcSet);


    IF gFakEbaFlag = 'E' THEN
      v_from_clause := ' from '||nvl(gProcessSource.ps_source_obj2, 'SLR_BM_LATEST_BAL_TMP')||' edb inner join slr_fak_combinations on (epg_id = fc_epg_id and FAK_ID = fc_fak_id) ';

      --join to eba_combinations only if config specifies attributes--
      IF(processConfig.pcd_attribute_1 IS NOT NULL OR processConfig.pcd_attribute_2 IS NOT NULL OR processConfig.pcd_attribute_3 IS NOT NULL
          OR processConfig.pcd_attribute_4 IS NOT NULL OR processConfig.pcd_attribute_5 IS NOT NULL) THEN
        v_from_clause := v_from_clause||' inner join slr_eba_combinations on (epg_id = ec_epg_id and KEY_ID = ec_eba_id) ';
        v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and ec_fak_id = fc_fak_id and BMEPS_SET_ID = :pEntProcSet)';
      ELSE
        v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and BMEPS_SET_ID = :pEntProcSet)';
      END IF;

    ELSE
      v_from_clause := ' from '||nvl(gProcessSource.ps_source_obj2, 'SLR_BM_LATEST_BAL_TMP')||' fdb inner join slr_fak_combinations on (epg_id = fc_epg_id and KEY_ID = fc_fak_id) ';
      v_from_clause := v_from_clause||' inner join SLR_BM_ENTITY_PROCESSING_SET on (fc_entity = BMEPS_ENTITY and BMEPS_SET_ID = :pEntProcSet)';
    END IF;

    v_from_clause := v_from_clause||' inner join SLR_ENTITIES ON (ENT_ENTITY = FC_ENTITY)'
                    ||' inner join SLR_ENTITY_PERIODS p1 on (p1.EP_ENTITY = BMEPS_ENTITY and :pBalanceDate between p1.EP_CAL_PERIOD_START and p1.EP_CAL_PERIOD_END)'
                    ||' inner join SLR_ENTITY_PERIODS p2 on (p2.EP_ENTITY = p1.EP_ENTITY and p2.EP_BUS_YEAR = p1.EP_BUS_YEAR+1 and p2.EP_BUS_PERIOD = 1)';

/*-----------CUSTOMIZATION FROM 20.2.3 MERGE START-----------*/
--    v_from_clause2 := ' from slr_jrnl_headers jh INNER JOIN slr_jrnl_lines jl ON (jh_jrnl_date = jl_effective_date and jh_jrnl_epg_id = jl_epg_id and JH_JRNL_ID=JL_JRNL_HDR_ID AND jh.JH_JRNL_INTERNAL_PERIOD_FLAG = ''Y'')'
/*T.Nulty added clause  and jh.jh_jrnl_source = :gConfig  - otherwise applied JE to all rules*/																		   
    v_from_clause2 := ' from slr_jrnl_headers jh INNER JOIN slr_jrnl_lines jl ON (jh_jrnl_date = jl_effective_date and jh_jrnl_epg_id = jl_epg_id and JH_JRNL_ID=JL_JRNL_HDR_ID AND jh.JH_JRNL_INTERNAL_PERIOD_FLAG = ''Y'' and jh.jh_jrnl_source = :gConfig  )'
/*-----------CUSTOMIZATION FROM 20.2.3 MERGE END-----------*/
                   ||' INNER JOIN SLR_BM_ENTITY_PROCESSING_SET ON (BMEPS_ENTITY = JL_ENTITY and BMEPS_SET_ID = :pEntProcSet)'
                   ||' inner join slr_entities on (JL_ENTITY = ent_entity)'
                   ||' inner join SLR_ENTITY_PERIODS p1 on (p1.EP_ENTITY = BMEPS_ENTITY and :pBalanceDate between p1.EP_CAL_PERIOD_START and p1.EP_CAL_PERIOD_END)'
                   ||' inner join SLR_ENTITY_PERIODS p2 on (p2.EP_ENTITY = p1.EP_ENTITY and p2.EP_BUS_YEAR = p1.EP_BUS_YEAR+1 and p2.EP_BUS_PERIOD = 1)'
                   || ' where p2.EP_BUS_PERIOD_START = JL_EFFECTIVE_DATE AND JL_TYPE = ''Adjust'' AND JH_JRNL_TYPE = :gJournalType ';

    --construct adjustment line insert--
    v_insert_stmt := 'insert into SLR_JRNL_LINES_TEMP (jl_description,jl_effective_date,jl_value_date,'
                  ||'jl_tran_ccy,jl_tran_amount,jl_local_ccy,jl_local_amount,jl_local_rate,jl_base_ccy,jl_base_amount,jl_base_rate,jl_jrnl_type,jl_type'
                  ||',jl_jrnl_internal_period_flag,jl_jrnl_ent_rate_set'
                  ||',jl_entity,jl_account,jl_segment_1,jl_segment_2,jl_segment_3,jl_segment_4,jl_segment_5,jl_segment_6,jl_segment_7,'
                  ||'jl_segment_8,jl_segment_9,jl_segment_10,jl_attribute_1,jl_attribute_2,jl_attribute_3,jl_attribute_4,'
                  ||'jl_attribute_5)';

/*-----------CUSTOMIZATION FROM 20.2.3 MERGE START-----------*/
--  v_sel_stmt := ' select ';
--  Original line above modified with fHint in one line below												 
    v_sel_stmt := ' select ' || SLR_UTILITIES_PKG.fHint('AG', 'PL_RETAINED_EARNINGS') || ' ';
/*-----------CUSTOMIZATION FROM 20.2.3 MERGE END-----------*/
    v_sel_stmt := v_sel_stmt ||':pcd_description,max(p2.EP_BUS_PERIOD_START),max(p2.EP_BUS_PERIOD_START)';

    --trans currency--
    v_sel_stmt2 := v_sel_stmt || ',JL_TRAN_CCY';
    v_sel_stmt := v_sel_stmt || ',FC_CCY';

    --trans amount--
    v_sel_stmt := v_sel_stmt || ',sum(TRAN_BALANCE)*(-1)';
    v_sel_stmt2 := v_sel_stmt2 || ',sum(JL_TRAN_AMOUNT)*(-1)';

    --local currency--
    v_sel_stmt := v_sel_stmt || ',max(ENT_LOCAL_CCY)';
    v_sel_stmt2 := v_sel_stmt2 || ',max(ENT_LOCAL_CCY)';

    --local amount--
    v_sel_stmt := v_sel_stmt || ',sum(LOCAL_BALANCE)*(-1)';
    v_sel_stmt2 := v_sel_stmt2 || ',sum(JL_LOCAL_AMOUNT)*(-1)';

    --local rate--
    v_sel_stmt := v_sel_stmt ||',null';
    v_sel_stmt2 := v_sel_stmt2 ||',null';

    --base currency--
    v_sel_stmt := v_sel_stmt || ',max(ENT_BASE_CCY)';
    v_sel_stmt2 := v_sel_stmt2 || ',max(ENT_BASE_CCY)';

    --base amount--
    v_sel_stmt := v_sel_stmt || ',sum(BASE_BALANCE)*(-1)';
    v_sel_stmt2 := v_sel_stmt2 || ',sum(JL_BASE_AMOUNT)*(-1)';

    --base rate--
    v_sel_stmt := v_sel_stmt ||',null';
    v_sel_stmt2 := v_sel_stmt2 ||',null';

    --jrnl_type
    v_sel_stmt := v_sel_stmt || ',:pJournalType';
    v_sel_stmt2 := v_sel_stmt2 || ',:pJournalType';

    --line_type--
    v_sel_stmt := v_sel_stmt || ',''Adjust''';
    v_sel_stmt2 := v_sel_stmt2 || ',''Adjust''';

    --internal period flag--
    v_sel_stmt := v_sel_stmt || ',''Y''';
    v_sel_stmt2 := v_sel_stmt2 || ',''Y''';

    --rate set--
    v_sel_stmt := v_sel_stmt || ',null';
    v_sel_stmt2 := v_sel_stmt2 || ',null';

    v_sel_stmt := v_sel_stmt ||fBMGenSelectSQL(processConfig);
    v_sel_stmt2 := v_sel_stmt2 ||fBMGenSelect2SQL(processConfig);

    v_group_by_clause := fBMGenGroupBySQL(processConfig,NULL);
    v_group_by_clause2 := fBMGenGroupBy2SQL(processConfig);

    v_stmt := v_insert_stmt || v_sel_stmt||v_from_clause ||v_group_by_clause||' UNION ALL '||v_sel_stmt2||v_from_clause2 ||v_group_by_clause2;

/*-----------CUSTOMIZATION FROM 20.2.3 MERGE START-----------*/
/*T.Nulty added pConfig variable*/								  
    pBMTraceJob('ADJUSTMENT',v_stmt||'; bindings['||processConfig.pcd_description||','||gJournalType||','||gEntProcSet||','||gBalanceDate||','
                                                  ||processConfig.pcd_description||','||gJournalType||','||gConfig||','||gEntProcSet||','||gBalanceDate||','||gJournalType||']');
/*T.Nulty added pConfig variable*/

    EXECUTE IMMEDIATE v_stmt
      USING processConfig.pcd_description,gJournalType,gEntProcSet,gBalanceDate
            ,processConfig.pcd_description,gJournalType,gConfig,gEntProcSet,gBalanceDate,gJournalType;
/*-----------CUSTOMIZATION FROM 20.2.3 MERGE END-----------*/
   --offset--
   pBMCreateOffset;
   commit;

   --create unposted journals--
   pBMCreateUnpostedJournals(lines_created);

   pBMTraceJob(gProcess||' END',null);

   exception
      WHEN OTHERS THEN
        pBMTraceJob(gProcess||' STOPPED',null);
        IF SQLCODE =-20001 THEN
            RAISE_APPLICATION_ERROR(-20001,'pBMPLRetainedEarnings: '||sqlerrm);
        ELSE
            RAISE_APPLICATION_ERROR(-20001,'pBMPLRetainedEarnings: '||dbms_utility.FORMAT_ERROR_STACK||';'||dbms_utility.FORMAT_ERROR_BACKTRACE);
        END IF;

  END pBMPLRetainedEarnings;



procedure pBMGetLatestBalanceFak(pBalanceDate in date, pEntProcSet in slr_bm_entity_processing_set.bmeps_set_id%type)
as
  sql_string VARCHAR2(10000);
  pdate_string varchar2(10);
  amount_string varchar2(1024);
BEGIN
  pBMTraceJob('pBMGetLatestBalance TRUNCATE', 'truncate table SLR_BM_LATEST_BAL_TMP');
  EXECUTE IMMEDIATE 'truncate table SLR_BM_LATEST_BAL_TMP';

-- merge.  AG custom for performance enhancement
--  pdate_string := to_char(pBalanceDate, 'YYYY-MM-DD');
   pdate_string := to_char(last_day(pBalanceDate), 'YYYY-MM-DD');
-- END custom


  if(gWhichAmount = 'L') then
    amount_string := 'TRAN_LTD_BALANCE as BTRAN, BASE_LTD_BALANCE as BBASE, LOCAL_LTD_BALANCE as BLOCAL';
  end if;
  if(gWhichAmount = 'Y') then
    amount_string := 'case when p1.EP_BUS_YEAR = PERIOD_YEAR then TRAN_YTD_BALANCE else 0 end as BTRAN, case when p1.EP_BUS_YEAR = PERIOD_YEAR then BASE_YTD_BALANCE else 0 end as BBASE, case when p1.EP_BUS_YEAR = PERIOD_YEAR then LOCAL_YTD_BALANCE else 0 end as BLOCAL';
  end if;
  if(gWhichAmount = 'P') then
    amount_string := 'case when p1.EP_BUS_YEAR = PERIOD_YEAR and p1.EP_BUS_PERIOD = PERIOD_MONTH then TRAN_MTD_BALANCE else 0 end as BTRAN, case when p1.EP_BUS_YEAR = PERIOD_YEAR and p1.EP_BUS_PERIOD = PERIOD_MONTH then BASE_MTD_BALANCE else 0 end as BBASE, case when p1.EP_BUS_YEAR = PERIOD_YEAR and p1.EP_BUS_PERIOD = PERIOD_MONTH then LOCAL_MTD_BALANCE else 0 end as BLOCAL';
  end if;

  sql_string := '
    insert into SLR_BM_LATEST_BAL_TMP(KEY_ID, FAK_ID, BALANCE_DATE, BALANCE_TYPE, TRAN_BALANCE, BASE_BALANCE, LOCAL_BALANCE, EPG_ID)
    select BID, BFAK, BDATE, BTYPE, BTRAN, BBASE, BLOCAL, BEPGID from
    (
    select KEY_ID as BID, FAK_ID as BFAK, BALANCE_DATE as BDATE, BALANCE_TYPE as BTYPE, ENTITY as BENTITY, '||amount_string||', EPG_ID AS BEPGID
    ,ROW_NUMBER() over (partition by BALANCE_TYPE, KEY_ID order by BALANCE_DATE desc) rn
    from '||gProcessSource.ps_source_obj1
 --AG custom for performance
 --   ||' inner join SLR_ENTITY_PERIODS p1 on p1.EP_ENTITY = ENTITY and to_date('''||pdate_string||''', ''YYYY-MM-DD'') between p1.EP_CAL_PERIOD_START and p1.EP_CAL_PERIOD_END'
    ||' inner join SLR_ENTITY_PERIODS p1 on p1.EP_ENTITY = ENTITY and to_date('''||pdate_string||''', ''YYYY-MM-DD'') = p1.EP_CAL_PERIOD_END'
-- END AG custom
    ;

    IF (gProcess NOT IN ('PLRETEARNINGS','FXPLSWEEP','PLREPATRIATION')) THEN
      sql_string := sql_string||' where 1=1 ';
    ELSE
      sql_string := sql_string
      ||' INNER JOIN SLR_ENTITY_PERIODS p2 ON (p2.EP_ENTITY = p1.EP_ENTITY AND p2.EP_BUS_YEAR = p1.EP_BUS_YEAR AND p2.EP_BUS_PERIOD = 1)'
      ||' WHERE BALANCE_DATE >= p2.EP_BUS_PERIOD_START'
      ;
    end if;

    sql_string := sql_string||' and ENTITY in (select BMEPS_ENTITY from SLR_BM_ENTITY_PROCESSING_SET where BMEPS_SET_ID = '''||pEntProcSet||''')
    and BALANCE_DATE <= to_date('''||pdate_string||''' , ''YYYY-MM-DD'')
    )'
    ||' where rn=1';

  pBMTraceJob('pBMGetLatestBalance', sql_string);
  execute immediate sql_string;

end pBMGetLatestBalanceFak;


  PROCEDURE pbmgetlatestbal(pbalancedate IN DATE,
                            pentprocset  IN slr_bm_entity_processing_set.bmeps_set_id%TYPE) AS
    sql_string    VARCHAR2(10000);
    pdate_string  VARCHAR2(10);
    pdate_string_part VARCHAR2(12);
    amount_string VARCHAR2(1024);
    v_partition   pls_integer;
  BEGIN

    pbmtracejob('pBMGetLatestBalance TRUNCATE',
                'truncate table SLR_BM_LATEST_BAL_TMP');
    EXECUTE IMMEDIATE 'truncate table SLR_BM_LATEST_BAL_TMP';

    pdate_string := to_char(pBalanceDate, 'YYYY-MM-DD');
    pdate_string_part := 'P'||to_char(pBalanceDate, 'YYYYMMDD');

    SELECT COUNT(1) INTO v_partition FROM user_tab_partitions WHERE table_name ='SLR_LAST_BALANCES' AND partition_name = pdate_string_part ;
    IF v_partition=0 THEN
         SLR_ADMIN_PKG.CreateDatePartitions('SLR_LAST_BALANCES', pDateTo => pbalancedate);
    END IF;


    FOR r_epg IN (SELECT DISTINCT lbh_epg_id AS epg_id
                    FROM slr_last_balance_helper --slr_last_balances_index
                   WHERE lbh_generated_for <> pBalanceDate) LOOP


      slr_admin_pkg.addepgsubpartition('SLR_LAST_BALANCES',
                                       p_epg_id           => r_epg.epg_id,
                                       p_datefrom         => pBalanceDate,
                                       p_dateto           => pBalanceDate);

      slr_post_journals_pkg.pgeneratelastbalances(p_epg_id     => r_epg.epg_id,
                                                  p_process_id => gProcessId,
                                                  p_day        => pBalanceDate);
    END LOOP;

    IF (gWhichAmount = 'L') THEN
      amount_string := 'TRAN_LTD_BALANCE as BTRAN, BASE_LTD_BALANCE as BBASE, LOCAL_LTD_BALANCE as BLOCAL';
    END IF;
    IF (gWhichAmount = 'Y') THEN
      amount_string := 'case when p1.EP_BUS_YEAR = PERIOD_YEAR then TRAN_YTD_BALANCE else 0 end as BTRAN, case when p1.EP_BUS_YEAR = PERIOD_YEAR then BASE_YTD_BALANCE else 0 end as BBASE, case when p1.EP_BUS_YEAR = PERIOD_YEAR then LOCAL_YTD_BALANCE else 0 end as BLOCAL';
    END IF;
    IF (gWhichAmount = 'P') THEN
      amount_string := 'case when p1.EP_BUS_YEAR = PERIOD_YEAR and p1.EP_BUS_PERIOD = PERIOD_MONTH then TRAN_MTD_BALANCE else 0 end as BTRAN, case when p1.EP_BUS_YEAR = PERIOD_YEAR and p1.EP_BUS_PERIOD = PERIOD_MONTH then BASE_MTD_BALANCE else 0 end as BBASE, case when p1.EP_BUS_YEAR = PERIOD_YEAR and p1.EP_BUS_PERIOD = PERIOD_MONTH then LOCAL_MTD_BALANCE else 0 end as BLOCAL';
    END IF;

    sql_string := '
    insert into SLR_BM_LATEST_BAL_TMP(KEY_ID, FAK_ID, BALANCE_DATE, BALANCE_TYPE, TRAN_BALANCE, BASE_BALANCE, LOCAL_BALANCE, EPG_ID)
    select BID, BFAK, BDATE, BTYPE, BTRAN, BBASE, BLOCAL, BEPGID from
    (
    select KEY_ID as BID, FAK_ID as BFAK, BALANCE_DATE as BDATE, BALANCE_TYPE as BTYPE, ENTITY as BENTITY, ' ||
                  amount_string || ', EPG_ID AS BEPGID

    from ' || gprocesssource.ps_source_obj1 ||
                  ' inner join SLR_ENTITY_PERIODS p1 on p1.EP_ENTITY = ENTITY and to_date(''' ||
                  pdate_string ||
                  ''', ''YYYY-MM-DD'') between p1.EP_CAL_PERIOD_START and p1.EP_CAL_PERIOD_END and GENERATED_FOR = to_date(''' ||
                  pdate_string || ''', ''YYYY-MM-DD'')';

    IF (gprocess NOT IN ('PLRETEARNINGS', 'FXPLSWEEP', 'PLREPATRIATION')) THEN
      sql_string := sql_string || ' where 1=1 ';
    ELSE
      sql_string := sql_string ||
                    ' INNER JOIN SLR_ENTITY_PERIODS p2 ON (p2.EP_ENTITY = p1.EP_ENTITY AND p2.EP_BUS_YEAR = p1.EP_BUS_YEAR AND p2.EP_BUS_PERIOD = 1)' ||
                    ' WHERE BALANCE_DATE >= p2.EP_BUS_PERIOD_START';
    END IF;

    sql_string := sql_string ||
                  ' and ENTITY in (select BMEPS_ENTITY from SLR_BM_ENTITY_PROCESSING_SET where BMEPS_SET_ID = ''' ||
                  pentprocset || ''')
    and BALANCE_DATE <= to_date(''' || pdate_string ||
                  ''' , ''YYYY-MM-DD'')
    )';

    pbmtracejob('pBMGetLatestBalance', sql_string);

    EXECUTE IMMEDIATE sql_string;

  END pbmgetlatestbal;


  PROCEDURE pBMGetLatestBalance(pbalancedate IN DATE,
                                pentprocset  IN slr_bm_entity_processing_set.bmeps_set_id%TYPE) AS
    sql_string    VARCHAR2(10000);
    pdate_string  VARCHAR2(10);
    amount_string VARCHAR2(1024);
    v_bal_kind    VARCHAR2(100);
  BEGIN

   if (UPPER( gprocesssource.ps_source_obj1) = 'VBMFXCLEARDOWNEBA'
    or UPPER( gprocesssource.ps_source_obj1) = 'VBMFXPNLSWEEPEBA1'
      or UPPER( gprocesssource.ps_source_obj1) = 'VBMFXPOSITIONREBALANCINGEBA1'
    or UPPER( gprocesssource.ps_source_obj1) = 'VBMFXREVALUATIONEBA1'
      or UPPER( gprocesssource.ps_source_obj1) = 'VBMREPATRIATIONEBA'
      or UPPER( gprocesssource.ps_source_obj1) = 'VBMRETAINEDEARNINGSEBA' ) then
         pBMGetLatestBal(pbalancedate, pentprocset);
    else
         pBMGetLatestBalanceFak(pbalancedate, pentprocset);
    END IF;


  END pBMGetLatestBalance;

END SLR_BALANCE_MOVEMENT_PKG;
/
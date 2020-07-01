package com.aptitudesoftware.test.aah;

import java.nio.file.Path;
import java.nio.file.Paths;
import org.apache.log4j.Logger;

public class AAHEnvironmentConstants {
	private static final Logger LOG = Logger.getLogger(AAHEnvironmentConstants.class);
	static {
		AAHEnvironmentConstants.ENVIRONMENT = System.getProperty("test.env");
		LOG.debug("AAHEnvironmentConstants.ENVIRONMENT = '" + AAHEnvironmentConstants.ENVIRONMENT + "'");
		
		AAHEnvironmentConstants.DATABASE_PLATFORM = System.getProperty("test.databasePlatform");
		LOG.debug("AAHEnvironmentConstants.DATABASE_PLATFORM = '" + AAHEnvironmentConstants.DATABASE_PLATFORM + "'");
		
		AAHEnvironmentConstants.DATABASE_TEST_USERNAME = System.getProperty("test.databaseTestUsername");
		LOG.debug("AAHEnvironmentConstants.DATABASE_TEST_USERNAME = '" + AAHEnvironmentConstants.DATABASE_TEST_USERNAME
				+ "'");
		
		AAHEnvironmentConstants.PATH_TO_SSH_KEY = Paths.get(System.getProperty("test.pathToSSHKey"));
		LOG.debug("AAHEnvironmentConstants.PATH_TO_SSH_KEY = '" + AAHEnvironmentConstants.PATH_TO_SSH_KEY + "'");
		
		AAHEnvironmentConstants.APTITUDE_HOST = System.getProperty("test.aptitudeHost");
		LOG.debug("AAHEnvironmentConstants.APTITUDE_HOST = '" + AAHEnvironmentConstants.APTITUDE_HOST + "'");
		
		AAHEnvironmentConstants.APTITUDE_TEST_LINUX_USERNAME = System.getProperty("test.aptitudeLinuxUsername");
		LOG.debug("AAHEnvironmentConstants.APTITUDE_TEST_LINUX_USERNAME = '"
				+ AAHEnvironmentConstants.APTITUDE_TEST_LINUX_USERNAME + "'");
		
		AAHEnvironmentConstants.APTITUDE_LINUX_USERNAME = System.getProperty("test.aptitudeLinuxUsername");
		LOG.debug("AAHEnvironmentConstants.APTITUDE_LINUX_USERNAME = '"
				+ AAHEnvironmentConstants.APTITUDE_LINUX_USERNAME + "'");
		
		AAHEnvironmentConstants.APTITUDE_LINUX_GROUP = System.getProperty("test.aptitudeLinuxGroup");
		LOG.debug("AAHEnvironmentConstants.APTITUDE_LINUX_GROUP = '" + AAHEnvironmentConstants.APTITUDE_LINUX_GROUP
				+ "'");
		
		AAHEnvironmentConstants.PATH_TO_STEP_SCRIPT = System.getProperty("test.pathToStepScript");
		LOG.debug(
				"AAHEnvironmentConstants.PATH_TO_STEP_SCRIPT = '" + AAHEnvironmentConstants.PATH_TO_STEP_SCRIPT + "'");
		
		AAHEnvironmentConstants.STEP_NAME_APPEND = System.getProperty("test.stepNameAppend");
		LOG.debug(
				"AAHEnvironmentConstants.STEP_NAME_APPEND = '" + AAHEnvironmentConstants.STEP_NAME_APPEND + "'");
		
		AAHEnvironmentConstants.STEP_SCRIPT_EXEC_FOLDER = System.getProperty("test.stepScriptExecutionFolder");
		LOG.debug("AAHEnvironmentConstants.STEP_SCRIPT_EXEC_FOLDER = '"
				+ AAHEnvironmentConstants.STEP_SCRIPT_EXEC_FOLDER + "'");
		
		AAHEnvironmentConstants.ORACLE_HOST_NAME = System.getProperty("test.databaseHost");
		LOG.debug("AAHEnvironmentConstants.ORACLE_HOST_NAME = '" + AAHEnvironmentConstants.ORACLE_HOST_NAME + "'");
		
		AAHEnvironmentConstants.ORACLE_TNS_ALIAS = System.getProperty("test.oracleTnsAlias");
		LOG.debug("AAHEnvironmentConstants.ORACLE_TNS_ALIAS = '" + AAHEnvironmentConstants.ORACLE_TNS_ALIAS + "'");
		
		AAHEnvironmentConstants.PATH_TO_ORACLE_WALLET = Paths.get(System.getProperty("test.pathToOracleWallet"));
		LOG.debug("AAHEnvironmentConstants.PATH_TO_ORACLE_WALLET = '" + AAHEnvironmentConstants.PATH_TO_ORACLE_WALLET
				+ "'");
		
		AAHEnvironmentConstants.TERADATA_HOST_NAME = System.getProperty("test.teradataHost");
		LOG.debug("AAHEnvironmentConstants.TERADATA_HOST_NAME = '" + AAHEnvironmentConstants.TERADATA_HOST_NAME + "'");
		
		AAHEnvironmentConstants.DATABASE_TEST_SCHEMA = System.getProperty("test.databaseTestSchema");
		LOG.debug("AAHEnvironmentConstants.DATABASE_SCHEMA = '"
				+ AAHEnvironmentConstants.DATABASE_TEST_SCHEMA + "'");
		
		AAHEnvironmentConstants.ORACLE_PORT = (System.getProperty("test.oraclePort").isEmpty() ? -1
				: Integer.parseInt(System.getProperty("test.oraclePort")));
		LOG.debug("AAHEnvironmentConstants.ORACLE_PORT = '" + AAHEnvironmentConstants.ORACLE_PORT + "'");
		
		AAHEnvironmentConstants.DATABASE_LOG_MECH = System.getProperty("test.databaseLogMech");
		LOG.debug("AAHEnvironmentConstants.DATABASE_LOG_MECH = '" + AAHEnvironmentConstants.DATABASE_LOG_MECH + "'");
		
		AAHEnvironmentConstants.AAH_STN_DB = System.getProperty("test.stnUsername");
		LOG.debug("AAHEnvironmentConstants.AAH_STN_DB = '" + AAHEnvironmentConstants.AAH_STN_DB + "'");
		
		AAHEnvironmentConstants.AAH_FDR_DB = System.getProperty("test.fdrUsername");
		LOG.debug("AAHEnvironmentConstants.AAH_FDR_DB = '" + AAHEnvironmentConstants.AAH_FDR_DB + "'");
		
		AAHEnvironmentConstants.AAH_SLR_DB = System.getProperty("test.slrUsername");
		LOG.debug("AAHEnvironmentConstants.AAH_SLR_DB = '" + AAHEnvironmentConstants.AAH_SLR_DB + "'");
		
		AAHEnvironmentConstants.AAH_RDR_DB = System.getProperty("test.rdrUsername");
		LOG.debug("AAHEnvironmentConstants.AAH_RDR_DB = '" + AAHEnvironmentConstants.AAH_RDR_DB + "'");
		
		AAHEnvironmentConstants.AAH_GUI_DB = System.getProperty("test.guiUsername");
		LOG.debug("AAHEnvironmentConstants.AAH_GUI_DB = '" + AAHEnvironmentConstants.AAH_GUI_DB + "'");
		
		AAHEnvironmentConstants.AAH_IO_DB = System.getProperty("test.ioDatabase");
		LOG.debug("AAHEnvironmentConstants.AAH_IO_DB = '" + AAHEnvironmentConstants.AAH_IO_DB + "'");

		AAHEnvironmentConstants.DATABASE_TEST_PASSWORD = System.getProperty("test.databaseTestPassword");
		LOG.debug((AAHEnvironmentConstants.DATABASE_TEST_PASSWORD.isEmpty()
				? "AAHEnvironmentConstants.DATABASE_TEST_PASSWORD is empty" : ""));
		
		AAHEnvironmentConstants.APTITUDE_TEST_LINUX_PASSWORD = System.getProperty("test.aptitudeLinuxPassword");
		LOG.debug((AAHEnvironmentConstants.APTITUDE_TEST_LINUX_PASSWORD.isEmpty()
				? "AAHEnvironmentConstants.APTITUDE_TEST_LINUX_PASSWORD is empty" : ""));
	}
	

	public static String ENVIRONMENT;
	public static String DATABASE_PLATFORM;
	public static String DATABASE_TEST_USERNAME;
	public static String DATABASE_TEST_PASSWORD;
	public static String DATABASE_TEST_SCHEMA;
	public static String DATABASE_LOG_MECH;

	public static String AAH_STN_DB;
	public static String AAH_FDR_DB;
	public static String AAH_SLR_DB;
	public static String AAH_RDR_DB;
	public static String AAH_GUI_DB;
	public static String AAH_IO_DB;

	public static Path PATH_TO_SSH_KEY;
	public static String APTITUDE_HOST;
	public static String APTITUDE_TEST_LINUX_USERNAME;
	public static String APTITUDE_TEST_LINUX_PASSWORD;
	public static String APTITUDE_LINUX_USERNAME;
	public static String APTITUDE_LINUX_GROUP;
	public static String PATH_TO_STEP_SCRIPT;
	public static String STEP_SCRIPT_EXEC_FOLDER;
	public static String STEP_NAME_APPEND;

	/* Oracle specific variables */
	public static String ORACLE_HOST_NAME;
	public static String ORACLE_TNS_ALIAS;
	public static int ORACLE_PORT;
	public static Path PATH_TO_ORACLE_WALLET;

	/* Teradata specific variables */
	public static String TERADATA_HOST_NAME;
}

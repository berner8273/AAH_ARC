package com.aptitudesoftware.test.quality.sql;

import java.nio.file.Path;
import java.nio.file.Paths;
import org.apache.log4j.Logger;

public class RuntimeConstants
{
    private static final Logger LOG = Logger.getLogger ( RuntimeConstants.class );

    static
    {
        RuntimeConstants.ORACLE_PORT                    = (
                                                              System.getProperty ( "test.oraclePort" ).isEmpty ()
                                                              ?
                                                              -1
                                                              : Integer.parseInt ( System.getProperty ( "test.oraclePort" ) )
                                                          );
        RuntimeConstants.ORACLE_TNS_ALIAS               = System.getProperty ( "test.oracleTnsAlias" );                      LOG.debug ( "RuntimeConstants.ORACLE_TNS_ALIAS = '"              + RuntimeConstants.ORACLE_TNS_ALIAS + "'" );
        RuntimeConstants.PATH_TO_ORACLE_WALLET          = Paths.get ( System.getProperty ( "test.pathToOracleWallet" ) );    LOG.debug ( "RuntimeConstants.PATH_TO_ORACLE_WALLET = '"         + RuntimeConstants.PATH_TO_ORACLE_WALLET + "'" );

        RuntimeConstants.DATABASE_HOST_NAME             = System.getProperty ( "test.databaseHost" );                        LOG.debug ( "RuntimeConstants.DATABASE_HOST_NAME = '"            + RuntimeConstants.DATABASE_HOST_NAME + "'" );
        RuntimeConstants.DATABASE_LOG_MECH              = System.getProperty ( "test.databaseLogMech" );                     LOG.debug ( "RuntimeConstants.DATABASE_LOG_MECH = '"             + RuntimeConstants.DATABASE_LOG_MECH + "'" );
        RuntimeConstants.DATABASE_PLATFORM              = System.getProperty ( "test.databasePlatform" );                    LOG.debug ( "RuntimeConstants.DATABASE_PLATFORM = '"             + RuntimeConstants.DATABASE_PLATFORM + "'" );
        RuntimeConstants.DATABASE_TEST_USERNAME         = System.getProperty ( "test.databaseTestUsername" );                LOG.debug ( "RuntimeConstants.DATABASE_TEST_USERNAME = '"        + RuntimeConstants.DATABASE_TEST_USERNAME + "'" );
        RuntimeConstants.DATABASE_TEST_PASSWORD         = System.getProperty ( "test.databaseTestPassword" );                LOG.debug ( ( RuntimeConstants.DATABASE_TEST_PASSWORD.isEmpty ()  ? "RuntimeConstants.DATABASE_TEST_PASSWORD is empty"  : "" ) );
        RuntimeConstants.TERADATA_TEST_DEFAULT_DATABASE = System.getProperty ( "test.teradataTestDefaultDatabase" );         LOG.debug ( "RuntimeConstants.TERADATA_TEST_DEFAULT_DATABASE = '" + RuntimeConstants.TERADATA_TEST_DEFAULT_DATABASE + "'" );
    }

    public static int    ORACLE_PORT;
    public static String ORACLE_TNS_ALIAS;
    public static Path   PATH_TO_ORACLE_WALLET;

    public static String DATABASE_HOST_NAME;
    public static String DATABASE_LOG_MECH;
    public static String DATABASE_PLATFORM;
    public static String DATABASE_TEST_USERNAME;
    public static String DATABASE_TEST_PASSWORD;
    public static String TERADATA_TEST_DEFAULT_DATABASE;
}

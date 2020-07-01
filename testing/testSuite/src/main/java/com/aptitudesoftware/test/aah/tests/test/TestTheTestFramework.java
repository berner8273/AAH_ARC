package com.aptitudesoftware.test.aah.tests.test;

import com.aptitudesoftware.test.aah.AAHDatabaseConnectorFactory;
import com.aptitudesoftware.test.aah.AAHDatabaseTableOperatorFactory;
import com.aptitudesoftware.test.aah.AAHDataComparisonOperatorFactory;
import com.aptitudesoftware.test.aah.AAHExcelOperatorFactory;
import com.aptitudesoftware.test.aah.AAHEnvironmentConstants;
import com.aptitudesoftware.test.aah.AAHResources;
import com.aptitudesoftware.test.aah.AAHServerOperatorFactory;
import com.aptitudesoftware.test.aah.AAHTokenReplacement;
import com.aptitudesoftware.test.tlf.database.DatabasePlatformConstants;
import com.aptitudesoftware.test.tlf.database.IDataComparisonOperator;
import com.aptitudesoftware.test.tlf.database.IDatabaseConnector;
import com.aptitudesoftware.test.tlf.database.IDatabaseTableOperator;
import com.aptitudesoftware.test.tlf.excel.IExcelOperator;
import com.aptitudesoftware.test.tlf.server.IServerOperator;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import org.apache.log4j.Logger;
import org.testng.Assert;
import org.testng.annotations.Test;

public class TestTheTestFramework
{
    private static final Logger LOG = Logger.getLogger ( TestTheTestFramework.class );

    private final Path                    PATH_TO_RESOURCES = AAHResources.getPathToResource ( "TestTheTestFramework" );
    private final IDatabaseConnector      DB_CONN_OPS       = AAHDatabaseConnectorFactory.getDatabaseConnector ();
    private final IDataComparisonOperator DATA_COMP_OPS     = AAHDataComparisonOperatorFactory.getDataComparisonOperator ( DB_CONN_OPS );
    private final IDatabaseTableOperator  DB_TABLE_OPS      = AAHDatabaseTableOperatorFactory.getDatabaseTableOperator ( DB_CONN_OPS );
    private final IExcelOperator          XL_OPS            = AAHExcelOperatorFactory.getExcelOperator ( DB_CONN_OPS );
    private final IServerOperator         SERVER_OPS        = AAHServerOperatorFactory.getServerOperator ();
    private final AAHTokenReplacement     TOKEN_OPS         = new AAHTokenReplacement ();

    private void cleardown () throws Exception
    {
        final IDatabaseTableOperator DB_TABLE_OPS = AAHDatabaseTableOperatorFactory.getDatabaseTableOperator ( AAHDatabaseConnectorFactory.getDatabaseConnector () );

        LOG.debug ( "Drop DUAL_WD" );

        DB_TABLE_OPS.dropIfExists ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "DUAL_WD" );

        LOG.debug ( "Drop DUAL_WOD" );

        DB_TABLE_OPS.dropIfExists ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "DUAL_WOD" );

        LOG.debug ( "Drop ER_DUAL_WD" );

        DB_TABLE_OPS.dropIfExists ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_DUAL_WD" );

        LOG.debug ( "Drop ER_DUAL_WOD" );

        DB_TABLE_OPS.dropIfExists ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "ER_DUAL_WOD" );

        LOG.debug ( "Drop DATA_FROM_SQL" );

        DB_TABLE_OPS.dropIfExists ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "DATA_FROM_SQL" );

        LOG.debug ( "Drop DATA_NO_SQL" );

        DB_TABLE_OPS.dropIfExists ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "DATA_NO_SQL" );
    }

    @Test
    public void testDatabaseConnectivity () throws Exception
    {
        LOG.debug ( "Started : testDatabaseConnectivity" );

        cleardown ();

        LOG.debug ( "Database cleared down" );

        Connection conn = null;

        try
        {
            LOG.debug ( "Get connection to the database" );

            conn = AAHDatabaseConnectorFactory.getDatabaseConnector ().getConnection ();

            LOG.debug ( "Database connection acquired" );

            final boolean IS_CONNECTION_NULL = ( conn == null );

            if ( IS_CONNECTION_NULL )
            {
                LOG.debug ( "The connection is null" );

                Assert.assertFalse ( IS_CONNECTION_NULL );
            }

            final String USERNAME = conn.getMetaData ().getUserName ();

            LOG.debug ( "DB username = " + USERNAME );

            final boolean IS_USERNAME_CORRECT = ( USERNAME.equalsIgnoreCase ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME ) );

            if ( ! IS_USERNAME_CORRECT )
            {
                LOG.debug ( "It was expected that the username would be " + AAHEnvironmentConstants.DATABASE_TEST_USERNAME + " but it is " + USERNAME );

                Assert.assertTrue ( IS_USERNAME_CORRECT );
            }
        }
        catch ( Exception e )
        {
            LOG.debug ( e );

            throw e;
        }
        finally
        {
            conn.close ();
        }

        LOG.debug ( "Ended : testDatabaseConnectivity" );
    }

    @Test
    public void testTableOperators () throws Exception
    {
        LOG.debug ( "Started : testTableOperators" );

        final Path PATH_TO_TEST_RESOURCES                   = PATH_TO_RESOURCES.resolve ( "testTableOperators" );
        final Path PATH_TO_ORACLE_EXPECTED_RESULTS          = PATH_TO_TEST_RESOURCES.resolve ( "OracleExpectedResults.xlsx" );
        final Path PATH_TO_ORACLE_DUAL_WD_ACTUAL_RESULTS    = PATH_TO_TEST_RESOURCES.resolve ( "dual_wd_actual_results.sql" );
        final Path PATH_TO_ORACLE_DUAL_WD_EXPECTED_RESULTS  = PATH_TO_TEST_RESOURCES.resolve ( "dual_wd_expected_results.sql" );
        final Path PATH_TO_ORACLE_DUAL_WOD_ACTUAL_RESULTS   = PATH_TO_TEST_RESOURCES.resolve ( "dual_wod_actual_results.sql" );
        final Path PATH_TO_ORACLE_DUAL_WOD_EXPECTED_RESULTS = PATH_TO_TEST_RESOURCES.resolve ( "dual_wod_expected_results.sql" );

        if ( ! Files.exists ( PATH_TO_ORACLE_EXPECTED_RESULTS ) )          { LOG.debug ( "'" + PATH_TO_ORACLE_EXPECTED_RESULTS.toString ()          + "' does not exist." ); assert ( false ); };
        if ( ! Files.exists ( PATH_TO_ORACLE_DUAL_WD_ACTUAL_RESULTS ) )    { LOG.debug ( "'" + PATH_TO_ORACLE_DUAL_WD_ACTUAL_RESULTS.toString ()    + "' does not exist." ); assert ( false ); };
        if ( ! Files.exists ( PATH_TO_ORACLE_DUAL_WD_EXPECTED_RESULTS ) )  { LOG.debug ( "'" + PATH_TO_ORACLE_DUAL_WD_EXPECTED_RESULTS.toString ()  + "' does not exist." ); assert ( false ); };
        if ( ! Files.exists ( PATH_TO_ORACLE_DUAL_WOD_ACTUAL_RESULTS ) )   { LOG.debug ( "'" + PATH_TO_ORACLE_DUAL_WOD_ACTUAL_RESULTS.toString ()   + "' does not exist." ); assert ( false ); };
        if ( ! Files.exists ( PATH_TO_ORACLE_DUAL_WOD_EXPECTED_RESULTS ) ) { LOG.debug ( "'" + PATH_TO_ORACLE_DUAL_WOD_EXPECTED_RESULTS.toString () + "' does not exist." ); assert ( false ); };

        cleardown ();

        LOG.debug ( "A database table operator has been constructed" );

        if ( AAHEnvironmentConstants.DATABASE_PLATFORM.equals ( DatabasePlatformConstants.ORACLE.toString () ) )
        {
            LOG.debug ( "The database platform is Oracle" );

            final boolean DUAL_EXISTS = DB_TABLE_OPS.checkIfExists ( "SYS" , "DUAL" );

            if ( DUAL_EXISTS )
            {
                LOG.debug ( "SYS.DUAL was found in the data dictionary" );

                Assert.assertTrue ( DUAL_EXISTS );
            }

            LOG.debug ( "Copy SYS.DUAL to TEST.DUAL_WD, retaining the data" );

            DB_TABLE_OPS.copyTable ( "SYS" , "DUAL" , AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "DUAL_WD"  , true );

            LOG.debug ( "Copy SYS.DUAL to TEST.DUAL_WD, without retaining the data" );

            DB_TABLE_OPS.copyTable ( "SYS" , "DUAL" , AAHEnvironmentConstants.DATABASE_TEST_USERNAME , "DUAL_WOD" , false );

            LOG.debug ( "Create a table to store the expected contents of 'DUAL_WD'" );

            XL_OPS.createDatabaseTableFromExcelTab ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , PATH_TO_ORACLE_EXPECTED_RESULTS , "ER_DUAL_WD" );

            LOG.debug ( "Load data into 'ER_DUAL_WD'" );

            XL_OPS.loadExcelTabToDatabaseTable ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , PATH_TO_ORACLE_EXPECTED_RESULTS , "ER_DUAL_WD" , TOKEN_OPS );

            LOG.debug ( "Compare the actual data in DUAL_WD to ER_DUAL_WD" );

            Assert.assertEquals
            (
                0
            ,   DATA_COMP_OPS.countMinusQueryResults
                (
                    PATH_TO_ORACLE_DUAL_WD_ACTUAL_RESULTS
                ,   PATH_TO_ORACLE_DUAL_WD_EXPECTED_RESULTS
                ,   new String[] {}
                ,   TOKEN_OPS
                )
            );

            LOG.debug ( "Create a table to store the expected contents of 'DUAL_WOD'" );

            XL_OPS.createDatabaseTableFromExcelTab ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , PATH_TO_ORACLE_EXPECTED_RESULTS , "ER_DUAL_WOD" );

            LOG.debug ( "Load data into 'ER_DUAL_WOD'" );

            XL_OPS.loadExcelTabToDatabaseTable ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , PATH_TO_ORACLE_EXPECTED_RESULTS , "ER_DUAL_WOD" , TOKEN_OPS );

            LOG.debug ( "Compare the actual data in DUAL_WD to ER_DUAL_WOD" );

            Assert.assertEquals
            (
                0
            ,   DATA_COMP_OPS.countMinusQueryResults
                (
                    PATH_TO_ORACLE_DUAL_WOD_ACTUAL_RESULTS
                ,   PATH_TO_ORACLE_DUAL_WOD_EXPECTED_RESULTS
                ,   new String[] {}
                ,   TOKEN_OPS
                )
            );

            cleardown ();
        }

        LOG.debug ( "Ended : testTableOperators" );
    }

    @Test
    public void testExcelOperators () throws Exception
    {
        LOG.debug ( "Started : testExcelOperators" );

        final Path PATH_TO_TEST_RESOURCES                      = PATH_TO_RESOURCES.resolve ( "testExcelOperators" );
        final Path PATH_TO_ORACLE_EXPECTED_RESULTS             = PATH_TO_TEST_RESOURCES.resolve ( "OracleExpectedResults.xlsx" );
        final Path PATH_TO_ORACLE_DATA_FROM_SQL_ACTUAL_RESULTS = PATH_TO_TEST_RESOURCES.resolve ( "data_from_sql_actual_results.sql" );
        final Path PATH_TO_ORACLE_DATA_NO_SQL_ACTUAL_RESULTS   = PATH_TO_TEST_RESOURCES.resolve ( "data_no_sql_actual_results.sql" );

        if ( ! Files.exists ( PATH_TO_ORACLE_EXPECTED_RESULTS ) )             { LOG.debug ( "'" + PATH_TO_ORACLE_EXPECTED_RESULTS.toString ()             + "' does not exist." ); assert ( false ); };
        if ( ! Files.exists ( PATH_TO_ORACLE_DATA_FROM_SQL_ACTUAL_RESULTS ) ) { LOG.debug ( "'" + PATH_TO_ORACLE_DATA_FROM_SQL_ACTUAL_RESULTS.toString () + "' does not exist." ); assert ( false ); };
        if ( ! Files.exists ( PATH_TO_ORACLE_DATA_NO_SQL_ACTUAL_RESULTS) )    { LOG.debug ( "'" + PATH_TO_ORACLE_DATA_NO_SQL_ACTUAL_RESULTS.toString ()   + "' does not exist." ); assert ( false ); };

        cleardown ();

        if ( AAHEnvironmentConstants.DATABASE_PLATFORM.equals ( DatabasePlatformConstants.ORACLE.toString () ) )
        {
            LOG.debug ( "The database platform is Oracle" );

            LOG.debug ( "Create a table to store the data whose contents are not based on SQL" );

            XL_OPS.createDatabaseTableFromExcelTab ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , PATH_TO_ORACLE_EXPECTED_RESULTS , "DATA_NO_SQL" );

            LOG.debug ( "Load data into 'DATA_NO_SQL'" );

            XL_OPS.loadExcelTabToDatabaseTable ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , PATH_TO_ORACLE_EXPECTED_RESULTS , "DATA_NO_SQL" , TOKEN_OPS );

            LOG.debug ( "Create a table to store the data whose contents *are* based on SQL" );

            XL_OPS.createDatabaseTableFromExcelTab ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , PATH_TO_ORACLE_EXPECTED_RESULTS , "DATA_FROM_SQL" );

            LOG.debug ( "Load data into 'DATA_NO_SQL'" );

            XL_OPS.loadExcelTabToDatabaseTable ( AAHEnvironmentConstants.DATABASE_TEST_USERNAME , PATH_TO_ORACLE_EXPECTED_RESULTS , "DATA_FROM_SQL" , TOKEN_OPS );

            LOG.debug ( "Compare the data in DATA_FROM_SQL to DATA_NO_SQL" );

            Assert.assertEquals
            (
                0
            ,   DATA_COMP_OPS.countMinusQueryResults
                (
                    PATH_TO_ORACLE_DATA_FROM_SQL_ACTUAL_RESULTS
                ,   PATH_TO_ORACLE_DATA_NO_SQL_ACTUAL_RESULTS
                ,   new String[] {}
                ,   TOKEN_OPS
                )
            );
        }

        LOG.debug ( "Ended : testExcelOperators" );
    }

    @Test
    public void testServerOperators () throws Exception
    {
        LOG.debug ( "Started : testServerOperators" );

        final Path PATH_TO_TEST_RESOURCES = PATH_TO_RESOURCES.resolve ( "testServerOperators" );
        final Path PATH_TO_TEST_FILE      = PATH_TO_TEST_RESOURCES.resolve ( "testFile.txt" );

        LOG.debug ( "Connect to the server and print the working directory (pwd)" );

        SERVER_OPS.executeCommand ( "pwd" );

        LOG.debug ( "Connect to the server and put a file in the working directory" );

        SERVER_OPS.sendFileToServer ( "/tmp" , PATH_TO_TEST_FILE );

        LOG.debug ( "Connect to the server and verify that the file is there" );

        SERVER_OPS.executeCommand ( "cat /tmp/testFile.txt" );

        LOG.debug ( "Ended : testServerOperators" );
    }
}
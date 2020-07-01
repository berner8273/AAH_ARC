package com.aptitudesoftware.test.aah;

import com.aptitudesoftware.test.tlf.database.DatabasePlatformConstants;
import com.aptitudesoftware.test.tlf.database.IDatabaseConnector;
import com.aptitudesoftware.test.tlf.database.OracleDatabaseConnector;
import com.aptitudesoftware.test.tlf.database.TeradataDatabaseConnector;
import org.apache.log4j.Logger;
import java.nio.file.Files;

public class AAHDatabaseConnectorFactory
{
    private static final Logger LOG = Logger.getLogger ( AAHDatabaseConnectorFactory.class );

    public static IDatabaseConnector getDatabaseConnector ()
    {
        LOG.debug ( "Getting a database connection for the platform '" + AAHEnvironmentConstants.DATABASE_PLATFORM + "';" );

        IDatabaseConnector dbConn = null;

        try
        {
            if ( AAHEnvironmentConstants.DATABASE_PLATFORM.equals ( DatabasePlatformConstants.ORACLE.toString () ) )
            {
                LOG.debug ( "The target database platform is Oracle" );

                LOG.debug ( "PATH_TO_ORACLE_WALLET = '" + AAHEnvironmentConstants.PATH_TO_ORACLE_WALLET + "'" );

                final boolean USE_WALLET = (
                                               ( Files.isDirectory ( AAHEnvironmentConstants.PATH_TO_ORACLE_WALLET ) )
                                               &&
                                               ( Files.newDirectoryStream ( AAHEnvironmentConstants.PATH_TO_ORACLE_WALLET ).iterator ().hasNext () )
                                           );

                LOG.debug ( "Wallets will" + ( USE_WALLET ? "" : " not" ) + " be used." );

                if ( USE_WALLET )
                {
                    LOG.debug ( "A connection will be made using an Oracle wallet" );

                    dbConn = new OracleDatabaseConnector ( AAHEnvironmentConstants.PATH_TO_ORACLE_WALLET , AAHEnvironmentConstants.ORACLE_TNS_ALIAS );
                }
                else
                {
                    LOG.debug ( "A connection will be made using an Oracle username and password" );

                    dbConn = new OracleDatabaseConnector
                                 (
                                     AAHEnvironmentConstants.ORACLE_HOST_NAME
                                 ,   AAHEnvironmentConstants.DATABASE_TEST_USERNAME
                                 ,   AAHEnvironmentConstants.DATABASE_TEST_PASSWORD
                                 ,   AAHEnvironmentConstants.ORACLE_PORT
                                 ,   AAHEnvironmentConstants.ORACLE_TNS_ALIAS
                                 );
                }
            }
            else if ( AAHEnvironmentConstants.DATABASE_PLATFORM.equals ( DatabasePlatformConstants.TERADATA.toString () ) )
            {
                LOG.debug ( "The target database platform is Teradata" );

                dbConn = new TeradataDatabaseConnector
                             (
                                 AAHEnvironmentConstants.TERADATA_HOST_NAME
                             ,   AAHEnvironmentConstants.DATABASE_TEST_USERNAME
                             ,   AAHEnvironmentConstants.DATABASE_TEST_PASSWORD
                             ,   AAHEnvironmentConstants.DATABASE_TEST_SCHEMA
                             ,   false
                             ,   AAHEnvironmentConstants.DATABASE_LOG_MECH
                             );
            }
            else
            {
                LOG.debug ( "The target database platform is '" + AAHEnvironmentConstants.DATABASE_PLATFORM + "' - which is not a supported platform." );

                assert ( false );
            }
        }
        catch ( Exception e )
        {
            LOG.debug ( "A critical error has occurred : " + e );

            System.exit ( -1 );
        }

        return dbConn;
    }
}

package com.aptitudesoftware.test.quality.sql;

import com.aptitudesoftware.test.tlf.database.DatabasePlatformConstants;
import com.aptitudesoftware.test.tlf.database.IDatabaseConnector;
import com.aptitudesoftware.test.tlf.database.OracleDatabaseConnector;
import com.aptitudesoftware.test.tlf.database.TeradataDatabaseConnector;
import org.apache.log4j.Logger;
import java.nio.file.Files;

public class DatabaseConnectorFactory
{
    private static final Logger LOG = Logger.getLogger ( DatabaseConnectorFactory.class );

    public static IDatabaseConnector getDatabaseConnector ()
    {
        LOG.debug ( "Getting a database connection for the platform '" + RuntimeConstants.DATABASE_PLATFORM + "';" );

        IDatabaseConnector dbConn = null;

        try
        {
            if ( RuntimeConstants.DATABASE_PLATFORM.equals ( DatabasePlatformConstants.ORACLE.toString () ) )
            {
                LOG.debug ( "The target database platform is Oracle" );

                LOG.debug ( "PATH_TO_ORACLE_WALLET = '" + RuntimeConstants.PATH_TO_ORACLE_WALLET + "'" );

                final boolean USE_WALLET = (
                                               ( Files.isDirectory ( RuntimeConstants.PATH_TO_ORACLE_WALLET ) )
                                               &&
                                               ( Files.newDirectoryStream ( RuntimeConstants.PATH_TO_ORACLE_WALLET ).iterator ().hasNext () )
                                           );

                LOG.debug ( "Wallets will" + ( USE_WALLET ? "" : " not" ) + " be used." );

                if ( USE_WALLET )
                {
                    LOG.debug ( "A connection will be made using an Oracle wallet" );

                    dbConn = new OracleDatabaseConnector ( RuntimeConstants.PATH_TO_ORACLE_WALLET , RuntimeConstants.ORACLE_TNS_ALIAS );
                }
                else
                {
                    LOG.debug ( "A connection will be made using an Oracle username and password" );

                    dbConn = new OracleDatabaseConnector
                                 (
                                     RuntimeConstants.DATABASE_HOST_NAME
                                 ,   RuntimeConstants.DATABASE_TEST_USERNAME
                                 ,   RuntimeConstants.DATABASE_TEST_PASSWORD
                                 ,   RuntimeConstants.ORACLE_PORT
                                 ,   RuntimeConstants.ORACLE_TNS_ALIAS
                                 );
                }
            }
            else if ( RuntimeConstants.DATABASE_PLATFORM.equals ( DatabasePlatformConstants.TERADATA.toString () ) )
            {
                LOG.debug ( "The target database platform is Teradata" );

                dbConn = new TeradataDatabaseConnector
                             (
                                 RuntimeConstants.DATABASE_HOST_NAME
                             ,   RuntimeConstants.DATABASE_TEST_USERNAME
                             ,   RuntimeConstants.DATABASE_TEST_PASSWORD
                             ,   RuntimeConstants.TERADATA_TEST_DEFAULT_DATABASE
                             ,   false
                             ,   RuntimeConstants.DATABASE_LOG_MECH
                             );
            }
            else
            {
                LOG.debug ( "The target database platform is '" + RuntimeConstants.DATABASE_PLATFORM + "' - which is not a supported platform." );

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
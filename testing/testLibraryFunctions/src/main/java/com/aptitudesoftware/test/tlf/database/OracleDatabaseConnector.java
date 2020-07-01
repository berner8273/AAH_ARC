package com.aptitudesoftware.test.tlf.database;

//import java.net.URL;
//import java.net.URLClassLoader;
import java.nio.file.Path;
import java.nio.file.Files;
import java.sql.Connection;
import java.sql.DriverManager;
import org.apache.log4j.Logger;

public class OracleDatabaseConnector implements IDatabaseConnector
{
    private static final Logger LOG = Logger.getLogger ( OracleDatabaseConnector.class );

    private final String DRIVER_CLASS = "oracle.jdbc.OracleDriver";

    private String  jdbcUrl        = "jdbc:oracle:thin:";
    private String  username       = "";
    private String  password       = "";
    private String  tnsAdmin       = "";
    private Path    walletLocation = null;
    private boolean useWallet      = false;

    public OracleDatabaseConnector ( final String pDBServerName , final String pUsername , final String pPassword , final int pPortNumber , final String pTnsAlias ) throws Exception
    {
        if ( pPortNumber < 0 )
        {
            throw new Exception ( "The Oracle port number must be '0' or above. 1521 is the default value used by Oracle." ); 
        };

        jdbcUrl  = jdbcUrl + "@" + pDBServerName + ":" + pPortNumber + "/" + pTnsAlias;

        LOG.debug ( "The Oracle jdbc URL was set to '" + jdbcUrl + "'" );

        username = pUsername;

        LOG.debug ( "The Oracle username was set to '" + username + "'" );

        password = pPassword;
    }

    public OracleDatabaseConnector ( final Path pWalletLocation , final String pTnsAlias ) throws Exception
    {
        tnsAdmin = System.getenv ( "TNS_ADMIN" );

        if ( tnsAdmin == null )
        {
            throw new Exception ( "The 'TNS_ADMIN' environment variable is not defined. Please define it." );
        }

        LOG.debug ( "The value of the TNS_ADMIN environment variable is '" + tnsAdmin + "'" );

        if ( ! Files.isDirectory ( pWalletLocation ) )
        {
            throw new Exception ( "The path '" + pWalletLocation + "' does not refer to a directory - it must refer to a directory containing an Oracle wallet." );
        }

        LOG.debug ( "'" + pWalletLocation + "' is a directory." );

        if ( ! Files.newDirectoryStream ( pWalletLocation ).iterator ().hasNext () )
        {
            throw new Exception ( "The folder '" + pWalletLocation.toString () + "' is empty - it must contain an Oracle wallet." );
        }

        LOG.debug ( "'" + pWalletLocation + "' is not empty." );

        useWallet      = true;

        walletLocation = pWalletLocation;

        jdbcUrl        = jdbcUrl + "/@" + pTnsAlias;

        LOG.debug ( "The Oracle jdbc URL was set to '" + jdbcUrl + "'" );
    }

    public Connection getConnection () throws Exception
    {
        LOG.debug ( "A connection to the database will be retrieved based on the URL '" + jdbcUrl + "'" );
//	ClassLoader cl = ClassLoader.getSystemClassLoader();
//	URL[] urls = ((URLClassLoader)cl).getURLs();
//	for(URL url: urls) {
//	LOG.debug(url.getFile());
//	}
        Class.forName ( DRIVER_CLASS );

        LOG.debug ( "The driver class has been set to '" + DRIVER_CLASS + "'" );

        Connection conn = null;

        if ( useWallet )
        {
            System.setProperty ( "oracle.net.tns_admin"       , tnsAdmin );

            System.setProperty ( "oracle.net.wallet_location" , walletLocation.toString () );
            
            conn = DriverManager.getConnection ( jdbcUrl );
        }
        else
        {
            conn = DriverManager.getConnection ( jdbcUrl , username , password );
        }

        LOG.debug ( "A database connection has been successfully retrieved using the jdbc URL '" + jdbcUrl + "' and username '" + conn.getMetaData ().getUserName () + "'" );

        conn.setAutoCommit ( false );

        LOG.debug ( "Autocommit has been set to 'false' on the database connection" );

        LOG.debug ( "A connection to the database has been successfully retrieved and set up" );

        return conn;
    }
}

package com.aptitudesoftware.test.tlf.database;

import java.sql.Connection;
import java.sql.DriverManager;

import org.apache.log4j.Logger;

public class TeradataDatabaseConnector implements IDatabaseConnector
{
    private static final Logger LOG = Logger.getLogger ( TeradataDatabaseConnector.class );

    private final String DRIVER_CLASS = "com.teradata.jdbc.TeraDriver";

    private String jdbcUrl  = "jdbc:teradata://";
    private String username = "";
    private String password = "";

    public TeradataDatabaseConnector ( final String pDBServerName , final String pUsername , final String pPassword , final String pDefaultDB , final boolean pFastLoad , final String pLogMech)
    {
        jdbcUrl  = jdbcUrl + pDBServerName + "/TMODE=ANSI,DATABASE=" + pDefaultDB + ( pFastLoad ? ",TYPE=FASTLOAD" : "" ) + ((pLogMech != null && !pLogMech.isEmpty()) ? ",LOGMECH=" + pLogMech : "" );

        LOG.debug ( "The Teradata jdbc URL was set to '" + jdbcUrl + "'" );

        username = pUsername;

        LOG.debug ( "The Teradata username was set to '" + username + "'" );

        password = pPassword;
    }

    public Connection getConnection () throws Exception
    {
        LOG.debug ( "A connection to the database will be retrieved based on the URL '" + jdbcUrl + "'" );

        Class.forName ( DRIVER_CLASS );

        LOG.debug ( "The driver class has been set to '" + DRIVER_CLASS + "'" );

        Connection conn = DriverManager.getConnection ( jdbcUrl , username , password );

        LOG.debug ( "A database connection has been successfully retrieved using the jdbc URL '" + jdbcUrl + "' and username '" + username + "'" );

        conn.setAutoCommit ( false );

        LOG.debug ( "Autocommit has been set on the database connection" );

        LOG.debug ( "A connection to the database has been successfully retrieved and set up" );

        return conn;
    }
}

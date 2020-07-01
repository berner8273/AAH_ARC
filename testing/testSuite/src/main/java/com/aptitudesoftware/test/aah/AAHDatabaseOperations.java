package com.aptitudesoftware.test.aah;

import com.aptitudesoftware.test.tlf.database.IDatabaseConnector;

import java.sql.Connection;
import java.sql.CallableStatement;
import java.sql.SQLException;

import org.apache.log4j.Logger;

public class AAHDatabaseOperations
{
    private static final Logger              LOG         = Logger.getLogger ( AAHDatabaseOperations.class );
    private static final IDatabaseConnector  DB_CONN_OPS = AAHDatabaseConnectorFactory.getDatabaseConnector ();
    private static final AAHTokenReplacement AAH_TOK_REP = new AAHTokenReplacement();

    public static void executeSql (final String sql) throws Exception
    {
        Connection        conn  = null;
        CallableStatement cStmt = null;

        final String EXECUTE_SQL =  AAH_TOK_REP.replaceTokensInString(sql);
        LOG.debug ( "Executing the following sql: " + EXECUTE_SQL );
        try
        {
            conn = DB_CONN_OPS.getConnection ();
            LOG.debug ( "A connection to the database was successfully retrieved" );

            cStmt = conn.prepareCall ( EXECUTE_SQL );
            LOG.debug ( "The statements were successfully prepared" );

            cStmt.execute ();
            LOG.debug ( "The statements were successfully executed" );

            conn.commit ();
            LOG.debug ( "The changes were committed to the database" );
        }
        catch ( SQLException sqle )
        {
            LOG.error ( "SQLException : " + sqle );
            throw sqle;
        }
        finally
        {
            cStmt.close ();
            conn.close ();
        }
    }
}
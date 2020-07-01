package com.aptitudesoftware.test.aah;

import com.aptitudesoftware.test.tlf.database.IDatabaseConnector;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import org.apache.log4j.Logger;

public class AAHSLROperations
{
    private static final Logger             LOG         = Logger.getLogger ( AAHSLROperations.class );
    private static final IDatabaseConnector DB_CONN_OPS = AAHDatabaseConnectorFactory.getDatabaseConnector ();

    public static void openAllEntityPeriods () throws Exception
    {
        Connection        conn   = null;
        PreparedStatement pStmt  = null;

        LOG.debug ( "Open all closed entity periods" );

        final String DML = "update slr.slr_entity_periods set ep_status = 'O' ; ";

        try
        {
            conn = DB_CONN_OPS.getConnection ();

            LOG.debug ( "A connection to the database was successfully retrieved" );

            pStmt = conn.prepareStatement ( DML );

            pStmt.addBatch ();

            pStmt.executeUpdate ();

            conn.commit ();

            LOG.debug ( "The changes were committed to the database" );
        }
        catch ( SQLException sqle )
        {
            throw sqle;
        }
        finally
        {
            pStmt.close ();

            conn.close ();
        }
    }
}
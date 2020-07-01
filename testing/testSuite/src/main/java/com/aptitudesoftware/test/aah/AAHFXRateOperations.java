package com.aptitudesoftware.test.aah;

import com.aptitudesoftware.test.tlf.database.IDatabaseConnector;

import java.sql.Connection;
import java.sql.CallableStatement;
import java.sql.SQLException;

import org.apache.log4j.Logger;

public class AAHFXRateOperations
{
    private static final Logger             LOG         = Logger.getLogger ( AAHBusinessDateOperations.class );
    private static final IDatabaseConnector DB_CONN_OPS = AAHDatabaseConnectorFactory.getDatabaseConnector ();

    public static void setNo1To1Days ( final int pNo1To1Days ) throws Exception
    {
        Connection        conn   = null;
        CallableStatement cStmt  = null;

        LOG.debug ( "Set number of days to : " + pNo1To1Days );

        final String DML =   " begin\n "
                           + "     update fdr.fr_general_lookup set lk_lookup_value1 = ? where lk_lkt_lookup_type_code = 'FXR_DEFAULT' and lk_match_key1 = 'NO_1_1_DAYS';"
                           + " end;"
                           ;

        try
        {
            conn = DB_CONN_OPS.getConnection ();

            LOG.debug ( "A connection to the database was successfully retrieved" );

            cStmt = conn.prepareCall ( DML );

            LOG.debug ( "The DML was successfully prepared" );

            cStmt.setInt ( 1 , pNo1To1Days );

            LOG.debug ( "The business date value was bound" );

            cStmt.executeUpdate ();

            conn.commit ();

            LOG.debug ( "The changes were committed to the database" );
        }
        catch ( SQLException sqle )
        {
            LOG.debug ( "A SQL exception occurred whilst setting the business date in fdr.fr_global_parameter : " + sqle );

            throw sqle;
        }
        finally
        {
            cStmt.close ();

            conn.close ();
        }
    }
}
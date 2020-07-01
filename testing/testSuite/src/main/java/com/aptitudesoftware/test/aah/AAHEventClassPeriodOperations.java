package com.aptitudesoftware.test.aah;

import com.aptitudesoftware.test.tlf.database.IDatabaseConnector;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import org.apache.log4j.Logger;

public class AAHEventClassPeriodOperations
{
    private static final Logger             LOG         = Logger.getLogger ( AAHEventClassPeriodOperations.class );
    private static final IDatabaseConnector DB_CONN_OPS = AAHDatabaseConnectorFactory.getDatabaseConnector ();

    public static void setCloseStatus (String sStatus,String sYear, String sPeriod, String sClass ) throws Exception
    {
        Connection        conn   = null;
        //CallableStatement cStmt  = null;  
                                     
        try
        {
        
        conn = DB_CONN_OPS.getConnection ();            
        PreparedStatement ps = conn.prepareStatement("update fdr.fr_general_lookup set lk_lookup_value1 = ? where LK_MATCH_KEY2 = ? and LK_MATCH_KEY3 = ? AND LK_MATCH_KEY1 = ?");
				
				ps.setString(1,sStatus);
				ps.setString(2,sYear);
				ps.setString(3,sPeriod);	
			  ps.setString(4,sClass);	
            

        LOG.debug ( "The DML was successfully prepared" );
				ps.executeUpdate();
					
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

            conn.close ();
        }
    }

    public static void setCloseStatusAll ( String sStatus , String sYear , String sPeriod ) throws Exception
    {
        Connection        conn   = null;
       // CallableStatement cStmt  = null;

        try
        {

        conn = DB_CONN_OPS.getConnection ();
        PreparedStatement ps = conn.prepareStatement("update fdr.fr_general_lookup set lk_lookup_value1 = ? where LK_MATCH_KEY2 = ? and LK_MATCH_KEY3 = ?");

                ps.setString(1,sStatus);
                ps.setString(2,sYear);
                ps.setString(3,sPeriod);

        LOG.debug ( "The DML was successfully prepared" );
                ps.executeUpdate();

            conn.commit ();

            LOG.debug ( "The changes were committed to the database" );
        }
        catch ( SQLException sqle )
        {
            LOG.debug ( "A SQL exception occurred whilst setting the event class period status in fdr.fr_general_lookup : " + sqle );

            throw sqle;
        }
        finally
        {
            conn.close ();
        }
    }
}
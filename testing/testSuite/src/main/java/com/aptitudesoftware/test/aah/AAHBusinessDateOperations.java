package com.aptitudesoftware.test.aah;

import com.aptitudesoftware.test.tlf.database.IDatabaseConnector;

import java.sql.Connection;
import java.sql.CallableStatement;
import java.sql.SQLException;

import java.time.LocalDate;

import org.apache.log4j.Logger;

public class AAHBusinessDateOperations
{
    private static final Logger             LOG         = Logger.getLogger ( AAHBusinessDateOperations.class );
    private static final IDatabaseConnector DB_CONN_OPS = AAHDatabaseConnectorFactory.getDatabaseConnector ();

    public static void setBusinessDate ( final LocalDate pTodaysBusinessDate ) throws Exception
    {
        Connection        conn   = null;
        CallableStatement cStmt  = null;

        LOG.debug ( "Set today's business date to : '" + pTodaysBusinessDate + "' for all LPGs" );

        final String DML =   " begin\n "
                           + "     for i in ( select lpg_id from fdr.fr_global_parameter ) loop "
                           + "         update fdr.fr_global_parameter set gp_todays_bus_date = ? where lpg_id = i.lpg_id; "
                           + "         update slr.slr_entities e      set ent_business_date  = ? where exists ( select null from fdr.fr_lpg_config l where l.lc_lpg_id = i.lpg_id and l.lc_grp_code = e.ent_entity );"
                           + "         fdr.pr_roll_date ( i.lpg_id ); "
                           + "         for j in ( select ent_entity from slr.slr_entities ) loop "
                           + "             slr.slr_pkg.pROLL_ENTITY_DATE ( j.ent_entity , null , 'N' );"
                           + "         end loop;"
                           + "     end loop; "
                           + " end;"
                           ;

        try
        {
            conn = DB_CONN_OPS.getConnection ();

            LOG.debug ( "A connection to the database was successfully retrieved" );

            cStmt = conn.prepareCall ( DML );

            LOG.debug ( "The DML was successfully prepared" );

            cStmt.setDate ( 1 , java.sql.Date.valueOf ( pTodaysBusinessDate.minusDays ( 1 ) ) );

            cStmt.setDate ( 2 , java.sql.Date.valueOf ( pTodaysBusinessDate.minusDays ( 1 ) ) );

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

    public static void setBusinessDate ( final LocalDate pTodaysBusinessDate , final int pLpgId ) throws Exception
    {
        Connection        conn   = null;
        CallableStatement cStmt  = null;

        LOG.debug ( "Set today's business date to : '" + pTodaysBusinessDate + "' against LPG '" + pLpgId + "'" );

        final String DML =   " begin\n "
                           + "     update fdr.fr_global_parameter set gp_todays_bus_date = ? where lpg_id = ?;"
                           + "     update slr.slr_entities e      set ent_business_date  = ? where exists ( select null from fdr.fr_lpg_config l where l.lc_lpg_id = ? and l.lc_grp_code = e.ent_entity );"
                           + "     fdr.pr_roll_date ( ? );"
                           + "     for j in ( select ent_entity from slr.slr_entities e where exists ( select null from fdr.fr_lpg_config l where l.lc_lpg_id = ? and l.lc_grp_code = e.ent_entity ) ) loop "
                           + "         slr.slr_pkg.pROLL_ENTITY_DATE ( j.ent_entity , null , 'N' );"
                           + "     end loop;"
                           + " end;"
                           ;

        try
        {
            conn = DB_CONN_OPS.getConnection ();

            LOG.debug ( "A connection to the database was successfully retrieved" );

            cStmt = conn.prepareCall ( DML );

            LOG.debug ( "The DML was successfully prepared" );

            cStmt.setDate ( 1 , java.sql.Date.valueOf ( pTodaysBusinessDate.minusDays ( 1 ) ) );

            LOG.debug ( "The business date value was bound to the FGP update" );

            cStmt.setInt ( 2 , pLpgId );

            LOG.debug ( "The lpg was bound to the FGP update statement" );

            cStmt.setDate ( 3 , java.sql.Date.valueOf ( pTodaysBusinessDate.minusDays ( 1 ) ) );

            LOG.debug ( "The business date value was bound to the FGP update" );

            cStmt.setInt ( 4 , pLpgId );

            LOG.debug ( "The lpg was bound to the ENT update" );

            cStmt.setInt ( 5 , pLpgId );

            LOG.debug ( "The lpg was bound to the FDR roll date" );

            cStmt.setInt ( 6 , pLpgId );

            LOG.debug ( "The lpg was bound to the SLR roll date" );

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
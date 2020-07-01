package com.aptitudesoftware.test.tlf.database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.apache.log4j.Logger;

public class TeradataDatabaseTableOperator implements IDatabaseTableOperator
{
    private static final Logger LOG = Logger.getLogger ( TeradataDatabaseTableOperator.class );

    private IDatabaseConnector databaseConnector;

    public TeradataDatabaseTableOperator ( final IDatabaseConnector pDatabaseConnector )
    {
        databaseConnector = pDatabaseConnector;
    }

    public boolean checkIfExists ( final String pTableOwner , final String pTableName ) throws Exception
    {
        Connection        conn       = null;
        PreparedStatement pStmt      = null;
        ResultSet         rs         = null;
        boolean           doesExist  = false;

        LOG.debug ( "The existence of the table '" + pTableOwner + "." + pTableName + "' will be confirmed" );

        try
        {
            conn = databaseConnector.getConnection ();

            LOG.debug ( "A connection to the database was successfully retrieved" );

            pStmt = conn.prepareStatement ( " select count ( * ) cnt from dbc.tablesv where trim ( lower ( databasename ) ) = trim ( lower ( ? ) ) and trim ( lower ( tablename ) ) = trim ( lower ( ? ) ) " );

            LOG.debug ( "The DML used to check whether the table exists has been successfully prepared" );

            pStmt.setString ( 1 , pTableOwner );

            LOG.debug ( "The table owner '" + pTableOwner + "' has been bound" );

            pStmt.setString ( 2 , pTableName );

            LOG.debug ( "The table name '" + pTableName + "' has been bound" );

            rs = pStmt.executeQuery ();

            LOG.debug ( "The query has been successfully executed" );

            rs.next ();

            if ( rs.getDouble ( "cnt" ) == 1 )
            {
                LOG.debug ( "The table has been found to exist" );

                doesExist = true;
            }
        }
        catch ( SQLException sqle )
        {
            LOG.fatal ( "SQL Exception: " + sqle );

            throw sqle;
        }
        finally
        {
            rs.close    ();

            pStmt.close ();

            conn.close  ();
        }

        LOG.debug ( "The database table '" + pTableOwner + "." + pTableName + "' does" + ( doesExist ? "" : " not" ) + " exist" );

        return doesExist;
    }
    
    public boolean checkIfExists ( final ITablename pTable ) throws Exception
    {
    	return checkIfExists(pTable.getTableOwner(), pTable.getTableName());
    }

    public void copyTable ( final String pSourceTableOwner , final String pSourceTableName , final String pTargetTableOwner , final String pTargetTableName , final boolean pIncludeData ) throws Exception
    {
        Connection        conn    = null;
        PreparedStatement pStmt   = null;

        final String DDL = "create table " + pTargetTableOwner + "." + pTargetTableName + " as ( select a.* from ( select b.* from " + pSourceTableOwner + "." + pSourceTableName + " b ) a ) " + ( pIncludeData ? " with data " : " with no data " );

        LOG.debug ( "The database table '" + pSourceTableOwner + "." + pSourceTableName + "' will be copied to '" + pTargetTableOwner + "." + pTargetTableName + "' using the DDL '" + DDL + "'" );

        try
        {
            conn = databaseConnector.getConnection ();

            LOG.debug ( "A connection to the database was successfully retrieved" );

            pStmt = conn.prepareStatement ( DDL );

            LOG.debug ( "The DDL statement was successfully prepared" );

            pStmt.executeUpdate ();

            LOG.debug ( "The DDL statement was executed successfully" );

            conn.commit ();

            LOG.debug ( "The changes were committed to the database" );
        }
        catch ( SQLException sqle )
        {
            LOG.fatal ( "SQL Exception: " + sqle );

            throw sqle;
        }
        finally
        {
            pStmt.close ();

            conn.close  ();
        }

        LOG.debug ( "The database table '" + pSourceTableOwner + "." + pSourceTableName + "' has been successfully copied to '" + pTargetTableOwner + "." + pTargetTableName + "'" );
    }
    
    public void copyTable ( final ITablename pSourceTable , final ITablename pTargetTable , final boolean pIncludeData ) throws Exception
    {
    	copyTable (pSourceTable.getTableOwner(), pSourceTable.getTableName(), pTargetTable.getTableOwner(), pTargetTable.getTableName(), pIncludeData);
    }

    public void dropIfExists  ( final String pTableOwner , final String pTableName ) throws Exception
    {
              Connection        conn       = null;
              PreparedStatement pStmt      = null;
        final String            DROPDDL    = "drop table " + pTableOwner + "." + pTableName;

        LOG.debug ( "The database table '" + pTableOwner + "." + pTableName + "' will be dropped using the following DDL '" + DROPDDL + "'" );

        if ( checkIfExists ( pTableOwner , pTableName ) )
        {
            try
            {
                conn = databaseConnector.getConnection ();

                LOG.debug ( "A connection to the database was successfully retrieved" );

                pStmt = conn.prepareStatement ( DROPDDL );

                LOG.debug ( "The DDL to be used to drop the table has been successfully prepared" );

                pStmt.executeUpdate ();

                LOG.debug ( "The database table '" + pTableOwner + "." + pTableName + "' has been successfully dropped" );

                conn.commit ();
            }
            catch ( SQLException sqle )
            {
                LOG.fatal ( "SQL Exception: " + sqle );

                throw sqle;
            }
            finally
            {
                pStmt.close ();

                conn.close  ();
            }
        }
    }
    
    public void dropIfExists  ( final ITablename pTable ) throws Exception
    {
        dropIfExists(pTable.getTableOwner(), pTable.getTableName());
    }
}
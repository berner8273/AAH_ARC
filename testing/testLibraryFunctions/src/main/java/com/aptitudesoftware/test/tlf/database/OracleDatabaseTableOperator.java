package com.aptitudesoftware.test.tlf.database;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.apache.log4j.Logger;

public class OracleDatabaseTableOperator implements IDatabaseTableOperator
{
    private static final Logger LOG = Logger.getLogger ( OracleDatabaseTableOperator.class );

    private IDatabaseConnector databaseConnector;

    public OracleDatabaseTableOperator ( final IDatabaseConnector pDatabaseConnector )
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

            pStmt = conn.prepareStatement ( " select count ( * ) cnt from all_tables where trim ( lower ( owner ) ) = trim ( lower ( ? ) ) and trim ( lower ( table_name ) ) = trim ( lower ( ? ) ) " );

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
        catch ( Exception e )
        {
            LOG.debug ( "Exception: " + e );
        }
        finally
        {
            if (rs != null) {
            	rs.close    ();
            	pStmt.close ();
            	conn.close  ();
            }
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
        CallableStatement cStmt   = null;

        final String DDL =   "declare\n"
                           + "    v_target_table_name  varchar2 ( 500  char ) := sys.dbms_assert.qualified_sql_name ( upper ( ? ) || '.' || upper ( ? ) );\n"
                           + "    v_source_table_name  varchar2 ( 500  char ) := sys.dbms_assert.sql_object_name    ( upper ( ? ) || '.' || upper ( ? ) );\n"
                           + "    v_ddl                varchar2 ( 2000 char ) := 'create table ' || v_target_table_name || ' as select * from ' || v_source_table_name || " + ( pIncludeData ? "''" : "' where 1 = 2' " ) + ";\n"
                           + "begin\n"
                           + "    execute immediate v_ddl;\n"
                           + "end;";

        LOG.debug ( "The database table '" + pSourceTableOwner + "." + pSourceTableName + "' will be copied to '" + pTargetTableOwner + "." + pTargetTableName + "' using the DDL '\n" + DDL + "'" );

        try
        {
            conn = databaseConnector.getConnection ();

            LOG.debug ( "A connection to the database was successfully retrieved" );

            cStmt = conn.prepareCall ( DDL );

            LOG.debug ( "The DDL statement was successfully prepared" );

            cStmt.setString ( 1 , pTargetTableOwner );
            
            LOG.debug ( "'" + pTargetTableOwner + "' was bound to parameter 1" );

            cStmt.setString ( 2 , pTargetTableName );

            LOG.debug ( "'" + pTargetTableName + "' was bound to parameter 2" );
            
            cStmt.setString ( 3 , pSourceTableOwner );

            LOG.debug ( "'" + pSourceTableOwner + "' was bound to parameter 3" );
            
            cStmt.setString ( 4 , pSourceTableName );

            LOG.debug ( "'" + pSourceTableName + "' was bound to parameter 4" );
            
            cStmt.execute ();

            LOG.debug ( "The DDL statement was executed successfully" );
        }
        catch ( SQLException sqle )
        {
            LOG.fatal ( "SQL Exception: " + sqle );

            throw sqle;
        }
        finally
        {
            cStmt.close ();

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
              Connection        conn   = null;
              CallableStatement cStmt  = null;
        final String            DDL    =   "declare\n"
                                         + "    v_table_name varchar2 ( 500 char ) := sys.dbms_assert.qualified_sql_name ( sys.dbms_assert.schema_name ( upper ( ? ) ) || '.' || upper ( ? ) );\n"
                                         + "begin\n"
                                         + "    execute immediate 'drop table ' || v_table_name;\n"
                                         + "end;\n";

        LOG.debug ( "The database table '" + pTableOwner + "." + pTableName + "' will be dropped using the following DDL '" + DDL + "'" );

        if ( checkIfExists ( pTableOwner , pTableName ) )
        {
            try
            {
                conn = databaseConnector.getConnection ();

                LOG.debug ( "A connection to the database was successfully retrieved" );

                cStmt = conn.prepareCall ( DDL );

                LOG.debug ( "The DDL to be used to drop the table has been successfully prepared" );

                cStmt.setString ( 1 , pTableOwner );

                cStmt.setString ( 2 , pTableName );

                cStmt.execute ();

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
                cStmt.close ();

                conn.close  ();
            }
        }
    }
    
    public void dropIfExists  ( final ITablename pTable ) throws Exception
    {
        dropIfExists(pTable.getTableOwner(), pTable.getTableName());
    }
}

package com.aptitudesoftware.test.tlf.database;

import com.aptitudesoftware.test.tlf.string.ITokenReplacement;

import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;

public class OracleDataComparisonOperator implements IDataComparisonOperator
{
    private static final Logger LOG = Logger.getLogger ( OracleDataComparisonOperator.class );

    private IDatabaseConnector databaseConnector;

    public OracleDataComparisonOperator ( final IDatabaseConnector pDatabaseConnector )
    {
        databaseConnector = pDatabaseConnector;
    }

    private void logResultSet ( final Level pLogLevel , final String pSql , final String [] pBindArray ) throws Exception
    {
        LOG.debug ( "Adding the result-set output by the query '" + pSql + "' to the log" );

        Connection        conn  = null;
        PreparedStatement pStmt = null;
        ResultSet         rs    = null;
        ResultSetMetaData rsmd  = null;

        try
        {
            conn  = databaseConnector.getConnection ();

            LOG.debug ( "A connection to the database was successfully retrieved" );

            pStmt = conn.prepareStatement ( pSql );

            LOG.debug ( "The DML statement was successfully prepared" );

            for ( int i = 0 ; i < pBindArray.length ; i++ )
            {
                String val = pBindArray [ i ];

                int    pos = i + 1;

                LOG.debug ( "The value '" + val + "' is to be bound to the position '" + pos + "' in the DML statement" );

                pStmt.setString ( pos , val );

                LOG.debug ( "The value was bound successfully" );
            }

            rs = pStmt.executeQuery ();

            LOG.debug ( "The result set was " + ( rs == null ? "NOT " : "" ) + "successfully retrieved" );

            rsmd = rs.getMetaData ();

            LOG.debug ( "Result set meta data " + ( rsmd == null ? "NOT " : "" ) +"successfully retrieved" );

            StringBuffer rsString = new StringBuffer ();

            rsString.append ( "\n" );

            LOG.debug ( "Newline character appended to the result set string" );

            LOG.debug ( "About to build the result set header" );

            for ( int i = 1 ; i <= rsmd.getColumnCount () ; i++ )
            {
                rsString.append ( String.format ( "%1$-" + rsmd.getColumnDisplaySize ( i ) + "s" , rsmd.getColumnLabel ( i ).trim () ) )
                        .append ( "|" );
            }

            LOG.debug ( "Result set header built successfully" );

            rsString.append ( "\n" );

            LOG.debug ( "Newline character appended to the result set header" );

            int rowCnt = 0;

            while ( rs.next () )
            {
                for ( int i = 1 ; i <= rsmd.getColumnCount () ; i++ )
                {
                    final int COL_LABEL_SIZE = rsmd.getColumnLabel ( i ).trim ().length ();

                    LOG.debug ( "COL_LABEL_SIZE = " + COL_LABEL_SIZE );

                    final int COL_DISPLAY_SIZE = rsmd.getColumnDisplaySize ( i );

                    LOG.debug ( "COL_DISPLAY_SIZE = " + COL_DISPLAY_SIZE );

                    final int COL_SIZE = ( COL_LABEL_SIZE > COL_DISPLAY_SIZE ? COL_LABEL_SIZE : COL_DISPLAY_SIZE );

                    LOG.debug ( "COL_SIZE = " + COL_SIZE );

                    String COL_VALUE = rs.getString ( i );

                    COL_VALUE = ( COL_VALUE == null ? "" : COL_VALUE.trim () );

                    LOG.debug ( "COL_VALUE = " + COL_VALUE );

                    rsString.append ( String.format ( "%1$-" + COL_SIZE + "s" , COL_VALUE ) )
                            .append ( "|" );

                    LOG.debug ( "Value appended to the result set string" );
                }

                rsString.append ( "\n" );

                LOG.debug ( "Newline character appended to the result set string" );
                
                rowCnt ++;
            
                if ( rowCnt > 100 )
                {
                    LOG.debug ( "100 records have been output in the result set - more aren't useful" );

                    break;
                }
            }

            LOG.log ( pLogLevel , rsString.toString() );
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
    }

    private int getMinusQueryCountResults  ( final Path pPathToQuery1 , final Path pPathToQuery2 , final String [] pBindArray , final ITokenReplacement pITokenReplacement ) throws Exception
    {
        LOG.debug ( "The SQL contained within '" + pPathToQuery1 + "' and '" + pPathToQuery2 + "' will be 'minused' and the number of records returned" );

        if ( ! Files.exists ( pPathToQuery1 ) )
        {
             LOG.fatal ( "The file '" + pPathToQuery1 + "' does not exist" );

             assert ( false );
        }

        if ( ! Files.exists ( pPathToQuery2 ) )
        {
             LOG.fatal ( "The file '" + pPathToQuery2 + "' does not exist" );

             assert ( false );
        }

        int cnt = 0;

        byte[] encodedQuery1 = Files.readAllBytes ( pPathToQuery1 );
        byte[] encodedQuery2 = Files.readAllBytes ( pPathToQuery2 );

        String query1 = new String ( encodedQuery1 , Charset.forName ( "UTF-8" ) );
        String query2 = new String ( encodedQuery2 , Charset.forName ( "UTF-8" ) );

        String minusSql      = pITokenReplacement.replaceTokensInString ( query1 + " \nminus\n " + query2 );
        String comparisonSql = " select count ( * ) cnt from ( " + minusSql + " ) a ";

        LOG.debug ( "The query '" + comparisonSql + "' will be executed" );

        Connection        conn    = null;
        PreparedStatement pStmt   = null;
        ResultSet         rs      = null;

        try
        {
            conn  = databaseConnector.getConnection ();

            LOG.debug ( "A connection to the database was successfully retrieved" );

            pStmt = conn.prepareStatement ( comparisonSql );

            LOG.debug ( "The DML statement was successfully prepared" );

            for ( int i = 0 ; i < pBindArray.length ; i++ )
            {
                String val = pBindArray [ i ];

                int    pos = i + 1;

                LOG.debug ( "The value '" + val + "' is to be bound to the position '" + pos + "' in the DML statement" );

                pStmt.setString ( pos , val );

                LOG.debug ( "The value was bound successfully" );
            }

            rs = pStmt.executeQuery ();

            LOG.debug ( "The DML statement was executed successfully" );

            rs.next ();

            cnt = rs.getInt ( "cnt" );

            LOG.debug ( "The count is '" + cnt + "'" );
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

        LOG.debug ( "The number of records found by the 'minus' SQL was '" + cnt + "'" );

        if ( cnt > 0 )
        {
            LOG.error ( "The records found by executing the SQL '" + minusSql + "' are : " );

            logResultSet ( Level.ERROR , minusSql , pBindArray );
        }

        return cnt;
    }

    private int getMinusQueryCountResultsNoLog  ( final Path pPathToQuery1 , final Path pPathToQuery2 , final String [] pBindArray , final ITokenReplacement pITokenReplacement ) throws Exception
    {
        LOG.debug ( "The SQL contained within '" + pPathToQuery1 + "' and '" + pPathToQuery2 + "' will be 'minused' and the number of records returned" );

        if ( ! Files.exists ( pPathToQuery1 ) )
        {
             LOG.fatal ( "The file '" + pPathToQuery1 + "' does not exist" );

             assert ( false );
        }

        if ( ! Files.exists ( pPathToQuery2 ) )
        {
             LOG.fatal ( "The file '" + pPathToQuery2 + "' does not exist" );

             assert ( false );
        }

        int cnt = 0;

        byte[] encodedQuery1 = Files.readAllBytes ( pPathToQuery1 );
        byte[] encodedQuery2 = Files.readAllBytes ( pPathToQuery2 );

        String query1 = new String ( encodedQuery1 , Charset.forName ( "UTF-8" ) );
        String query2 = new String ( encodedQuery2 , Charset.forName ( "UTF-8" ) );

        String minusSql      = pITokenReplacement.replaceTokensInString ( query1 + " \nminus\n " + query2 );
        String comparisonSql = " select count ( * ) cnt from ( " + minusSql + " ) a ";

        LOG.debug ( "The query '" + comparisonSql + "' will be executed" );

        Connection        conn    = null;
        PreparedStatement pStmt   = null;
        ResultSet         rs      = null;

        try
        {
            conn  = databaseConnector.getConnection ();

            LOG.debug ( "A connection to the database was successfully retrieved" );

            pStmt = conn.prepareStatement ( comparisonSql );

            LOG.debug ( "The DML statement was successfully prepared" );

            for ( int i = 0 ; i < pBindArray.length ; i++ )
            {
                String val = pBindArray [ i ];

                int    pos = i + 1;

                LOG.debug ( "The value '" + val + "' is to be bound to the position '" + pos + "' in the DML statement" );

                pStmt.setString ( pos , val );

                LOG.debug ( "The value was bound successfully" );
            }

            rs = pStmt.executeQuery ();

            LOG.debug ( "The DML statement was executed successfully" );

            rs.next ();

            cnt = rs.getInt ( "cnt" );

            LOG.debug ( "The count is '" + cnt + "'" );
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

        LOG.debug ( "The number of records found by the 'minus' SQL was '" + cnt + "'" );

        return cnt;
    }
        
    public int countMinusQueryResults ( final Path pPathToQuery1 , final Path pPathToQuery2 , final String [] pBindArray , final ITokenReplacement pITokenReplacement ) throws Exception
    {
        return getMinusQueryCountResults
               (
                   pPathToQuery1
               ,   pPathToQuery2
               ,   pBindArray
               ,   pITokenReplacement
               )
               +
               getMinusQueryCountResults
               (
                   pPathToQuery2
               ,   pPathToQuery1
               ,   pBindArray
               ,   pITokenReplacement
               );
    }
    
    public int countMinusQueryResultsNoLog ( final Path pPathToQuery1 , final Path pPathToQuery2 , final String [] pBindArray , final ITokenReplacement pITokenReplacement ) throws Exception
    {
        return getMinusQueryCountResultsNoLog
               (
                   pPathToQuery1
               ,   pPathToQuery2
               ,   pBindArray
               ,   pITokenReplacement
               )
               +
               getMinusQueryCountResultsNoLog
               (
                   pPathToQuery2
               ,   pPathToQuery1
               ,   pBindArray
               ,   pITokenReplacement
               );
    }
}
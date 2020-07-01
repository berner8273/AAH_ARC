package com.aptitudesoftware.test.tlf.excel;

import com.aptitudesoftware.test.tlf.database.IDatabaseConnector;
import com.aptitudesoftware.test.tlf.string.ITokenReplacement;

import java.nio.file.Path;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;
import java.util.TreeMap;
import java.util.SortedMap;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFRow;

import org.apache.log4j.Logger;

public class TeradataExcelOperator implements IExcelOperator
{
    private static final Logger LOG = Logger.getLogger ( TeradataExcelOperator.class );

    private IDatabaseConnector databaseConnector;

	private XSSFWorkbook XL;
	
	private DataFormatter fmt = new DataFormatter();

    private SortedMap<Integer,ExcelColumnDetails> getExcelColumnDetails ( final XSSFSheet pExcelWorksheetSheet )
    {
        final SortedMap<Integer,ExcelColumnDetails> XLCOLDTLS = new TreeMap<Integer,ExcelColumnDetails> ();

        for ( Cell stCell : pExcelWorksheetSheet.getRow ( 0 ) )
        {
            ExcelColumnDetails colDtls = new ExcelColumnDetails ();

            colDtls.colName = stCell.getStringCellValue ().trim ().toLowerCase ();

            colDtls.colIndex    = stCell.getColumnIndex ();

            LOG.debug ( "The column '" + colDtls.colName + "' was found at index location '" + colDtls.colIndex + "'" );

            colDtls.isDate      = pExcelWorksheetSheet .getRow ( 1 ).getCell ( colDtls.colIndex ).getStringCellValue ().trim ().toLowerCase ().equals     ( "date" );

            LOG.debug ( "The column '" + colDtls.colName + "' is " + ( colDtls.isDate ? "" : "not " ) + "a date" );

            colDtls.isTimestamp = pExcelWorksheetSheet .getRow ( 1 ).getCell ( colDtls.colIndex ).getStringCellValue ().trim ().toLowerCase ().startsWith ( "timestamp" );

            LOG.debug ( "The column '" + colDtls.colName + "' is " + ( colDtls.isTimestamp ? "" : "not " ) + "a timestamp" );

            colDtls.isNumber    =    pExcelWorksheetSheet .getRow ( 1 ).getCell ( colDtls.colIndex ).getStringCellValue ().trim ().toLowerCase ().startsWith ( "decimal" )
                                  || pExcelWorksheetSheet .getRow ( 1 ).getCell ( colDtls.colIndex ).getStringCellValue ().trim ().toLowerCase ().startsWith ( "number"  );

            LOG.debug ( "The column '" + colDtls.colName + "' is " + ( colDtls.isNumber ? "" : "not " ) + "a number" );

            colDtls.isInteger   = pExcelWorksheetSheet .getRow ( 1 ).getCell ( colDtls.colIndex ).getStringCellValue ().trim ().toLowerCase ().equals ( "integer" );

            LOG.debug ( "The column '" + colDtls.colName + "' is " + ( colDtls.isInteger ? "" : "not " ) + "an integer" );

            String isSqlInd     = pExcelWorksheetSheet .getRow ( 2 ).getCell ( colDtls.colIndex ).getStringCellValue ().trim ();

            if ( ! ( isSqlInd.equals ( "Y" ) || isSqlInd.equals ( "N" ) ) )
            {
                LOG.debug ( "The 'IS SQL? INDICATOR' must have a value of 'Y' or 'N' - it has a value of '" + isSqlInd + "' for column '" + colDtls.colName + "'" );

                assert ( false );
            }

            colDtls.isSQL = isSqlInd.equals ( "Y" );

            LOG.debug ( "The column '" + colDtls.colName + "' is " + ( colDtls.isSQL ? "" : "not " ) + "SQL" );

            XLCOLDTLS.put ( new Integer ( colDtls.colIndex ) , colDtls );
        }

        return XLCOLDTLS;
    }

    private boolean hasSQL ( final SortedMap<Integer,ExcelColumnDetails> pExcelFormat )
    {
        boolean hasSQL = false;

        for ( SortedMap.Entry<Integer,ExcelColumnDetails> xlCol : pExcelFormat.entrySet () )
        {
            LOG.debug ( "Check to see whether the following column contains SQL : " + xlCol.getValue ().colName );

            if ( xlCol.getValue ().isSQL )
            {
                hasSQL = true;

                LOG.debug ( "The following column has SQL : " + xlCol.getValue ().colName );

                break;
            }
        }

        return hasSQL;
    }

    private String getInsertStatement ( final String pTableOwner , final String pTableName , final SortedMap<Integer,ExcelColumnDetails> pExcelFormat )
    {
        String ddl    = "";

        String colddl = "";

        String valddl = "";

        if ( hasSQL ( pExcelFormat ) )
        {
            for ( SortedMap.Entry<Integer,ExcelColumnDetails> xlCol : pExcelFormat.entrySet () )
            {
                ExcelColumnDetails colDtls = xlCol.getValue ();

                colddl = colddl + ", " + colDtls.colName;

                if ( colDtls.isSQL )
                {
                    valddl = valddl + ", (<" + colDtls.colIndex + ">)";
                }
                else
                {
                    valddl = valddl + ", ? ";
                }

                ddl = "insert into " + pTableOwner + "." + pTableName + " ( " + colddl.replaceAll ( "^,+" , "" ) + " ) values ( " + valddl.replaceAll ( "^,+" , "" ) + " ) ";
            }
        }
        else
        {
            for ( SortedMap.Entry<Integer,ExcelColumnDetails> xlCol : pExcelFormat.entrySet () )
            {
                ExcelColumnDetails colDtls = xlCol.getValue ();

                colddl = colddl + ", " + colDtls.colName;

                valddl = valddl + ", ? ";

                ddl    = "insert into " + pTableOwner + "." + pTableName + " ( " + colddl.replaceAll ( "^,+" , "" ) + " ) values ( " + valddl.replaceAll ( "^,+" , "" ) + " ) ";
            }
        }

        return ddl;
    }

    private String getCreateTableStatement ( final String pTableOwner , final Path pPathToExcelFile , final String pExcelTabName ) throws Exception
    {
        LOG.debug ( "DDL to create the table '" + pTableOwner + "." + pExcelTabName + "' will be formulated, based on the excel file at '" + pPathToExcelFile + "'" );

        XL = new XSSFWorkbook ( pPathToExcelFile.toFile () );

        LOG.debug ( "A reference to the excel file was retrieved" );

        final XSSFSheet ST  = XL.getSheet ( pExcelTabName );

        if ( ST == null )
        {
            LOG.fatal ( "The tab '" + pExcelTabName + "' within the excel file at '" + pPathToExcelFile + "' does not exist" );

            assert ( false );
        }

        final XSSFRow CN = ST.getRow        ( 0 );

        LOG.debug ( "A reference to row '0' in the excel tab '" + pExcelTabName + "' was retrieved" );

        final XSSFRow DT = ST.getRow        ( 1 );

        LOG.debug ( "A reference to row '1' in the excel tab '" + pExcelTabName + "' was retrieved" );

        String ddl = "";

        for ( Cell cnCell : CN )
        {
            ddl = ddl + ", " + cnCell.getStringCellValue ().trim () + " " + DT.getCell ( cnCell.getColumnIndex() ).getStringCellValue ().trim () + " ";
        }

        ddl = "create table " + pTableOwner + "." + pExcelTabName + " ( " + ddl.replaceAll ( "^,+" , "" ) + " ) ";

        LOG.debug ( "The DDL '" + ddl + "' has been generated from the excel" );

        return ddl;
    }

    private void bindCellValueToSQL ( final PreparedStatement pStmt , final Cell pCell , final ExcelColumnDetails pColumnDetails , final int pNumSQLColumns) throws Exception
    {
        final int PARAMETER_INDEX = pColumnDetails.colIndex + 1 - pNumSQLColumns;

        LOG.debug ( "Cell " + pColumnDetails.colIndex + " will be bound to parameter index " + PARAMETER_INDEX );

        if ( pCell == null || pCell.getCellType () == Cell.CELL_TYPE_BLANK )
        {
            LOG.debug ( "Cell '" + pColumnDetails.colIndex + "' will be treated as being blank / null" );

            if ( pColumnDetails.isDate )
            {
                LOG.debug ( "Cell '" + pColumnDetails.colIndex + "': binding null date to DDL" );

                pStmt.setNull ( PARAMETER_INDEX , Types.DATE );
            }
            else if ( pColumnDetails.isTimestamp )
            {
                LOG.debug ( "Cell '" + pColumnDetails.colIndex + "': binding null timestamp to DDL" );

                pStmt.setNull ( PARAMETER_INDEX , Types.TIMESTAMP );
            }
            else if ( pColumnDetails.isNumber )
            {
                LOG.debug ( "Cell '" + pColumnDetails.colIndex + "': binding null number to DDL" );

                pStmt.setNull ( PARAMETER_INDEX , Types.DOUBLE );
            }
            else if ( pColumnDetails.isInteger )
            {
                LOG.debug ( "Cell '" + pColumnDetails.colIndex + "': binding null integer to DDL" );

                pStmt.setNull ( PARAMETER_INDEX , Types.INTEGER );
            }
            else
            {
                LOG.debug ( "Cell '" + pColumnDetails.colIndex + "': binding null string to DDL" );

                pStmt.setNull ( PARAMETER_INDEX , Types.VARCHAR );
            }
        }
        else
        {
            if ( pColumnDetails.isDate )
            {
                LOG.debug ( "Cell '" + pColumnDetails.colIndex + "': binding date to DDL" );

                pStmt.setDate ( PARAMETER_INDEX , new java.sql.Date ( pCell.getDateCellValue ().getTime () ) );

                LOG.debug ( "Date bound to SQL" );
            }
            else if ( pColumnDetails.isTimestamp )
            {
                LOG.debug ( "Cell '" + pColumnDetails.colIndex + "': binding timestamp to DDL" );

                pStmt.setTimestamp ( PARAMETER_INDEX , new java.sql.Timestamp ( pCell.getDateCellValue ().getTime () ) );

                LOG.debug ( "Timestamp bound to SQL" );
            }
            else if ( pColumnDetails.isNumber )
            {
                LOG.debug ( "Cell '" + pColumnDetails.colIndex + "': binding number to DDL" );

                pStmt.setDouble ( PARAMETER_INDEX , Double.parseDouble(fmt.formatCellValue(pCell) ) );

                LOG.debug ( "Number bound to SQL" );
            }
            else if ( pColumnDetails.isInteger )
            {
                LOG.debug ( "Cell '" + pColumnDetails.colIndex + "': binding integer to DDL" );

                pStmt.setInt ( PARAMETER_INDEX , ( int ) ( Double.parseDouble(fmt.formatCellValue(pCell) ) ) );

                LOG.debug ( "Integer bound to SQL" );
            }
            else
            {
                if ( pCell.getCellType () == Cell.CELL_TYPE_NUMERIC )
                {
                    LOG.debug ( "Cell '" + pColumnDetails.colIndex + "': binding number stored as a string to DDL" );

                    pStmt.setString ( PARAMETER_INDEX , fmt.formatCellValue(pCell) );

                    LOG.debug ( "Number stored as string bound to SQL" );
                }
                else
                {
                    LOG.debug ( "Cell '" + pColumnDetails.colIndex + "': binding string to DDL" );

                    pStmt.setString ( PARAMETER_INDEX , fmt.formatCellValue(pCell) );

                    LOG.debug ( "String bound to SQL" );
                }
            }
        }
    }

    public TeradataExcelOperator ( final IDatabaseConnector pIDatabaseConnector )
    {
        databaseConnector = pIDatabaseConnector;
    }

    public void createDatabaseTableFromExcelTab ( final String pTableOwner , final Path pPathToExcelFile , final String pExcelTabName ) throws Exception
    {
        LOG.debug ( "The table '" + pTableOwner + "." + pExcelTabName + "' will be created, based on the excel file at '" + pPathToExcelFile + "'" );

        String            ddl   = getCreateTableStatement ( pTableOwner , pPathToExcelFile , pExcelTabName );
        Connection        conn  = null;
        PreparedStatement pStmt = null;

        try
        {
            conn = databaseConnector.getConnection ();

            LOG.debug ( "A connection to the database was successfully retrieved" );

            pStmt = conn.prepareStatement ( ddl );

            LOG.debug ( "The DDL statement was successfully prepared" );

            pStmt.executeUpdate ();

            LOG.debug ( "The DDL statement was successfully executed" );

            conn.commit ();
        }
        catch ( SQLException sqle )
        {
            LOG.fatal ( "SQL Exception: " + sqle );

            SQLException childsqle = sqle.getNextException();

            while (childsqle != null)
            {
                LOG.fatal ( "SQL Exception detail: " + childsqle);
                childsqle = childsqle.getNextException();
            }

            throw sqle;
        }
        finally
        {
            LOG.debug ( "Closing 'pStmt'" );

            pStmt.close ();

            LOG.debug ( "Closed 'pStmt'" );

            LOG.debug ( "Closing 'conn'" );

            conn.close ();

            LOG.debug ( "Closed 'conn'" );

            LOG.debug ( "Closing 'XL'" );

            LOG.debug ( "Closed 'XL'" );
        }

        LOG.debug ( "The table '" + pTableOwner + "." + pExcelTabName + "' has been created successfully using the DDL '" + ddl + "'" );
    }

    public void loadExcelTabToDatabaseTable ( final String pTableOwner , final Path pPathToExcelFile , final String pExcelTabName , final ITokenReplacement pITokenReplacement ) throws Exception
    {
        LOG.debug ( "Data will be loaded into the table '" + pTableOwner + "." + pExcelTabName + "', based on the excel file at '" + pPathToExcelFile + "'" );

        XL = new XSSFWorkbook ( pPathToExcelFile.toFile () );

        LOG.debug ( "A reference to the excel file was retrieved" );

        final XSSFSheet ST = XL.getSheet ( pExcelTabName );

        if ( ST == null )
        {
            LOG.fatal ( "The tab '" + pExcelTabName + "' within the excel file at '" + pPathToExcelFile + "' does not exist" );

            assert ( false );
        }

        final int SPREADSHEET_WIDTH = ST.getRow ( 0 ).getPhysicalNumberOfCells ();

        LOG.debug ( "The width of the spreadsheet's tab was calculated to be '" + SPREADSHEET_WIDTH + "' cells" );

        final SortedMap<Integer,ExcelColumnDetails> XLCOLDTLS = getExcelColumnDetails ( ST );

              Connection        conn    = null;
              PreparedStatement pStmt   = null;

        String  ddl            = "";
        boolean ddlContainsSQL = hasSQL ( XLCOLDTLS );

        LOG.debug ( "Build an insert statement to target '" + pTableOwner + "." + pExcelTabName + "'" );

        ddl = getInsertStatement ( pTableOwner , pExcelTabName , XLCOLDTLS );

        LOG.debug ( "The template of the SQL which will be used to load data is '" + ddl + "'" );

        try
        {
            conn = databaseConnector.getConnection ();

            if ( ddlContainsSQL )
            {
                LOG.debug ( "The insert statement contains both values AND sql." );

                LOG.debug ( "Connection is null? '" + ( conn == null ) + "'" );

                int numRecordsInserted = 0;

                for ( Row stRow : ST )
                {
                    String thisDDL = ddl;

                    if ( stRow.getRowNum () >= 3 )
                    {
                        /*prepare SQL statement by modifying it with SQL taken from the spreadsheet*/

                        for ( int i = 0 ; i < SPREADSHEET_WIDTH ; i++ )
                        {
                            ExcelColumnDetails currColDtls = XLCOLDTLS.get ( new Integer ( i ) );

                            LOG.debug ( "Examining column '" + currColDtls.colName + "'" );

                            Cell currCell = stRow.getCell ( i );

                            LOG.debug ( "Examining cell '" + i + "' - value - '" + fmt.formatCellValue(currCell) + "'" );

                            if ( currColDtls.isSQL )
                            {
                                LOG.debug ( "Replace '<" + currColDtls.colIndex + ">' with '" + currCell.getStringCellValue () + "'" );

                                thisDDL = thisDDL.replaceAll ( "<" + currColDtls.colIndex + ">" , currCell.getStringCellValue () );
                            }
                        }

                        thisDDL = pITokenReplacement.replaceTokensInString ( thisDDL );

                        LOG.debug ( "Preparing the statement '" + thisDDL + "'" );

                        pStmt = conn.prepareStatement ( thisDDL );

                        /*bind values to SQL statement*/

                        int numSQLColumnsExamined = 0;

                        for ( int i = 0 ; i < SPREADSHEET_WIDTH ; i++ )
                        {
                            ExcelColumnDetails currColDtls = XLCOLDTLS.get ( new Integer ( i ) );

                            if ( currColDtls.isSQL )
                            {
                                numSQLColumnsExamined++;
                            }
                            else
                            {
                                bindCellValueToSQL ( pStmt , stRow.getCell ( i ) , currColDtls , numSQLColumnsExamined );
                            }
                        }

                        LOG.debug ( "Executing DDL '" + thisDDL + "'" );

                        pStmt.executeUpdate ();

                        LOG.debug ( "DDL executed successfully" );

                        numRecordsInserted++;
                    }
                }

                conn.commit ();

                LOG.debug ( numRecordsInserted + " records were committed to the database table '" + pTableOwner + "." + pExcelTabName + "'" );
            }
            else
            {
                LOG.debug ( "The insert statement contains only values" );

                LOG.debug ( "Prepare the statement '" + pITokenReplacement.replaceTokensInString ( ddl ) + "'" );

                LOG.debug ( "Connection is null? '" + ( conn == null ) + "'" );

                int numRecordsToInsert = 0;

                pStmt = conn.prepareStatement ( pITokenReplacement.replaceTokensInString ( ddl ) );

                LOG.debug ( "The SQL '" + ddl + "' was successfully prepared" );

                for ( Row stRow : ST )
                {
                    LOG.debug ( "Loading excel row # '" + stRow.getRowNum () + "'" );

                    if ( stRow.getRowNum () >= 3 )
                    {
                        for ( int i = 0 ; i < SPREADSHEET_WIDTH ; i++ )
                        {
                            ExcelColumnDetails currColDtls = XLCOLDTLS.get ( new Integer ( i ) );

                            LOG.debug ( "Examining column '" + currColDtls.colName + "'" );

                            Cell currCell = stRow.getCell ( i );

                            LOG.debug ( "Examining cell '" + i + "' - value - '" + fmt.formatCellValue(currCell) + "'" );

                            bindCellValueToSQL ( pStmt , currCell , currColDtls , 0 );
                        }

                        LOG.debug ( "Adding insert statement to the batch of insert statements" );

                        pStmt.addBatch ();

                        numRecordsToInsert++;
                    }
                }

                if ( numRecordsToInsert > 0 )
                {
                    LOG.debug ( "Executing batch" );

                    int [] batchCount = pStmt.executeBatch ();

                    if ( batchCount == null )
                    {
                        throw new Exception ( "No records were inserted" );
                    }
                    else if ( batchCount.length != numRecordsToInsert )
                    {
                        LOG.debug ( "The batch insert created '" + batchCount.length + "' records. '" + numRecordsToInsert + "' was expected." );

                        conn.rollback ();

                        throw new Exception ( "The batch insert created '" + batchCount.length + "' records. '" + numRecordsToInsert + "' was expected." );
                    }
                    else
                    {
                        conn.commit ();

                        LOG.debug ( "'" + numRecordsToInsert + "' records were successfully loaded into the database table '" + pTableOwner + "." + pExcelTabName + "'" );
                    }
                }
            }
        }
        catch ( SQLException sqle )
        {
            LOG.fatal ( "SQL Exception: " + sqle );

            sqle.printStackTrace();

            SQLException childsqle = sqle.getNextException ();

            while ( childsqle != null )
            {
                LOG.fatal ( "SQL Exception detail: " + childsqle );

                childsqle = childsqle.getNextException ();
            }

            throw sqle;
        }
        finally
        {
            LOG.debug ( "Closing 'pStmt'" );

            pStmt.close ();

            LOG.debug ( "Closed 'pStmt'" );

            LOG.debug ( "Closing 'conn'" );

            conn.close ();

            LOG.debug ( "Closed 'conn'" );

            LOG.debug ( "Closing 'XL'" );

            LOG.debug ( "Closed 'XL'" );
        }
    }
}
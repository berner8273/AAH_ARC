package com.aptitudesoftware.test.aah;

import com.aptitudesoftware.test.tlf.database.IDataComparisonOperator;
import com.aptitudesoftware.test.tlf.database.IDatabaseConnector;
import com.aptitudesoftware.test.tlf.database.IDatabaseTableOperator;
import com.aptitudesoftware.test.tlf.server.IServerOperator;
import com.aptitudesoftware.test.tlf.excel.IExcelOperator;

import java.nio.file.Files;
import java.util.ArrayList;

import org.apache.log4j.Logger;
import org.testng.Assert;

public class AAHTest
{
    private static final Logger LOG = Logger.getLogger ( AAHTest.class );

    public final IDatabaseConnector      	DB_CONN_OPS 	= AAHDatabaseConnectorFactory.getDatabaseConnector ();
    public final IDataComparisonOperator 	DATA_COMP_OPS	= AAHDataComparisonOperatorFactory.getDataComparisonOperator ( DB_CONN_OPS );
    public final AAHTokenReplacement     	TOKEN_OPS   	= new AAHTokenReplacement ();
    public final IExcelOperator          	XL_OPS      	= AAHExcelOperatorFactory.getExcelOperator ( DB_CONN_OPS );
    public final IDatabaseTableOperator  	DB_TABLE_OPS	= AAHDatabaseTableOperatorFactory.getDatabaseTableOperator ( DB_CONN_OPS );
    public final IServerOperator         	SERVER_OPS		= AAHServerOperatorFactory.getServerOperator ();

    public ArrayList<AAHExpectedResult>		ER_TABLES		= new ArrayList<AAHExpectedResult>();
    public ArrayList<AAHSeedTable> 			SEED_TABLES		= new ArrayList<AAHSeedTable>();
    public ArrayList<AAHSeedFile>			SEED_FILES		= new ArrayList<AAHSeedFile>();

    public void setupTest () throws Exception
    {
        LOG.info ( "Confirm that the files relied upon by the test exist" );
        for (AAHExpectedResult er : ER_TABLES) {
        	if ( ! Files.exists ( er.getPathToDataFile() ) )    { LOG.error ( "'" + er.getPathToDataFile().toString ()     + "' does not exist." ); assert ( false ); };
            if ( ! Files.exists ( er.getPathToExpSQLFile() ) )  { LOG.error ( "'" + er.getPathToExpSQLFile().toString ()   + "' does not exist." ); assert ( false ); };
            if ( ! Files.exists ( er.getPathToActSQLFile() ) ) 	{ LOG.error ( "'" + er.getPathToActSQLFile().toString () + "' does not exist." ); assert ( false ); };
        }
        for (AAHSeedTable seed : SEED_TABLES) {
        	if ( ! Files.exists ( seed.getPathToDataFile() ) )  { LOG.error ( "'" + seed.getPathToDataFile().toString ()     + "' does not exist." ); assert ( false ); };
        }
        for (AAHSeedFile seed : SEED_FILES) {
        	if ( ! Files.exists ( seed.getPathToDataFile() ) )  { LOG.error ( "'" + seed.getPathToDataFile().toString ()     + "' does not exist." ); assert ( false ); };
        }

        LOG.info ( "Seed some data into the environment to initialise it" );
        for (AAHSeedTable seed : SEED_TABLES) {
        	XL_OPS.loadExcelTabToDatabaseTable ( seed.getActualTable().getTableOwner () , seed.getPathToDataFile() , seed.getActualTable().getTableName () , TOKEN_OPS );
        }
        
        LOG.debug ( "Connect to the server and put a file in the inbound directory" );
        for (AAHSeedFile sf : SEED_FILES) {
        	SERVER_OPS.sendFileToServer (sf.getTarget() , sf.getPathToDataFile() );
        }
    }
    
    public void compareResults () throws Exception
    {
        LOG.info ( "Load Expected Results Tables" );
        for (AAHExpectedResult er : ER_TABLES) {
        	XL_OPS.createDatabaseTableFromExcelTab ( er.getExpectedTable().getTableOwner () , er.getPathToDataFile() , er.getExpectedTable().getTableName () );
        	XL_OPS.loadExcelTabToDatabaseTable ( er.getExpectedTable().getTableOwner () , er.getPathToDataFile() , er.getExpectedTable().getTableName () , TOKEN_OPS );
        }
        
        LOG.info ( "Compare actual results to expected results" );
        for (AAHExpectedResult er : ER_TABLES) {
	        Assert.assertEquals ( er.compareTables(DATA_COMP_OPS, TOKEN_OPS), 0, 
	        		"Attempted to verify that " +
	        		er.getActualTable() + " and " +
	        		er.getExpectedTable() + " are equal: ");
        }
    }
    
    public void runBasicTest (final String pStepName) throws Exception
    {
        setupTest();
        
        runStep(pStepName);

        compareResults();
    }
    
    // public void runBasicTest (final ArrayList<String> pStepNames) throws Exception
    // {
    //     setupTest();
        
    //     for (String pStepName : pStepNames) {
    //     	runStep(pStepName);
    //     }

    //     compareResults();
    // }

    public void runBasicTest (final ArrayList<AAHStep> pSteps) throws Exception
    {
        setupTest();
        
        for (AAHStep pStep : pSteps) {
        	runStep(pStep.getName());
        }

        compareResults();
    }
    
    public void runStep (final String pStepName) throws Exception
    {
        
        LOG.info ( "Run batch step" );
        Assert.assertTrue
        (
            AAHExecution.executeBatchStep
            ( pStepName , AAHEnvironmentConstants.STEP_SCRIPT_EXEC_FOLDER ),
            "The batch step '" + pStepName + "' failed. Verify the Aptitude process runs manually: "
        );

    }
    
    public void runBasicNegativeTest (final String pStepName) throws Exception
    {
    	setupTest();
        
        runNegativeStep(pStepName);

        compareResults();
    }
    
    public void runNegativeStep (final String pStepName) throws Exception
    {        
        LOG.info ( "Run batch step" );
        Assert.assertFalse
        (
            AAHExecution.executeBatchStep
            ( pStepName , AAHEnvironmentConstants.STEP_SCRIPT_EXEC_FOLDER ),
            "The batch step '" + pStepName + "' ran successfully when expecting an error. "
        );
    }
    
    public boolean checkIfFileExists (String pFilePath) {
    	
    	
 	        boolean checkFile = true;
 	        try {
 				SERVER_OPS.executeCommand("ls " + pFilePath );
 			} catch ( Exception e ) {
 				checkFile = false;
 			}
 	   
         return checkFile;
    }
    
    
    
    public void cleardown () throws Exception
	{
		LOG.info ( "Starting cleardown" );
		LOG.info ( "Drop expected results tables from previous runs" );
		for (AAHExpectedResult er : ER_TABLES) {
			DB_TABLE_OPS.dropIfExists ( er.getExpectedTable() );
		}
		LOG.info ( "Cleardown data created by previous runs" );
		for (AAHExpectedResult er : ER_TABLES) {
        	AAHCleardownOperations.clearTable( er.getActualTable(), er.getCleardownWhere() );
        }
        for (int i = SEED_TABLES.size() - 1; i >= 0; i--) {
        	AAHCleardownOperations.clearTable( SEED_TABLES.get(i).getActualTable(), 
        			SEED_TABLES.get(i).getCleardownWhere() );
        }
		
	}

}

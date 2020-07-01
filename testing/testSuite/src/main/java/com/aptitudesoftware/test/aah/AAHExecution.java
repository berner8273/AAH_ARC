package com.aptitudesoftware.test.aah;

import org.apache.log4j.Logger;

public class AAHExecution
{
    private static final Logger LOG = Logger.getLogger ( AAHExecution.class );

    public static boolean executeBatchStep ( final AAHStep pAAHStep )
    {
    	return executeBatchStep(pAAHStep.getName());
    }
    
    public static boolean executeBatchStep ( final String pAAHStep )
    {
        LOG.debug ( "pAAHStep : " + pAAHStep );
        StringBuffer BATCH_STEP_COMMAND = new StringBuffer ( AAHEnvironmentConstants.PATH_TO_STEP_SCRIPT ).append ( ' ' ).append ( pAAHStep );
        if (AAHEnvironmentConstants.STEP_SCRIPT_EXEC_FOLDER != null && !AAHEnvironmentConstants.STEP_SCRIPT_EXEC_FOLDER.isEmpty()) {
        	LOG.debug ( "pExecutionFolder : " + AAHEnvironmentConstants.STEP_SCRIPT_EXEC_FOLDER );
        	BATCH_STEP_COMMAND = BATCH_STEP_COMMAND.append ( ' ' ).append ( AAHEnvironmentConstants.STEP_SCRIPT_EXEC_FOLDER );
        }
        return executeCommand( BATCH_STEP_COMMAND );
    }
    
    public static boolean executeBatchStep ( final String pAAHStep , final String pExecutionFolder )
    {
        LOG.debug ( "pAAHStep : " + pAAHStep );
        LOG.debug ( "pExecutionFolder : " + pExecutionFolder );

        final StringBuffer BATCH_STEP_COMMAND = new StringBuffer ( AAHEnvironmentConstants.PATH_TO_STEP_SCRIPT ).append ( ' ' ).append ( pAAHStep ).append ( ' ' ).append ( pExecutionFolder );

        return executeCommand( BATCH_STEP_COMMAND );
    }
    
    public static boolean executeCommand ( final StringBuffer pCommand )
    {
    	boolean result = true;
    	
    	LOG.debug ( "The following command will be run to invoke the batch step : " + pCommand.toString () );

        try
        {
            LOG.debug ( "Executing the command to run the batch step ... " );

            AAHServerOperatorFactory.getServerOperator ().executeCommand ( pCommand.toString () );

            LOG.debug ( "The batch step has run successfully" );
        }
        catch ( Exception e )
        {
            LOG.debug ( "The batch step has run failed: " + e.getMessage() );

            result = false;
        }

        return result;
    }

    public static void processDepartments ()
    {
        assert ( AAHExecution.executeBatchStep ( AAHStep.StandardiseDepartments ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.DSRDepartments ) );
    }

    public static void processFXRates ()
    {
        assert ( AAHExecution.executeBatchStep ( AAHStep.StandardiseFXRates ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.DSRFXRates ) );
    }

    public static void processGLAccounts ()
    {
        assert ( AAHExecution.executeBatchStep ( AAHStep.StandardiseGLAccounts ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.DSRGLAccounts ) );
    }

    public static void processGLChartfields ()
    {
        assert ( AAHExecution.executeBatchStep ( AAHStep.StandardiseGLChartfields ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.DSRGLChartfields ) );
    }

    public static void processTaxJurisdictions ()
    {
        assert ( AAHExecution.executeBatchStep ( AAHStep.StandardiseTaxJurisdiction ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.DSRTaxJurisdiction ) );
    }

    public static void processLegalEntities ()
    {
        assert ( AAHExecution.executeBatchStep ( AAHStep.StandardiseLegalEntities ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.DSRLegalEntities ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.DSRPartyBusiness ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.DSRInternalProcessEntities ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.DSRDepartments ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.DSRLegalEntityHierNodes ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.StandardiseLegalEntityLinks ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.DSRLegalEntityHierLinks ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.DSRLegalEntitySupplementalData ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.DSRLegalEntityHierarchyData ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.SLRUpdateDaysPeriods ) );
    }

    public static void processLedgers ()
    {
        assert ( AAHExecution.executeBatchStep ( AAHStep.StandardiseLedgers ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.DSRLedgers ) );
    }

    public static void processGLComboEdit ()
    {
        assert ( AAHExecution.executeBatchStep ( AAHStep.StandardiseGLComboEdit ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.DSRGLComboEdit ) );
    }

    public static void processInsurancePolicies ()
    {
        assert ( AAHExecution.executeBatchStep ( AAHStep.StandardiseInsurancePolicies ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.DSRInsurancePolicies ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.DSRFXRates ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.DSRPolicyTaxJurisdictions ) );
    }

    public static void processEventHierarchies ()
    {
        assert ( AAHExecution.executeBatchStep ( AAHStep.StandardiseEventHierarchy ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.DSREventHierarchy ) );
    }

    public static void processUsers ()
    {
        assert ( AAHExecution.executeBatchStep ( AAHStep.StandardiseUser ) );
    }

    public static void processSLR ()
    {
        assert ( AAHExecution.executeBatchStep ( AAHStep.SLRUpdateDaysPeriods ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.SLRAccounts ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.SLRFXRates ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.SLRUpdateCurrencies ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.SLRUpdateFakSeg3 ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.SLRUpdateFakSeg4 ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.SLRUpdateFakSeg5 ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.SLRUpdateFakSeg6 ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.SLRUpdateFakSeg7 ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.SLRUpdateFakSeg8 ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.SLRpUpdateJLU ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.SLRpProcess ) );
    }

    public static void processJournalLines ()
    {
        assert ( AAHExecution.executeBatchStep ( AAHStep.StandardiseJournalLine ) );

        assert ( AAHExecution.executeBatchStep ( AAHStep.DSRJournalLine ) );
    }
	
    public static void processGLINTExtract ()
    {
        assert ( AAHExecution.executeBatchStep ( AAHStep.GLINTExtract ) );
    }	

    public static void processFXReval ()
    {
        assert ( AAHExecution.executeBatchStep ( AAHStep.FXReval ) );
    }		
}
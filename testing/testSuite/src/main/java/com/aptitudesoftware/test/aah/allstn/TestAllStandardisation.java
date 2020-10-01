// package com.aptitudesoftware.test.aah.tests.allstn;

// import com.aptitudesoftware.test.aah.AAHBusinessDateOperations;
// import com.aptitudesoftware.test.aah.AAHCleardownOperations;
// import com.aptitudesoftware.test.aah.AAHDatabaseConnectorFactory;
// import com.aptitudesoftware.test.aah.AAHDatabaseTableOperatorFactory;
// import com.aptitudesoftware.test.aah.AAHDataComparisonOperatorFactory;
// import com.aptitudesoftware.test.aah.AAHExcelOperatorFactory;
// import com.aptitudesoftware.test.aah.AAHExecution;
// import com.aptitudesoftware.test.aah.AAHEnvironmentConstants;
// import com.aptitudesoftware.test.aah.AAHFXRateOperations;
// import com.aptitudesoftware.test.aah.AAHResourceConstants;
// import com.aptitudesoftware.test.aah.AAHResources;
// import com.aptitudesoftware.test.aah.AAHServerOperatorFactory;
// import com.aptitudesoftware.test.aah.AAHStep;
// import com.aptitudesoftware.test.aah.AAHTablenameConstants;
// import com.aptitudesoftware.test.aah.AAHTokenReplacement;
// import com.aptitudesoftware.test.tlf.database.DatabasePlatformConstants;
// import com.aptitudesoftware.test.tlf.database.IDataComparisonOperator;
// import com.aptitudesoftware.test.tlf.database.IDatabaseConnector;
// import com.aptitudesoftware.test.tlf.database.IDatabaseTableOperator;
// import com.aptitudesoftware.test.tlf.excel.IExcelOperator;
// import com.aptitudesoftware.test.tlf.server.IServerOperator;
// import java.nio.file.Files;
// import java.nio.file.Path;
// import java.sql.Connection;
// import java.time.LocalDate;
// import org.apache.log4j.Logger;
// import org.testng.Assert;
// import org.testng.annotations.Test;

// public class TestAllStandardisation
// {
//     private static final Logger LOG = Logger.getLogger ( TestAllStandardisation.class );

//     private final Path                    PATH_TO_RESOURCES = AAHResources.getPathToResource ( "TestAllStandardisation" );
//     private final IDatabaseConnector      DB_CONN_OPS       = AAHDatabaseConnectorFactory.getDatabaseConnector ();
//     private final IDataComparisonOperator DATA_COMP_OPS     = AAHDataComparisonOperatorFactory.getDataComparisonOperator ( DB_CONN_OPS );
//     private final IDatabaseTableOperator  DB_TABLE_OPS      = AAHDatabaseTableOperatorFactory.getDatabaseTableOperator ( DB_CONN_OPS );
//     private final IExcelOperator          XL_OPS            = AAHExcelOperatorFactory.getExcelOperator ( DB_CONN_OPS );
//     private final IServerOperator         SERVER_OPS        = AAHServerOperatorFactory.getServerOperator ();
//     private final AAHTokenReplacement     TOKEN_OPS         = new AAHTokenReplacement ();

//     private void cleardown () throws Exception
//     {
//         final IDatabaseTableOperator DB_TABLE_OPS = AAHDatabaseTableOperatorFactory.getDatabaseTableOperator ( AAHDatabaseConnectorFactory.getDatabaseConnector () );

//         final AAHTablenameConstants [] EXPECTED_RESULTS_TABLES = {
//                                                                      AAHTablenameConstants.ER_FR_LOG
//                                                                  };

//         for ( AAHTablenameConstants t : EXPECTED_RESULTS_TABLES )
//         {
//             DB_TABLE_OPS.dropIfExists ( t.getTableOwner () , t.getTableName () );
//         }

//         AAHCleardownOperations.cleardown ();
//     }

//     @Test
//     public void testSingleValidFeed () throws Exception
//     {
//         final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( "testSingleValidFeed" );
//         final Path PATH_TO_SEED_DATA        = PATH_TO_TEST_RESOURCES.resolve ( "SeedData.xlsx" );

//         if ( ! Files.exists ( PATH_TO_SEED_DATA ) ) { LOG.debug ( "'" + PATH_TO_SEED_DATA.toString () + "' does not exist." ); assert ( false ); };

//         final AAHTablenameConstants [] TABLES_TO_SEED = {
//                                                             AAHTablenameConstants.FEED
//                                                         ,   AAHTablenameConstants.FEED_RECORD_COUNT
//                                                         ,   AAHTablenameConstants.DEPARTMENT
//                                                         ,   AAHTablenameConstants.FX_RATE
//                                                         ,   AAHTablenameConstants.GL_ACCOUNT
//                                                         ,   AAHTablenameConstants.GL_CHARTFIELD
//                                                         ,   AAHTablenameConstants.TAX_JURISDICTION
//                                                         ,   AAHTablenameConstants.LEGAL_ENTITY
//                                                         ,   AAHTablenameConstants.LEGAL_ENTITY_LINK
//                                                         ,   AAHTablenameConstants.LEDGER
//                                                         ,   AAHTablenameConstants.ACCOUNTING_BASIS_LEDGER
//                                                         ,   AAHTablenameConstants.LEGAL_ENTITY_LEDGER
//                                                         ,   AAHTablenameConstants.GL_COMBO_EDIT_PROCESS
//                                                         ,   AAHTablenameConstants.GL_COMBO_EDIT_ASSIGNMENT
//                                                         ,   AAHTablenameConstants.GL_COMBO_EDIT_RULE
//                                                         ,   AAHTablenameConstants.INSURANCE_POLICY
//                                                         ,   AAHTablenameConstants.CESSION
//                                                         ,   AAHTablenameConstants.CESSION_LINK
//                                                         ,   AAHTablenameConstants.FR_INSTRUMENT_LOOKUP
//                                                         ,   AAHTablenameConstants.INSURANCE_POLICY_FX_RATE
//                                                         ,   AAHTablenameConstants.INSURANCE_POLICY_TAX_JURISD
//                                                         ,   AAHTablenameConstants.JOURNAL_LINE
//                                                         ,   AAHTablenameConstants.SLR_ENTITY_PERIODS
//                                                         ,   AAHTablenameConstants.SLR_ENTITY_PROC_GROUP
//                                                         };

//         LOG.debug ( "Start cleardown" );

//         cleardown ();

//         LOG.debug ( "Completed cleardown" );

//         AAHBusinessDateOperations.setBusinessDate ( LocalDate.of ( 2017 , 2 , 1 ) );

//         LOG.debug ( "Set the business date" );

//         for ( AAHTablenameConstants t : TABLES_TO_SEED )
//         {
//             XL_OPS.loadExcelTabToDatabaseTable ( t.getTableOwner () , PATH_TO_SEED_DATA , t.getTableName () , TOKEN_OPS );
//         }

//         AAHExecution.processDepartments ();

//         LOG.debug ( "Processed department data through to AAH core" );

//         AAHExecution.processFXRates ();

//         LOG.debug ( "Processed fx_rate data through to AAH core" );

//         AAHExecution.processGLAccounts ();

//         LOG.debug ( "Processed gl_account data through to AAH core" );

//         AAHExecution.processGLChartfields ();

//         LOG.debug ( "Processed gl_chartfield data through to AAH core" );

//         AAHExecution.processTaxJurisdictions ();

//         LOG.debug ( "Processed tax_jurisdiction data through to AAH core" );

//         AAHExecution.processLegalEntities ();

//         LOG.debug ( "Processed legal_entity data through to AAH core" );

//         AAHExecution.processLedgers ();

//         LOG.debug ( "Processed ledger data through to AAH core" );

//         AAHExecution.processGLComboEdit ();

//         LOG.debug ( "Processed gl_combo_edit data through to AAH core" );

//         AAHExecution.processInsurancePolicies ();

//         LOG.debug ( "Processed insurance_policy data through to AAH core" );

//         AAHExecution.processEventHierarchies ();

//         LOG.debug ( "Processed event_hierarchy data through to AAH core" );

//         AAHExecution.processSLR ();

//         LOG.debug ( "Processed FDR reference data through to SLR" );

//         AAHExecution.processJournalLines ();

//         LOG.debug ( "Processed journal line data through to AAH core" );

//     }
// }
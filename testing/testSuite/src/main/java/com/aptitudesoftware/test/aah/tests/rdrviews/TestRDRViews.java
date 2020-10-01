package com.aptitudesoftware.test.aah.tests.rdrviews;
import com.aptitudesoftware.test.aah.AAHExpectedResult;
import com.aptitudesoftware.test.aah.AAHResourceConstants;
import com.aptitudesoftware.test.aah.AAHResources;
import com.aptitudesoftware.test.aah.AAHTablenameConstants;
import com.aptitudesoftware.test.aah.AAHTest;
import java.nio.file.Path;
import org.apache.log4j.Logger;
import org.testng.annotations.Test;


public class TestRDRViews extends AAHTest
{
    private static final Logger LOG = Logger.getLogger (TestRDRViews.class );

    private final Path PATH_TO_RESOURCES = AAHResources.getPathToResource ( this.getClass().getSimpleName() );

    @Test
    public void testRDRViews() throws Exception
    {
    	
        //edit this line
        final String TEST_NAME              = "testRDRViews";
        
        final Path PATH_TO_TEST_RESOURCES   = PATH_TO_RESOURCES.resolve ( TEST_NAME );
        LOG.info( "RESOURCES: " + this.getClass().getSimpleName() );
        LOG.info( "Running " + this.getClass().getName() + "." + TEST_NAME );
        LOG.info( "Reseting environment");
        ER_TABLES.clear();
        SEED_TABLES.clear();

        ER_TABLES.add(
            new AAHExpectedResult(AAHTablenameConstants.ER_RDR_VIEW_COLUMNS,
            AAHTablenameConstants.RDR_VIEW_COLUMNS,
            PATH_TO_TEST_RESOURCES,
            "ExpectedResults.xlsx",
            AAHResourceConstants.RDR_VIEW_COLUMNS_ER,
            AAHResourceConstants.RDR_VIEW_COLUMNS_AR));

            cleardown ();
            setupTest();
            compareResults();
            cleardown ();
    }
}

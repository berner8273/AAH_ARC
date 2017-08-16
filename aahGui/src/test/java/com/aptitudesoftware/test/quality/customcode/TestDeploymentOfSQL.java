package com.aptitudesoftware.test.quality.sql.custom;

import com.aptitudesoftware.test.quality.sql.ICodeDeploymentChecker;
import com.aptitudesoftware.test.quality.sql.CodeDeploymentCheckerFactory;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import org.apache.log4j.Logger;
import org.testng.annotations.Test;
import org.testng.Assert;

public class TestDeploymentOfSQL
{
    private static final Logger                 LOG                       = Logger.getLogger ( TestDeploymentOfSQL.class );
    private static final String                 DATABASE_PLATFORM         = System.getProperty ( "test.databasePlatform" );
    private static final Path                   PATH_TO_ROOT              = Paths.get ( System.getProperty ( "test.pathToRoot" ) );
    private static       ICodeDeploymentChecker DEPLOYMENT_CHECKER        = null;
    private static final Map <String, String>   PATH_TO_DB_NAME_MAPPINGS;
    static
    {
        PATH_TO_DB_NAME_MAPPINGS = new HashMap <String, String> ();
        PATH_TO_DB_NAME_MAPPINGS.put ( "stn" , System.getProperty ( "test.stnUsername" ) );
        PATH_TO_DB_NAME_MAPPINGS.put ( "fdr" , System.getProperty ( "test.fdrUsername" ) );
        PATH_TO_DB_NAME_MAPPINGS.put ( "gui" , System.getProperty ( "test.guiUsername" ) );
        PATH_TO_DB_NAME_MAPPINGS.put ( "rdr" , System.getProperty ( "test.rdrUsername" ) );
        PATH_TO_DB_NAME_MAPPINGS.put ( "slr" , System.getProperty ( "test.slrUsername" ) );
    }

    @Test
    public void testDeploymentOfSQL () throws Exception
    {
        LOG.debug ( "Started : 'testDeploymentOfSQL'" );

        LOG.debug ( "'DATABASE_PLATFORM' = '" + DATABASE_PLATFORM + "'" );

        LOG.debug ( "'PATH_TO_ROOT' = '" + PATH_TO_ROOT + "'" );

        DEPLOYMENT_CHECKER = new CodeDeploymentCheckerFactory ().getCodeDeploymentChecker ( DATABASE_PLATFORM , PATH_TO_ROOT , PATH_TO_DB_NAME_MAPPINGS );

        Assert.assertFalse ( DEPLOYMENT_CHECKER.getResult () );

        LOG.debug ( "Ended : 'testDeploymentOfSQL'" );
    }
}
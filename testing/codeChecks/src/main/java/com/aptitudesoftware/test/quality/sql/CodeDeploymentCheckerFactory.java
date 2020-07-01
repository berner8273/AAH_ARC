package com.aptitudesoftware.test.quality.sql;

import com.aptitudesoftware.test.quality.sql.oracle.deployment.OracleCodeDeploymentChecker;
import java.nio.file.Path;
import java.util.Map;

public class CodeDeploymentCheckerFactory
{
    public ICodeDeploymentChecker getCodeDeploymentChecker ( final String pDatabasePlatform , final Path pPathToRootFolder , final Map <String, String> pPathToDBNameMappings ) throws Exception
    {
        ICodeDeploymentChecker deploymentChecker = null;

        if ( pDatabasePlatform.toString ().equals ( DatabasePlatformConstants.ORACLE.toString () ) )
        {
            deploymentChecker = new OracleCodeDeploymentChecker ( pPathToRootFolder , pPathToDBNameMappings );
        }

        return deploymentChecker;
    }
}
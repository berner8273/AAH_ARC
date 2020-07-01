package com.aptitudesoftware.test.quality.sql;

import com.aptitudesoftware.test.quality.sql.oracle.code.OracleCodeQualityChecker;

public class SQLCodeQualityCheckerFactory
{
    public ISQLCodeQualityChecker getSQLCodeQualityChecker ( final String pDatabasePlatform )
    {
        ISQLCodeQualityChecker sqlChecker = null;

        if ( pDatabasePlatform.toString ().equals ( DatabasePlatformConstants.ORACLE.toString () ) )
        {
            sqlChecker = new OracleCodeQualityChecker ();
        }

        return sqlChecker;
    }
}
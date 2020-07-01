package com.aptitudesoftware.test.aah;

import com.aptitudesoftware.test.tlf.database.DatabasePlatformConstants;
import com.aptitudesoftware.test.tlf.database.IDatabaseConnector;
import com.aptitudesoftware.test.tlf.database.IDatabaseTableOperator;
import com.aptitudesoftware.test.tlf.database.OracleDatabaseTableOperator;
import com.aptitudesoftware.test.tlf.database.TeradataDatabaseTableOperator;

public class AAHDatabaseTableOperatorFactory
{
    public static IDatabaseTableOperator getDatabaseTableOperator ( final IDatabaseConnector pIDatabaseConnector )
    {
        IDatabaseTableOperator dbTableOp = null;

        if ( AAHEnvironmentConstants.DATABASE_PLATFORM.equals ( DatabasePlatformConstants.ORACLE.toString () ) )
        {
            dbTableOp = new OracleDatabaseTableOperator ( pIDatabaseConnector );
        }

        if ( AAHEnvironmentConstants.DATABASE_PLATFORM.equals ( DatabasePlatformConstants.TERADATA.toString () ) )
        {
            dbTableOp = new TeradataDatabaseTableOperator ( pIDatabaseConnector );
        }

        return dbTableOp;
    }
}
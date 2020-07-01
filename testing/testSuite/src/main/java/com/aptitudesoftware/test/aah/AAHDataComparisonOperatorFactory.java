package com.aptitudesoftware.test.aah;

import com.aptitudesoftware.test.tlf.database.DatabasePlatformConstants;
import com.aptitudesoftware.test.tlf.database.IDatabaseConnector;
import com.aptitudesoftware.test.tlf.database.IDataComparisonOperator;
import com.aptitudesoftware.test.tlf.database.OracleDataComparisonOperator;
import com.aptitudesoftware.test.tlf.database.TeradataDataComparisonOperator;

public class AAHDataComparisonOperatorFactory
{
    public static IDataComparisonOperator getDataComparisonOperator ( final IDatabaseConnector pIDatabaseConnector )
    {
        IDataComparisonOperator dataCompOps = null;

        if ( AAHEnvironmentConstants.DATABASE_PLATFORM.equals ( DatabasePlatformConstants.ORACLE.toString () ) )
        {
            dataCompOps = new OracleDataComparisonOperator ( pIDatabaseConnector );
        }

        if ( AAHEnvironmentConstants.DATABASE_PLATFORM.equals ( DatabasePlatformConstants.TERADATA.toString () ) )
        {
            dataCompOps = new TeradataDataComparisonOperator ( pIDatabaseConnector );
        }

        return dataCompOps;
    }
}
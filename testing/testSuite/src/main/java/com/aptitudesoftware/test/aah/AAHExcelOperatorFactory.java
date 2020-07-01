package com.aptitudesoftware.test.aah;

import com.aptitudesoftware.test.tlf.database.DatabasePlatformConstants;
import com.aptitudesoftware.test.tlf.database.IDatabaseConnector;
import com.aptitudesoftware.test.tlf.excel.IExcelOperator;
import com.aptitudesoftware.test.tlf.excel.OracleExcelOperator;
import com.aptitudesoftware.test.tlf.excel.TeradataExcelOperator;

public class AAHExcelOperatorFactory
{
    public static IExcelOperator getExcelOperator ( final IDatabaseConnector pIDatabaseConnector  )
    {
        IExcelOperator excelOps = null;

        if ( AAHEnvironmentConstants.DATABASE_PLATFORM.equals ( DatabasePlatformConstants.ORACLE.toString () ) )
        {
            excelOps = new OracleExcelOperator ( pIDatabaseConnector );
        }

        if ( AAHEnvironmentConstants.DATABASE_PLATFORM.equals ( DatabasePlatformConstants.TERADATA.toString () ) )
        {
            excelOps = new TeradataExcelOperator ( pIDatabaseConnector );
        }

        return excelOps;
    }
}
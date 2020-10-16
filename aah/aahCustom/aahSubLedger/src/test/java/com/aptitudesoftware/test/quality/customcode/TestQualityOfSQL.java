package com.aptitudesoftware.test.quality.sql.custom;

import com.aptitudesoftware.test.quality.sql.ISQLCodeQualityChecker;
import com.aptitudesoftware.test.quality.sql.SQLCodeQualityCheckerFactory;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import org.apache.log4j.Logger;
import org.testng.annotations.Test;
import org.testng.Assert;

public class TestQualityOfSQL
{
    private static final Logger                 LOG                       = Logger.getLogger ( TestQualityOfSQL.class );
    private static final String                 DATABASE_PLATFORM         = System.getProperty ( "test.databasePlatform" );
    private static final Path                   PATH_TO_ROOT              = Paths.get ( System.getProperty ( "test.pathToRoot" ) );
    private static final Path                   PATH_TO_INSTALL_FILE      = PATH_TO_ROOT.resolve ( "install.sql" );
    private static final ISQLCodeQualityChecker SQL_CHECKER               = new SQLCodeQualityCheckerFactory().getSQLCodeQualityChecker ( DATABASE_PLATFORM );
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
    public void testForBadEOLCharacters () throws Exception
    {
        LOG.debug ( "Started : 'testForBadEOLCharacters'" );

        LOG.debug ( "'DATABASE_PLATFORM' = '" + DATABASE_PLATFORM + "'" );

        LOG.debug ( "'PATH_TO_ROOT' = '" + PATH_TO_ROOT + "'" );

        LOG.debug ( "'PATH_TO_INSTALL_FILE' = '" + PATH_TO_INSTALL_FILE + "'" );

        Assert.assertFalse ( SQL_CHECKER.hasBadEOLCharacters ( PATH_TO_ROOT ) );

        LOG.debug ( "Ended : 'testForBadEOLCharacters'" );
    }

    @Test
    public void testForBadFileNames () throws Exception
    {
        LOG.debug ( "Started : 'testForBadFileNames'" );

        LOG.debug ( "'DATABASE_PLATFORM' = '" + DATABASE_PLATFORM + "'" );

        LOG.debug ( "'PATH_TO_ROOT' = '" + PATH_TO_ROOT + "'" );

        LOG.debug ( "'PATH_TO_INSTALL_FILE' = '" + PATH_TO_INSTALL_FILE + "'" );

        Assert.assertFalse ( SQL_CHECKER.hasBadFileNames ( PATH_TO_ROOT ) );

        LOG.debug ( "Ended : 'testForBadFileNames'" );
    }

    @Test
    public void testForEmptyFiles () throws Exception
    {
        LOG.debug ( "Started : 'testForEmptyFiles'" );

        LOG.debug ( "'DATABASE_PLATFORM' = '" + DATABASE_PLATFORM + "'" );

        LOG.debug ( "'PATH_TO_ROOT' = '" + PATH_TO_ROOT + "'" );

        LOG.debug ( "'PATH_TO_INSTALL_FILE' = '" + PATH_TO_INSTALL_FILE + "'" );

        Assert.assertFalse ( SQL_CHECKER.areFilesEmpty ( PATH_TO_ROOT ) );

        LOG.debug ( "Ended : 'testForEmptyFiles'" );
    }

    @Test
    public void testForBadFileExtensions () throws Exception
    {
        LOG.debug ( "Started : 'testForBadFileExtensions'" );

        LOG.debug ( "'DATABASE_PLATFORM' = '" + DATABASE_PLATFORM + "'" );

        LOG.debug ( "'PATH_TO_ROOT' = '" + PATH_TO_ROOT + "'" );

        LOG.debug ( "'PATH_TO_INSTALL_FILE' = '" + PATH_TO_INSTALL_FILE + "'" );

        Assert.assertFalse ( SQL_CHECKER.hasBadFileExtensions ( PATH_TO_ROOT ) );

        LOG.debug ( "Ended : 'testForBadFileExtensions'" );
    }

    @Test
    public void testInstallFile () throws Exception
    {
        LOG.debug ( "Started : 'testInstallFile'" );

        LOG.debug ( "'DATABASE_PLATFORM' = '" + DATABASE_PLATFORM + "'" );

        LOG.debug ( "'PATH_TO_ROOT' = '" + PATH_TO_ROOT + "'" );

        LOG.debug ( "'PATH_TO_INSTALL_FILE' = '" + PATH_TO_INSTALL_FILE + "'" );

        Assert.assertFalse ( SQL_CHECKER.checkInstallScriptQuality ( PATH_TO_INSTALL_FILE ) );

        LOG.debug ( "Ended : 'testInstallFile'" );
    }

    @Test
    public void testFileSetQuality () throws Exception
    {
        LOG.debug ( "Started : 'testFileSetQuality'" );

        LOG.debug ( "'DATABASE_PLATFORM' = '" + DATABASE_PLATFORM + "'" );

        LOG.debug ( "'PATH_TO_ROOT' = '" + PATH_TO_ROOT + "'" );

        LOG.debug ( "'PATH_TO_INSTALL_FILE' = '" + PATH_TO_INSTALL_FILE + "'" );

        Assert.assertFalse ( SQL_CHECKER.checkFileSetQuality ( PATH_TO_ROOT , PATH_TO_DB_NAME_MAPPINGS ) );

        LOG.debug ( "Ended : 'testFileSetQuality'" );
    }
}
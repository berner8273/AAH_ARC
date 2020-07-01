package com.aptitudesoftware.test.quality.sql;

import java.nio.file.attribute.BasicFileAttributes;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.Files;
import java.nio.file.FileSystems;
import java.nio.file.FileVisitResult;
import java.nio.file.Path;
import java.nio.file.PathMatcher;
import org.apache.log4j.Logger;

public class SQLBadFileNameChecker extends SimpleFileVisitor <Path>
{
    private static final Logger LOG = Logger.getLogger ( SQLBadFileNameChecker.class );

    private boolean     foundBadFileName = false;
    private PathMatcher MATCHER          = FileSystems.getDefault().getPathMatcher ( "glob:**/*.sql" );

    public SQLBadFileNameChecker ( final Path pPathToRootFolder ) throws Exception
    {
        Files.walkFileTree
        (
            pPathToRootFolder
        ,   this
        );
    }

    @Override
    public FileVisitResult visitFile ( Path pFile , BasicFileAttributes attrs )
    {
        LOG.debug ( "Check file : '" + pFile.toString () + "' for a bad file name" );

        if ( MATCHER.matches ( pFile ) )
        {
            LOG.debug ( "File : '" + pFile.toString () + "' is a .sql file" );

            String fileName = pFile.getFileName ().toString ();

            if ( ! fileName.equals ( fileName.toLowerCase () ) )
            {
                foundBadFileName = true;

                LOG.error ( "The name of file '" + pFile.toString () + "' must be in lowercase." );
            }
        }

        return FileVisitResult.CONTINUE;
    }

    public boolean getResult ()
    {
        return foundBadFileName;
    }
}
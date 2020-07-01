package com.aptitudesoftware.test.quality.sql;

import java.nio.file.attribute.BasicFileAttributes;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.Files;
import java.nio.file.FileSystems;
import java.nio.file.FileVisitResult;
import java.nio.file.Path;
import java.nio.file.PathMatcher;
import org.apache.log4j.Logger;

public class SQLFileExtensionChecker extends SimpleFileVisitor <Path>
{
    private static final Logger LOG = Logger.getLogger ( SQLFileExtensionChecker.class );

    private boolean           foundBadFileExtension = false;
    private final PathMatcher MATCHER               = FileSystems.getDefault().getPathMatcher ( "glob:**/*.{sql,hdr,bdy}" );

    public SQLFileExtensionChecker ( final Path pPathToRootFolder ) throws Exception
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
        LOG.debug ( "Check file : '" + pFile.toString () + "' for .sql, .hdr or .bdy file extension" );

        if ( ! MATCHER.matches ( pFile ) )
        {
            LOG.error ( "File : '" + pFile.toString () + "' does not have a .sql, .hdr or .bdy extension" );

            foundBadFileExtension = true;
        }

        return FileVisitResult.CONTINUE;
    }

    public boolean getResult ()
    {
        return foundBadFileExtension;
    }
}
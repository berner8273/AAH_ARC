package com.aptitudesoftware.test.quality.sql;

import java.nio.file.attribute.BasicFileAttributes;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.Files;
import java.nio.file.FileSystems;
import java.nio.file.FileVisitResult;
import java.nio.file.Path;
import java.nio.file.PathMatcher;
import java.util.stream.Stream;
import org.apache.log4j.Logger;

public class SQLEmptyFileChecker extends SimpleFileVisitor <Path>
{
    private static final Logger LOG = Logger.getLogger ( SQLEmptyFileChecker.class );

    private boolean     areAnyFilesEmpty   = false;
    private boolean     currentFileIsEmpty = false;
    private PathMatcher matcher          = FileSystems.getDefault ().getPathMatcher ( "glob:**/*.{sql}" );

    public SQLEmptyFileChecker ( final Path pPathToRootFolder ) throws Exception
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
        LOG.debug ( "Check file : '" + pFile.toString () + "' to see if it is empty" );

        if ( matcher.matches ( pFile ) )
        {
            try ( Stream <String> fileStream = Files.lines ( pFile ) )
            {
                currentFileIsEmpty = ( fileStream.allMatch ( s -> s.trim ().equals ( "" ) ) );

                if ( currentFileIsEmpty )
                {
                    LOG.error ( "The file '" + pFile.toString () + "' is empty." );

                    areAnyFilesEmpty = true;
                }
            }
            catch ( Exception e )
            {
                LOG.error ( "An exception occured whilst checking to see whether the file '" + pFile.toString () + "' is empty : " + e );
            }
        }

        return FileVisitResult.CONTINUE;
    }

    public boolean getResult ()
    {
        return areAnyFilesEmpty;
    }
}
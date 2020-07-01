package com.aptitudesoftware.test.tlf.server;

import java.nio.file.attribute.PosixFilePermissions;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.exec.CommandLine;
import org.apache.commons.exec.DefaultExecutor;
import org.apache.commons.exec.Executor;

import org.apache.log4j.Logger;

public class SUDOServerOperator implements IServerOperator
{
    private static final Logger LOG = Logger.getLogger ( SUDOServerOperator.class );

    private String userName = "";

    public SUDOServerOperator ( final String pUserName )
    {
        userName = (pUserName == null) ? System.getProperty ( "user.name" ).toLowerCase ().trim () : pUserName;

        LOG.debug ( "userName has been set to '" + userName + "'" );
    }

    public void executeCommand ( final String pCommand ) throws Exception
    {
        CommandLine command = null;

        if ( System.getProperty ( "user.name" ).toLowerCase ().trim ().equals ( userName.toLowerCase ().trim () ) || userName == null || userName.isEmpty() )
        {
            command = new CommandLine ( "/bin/bash" );

            command.addArgument ( "-c" ).addArgument ( "${theCommand}" , false );
        }
        else
        {
            command = new CommandLine ( "sudo" );

            command.addArgument ( "-iu" ).addArgument ( userName ).addArgument ( "bash" ).addArgument ( "-c " ).addArgument ( "${theCommand}" , false );
        }

        Map<String,String> m = new HashMap<String,String>();

        m.put ( "theCommand" , pCommand );

        command.setSubstitutionMap ( m );

        Executor executor  = new DefaultExecutor ();

        LOG.info ( "Executing command: '" + command + "'" );
        int exitValue = executor.execute ( command );

        if ( exitValue != 0 )
        {
            throw new Exception ( "The attempt to execute the command '" + command + "' was unsuccessful - it returned with the value '" + exitValue + "'" );
        }
        else
        {
            LOG.info ( "The command '" + command + "' was executed successfully" );
        }
    }

    public void deleteContentsOfFolder ( final String pPathToFolder ) throws Exception
    {
        Path PATH_TO_FOLDER = Paths.get ( pPathToFolder );

        executeCommand ( "rm -rf " + PATH_TO_FOLDER.toString ().trim ().replaceAll ( "/$" , "/*" ) );
    }

    public void retrieveFileFromServer ( final String pPathToSourceFileOnServer , final Path pPathToLocalTargetFolder ) throws Exception
    {

    }

    public void sendFileToServer       ( final String pPathToTargetFolderOnServer , final Path pPathToLocalFile ) throws Exception
    {
        LOG.info ( "Sending '" + pPathToLocalFile + "' to '" + pPathToTargetFolderOnServer + "'" );

        final Path PATH_TO_INTERMEDIATE_FOLDER = Files.createTempDirectory ( "application_" + userName + "_" );

        final Path PATH_TO_INTERMEDIATE_FILE   = PATH_TO_INTERMEDIATE_FOLDER.resolve ( pPathToLocalFile .getFileName().toString() );

        Files.setPosixFilePermissions ( PATH_TO_INTERMEDIATE_FOLDER , PosixFilePermissions.fromString ( "rwxrwxrwx" ) );

        Files.copy ( pPathToLocalFile , PATH_TO_INTERMEDIATE_FILE );

        Files.setPosixFilePermissions ( PATH_TO_INTERMEDIATE_FILE , PosixFilePermissions.fromString ( "rwxrwxrwx" ) );

        executeCommand ( "cp " + PATH_TO_INTERMEDIATE_FILE + " " + pPathToTargetFolderOnServer  + ";" );

        Files.delete ( PATH_TO_INTERMEDIATE_FILE );

        Files.delete ( PATH_TO_INTERMEDIATE_FOLDER );

        LOG.info ( "" + pPathToLocalFile + "' was successfully sent to '" + pPathToTargetFolderOnServer + "'" );
    }
}

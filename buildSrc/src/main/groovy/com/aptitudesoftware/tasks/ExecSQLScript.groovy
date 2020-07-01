package com.aptitudesoftware.tasks;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import org.gradle.api.tasks.Exec;
import org.gradle.api.tasks.TaskAction;

class ExecSQLScript extends Exec {
    private String  databasePlatform       = "";
    private boolean selfLogon              = true;
    private String  logonUsername          = "";
    private String  logonPassword          = "";
    private String  oracleTnsAlias         = "";
    private final   List <String> execArgs = new ArrayList <String> (5);

    void setDatabasePlatform ( final String pDatabasePlatform ) {
        databasePlatform = pDatabasePlatform;

        if      ( databasePlatform.equals ( "ORACLE" ) ) {
            executable = 'sqlplus';
        }
        else if ( databasePlatform.equals ( "TERADATA" ) ) {
            executable = 'bteq';
        }
    }

    void setSelfLogon ( final boolean pSelfLogon ) {
        selfLogon = pSelfLogon;

        if ( selfLogon ) {
            if      ( databasePlatform.equals ( "ORACLE" ) ) {
                execArgs.add ( 0 , '/NOLOG' );
            }
            else if ( databasePlatform.equals ( "TERADATA" ) ) {
                execArgs.add ( 0 , '' );
            }
        }
    }

    void setPathToSQLFile ( final Path pPathToSQLFile ) {
        final Path REL_PATH_TO_FILE = Paths.get ( workingDir.toURI () ).relativize ( pPathToSQLFile );

        if ( selfLogon ) {
            if      ( databasePlatform.equals ( "ORACLE" ) ) {
                execArgs.add ( 1 , "@${REL_PATH_TO_FILE.fileName}" );
                args = execArgs;
            }
            else if ( databasePlatform.equals ( "TERADATA" ) ) {

            }
        }
        else {
            if      ( databasePlatform.equals ( "ORACLE" ) ) {
                execArgs.add ( 1 , "@${pPathToSQLFile}" );
                args = execArgs;
            }
            else if ( databasePlatform.equals ( "TERADATA" ) ) {

            }
        }
    }

    void setOracleTnsAlias ( final String pOracleTnsAlias ) {
        oracleTnsAlias = pOracleTnsAlias;
    }

    void setLogonUsername ( final String pLogonUsername ) {
        logonUsername = pLogonUsername;
    }

    void setLogonPassword ( final String pLogonPassword ) {
        logonPassword = pLogonPassword;

        if ( ! selfLogon ) {
            if      ( databasePlatform.equals ( "ORACLE" ) ) {
                execArgs.add ( 0 , "${logonUsername}/${logonPassword}@${oracleTnsAlias}" );
            }
            else if ( databasePlatform.equals ( "TERADATA" ) ) {
                execArgs.add ( 0 , '' );
            }
        }
    }
}
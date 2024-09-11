CREATE OR REPLACE package stn.temp_pkg_merger as

function  fBuildSql (asWhere varchar, anScenerio number) return varchar ;

procedure pRunProcess;

PROCEDURE pInsertJournalLine (anScenerio number); 

PROCEDURE pInitialize;

PROCEDURE pCreateFeed (anScenerio number) ;


END;
/
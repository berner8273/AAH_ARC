CREATE OR REPLACE package STN.temp_pkg_merger_cr as

function  fBuildSql (asWhere varchar, anScenerio number) return varchar ;

procedure pRunProcess;

PROCEDURE pInsertJournalLine (anScenerio number); 

PROCEDURE pInitialize;

PROCEDURE pCreateFeed (anScenerio number) ;


END;
/
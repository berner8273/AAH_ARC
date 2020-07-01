package com.aptitudesoftware.test.quality.sql;

import java.nio.file.Path;
import java.util.Map;

public interface ISQLCodeQualityChecker
{
    /*
     * Check that files in directory pPathToRootFolder and all of its children do not contain \r EOL characters.
     */
    public boolean hasBadEOLCharacters             ( final Path pPathToRootFolder ) throws Exception;

    /*
     * Check that files in directory pPathToRootFolder and all of its children are named in lowercase.
     */
    public boolean hasBadFileNames                 ( final Path pPathToRootFolder ) throws Exception;

    /*
     * Check that files in directory pPathToRootFolder and all of its children are not empty.
     */
    public boolean areFilesEmpty                   ( final Path pPathToRootFolder ) throws Exception;

    /*
     * Check that files have the expected file extension
     */
    public boolean hasBadFileExtensions            ( final Path pPathToRootFolder ) throws Exception;

    /*
     * (1) Check that files referred to by the file pPathToInstallFile exist.
     * (2) Check that all files in codebase ar referred to by the file pPathToInstallFile.
     * (3) Check that no duplicate entries exist in the file pPathToInstallFile.
     */
    public boolean checkInstallScriptQuality       ( final Path pPathToInstallFile ) throws Exception;

    /*
     * Check that files in directory pPathToRootFolder and all of its children meet the patterns specified in pSQLCodePattern.
     */
    public boolean checkFileSetQuality             ( final Path pPathToRootFolder , final Map <String, String> pPathToDBNameMappings ) throws Exception;
}
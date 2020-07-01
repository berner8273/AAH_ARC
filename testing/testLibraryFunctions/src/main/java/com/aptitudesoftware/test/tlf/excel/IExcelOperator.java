package com.aptitudesoftware.test.tlf.excel;

import com.aptitudesoftware.test.tlf.string.ITokenReplacement;

import java.nio.file.Path;

public interface IExcelOperator
{
    public void createDatabaseTableFromExcelTab ( final String pTableOwner , final Path pPathToExcelFile , final String pExcelTab ) throws Exception;

    public void loadExcelTabToDatabaseTable     ( final String pTableOwner , final Path pPathToExcelFile , final String pExcelTab , final ITokenReplacement pITokenReplacement ) throws Exception;
}
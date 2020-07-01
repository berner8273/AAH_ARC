package com.aptitudesoftware.test.tlf.database;

import com.aptitudesoftware.test.tlf.string.ITokenReplacement;

import java.nio.file.Path;

public interface IDataComparisonOperator
{
    public int countMinusQueryResults ( final Path pPathToQuery1 , final Path pPathToQuery2 , final String[] pBindArray , final ITokenReplacement pITokenReplacement ) throws Exception;

    public int countMinusQueryResultsNoLog ( final Path pPathToQuery1 , final Path pPathToQuery2 , final String[] pBindArray , final ITokenReplacement pITokenReplacement ) throws Exception;
}
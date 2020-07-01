package com.aptitudesoftware.test.quality.sql;


public interface ICodeDeploymentChecker
{
    /*
     * Check that files in directory pPathToRootFolder have been deployed to the database.
     */
    public boolean getResult ();
}
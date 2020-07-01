package com.aptitudesoftware.test.tlf.database;

public interface IDatabaseTableOperator
{
	public boolean checkIfExists ( final String pTableOwner , final String pTableName ) throws Exception;
	
	public boolean checkIfExists ( final ITablename pTable ) throws Exception;

	public void copyTable        ( final String pSourceTableOwner , final String pSourceTableName , final String pTargetTableOwner , final String pTargetTableName , final boolean pIncludeData ) throws Exception;

	public void copyTable        ( final ITablename pSourceTable , final ITablename pTargetTable , final boolean pIncludeData ) throws Exception;

    public void dropIfExists     ( final String pTableOwner , final String pTableName ) throws Exception;
    
    public void dropIfExists     ( final ITablename pTable ) throws Exception;
}
package com.aptitudesoftware.test.aah;

import java.nio.file.Path;

import com.aptitudesoftware.test.tlf.database.IDataComparisonOperator;

public class AAHExpectedResult
{
	public AAHTablenameConstants expectedTable;
	
	public AAHTablenameConstants actualTable;
	
	public String dataFileName;

	public String expectedSQLFileName;
	
	public String actualSQLFileName;
	
	public Path pathToResources;
	
	public Path pathToDataFile;
	
	public Path pathToExpSQLFile;
	
	public Path pathToActSQLFile;
	
	public String cleardownWhere;
	
	public AAHExpectedResult( final AAHTablenameConstants pExpectedTable,
						final AAHTablenameConstants pActualTable,
						final Path pPathToResources,
						final String pDataName, 
						final String pExpSQLName, 
						final String pActSQLName,
						final String pCleardownWhere) {
		
		this.expectedTable 			= pExpectedTable;
		this.actualTable 			= pActualTable;
		this.dataFileName 			= pDataName;
		this.expectedSQLFileName 	= pExpSQLName;
		this.actualSQLFileName		= pActSQLName;
		this.pathToResources 		= pPathToResources;
		this.cleardownWhere			= pCleardownWhere;
		this.pathToDataFile 		= (dataFileName == null) 		? null : pathToResources.resolve(dataFileName);
		this.pathToExpSQLFile 		= (expectedSQLFileName == null) ? null : pathToResources.resolve(expectedSQLFileName);
		this.pathToActSQLFile 		= (actualSQLFileName == null) 	? null : pathToResources.resolve(actualSQLFileName);
	}
	
	public AAHExpectedResult( final AAHTablenameConstants pExpectedTable,
			final AAHTablenameConstants pActualTable,
			final Path pPathToResources,
			final String pDataName, 
			final String pExpSQLName, 
			final String pActSQLName) {
		
		this(pExpectedTable, pActualTable, pPathToResources, pDataName, pExpSQLName, pActSQLName, null);
	}

	public AAHExpectedResult( final AAHTablenameConstants pExpectedTable,
						final AAHTablenameConstants pActualTable,
						final Path pPathToResources,
						final String pDataName, 
						final AAHResourceConstants pExpSQL, 
						final AAHResourceConstants pActSQL,
						final String pCleardownWhere) {
		
		this.expectedTable 			= pExpectedTable;
		this.actualTable 			= pActualTable;
		this.dataFileName 			= pDataName;
		this.expectedSQLFileName 	= pExpSQL.name();
		this.actualSQLFileName		= pActSQL.name();
		this.pathToResources 		= pPathToResources;
		this.cleardownWhere			= pCleardownWhere;
		this.pathToDataFile 		= (dataFileName == null) 		? null : pathToResources.resolve(dataFileName);
		this.pathToExpSQLFile 		= (expectedSQLFileName == null) ? null : pExpSQL.getPathToResource();
		this.pathToActSQLFile 		= (actualSQLFileName == null) 	? null : pActSQL.getPathToResource();
	}

	public AAHExpectedResult( final AAHTablenameConstants pExpectedTable,
						final AAHTablenameConstants pActualTable,
						final Path pPathToResources,
						final String pDataName, 
						final AAHResourceConstants pExpSQL, 
						final String pActSQLName,
						final String pCleardownWhere) {
		
		this.expectedTable 			= pExpectedTable;
		this.actualTable 			= pActualTable;
		this.dataFileName 			= pDataName;
		this.expectedSQLFileName 	= pExpSQL.name();
		this.actualSQLFileName		= pActSQLName;
		this.pathToResources 		= pPathToResources;
		this.cleardownWhere			= pCleardownWhere;
		this.pathToDataFile 		= (dataFileName == null) 		? null : pathToResources.resolve(dataFileName);
		this.pathToExpSQLFile 		= (expectedSQLFileName == null) ? null : pExpSQL.getPathToResource();
		this.pathToActSQLFile 		= (actualSQLFileName == null) 	? null : pathToResources.resolve(actualSQLFileName);
	}
	
	public AAHExpectedResult( final AAHTablenameConstants pExpectedTable,
			final AAHTablenameConstants pActualTable,
			final Path pPathToResources,
			final String pDataName, 
			final AAHResourceConstants pExpSQL, 
			final AAHResourceConstants pActSQL) {
		
		this(pExpectedTable, pActualTable, pPathToResources, pDataName, pExpSQL, pActSQL, null);
	}
	
	public AAHTablenameConstants getExpectedTable() {
		return expectedTable;
	}

	public AAHTablenameConstants getActualTable() {
		return actualTable;
	}

	public String getExpectedDataFileName() {
		return dataFileName;
	}

	public String getExpectedSQLFileName() {
		return expectedSQLFileName;
	}

	public String getActualSQLFileName() {
		return actualSQLFileName;
	}

	public Path getPathToResources() {
		return pathToResources;
	}

	public Path getPathToDataFile() {
		return pathToDataFile;
	}

	public Path getPathToExpSQLFile() {
		return pathToExpSQLFile;
	}

	public Path getPathToActSQLFile() {
		return pathToActSQLFile;
	}
	
	public int compareTables(IDataComparisonOperator pDataCompOps, AAHTokenReplacement pTokenOps) throws Exception {
		return pDataCompOps.countMinusQueryResults 
				(getPathToActSQLFile(), getPathToExpSQLFile(), new String[] {}, pTokenOps);
	}
	
	public String getCleardownWhere() {
		return cleardownWhere;
	}
}
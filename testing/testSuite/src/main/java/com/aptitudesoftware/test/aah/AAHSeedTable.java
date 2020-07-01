package com.aptitudesoftware.test.aah;

import java.nio.file.Path;

public class AAHSeedTable
{	
	public AAHTablenameConstants actualTable;
	
	public String dataFileName;
	
	public Path pathToResources;
	
	public Path pathToDataFile;
	
	public String cleardownWhere;
	
	public AAHSeedTable( final AAHTablenameConstants pActualTable,
						final Path pPathToResources,
						final String pDataName,
						final String pCleardownWhere) {
		
		this.actualTable 			= pActualTable;
		this.dataFileName 			= pDataName;
		this.pathToResources 		= pPathToResources;
		this.pathToDataFile 		= (dataFileName == null) 		? null : pathToResources.resolve(dataFileName);
		this.cleardownWhere			= pCleardownWhere;
	}
	
	public AAHSeedTable( final AAHTablenameConstants pActualTable,
			final Path pPathToResources,
			final String pDataName) {
		
		this(pActualTable, pPathToResources, pDataName, null);
	}

	public AAHTablenameConstants getActualTable() {
		return actualTable;
	}

	public String getExpectedDataFileName() {
		return dataFileName;
	}

	public Path getPathToResources() {
		return pathToResources;
	}

	public Path getPathToDataFile() {
		return pathToDataFile;
	}
	
	public String getCleardownWhere() {
		return cleardownWhere;
	}

}
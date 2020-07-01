package com.aptitudesoftware.test.aah;

import java.nio.file.Path;

public class AAHSeedFile
{
	public String dataFileName;
	
	public Path pathToResources;
	
	public Path pathToDataFile;
	
	public String target;
	
	public AAHSeedFile(final Path pPathToResources,
						final String pDataFileName, 
						final String pTarget) {
		
		this.dataFileName 		= pDataFileName;
		this.target 			= pTarget;
		this.pathToResources 	= pPathToResources;
		this.pathToDataFile 	= (dataFileName == null) ? null : pathToResources.resolve(dataFileName);
	}

	public String getDataFileName() {
		return dataFileName;
	}

	public Path getPathToResources() {
		return pathToResources;
	}

	public Path getPathToDataFile() {
		return pathToDataFile;
	}

	public String getTarget() {
		return target;
	}
	
	public String toString ()
    {
        return dataFileName;
    }
}
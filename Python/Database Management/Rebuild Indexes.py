############################################################################# 
### Jay Dahlstrom
### Campus Engineering, University of Washington
### April 7, 2014
###

############################################################################# 
### Description: This script is designed to update indexes on all GIS features
### in the provided databases.  Any non-ESRI table is excluded from having its
### indexes rebuilt.  This script should be run every month to keep database 
### performance up.
### 


############################################################################# 
### Libraries
###

import arcpy
from arcpy import env

############################################################################# 
### Parameters
###

DatabaseConnections = [r"Database Connections\FS_CEO.sde", r"Database Connections\FS_MAC.sde", r"Database Connections\FS_CEO_EXTINGUISHER.sde", r"Database Connections\PUB-FMC.sde"]

#############################################################################  
###Script Follows
###

def main(DbConnections):
    #Rebuild Indexes
    RebuildGisIndexes(DbConnections)

def RebuildGisIndexes(Connections):
    '''
    This function takes Geodatabase connections as inputs
    (in the form of a list) and rebuilds the indexes for
    all ESRI registered tables in the database.
    '''
    for Connection in Connections:
        env.workspace = Connection
        DataList = arcpy.ListTables() + arcpy.ListFeatureClasses()
        GisDataList = []
        for item in DataList:
            # Exclude non-ESRI tables from having indexes updated
            if 'DBO' in item:
                GisDataList.append(item)
        arcpy.RebuildIndexes_management(Connection, "NO_SYSTEM", GisDataList, "ALL")
        print "Indexes for GIS tables in " + Connection + " have been rebuilt"
    print "Script ran successfully"
	
if __name__ == "__main__":
    main(DatabaseConnections)

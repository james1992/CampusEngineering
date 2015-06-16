import arcpy
from arcpy import env


def main():
    #IAMUW databases
    DatabaseConnections = [r"Database Connections\IAMUW-FS_CEO.sde", r"Database Connections\IAMUW-FS_MAC.sde"]
    
    #Replicas to Sync
    CEODatabaseReplicas = ["test", "UtilityPoleField", "LuminareField", "PhotocellField", "SpliceField", "LightingContactorField"]
    MCDatabaseReplicas = ["test", "LandscapeField", "BollardField", "TreeField", "BenchField"]
    #Sync the Replicas
    SyncReplicaDatasets(CEODatabaseReplicas, MCDatabaseReplicas)
    '''
    #Compress IAMUW Databases
    DatabaseCompression(DatabaseConnections)
    
    #Tables and Feature Classes to move versioned edits to base
    CeoDatabaseObjects = ["CEO_ELECTRICAL_LIGHTINGCONTACTOR", "CEO_ELECTRICAL_LIGHTINGCONTACTOR_AUX", "CEO_ELECTRICAL_LUMINARE", 
                          "CEO_ELECTRICAL_LUMINARE_AUX", "CEO_ELECTRICAL_PHOTOCELL", "CEO_ELECTRICAL_PHOTOCELL_AUX", "CEO_ELECTRICAL_SPLICE",
                          "CEO_ELECTRICAL_SPLICE_AUX", "CEO_ELECTRICAL_UTILITYPOLE", "CEO_ELECTRICAL_UTILITYPOLE_AUX"]
    McDatabaseObjects = ["MC_BENCH", "MC_BENCH_AUX", "MC_BOLLARD", "MC_BOLLARD_AUX", "MC_LANDSCAPEPROFILE", "MC_LANDSCAPEPROFILE_AUX",
                         "MC_TREE", "MC_TREE_AUX", "MC_TREE_AUX_DESIGNATION", "MC_TREE_AUX_MAINTENANCE"]
    #Compress edits in CEO and MAC databases
    CeoCompressToBase(CeoDatabaseObjects)
    McCompressToBase(McDatabaseObjects)
    
    #Analyze Database Table Statistics
    AnalyzeDatabaseStatistics(DatabaseConnections)
    '''

def SyncReplicaDatasets(CeoReplicas, McReplicas):
    '''
    This function takes replicas from the CEO and MAC databases
    and syncs changes that have been made to the releveant child
    datasets in the IAMUW_REPLICATION database on the pub server.
    '''
    for replica in CeoReplicas:
        arcpy.SynchronizeChanges_management(r"Database Connections\IAMUW-FS_CEO.sde", replica,
                                            r"Database Connections\IAMUW_REPLICATION.sde", "FROM_GEODATABASE2_TO_1",
                                            "IN_FAVOR_OF_GDB2", "BY_OBJECT")
        print replica + ' has been synced'
    for replica in McReplicas:
        arcpy.SynchronizeChanges_management(r"Database Connections\IAMUW-FS_MAC.sde", replica,
                                            r"Database Connections\IAMUW_REPLICATION.sde", "FROM_GEODATABASE2_TO_1",
                                            "IN_FAVOR_OF_GDB2", "BY_OBJECT")
        print replica + ' has been synced'

def DatabaseCompression(ConnectionNames):
    '''
    This function takes database connections and then
    compresses those databases to remove unused states from
    the tree.  This is done to improve query performance.
    '''
    for Connection in ConnectionNames:
        arcpy.Compress_management(Connection)
        print Connection + " has been compressed"

def CeoCompressToBase(CeoObjects):
    '''
    This function takes tables in the CEO database, sets the
    ArcGIS workspace and then calls the VersionManagement function
    for each item in the list.
    '''
    env.workspace = r"Database Connections\IAMUW-FS_CEO.sde"
    for item in CeoObjects:
        VersionManagement(item)

def McCompressToBase(McObjects):
    '''
    This function takes tables in the MAC database, sets the
    ArcGIS workspace and then calls the VersionManagement function
    for each item in the list.
    '''
    env.workspace = r"Database Connections\IAMUW-FS_MAC.sde"
    for item in CeoObjects:
        VersionManagement(item)


def VersionManagement(DbItem):
    '''
    Takes a database table and unregisters it as versioned and then
    re-registers it as versioned without the option to move edits
    to base.  This compresses edits to base. Note: workspace must
    be specified prior to running this function.
    '''
    arcpy.UnregisterAsVersioned_management(DbItem, "NO_KEEP_EDIT", "COMPRESS_DEFAULT")
    arcpy.RegisterAsVersioned_management(DbItem, "NO_EDITS_TO_BASE")
    print "Edits from" + DbItem + " have been compressed to base"

def AnalyzeDatabaseStatistics(ConnectionNames):
    '''
    This function takes database connections and runs through
    all of the ESRI tables and feature classes to update
    their statistics.  This significantly improves query times.
    '''
    for Connection in ConnectionNames:
        env.workspace = Connection
        dataList = arcpy.ListTables() + arcpy.ListFeatureClasses()
        for item in dataList:
            # exclude tables not registered with Geodatabase
            if 'DBO' in item:
                arcpy.AnalyzeDatasets_management(connection, "SYSTEM", item,
                                     "ANALYZE_BASE", "ANALYZE_DELTA", "NO_ANALYZE_ARCHIVE")
                print item + " has been analyzed"
            else:
                pass

if __name__ == "__main__":
    main()

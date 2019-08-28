############################################################################# 
### Jay Dahlstrom
### Facilities IT, University of Washington
### August 5, 2019
###

############################################################################# 
### Description: Working with ArcGIS software requires additional configuration
### on the backend to grant users with editor or viewer permissions access to 
### the data in the database.  This does not affect users with database owner
### or system administrator roles.  This script runs nightly on each database
### granting editor and viewer access to all feature classes and tables in the
### database to the appropriate UW Groups.
###
### Note: The names of the databases must match those used below. If they do not 
### update the database names through ArcMap/ArcCatalog.
###


############################################################################# 
### Libraries
###

import arcpy

############################################################################# 
### Parameters
###

databaseConnections = [r"Database Connections\BaseComponents.sde",r"Database Connections\CampusEngineeringOperations.sde",r"Database Connections\EngineeringServices.sde",r"Database Connections\FacilitiesServices.sde",r"Database Connections\FacilitiesMaintenance.sde",
                       r"Database Connections\TransportationServices.sde",r"Database Connections\UMP.sde",r"Database Connections\DevelopmentArea.sde"]

editorGroups = ["","NETID\u_uwes_sql_editors_cuo","NETID\u_uwes_sql_editors_es","NETID\u_uwes_sql_editors_fac","NETID\u_uwes_sql_editors_fm","NETID\u_uwes_sql_editors_ts","NETID\u_uwes_sql_dev_editors","NETID\u_uwes_sql_dev_editors"]

viewerGroups = ["NETID\u_uwes_sql_viewers_base","NETID\u_uwes_sql_viewers_cuo","NETID\u_uwes_sql_viewers_es","NETID\u_uwes_sql_viewers_fac","NETID\u_uwes_sql_viewers_fm","NETID\u_uwes_sql_viewers_ts","",""]

#############################################################################  
###Script Follows
###

def main(databaseConnections, editorGroups, viewerGroups):
    updatePermissions(databaseConnections, editorGroups, viewerGroups)
	
def updatePermissions(databaseConnections, editorGroups, viewerGroups):
    '''
    Function that takes 3 parameters (an ArcGIS database connection string,
    a database editor group and a database viewer group).  The two groups are
    pulled from security groups that were created in UW Group Services and that
    have already been added to SQL Server.  The function updates the feature
    classes and tables in each databse to grant the appropriate view and edit
    rights to the associated groups.
    '''
    count = 0
    for connection in databaseConnections:
        arcpy.env.workspace = connection
        tables = arcpy.ListTables()
        featureclasses = arcpy.ListFeatureClasses()
        allDatasets = tables + featureclasses
        if viewerGroups[count] == "":
            setDataEditors(allDatasets, editorGroups[count])
            print connection
            print "editor"
        elif editorGroups[count] == "":
            setDataViewers(allDatasets, viewerGroups[count])
            print connection
            print "viewer"
        else:
            setDataEditors(allDatasets, editorGroups[count])
            setDataViewers(allDatasets, viewerGroups[count])
            print connection
            print "both"
        count = count + 1
            
def setDataEditors(allDatasets, editorGroup):
    '''
    Function that grants read and write permissions for the provided
    editor group to all of the feature classes and tables within the
    provided database.
    '''
    for dataset in allDatasets:
        arcpy.ChangePrivileges_management(dataset, editorGroup, "GRANT", "GRANT")

def setDataViewers(allDatasets, viewerGroup):
    '''
    Function that grants read and permissions for the provided
    viewer group to all of the feature classes and tables within the
    provided database.
    '''
    for dataset in allDatasets:
        arcpy.ChangePrivileges_management(dataset, viewerGroup, "GRANT", "AS_IS")
    
if __name__ == "__main__":
    main(databaseConnections, editorGroups, viewerGroups)

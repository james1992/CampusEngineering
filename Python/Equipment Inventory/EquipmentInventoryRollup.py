############################################################################# 
### Author: Jay Dahlstrom
### Entity: Campus Engineering, University of Washington
### Python Version: 2.7.8
### Date Created: June 17, 2015
### Last Modified Date: September 21, 2015

############################################################################# 
### Description: This project required that the working feature class support
### moving edits to base automatically which means that replication is not an
### option.  To get new records back to the production tables a python script
### was required.  This script truncates the production tables to remove old
### entries and then uses a search cursor to extract all of the rows from each
### of the three tables and finally an insert cursor is used to add those rows
### to the production tables.
###
### Note: This script needs to be run last
###


############################################################################# 
### Libraries
###

import arcpy
from arcpy import env

############################################################################# 
### Parameters
###

# Equipment Tables, names are the same in both databases
EquipmentTables = ["CEO_EQUIPMENT_INVENTORY", "CEO_EQUIPMENT_INVENTORY_AUX", "CEO_EQUIPMENT_INVENTORY_AUX_LOCATION"]

# Fields to be updated in Feature Class
GeomFields = ["FEATURE_ID", "FEATURE_TYPE", "FEATURE_STATUS", "FEATURE_STATUS_DATE", "NOTES", "SHAPE@XY"]

# Fields to be updated in Aux Table
DescriptionFields = ["EIO", "EQUIPMENT_DESCRIPTION", "MANUFACTURE", "MODEL", "SERIAL_NUMBER", "BUDGET_NUMBER"]

# Fields to be updated in Aux Location Table
LocationFields = ["EIO", "FACNAME", "WING", "ROOM_NUMBER", "LOCATION_DESCRIPTION", "DATE", "CUSTODIAN"]

#############################################################################  
###Script Follows
###

def main(TableNames, FeatureClassFields, AuxFields, AuxLocationFields):
    TruncateProductionTables(TableNames)
    
    # Create nested list of fields to allow for iteration
    Fields = [FeatureClassFields, AuxFields, AuxLocationFields]
    
    # Initialize count variable for iteration
    count = 0
    for DatabaseTable in TableNames:
        NestedList = ExtractDatabaseRecords(DatabaseTable, Fields[count])
        Repopulatetable(DatabaseTable, Fields[count], NestedList)
        count = count + 1
    print 'All scripts have been run successfully and production tables are now synced'

def TruncateProductionTables(Tables):
    '''
    Remove all entries from the production tables
    but keep the schema intact.
    '''
    env.workspace = r"Database Connections/IAMUW-FS_CEO.sde"
    for Table in Tables:
        # Tables must be unregistered as versioned before they can be truncated
        arcpy.UnregisterAsVersioned_management(Table, "NO_KEEP_EDIT", "COMPRESS_DEFAULT")
        arcpy.TruncateTable_management(Table)
        # Re-register as versioned after successfully truncating table
        arcpy.RegisterAsVersioned_management(Table, "NO_EDITS_TO_BASE")
    
def ExtractDatabaseRecords(Table, Fields):
    '''
    Function that takes all of the rows from a table
    and puts returns them as a nested list.  The order
    of that nested list is the same as the order of the
    rows in the table, so EIO is first.
    '''
    EquipmentList = []
    env.workspace = r"Database Connections/PUB-REPLICATION.sde"
    with arcpy.da.SearchCursor(Table, Fields) as Cursor:
        for Row in Cursor:
            # Create a temp list that will work for any number of fields
            RowList =[]
            for item in Row:
                # Add all row data to list
                RowList.append(item)
            # Create a nested list for each row
            EquipmentList.append(RowList)
    del Row
    del Cursor
    return EquipmentList

def Repopulatetable(Table, Fields, EquipmentList):
    '''
    Function that takes a nested list for a particular table
    and inserts new rows into that table from the nested list.
    Only the GlobalIDs will not match between the source and
    destination tables.
    '''
    # Set editing environment for versioned table
    workspace = env.workspace = r"Database Connections/IAMUW-FS_CEO.sde"
    edit = arcpy.da.Editor(workspace)
    edit.startEditing(False, True)
    edit.startOperation()
    with arcpy.da.InsertCursor(Table, Fields) as InsertCursor:
        for Entry in EquipmentList:
            InsertCursor.insertRow(Entry)
    edit.stopOperation()
    # Stop editing and save edits
    edit.stopEditing(True)


if __name__ == "__main__":
    main(EquipmentTables, GeomFields, DescriptionFields, LocationFields)


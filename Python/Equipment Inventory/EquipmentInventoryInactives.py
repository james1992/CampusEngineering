############################################################################# 
### Author: Jay Dahlstrom
### Entity: Campus Engineering, University of Washington
### Python Version: 2.7.8
### Date Created: September 21, 2015
### Last Modified Date: September 21, 2015

############################################################################# 
### Description: The purpose of this script is to turn any pieces of equipment
### that haS been removed from OASIS to inactive in the GIS database.  Just
### as new equipment can be added so toO can old equipment be removed.  Records
### are never deleted from the database but instead are turned inactive and
### can no longer be viewed from the web map, but they are still in the database
### which means that they can be queried.  To accomplish this a list of EIO 
### numbers in OASIS is compared to the list in the GIS, any records that exist
### in GIS but not OASIS are turned to inactive (if they are no longer in OASIS
### then they have been surplused or claimed as lost).
###
### Note: this script should be run after the updates procedure.
###


############################################################################# 
### Libraries
###

import arcpy


############################################################################# 
### Parameters
###

# Location of the ESRI table created in the Additions script
OutputExcelTable = r"C:\Users\jamesd26\Desktop\Domain Updates\zEquipmentInventory.gdb\EIO"

# EIO field in Excel
ExcelEio = ['Asset']

# Location of the geometry feature class, used for web maps
GisGeometryFc = r"Database Connections\PUB-REPLICATION.sde\CEO_EQUIPMENT_INVENTORY"

# EIO field in geometry
GisEio = ['FEATURE_ID']

#############################################################################  
###Script Follows
###

def main(ExcelData, ExcelId, FcData, FcId):
    print 'now I am turning equipment that has been removed from OASIS to inactive.  Those EIO numbers are:'
    
    # Create lists for EIO numbers in Excel and GIS
    ExcelEioList = IdentifyEioNumbers(ExcelData, ExcelId)
    GisEioList = IdentifyEioNumbers(FcData, FcId)

    # Identify Equipment that should be inactive
    InactiveEioList = IdentifyInactiveEquipment(ExcelEioList, GisEioList)

    # Turn Equipment to Inactive
    UpdateInactiveEquipment(FcData, InactiveEioList)
    
def IdentifyEioNumbers(InputTable, IdField):
    '''
    Given an input table this function iterates through each
    row and grabs the EIO number and returns them
    as a list.  The GIS and Excel lists will be compared to
    find equipment that should be made inactive.
    '''
    EioList = []
    with arcpy.da.SearchCursor(InputTable, IdField) as cursor:
        for row in cursor:
            EioList.append(row[0])
    del cursor
    return EioList

def IdentifyInactiveEquipment(ExcelList, GisList):
    '''
    Function that compares two lists, any items in the
    second list (GisList) that don't appear in the first
    list (ExcelList) are return in a new list.  These
    items will be turned inactive in the Update Inactive
    Equipment function.
    '''
    InactiveEioList = []
    for Equipment in GisList:
        if Equipment in ExcelList:
            pass
        else:
            print Equipment
            InactiveEioList.append(Equipment)
    return InactiveEioList

def UpdateInactiveEquipment(FeatureClass, InactiveList):
    '''
    Given a feature class and list of EIO tags this function
    turns the geometries that represent those tags to
    inactive. This is done through an update cursor.
    '''
    # Initialize editing environment
    edit = arcpy.da.Editor(r"Database Connections\PUB-REPLICATION.sde")
    edit.startEditing(False, True)
    edit.startOperation()
    with arcpy.da.UpdateCursor(FeatureClass, ['FEATURE_ID', 'FEATURE_STATUS']) as Cursor:
        for GisRow in Cursor:
            if GisRow[0] in InactiveList:
                GisRow[1] = 2
                Cursor.updateRow(GisRow)
    del GisRow
    del Cursor
    edit.stopOperation()
    # Stop editing and save changes
    edit.stopEditing(True)


if __name__ == "__main__":
    main(OutputExcelTable, ExcelEio, GisGeometryFc, GisEio)


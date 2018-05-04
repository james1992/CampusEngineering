############################################################################# 
### Author: Jay Dahlstrom
### Entity: Campus Engineering, University of Washington
### Python Version: 2.7.8
### Date Created: June 17, 2015
### Last Modified Date: July 6, 2016
###

############################################################################# 
### Description: This script needs to be run after the Equipment Invnetory Additions
### script, this is because it relies upon the outputs of that procedure such as the ESRI
### table that is create from the master excel file.  The purpose of this script 
### is to update any rows that have changed in the Excel, for example the room
### number of an asset has been changed.  Any rows that are new or have not
### changed are skipped.  For now the same process is implemented on both the location
### and description tables.  In the future a historical record set will be maintained
### for locations, but right now it is not pratical without an accurate baseline.
###
### Note: The equipment removal script should be run following this script.
###


############################################################################# 
### Libraries
###

import arcpy

# Make use of funcations that were already created
import EquipmentInventoryAdditions

############################################################################# 
### Parameters
###

# Location of the ESRI table created in the Additions script
OutputExcelTable = r"C:\Users\jamesd26.NETID\Desktop\Domains\EquipmentInventory.gdb\EIO"

# Fields to be extracted from Excel table for equipment descriptions 
DescriptionFieldsExcel = ['Asset', 'Description', 'Manufacturer', 'Model', 'Serial_', 'Budget']

# Fields to be extracted from Excel table for equipment locations
LocationFieldsExcel = ['Asset', 'Building', 'Wing', 'Room', 'Other_Loc', 'Custodian']

# Equipment description table in SQL Server, used for web map
DescriptionTable = r"Database Connections\FS_CEO.sde\CEO_EQUIPMENT_INVENTORY_AUX"

# Field names used in the Description table in SQL Server
DescriptionFields = ['EIO', 'EQUIPMENT_DESCRIPTION', 'MANUFACTURE', 'MODEL', 'SERIAL_NUMBER', 'BUDGET_NUMBER']

# Equipment location table in SQL Server, used for web map
LocationTable = r"Database Connections\FS_CEO.sde\CEO_EQUIPMENT_INVENTORY_AUX_LOCATION"

# Field names used in the Location table in SQL Server
LocationFields = ['EIO', 'FACNAME', 'WING', 'ROOM_NUMBER', 'LOCATION_DESCRIPTION', 'CUSTODIAN']


#############################################################################  
###Script Follows
###

def main(ExcelTable, InputDescriptionFields, InputLocationFields, AuxTable, AuxFields, AuxLocationTable, AuxLocationFields):
    print 'now I am updating existing rows.  Here are the rows that have been updated:'
    
    # Use function from the EquipmentInventoryAdditions file to extract equipment description values from Excel Table
    DescriptionRows = EquipmentInventoryAdditions.ExtractEquipmentDescription(ExcelTable, InputDescriptionFields)
    
    # Use function from the EquipmentInventoryAdditions file to extract equipment location values from Excel Table
    LocationRows = EquipmentInventoryAdditions.ExtractEquipmentLocationInformation(ExcelTable, InputLocationFields)
    
    # Update any rows with changes in the description table (AUX)
    UpdateExistingDescriptions(AuxTable, AuxFields, DescriptionRows)
      
    # Insert new rows if asset location attributes have changed in the Excel
    UpdateExistingLocations(AuxLocationTable, AuxLocationFields, LocationRows)
    
def UpdateExistingDescriptions(Table, Fields, DescriptionExcelList):
    ''' 
    This function takes the table in SQL Server that stores the
    descriptive information about the equipment, the fields in that
    table and a list from the master excel with the descriptive
    information.  Creates an update cursor and then sends the list
    pair to Check Inputs for comparison.  Any updates are eventually
    processed in the update rows function.  Those updates are saved
    at the end of this function.
    '''
    # Initialize editing environment
    edit = arcpy.da.Editor(r"Database Connections\FS_CEO.sde")
    edit.startEditing(False, True)
    edit.startOperation()
    with arcpy.da.UpdateCursor(Table, Fields) as Cursor:
        for GisRow in Cursor:
            for ExcelRow in DescriptionExcelList:
                CheckInputs(GisRow, ExcelRow, Cursor)
    del GisRow
    del Cursor
    edit.stopOperation()
    # Stop editing and save changes
    edit.stopEditing(True)


def UpdateExistingLocations(Table, Fields, LocationExcelList):
    '''
    This function takes the table in SQL Server that stores the
    location information about the equipment, the fields in that
    table and a list from the master excel with the location
    information.  Creates an update cursor and then sends the list
    pair to Check Inputs for comparison.  Any updates are eventually
    processed in the update rows function.  Those updates are saved
    at the end of this function.
    '''
    # Initialize editing environment
    edit = arcpy.da.Editor(r"Database Connections\FS_CEO.sde")
    edit.startEditing(False, True)
    edit.startOperation()
    with arcpy.da.UpdateCursor(Table, Fields) as Cursor:
        for GisRow in Cursor:
            for ExcelRow in LocationExcelList:
                CheckInputs(GisRow, ExcelRow, Cursor)
    edit.stopOperation()
    # Stop editing and save changes
    edit.stopEditing(True)

def CheckInputs(GisRow, ExcelRow, Cursor):
    '''
    Function that checks the EIO column in each row of the Excel to make sure
    that there are mo illegal characters.  Rows with illegal characters are skipped.
    Rows that pass are sent to the Compare EIO function.
    '''
    # Exclude illegal characters
    if ExcelRow[0] == 'None' or GisRow[0] == 'None' or ExcelRow[0] == '' or GisRow[0] == '':
        pass
    elif 'C' in ExcelRow[0]:
        pass
    elif 'C' in GisRow[0]:
        pass
    else:
        CompareEIO(GisRow, ExcelRow, Cursor)

def CompareEIO(GisRow, ExcelRow, Cursor):
    '''
    Any Excel rows that reach this point have their EIO value compared to
    the EIO value of the accompanying GIS row.  If the values don't match
    the row is skipped. Then if they do match the list pair moves to the
    Compare Entire Row function.
    '''
    # Convert EIO numbers to int to allow for comparison
    # Had issues with int value from Excel not equaling str in GIS
    IntExcelRow = int(ExcelRow[0])
    IntGisRow = int(GisRow[0])
    if IntExcelRow == IntGisRow:
        CompareEntireRow(GisRow, ExcelRow, Cursor)
    # If the values don't match then do nothing
    else:
        pass

def CompareEntireRow(GisRow, ExcelRow, Cursor):
    '''
    Last function to compare GIS to Excel row.  Entries that get here will have
    mtaching EIO values, so the final step is to compare the entire row.  If
    rows match then they are skipped, on the other hand if they differ then a
    temporary row will be returned.  For both the location and description tables
    these rows will be used to update the existing GIS row. *This may change for
    locations in the future.
    '''
    # Create a temporary list for each Excel row that gets here
    TempRow = []
    Count = 0
    # Convert EIO to string to allow for complete comparison
    for Attribute in ExcelRow:
        # Covert only EIO number to string
        if Count == 0:
            TempRow.append(str(Attribute))
            Count = Count + 1
        # Append all other values as is
        else:
            TempRow.append(Attribute)
            Count = Count + 1
    # If there are no differences then do nothing
    if TempRow == GisRow:
        pass
    # If an entry does exist but there are differences than update
    else:
        UpdateRows(GisRow, TempRow, Cursor)

def UpdateRows(GisRow, UpdatedRow, Cursor):
    '''
    Updates any GIS rows with changes that were made in OASIS.  This is done for
    both the description and location tables.
    '''
    Count = 0
    while Count < 6:
        GisRow[Count] = UpdatedRow[Count]
        Count = Count + 1
    Cursor.updateRow(GisRow)
    print UpdatedRow

if __name__ == "__main__":
    main(OutputExcelTable, DescriptionFieldsExcel, LocationFieldsExcel, DescriptionTable, DescriptionFields, LocationTable, LocationFields)

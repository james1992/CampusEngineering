############################################################################# 
### Author: Jay Dahlstrom
### Entity: Campus Engineering, University of Washington
### Python Version: 2.7.8
### Date Created: June 17, 2015
### Last Modified Date: August 8, 2015
###

############################################################################# 
### Description: This script needs to be run after the Equipment Adds table,
### this is because it relies upon the outputs of that script such as the ESRI
### table that is create from the master excel file.  The purpose of this script 
### is to update any rows that have been changed in the Excel, for example the room
### number of an asset has been changed.  Any rows that are new or have not
### changed are skipped.  For the location information any old records are kept
### for historical purposes, their status is changed from 'CURRENT' to 'HISTORICAL'
### this will allow management to better track how asset locations and custodians
### have changed over time.
###
### Note: The equipment removal script needs to be run following this script.
###


############################################################################# 
### Libraries
###

import arcpy
import EquipmentInventoryAdditions

############################################################################# 
### Parameters
###

# Location of the ESRI table created in the Additions script
OutputExcelTable = r"C:\Users\jamesd26\Desktop\Temp\zEquipmentInventory.gdb\EIO"

# Fields to be extracted from Excel table for equipment descriptions 
DescriptionFieldsExcel = ['Asset', 'Description', 'Manufacturer', 'Model', 'Serial', 'Budget']

# Fields to be extracted from Excel table for equipment locations
LocationFieldsExcel = ['Asset', 'Building', 'Wing', 'Room', 'Other_Loc', 'Custodian']

# Equipment description table in SQL Server, used for web map
DescriptionTable = r"Database Connections\IAMUW_REPLICATION.sde\CEO_EQUIPMENT_INVENTORY_AUX"

# Field names used in the Description table in SQL Server
DescriptionFields = ['EIO', 'EQUIPMENT_DESCRIPTION', 'MANUFACTURE', 'MODEL', 'SERIAL_NUMBER', 'BUDGET_NUMBER']

# Equipment location table in SQL Server, used for web map
LocationTable = r"Database Connections\IAMUW_REPLICATION.sde\CEO_EQUIPMENT_INVENTORY_AUX_LOCATION"

# Field names used in the Location table in SQL Server
LocationFields = ['EIO', 'FACNAME', 'WING', 'ROOM_NUMBER', 'LOCATION_DESCRIPTION', 'CUSTODIAN', 'LOCATION_STATUS']


#############################################################################  
###Script Follows
###

def main(ExcelTable, InputDescriptionFields, InputLocationFields, AuxTable, AuxFields, AuxLocationTable, AuxLocationFields):
    # Use function from the EquipmentInventoryAdditions file to extract equipment description values from Excel Table
    DescriptionRows = EquipmentInventoryAdditions.ExtractEquipmentDescription(ExcelTable, InputDescriptionFields)
    
    # Use function from the EquipmentInventoryAdditions file to extract equipment location values from Excel Table
    LocationRows = EquipmentInventoryAdditions.ExtractEquipmentLocationInformation(ExcelTable, InputLocationFields)
    
    # Update any rows with changes in the description table (AUX)
    UpdateExistingRows(AuxTable, AuxFields, DescriptionRows)
    
    # Use function from the EquipmentInventoryAdditions file to extract existing equipment location values, these will
    # be used to compare existing values to those in the updated Excel.
    ExistingLocationRows = EquipmentInventoryAdditions.ExtractEquipmentLocationInformation(AuxLocationTable, AuxLocationFields)
    
    # Insert new rows if asset location attributes have changed in the Excel
    InsertAdditionalRows(AuxLocationTable, AuxLocationFields, LocationRows, ExistingLocationRows)
    
def UpdateExistingRows(Table, Fields, DescriptionExcelList):
    ''' 
    This function takes the table in SQL Server that stores the
    descriptive information about the equipment, the fields in that
    table and a list from the master excel with the descriptive
    information.  It then updates any existing rows that have been
    altered in the Excel.
    '''
    # Initialize editing environment
    edit = arcpy.da.Editor(r"Database Connections\IAMUW_REPLICATION.sde")
    edit.startEditing(False, True)
    edit.startOperation()
    with arcpy.da.UpdateCursor(Table, Fields) as Cursor:
        for Row in Cursor:
            for Item in DescriptionExcelList:
                # Convert EIO numbers to int to allow for comparison
                # Had issues with int value from table not equally int from list
                if Row[0] == 'None' or Row[0] == '':
                    pass
                elif 'C' in Row[0]:
                    pass
                else:
                    IntItem = int(Item[0])
                    IntRow = int(Row[0])
                    if IntRow == IntItem:
                        # Create a temporary list for each row that gets here
                        TempRow = []
                        Count = 0
                        # Convert EIO to string to allow complete comparison
                        for Attribute in Item:
                            if Count == 0:
                                TempRow.append(str(Attribute))
                                Count = Count + 1
                            else:
                                TempRow.append(Attribute)
                                Count = Count + 1
                        # If there are no differences then do nothing
                        if TempRow == Row:
                            pass
                        # If an entry does exist but there are differences than update
                        else:
                            Count = 0
                            while Count < 6:
                                Row[Count] = TempRow[Count]
                                print Row[Count]
                                Count = Count + 1
                            Cursor.updateRow(Row)
                            print TempRow
                    # If there is not an existing entry then do nothing
                    else:
                        pass
    del Row
    del Cursor
    edit.stopOperation()
    # Stop editing and save changes
    edit.stopEditing(True)


def InsertAdditionalRows(Table, Fields, LocationExcelList, ExistingLocationsList):
    '''
    Function that takes the equipment location table in SQL Server along with
    the fields in that table, the location information from the master excel and
    what locations already exist in the database.  If the entry for a given EIO
    in the database does not match what is in the Excel then a new row is added
    with the information from the Excel.  This will provide a location history.
    '''
    # Initialize editing environment
    edit = arcpy.da.Editor(r"Database Connections\IAMUW_REPLICATION.sde")
    edit.startEditing(False, True)
    edit.startOperation()
    with arcpy.da.InsertCursor(Table, Fields) as Cursor:
        for Entry in LocationExcelList:
            for Item in ExistingLocationsList:
                # Convert EIO numbers to int to allow for comparison
                # Had issues with int value from table not equally int from list
                if Item[0] == 'None' or Item[0] == '':
                    pass
                elif 'C' in Item[0]:
                    pass
                else:
                    IntEntry = int(Entry[0])
                    IntItem = int(Item[0])
                    if IntEntry == IntItem:
                        # Create a temporary list for each row that gets here
                        TempRow = []
                        Count = 0
                        # Convert EIO to string to allow complete comparison
                        for Attribute in Entry:
                            if Count == 0:
                                TempRow.append(str(Attribute))
                                Count = Count + 1
                            else:
                                TempRow.append(Attribute)
                                Count = Count + 1
                        # If there are no differences then do nothing
                        if TempRow == Item:
                            pass
                        # If an entry does exist but there are differences than update
                        else:
                            Cursor.insertRow(TempRow)
                            print TempRow
                    # If there is not an existing entry then do nothing
                    else:
                        pass            
    edit.stopOperation()
    # Stop editing and save changes
    edit.stopEditing(True)


if __name__ == "__main__":
    main(OutputExcelTable, DescriptionFieldsExcel, LocationFieldsExcel, DescriptionTable, DescriptionFields, LocationTable, LocationFields)

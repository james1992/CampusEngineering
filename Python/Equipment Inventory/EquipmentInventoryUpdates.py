############################################################################# 
### Jay Dahlstrom
### Campus Engineering, University of Washington
### June 17, 2015
###

############################################################################# 
### Description: This script takes the Master Equipment Excel that is updated
### by Michael Flanagan and coverts the Excel into an ESRI table.  With the 
### ESRI table the script is able to extract all of the entries and place them
### into the relevent tables in SQL Server.  The purpose of this script is to
### update any rows that have been changed in the Excel, for example the room
### number has been changed.  Any rows that are new or have not changed are
### skipped.
###


############################################################################# 
### Libraries
###

import arcpy
import EquipmentInventoryAdditions

############################################################################# 
### Parameters
###

OutputExcelTable = r"C:\Users\jamesd26\Desktop\Temp\zEquipmentInventory.gdb\EIO"
DescriptionFieldsExcel = ["Inventory_Tag__", "Equipment_Description", "Manufacturer", "Model", "Serial__", "Budget"]
LocationFieldsExcel = ["Inventory_Tag__", "Building", "Wing", "Room", "Other_Location", "Current_Custodian"]
DescriptionTable = r"Database Connections\IAMUW_REPLICATION.sde\CEO_EQUIPMENT_INVENTORY_AUX"
DescriptionFields = ["EIO", "EQUIPMENT_DESCRIPTION", "MANUFACTURE", "MODEL", "SERIAL_NUMBER", "BUDGET_NUMBER"]
LocationTable = r"Database Connections\IAMUW_REPLICATION.sde\CEO_EQUIPMENT_INVENTORY_AUX_LOCATION"
LocationFields = ["EIO", "FACNAME", "WING", "ROOM_NUMBER", "LOCATION_DESCRIPTION", "CUSTODIAN"]


#############################################################################  
###Script Follows
###

def main(ExcelTable, InputDescriptionFields, InputLocationFields, AuxTable, AuxFields, AuxLocationTable, AuxLocationFields):
    # Use function from the EquipmentInventoryAdditions file to extract equipment description values from Excel Table
    DescriptionRows = EquipmentInventoryAdditions.ExtractEquipmentDescription(ExcelTable, InputDescriptionFields)
    # Use function from the EquipmentInventoryAdditions file to extract equipment location values from Excel Table
    LocationRows = EquipmentInventoryAdditions.ExtractEquipmentLocationInformation(ExcelTable, InputLocationFields)
    # Update any rows with changes in the description table (aux)
    UpdateExistingRows(AuxTable, AuxFields, DescriptionRows)
    # Use function from the EquipmentInventoryAdditions file to extract existing equipment location values
    ExistingLocationRows = EquipmentInventoryAdditions.ExtractEquipmentLocationInformation(AuxLocationTable, AuxLocationFields)
    # Insert new rows if asset location changed
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

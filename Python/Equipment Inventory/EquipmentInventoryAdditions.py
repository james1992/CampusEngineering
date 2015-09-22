############################################################################# 
### Author: Jay Dahlstrom
### Entity: Campus Engineering, University of Washington
### Python Version: 2.7.8
### Date Created: June 9, 2015
### Last Modified Date: September 21, 2015
### 

############################################################################# 
### Description: This script takes the Master  Equipment Excel file that
### is updated by Michael Flanagan and converts it first to an ESRI table.
### With that table the script is then able to extract the entries and place them 
### into the relevent tables in SQL which power web maps.  If the piece of 
### equipment already has an entry in GIS then it skipped by this procedure.
### The function is run after an an alert is sent from SharePoint that
### the document has been updated.
###
### Note: The equipment updates script should be run following this script
###

############################################################################# 
### Libraries
###

import arcpy

############################################################################# 
### Parameters
###

# Location of SQL Tables
Workspace = r"Database Connections\IAMUW_REPLICATION.sde"

# Location of Master Excel file
Excel = r"C:\Users\jamesd26\Desktop\TEST\SharePoint\Michael Flanagan\EIO MASTER\EIO MASTER.xlsx"

# Sheet to be used in Excel file
Sheet = "Sheet1"

# Temporary table to be created from Excel File
OutputExcelTable = r"C:\Users\jamesd26\Desktop\Domain Updates\zEquipmentInventory.gdb\EIO"

# Fields to be extracted from Excel table for equipment descriptions
DescriptionFieldInputs = ["Asset", "Description", "Manufacturer", "Model", "Serial_", "Budget"]

# Equipment description table in SQL Server, used for web map
DescriptionTable = r"Database Connections\IAMUW_REPLICATION.sde\CEO_EQUIPMENT_INVENTORY_AUX"

# Fields to be extracted from Excel table for equipment locations
LocationFieldInputs = ["Asset", "Building", "Wing", "Room", "Other_Loc", "Custodian"]

# Equipment location table in SQL Server, used for web map
LocationTable = r"Database Connections\IAMUW_REPLICATION.sde\CEO_EQUIPMENT_INVENTORY_AUX_LOCATION"

#############################################################################  
###Script Follows
###

def main(ProductionWorkspace, ExcelDoc, ExcelSheet, OutputTable, DescriptionFields, EquipmentDescriptionTable, LocationFields, EquipmentLocationTable):
    print 'First I will add any new pieces of equipment.  Here are the rows that have been added:'

    # Create table from Excel
    ExcelToTable(ExcelDoc, ExcelSheet, OutputTable)

    # Extract description information from table
    EquipmentDescriptionList = ExtractEquipmentDescription(OutputTable, DescriptionFields)

    # Insert description data into production SQL table
    InsertEquipmentDescription(ProductionWorkspace, EquipmentDescriptionTable, EquipmentDescriptionList)

    # Extract location information from table
    EquipmentLocationList = ExtractEquipmentLocationInformation(OutputTable, LocationFields)

    # Insert location data into production SQL table
    InsertEquipmentLocationInformation(ProductionWorkspace, EquipmentLocationTable, EquipmentLocationList)

def ExcelToTable(ExcelFile, SheetName, TableName):
    '''
    Function that takes an Excel File and a Sheet Name and
    transforms that sheet into an ESRI table.  All variables
    should be string. Note: Sheet must be setup with one top
    row for column names and then the rest should be rows
    containing data.
    '''
    # Location of File GDB
    arcpy.env.workspace = r"C:\Users\jamesd26\Desktop\Domain Updates\zEquipmentInventory.gdb"
    #Remove existing table
    arcpy.env.overwriteOutput = True
    arcpy.ExcelToTable_conversion(ExcelFile, TableName, SheetName)

def IdentifyExistingEquipment(InputTable):
    '''
    Given an input table this function iterates through each
    row and grabs each EIO number and returns them
    as a list.  This is used to check if a record for that
    equipment already exists.
    '''
    EioList = []
    with arcpy.da.SearchCursor(InputTable, ['EIO']) as cursor:
        for row in cursor:
            EioList.append(row[0])
    del cursor
    return EioList

def ExtractEquipmentDescription(TableName, FieldNames):
    '''
    Function that given a table and a list of columns (as string)
    iterates through each row of the table and puts those
    values into a nested list.  That nested list is returned.
    The function is used on the ESRI table that was created
    in the Excel To Table function for description data.
    '''
    EquipmentList = []
    with arcpy.da.SearchCursor(TableName, FieldNames) as cursor:
        for row in cursor:
            # Remove the '-' from budget numbers, needed for issue when exporting to Excel
            BudgetNumber = row[5].replace('-', '')
            # Create nested lists for each row
            EquipmentList.append([row[0], row[1], row[2], row[3], row[4], BudgetNumber])
    del cursor
    return EquipmentList

def InsertEquipmentDescription(Workspace, DescriptionTable, EquipmentDescriptionList):
    '''
    Function takes any newly added pieces of equipment and adds
    an entry to the equipment description table.  If a record for
    that piece of equipment already exists then that row is
    skipped.
    '''
    ExistingDescriptions = IdentifyExistingEquipment(r"Database Connections\IAMUW_REPLICATION.sde\CEO_EQUIPMENT_INVENTORY_AUX")
    # Set editing environment for versioned table
    edit = arcpy.da.Editor(Workspace)
    edit.startEditing(False, True)
    edit.startOperation()
    with arcpy.da.InsertCursor(DescriptionTable, ('EIO', 'EQUIPMENT_DESCRIPTION', 'MANUFACTURE', 'MODEL', 'SERIAL_NUMBER', 'BUDGET_NUMBER')) as DescriptionInsert:
        for entry in EquipmentDescriptionList:
            print entry
            # If equipment is already inventoried then skip
            if str(entry[0]) in ExistingDescriptions:
                pass
            else:
                print entry
                DescriptionInsert.insertRow(entry)
    edit.stopOperation()
    # Stop editing and save edits
    edit.stopEditing(True)

def ExtractEquipmentLocationInformation(TableName, FieldNames):
    '''
    Function that given a table and a list of columns (as string)
    iterates through each row of the table and puts those
    values into a nested list.  That nested list is returned.
    The function is used on the ESRI table that was created
    in the Excel To Table function for location data.
    '''
    EquipmentLocationList = []
    with arcpy.da.SearchCursor(TableName, FieldNames) as cursor:
        for row in cursor:
            # Create nested lists for each row, add entry status that 'CURRENT' for status for view
            EquipmentLocationList.append([row[0], row[1], row[2], row[3], row[4], row[5]])
    del row
    del cursor
    return EquipmentLocationList

def InsertEquipmentLocationInformation(Workspace, LocationTable, EquipmentLocationList):
    '''
    Function takes any newly added pieces of equipment and adds
    an entry to the equipment location table.  If a record for
    that piece of equipment already exists then that row is
    skipped.
    '''
    ExistingEquipment = IdentifyExistingEquipment(r"Database Connections\IAMUW_REPLICATION.sde\CEO_EQUIPMENT_INVENTORY_AUX_LOCATION")
    # Set editing environment for versioned table
    edit = arcpy.da.Editor(Workspace)
    edit.startEditing(False, True)
    edit.startOperation()
    with arcpy.da.InsertCursor(LocationTable, ('EIO', 'FACNAME', 'WING', 'ROOM_NUMBER', 'LOCATION_DESCRIPTION', 'CUSTODIAN', 'LOCATION_STATUS')) as DescriptionInsert:
        for entry in EquipmentLocationList:
            if str(entry[0]) in ExistingEquipment:
                # If equipment is already inventoried then skip
                pass
            else:
                DescriptionInsert.insertRow(entry)
    edit.stopOperation()
    # Stop editing and save edits
    edit.stopEditing(True)

	
if __name__ == "__main__":
    main(Workspace, Excel, Sheet, OutputExcelTable, DescriptionFieldInputs, DescriptionTable, LocationFieldInputs, LocationTable)

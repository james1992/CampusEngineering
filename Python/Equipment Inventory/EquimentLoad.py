############################################################################# 
### Author: Jay Dahlstrom
### Entity: Engineering Services, University of Washington
### Python Version: 2.7.8
### Date Created: May 2, 2018
###

############################################################################# 
### Description: This scripts takes an input CSV that contais asset information
### for the EIO project from the OASIS database.  The table must be a CSV not 
### XLS.  The data is loaded into the EquipmentInventoryExcelLoad table to create
### a GIS copy of the data that does not impact the core data and it allows the
### the script to update the Load Status field to identify which equipment is in
### GIS and was updated and what equipment is not yet in GIS.  The script also
### update equipment no longer in the OASIS database by setting the feature status
### to inactive.
###

############################################################################# 
### Libraries
###

import arcpy
import csv
import datetime

############################################################################# 
### Parameters
###

CSV = r"C:\Users\jamesd26.NETID\Downloads\OASIS.csv"

ExcelLoadTable = r"Database Connections\FacilitiesServices.sde\EquipmentInventoryExcelLoad"
ExcelLoadAttributes = ["AssetTag","OldAssetTag","Description","Manufacturer","Model","SerialNumber","Custodian","Building","Wing","Room","OtherLocation","Budget","DateReceived"]

EquipmentFeatureClass = r"Database Connections\FacilitiesServices.sde\EquipmentInventory"
EquipmentFeatureClassAttributes = ["AssetTag","Description","Manufacturer","Model","SerialNumber","Custodian","Building","Wing","Room","OtherLocation","Budget","DateReceived", "FeatureStatus"]

#############################################################################  
### Script Follows
### 

def main(CSVFile, ExcelLoadTable, ExcelLoadAttributes, EquipmentFeatureClass, EquipmentFeatureClassAttributes):
    # Grab the CSV data and load it into a list
    CSVData = ExtractCSVData(CSVFile)
    # Create a list of existing equipment IDs
    ExistingAssetTags = EquipmentSearchCursor(EquipmentFeatureClass)
    # Update the existing equipment information in GIS and return a list of the equipment that was updated
    AssetUpdates = EquipmentInventoryUpdates(EquipmentFeatureClass, EquipmentFeatureClassAttributes, CSVData, ExistingAssetTags)
    # Load data into the Excel Load table and set the load status
    ExcelLoadInsertCursor(ExcelLoadTable, ExcelLoadAttributes, CSVData)
    UpdateExcelLoadTable(ExcelLoadTable, AssetUpdates)

def ExtractCSVData(CSVFile):
    '''
    Function that extracts EIO data from the OASIS CSV file.  The function
    requires the path to the CSV file as an input and returns the extracted
    data in the form of a nested list.
    '''
    data = []
    count = 0
    with open(CSVFile, 'rb') as csvfile:
        EIO = csv.reader(csvfile, delimiter=',')
        for row in EIO:
            # Ignore the header row
            if count == 0:
                pass
            else:
                # Return the data in the order to match output tables
                data.append([row[0], row[20], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[13], row[15]])
            count += 1
    return data

def EquipmentSearchCursor(FC):
    '''
    Function that searches through the Equipment Inventory feature class and pulls out
    all of the active asset tags currently in the database.  The function requires the
    path to the feature class as an input and return a list of all asset tags #
    currently in GIS that have a feature status of "Active".
    '''
    AssetTags = []
    with arcpy.da.SearchCursor(FC, ["AssetTag", "FeatureStatus"]) as cursor:
        for row in cursor:
            # Only return tags that are active
            if row[1] == "Active":
                AssetTags.append(row[0])
    return AssetTags


def EquipmentInventoryUpdates(EquipmentFC, EquipmentFields, CSVData, ExistingAssetTags):
    '''
    Function that updates the Equipment Inventory feature class with the new data from
    OASIS.  The function requires the the path to the feature class, the fields to be updated,
    the nested list of asset information from the CSV and a list of active asset tags from
    the Equipment Search Cursor function.  The function first updates all existing rows in GIS
    with the information from OASIS.  If a row is updated it is removed from the Existing Asset
    Tags list and added to the Asset Updates list.  Next the function initiates a new update
    cursor and sets all asset tags still in the ExistingAssetTags list and sets the feature
    status for those rows to "Inactive".  The function returns the AssetUpdates lists.
    '''
    # Record the Asset Tags that are updated through the cursor
    AssetUpdates = []
    edit = arcpy.da.Editor(r"Database Connections\FacilitiesServices.sde")
    edit.startEditing(False, True)
    edit.startOperation()

    # Update the existing rows
    with arcpy.da.UpdateCursor(EquipmentFC, EquipmentFields) as Cursor:
        for GisRow in Cursor:
            for CSVRow in CSVData:
                if GisRow[0] == CSVRow[0]:
                    count = 1
                    # Only update the specified rows from the CSV
                    while count > 12:
                        GisRow[count] = CSVRow[count + 1]
                        count = count + 1
                    Cursor.updateRow(GisRow)
                    ExistingAssetTags.remove(CSVRow[0])
                    AssetUpdates.append(CSVRow[0])
                # If a row was previously set to Inactive but is back in the OASIS Excel update the feature status back to "Active"
                if GisRow[12] == "Inactive":
                    GisRow[12] = "Active"
                    Cursor.updateRow(GisRow)
    print "Number of Tags Set to Inactive: " + len(ExistingAssetTags)
    with arcpy.da.UpdateCursor(EquipmentFC, ["AssetTag", "FeatureStatus", "FeatureStatusDate"]) as Cursor:
        for GisRow in Cursor:
            for Tag in ExistingAssetTags:
                # Set feature status to inactive if the row is still in Existing Asset Tags and date stamp the row
                if GisRow[0] == Tag:
                    GisRow[1] = "Inactive"
                    GisRow[2] = datetime.datetime.now().strftime("%y-%m-%d")
                    Cursor.updateRow(GisRow)

    edit.stopOperation()
    # Stop editing and save edits
    edit.stopEditing(True)

    return AssetUpdates

def ExcelLoadInsertCursor(FC, Fields, DataList):
    '''
    Function that takes the Excel Load table, the fields in the table and the list
    of assets pulled from the OASIS CSV and inserts the CSV data into the table.
    The function requires the path to the table, the fields to be updated and the
    nested list of OASIS assets pulled from the CSV.
    '''
    edit = arcpy.da.Editor(r"Database Connections\FacilitiesServices.sde")
    edit.startEditing(False, True)
    edit.startOperation()

    # Remove existing rows to create blank slate    
    with arcpy.da.UpdateCursor(FC, Fields) as DataRemoval:
        for row in DataRemoval:
            DataRemoval.deleteRow()
    del DataRemoval

    # Insert the OASIS data from the current pull
    with arcpy.da.InsertCursor(FC, Fields) as DataInsert:
        for item in DataList:
            DataInsert.insertRow(item)
    del DataInsert

    edit.stopOperation()
    # Stop editing and save edits
    edit.stopEditing(True)

def UpdateExcelLoadTable(FC, AssetUpdates):
    '''
    Function that updates the newly loaded data in the Excel Load data table with
    the status of the script in updating the rows in the Equipment Inventory feature
    class.  If the row exists in the feature class then the corresponding row in
    Excel Load is set to "Update" in Load Status.  If the Asset is not currently in
    the feature class then "Not in GIS" is inserted into Load Status.
    '''
    edit = arcpy.da.Editor(r"Database Connections\FacilitiesServices.sde")
    edit.startEditing(False, True)
    edit.startOperation()

    # Remove existing rows to create blank slate    
    with arcpy.da.UpdateCursor(FC, ["AssetTag", "LoadStatus"]) as DataUpdates:
        for row in DataUpdates:
            for asset in AssetUpdates:
                if row[0] == asset:
                    row[1] = "Update"
                    DataUpdates.updateRow(row)                  

    with arcpy.da.UpdateCursor(FC, ["AssetTag", "LoadStatus"]) as DataUpdates:
        for row in DataUpdates:
            if row[1] <> "Update":
                row[1] = "Not in GIS"
                DataUpdates.updateRow(row) 

    edit.stopOperation()
    # Stop editing and save edits
    edit.stopEditing(True)


if __name__ == "__main__":
    main(CSV, ExcelLoadTable, ExcelLoadAttributes, EquipmentFeatureClass, EquipmentFeatureClassAttributes)

############################################################################# 
### Jay Dahlstrom
### Engineering Services, University of Washington
### Created: May 19, 2017
### Modified: May 28, 2019
### 

############################################################################# 
### Description: Script that works with the confidence test data to take the
### documents that the technicians attached to the GIS testing record.  This 
### script simplifies the process for the technicians to record their work
### and ensures that a standard filing structure will be utilized on SharePoint.

############################################################################# 
### Libraries
###

import os
import arcpy

############################################################################# 
### Parameters
###

# File path to attachment table (typically in Geodatabase)
# Don't forget to put 'r' before file paths
ImageTable          = r'Database Connections\CampusEngineeringOperations.sde\ConfidenceTestsInspections__ATTACH'
# The Blob field that contains the attachment information
ImageDataField      = "DATA"
# The field that contains the attachment name
ImageNameField      = "ATT_NAME"
# Field that contains the GlobalID for the related inspection record
ImageRelationalIDField = 'REL_GLOBALID'
# Table that contains the specific test data (used to link back to system information in the point feature class)
AuxTable            = r'Database Connections\CampusEngineeringOperations.sde\ConfidenceTestsInspections'
AuxAttributes       = ['GlobalID', 'REL_GlobalID']
# Feature class that contains information on system that was tested
GeomTable           = r'Database Connections\CampusEngineeringOperations.sde\ConfidenceTests'
GeomAttributes      = ['GlobalID', 'FacNum']
# Folder where attachments will be saved, need to create first
OutputFolder        = r'C:\Users\Administrator\UW\Confidence Tests - Confidence Tests'

#############################################################################  
###Script Follows
###

def main(TableLocation, ImageDataField, ImageNameField, ImageRelationalIDField, AuxTable, AuxAttributes, GeomTable, GeomAttributes, OutputFolder):
    print OutputFolder
    SearchCursor(ImageTable, ImageDataField, ImageNameField, ImageRelationalIDField, AuxTable, AuxAttributes, GeomTable, GeomAttributes, OutputFolder)
    DeleteAttachments(TableLocation)

def SearchCursor(TableLocation, BlobData, ImageName, GeomOID, AuxTable, AuxAttributes, GeomTable, GeomAttributes, FolderLocation):
    '''
    Function that takes the three tables (images, inspection and geometry) and extracts the image
    BLOB data, associates that data with the building FacNum and finally passes the file name,
    BLOB Data, FacNum and output folder to the file creator function.
    '''
    # Initial list to hold the FacNum and GlobalID for each system
    GeomList = []
    with arcpy.da.SearchCursor(GeomTable, GeomAttributes) as cursor:
        for row in cursor:
            GeomList.append([row[0], row[1]])
                            
    # Remove schema lock on table
    del row
    del cursor

    # Second list to hold the FacNum (from geom table) and GlobalID (from aux table)
    AuxList = []
    with arcpy.da.SearchCursor(AuxTable, AuxAttributes) as cursor:
        for row in cursor:
            for geom in GeomList:
                # If the GlobalID matches the REL_GUID
                if geom[0] == row[1]:
                    AuxList.append([row[0], geom[1]])
    # Remove schema lock on table
    del row
    del cursor
    
    with arcpy.da.SearchCursor(TableLocation, [GeomOID, ImageName, BlobData]) as cursor:
        for row in cursor:
            for data in AuxList:
                # If the GlobalID matches the REL_GlobalID
                if data[0] == row[0]:
                    FileName = row[1]
                    BinaryData = row[2]
                    FacNum = data[1]
                    # Call the File creator with each iteration
                    FileCreator(FileName, BinaryData, FacNum, FolderLocation)   
    # Remove schema lock on table
    del cursor

def FileCreator(AttachmentName, BinaryInfo, FacNum, FolderLocation):
    '''
    The second function takes the name of an attachment, it's BLOB data, a FacNum, the test system
    and folder location and converts the BLOB data into a file in the appropriate folder.
    The output folder is determined by the FacNum and System that is passed to the function.
    '''
    # Extract all of the sub folders in the directory
    BuildingFolders = [ name for name in os.listdir(FolderLocation) if os.path.isdir(os.path.join(FolderLocation, name)) ]
    for Folder in BuildingFolders:
        # Split the FacNum and FacName for comparison
        SplitFolder = Folder.split('-')
        # If the FacNums match
        if FacNum == SplitFolder[1]:
            print AttachmentName
            DocumentPath = os.path.join(FolderLocation, Folder, 'Annual')
            Files = os.listdir(DocumentPath)
            if AttachmentName in Files:
                UpdateAttachmentRecords(TableLocation, 'Duplicate', AttachmentName)
            else:
                open(DocumentPath + os.sep + AttachmentName, 'wb').write(BinaryInfo.tobytes())
                UpdateAttachmentRecords(TableLocation, 'Yes', AttachmentName)

def UpdateAttachmentRecords(TableLocation, Setting, AttachmentName):
    '''
    For an extra layer of data validation, this function updates the Migrated column in the
    ConfidenceTestsInspections__ATTACH table to read either Yes or Duplicate from the default
    value of No.  This function is only called from within FileCreator and takes the
    attachment table location, update value (Yes or Duplicate) and attachment name as inputs.
    '''
    with arcpy.da.UpdateCursor(TableLocation, ["ATT_NAME", "Migrated"]) as cursor:
        for row in cursor:
            if row[0] == AttachmentName:
                row[1] = Setting
            cursor.updateRow(row)

def DeleteAttachments(TableLocation):
    '''
    The final function in this script deletes the GIS copy of the PDF for all documents that were
    copied to SharePoint. This way there is only one copy of each document for retention purposes.
    Any PDFs in GIS with a value in the Migrated column of No or Duplicate are not deleted.
    '''
    edit = arcpy.da.Editor(r"Database Connections\CampusEngineeringOperations.sde")
    edit.startEditing(False, True)
    edit.startOperation()
    
    with arcpy.da.UpdateCursor(TableLocation, ["ATT_NAME", "Migrated"]) as cursor:
        for row in cursor:
            if row[1] == 'Yes':
                cursor.deleteRow()
            else:
                pass

    edit.stopOperation()
    # Stop editing and save edits
    edit.stopEditing(True)
	
if __name__ == "__main__":
    main(ImageTable, ImageDataField, ImageNameField, ImageRelationalIDField, AuxTable, AuxAttributes, GeomTable, GeomAttributes, OutputFolder)

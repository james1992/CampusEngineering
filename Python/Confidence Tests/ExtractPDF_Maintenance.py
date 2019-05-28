############################################################################# 
### Jay Dahlstrom
### Engineering Services, University of Washington
### May 19, 2017
###

############################################################################# 
### Description: Script that works with the confidence test data to take the
### documents that the technicians attached to the GIS testing record.  This 
### script simplifies the process for the technicians to record their work
### and ensures that a standard naming convention will be utilized on SharePoint.

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
ImageTable          = r'Database Connections\CampusEngineeringOperations.sde\ConfidenceTestsMaintenance__ATTACH'
# The Blob field that contains the attachment information
ImageDataField      = "DATA"
# The field that contains the attachment name
ImageNameField      = "ATT_NAME"
# Field that contains the OID of related geometry
ImageRelationalOIDField = 'REL_GLOBALID'
# Table that contains the specific test data (used to link back to system in Geom)
AuxTable            = r'Database Connections\CampusEngineeringOperations.sde\ConfidenceTestsMaintenance'
AuxAttributes       = ['GlobalID', 'REL_GlobalID']
# Feature class that contains information on system that was tested
GeomTable           = r'Database Connections\CampusEngineeringOperations.sde\ConfidenceTests'
GeomAttributes      = ['GlobalID', 'FacNum', 'System']
# Folder where attachments will be saved, need to create first
OutputFolder        = r'C:\Users\Administrator\UW\Confidence Tests - Confidence Tests'

#############################################################################  
###Script Follows
###

def main(TableLocation, ImageDataField, ImageNameField, ImageRelationalOIDField, AuxTable, AuxAttributes, GeomTable, GeomAttributes, OutputFolder):
    print OutputFolder
    SearchCursor(ImageTable, ImageDataField, ImageNameField, ImageRelationalOIDField, AuxTable, AuxAttributes, GeomTable, GeomAttributes, OutputFolder)
    DeleteAttachments(TableLocation)

def SearchCursor(TableLocation, BlobData, ImageName, GeomOID, AuxTable, AuxAttributes, GeomTable, GeomAttributes, FolderLocation):
    '''
    Function that takes the three tables (images, aux and geom) and extracts the image
    BLOB data, associates that data with the building FacNum and finally passes the file name,
    BLOB Data, FacNum and output folder to the file creator function.
    '''
    # Initial list to hold the FacNum and GlobalID for each system
    GeomList = []
    with arcpy.da.SearchCursor(GeomTable, GeomAttributes) as cursor:
        for row in cursor:
            GeomList.append([row[0], row[1], row[2]])
                            
    # Remove schema lock on table
    del row
    del cursor
    
    # Second list to hold the FacNum (from geom table) and OID (from aux table)
    AuxList = []
    with arcpy.da.SearchCursor(AuxTable, AuxAttributes) as cursor:
        for row in cursor:
            for geom in GeomList:
                # If the GlobalID matches the REL_GUID
                if geom[0] == row[1]:
                    AuxList.append([row[0], geom[1], geom[2]])
    # Remove schema lock on table
    del row
    del cursor
    
    cursor = arcpy.da.SearchCursor(TableLocation, [GeomOID, ImageName, BlobData])
    for row in cursor:
        for data in AuxList:
            # If the OID matches the REL_OBJECTID
            if data[0] == row[0]:
                FileName = row[1]
                BinaryData = row[2]
                FacNum = data[1]
                System = data[2]
                # Call the File creator with each iteration
                FileCreator(FileName, BinaryData, FacNum, System, FolderLocation) 
    # Remove schema lock on table
    del cursor

def FileCreator(AttachmentName, BinaryInfo, FacNum, System, FolderLocation):
    '''
    The second function takes the name of an attachment, it's BLOB data, a FacNum and folder
    location and converts the BLOB data into a file in the appropriate folder.  The output folder
    is determined by the FacNum that is passed to the function.
    '''
    # Extract all of the sub folders in the directory
    BuildingFolders = [ name for name in os.listdir(FolderLocation) if os.path.isdir(os.path.join(FolderLocation, name)) ]
    for Folder in BuildingFolders:
        # Split the FacNum and FacName for comparison
        SplitFolder = Folder.split('-')
        # If the FacNums match
        if FacNum == SplitFolder[1]:
            print AttachmentName
            if System == 'Dry Sprinkler' or System == 'Wet Sprinkler':
                DocumentPath = os.path.join(FolderLocation, Folder, 'Sprinkler')
            if System == 'Dry Standpipe' or System == 'Wet Standpipe':
                DocumentPath = os.path.join(FolderLocation, Folder, 'Stand Pipe')
            Files = os.listdir(DocumentPath)
            if AttachmentName in Files:
                pass
            else:
                open(DocumentPath + os.sep + AttachmentName, 'wb').write(BinaryInfo.tobytes())

def DeleteAttachments(TableLocation):
    '''
    The final function in this script deletes the GIS copy of the PDF from the database.
    This way there is only one copy of each document for retention purposes.  This function
    only runs after the documents are successfully copied to Office 365
    '''
    edit = arcpy.da.Editor(r"Database Connections\CampusEngineeringOperations.sde")
    edit.startEditing(False, True)
    edit.startOperation()

    with arcpy.da.UpdateCursor(TableLocation, ["ATT_NAME"]) as cursor:
        for row in cursor:
            cursor.deleteRow()

    edit.stopOperation()
    # Stop editing and save edits
    edit.stopEditing(True)
	
if __name__ == "__main__":
    main(ImageTable, ImageDataField, ImageNameField, ImageRelationalOIDField, AuxTable, AuxAttributes, GeomTable, GeomAttributes, OutputFolder)

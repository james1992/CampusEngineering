############################################################################# 
### Jay Dahlstrom
### Engineering Services, University of Washington
### Created: March 17, 2017
### Updated: January 14, 2019
###

############################################################################# 
### Description: This script takes the landscape evaluation information from the editable
### feature class and tables and condenses it into a single feature class that
### contains all of the information pertaining to completed evaluations.  This new
### feature class is used in the landscape evaluation map service.
###
### In the past spatial views were used to create these services but performance
### was poor and it was impossible to include attachments.  This script resolves
### those two issues but requires a manual update process.
### 

############################################################################# 
### Libraries
###

import os
from os import listdir
from os.path import join
import arcpy
from arcpy import env
import shutil

############################################################################# 
### Parameters
###

# Spatial view that contains all of the attributes to be copied.
# Don't forget to put 'r' before file paths
LandscapeEvaluationView = r"Database Connections\FacilitiesMaintenance.sde\ViewGroundsLandscapeEvaluations"
LandscapeEvaluationViewFields = ["GroundsMaintenanceZone", "GroundsMaintenanceLevel", "Reviewer", "REVIEWDATE", "PointsAvailable", "PointsReceived", "Percentage", "last_edited_date",
                  "WeedControl","PresenceOfLitter", "BareAreas", "Edging", "PruningComposition", "MulchConsistency", "TreeCare", "PlantDebris", "HardscapeQuality", "LawnQuality", "Notes", "GlobalID", "SHAPE@"]

# Output feature class
LandscapeEvaluationFC = r"Database Connections\FacilitiesMaintenance.sde\GroundsLandscapeEvaluationResults"
LandscapeEvaluationFCFields = ["GroundsMaintenanceZone", "GroundsMaintenanceLevel", "Reviewer", "ReviewDate", "PointsAvailable", "PointsReceived", "Percentage", "last_edited_date",
                  "WeedControl", "PresenceOfLitter", "BareAreas", "Edging", "PruningComposition", "MulchConsistency", "TreeCare", "PlantDebris", "HardscapeQuality", "LawnQuality", "Notes", "REL_GlobalID", "SHAPE@"]

# Link between GlobalID in editable table and GlobalID in landscape evaluation feature class.
# Used to link the images to the correct points since GlobalIDs cannot be copied over through a script.
LandscapeEvaluationFCFieldsGUID = ["REL_GlobalID", "GlobalID"]

# Output attachment table
LandscapeEvaluationAttachmentTable = r"Database Connections\FacilitiesMaintenance.sde\GroundsLandscapeEvaluationResults__ATTACH"
LandscapeEvaluationAttachmentField = ["REL_GLOBALID", "CONTENT_TYPE", "ATT_NAME", "DATA"]

# File path to editable attachment table
EditableLandscapeEvaluationImageTable         = r"Database Connections\FacilitiesMaintenance.sde\GroundsLandscapeEvaluations__ATTACH"
# The Blob field that contains the attachment information
EditableLandscapeEvaluationImageDataField     = "DATA"
# The field that contains the attachment name
EditableLandscapeEvaluationImageNameField     = "ATT_NAME"
# Field that contains the Guid of related geometry
EditableLandscapeEvaluationImageRelationalGuidField = "REL_GLOBALID"

# Folder where attachments will be saved before they are loaded into new table
TempImageFolder = r"C:\Users\jamesd26\Desktop\LandscapeEvalPhotos"

############################################################################# 
### Script
###

def main(LandscapeEvaluationView, LandscapeEvaluationViewFields, LandscapeEvaluationFC, LandscapeEvaluationFCFields, LandscapeEvaluationFCFieldsGUID, LandscapeEvaluationAttachmentTable, LandscapeEvaluationAttachmentField, EditableLandscapeEvaluationImageTable, EditableLandscapeEvaluationImageDataField, EditableLandscapeEvaluationImageNameField, EditableLandscapeEvaluationImageRelationalGuidField, TempImageFolder):
    # Make the temporary image directory
    if os.path.isdir(TempImageFolder) == True:
        shutil.rmtree(TempImageFolder)

    os.makedirs(TempImageFolder)

    LandscapeEvaluationList = []
    LandscapeEvaluationListViewSearchCursor(LandscapeEvaluationView, LandscapeEvaluationViewFields, LandscapeEvaluationList)
    
    LandscapeEvaluationListInsertCursor(LandscapeEvaluationFC, LandscapeEvaluationFCFields, LandscapeEvaluationList)
    #List to keep track of previously used file names
    ImageList = list()
    # If file name is a duplicate a number will be added to the filename to ensure uniqueness
    DuplicateCount = 1
    ImageSearchCursor(EditableLandscapeEvaluationImageTable, EditableLandscapeEvaluationImageDataField, EditableLandscapeEvaluationImageNameField, EditableLandscapeEvaluationImageRelationalGuidField, TempImageFolder, ImageList, DuplicateCount)

    PictureList = FilesPathsIntoList(TempImageFolder)
    print "The number of attachments in the directory is: " + str(len(PictureList))
    
    RelationshipList = REL_GuidtoGlobalID(LandscapeEvaluationFC, LandscapeEvaluationFCFieldsGUID)
    FinalizedList = MapGlobalIDtoPicture(PictureList, RelationshipList)
    InsertAttachments(FinalizedList, LandscapeEvaluationAttachmentTable, LandscapeEvaluationAttachmentField)
    print "All attachments have been added to the destination table"

    shutil.rmtree(TempImageFolder)
    print "Temp folder has been removed"


def LandscapeEvaluationListViewSearchCursor(FC, Fields, LandscapeEvaluationList):
    '''
    Function that accepts the path to the landscape evaluation view and extracts
    all of the attributes and rows from that view.  Each row is inserted into
    its own list within the TreList list.
    '''
    with arcpy.da.SearchCursor(FC, Fields) as cursor:
        for row in cursor:             
            LandscapeEvaluationList.append([row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13], row[14], row[15], row[16], row[17], row[18], row[19], row[20]])
    print "Number of evaluations being copied to LandscapeEvaluationList layer is: " + str(len(LandscapeEvaluationList))
    del row
    del cursor

def LandscapeEvaluationListInsertCursor(FC, Fields, LandscapeEvaluationList):
    '''
    Function that takes the nested list produced by Landscape Evaluation View Search Cursor and inserts
    each nested list into its own row in the landscape evaluation results feature class.
    '''
    edit = arcpy.da.Editor(r"Database Connections\FacilitiesMaintenance.sde")
    edit.startEditing(False, True)
    edit.startOperation()

    # Remove existing rows to create blank slate    
    with arcpy.da.UpdateCursor(FC, Fields) as LandscapeEvaluationRemoval:
        for row in LandscapeEvaluationRemoval:
            LandscapeEvaluationRemoval.deleteRow()
    del LandscapeEvaluationRemoval

    edit.stopOperation()
    # Stop editing and save edits
    edit.stopEditing(True)

    edit = arcpy.da.Editor(r"Database Connections\FacilitiesMaintenance.sde")
    edit.startEditing(False, True)
    edit.startOperation()

    with arcpy.da.InsertCursor(FC, Fields) as LandscapeEvaluationInsert:
        for item in LandscapeEvaluationList:
            LandscapeEvaluationInsert.insertRow([item[0], item[1], item[2], item[3], item[4], item[5], item[6], item[7], item[8], item[9], item[10], item[11], item[12], item[13], item[14], item[15], item[16], item[17], item[18], item[19], item[20]])
    del LandscapeEvaluationInsert
    
    edit.stopOperation()
    # Stop editing and save edits
    edit.stopEditing(True)


def ImageSearchCursor(TableLocation, BlobData, ImageName, GeomGuid, FolderLocation, ImageList, DuplicateCount):
    '''
    This function uses an arcpy search cursor to extract information from an
    ArcGIS attachment table.  The information will then be used to write all
    attachments to a location on disk.  All variables other than GeomGuid must be
    string, the numeric variable GeomOID will be converted to string.
    '''
    with arcpy.da.SearchCursor(TableLocation, [GeomGuid, ImageName, BlobData]) as cursor:
        for row in cursor:
            StringGeomGuid = str(row[0])
            BinaryData = row[2]
            FileName = StringGeomGuid + '@' + row[1]
            JPEGCreator(FileName, BinaryData, FolderLocation, ImageList, DuplicateCount)
    # Remove schema lock on table
    del row
    del cursor




def JPEGCreator(AttachmentName, BinaryInfo, FolderPath, ImageList, DuplicateCount):
    '''
    The second function in this script takes an Attachment Name, a folder location and
    binary data to write an ArcGIS attachment to disk.  For example it will take a JPEG
    that is stored in binary format and it write it to bytes in a given folder.  If the file
    name already exists the function will append a number to the front of the file name.  That
    number comes from the DuplicateCount variable which is an auto incrementing variable, ImageList
    is used to determine if a name is a duplicate value.
    '''
    if AttachmentName in ImageList:
        StringDuplicateCount = str(DuplicateCount)
        FileName = StringDuplicateCount + '_' + AttachmentName
        open(FolderPath + os.sep + FileName, wb).write(BinaryInfo.tobytes())
        # Print adjusted names so they can be easily found and fixed
        print FileName
        DuplicateCount = DuplicateCount + 1
    else:
        open(FolderPath + os.sep + AttachmentName, 'wb').write(BinaryInfo.tobytes())

def FilesPathsIntoList(Directory):
    '''
    Function that takes a path to a directory that is accessible to the computer on which this script is
    being run and then returns a nested list of file names and file paths for each file in the directory.
    '''
    FileList = []
    Files = listdir(Directory)
    for f in Files:
        picture = join(Directory, f)
        FileList.append([f, picture])
    return FileList

def REL_GuidtoGlobalID(FC, Attributes):
    '''
    This function takes an ESRI feature class and a set of attributes
    (REL_GlobalID and GlobalID in that order only) and creates a nested
    list mapping REL_GlobalID to GlobalId for each record in the feature
    class.  That nested list is returned by the function.
    '''
    GlobalIdList = []
    SearchCursor = arcpy.da.SearchCursor(FC, Attributes)
    for row in SearchCursor:
        RowList = [row[0], row[1]]
        GlobalIdList.append(RowList)
    del row
    del SearchCursor
    return GlobalIdList

def MapGlobalIDtoPicture(PicList, GuidList):
    '''
    This functions takes the lists that were returned by the previous
    two functions (FilesPathsIntoList and ObjectIDtoGlobalID, respectively).
    The REL_GlobalID and file name are extracted from the file by splitting on
    the '@' symbol.  The REL_GlobalID of the file is compared to the REL_GlobalID
    of each record from the feature class, when a match is found a new entry is
    added to the nested list.  Each entry contains GlobalID, File Name and
    File Path in that order.  The nested list is returned by the function
    '''
    CompletedList = []
    for picture in PicList:
        PicGuid = picture[0].split('@')[0]
        PicName = picture[0].split('@')[1]
        for entry in GuidList:
            if entry[0] == PicGuid:
                TempList = [entry[1], PicName, picture[1]]
                CompletedList.append(TempList)
            else:
                pass
    return CompletedList

def InsertAttachments(FinalList, Table, Attributes):
    '''
    The last function in this script takes the finalized list from the last
    function (MapGlobalIDtoPicture) along with an attachment table name and
    columns and proceeds to populate that table with the files from the starting
    directory.  Files are linked to their geometries based on the REL_GLOBALID
    field.  Nothing is returned by this function.
    '''

    edit = arcpy.da.Editor(r"Database Connections\FacilitiesMaintenance.sde")
    edit.startEditing(False, True)
    edit.startOperation()

    with arcpy.da.InsertCursor(Table, Attributes) as AttachmentInsert:
        for item in FinalList:
            print item
            PicBinary = open(item[2], "rb").read()
            AttachmentInsert.insertRow([item[0], "image/jpeg", item[1], PicBinary])
    del AttachmentInsert

    edit.stopOperation()
    # Stop editing and save edits
    edit.stopEditing(True)


if __name__ == "__main__":
    main(LandscapeEvaluationView, LandscapeEvaluationViewFields, LandscapeEvaluationFC, LandscapeEvaluationFCFields, LandscapeEvaluationFCFieldsGUID, LandscapeEvaluationAttachmentTable, LandscapeEvaluationAttachmentField, EditableLandscapeEvaluationImageTable, EditableLandscapeEvaluationImageDataField, EditableLandscapeEvaluationImageNameField, EditableLandscapeEvaluationImageRelationalGuidField, TempImageFolder)

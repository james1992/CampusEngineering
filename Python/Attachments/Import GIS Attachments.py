############################################################################# 
### Jay Dahlstrom
### Campus Engineering, University of Washington
### April 14, 2015
###

############################################################################# 
### Description: This script takes files that are stored on a computer, network
### drive, etc... and then imports them into a ESRI attachment table for a 
### given feature class.  The pictures must have the OID in the name before an
### '@' symbol with the image name following that symbol.  The relationship
### between feature class and attachments must be GlobalID based.


############################################################################# 
### Libraries
###

import os
from os import listdir
from os.path import join
import arcpy
from arcpy import env

############################################################################# 
### Parameters
###

# Path to folder that contains files
FolderLocation = "Z:\GIS-MIGRATION\IAMUW OID\MC_BOLLARD"
# GIS workspace
env.workspace = r"Database Connections\PUB-REPLICATION.sde"
# Related Feature Class
FeatureClass = "MC_BOLLARD"
# OID and GlobalID Column Names
FeatureClassColumns = ["OBJECTID", "GlobalID"]
# Attachment Table
AttachmentTable = "MC_BOLLARD__ATTACH"
# Attachment Fields to be updated
AttachmentField = ["REL_GLOBALID", "CONTENT_TYPE", "ATT_NAME", "DATA"]

#############################################################################  
###Script Follows
###

def main(Folder, OriginFc, OriginColumns, DestinationTable, DestinationColumns):
    PictureList = FilesPathsIntoList(Folder)
    print "The number of attachments in the directory is: " + str(len(PictureList))
    RelationshipList = ObjectIDtoGlobalID(OriginFc, OriginColumns)
    FinalizedList = MapGlobalIDtoPicture(PictureList, RelationshipList)
    InsertAttachments(FinalizedList, DestinationTable, DestinationColumns)
    print "All attachments have been added to the destination table"

def FilesPathsIntoList(Directory):
    '''
    Function that takes a path to a directory that is
    accessible to the computer on which this script is
    being run and then returns a nested list of file name
    and file path for each file in the directory.
    '''
    FileList = []
    Files = listdir(Directory)
    for f in Files:
        picture = join(Directory, f)
        FileList.append([f, picture])
    return FileList

def ObjectIDtoGlobalID(FC, Attributes):
    '''
    This function takes an ESRI feature class and a set of attributes
    (OnjectID and GlobalID in that order only) and creates a nested
    list mapping ObjectID to GlobalId for each record in the feature
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
    The ObjectID and file name are extracted from the file by splitting on
    the '@' symbol.  The ObjectID of the file is compared to the OID of each
    record from the feature class, when a match is found a new entry is added
    to the nested list.  Each entry contains GlobalID, File Name and File Path
    in that order.  The nested list is returned by the function
    '''
    CompletedList = []
    for picture in PicList:
        PicOID = picture[0].split('@')[0]
        PicName = picture[0].split('@')[1]
        for entry in GuidList:
            if entry[0] == int(PicOID):
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
    edit = arcpy.da.Editor(r"Database Connections\PUB-REPLICATION.sde")
    edit.startEditing(False, True)
    edit.startOperation()
    with arcpy.da.InsertCursor(Table, Attributes) as AttachmentInsert:
        for item in FinalList:
            PicBinary = open(item[2], "rb").read()
            AttachmentInsert.insertRow([item[0], "image/jpeg", item[1], PicBinary])
    del AttachmentInsert
    edit.stopOperation()
    # Stop editing and save edits
    edit.stopEditing(True)

if __name__ == "__main__":
    main(FolderLocation, FeatureClass, FeatureClassColumns, AttachmentTable, AttachmentField)

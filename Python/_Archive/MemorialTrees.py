############################################################################# 
### Jay Dahlstrom
### Engineering Services, University of Washington
### March 22, 2017
###

############################################################################# 
### Description: 
###
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


TreeView = r"Database Connections\FS_VIEW.sde\VIEW_MEMORIAL_TREE"
TreeViewFields = ["TreeNumber", "MemorialDescription", "TreeType", "SpeciesName", "CommonName", "DOMAIN_VALUE_DESIGNATION_CODE", "GlobalID", "SHAPE@", "FEATURE_STATUS"]

MemorialFC = r"Database Connections\FS_VIEW.sde\PUBLIC_MEMORIAL_TREES"
MemorialFCFields = ["RGUID", "TreeNumber", "MemorialDescription", "TreeType", "SpeciesName", "CommonName", "DesignationCode", "FEATURE_STATUS", "SHAPE@"]
MemorialFCFieldsGUID = ["RGUID", "GlobalID"]

MemorialAttachmentTable = r"Database Connections\FS_VIEW.sde\PUBLIC_MEMORIAL_TREES__ATTACH"
# Attachment Fields to be updated
MemorialAttachmentField = ["REL_GLOBALID", "CONTENT_TYPE", "ATT_NAME", "DATA"]

# File path to attachment table (typically in Geodatabase)
# Don't forget to put 'r' before file paths
ImageTable         = r"Database Connections\FS_MAC.sde\MC_TREE__ATTACH"
# The Blob field that contains the attachment information
ImageDataField     = "DATA"
# The field that contains the attachment name
ImageNameField     = "ATT_NAME"
# Field that contains the OID of related geometry
ImageRelationalOIDField = "REL_GLOBALID"
# Folder where attachments will be saved, need to create first
TempImageFolder       = r"C:\Users\jamesd26.NETID\Desktop\TreesPhotos"

############################################################################# 
### Script
###

def main(TreeView, TreeViewFields, MemorialFC, MemorialFCFields, MemorialFCFieldsGUID, MemorialAttachmentTable, MemorialAttachmentField, ImageTable, ImageDataField, ImageNameField, ImageRelationalOIDField, TempImageFolder):
    os.makedirs(TempImageFolder)
    TreeList = []
    TreeViewSearchCursor(TreeView, TreeViewFields, TreeList)
    
    MemorialTreeInsertCursor(MemorialFC, MemorialFCFields, TreeList)
    #List to keep track of previously used file names
    ImageList = list()
    # If file name is a duplicate a number will be added to ensure uniqueness
    DuplicateCount = 1
    ImageSearchCursor(ImageTable, ImageDataField, ImageNameField, ImageRelationalOIDField, TempImageFolder, ImageList, DuplicateCount)

    PictureList = FilesPathsIntoList(TempImageFolder)
    print "The number of attachments in the directory is: " + str(len(PictureList))
    RelationshipList = ObjectIDtoGlobalID(MemorialFC, MemorialFCFieldsGUID)
    FinalizedList = MapGlobalIDtoPicture(PictureList, RelationshipList)
    InsertAttachments(FinalizedList, MemorialAttachmentTable, MemorialAttachmentField)
    print "All attachments have been added to the destination table"
    shutil.rmtree(TempImageFolder)
    print "Temp folder has been removed"


def TreeViewSearchCursor(FC, Fields, TreeList):
    '''

    '''
    with arcpy.da.SearchCursor(FC, Fields) as cursor:
        for row in cursor:
            if row[8] == 2:
                pass
            else:
                TreeNumNoSpace = row[0].replace(" ", "")
                MemorialDescriptionNoSpace = row[1]
                TreeTypeNoSpace = row[2]
                SpeciesNameNoSpace = row[3]
                CommonNameNoSpace = row[4]
                DesignationCodeNoSpace = row[5]
                
                TreeList.append([row[6], TreeNumNoSpace, MemorialDescriptionNoSpace, TreeTypeNoSpace, SpeciesNameNoSpace, CommonNameNoSpace, DesignationCodeNoSpace, row[8], row[7]])

    del row
    del cursor

def MemorialTreeInsertCursor(FC, Fields, TreeList):
    '''

    '''
    edit = arcpy.da.Editor(r"Database Connections\FS_VIEW.sde")
    edit.startEditing(False, True)
    edit.startOperation()

    with arcpy.da.UpdateCursor(FC, Fields) as MemorialTreeRemoval:
        for row in MemorialTreeRemoval:
            MemorialTreeRemoval.deleteRow()
    del MemorialTreeRemoval

    with arcpy.da.InsertCursor(FC, Fields) as MemorialTreeInsert:
        for item in TreeList:
            MemorialTreeInsert.insertRow([item[0], item[1], item[2], item[3], item[4], item[5], item[6], item[7], item[8]])
    del MemorialTreeInsert
    edit.stopOperation()
    # Stop editing and save edits
    edit.stopEditing(True)


def ImageSearchCursor(TableLocation, BlobData, ImageName, GeomOID, FolderLocation, ImageList, DuplicateCount):
	'''
	This function uses an arcpy search cursor to extract information from an
	ArcGIS attachment table.  The information will then be used to write all
	attachments to a location on disk.  All variables other than GeomOID must be
	string, the numeric variable GeomOID will be converted to string.
	'''
	with arcpy.da.SearchCursor(TableLocation, [GeomOID, ImageName, BlobData]) as cursor:
		for row in cursor:
			StringGeomOID = str(row[0])
			BinaryData = row[2]
			FileName = StringGeomOID + '@' + row[1]
			print FileName
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
	print ImageList
	print AttachmentName
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
            if entry[0] == PicOID:
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
    edit = arcpy.da.Editor(r"Database Connections\FS_VIEW.sde")
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
    main(TreeView, TreeViewFields, MemorialFC, MemorialFCFields, MemorialFCFieldsGUID, MemorialAttachmentTable, MemorialAttachmentField, ImageTable, ImageDataField, ImageNameField, ImageRelationalOIDField, TempImageFolder)


############################################################################# 
### Jay Dahlstrom
### Campus Engineering, University of Washington
### December 20, 2014
###

############################################################################# 
### Description: This script is designed to extract attachments
### from an ArcGIS attachments table.  It takes the table location,
### the relational object Id field, data (blob) field, attachment
### name field and the output folder file path.  With those inputs
### the script saves a copy of the attachment in its native format
### in the output folder with the file name of "RelationalOID@Filename"
### to do this the script converts the binary information into bytes.
###
### *NOTE: The output folder must be created prior to running the script

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
ImageTable         = r'Database Connections\FS_MAC.sde\MC_LANDSCAPEPROFILE__ATTACH'
# The Blob field that contains the attachment information
ImageDataField     = "DATA"
# The field that contains the attachment name
ImageNameField     = "ATT_NAME"
# Field that contains the OID of related geometry
ImageRelationalOIDField = 'REL_GLOBALID'
# Folder where attachments will be saved, need to create first
OutputFolder       = r'C:\Users\jamesd26.NETID\Desktop\new'

#############################################################################  
###Script Follows
###

def main(TableLocation, ImageDataField, ImageNameField, ImageRelationalOIDField, OutputFolder):
	print OutputFolder
	#List to keep track of previously used file names
	ImageList = list()
	# If file name is a duplicate a number will be added to ensure uniqueness
	DuplicateCount = 1
	SearchCursor(ImageTable, ImageDataField, ImageNameField, ImageRelationalOIDField, OutputFolder, ImageList, DuplicateCount)


def SearchCursor(TableLocation, BlobData, ImageName, GeomOID, FolderLocation, ImageList, DuplicateCount):
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
			FileName = row[1]
			print FileName
			print StringGeomOID, BinaryData, FileName
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
	
if __name__ == "__main__":
    main(ImageTable, ImageDataField, ImageNameField, ImageRelationalOIDField, OutputFolder)

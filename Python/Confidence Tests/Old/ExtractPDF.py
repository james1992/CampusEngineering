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
### With standard names SharePoint can employ document retention schedules.

############################################################################# 
### Libraries
###

import os
from os import listdir
from os.path import join
import datetime
import arcpy
from arcpy import env
import shutil

############################################################################# 
### Parameters
###

AttachmentTable = r'Database Connections\FS_CEO.sde\CEO_FIRE_PROTECTION_CONFIDENCE_TESTS_AUX__ATTACH'
AttachmentAttributes = ['DATA', 'ATT_NAME','REL_OBJECTID']

AuxTable = r'Database Connections\FS_CEO.sde\CEO_FIRE_PROTECTION_CONFIDENCE_TESTS_AUX'
AuxAttributes = ['OBJECTID', 'INSPECTION_DATE', 'REL_GUID']

GeomTable = r'Database Connections\FS_CEO.sde\CEO_FIRE_PROTECTION_CONFIDENCE_TESTS'
GeomAttributes = ['GlobalID', 'FEATURE_TYPE', 'SYSTEM_NUMBER', 'FACNAME', 'FACNUM']
SystemCodeToName = [[0, 'Undefined'], [1, 'Fire Alarm'], [2, 'HazMat Emergency'], [3, 'Kitchen Hood'], [4,'Sprinkler'], [5, 'Pressurization'], [6, 'Standpipe']]

FolderLocation = r'C:\Users\jamesd26.NETID\Desktop\new'

############################################################################# 
### Script
###

def main(AttachmentTable, AttachmentAttributes, AuxTable, AuxAttributes, GeomTable, GeomAttributes, SystemCodeToName, FolderLocation):
    AttachmentList = SearchCursor(AttachmentTable, AttachmentAttributes)
    AttachmentListCleanup(AttachmentList)

    AuxList = SearchCursor(AuxTable, AuxAttributes)
    AuxListCleanup(AuxList)

    GeomList = SearchCursor(GeomTable, GeomAttributes)
    GeomListCleanup(GeomList, SystemCodeToName)

    CombinedList = CombineLists(AttachmentList, AuxList, GeomList)
    print CombinedList
    CreateFiles(FolderLocation, CombinedList)

    #BackupAttachmentsData(AttachmentTable)
    #TruncateAttachmentTable(AttachmentTable)


def SearchCursor(Table, Attributes):
    '''
    Universal function that takes a GIS table and a list of
    attributes as inputs.  The function then uses an arcpy
    search cursor to create a nested list where each inner
    list represents a row in the table that contains all
    of the requested attributes.
    '''
    AttributeList = []
    with arcpy.da.SearchCursor(Table, Attributes) as Cursor:
        for Row in Cursor:
            RowList = []
            for Column in Row:
                RowList.append(Column)
            AttributeList.append(RowList)
    del Row
    del Cursor
    return AttributeList

def AttachmentListCleanup(AttachmentList):
    '''
    Function that takes the product from a search of 
    an attachment table and cleans up the attributes
    for use in later functions.
    '''
    for Attachment in AttachmentList:
        File = Attachment[1].split('.')
        Extension = '.' + File[-1]
        Attachment[1] = Extension

def AuxListCleanup(AuxList):
    '''
    Function that takes the product from a search of 
    an auxilliary table and cleans up the attributes
    for use in later functions.
    '''
    for Test in AuxList:
        TestDateTime = str(Test[1])
        Split = TestDateTime.split(' ')
        TestDateTemp = Split[0]
        DateParts = TestDateTemp.split('-')
        TestDateFinal = DateParts[1] + '-' + DateParts[2] + '-' + DateParts[0]
        Test[1] = TestDateFinal

def GeomListCleanup(GeomList, SystemCodeToName):
    '''
    Function that takes the product from a search of 
    a geometry feature class and cleans up the attributes
    for use in later functions.
    '''
    for System in GeomList:
        SystemCode = System[1]
        for Pair in SystemCodeToName:
            if SystemCode == Pair[0]:
                SystemName = Pair[1]
            else:
                pass
        System[1] = SystemName

def CombineLists(AttachmentList, AuxList, GeomList):
    '''
    Function takes the three previously extracted lists
    and merges them into one single list.  All excess
    attributes are removed and a standard order create
    for use in create documents from the attachment data.
    '''
    AttachmentAuxTempList = []
    FinalList = []
    for Attachment in AttachmentList:
        for Test in AuxList:
            if Attachment[2] == Test[0]:
                AttachmentAuxTempList.append([Attachment[1], Attachment[0], Test[1], Test[2]])
            else:
                pass
    for Record in AttachmentAuxTempList:
        for System in GeomList:
            if Record[3] == System[0]:
                #                  FacName, SystemType, SystemNo., TestDate, FileType, BLOB Data, FacNum
                FinalList.append([System[3], System[1], System[2], Record[2], Record[0], Record[1], System[4]])
            else:
                pass
    return FinalList

def CreateFiles(FolderLocation, CombinedList):
    '''
    Function that takes the combined list and a folder location
    and create physical copies of the files that were uploaded 
    by the technicians using a standard naming convention.  The 
    files are subsequently uploaded to a SharePoint site.
    '''
    BuildingFolders = [ name for name in os.listdir(FolderLocation) if os.path.isdir(os.path.join(FolderLocation, name)) ] 
    for Document in CombinedList:
        if Document[2] == None:
            FileName = Document[0] + '-' + Document[1] + '_' + Document[3] + Document[4]
        else:
            FileName = Document[0] + '-' + Document[1] + '-' + Document[2] + '_' + Document[3] + Document[4]
        for Folder in BuildingFolders:
            FacNum = Document[6]
            
            SplitFolder = Folder.split('-')
            if FacNum == SplitFolder[1]:
                FinalFileName = FileName.replace( " ", "")
                print FinalFileName
                DocumentPath = os.path.join(FolderLocation, Folder)
                print DocumentPath
                open(DocumentPath + os.sep + FinalFileName, 'wb').write(Document[5].tobytes())
            else:
                pass

def BackupAttachmentsData(AttachmentTable):
    '''
    Function that creates a backup attachment table in a 
    local database in the same location as this script.
    '''
    Database = r"C:\Users\jamesd26.NETID\Desktop\GitHub\CampusEngineering\Python\Confidence Tests\Backup.gdb"
    OutTable = 'Attachments_' + str(datetime.date.today()).replace('-','_')
    arcpy.TableToTable_conversion(AttachmentTable, Database, OutTable)

def TruncateAttachmentTable(AttachmentTable):
    '''
    Function that removes all of the rows from the attachment
    table to ensure the database does not become bloated with
    reports that have been uploaded to SharePoint
    '''
    arcpy.TruncateTable_management(AttachmentTable)

if __name__ == "__main__":
    main(AttachmentTable, AttachmentAttributes, AuxTable, AuxAttributes, GeomTable, GeomAttributes, SystemCodeToName, FolderLocation)

############################################################################# 
### Jay Dahlstrom
### Campus Engineering, University of Washington
### May 5, 2015
###

############################################################################# 
### Description: This script runs weekly on Jay's PC to copy all SQL Server
### .bak files from the PUB and IAMUW database servers onto the Drobo.  This
### is done to limit data loss from a single point of failure.  The backups
### are only transfered after the full back up is taken by the database meaning
### that any changes saved in differential or transaction log backups could
### be lost, these files are only meant as a last resort.



############################################################################# 
### Libraries
###

import shutil
import datetime
import os
from os import listdir

############################################################################# 
### Parameters
###

IamuwBackups = "Y:\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Backup"
PubBackups   = "X:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Backup"

#############################################################################  
###Script Follows
###

def main(IamuwFolder, PubFolder):
    #Get the current date
    TodaysDate = GetDate()

    #Create the required folders
    NewFolderLocations = CreateFolders('Z:\FS\Student Intern\Interns\Jay Dahlstrom\Database Backups', TodaysDate)

    #Pair source and destination folders
    FolderList =  CreateNestedList(NewFolderLocations, IamuwFolder, PubFolder)

    #Transfer files from source to destination folders
    IdentifyBackupFiles(FolderList)

    print 'All files have been transfered successfully'
    

def GetDate():
    '''
    Function that takes no inputs and returns
    the string value for the current date in
    Year-Month-Day format.
    '''
    CurrentDate = datetime.date.today()
    return str(CurrentDate)

def CreateFolders(Path, Date):
    '''
    Function that takes a file path and the current date (string)
    and then creates a new folder for the date as well as two subfolders.
    One sub folder for 'IAMUW' and the other for 'PUB'.
    '''
    MainFolder = os.path.join(Path, Date)
    os.makedirs(MainFolder)
    
    IAMUWFolder = os.path.join(MainFolder, 'IAMUW')
    os.makedirs(IAMUWFolder)
    
    PUBFolder = os.path.join(MainFolder, 'PUB')
    os.makedirs(PUBFolder)

    return IAMUWFolder, PUBFolder

def CreateNestedList(NewFolders, IamuwPath, PubPath):
    '''
    Function that takes a list of new folder locations and merges
    them with their respective source folder.  These new folders
    will hold the copied backup files for the relevant database.
    '''
    return [[IamuwPath, NewFolders[0]],[PubPath, NewFolders[1]]]

def IdentifyBackupFiles(FolderGroups):
    '''
    This function takes as an input a nested list of source and
    destination folder paths that contain database backup files.
    The source location is where SQL Server saves the file while
    the destination is an auxillary location to save the file. File
    paths are created for both the source and destination folders,
    those are used in the TransferBackupFiles function to copy the data.
    '''
    for group in FolderGroups:
        BackupFiles = listdir(group[0])
        for database in BackupFiles:
            OldPath = os.path.join(group[0], database)
            NewPath = os.path.join(group[1], database)
            TransferBackupFiles(OldPath, NewPath)



def TransferBackupFiles(Source, Destination):
    '''
    This function takes a source and destination file path and then
    copies the source file into the destination location.  Metadata
    about the document is also transfered to the destination.
    '''
    shutil.copy2(Source, Destination)
	
if __name__ == "__main__":
    main(IamuwBackups, PubBackups)

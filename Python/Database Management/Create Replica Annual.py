############################################################################# 
### Jay Dahlstrom
### Campus Engineering, University of Washington
### May 28, 2015
###

############################################################################# 
### Description: This function is designed to create yearly archives of all 
### active Campus Engineering GIS assets, thus creating a snapshot in time.
### It will be possible to look back at a given year and see what campus 
### looked like spatially (e.g. which buildings were on campus, the current
### landscape, etc...).
###


############################################################################# 
### Libraries
###

import os
import datetime
import arcpy
from arcpy import env

############################################################################# 
### Parameters
###

ArchiveFolder = r"Z:\FS\Student Intern\Interns\Jay Dahlstrom\GIS Archives"
IamuwDatabases = [r"Database Connections\IAMUW-FS_MAC.sde", r"Database Connections\IAMUW-FS_CEO.sde"]

#############################################################################  
###Script Follows
###

def main(OutputLocation, InputDatabases):
    Year, Date = GetDate()
    ArchiveDatabase = CreateDatabase(ArchiveFolder, Year, Date)
    for Database in InputDatabases:
        CopyFeatureClasses(Database, ArchiveDatabase)
        CopyTables(Database, ArchiveDatabase)

def GetDate():
    '''
    Function that takes no inputs and returns
    the string value for the current date in
    Year-Month-Day format.
    '''
    CurrentDate = str(datetime.date.today())
    CurrentYear = CurrentDate.split('-')
    #Return the year as well as the full date
    return CurrentYear[0], CurrentDate

def CreateDatabase(MainFolder, Year, Date):
    '''
    Function that takes a folder location, the current year
    and the date all as strings.  The output of this function
    is a new folder for the current year and then inside that
    folder an ESRI file geodatabase with the date as it's name.
    '''
    ArchiveFolder = os.path.join(MainFolder, Year)
    if not os.path.exists(ArchiveFolder):
        os.makedirs(ArchiveFolder)
        FileGeodatabase = arcpy.CreateFileGDB_management(ArchiveFolder, Date, "CURRENT")
    else:
        FileGeodatabase = arcpy.CreateFileGDB_management(ArchiveFolder, Date, "CURRENT")
    return FileGeodatabase

def CopyFeatureClasses(IamuwDatabase, OutputDatabase):
    '''
    Given input and output databases this function copies
    all of the feature classes from the input to the output.
    Only rows in those feature classes with a Feature Status
    set to 1 ('Active') are copied over.
    '''
    env.workspace = IamuwDatabase
    FeatureClasses = arcpy.ListFeatureClasses()
    for FeatureClass in FeatureClasses:
        #Skip backdrop feature class and any spatial views
        if 'BACKDROP' in FeatureClass:
            pass
        elif 'VIEW' in FeatureClass:
            pass
        elif 'ANNOTATIONS' in FeatureClass:
            #Split along the periods to remove illegal characters
            FeatureClassName = FeatureClass.split('.')
            #FeatureClassName[2] is used to extract only the feature class name and not the preceeding schema or DB name.
            arcpy.FeatureClassToFeatureClass_conversion(FeatureClass, OutputDatabase, FeatureClassName[2])
        else:
            #Split along the periods to remove illegal characters
            FeatureClassName = FeatureClass.split('.')
            #FeatureClassName[2] is used to extract only the feature class name and not the preceeding schema or DB name.
            arcpy.FeatureClassToFeatureClass_conversion(FeatureClass, OutputDatabase, FeatureClassName[2], "FEATURE_STATUS" " = 1")

def CopyTables(IamuwDatabase, OutputDatabase):
    '''
    Given input and output databases this function copies all of the
    geodatabase tables from the input to the output.
    '''
    env.workspace = IamuwDatabase
    Tables = arcpy.ListTables()
    for Table in Tables:
        #Exclude non-ESRI tables
        if 'DBO' in Table:
            #Split along the periods to remove illegal characters
            TableName = Table.split('.')
            #TableName[2] is used to extract only the table name and not the preceeding schema or DB name.
            arcpy.TableToTable_conversion(Table, OutputDatabase, TableName[2])
        else:
            pass

	
if __name__ == "__main__":
    main(ArchiveFolder, IamuwDatabases)

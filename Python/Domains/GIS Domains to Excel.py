############################################################################# 
### Jay Dahlstrom
### Campus Engineering, University of Washington
### February 23, 2015
###

############################################################################# 
### Description: This script is designed to take a given ESRI geodatabase and
### first export all of those domains to another database (typically a File
### Geodatabase on the users desktop.  Once the domains have all been exported
### to the new database those tables are converted into Microsoft Excel files
### and those files are stored in a user specified folder.  This way domains
### can easily be pulled out of database with minimal user effort.
###
### *All output locations must be created prior to running this script.

############################################################################# 
### Libraries
###

import os
import sys
import arcpy

############################################################################# 
### Parameters
###
### *Make sure to leave the 'r' infront of all file paths

# ESRI Geodatabase that contains the domains you want to export
DomainDatabase = r"Database Connections\IAMUW-FS_MAC.sde"
# Domain Name filter, keyword in domain name used to filter domains out from script
DomainFilter = "DOMAIN"
# ESRI Geodatabase where the domains will be made into individual tables
IntermediateDatabase = r"C:\Users\jamesd26\Desktop\AM Domains\DomainTables_2_23.gdb"
# Folder location on computer/network drive
OutputFolder = r"Z:\IAMUW GIS DOMAINS\1.23.15"


#############################################################################  
###Script Follows
###

def main(DomainLocation, NameFilter, TableLocation, OutputFolder):
        DomainToTable(DomainDatabase, DomainFilter, IntermediateDatabase)
        TableToExcel(IntermediateDatabase, OutputFolder)

def DomainToTable(DomainLocation, NameFilter, TableLocation):
        '''
        This function takes a database that contains ESRI domains (string) that
        the user wants to export to tables.  A filter to query out some of the
        domains if necessary (string) and finally a secondary database where the
        new tables will be created (string).
        '''
        arcpy.env.workspace = TableLocation
        arcpy.env.overwriteOutput = True
        Description = arcpy.Describe(DomainLocation)
        Domains = Description.domains
        for Domain in Domains:
                if NameFilter in Domain:
                        print Domain
                        Table = os.path.join(export_db, domain)
                        arcpy.DomainToTable_management(DomainLocation, Domain, Table,'Code','Description')

def TableToExcel(TableLocation, OutputFolder):
        '''
        This function takes a database (string) that contains tables that the user
        wants to export to Excel.  The output folder where those Excel files will be
        stored is also needed as a parameter (string).
        '''
        arcpy.env.workspace = TableLocation
        Tables = arcpy.ListTables()
        for Table in Tables:
                OutputExcel = Table + ".xls"
                OutputPath = os.path.join(OutputFolder, OutputExcel)
                print OutputPath
                arcpy.TableToExcel_conversion(table, Output_XLS)
	
if __name__ == "__main__":
    main(DomainDatabase, DomainFilter, IntermediateDatabase, OutputFolder)

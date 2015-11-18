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

# ESRI Geodatabase FS-CEO that contains domains that need to be moved to tables
DomainCeoDatabase = r"Database Connections\IAMUW-FS_CEO.sde"
# ESRI Geodatabase FS-FMC that contains domains that need to be moved to tables
DomainFmcDatabase = r"Database Connections\IAMUW-FS_MAC.sde"
# Domain Name filter, keyword in domain name used to filter domains out from script
DomainFilter = "DOMAIN"
# ESRI Geodatabase where the domains will be made into individual tables on IAMUW
OutputDatabaseIamuw = r"Database Connections\IAMUW-FS_CEO_AUX.sde"
# ESRI Geodatabase where the domains will be made into individual tables on PUB
OutputDatabasePub = r"Database Connections\PUB_DOMAIN.sde"

#############################################################################  
###Script Follows
###

def main(CeoDomains, FmcDomains, NameFilter, IamuwDatabaseLocation, PubDatabaseLocation):
        DomainToTable(CeoDomains, DomainFilter, IamuwDatabaseLocation)
        DomainToTable(CeoDomains, DomainFilter, PubDatabaseLocation)
        print 'All CEO domains have been exported to the output database'
        DomainToTable(FmcDomains, DomainFilter, IamuwDatabaseLocation)
        DomainToTable(FmcDomains, DomainFilter, PubDatabaseLocation)
        print 'All FMC domains have been exported to the output database'

def DomainToTable(DomainLocation, NameFilter, TableDatabase):
        '''
        This function takes a database that contains ESRI domains (string) that
        the user wants to export to tables.  A filter to query out some of the
        domains if necessary (string) and finally a secondary database where the
        new tables will be created (string).
        '''
        arcpy.env.workspace = TableDatabase
        arcpy.env.overwriteOutput = True
        Description = arcpy.Describe(DomainLocation)
        Domains = Description.domains
        for Domain in Domains:
                if NameFilter in Domain:
                        Table = os.path.join(TableDatabase, Domain)
                        arcpy.DomainToTable_management(DomainLocation, Domain, Table,'Code','Description')

if __name__ == "__main__":
    main(DomainCeoDatabase, DomainFmcDatabase, DomainFilter, OutputDatabaseIamuw, OutputDatabasePub)

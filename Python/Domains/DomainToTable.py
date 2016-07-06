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
#
DomainPubDatabase = r"Database Connections\PUB-REPLICATION.sde"
# Domain Name filter, keyword in domain name used to filter domains out from script
DomainFilter = "DOMAIN"
# ESRI Geodatabase where the domains will be made into individual tables on IAMUW
OutputDatabaseIamuw = r"Database Connections\IAMUW-FS_CEO_AUX.sde"
# ESRI Geodatabase where the domains will be made into individual tables on PUB
OutputDatabasePub = r"Database Connections\FS_VIEW.sde"

#############################################################################  
###Script Follows
###

def main(CeoDomains, FmcDomains, PubDomains, NameFilter, IamuwDatabaseLocation, PubDatabaseLocation):
        TablesInPub = StripTableNames(PubDatabaseLocation)
        print 'Existing tables have been identified'
        
        DomainToTableIamuw(CeoDomains, DomainFilter, IamuwDatabaseLocation)
        DomainToTablePub(CeoDomains, DomainFilter, PubDatabaseLocation, TablesInPub)
        print 'All CEO domains have been exported to the output database'
        
        DomainToTableIamuw(FmcDomains, DomainFilter, IamuwDatabaseLocation)
        DomainToTablePub(FmcDomains, DomainFilter, PubDatabaseLocation, TablesInPub)
        print 'All FMC domains have been exported to the output database'

        DomainToTableIamuw(PubDomains, DomainFilter, IamuwDatabaseLocation)
        DomainToTablePub(PubDomains, DomainFilter, PubDatabaseLocation, TablesInPub)
        print 'All PUB domains have been exported to the output database'

        #EnableEditing(PubDatabaseLocation)
        #print 'Editing has been enabled on the domain tables in the PUB database'

def DomainToTablePub(DomainLocation, NameFilter, TableDatabase, ExistingTables):
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
                print Domain
                if NameFilter in Domain:
                        if Domain not in ExistingTables:
                                Table = os.path.join(TableDatabase, Domain)
                                arcpy.DomainToTable_management(DomainLocation, Domain, Table,'Code','Description')
                        else:
                                pass

def DomainToTableIamuw(DomainLocation, NameFilter, TableDatabase):
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
                print Domain
                if NameFilter in Domain:
                        Table = os.path.join(TableDatabase, Domain)
                        arcpy.DomainToTable_management(DomainLocation, Domain, Table,'Code','Description')

def StripTableNames(TableDatabase):
        '''
        Takes a SDE database location and returns a list of all tables in that
        database.  The table names have the database and schema names stripped.
        This is done so that comparisons can be performed with domain names in
        production databases.
        '''
        arcpy.env.workspace = TableDatabase
        Tables = arcpy.ListTables()
        TrimmedTables = []
        for Table in Tables:
                Temp = Table[15:]
                TrimmedTables.append(Temp)
        return TrimmedTables

def EnableEditing(PubDomainDatabase):
        '''
        The workflow for updating domains will revolve around editing the domains
        in the PUB Domain database tables and then republishing those tables back
        to the domains in the production databases.  To edit these tables versioning
        needs to be enabled.
        '''
        arcpy.env.workspace = PubDomainDatabase
        Tables = arcpy.ListTables()
        for Table in Tables:
                DatasetVersioned = arcpy.Describe(Table).isVersioned
                if DatasetVersioned == True:
                        pass
                else:
                        arcpy.RegisterAsVersioned_management(Table, "EDITS_TO_BASE")

        
if __name__ == "__main__":
    main(DomainCeoDatabase, DomainFmcDatabase, DomainPubDatabase, DomainFilter, OutputDatabaseIamuw, OutputDatabasePub)

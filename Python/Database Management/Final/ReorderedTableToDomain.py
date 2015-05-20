############################################################################# 
### Jay Dahlstrom
### Campus Engineering, University of Washington
### April 7, 2014
###

############################################################################# 
### Description:
### 
### 
### 


############################################################################# 
### Libraries
###

import arcpy
from arcpy import env
import operator
from operator import itemgetter

############################################################################# 
### Parameters
###

#Location of Domain tables
env.workspace = r"Database Connections\IAMUW-FS_CEO_AUX.sde"

#############################################################################  
###Script Follows
###

def main():
    DomainTables = arcpy.ListTables()
    CreateSortedList(DomainTables)
    ReplaceEsriDomains(DomainTables)

def CreateSortedList(Tables):
    '''
    Takes a list of ESRI domain tables stored in SQL Server and re-orders
    the rows in those tables into ascending order based on the description field.
    The function does not return any values but instead for each table it calls
    the RepopulateTable function.
    '''
    for DomainTable in Tables:
        DomainList = []
        with arcpy.da.SearchCursor(DomainTable, ['Code', 'Description']) as cursor:
            for row in cursor:
                if row[1] == 'Undefined':
                    pass
                else:
                    DomainList.append([row[0], row[1]])
        DomainList.sort(key=itemgetter(1))
        DomainList.insert(0, [0, u'Undefined'])
        RepopulateTable(DomainTable, DomainList)

def TruncateTable(Table):
    '''
    Takes a single ESRI table stored in  SQL server and removes all of its
    rows (truncating the table).  Table schema and metadata are left intact.
    '''
    arcpy.TruncateTable_management(Table)

def RepopulateTable(Table, DomainList):
    '''
    Given a table and a reordered list of domains this function adds rows
    to the now empty table in the order they appear in the list.  This provides
    an alphabetized table.
    '''
    TruncateTable(Table)
    with arcpy.da.InsertCursor(Table, ['Code', 'Description']) as cursor:
        for Domain in DomainList:
            cursor.insertRow(Domain)
    del cursor

def ReplaceEsriDomains(Tables):
    '''
    This function takes a list of database tables and based on their names
    reuploads them to their respective ESRI Enterprise database as domains.
    The old domain values are replaced with the newly ordered values in the
    tables.  If the domain does not already exist in the enterprise database
    then it is skipped over by this function.
    '''
    ExistingCeoDomains = arcpy.da.ListDomains(r"Database Connections\IAMUW-FS_CEO.sde")
    ExistingMcDomains = arcpy.da.ListDomains(r"Database Connections\IAMUW-FS_MAC.sde")
    for Table in Tables:
        if 'CEO' or 'TS' in Table:
            for Domain in ExistingCeoDomains:
                #print Table
                #print Domain.name
                if Domain.name in Table:
                    arcpy.TableToDomain_management(Table, 'Code', 'Description', r"Database Connections\IAMUW-FS_CEO.sde",Table, '', 'REPLACE')
        if 'MC' in Table:
            for Domain in ExistingMcDomains:
                if Domain.name in Table:
                    arcpy.TableToDomain_management(Table, 'Code', 'Description', r"Database Connections\IAMUW-FS_MAC.sde",Table, '', 'REPLACE')

	
if __name__ == "__main__":
    main()

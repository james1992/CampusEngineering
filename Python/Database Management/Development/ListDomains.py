import arcpy
from arcpy import env

env.workspace = r"Database Connections\IAMUW-FS_CEO_AUX.sde"
env.overwriteOutput = True

Databases = [r"Database Connections\IAMUW-FS_CEO.sde", r"Database Connections\IAMUW-FS_MAC.sde"]

def IdentifyDomains(InDatabases):
    '''
    Takes two or more database connections and lists all of the
    domains in each location.  If the domain is type 'short' then
    it is sent to the CreateTableFromDomain function, if not it is
    skipped over.
    '''
    for Database in InDatabases:
        Domains = arcpy.da.ListDomains(Database)
        for Domain in Domains:
            if Domain.type == 'Short' and count == 0:
                DomainName = Domain.name
                CreateTableFromDomain(Database, DomainName)
            else:
                pass

def CreateTableFromDomain(InDatabase, DomainName):
    '''
    Takes a ESRI geodatabase along with the name of a domain and
    creates a table in the specified workspace.  The table name is
    the same as the name of the domain name.
    '''
    arcpy.DomainToTable_management(InDatabase, DomainName, DomainName, "Code", "Description")
    

IdentifyDomains(Databases)

############################################################################# 
### Jay Dahlstrom
### Campus Engineering, University of Washington
### July 28, 2014
###

############################################################################# 
### Description: This script takes any newly added peices of equipment and
### adds the EIO number to the point that was created for that equipment in
### GIS.  Once this script has been run all of the attributes for that point
### will be visible in the web viewer.
###
### Note: A point must exist for every new point in GIS first before this script
### can be run.
###

############################################################################# 
### Libraries
###

import arcpy

############################################################################# 
### Parameters
###

OutputExcelTable = r"C:\Users\jamesd26\Desktop\Temp\zEquipmentInventory.gdb\EIO"
UpdateFc = r"Database Connections\IAMUW_REPLICATION.sde\CEO_EQUIPMENT_INVENTORY"
UpdateFields = ['FEATURE_ID', 'FEATURE_TYPE']
WhereClause = "FEATURE_TYPE = 1 AND FEATURE_ID IS NULL"

#############################################################################  
###Script Follows
###

def main(OutputTable, FC, Fields, Where):
    Tags = ExtractNewGeometryEIO(OutputTable)
    NewTagsOnly = RemoveExistingTags(FC, AllTags)
    #UpdateGeometriesWithEIO(FC, Fields, Where, NewTagsOnly)

def ExtractNewGeometryEIO(OutputExcelTable):
    '''
    Function that uses a search cursor on the ESRI table
    that was created from the Equipment List Excel and
    extracts all of the Tag Numbers.  A list of those
    tags is returned at the end of the function.
    '''
    TagList = []
    with arcpy.da.SearchCursor(OutputExcelTable, "Inventory_Tag__") as cursor:
        for row in cursor:
            TagList.append(row[0])
    del row
    del cursor
    
    return TagList

def RemoveExistingTags(FC, AllTags):
    '''

    '''
    Count = 0
    with arcpy.da.SearchCursor(FC, "FEATURE_ID") as cursor:
        for row in cursor:
            if row[0] in AllTags:
                Count += 1
    del row
    del cursor
    print Count 
    return TagList


def UpdateGeometriesWithEIO(FC, Fields, WhereClause, FinalTagList):
    '''
    Function that uses an update cursor to apply new equipment
    tags to the correct geometry in GIS.  A where clause is used to limit
    the additions by department and only for points that dont already
    have an EIO value, which should only be newly added points.
    Once the tag has been added all of the attributal data will automatically
    be visible in the web viewer by clicking on the given point.
    '''
    edit = arcpy.da.Editor(r"Database Connections\IAMUW_REPLICATION.sde")
    edit.startEditing(False, True)
    edit.startOperation()
    count = 0
    with arcpy.da.UpdateCursor(FC, Fields, WhereClause) as Cursor:
        for row in Cursor:
            row[0] = FinalTagList[count]
            count += 1
            Cursor.updateRow(row)
        
    edit.stopOperation()
    # Stop editing and save edits
    edit.stopEditing(True)
    print count


if __name__ == "__main__":
    main(OutputExcelTable, UpdateFc, UpdateFields, WhereClause)

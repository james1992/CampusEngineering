############################################################################# 
### Jay Dahlstrom
### Campus Engineering, University of Washington
### September 26, 2016
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
import datetime

############################################################################# 
### Parameters
###

InputDatabase = r"Z:\FS\Student Intern\PROJECTS\CEO\Building Floor Plans\GeoReferenced Floor Plans\Yurika\FloorPlans.gdb"
env.workspace = InputDatabase

    
OutFeatureClass = r"Database Connections\FS_CEO.sde\CEO_BACKGROUND_FLOORPLAN"
OutFeatureClassFields = ["SHAPE@", "FEATURE_ID", "NOTES"]
    
OutTable = r"Database Connections\FS_CEO.sde\CEO_BACKGROUND_FLOORPLAN_AUX"
OutTableFields = ["FACNUM", "FLOOR", "ROOM_NO", "REL_GUID"]

#############################################################################  
###Script Follows
###

def main(OutFc, OutFcFields, OutTables, OutTableFields):
    FeatureClasses = arcpy.ListFeatureClasses()
    for FeatureClass in FeatureClasses:
        print "1"
        RoomList = []
        FacNum = ExtractRoomData(FeatureClass, RoomList)
        print FacNum
        InsertGeoms(OutFc, OutFcFields, RoomList)
        print "GlobalID"
        ExtractGlobalID(OutFc, FacNum, RoomList)
        print "Insert"
        InsertTabular(OutTable, OutTableFields, RoomList)


def ExtractRoomData(FeatureClass, RoomList):
    '''
    Takes a feature class containing floors that have
    been extracted from CAD and an empty list as inputs.
    Returns a nested list for each geometry with the following
    attributes: Shape@, Room Number, FacNum and Floor (in that
    order).
    '''
    Attributes = ["SHAPE@", "ROOM_NUMBER", "FACNUM", "FLOOR"]
    with arcpy.da.SearchCursor(FeatureClass, Attributes) as Cursor:
        for Row in Cursor:
            TempList = [Row[0], Row[1], Row[2], Row[3]]
            RoomList.append(TempList)
            FacNum = Row[2]
    return FacNum

def InsertGeoms(OutFc, OutFcFields, RoomList):
    '''
    Inserts the room geometries that were extracted from
    the ExtractRoomData function.  Takes as input an output
    Feature Class, the output fields and the nested list containing
    room data and geometries
    '''
    OutDatabase = r"Database Connections\FS_CEO.sde"
    cursor = arcpy.da.InsertCursor(OutFc, OutFcFields)
    for x in RoomList:
        print x
        cursor.insertRow((x[0], x[1], x[2]))
    del cursor

def ExtractGlobalID(OutFc, FacNum, RoomList):
    '''
    Grabs the system generated GlobalID from the Feature Class
    and appends it to the appropriate nested geometry list.  Requires
    the location fo the output feature class, the current FacNum and
    the geometry list.
    '''
    with arcpy.da.SearchCursor(OutFc, ["FEATURE_ID", "NOTES", "GlobalID"]) as Cursor:
        for Row in Cursor:
            if Row[1] == str(FacNum):
                for a in RoomList:
                    if a[1] == Row[0]:
                        a.append(Row[2])
                    else:
                        pass
            else:
                pass

def InsertTabular(OutTable, OutTableFields, RoomList):
    '''
    Populates the tabular data for the rooms that have been extracted.
    Retuires the location of the output table, the output fields and
    a nested list of the data that is to be populated.
    '''
    OutDatabase = r"Database Connections\FS_CEO.sde"
    cursor = arcpy.da.InsertCursor(OutTable, OutTableFields)
    for y in RoomList:
        cursor.insertRow((y[2], y[3], y[1], y[4]))
    del cursor

if __name__ == "__main__":
    main(OutFeatureClass, OutFeatureClassFields, OutTable, OutTableFields)

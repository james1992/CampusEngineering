############################################################################# 
### Jay Dahlstrom
### Campus Engineering, University of Washington
### January 13, 2014
###

############################################################################# 
### Description: The purpose of this script is to calculate the landscape
### area value of each maintenance zone on the University of Washington
### campus. A search cursor is used to extract the area and landscape type
### values from the landscape feature class these values are put through a 
### formula to determine the area value.  These values are then summed based
### upon the maintenance zone where the landscape polygons reside.  Those sums
### are exported and insert into the corresponding rows in the maintenance 
### zomes feature class, a new column is created each time this script is run.
### 

############################################################################# 
### Libraries
###

import arcpy

############################################################################# 
### Parameters
###

# File path to Landscape Feature Class
LandscapeGeoms       = r"C:\Users\jamesd26\Desktop\Python\Landscape\TESTS.gdb\Landscape"
# Area attribute column in Landscape feature class
LandscapeArea        = "SHAPE_Area"
# Type attribute column in Landscape feature class
LandscapeType        = "TYPE"
# Maintenance level attribute column in Landscape feature class
LandscapeLevel       = "LANDSCAPE_MAINT_LEVEL"
# Maintenance zone attribute column in Landscape feature class
LandscapeZone        = "Zone"
# File path to the Maintenance zone feature class
MaintenanceZoneGeoms = r"C:\Users\jamesd26\Desktop\Python\Landscape\TESTS.gdb\Zones"
# Maintenance Zone column in Maintenance Zone feature class
MaintenanceZone      = "ZONE_"
# Name of the column to contain area values for each zone
OutputZoneColumn     = input("Give the Output Column a Name (string): ")

#############################################################################  
###Script Follows
###

def main(LandscapeFC, AreaField, TypeField, LevelField, LandscapeZoneField, MaintenanceZoneFC, MaintenanceZoneField, NewColumn):
	ValueAndZone = SearchCursor(LandscapeFC, AreaField, TypeField, LevelField, LandscapeZoneField)
	ZoneValues = SumValues(ValueAndZone)
	print ZoneValues
	CreateNewField(MaintenanceZoneFC, NewColumn)
	UpdateCursor(MaintenanceZoneFC, MaintenanceZoneField, NewColumn, ZoneValues)
	print "done"
def SearchCursor(LandscapeFC, AreaField, TypeField, LevelField, ZoneField):
        '''

        '''
        ValuePair = []
        with arcpy.da.SearchCursor(LandscapeFC, [AreaField, TypeField, LevelField, ZoneField]) as cursor:
                for row in cursor:
                        if row[1] == 'Bed' or row[1] == 'Native':
                                if row[2] == 0:
                                        RowAreaValue = 0
                                elif row[2] == 1:
                                        RowAreaValue = ((row[0]/1000) * 0.03)
                                elif row[2] == 2:
                                        RowAreaValue = ((row[0]/1000) * 0.02)
                                elif row[2] == 3:
                                        RowAreaValue = ((row[0]/1000) * 0.019)
                                elif row[2] == 4:
                                        RowAreaValue = ((row[0]/1000) * 0.0019)
                                TempList = [row[3], RowAreaValue]
                                ValuePair.append(TempList)
                        elif row[1] == 'Lawn':
                                if row[2] == 0:
                                        RowAreaValue = 0
                                elif row[2] == 1:
                                        RowAreaValue = ((row[0]/1000) * 0.0078)
                                elif row[2] == 2:
                                        RowAreaValue = ((row[0]/1000) * 0.0052)
                                elif row[2] == 3:
                                        RowAreaValue = ((row[0]/1000) * 0.0026)
                                elif row[2] == 4:
                                        RowAreaValue = ((row[0]/1000) * 0.0014)
                                TempList = [row[3], RowAreaValue]
                                ValuePair.append(TempList)
                        else:
                                pass
        del row
        del cursor
        return ValuePair

def SumValues(ZoneValuePair):
        '''

        '''
        # Initialize zone sums
        ZoneOneSum   = 0
        ZoneTwoSum   = 0
        ZoneThreeSum = 0
        ZoneFourSum  = 0
        ZoneFiveSum  = 0
        ZoneSixSum   = 0
        ZoneSevenSum = 0
        ZoneEightSum = 0
        print len(ZoneValuePair)
        for entry in ZoneValuePair:
                if entry[0] == 1:
                        ZoneOneSum = ZoneOneSum + entry[1]
                if entry[0] == 2:
                        ZoneTwoSum = ZoneTwoSum + entry[1]
                if entry[0] == 3:
                        ZoneThreeSum = ZoneThreeSum + entry[1]
                if entry[0] == 4:
                        ZoneFourSum = ZoneFourSum + entry[1]
                if entry[0] == 5:
                        ZoneFiveSum = ZoneFiveSum + entry[1]
                if entry[0] == 6:
                        ZoneSixSum = ZoneSixSum + entry[1]
                if entry[0] == 7:
                        ZoneSevenSum = ZoneSevenSum + entry[1]
                if entry[0] == 8:
                        ZoneEightSum = ZoneEightSum + entry[1]
        return [[1,ZoneOneSum], [2,ZoneTwoSum], [3,ZoneThreeSum], [4,ZoneFourSum], [5,ZoneFiveSum], [6,ZoneSixSum], [7,ZoneSevenSum], [8,ZoneEightSum]]

def CreateNewField(FeatureClass, NewColumnName):
        '''

        '''
        arcpy.AddField_management(FeatureClass, NewColumnName, 'FLOAT', 10, 7)

def UpdateCursor(ZoneFeatureClass, ZoneField, NewColumnName, ValueList):
        '''

        '''
        with arcpy.da.UpdateCursor(ZoneFeatureClass, [ZoneField, NewColumnName]) as cursor:
                for row in cursor:
                        for item in ValueList:
                                if row[0] == item[0]:
                                        row[1] = item[1]
                                        cursor.updateRow(row)
        del row
        del cursor



if __name__ == "__main__":
    main(LandscapeGeoms, LandscapeArea, LandscapeType, LandscapeLevel, LandscapeZone, MaintenanceZoneGeoms, MaintenanceZone, OutputZoneColumn)


############################################################################# 
### Jay Dahlstrom
### Campus Engineering, University of Washington
### June 15, 2015
###

############################################################################# 
### Description: The purpose of this script is to calculate the landscape
### area value of each maintenance zone on the University of Washington
### campus. A search cursor is used to extract the area and landscape type
### values from the landscape feature class these values are put through a 
### formula to determine the number of hours required to maintain that landscape
### each year.  The values are assigned to "MAINTENANCE_HOURS" field for each
### landscape polyogon. Those same values are also aggregated based on the
### gardening zone that covers the polygon and those new sums are inserted into
### the "MAINTENANCE_HOURS" field for each zone, then the FTE field is calculated
### by dividing the hours by 1608, that gives the number of employees needed
### annually to keep up on maintenance.
### 

############################################################################# 
### Libraries
###

import arcpy
from arcpy import env

############################################################################# 
### Parameters
###

# File path to Landscape Feature Class
LandscapeGeoms       = r"Database Connections\IAMUW_REPLICATION.sde\MC_LANDSCAPEPROFILE"
# File path to Landscape Auxilliary Table
LandscapeTable       = r"Database Connections\IAMUW_REPLICATION.sde\MC_LANDSCAPEPROFILE_AUX"
# Area attribute column in Landscape feature layer
LandscapeArea        = "SHAPE.STArea()"
# Type attribute column in Landscape feature layer
LandscapeType        = "IAMUW_REPLICATION.DBO.MC_LANDSCAPEPROFILE.FEATURE_TYPE"
# Maintenance level attribute column in Landscape feature layer
LandscapeLevel       = "IAMUW_REPLICATION.DBO.MC_LANDSCAPEPROFILE_AUX.LANDSCAPE_MAINTENANCE_LEVEL"
# Maintenance zone attribute column in Landscape feature layer
LandscapeZone        = "IAMUW_REPLICATION.DBO.MC_LANDSCAPEPROFILE_AUX.ZONE"
# File path to the Maintenance Zone Aux table
MaintenanceZoneGeoms = r"Database Connections\IAMUW-FS_MAC.sde\MC_LANDSCAPEPROFILE_MAINTENANCE_ZONE_AUX"
# Maintenance Zone column in the Maintenance Zone Aux table
MaintenanceZone      = "ZONE"

#############################################################################  
###Script Follows
###

def main(LandscapeFC, LandscapeAux, AreaField, TypeField, LevelField, LandscapeZoneField, MaintenanceZoneFC, MaintenanceZoneField):
        # Create in memory feature layer
        CreateFeatureLayer(LandscapeFC, LandscapeAux)
        # Extract values from feature layer
        ValueAndZone = LandscapeSearchCursor(AreaField, TypeField, LevelField, LandscapeZoneField)
        # Aggregate hours by zone
        ZoneValues = SumValuesByZone(ValueAndZone)
        # Update Landscape Aux table
        LandscapeAuxUpdateCursor(r"Database Connections\IAMUW-FS_MAC.sde\MC_LANDSCAPEPROFILE_AUX", ValueAndZone)
        # Update Gardening Zone Aux Table with hours and FTE
        MaintenanceZoneUpdateCursor(MaintenanceZoneFC, MaintenanceZoneField, ZoneValues)
        print "done"

def CreateFeatureLayer(Geometries, Table):
        '''
        Function that will create an in memmory feature layer for
        use in this script.  Once the script is finished the
        feature layer is removed from system memory.
        '''
        env.workspace = r"Database Connections\IAMUW_REPLICATION.sde"
        arcpy.MakeFeatureLayer_management("MC_LANDSCAPEPROFILE", "Landscape_lyr")
        arcpy.MakeTableView_management("MC_LANDSCAPEPROFILE_AUX", "LandscapeAux_lyr")
        # Join geoms to table
        arcpy.AddJoin_management("Landscape_lyr", "GlobalID", "LandscapeAux_lyr", "REL_GUID", "KEEP_COMMON")

def LandscapeSearchCursor(AreaField, TypeField, LevelField, ZoneField):
        '''
        This function iterates through each row of the landscape profile
        feature class and if the row correpsonds to bed, lawn or native
        the function proceeds.  If the row meets that criteria then based
        on the maintenance level the area value for that row is divided by
        a predefined value and then the maintenance zone, maintenance value
        and relational GUID are added into a nested list.
        '''
        ValuePair = []
        with arcpy.da.SearchCursor("Landscape_lyr", [AreaField, TypeField, LevelField, ZoneField, "IAMUW_REPLICATION.DBO.MC_LANDSCAPEPROFILE_AUX.REL_GUID"]) as cursor:
                for row in cursor:
                        # if the landscape is either a lawn, bed or native then proceed
                        if row[1] == 1 or row[1] == 3 or row[1] == 4:
                                if row[2] == 0:
                                        RowAreaValue = 0
                                elif row[2] == 1:
                                        RowAreaValue = (row[0]/83.7)
                                elif row[2] == 2:
                                        RowAreaValue = (row[0]/125.5)
                                elif row[2] == 3:
                                        RowAreaValue = (row[0]/251.1)
                                elif row[2] == 4:
                                        RowAreaValue = (row[0]/502.2)
                                TempList = [row[3], RowAreaValue, row[4]]
                                ValuePair.append(TempList)
                        else:
                                pass
        del row
        del cursor
        return ValuePair

def SumValuesByZone(ZoneValuePair):
        '''
        This function takes the nested list from the LandscapeSearchCursor
        function and then based on the zone adds the maintenance value to
        the subsequent zome variable in the list.  That list is returned by
        the function.
        '''
        # Initialize zone sums
        ZoneValues = [[1,0],[2,0],[3,0],[4,0],[5,0],[6,0],[7,0],[8,0]]
        for entry in ZoneValuePair:
                if entry[0] == 1:
                        ZoneValues[0][1] = ZoneValues[0][1] + entry[1]
                if entry[0] == 2:
                        ZoneValues[1][1] = ZoneValues[1][1] + entry[1]
                if entry[0] == 3:
                        ZoneValues[2][1] = ZoneValues[2][1] + entry[1]
                if entry[0] == 4:
                        ZoneValues[3][1] = ZoneValues[3][1] + entry[1]
                if entry[0] == 5:
                        ZoneValues[4][1] = ZoneValues[4][1] + entry[1]
                if entry[0] == 6:
                        ZoneValues[5][1] = ZoneValues[5][1] + entry[1]
                if entry[0] == 7:
                        ZoneValues[6][1] = ZoneValues[6][1] + entry[1]
                if entry[0] == 8:
                        ZoneValues[7][1] = ZoneValues[7][1] + entry[1]
        return ZoneValues


def LandscapeAuxUpdateCursor(Table, ValueList):
        '''
        This function takes the nested list from the LandscapeSearchCursor
        and uses those values to update the rows in the aux table for each
        geometry.  To do this it uses the rel guid to identify the correct
        row and then inserts the maintenance value into the MAINTENANCE_HOURS
        field.
        '''
        # Initialize editing environment
        edit = arcpy.da.Editor(r"Database Connections\IAMUW-FS_MAC.sde")
        edit.startEditing(False, True)
        edit.startOperation()
        with arcpy.da.UpdateCursor(Table, ["REL_GUID", "MAINTENANCE_HOURS"]) as cursor:
                for row in cursor:
                        for item in ValueList:
                                # if the GUIDs match then proceed
                                if row[0] == item[2]:
                                        print item[2]
                                        row[1] = item[1]
                                        cursor.updateRow(row)
                                else:
                                        pass
        del row
        del cursor
        edit.stopOperation()
        # Stop editing and save changes
        edit.stopEditing(True)

def MaintenanceZoneUpdateCursor(GardenersZonesFC, ZoneField, ZoneValues):
        '''
        Function that takes the number of hours required for each
        gardening zone from the ZoneValues list and updates the
        respective row with the calculated hours, it then divides
        that number by 1608 to find the number of FTES needed per
        zone.
        '''
        # Initialize editing environment
        edit = arcpy.da.Editor(r"Database Connections\IAMUW-FS_MAC.sde")
        edit.startEditing(False, True)
        edit.startOperation()
        count = 0
        with arcpy.da.UpdateCursor(GardenersZonesFC, [ZoneField, "MAINTENANCE_HOURS", "FTES_REQUIRED"]) as cursor:
                for row in cursor:
                        for item in ZoneValues:
                                # if zones values match then proceed
                                if int(row[0]) == item[0]:
                                        print item[0]
                                        row[1] = item[1]
                                        row[2] = (item[1]/1608)
                                        cursor.updateRow(row)
                                else:
                                        pass
        del row
        del cursor
        edit.stopOperation()
        # Stop editing and save changes
        edit.stopEditing(True)


if __name__ == "__main__":
    main(LandscapeGeoms, LandscapeTable, LandscapeArea, LandscapeType, LandscapeLevel, LandscapeZone, MaintenanceZoneGeoms, MaintenanceZone)

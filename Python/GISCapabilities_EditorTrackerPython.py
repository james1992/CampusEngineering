############################################################################# 
### Created by Yurika Harada
### Engineering Services, University of Washington
### October 17, 2018
### 

############################################################################# 
### Description: Uses the Editor Tracker attribute column in shapefiles
### to collect the number of times that each shapefile has been edited within
### a selected number of days.

############################################################################# 
### Libraries
###

import os
import arcpy

############################################################################# 
### Parameters
###

print("script started")

fc = "C:\Users\ymharada\Documents\GitHub\CampusEngineering\FacilitiesMaintenance.gdb\GroundsBollard"
field = "Material"
cursor = arcpy.SearchCursor(fc,fields="Material;last_edited_date")
row = cursor.next()
while row:
    print(row.getValue(field))
    row = cursor.next()
	
print("script finished")
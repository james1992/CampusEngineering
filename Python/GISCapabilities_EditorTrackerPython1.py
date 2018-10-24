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
#prints everything, is not currently correct.
print("script started")
fc = "C:\Users\ymharada\Desktop\FacilitiesMaintenance.gdb\AdaAccessPoints"
field = ["last_edited_date"]

DatesEdited=[]
with arcpy.da.SearchCursor(fc, field) as cursor:
	for row in cursor:
		from datetime import datetime, date
		d = [2018,03,01]
 		if [datetime(d[0], d[1], d[2]) >= row[0]]:
		    DatesEdited.append([row[0], field[1]])  		
		    print "DatesEdited = {0}".format(row[0])          
	del row
	del cursor			
print("script finished")

############################################################################# 
### Jay Dahlstrom
### Engineering Services, University of Washington
### November 7, 2018
###

############################################################################# 
### Description: Tabulates the number of edits made to each project in the user
### specified quarter and year.  These sums are returned by the script in the
### form of a csv file on the user's desktop with rows for each project.
### 


############################################################################# 
### Libraries
###

import arcpy
from datetime import datetime as dt

############################################################################# 
### Parameters
###

quarter = 4
year = 2018
projects = [["Catch Basin Inspections", "Managed", [r'Database Connections\FacilitiesMaintenance.sde\GroundsCatchBasins']],
            ["Tree Inventory", "Maintained",[r'Database Connections\FacilitiesMaintenance.sde\GroundsTrees', r'Database Connections\FacilitiesMaintenance.sde\GroundsTreesDesignation',r'Database Connections\FacilitiesMaintenance.sde\GroundsTreesMaintenance', r'Database Connections\FacilitiesMaintenance.sde\GroundsTreesSalvage']]

            ]

#############################################################################  
###Script Follows
###

def main(quarter, year, projects):
    formattedBeginDate, formattedEndDate = DateRangeCalculator(quarter, year)
    SearchCursor(projects, ["last_edited_date"], formattedBeginDate, formattedEndDate)

def DateRangeCalculator(quarter, year):
    '''

    '''
    beginDate = ''
    endDate = ''
    if quarter == 1:
        beginDate = "{}/1/1".format(str(year))
        endDate = "{}/3/31".format(str(year))
    elif quarter == 2:
        beginDate = "{}/4/1".format(str(year))
        endDate = "{}/6/30".format(str(year))
    elif quarter == 3:
        beginDate = "{}/7/1".format(str(year))
        endDate = "{}/9/30".format(str(year))
    else:
        beginDate = str('{}/10/1'.format(str(year)))
        endDate = str('{}/12/31'.format(str(year)))
    formattedBeginDate = dt.strptime(beginDate, "%Y/%m/%d").date()
    formattedEndDate = dt.strptime(endDate, "%Y/%m/%d").date()
    
    return formattedBeginDate, formattedEndDate

def SearchCursor(projects, fields, beginDate, endDate):
    '''

    '''
    projectEdits = []
    for project in projects:
        countEdits = 0
        countRows = 0
        for item in project[2]:
            with arcpy.da.SearchCursor(item, fields) as cursor:
                for row in cursor:
                    countRows += 1
                    editDate = row[0].date()
                    if beginDate <= editDate <= endDate:
                        countEdits += 1
                    else:
                        pass
        projectEdits.append([project[0], project[1], countEdits, countRows, round((float(countEdits)/countRows),3)])
    print projectEdits

	
if __name__ == "__main__":
    main(quarter, year, projects)

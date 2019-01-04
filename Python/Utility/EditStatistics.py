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
import csv

############################################################################# 
### Parameters
###


print "The script will only work from 2018-Q4 forward, previous quarters and years lack sufficient data."
year = input("What year do you want to review?")
quarter = input("What quarter (1,2,3,4) in the provided year do you want to review?")

# Project list formatted project name, type, [nested list of tables], notes
projects = [["Catch Basin Inspections", "Managed", [r'Database Connections\FacilitiesMaintenance.sde\GroundsCatchBasins', r'Database Connections\FacilitiesMaintenance.sde\GroundsCatchBasinsInspectionForm'], ""],
            ["Oil Container Inspections","Managed",[r'Database Connections\EngineeringServices.sde\EnvironmentalOilSpillPrevention', r'Database Connections\EngineeringServices.sde\EnvironmentalOilSpillPreventionInspections'], ""],
            ["Confidence Tests","Managed",[r'Database Connections\CampusEngineeringOperations.sde\ConfidenceTests', r'Database Connections\CampusEngineeringOperations.sde\ConfidenceTestsInspections', r'Database Connections\CampusEngineeringOperations.sde\ConfidenceTestsMaintenance'], ""],
            ["AHU Inventory","Managed",[r'Database Connections\CampusEngineeringOperations.sde\AirHandlingUnits', r'Database Connections\CampusEngineeringOperations.sde\AirHandlingUnitsInspections'], ""],
            ["Tree Inventory", "Maintained",[r'Database Connections\FacilitiesMaintenance.sde\GroundsTrees', r'Database Connections\FacilitiesMaintenance.sde\GroundsTreesDesignation',r'Database Connections\FacilitiesMaintenance.sde\GroundsTreesMaintenance', r'Database Connections\FacilitiesMaintenance.sde\GroundsTreesSalvage'], ""],
            ["Fire Extinguishers","Maintained",[r'Database Connections\CampusEngineeringOperations.sde\FireExtinguishers'],"Check non-ESRI tables"],
            ["Access Guide","Maintained", [r'Database Connections\EngineeringServices.sde\AdaAccessPoints', r'Database Connections\EngineeringServices.sde\AdaAccessRoutes', r'Database Connections\EngineeringServices.sde\AdaAnnotations', r'Database Connections\EngineeringServices.sde\AdaBuildingInformation', r'Database Connections\EngineeringServices.sde\AdaLandscape'], ""],
            ["Site Lighting","Maintained", [r'Database Connections\EngineeringServices.sde\ElectricalSiteLightingBuildingLights', r'Database Connections\EngineeringServices.sde\ElectricalSiteLightingConduit', r'Database Connections\EngineeringServices.sde\ElectricalSiteLightingContactors', r'Database Connections\EngineeringServices.sde\ElectricalSiteLightingGroundPacks', r'Database Connections\EngineeringServices.sde\ElectricalSiteLightingLights'
                                            , r'Database Connections\EngineeringServices.sde\ElectricalSiteLightingPhotocell', r'Database Connections\EngineeringServices.sde\ElectricalSiteLightingSplice', r'Database Connections\EngineeringServices.sde\ElectricalSiteLightingUtilityPoles'], ""],
            ["Bench Inventory","Maintained", [r'Database Connections\FacilitiesMaintenance.sde\GroundsBench'], ""],
            ["Bollard Inventory","Maintained", [r'Database Connections\FacilitiesMaintenance.sde\GroundsBollard'], ""],
            ["Grounds Fieldwork","Maintained", [r'Database Connections\FacilitiesMaintenance.sde\GroundsFieldwork'], ""],
            ["Irrigation Controllers","Maintained", [r'Database Connections\FacilitiesMaintenance.sde\GroundsIrrigationControllers'], ""],
            ["Landscape Evaluations","Maintained", [r'Database Connections\FacilitiesMaintenance.sde\GroundsLandscapeEvaluations'], ""],
            ["Invasive Species Management","Maintained", [r'Database Connections\FacilitiesMaintenance.sde\GroundsPesticideApplications', r'Database Connections\FacilitiesMaintenance.sde\GroundsPlantDisease', r'Database Connections\FacilitiesMaintenance.sde\GroundsPlantDiseasePlots', r'Database Connections\FacilitiesMaintenance.sde\GroundsWeedsControlRecommended',
                                                          r'Database Connections\FacilitiesMaintenance.sde\GroundsWeedsEradicationRequired', r'Database Connections\FacilitiesMaintenance.sde\GroundsWeedsMonitorList'], ""],
            ["Snow Removal","Maintained", [r'Database Connections\FacilitiesMaintenance.sde\GroundsSnowRemoval'], ""],
            ["Bike Inventory","Maintained", [r'Database Connections\TransportationServices.sde\BikeLockersAndHouses',r'Database Connections\TransportationServices.sde\BikeRackGroups',r'Database Connections\TransportationServices.sde\BikeRackGroupsCounts',r'Database Connections\TransportationServices.sde\BikeRackIndividual',r'Database Connections\TransportationServices.sde\BikeRoomsInBuildings',r'Database Connections\TransportationServices.sde\BikesAbandoned'], ""]
            ]

#############################################################################  
###Script Follows
###

def main(quarter, year, projects):
    formattedBeginDate, formattedEndDate = DateRangeCalculator(quarter, year)
    projectEdits = SearchCursor(projects, ["last_edited_date"], formattedBeginDate, formattedEndDate)
    ExportToCSV(projectEdits)

def DateRangeCalculator(quarter, year):
    '''
    Function that takes a quarter number (1,2,3,4) and a
    year as integers and returns the start and end dates of
    the provided quarter in the given year.
    '''
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
    # Format the dates for comparison
    formattedBeginDate = dt.strptime(beginDate, "%Y/%m/%d").date()
    formattedEndDate = dt.strptime(endDate, "%Y/%m/%d").date()
    
    return formattedBeginDate, formattedEndDate

def SearchCursor(projects, fields, beginDate, endDate):
    '''
    Function that takes a nested list of projects, a search field
    and the start and end dates of the desired quarter and then
    returns a nested list of projects with the number of edits
    made in the quarter along with the number of rows and percent
    editted in that time,
    '''
    projectEdits = []
    for project in projects:
        countEdits = 0
        countRows = 0
        # Iterate through all feature classes/tables
        for item in project[2]:
            with arcpy.da.SearchCursor(item, fields) as cursor:
                for row in cursor:
                    countRows += 1
                    # If there is no last edit date then pass
                    if row[0] == None:
                        pass
                    else:
                        # Remove the time component from last edit for comparison purposes
                        editDate = row[0].date()
                        if beginDate <= editDate <= endDate:
                            countEdits += 1
                        else:
                            pass
        projectEdits.append([project[0], project[1], countEdits, countRows, round((float(countEdits)/countRows),3), project[3]])
    return projectEdits

def ExportToCSV(projectEdits):
    '''
    Function that takes the nested list produced by the SearchCursor
    and put those values into a CSV file for import into the BSC
    measure.
    '''
    with open("editsReport.csv", 'wb') as csvfile:
        filewriter = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        filewriter.writerow(['Project', 'Type', 'CountEdits', 'CountRows', 'PercentEdit', 'Notes'])
        for row in projectEdits:
            filewriter.writerow([row[0], row[1], row[2], row[3], row[4], row[5]])
	
if __name__ == "__main__":
    main(quarter, year, projects)

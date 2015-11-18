############################################################################# 
### Jay Dahlstrom
### Campus Engineering, University of Washington
### November 17, 2015
###

############################################################################# 
### Description: This script is designed to take information that has been
### collected in the field about the accuracy of storm and sewer lid labels
### identify where lids can be moved to in order to fix lids that have 
### inaccurate labels. In this way a manhole for a sewer system with a label
### that reads 'Drain' can be swapped out for a storm water manhole that reads
### 'Sewer'.  In so doing each manhole will have the correct label.  This is 
### the first set of information returned by this script.  Now it is likely
### that not all lids will have a viable replacement on campus, in these
### situations it will be necessary to purchase new lids for these areas.
### The script will return the number of lids that need to be purchased and
### which manholes they will be used on.  In both cases maps will be created
### to provide context for which lids are referenced in the output.


############################################################################# 
### Libraries
###

import arcpy
from arcpy import env
import os

############################################################################# 
### Parameters
###

"Should move some variables up here"

#############################################################################  
###Script Follows
###

def main():
    # Creates the working fodler and geodatabase for the script.
    CreateWorkingArea()

    # Copies the data from the spatial view in ArcSDE and exports
    # it to the temprary geodatabase.
    FeatureClass = CreateTempFeatureClass()

    # Extract data required for analysis from the feature class for
    # use in the next section of this script
    ExtractData(FeatureClass)


    # Removes the geodatabase and folder from the computer.
    #RemoveGdbFolder()


# Create Folder and GDB

def CreateWorkingArea():
    '''
    Function that creates a folder and file geodatabase that will be
    used as the working area for this script
    '''
    OutFolder = r"C:\Users\jamesd26\Desktop\GDB"
    OutName = "Manhole"
    
    os.makedirs(OutFolder)
    arcpy.CreateFileGDB_management(OutFolder, OutName)


# Setting up the Data


def CreateTempFeatureClass():
    '''
    Function that calls three other functions that are used to create
    a new feature class from the civil man hole view in ArcSDE.  The
    new feature class will be used by this script to perform calculations
    without the worry of harming the production data.
    '''
    FeatureClass = ExportView()
    AddGlobalID(FeatureClass)
    AddCoordinates(FeatureClass)

    return FeatureClass
    
def ExportView():
    '''
    Exports the spatial view from the ArcSDE database to a local
    File GDB on the computer.  Note: there needs to be a connection
    to the database PUB_IAMUW_REPLICATION in ArcCatalog on the machine
    that is running this script.
    '''
    env.workspace = r"Database Connections\PUB-REPLICATION.sde"
    
    InFeatureClass = "VIEW_CIVIL_MANHOLE_INSPECTION"
    OutLocation = r"C:\Users\jamesd26\Desktop\GDB\Manhole.gdb"
    OutFeatureClass = "Data"
    
    arcpy.FeatureClassToFeatureClass_conversion(InFeatureClass, OutLocation, OutFeatureClass)
    NewFeatureClass = os.path.join(OutLocation, OutFeatureClass)
    return NewFeatureClass

def AddGlobalID(Dataset):
    '''
    Creates and populates a GlobalID Column in the output feature class
    that was created in the ExportView function.
    '''
    arcpy.AddGlobalIDs_management(Dataset)
    
def AddCoordinates(Dataset):
    '''
    Adds and populates X and Y fields in the newly created feature class
    from the ExportView function.  This function requires the location of
    a feature class to run correctly.
    '''
    arcpy.AddXY_management(Dataset)
    IndentifyLidstoMove()
# Extracting the Data


def ExtractData(Dataset):
    '''
    Function that calls other functions that are used to extract the required
    data from the working feature class that was created by this script.  Data
    for lids with wrong labels (for both sewer and storm systems) is collected
    along with data for lids that need to be moved.  In total four nested lists
    are returned for use in the calculations that will follow.
    '''
    WrongSewerLabels, WrongStormLabels = IdentifyLidsWithWrongLabels(Dataset)
    
def IdentifyLidsWithWrongLabels(Dataset):
    '''
    Identifies the manhole lids that have wrong labels for a given system
    (either storm or sewer) and places them into a nested list ((GlobalID,
    X, Y), (GlobalID, X, Y)....).  Uses an ArcPy Search Cursor.
    '''
    Fields = ["GlobalID", "System", "CorrectLabel", "POINT_X","POINT_Y"]
    WrongLidListSewer = []
    WrongLidListStorm = []

    SewerList = SearchCursorWrongLabels(Dataset, Fields, WrongLidListSewer, 'Sewer', 'No')
    StormList = SearchCursorWrongLabels(Dataset, Fields, WrongLidListStorm, 'Storm', 'No')

    return SewerList, StormList

def SearchCursorWrongLabels(Dataset, AttributeFields, NestedList, System, WhereCluase):
    '''
    Runs a search cursor against an input feature class and fields
    with a where clause.  This cursor is designed to be used for identifying
    manhole lids with wrong labels.  The results are returned as a nested list.
    '''
    with arcpy.da.SearchCursor(Dataset, AttributeFields) as Cursor:
        for Row in Cursor:
            if Row[1] == System and Row[2] == WhereCluase:
                TempList = [Row[0], Row[1], Row[3], Row[4]]
                NestedList.append(TempList)
            else:
                pass
    return NestedList

    
def IndentifyLidstoMove():
    '''
    Identifies lids that need to be moved to a different man hole on campus,
    these are lids that cover manholes that also have inaccurate labels.
    The lids will be placed into nested lists (GlobalID, X, Y), (GlobalID,
    X, Y)....) based upon the type of label they have.
    '''
    Fields = ["GlobalID", "System", "CorrectLabel", "POINT_X","POINT_Y"]

    



# Calculate Distances


def CalculateDistanceBetweenPoints():
    '''
    Uses the formula SQRT((y2-y1)2 +(x2-x1)2) to calculate distances
    between a lid with a wrong label and a lid with a correct label
    that needs to be moved.  Returns a nested list where each lid
    to be moved is grouped with lids that it could be moved to with
    the distance between them.  The format of the nested is (GlobalID
    [LidtoMove], ((GlobalID[WrongLabel], Distance), (GlobalID[WrongLabel],
    Distance), ....).
    '''

def GroupDistancePairs():
    '''
    Takes the value pairs from the CalculateDistanceBetweenPoints along
    with two lists and groups the pairs in the first list by Lid to Move
    (Wrong lid, Wrong lid...) and in the second by Wrong Lid (Lid to Move,
    Lid to Move).
    '''

# Analyze the Data


def RemoveDistancesOver2500():
    '''
    Removes any list pairs from the nested list that was returned by
    the CalculateDistanceBetweenPoints functions that have a distance
    greater than 2500 feet.  This is done to limit the number of options
    for a given man hole to those that are a reasonable distance away.
    '''

def SelectLidToMove():
    '''
    Selects the lid that will be moved to each manhole that has an
    incorrect label.  The pair of wrong label to label to move will
    be returned as a nested list.
    '''

def ListLidsAlreadySelected():
    '''
    Creates a list that identifies manhole lids that were previously
    selected in the SelectLidToMove function to be moved to a wrong label.
    Each lid can only be moved once so they need to be removed from the
    list of available options.
    '''


# Returning Results


def ReturnLidsToMoveWithoutMatches():
    '''
    Returns any lids to move that were not matched with a manhole that
    had an incorrect label.
    '''

def ReturnLidsWrongLabelsWithoutMatches():
    '''
    Returns any manholes that have an incorrect label that were not
    matched to a lid to move.
    '''

# Creating Maps



# Clean up Data


def RemoveGdbFolder():
    '''
    Removes the folder and geodatabase that were created at the start
    of this script.  Once the script has successfully run they are no
    longer needed.
    '''
    arcpy.Delete_management(r"C:\Users\jamesd26\Desktop\GDB\Manhole.gdb")
    os.rmdir(r"C:\Users\jamesd26\Desktop\GDB")

	
if __name__ == "__main__":
    main()

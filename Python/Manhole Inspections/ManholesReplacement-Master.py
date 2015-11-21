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
from operator import itemgetter
import math
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
    #CreateWorkingArea()

    # Copies the data from the spatial view in ArcSDE and exports
    # it to the temprary geodatabase.
    #FeatureClass = CreateTempFeatureClass()

    # Extract data required for analysis from the feature class for
    # use in the next section of this script
    FeatureClass = "C:\Users\jamesd26\Desktop\GDB\Manhole.gdb\Data"
    SewerLidsWrongLabel, StormLidsWrongLabel, SewerLidsMove, StormLidsMove = ExtractData(FeatureClass)

    # Calculate the distances between points to move and lids with
    # wrong labels.  Do this for both storm and sewer systems. SortedSewerLidsWrongLabel,
    SortedStormLidsWrongLabel  = PerformCalculations(SewerLidsWrongLabel, StormLidsWrongLabel, SewerLidsMove, StormLidsMove)

    # Determine lid to move based on shortest distance
    #SewerLidPairs = SelectLidToMove(SortedSewerLidsWrongLabel)
    StormLidPairs = SelectLidToMove(SortedStormLidsWrongLabel)
    print StormLidPairs
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
    WrongSewerLids, WrongStormLids = IdentifyLidsWithWrongLabels(Dataset)
    SewerLidsToMove, StormLidsToMove = IndentifyLidstoMove(Dataset)

    return WrongSewerLids, WrongStormLids, SewerLidsToMove, StormLidsToMove
    
def IdentifyLidsWithWrongLabels(Dataset):
    '''
    Identifies the manhole lids that have wrong labels for a given system
    (either storm or sewer) and places them into a nested list ((GlobalID,
    X, Y), (GlobalID, X, Y)....).  Uses an ArcPy Search Cursor.
    '''
    Fields = ["GlobalID", "System", "CorrectLabel", "POINT_X","POINT_Y"]

    SewerList = SearchCursorWrongLabels(Dataset, Fields, 'Sewer', 'No')
    StormList = SearchCursorWrongLabels(Dataset, Fields, 'Storm', 'No')

    return SewerList, StormList

def SearchCursorWrongLabels(Dataset, AttributeFields, System, CorrectLabel):
    '''
    Runs a search cursor against an input feature class and fieldswith a
    where clause.  This cursor is designed to be used for identifying
    manhole lids with wrong labels.  The results are returned as a nested list.
    '''
    NestedList = []
    with arcpy.da.SearchCursor(Dataset, AttributeFields) as Cursor:
        for Row in Cursor:
            if Row[1] == System and Row[2] == CorrectLabel:
                TempList = [Row[0], Row[1], Row[3], Row[4]]
                NestedList.append(TempList)
            else:
                pass
    return NestedList

    
def IndentifyLidstoMove(Dataset):
    '''
    Identifies lids that need to be moved to a different man hole on campus,
    these are lids that cover manholes that also have inaccurate labels.
    The lids will be placed into nested lists (GlobalID, X, Y), (GlobalID,
    X, Y)....) based upon the type of label they have.
    '''
    Fields = ["GlobalID", "System", "CorrectLabel", "TypeOfLabel", "SquareLid", "POINT_X","POINT_Y"]

    StormMoveList = SearchCursorLidsToMove(Dataset, Fields, 'Sewer', 'No', 'Drain', 'No')
    StormMoveList = StormMoveList + SearchCursorLidsToMove(Dataset, Fields, 'Sewer', 'No', 'Storm', 'No')
    
    SewerMoveList = SearchCursorLidsToMove(Dataset, Fields, 'Storm', 'No', 'Sewer', 'No')

    return SewerMoveList, StormMoveList

def SearchCursorLidsToMove(Dataset, AttributeFields, System, CorrectLabel, LabelType, SquareLid):
    '''
    Runs a search cursor against an input feature class and fieldswith a
    where clause.  This cursor is designed to be used to identify manhole lids
    that have wrong labels that can be moved.  The restuls are returned as a
    nested list.
    '''
    NestedList = []
    with arcpy.da.SearchCursor(Dataset, AttributeFields) as Cursor:
        for Row in Cursor:
            if Row[1] == System and Row[2] == CorrectLabel and Row[3] == LabelType and Row[4] == SquareLid:
                TempList = [Row[0], Row[3], Row[5], Row[6]]
                NestedList.append(TempList)
            else:
                pass
    return NestedList

# Calculate Distances


def PerformCalculations(SewerLidsWrongLabel, StormLidsWrongLabel, SewerLidsMove, StormLidsMove):
    '''
    Function that calls other functions that are used to calculate and log the
    distances between lids that can be moved and lids with wrong labels. Data
    is returned in a sorted list (shortest to longest distance).  This is done
    for two lists, one that is order by Lids to Move and the other by Lids
    with Wrong labels which will provide to ways to look at the data.
    '''
    #SortedSewerLidsWrongLabel = CalculateDistanceBetweenPoints(SewerLidsWrongLabel, SewerLidsMove)
    SortedStormLidsWrongLabel = CalculateDistanceBetweenPoints(StormLidsWrongLabel, StormLidsMove)
    #SortedSewerLidsWrongLabel
    return SortedStormLidsWrongLabel

def CalculateDistanceBetweenPoints(LidWrongLabel, LidToMove):
    '''
    Uses the formula SQRT((y2-y1)2 +(x2-x1)2) to calculate distances
    between a lid with a wrong label and a lid with a correct label
    that needs to be moved.  Returns a nested list where each lid
    to be moved is grouped with lids that it could be moved to with
    the distance between them.  The format of the nested is (GlobalID
    [LidtoMove], ((GlobalID[WrongLabel], Distance), (GlobalID[WrongLabel],
    Distance), ....).
    ''' 
    LidsWrongLabels = {}

    if len(LidToMove) == 0:
        for WrongLid in LidWrongLabel:
            LidID = WrongLid[0]
            LidsWrongLabels[LidID] = 'None'
        return LidsWrongLabels
    else:
        for MoveLid in LidToMove:
            for WrongLid in LidWrongLabel:
                Xdistance = math.pow((MoveLid[2]-WrongLid[2]),2)
                Ydistance = math.pow((MoveLid[3]-WrongLid[3]),2)
                Sum = Ydistance + Xdistance
                Distance = math.sqrt(Sum)
                GroupDistancePairs(LidsWrongLabels, WrongLid[0], MoveLid[0], Distance)

        SortedLidsWrong = CreateSortedDistanceLists(LidsWrongLabels)
        return SortedLidsWrong
    
    
def GroupDistancePairs(GuidDictionary, PrimaryGuid, SecondaryGuid, Distance):
    '''
    Takes the value pairs from the CalculateDistanceBetweenPoints along
    with two lists and groups the pairs in the first list by Lid to Move
    (Wrong lid, Wrong lid...) and in the second by Wrong Lid (Lid to Move,
    Lid to Move).
    '''
    if PrimaryGuid in GuidDictionary.keys():
        AdditionalDistanceList = [SecondaryGuid, Distance]
        GuidDictionary[PrimaryGuid].append(AdditionalDistanceList)
    else:
        FirstDistanceList = [SecondaryGuid, Distance]
        GuidDictionary[PrimaryGuid] = []
        GuidDictionary[PrimaryGuid].append(FirstDistanceList)

def CreateSortedDistanceLists(LidDictionary):
    '''
    Takes the values of nested lists and returns a list that is sorted
    by distance (shortest distance to longest).
    '''
    SortedDictionary = {}
    for Lid in LidDictionary:
        PairsList = LidDictionary[Lid]
        PairsList.sort(key=itemgetter(1))
        SortedDictionary[Lid] = PairsList
    return SortedDictionary

def RecordShortestDistanceToMove(ShortestDistanceDict, LidToMove, Distance):
    '''
    Uses a dictionary to record the shortest distance that a lid that can
    be moved needs to go to a lid with a wrong label.  This way lids will
    be moved the shortest distance possible.
    '''
    if LidToMove in ShortestDistanceDict.keys():
        if Distance < ShortestDistanceDict[LidToMove]:
            ShortestDistanceDict[LidToMove] = Distance
        else:
            pass
    else:
        ShortestDistanceDict[LidToMove] = Distance


# Analyze the Data


def SelectLidToMove(SortedLidsWrongLabel):
    '''
    Selects the lid that will be moved to each manhole that has an
    incorrect label.  The pair of wrong label to label to move will
    be returned as a nested list.
    '''
    PairDict = {}
    NoMatches = []
    for Lid in SortedLidsWrongLabel:
        MoveLidOptions = SortedLidsWrongLabel[Lid]
        print MoveLidOptions
        Count = 0
        if len(MoveLidOptions) == 0:
            PairDict[Lid] = ['None', 'N/A']
        elif MoveLidOptions == 'None':
            PairDict[Lid] = 'None'            
        else:
            for Choice in MoveLidOptions:
                if Count == 0:
                    PairDict[Lid] = [Choice[0], Choice[1]]
                    #print PairDict
                    Count = Count + 1
                    RemoveLidsAlreadySelected(SortedLidsWrongLabel, Choice[0])
                else:
                    pass
    return PairDict

def RemoveLidsAlreadySelected(SortedLidsWrongLabels, LidMoved):
    '''
    Creates a list that identifies manhole lids that were previously
    selected in the SelectLidToMove function to be moved to a wrong label.
    Each lid can only be moved once so they need to be removed from the
    list of available options.
    '''
    for Lid in SortedLidsWrongLabels:
        MoveLidList = SortedLidsWrongLabels[Lid]
        for Item in MoveLidList:
            if Item[0] == LidMoved:
                MoveLidList.remove(Item)
            else:
                pass
        SortedLidsWrongLabels[Lid] = MoveLidList


#####
#####
##### Good through here.
#####
#####

# Create Maps and Return Results


def ReturnLidsWrongLabelsWithoutMatches():
    '''
    Returns any manholes that have an incorrect label that were not
    matched to a lid to move.
    '''



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

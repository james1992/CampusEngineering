############################################################################# 
### Jay Dahlstrom
### Campus Engineering, University of Washington
### November 23, 2015
###

############################################################################# 
### Description: This script is designed to take information that has been
### collected in the field about the accuracy of storm and sewer manhole labels
### and identify where lids can be moved to in order to fix lids that have 
### inaccurate labels. In this way a manhole for a sewer system with a label
### that reads 'Drain' can be swapped out for a storm water manhole that reads
### 'Sewer'.  Distances between the matched manholes will also be recorded using
### US Survey Feet. In so doing each manhole will have the correct label.  This is 
### the first set of information returned by this script.  Now it is likely
### that not all lids will have a viable replacement on campus, in these
### situations it will be necessary to purchase new lids for these areas.
### The script will return the number of lids that need to be purchased and
### which manholes they will be used on.  In both cases maps will be created
### to provide context for which lids are referenced in the output.
###
### A secondary product of this script is maps that identify newly located
### manholes that were not on Jim's list and manholes that were on Jim's list
### but that could not be located in the field.


############################################################################# 
### Libraries
###

import arcpy
from arcpy import env
import datetime
from operator import itemgetter
import math
import os

############################################################################# 
### Parameters
###

# No parameters are required for this script

#############################################################################  
###Script Follows
###

def main():
    # Creates the working folder and geodatabase for the script.
    CreateWorkingArea()

    # Copies the data from the spatial view in ArcSDE and exports
    # it to the temprary geodatabase.  This copy will be used by the script
    FeatureClass = CreateTempFeatureClass()

    # Extract data required for analysis from the feature class for
    # use in the next section of this script
    FeatureClass = "C:\Users\jamesd26\Desktop\GDB\Manhole.gdb\Data"
    SewerLidsWrongLabel, StormLidsWrongLabel, SewerLidsMove, StormLidsMove = ExtractData(FeatureClass)

    # Calculate the distances between points to move and lids with
    # wrong labels.  Do this for both storm and sewer systems.
    SortedSewerLidsWrongLabel, SortedStormLidsWrongLabel  = PerformCalculations(SewerLidsWrongLabel, StormLidsWrongLabel, SewerLidsMove, StormLidsMove)

    # Determine the lid to move based on the shortest distance
    SewerLidPairs = PerformAnalysis(SortedSewerLidsWrongLabel)
    StormLidPairs = PerformAnalysis(SortedStormLidsWrongLabel)
    
    # Create end products for Jim, includes maps and feature classes
    AddFc, UnknownFc, WrongSewerFc, WrongStormFc = CreateDeliverables(FeatureClass, SewerLidPairs, StormLidPairs)

    # Updates the data sources for layers in maps used for reports
    UpdateMapDataSources(AddFc, UnknownFc, WrongSewerFc, WrongStormFc)    
    
    # Removes the working geodatabase and folder from the computer.
    RemoveGdbFolder()


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
    a new feature class from the civil manhole view in ArcSDE.  The
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
    File GDB on this computer.  Note: there needs to be a connection
    to the database PUB_IAMUW_REPLICATION in ArcCatalog on the machine
    that is running this script.
    '''
    # Location that contains the spatial view
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
    that was created in the ExportView function.  This function requires the
    location of the feature class to run correctly.
    '''
    arcpy.AddGlobalIDs_management(Dataset)
    
def AddCoordinates(Dataset):
    '''
    Adds and populates X and Y fields in the newly created feature class
    from the ExportView function.  This function requires the location of
    the feature class to run correctly.
    '''
    arcpy.AddXY_management(Dataset)

    
# Extracting the Data for Analysis


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
    (either storm or sewer) and places them into a nested list [[GlobalID,
    X, Y], [GlobalID, X, Y]....].  Uses an ArcPy Search Cursor.
    '''
    Fields = ["GlobalID", "System", "CorrectLabel", "POINT_X","POINT_Y"]

    SewerList = SearchCursorWrongLabels(Dataset, Fields, 'Sewer', 'No')
    StormList = SearchCursorWrongLabels(Dataset, Fields, 'Storm', 'No')

    return SewerList, StormList

def SearchCursorWrongLabels(Dataset, AttributeFields, System, CorrectLabel):
    '''
    Runs a search cursor against an input feature class and fields with a
    where clause.  This cursor is designed to be used for identifying
    manhole lids with wrong labels.  The results are returned as a nested list.
    '''
    NestedList = []
    with arcpy.da.SearchCursor(Dataset, AttributeFields) as Cursor:
        for Row in Cursor:
            # If the where clause is true then proceed
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
    The lids will be placed into nested lists [[GlobalID, X, Y], [GlobalID,
    X, Y]....] based upon the type of label they have.
    '''
    Fields = ["GlobalID", "System", "CorrectLabel", "TypeOfLabel", "SquareLid", "POINT_X","POINT_Y"]

    StormMoveList = SearchCursorLidsToMove(Dataset, Fields, 'Sewer', 'No', 'Drain', 'No')
    StormMoveList = StormMoveList + SearchCursorLidsToMove(Dataset, Fields, 'Sewer', 'No', 'Storm', 'No')
    
    SewerMoveList = SearchCursorLidsToMove(Dataset, Fields, 'Storm', 'No', 'Sewer', 'No')

    return SewerMoveList, StormMoveList

def SearchCursorLidsToMove(Dataset, AttributeFields, System, CorrectLabel, LabelType, SquareLid):
    '''
    Runs a search cursor against an input feature class and fields with a
    where clause.  This cursor is designed to be used to identify manhole lids
    that have wrong labels that can be moved.  The results are returned as a
    nested list.
    '''
    NestedList = []
    with arcpy.da.SearchCursor(Dataset, AttributeFields) as Cursor:
        for Row in Cursor:
            # If the where clause is true then proceed
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
    is returned using nested dictionaries that match the lid with the wrong label
    as the outter most key to lids that can be moved, where the value of each key
    is a nested and sorted list (from shortest distance to longest).  This is done for
    each system (sewer and storm).
    '''
    SortedSewerLidsWrongLabel = CalculateDistanceBetweenPoints(SewerLidsWrongLabel, SewerLidsMove)
    SortedStormLidsWrongLabel = CalculateDistanceBetweenPoints(StormLidsWrongLabel, StormLidsMove)

    return SortedSewerLidsWrongLabel, SortedStormLidsWrongLabel

def CalculateDistanceBetweenPoints(LidWrongLabel, LidToMove):
    '''
    Uses the formula SQRT((y2-y1)^2 +(x2-x1)^2) to calculate distances
    between a lid with a wrong label and a lid with a correct label
    that needs to be moved.  Returns a nested dictionary where each lid
    with a wrong label is grouped with lids that can be moved using a key
    and value pair (as described above).  The format of the nested is {GlobalID
    [WrongLabel]: ((GlobalID[LidToMove], Distance), (GlobalID[LidToMove],
    Distance), ....}.
    ''' 
    LidsWrongLabels = {}
    # If initial list of lids to move is empty then they do not go through sorting/calculations
    if len(LidToMove) == 0:
        for WrongLid in LidWrongLabel:
            LidID = WrongLid[0]
            LidsWrongLabels[LidID] = 'None'
        return LidsWrongLabels
    # If there is at least one lid to move then proceed with the calculations
    else:
        # Iterate through both lists to determine all possible distances
        for MoveLid in LidToMove:
            for WrongLid in LidWrongLabel:
                # Calculate the distance in the X direction
                Xdistance = math.pow((MoveLid[2]-WrongLid[2]),2)
                # Calculate the distance in the Y direction
                Ydistance = math.pow((MoveLid[3]-WrongLid[3]),2)
                Sum = Ydistance + Xdistance
                # Use the math library to perform SQRT
                Distance = math.sqrt(Sum)
                GroupDistancePairs(LidsWrongLabels, WrongLid[0], MoveLid[0], Distance)
        # After grouping all values sort the nested lists to put them in order
        SortedLidsWrong = CreateSortedDistanceLists(LidsWrongLabels)
        return SortedLidsWrong
    
    
def GroupDistancePairs(GuidDictionary, PrimaryGuid, SecondaryGuid, Distance):
    '''
    Takes the value pairs from the CalculateDistanceBetweenPoints along
    with a dictionary and groups lids with wrong labels [keys] to lids to move
    and the distance between the two [values].  These values are stored in a
    nested list for each key.
    '''
    if PrimaryGuid in GuidDictionary.keys():
        AdditionalDistanceList = [SecondaryGuid, Distance]
        GuidDictionary[PrimaryGuid].append(AdditionalDistanceList)
    else:
        FirstDistanceList = [SecondaryGuid, Distance]
        # If the value was not already in the dictionary then set it to a blank list
        # this allows all future values to be easily appended
        GuidDictionary[PrimaryGuid] = []
        GuidDictionary[PrimaryGuid].append(FirstDistanceList)

def CreateSortedDistanceLists(LidDictionary):
    '''
    Takes the values of nested dictionary and creates a list that is
    sorted by distance (shortest distance to longest). This list is then
    used in the CreateSortedDictionaryList function to create a ranked
    dictionary.
    '''
    SortedList = []
    for Lid in LidDictionary:
        PairsList = LidDictionary[Lid]
        # Use itemgetter to sort on the distance value
        PairsList.sort(key=itemgetter(1))
        # Append the dictionary key and value pair to a nested list
        SortedList.append([[Lid], PairsList])
    SortedDictionary = CreateSortedDictionaryList(SortedList)
    return SortedDictionary

def CreateSortedDictionaryList(SortedDistanceList):
    '''
    Takes a sorted nested list of [wrongLids, [moveLidShortest, Distance],
    ... [moveLidLongest, Distance]] and creates a nested dictionary where
    the outter most key represents the wrongLid with the shortest lid to
    move distance.  The next key is then the wrongLidID and the values are
    all of the moveLid and Distance pairs.  For each outter key there is
    exactly one innner key.
    '''
    SortedDictionary = {}
    # Sort again to order the nested lists, this puts the nested list
    # with the shortest distance to a move lid first and the longest
    # matched pair distance list.
    SortedDistanceList.sort(key=itemgetter(1,1))
    Count = 1
    for Item in SortedDistanceList:
        TempDict = {}
        TempDict[Item[0][0]] = []
        for Match in Item[1]:
            TempDict[Item[0][0]].append(Match)
        SortedDictionary[Count] = TempDict
        Count = Count + 1
    return SortedDictionary
        

# Analyze the Data


def PerformAnalysis(SortedLidsWrongLabel):
    '''
    Calls the functions that perform analysis on the data pulled
    from the database on manhole distances between wrong labels and
    labels that can be moved.
    '''
    # Create a dictionary that will be used to hold final matches
    PairDict = {}
    SelectLidToMove(SortedLidsWrongLabel,PairDict)
    return PairDict

def SelectLidToMove(SortedLidsWrongLabel,PairDict):
    '''
    Selects the lid that will be moved to each manhole that has an
    incorrect label.  The pair of wrong label to label to move will
    be returned as a dictionary key and value pair.
    '''
    NoMatches = []
    # Conditional used to exit recursive loop when all values have been matched
    if len(SortedLidsWrongLabel) > 0:
        for Rank in SortedLidsWrongLabel:
            # Only match pairs if the rank of the wrong lid is first.  This
            # way only the shortest possible distances will be selected
            if Rank == 1:
                for Lid in SortedLidsWrongLabel[Rank]:
                    MoveLidOptions = SortedLidsWrongLabel[Rank][Lid]
                    Count = 0
                    for Choice in MoveLidOptions:
                        # Only proceed with the shortest distance
                        if Count == 0:
                            PairDict[Lid] = [Choice[0], Choice[1]]
                            Count = Count + 1
                            # Remove the Lid to Move that was selected from all remaining
                            # key and value pairs
                            RemoveLidsAlreadySelected(SortedLidsWrongLabel, Choice[0])
                            # Remove the dictionary entry for the wrong label lid that was
                            # used in this iteration
                            RemoveLidsWithMatches(SortedLidsWrongLabel, Rank)
                        else:
                            pass
                # Resort the dictionary now that the lids used in the previous pass were removed
                UpdatedSortedLidsWrongLabel = PrepareWrongLidsForResort(SortedLidsWrongLabel)
                # Re-run this function on the updated ranked dictionary.
                # Do this until all matches have been 
                FinalDict = SelectLidToMove(UpdatedSortedLidsWrongLabel,PairDict)
                break
            # If there is not a rank assigned then append these default values
            elif SortedLidsWrongLabel[Rank] == 'None':
                PairDict[Rank] = ['None', 'N/A']
            else:
                pass
        # Return an arbitrary values to conclude the recursive loop
        return 'x'
    else:
        # Return an arbitrary values to conclude the recursive loop
        return 'x'

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
        # Update the key value pair to omit the selected value
        SortedLidsWrongLabels[Lid] = MoveLidList

def RemoveLidsWithMatches(SortedLidsWrongLabels, Rank):
    '''
    Takes out the lids with wrong labels that have been matched from the
    dictionary.  This is done so that they won't be iterated over again
    by the script, they can only be run once.
    '''
    # Remove the key from the dictionary that was selected 
    SortedLidsWrongLabels.pop(Rank)

def PrepareWrongLidsForResort(OldSortedLidsWrongLabels):
    '''
    After the dictionary of ranked values has been processed at least
    once by the SelectLidToMove function and a lid with a wrong label
    has been matched to a lid to move (and all instances of the wrong
    and move labels removed from the dictionary), the remaining
    wrong lids need to be reordered by which one has the closest
    remaining match.    
    '''
    NewDict = {}
    # Only if the dictionary has 
    if len(OldSortedLidsWrongLabels) > 0:
        for OldRank in OldSortedLidsWrongLabels:
            for WrongLid in OldSortedLidsWrongLabels[OldRank]:
                # If there are no more possible matches then append
                # a value of 'None' to the lid with the wrong label
                if len(OldSortedLidsWrongLabels[OldRank][WrongLid]) == 0:
                    NewDict[WrongLid] = 'None'
                # If there are still values remaining then run the resort
                else:
                    NewMoveOptions = OldSortedLidsWrongLabels[OldRank][WrongLid]
                    NewDict[[WrongLid][0]] = []
                    for Item in NewMoveOptions:
                        NewDict[[WrongLid][0]].append(Item)
                    NewDict = CreateSortedDistanceLists(NewDict)
    else:
        pass
    return NewDict


# Create Feature Classes from Results


def CreateDeliverables(FeatureClass, SewerLidMatches, StormLidMatches):
    '''
    Runs all of the functions to create deliverables that will be
    used in maps and reports for the manhole inspection project.
    '''
    env.workspace = "C:\Users\jamesd26\Desktop\ManholeInspections\ManholeResults.gdb"
    env.overwriteOutput = True

    # Determine today's date, this will be used to name the output feature classes.
    DateTimeToday = datetime.datetime.now()
    Date = str(DateTimeToday.year) + '_' + str(DateTimeToday.month) + '_' + str(DateTimeToday.day)

    # Add a REL_GUID field to the feature class in order to maintain the GlobalID values
    # after the copies are made in the following functions
    CreateGuidField(FeatureClass)

    # Output feature classes for 'Adds', 'Unknowns' and Wrong Labels
    AddsFeatureClass = ReturnNewlyIdentifiedLids(Date, FeatureClass)
    UnknownFeatureClass = ReturnLidsThatCouldNotBeFound(Date, FeatureClass)
    WrongFeatureClassSewer = ReturnMislabeledManholes(Date, FeatureClass, 'Sewer')
    WrongFeatureClassStorm = ReturnMislabeledManholes(Date, FeatureClass, 'Storm')

    # Populate the Lid Match and Distance fields with the values from the
    # analysis that was performed in this script.
    UpdateFields = ["REL_GUID", "MatchedNumber", "MatchedStatus", "Distance"]
    CreateUnmatchFields(WrongFeatureClassSewer)
    CreateUnmatchFields(WrongFeatureClassStorm)
    
    WrongLidUpdateCursor(WrongFeatureClassSewer, UpdateFields, SewerLidMatches)
    WrongLidUpdateCursor(WrongFeatureClassStorm, UpdateFields, StormLidMatches)

    return AddsFeatureClass, UnknownFeatureClass, WrongFeatureClassSewer, WrongFeatureClassStorm

def CreateGuidField(LidsDataset):
    '''
    Adds a GUID field to the working feature class that was created at
    the start of the script.  This is done to maintain the GlobalID
    values when the dataset is exported for each of the deliverables:
    Adds, Lids that could not be located and Lids with wrong labels.
    This is done using an update cursor.
    '''
    arcpy.AddField_management(LidsDataset, "REL_GUID", "GUID")
    with arcpy.da.UpdateCursor(LidsDataset, ["GlobalID", "REL_GUID"]) as Cursor:
        for Row in Cursor:
            Row[1] = Row[0]
            Cursor.updateRow(Row)
    del Cursor

def ReturnNewlyIdentifiedLids(DateToday, Dataset):
    '''
    Creates a new feature class that contains only the man holes
    that were not on Jim's list but were located by the field team.                                     
    '''
    NewFeatureClass = "Adds" + '_' + DateToday
    arcpy.FeatureClassToFeatureClass_conversion(Dataset, "C:\Users\jamesd26\Desktop\ManholeInspections\ManholeResults.gdb", NewFeatureClass, """ "FieldStatus" = 'Add' """)
    return NewFeatureClass

def ReturnLidsThatCouldNotBeFound(DateToday, Dataset):
    '''
    Creates a new feature class for the manholes that were on Jim's list
    but that the field team was unable to locate.
    '''
    NewFeatureClass = "Unknown" + '_' + DateToday
    arcpy.FeatureClassToFeatureClass_conversion(Dataset, "C:\Users\jamesd26\Desktop\ManholeInspections\ManholeResults.gdb", NewFeatureClass, """ "FieldStatus" = 'Unknown' """)
    return NewFeatureClass
    
def ReturnMislabeledManholes(DateToday, Dataset, System):
    '''
    Creates a feature class for the man holes that had incorrect labels,
    this was done based on Jim's storm and sanitary sewer maps.
    '''
    NewFeatureClass = System + "Wrong" + '_' + DateToday
    arcpy.FeatureClassToFeatureClass_conversion(Dataset, "C:\Users\jamesd26\Desktop\ManholeInspections\ManholeResults.gdb", NewFeatureClass, """ "CorrectLabel" = 'No' """)
    return NewFeatureClass

def CreateUnmatchFields(WrongLidsDataset):
    '''
    Adds fields to the feature class that was created in the ReturnMislabeledManholes
    function.  These fields are for the lid that was matched as the most
    efficient move plus the distance between the two points.  If there was not
    a matched then the values are 'None' and 'N/A', respectively.
    '''
    arcpy.AddField_management(WrongLidsDataset, "MatchedNumber", "SHORT")
    arcpy.AddField_management(WrongLidsDataset, "MatchedStatus", "TEXT", "", "", 25)
    arcpy.AddField_management(WrongLidsDataset, "Distance", "TEXT", "", "", 25)

def WrongLidUpdateCursor(WrongLidsDataset, Fields, LidMatches):
    '''
    Appends the values that were obtained during analysis to the lids in the
    wrong labels feature class.  The field that were created in the CreateUnmatchFields
    are used in the update cursor.
    '''
    Count = 1
    MatchNumberList = []
    with arcpy.da.UpdateCursor(WrongLidsDataset, Fields) as Cursor:
        for Row in Cursor:
            for Entry in LidMatches:
                if Row[0] == Entry and LidMatches[Entry][0] == 'None':
                    Row[1] = 0
                    Row[2] = LidMatches[Entry][0]
                    Row[3] = LidMatches[Entry][1]
                    Cursor.updateRow(Row)
                elif Row[0] == Entry and LidMatches[Entry][0] <> 'None':
                    Row[1] = Count
                    Row[2] = 'Replace'
                    Row[3] = LidMatches[Entry][1]
                    Cursor.updateRow(Row)
                    MatchNumberList.append([LidMatches[Entry][0], LidMatches[Entry][1], Count])
                    Count = Count + 1
                else:
                    pass
            
    del Cursor
    
    with arcpy.da.UpdateCursor(WrongLidsDataset, Fields) as Cursor:
        for Row in Cursor:
            for Item in MatchNumberList:
                if Row[0] == Item[0]:
                    Row[1] = Item[2]
                    Row[2] = 'Move'
                    Row[3] = LidMatches[Entry][1]
                    Cursor.updateRow(Row)
                else:
                    pass
    del Cursor
    

# Update Links in Maps

def UpdateMapDataSources(AddFeatureClass, UnknownFeatureClass, WrongLabelSewerFeatureClass, WrongLabelStormFeatureClass):
    '''
    Takes the pre-existing reporting maps and updates the data sources
    for man hole layers in the table of contents.  In so doing it will
    ensure that the most current data is always used in reports.
    '''
    ChangeDataSource("C:\Users\jamesd26\Desktop\ManholeInspections\Additions_StormManholes.mxd", 'adds', AddFeatureClass)
    ChangeDataSource("C:\Users\jamesd26\Desktop\ManholeInspections\Unknowns_StormManholes.mxd",'not located',UnknownFeatureClass)
    ChangeDataSource("C:\Users\jamesd26\Desktop\ManholeInspections\Wrong_SewerManholes.mxd", 'sewer manholes',WrongLabelSewerFeatureClass)
    ChangeDataSource("C:\Users\jamesd26\Desktop\ManholeInspections\Wrong_StormManholes.mxd", 'storm manholes',WrongLabelStormFeatureClass)

def ChangeDataSource(MXD, LayerName, FeatureClass):
    '''
    Takes an MXD file, a layer name and a new feature class name and
    updates the layer to point to the new feature class.
    '''
    mxd = arcpy.mapping.MapDocument(MXD)

    for Item in arcpy.mapping.ListLayers(mxd):
        if Item.name.lower() == LayerName:
            Item.replaceDataSource("C:\Users\jamesd26\Desktop\ManholeInspections\ManholeResults.gdb", "FILEGDB_WORKSPACE", FeatureClass)
        else:
            pass

    mxd.save()
            

# Clean up Desktop, Remove Temp Folder


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

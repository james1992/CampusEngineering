-- =============================================
-- Author:		Jay Dahlstrom
-- Create date: 1/28/2019
-- Description:	This TSQL is designed to be run through
-- SQL Server agent on an hourly basis to update the
-- Confidence Test Annual tables.  This replaces
-- all of the views that previously supported the web maps
-- with only the two tables produced by this script.
-- =============================================

-- Define the working database

USE CampusEngineeringOperations

-- Create a temporary table to hold confidence test most recent data
-- Table is automatically purged after session, drop statement is there just in case to prevent errors.

IF OBJECT_ID('tempdb.dbo.#ConfidenceTestMostRecent') IS NOT NULL
	DROP TABLE #ConfidenceTestMostRecent

CREATE TABLE #ConfidenceTestMostRecent 
		(OBJECTID INT NOT NULL, 
		 REL_GlobalID uniqueidentifier NULL,
		 InspectionResult nvarchar(50) NULL,
		 InspectionDate datetime2(7) NULL,
		 Notes nvarchar(250) NULL,
		 UserID nvarchar(50) NULL,
		 last_edited_date datetime2(7) NULL)
GO

-- Insert most recent inspection data into temp table above

INSERT INTO #ConfidenceTestMostRecent
SELECT	OBJECTID, 
		REL_GlobalID, 
		Result,
		InspectionDate, 
		Notes, 
		UserID, 
		last_edited_date
FROM    dbo.CONFIDENCETESTSINSPECTIONS
-- The purpose of the where statement is to return only the most recent inspection for each asset
WHERE   (OBJECTID IN (SELECT MAX(OBJECTID) AS OID FROM dbo.CONFIDENCETESTSINSPECTIONS AS ResultsMax GROUP BY REL_GlobalID))
GO

-- Truncate ConfidenceTestProgress table and then populate with new values
-- These are the points on the map.

TRUNCATE TABLE ConfidenceTestsProgress
GO

INSERT INTO ConfidenceTestsProgress

SELECT OBJECTID, 
System, 
TestStatus, 
CASE WHEN TestStatus = 'Confidence Test Complete' THEN 1 ELSE 0 END AS TestCompleteCount,
CurrentMonth, 
FacilityNumber, 
FacilityName, 
SystemLocation, 
Serves, 
MonthDue, 
DocumentStorage, 
SystemDescription,  
InspectionDate, 
QuarterInspected,
Notes, 
UserID, 
last_edited_date,
SHAPE 

FROM  (SELECT	dbo.CONFIDENCETESTS.OBJECTID, 
				dbo.CONFIDENCETESTS.System, 
				-- Determine if the most recent inspection date is in compliance or not.
				CASE WHEN InspectionResult = 'Yellow (Maintenance Required)' THEN 'Maintenance Required' 
				WHEN InspectionResult = 'Red (System Not Operational)' THEN 'Maintenance Required' 
				WHEN YEAR(GETDATE()) - YEAR(InspectionDate) = 0 THEN 'Confidence Test Complete' 
				WHEN MONTH(GETDATE()) = MonthDue THEN 'Confidence Test Due' 
				WHEN MONTH(GETDATE()) > MonthDue AND YEAR(GETDATE()) - YEAR(InspectionDate) = 1 THEN 'Confidence Past Due' 
				WHEN MONTH(GETDATE()) < MonthDue AND YEAR(GETDATE()) - YEAR(InspectionDate) = 1 THEN 'Confidence Test Complete' 
				WHEN YEAR(GETDATE()) - YEAR(InspectionDate) > 1 THEN 'Confidence Past Due' 
				WHEN InspectionDate IS NULL THEN 'No Previously Recorded Tests' END AS TestStatus, 

				MONTH(GETDATE()) AS CurrentMonth, 
				dbo.CONFIDENCETESTS.FacNum AS FacilityNumber, 
				dbo.CONFIDENCETESTS.FacName AS FacilityName, 
				dbo.CONFIDENCETESTS.Location AS SystemLocation, 
				dbo.CONFIDENCETESTS.Serves, 
				dbo.CONFIDENCETESTS.MonthDue, 
				dbo.CONFIDENCETESTS.Documents AS DocumentStorage, 
				dbo.CONFIDENCETESTS.SystemDescription, 
				dbo.CONFIDENCETESTS.Quarter AS QuarterInspected, 
				#ConfidenceTestMostRecent.InspectionDate, 
				#ConfidenceTestMostRecent.Notes, 
				#ConfidenceTestMostRecent.UserID, 
				#ConfidenceTestMostRecent.last_edited_date, 
				dbo.CONFIDENCETESTS.SHAPE
				FROM dbo.CONFIDENCETESTS LEFT OUTER JOIN
					 #ConfidenceTestMostRecent ON dbo.CONFIDENCETESTS.GlobalID = #ConfidenceTestMostRecent.REL_GlobalID
				-- Filter out inactive points and all standpipes.
				WHERE (dbo.CONFIDENCETESTS.FeatureStatus = N'Active') AND (dbo.CONFIDENCETESTS.System <> N'Wet Standpipe') AND (dbo.CONFIDENCETESTS.System <> N'Dry Standpipe')) AS innerTable

-- Create a temporary table to hold confidence test annual building progress aggregate data
-- Table is automatically purged after session, drop statement is there just in case to prevent errors.

IF OBJECT_ID('tempdb.dbo.#ConfidenceTestBuildingProgress') IS NOT NULL
	DROP TABLE #ConfidenceTestBuildingProgress

CREATE TABLE #ConfidenceTestBuildingProgress 
		(FacilityNumber nvarchar(5) NULL, 
		 DocumentStorage nvarchar(500) NULL,
		 NumberComplete int NULL,
		 TotalTestsToDate int NULL,
		 last_edited_date datetime2(7) NULL)
GO

-- Insert building inspection progress data into temp table above

INSERT INTO #ConfidenceTestBuildingProgress
SELECT      FacilityNumber, 
			DocumentStorage, 
			SUM(TestCompleteCount) AS NumberComplete, 
			COUNT(OBJECTID) AS TotalTestsToDate, 
			MIN(last_edited_date) AS LastEdited
FROM        dbo.ConfidenceTestsProgress
GROUP BY FacilityNumber, DocumentStorage
GO

-- Truncate ConfidenceTestBuildingProgress table and then populate with new values
-- These are the buildings on the map.

TRUNCATE TABLE ConfidenceTestsBuildingProgress
GO

INSERT INTO dbo.ConfidenceTestsBuildingProgress

SELECT	dbo.ViewUniversityBuildings.FacilityNumber, 
		dbo.ViewUniversityBuildings.FacilityName, 
		#ConfidenceTestBuildingProgress.DocumentStorage, 
		#ConfidenceTestBuildingProgress.NumberComplete, 
		#ConfidenceTestBuildingProgress.TotalTestsToDate, 
		#ConfidenceTestBuildingProgress.NumberComplete / CAST(#ConfidenceTestBuildingProgress.TotalTestsToDate AS FLOAT) AS PercentComplete, 
		#ConfidenceTestBuildingProgress.last_edited_date,
		dbo.ViewUniversityBuildings.SHAPE 

FROM dbo.ViewUniversityBuildings INNER JOIN
         #ConfidenceTestBuildingProgress ON dbo.ViewUniversityBuildings.FacilityNumber = #ConfidenceTestBuildingProgress.FacilityNumber
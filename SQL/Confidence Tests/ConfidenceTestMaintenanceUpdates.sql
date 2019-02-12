-- =============================================
-- Author:		Jay Dahlstrom
-- Create date: 1/28/2019
-- Description:	This TSQL is designed to be run through
-- SQL Server agent on an hourly basis to update the
-- Confidence Test Maintenance tables.  This replaces
-- all of the views that previously supported the web maps
-- with only the two tables produced by this script.
-- =============================================

-- Define the working database

USE CampusEngineeringOperations

-- Create a temporary table to hold confidence test maintenance most recent data
-- Table is automatically purged from tempdb after session, drop statement is there just in case to prevent errors.

IF OBJECT_ID('tempdb.dbo.#ConfidenceTestMaintenanceMostRecent') IS NOT NULL
	DROP TABLE #ConfidenceTestMaintenanceMostRecent

CREATE TABLE #ConfidenceTestMaintenanceMostRecent 
		(OBJECTID INT NOT NULL, 
		 REL_GlobalID uniqueidentifier NULL,
		 InspectionDate datetime2(7) NULL,
		 Notes nvarchar(250) NULL,
		 UserID nvarchar(50) NULL,
		 last_edited_date datetime2(7) NULL)
GO

-- Insert most recent maintenance data into temp table above

INSERT INTO #ConfidenceTestMaintenanceMostRecent
SELECT	OBJECTID, 
		REL_GlobalID, 
		InspectionDate, 
		Notes, 
		UserID, 
		last_edited_date
FROM    dbo.CONFIDENCETESTSMAINTENANCE
-- The purpose of the where statement is to return only the most recent inspection for each asset
WHERE   (OBJECTID IN (SELECT MAX(OBJECTID) AS OID FROM dbo.CONFIDENCETESTSMAINTENANCE AS ResultsMax GROUP BY REL_GlobalID))
GO

-- Truncate ConfidenceTestMaintenanceProgress table and then populate with new values
-- These are the points on the map.

TRUNCATE TABLE ConfidenceTestsMaintenanceProgress
GO

INSERT INTO dbo.ConfidenceTestsMaintenanceProgress

SELECT      OBJECTID, 
			System, 
			TestStatus,
			CASE WHEN TestStatus = '5 Year Maintenance Complete' THEN 1 ELSE 0 END AS TestCompleteCount, 
			CurrentMonth, 
			FacilityNumber, 
			FacilityName, 
			SystemLocation, 
			Serves, 
			MaintenanceReportYear, 
			DocumentStorage, 
			SystemDescription, 
			InspectionDate, 
			Notes, 
			UserID, 
			last_edited_date, 
			SHAPE 

FROM        (SELECT dbo.CONFIDENCETESTS.OBJECTID, 
					dbo.CONFIDENCETESTS.System, 
					CASE WHEN MaintenanceReportYear = YEAR(InspectionDate) THEN '5 Year Maintenance Complete' 
					WHEN MaintenanceReportYear > YEAR(InspectionDate) AND YEAR(InspectionDate) >= (MaintenanceReportYear - 5) THEN '5 Year Maintenance Complete' 
					-- Determine if the last test date is in compliance or not.  Different reporting month for standpipes and sprinklers
					WHEN (System = 'Wet Standpipe' OR System = 'Dry Standpipe') AND MaintenanceReportYear = YEAR(GETDATE()) AND YEAR(InspectionDate) >= (MaintenanceReportYear - 5) AND MONTH(GETDATE()) < 8 THEN '5 Year Maintenance Complete' 
					WHEN (System = 'Wet Standpipe' OR System = 'Dry Standpipe') AND MaintenanceReportYear = YEAR(GETDATE()) AND YEAR(InspectionDate) >= (MaintenanceReportYear - 5) AND MONTH(GETDATE()) = 8 THEN '5 Year Maintenance Due' 
					WHEN (System = 'Wet Standpipe' OR System = 'Dry Standpipe') AND MaintenanceReportYear = YEAR(GETDATE()) AND YEAR(InspectionDate) >= (MaintenanceReportYear - 5) AND MONTH(GETDATE()) > 8 THEN '5 Year Maintenance Past Due' 
					WHEN (System = 'Wet Sprinkler' OR System = 'Dry Sprinkler') AND MaintenanceReportYear = YEAR(GETDATE()) AND YEAR(InspectionDate) >= (MaintenanceReportYear - 5) AND MONTH(GETDATE()) < 7 THEN '5 Year Maintenance Complete' 
					WHEN (System = 'Wet Sprinkler' OR System = 'Dry Sprinkler') AND MaintenanceReportYear = YEAR(GETDATE()) AND YEAR(InspectionDate) >= (MaintenanceReportYear - 5) AND MONTH(GETDATE()) = 7 THEN '5 Year Maintenance Due' 
					WHEN (System = 'Wet Sprinkler' OR System = 'Dry Sprinkler') AND MaintenanceReportYear = YEAR(GETDATE()) AND YEAR(InspectionDate) >= (MaintenanceReportYear - 5) AND MONTH(GETDATE()) > 7 THEN '5 Year Maintenance Past Due' 
					WHEN YEAR(InspectionDate) < (MaintenanceReportYear - 5) THEN '5 Year Maintenance Past Due' 
					WHEN InspectionDate IS NULL AND YEAR(GETDATE()) < MaintenanceReportYear THEN 'Test not Due Yet'
					WHEN InspectionDate IS NULL AND YEAR(GETDATE()) = MaintenanceReportYear THEN '5 Year Maintenance Due'
					WHEN InspectionDate IS NULL THEN 'No Previously Maintenance Records' END AS TestStatus,
					 
					MONTH(GETDATE()) AS CurrentMonth, 
					dbo.CONFIDENCETESTS.FacNum AS FacilityNumber, 
					dbo.CONFIDENCETESTS.FacName AS FacilityName, 
					dbo.CONFIDENCETESTS.Location AS SystemLocation, 
					dbo.CONFIDENCETESTS.Serves, 
					dbo.CONFIDENCETESTS.Documents AS DocumentStorage, 
					dbo.CONFIDENCETESTS.SystemDescription, 
					dbo.CONFIDENCETESTS.MaintenanceReportYear, 
					#ConfidenceTestMaintenanceMostRecent.InspectionDate, 
					#ConfidenceTestMaintenanceMostRecent.Notes, 
					#ConfidenceTestMaintenanceMostRecent.UserID, 
					#ConfidenceTestMaintenanceMostRecent.last_edited_date, 
					dbo.CONFIDENCETESTS.SHAPE
					FROM dbo.CONFIDENCETESTS LEFT OUTER JOIN
						 #ConfidenceTestMaintenanceMostRecent ON dbo.CONFIDENCETESTS.GlobalID = #ConfidenceTestMaintenanceMostRecent.REL_GlobalID
					-- Filter out everything except for active standpipes and sprinklers
					WHERE (dbo.CONFIDENCETESTS.FeatureStatus = N'Active') AND 
					(dbo.CONFIDENCETESTS.MaintenanceReportYear IS NOT NULL) AND (dbo.CONFIDENCETESTS.System = 'Dry Sprinkler' OR dbo.CONFIDENCETESTS.System = 'Dry Standpipe' OR dbo.CONFIDENCETESTS.System = 'Wet Sprinkler' OR dbo.CONFIDENCETESTS.System = 'Wet Standpipe')) AS innertable
GO

-- Create a temporary table to hold confidence test maintenance building progress aggregate data
-- Table is automatically purged after session, drop statement is there just in case to prevent errors.

IF OBJECT_ID('tempdb.dbo.#ConfidenceTestMaintenanceBuildingProgress') IS NOT NULL
	DROP TABLE #ConfidenceTestMaintenanceBuildingProgress

CREATE TABLE #ConfidenceTestMaintenanceBuildingProgress 
		(FacilityNumber nvarchar(5) NULL, 
		 DocumentStorage nvarchar(500) NULL,
		 NumberComplete int NULL,
		 TotalTestsToDate int NULL,
		 last_edited_date datetime2(7) NULL)
GO

-- Insert building inspection progress data into temp table above

INSERT INTO #ConfidenceTestMaintenanceBuildingProgress
SELECT      FacilityNumber, 
			DocumentStorage, 
			SUM(TestCompleteCount) AS NumberComplete, 
			COUNT(TestStatus) AS TotalTestsToDate, 
			MIN(last_edited_date) AS LastEdited
FROM        dbo.ConfidenceTestsMaintenanceProgress
WHERE TestStatus <> 'Test not Due Yet'
GROUP BY FacilityNumber, DocumentStorage
GO

-- Truncate ConfidenceTestMaintenanceBuildingProgress table and then populate with new values
-- There are the buildings on the map.

TRUNCATE TABLE ConfidenceTestsMaintenanceBuildingProgress
GO

INSERT INTO dbo.ConfidenceTestsMaintenanceBuildingProgress

SELECT	dbo.ViewUniversityBuildings.FacilityNumber, 
		dbo.ViewUniversityBuildings.FacilityName, 
		#ConfidenceTestMaintenanceBuildingProgress.DocumentStorage, 
		#ConfidenceTestMaintenanceBuildingProgress.NumberComplete, 
		#ConfidenceTestMaintenanceBuildingProgress.TotalTestsToDate, 
		#ConfidenceTestMaintenanceBuildingProgress.NumberComplete / CAST(#ConfidenceTestMaintenanceBuildingProgress.TotalTestsToDate AS FLOAT) AS PercentComplete, 
		#ConfidenceTestMaintenanceBuildingProgress.last_edited_date,
		dbo.ViewUniversityBuildings.SHAPE 

FROM dbo.ViewUniversityBuildings INNER JOIN
         #ConfidenceTestMaintenanceBuildingProgress ON dbo.ViewUniversityBuildings.FacilityNumber = #ConfidenceTestMaintenanceBuildingProgress.FacilityNumber
------------------------------------------------------------------------------------------------------------
--Created by Jay Dahlstrom
--DateCreated: October 1, 2019
--This script updates the base tables in the blinds and shades project.
--It adds the Facility Name to the installation records for use in the PowerApps Gallery and it
--populates the table that is used in the web map.
------------------------------------------------------------------------------------------------------------

USE FacilitiesConstruction
GO

-- Set the FacName column in the Installation Records table
UPDATE BlindsAndShadesInstallationRecords
SET FacName = FacilityName
FROM BlindsAndShadesInstallationRecords
	JOIN BaseComponents.dbo.ViewUniversityBuildings
	ON (BlindsAndShadesInstallationRecords.FacNum = BaseComponents.dbo.ViewUniversityBuildings.FacilityNumber)
GO

-- Remove existing data
TRUNCATE TABLE dbo.BlindsAndShadesBuildings
DROP TABLE IF EXISTS #tempCount
GO

-- Populate BlindsAndShadesBuildings with current building list
INSERT INTO BlindsAndShadesBuildings (FacNum, FacName, SHAPE)
SELECT FacilityNumber, FacilityName, SHAPE
FROM BaseComponents.dbo.ViewUniversityBuildings
GO

-- Add the Form URL to all rows in BlindsAndShadesBuildings
UPDATE BlindsAndShadesBuildings
SET FormURL = 'https://apps.powerapps.com/play/dd05457c-6be5-441e-9748-4e3d7549feee?FacNum=' + BlindsAndShadesBuildings.FacNum + '&screenID=Home',
	Report = 'No'
GO

-- Aggregate the number of reports by building and insert into temp table
SELECT COUNT(UniqueID) as Total, FacNum
INTO #tempCount
FROM BlindsAndShadesInstallationRecords
GROUP BY FacNum
GO

-- Insert the aggregated counts into BlindsAndShadesBuildings along with a report URL for those with inspections
UPDATE BlindsAndShadesBuildings
SET NumberOfRecords = #tempCount.Total,
	-- To get URL to work in ArcGIS Online replace spaces with %20
	ReportURL = REPLACE('https://apps.powerapps.com/play/dd05457c-6be5-441e-9748-4e3d7549feee?Search=' + BlindsAndShadesBuildings.FacName + '&screenID=Browse', ' ', '%20'),
	Report = 'Yes'
FROM BlindsAndShadesBuildings
	JOIN #tempCount
	ON (BlindsAndShadesBuildings.FacNum = #tempCount.FacNum)
GO

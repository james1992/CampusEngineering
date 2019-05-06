-- =============================================
-- Author:		Jay Dahlstrom
-- Create date: 5/1/2019
-- Description:	This TSQL is designed to be run through
-- SQL Server agent on an hourly basis to update the
-- Air Handling Unit Progress and Air Handling Unit Building
-- Progress tables.  
-- =============================================

-- Define the working database

USE CampusEngineeringOperations

-- Create a temporary table to hold confidence test maintenance most recent data
-- Table is automatically purged from tempdb after session, drop statement is there just in case to prevent errors.

IF OBJECT_ID('tempdb.dbo.#AirHandlingUnitInspectionMostRecent') IS NOT NULL
	DROP TABLE #AirHandlingUnitInspectionMostRecent

CREATE TABLE #AirHandlingUnitInspectionMostRecent
		(OBJECTID INT NOT NULL, 
		 REL_OBJECTID int NULL,
		 InspectionDate datetime2(7) NULL,
		 NormalOperation nvarchar(10) NULL,
		 InspectionNotes nvarchar(250) NULL,
		 UserID nvarchar(50) NULL,
		 last_edited_date datetime2(7) NULL)
GO

-- Insert most recent maintenance data into temp table above

INSERT INTO #AirHandlingUnitInspectionMostRecent
SELECT	OBJECTID, 
		REL_OBJECTID, 
		InspectionDate, 
		NormalOperation,
		InspectionNotes, 
		created_user, 
		last_edited_date
FROM    dbo.AIRHANDLINGUNITSINSPECTIONS
-- The purpose of the where statement is to return only the most recent inspection for each asset
WHERE   (OBJECTID IN (SELECT MAX(OBJECTID) AS OID FROM dbo.AIRHANDLINGUNITSINSPECTIONS AS ResultsMax GROUP BY REL_OBJECTID))
GO

IF OBJECT_ID('tempdb.dbo.#AirHandlingUnitInspectionProgress') IS NOT NULL
	DROP TABLE #AirHandlingUnitInspectionProgress

CREATE TABLE #AirHandlingUnitInspectionProgress
		(	[OBJECTID] [int] NOT NULL,
			[FanName] [nvarchar](50) NULL,
			InspectionStatus [nvarchar](50) NULL,
			InspectionCompleteCount [int] NULL,
			[FanType] [nvarchar](50) NULL,
			[FanStatus] [nvarchar](25) NULL,
			[DeviceNumber] [nvarchar](25) NULL,
			[Location] [nvarchar](100) NULL,
			[AreasServed] [nvarchar](200) NULL,
			[DataOrder] [nvarchar](25) NULL,
			[CFM] [numeric](38, 8) NULL,
			[HP] [numeric](38, 8) NULL,
			[EmergencyPower] [nvarchar](15) NULL,
			[VFD] [nvarchar](15) NULL,
			[MotorControlLocation] [nvarchar](100) NULL,
			[FloorID] [nvarchar](60) NULL,
			[FacNum] [nvarchar](60) NULL,
			[GlobalID] [uniqueidentifier] NOT NULL,
			UserID nvarchar(50) NULL,
			InspectionDate datetime2(7) NULL,
			InspectionNotes nvarchar(250) NULL,
			InspectionNormalOperation nvarchar(10) NULL,
			last_edited_date datetime2(7) NULL,
			[Shape] [geometry] NULL)
GO

INSERT INTO #AirHandlingUnitInspectionProgress
SELECT	OBJECTID,
		FanName,
		InspectionStatus,
		CASE WHEN InspectionStatus = 'Annual Inspection Complete' THEN 1 ELSE 0 END AS InspectionCompleteCount,
		FanType,
		FanStatus,
		DeviceNumber,
		Location,
		AreasServed,
		DataOrder,
		CFM,
		HP,
		EmergencyPower,
		VFD,
		MotorControlLocation,
		FloorID,
		FacNum,
		GlobalID,
		UserID,
		InspectionDate,
		InspectionNotes,
		NormalOperation,
		last_edited_date,
		Shape
		
FROM (SELECT dbo.AIRHANDLINGUNITS.OBJECTID,
			 dbo.AIRHANDLINGUNITS.FanName,
			 CASE WHEN YEAR(GETDATE()) - YEAR(#AirHandlingUnitInspectionMostRecent.InspectionDate) = 0 THEN 'Annual Inspection Complete' 
				WHEN YEAR(GETDATE()) - YEAR(#AirHandlingUnitInspectionMostRecent.InspectionDate) >= 1 THEN 'Annual Inspection Past Due' 
				WHEN InspectionDate IS NULL THEN 'Annual Inspection Past Due' 
			 END AS InspectionStatus,
			 dbo.AIRHANDLINGUNITS.FanType,
			 dbo.AIRHANDLINGUNITS.FanStatus,
			 dbo.AIRHANDLINGUNITS.DeviceNumber,
			 dbo.AIRHANDLINGUNITS.Location,
			 dbo.AIRHANDLINGUNITS.AreasServed,
			 dbo.AIRHANDLINGUNITS.DataOrder,
			 dbo.AIRHANDLINGUNITS.CFM,
			 dbo.AIRHANDLINGUNITS.HP,
			 dbo.AIRHANDLINGUNITS.EmergencyPower,
			 dbo.AIRHANDLINGUNITS.VFD,
			 dbo.AIRHANDLINGUNITS.MotorControlLocation,
			 dbo.AIRHANDLINGUNITS.FloorID,
			 SUBSTRING(dbo.AIRHANDLINGUNITS.FloorID, 1, 4) AS FacNum,
			 dbo.AIRHANDLINGUNITS.GlobalID,
			 #AirHandlingUnitInspectionMostRecent.UserID,
			 #AirHandlingUnitInspectionMostRecent.InspectionDate,
			 #AirHandlingUnitInspectionMostRecent.InspectionNotes,
			 #AirHandlingUnitInspectionMostRecent.NormalOperation,
			 #AirHandlingUnitInspectionMostRecent.last_edited_date,
			 dbo.AIRHANDLINGUNITS.Shape

	FROM dbo.AIRHANDLINGUNITS LEFT OUTER JOIN
		#AirHandlingUnitInspectionMostRecent ON dbo.AIRHANDLINGUNITS.OBJECTID = #AirHandlingUnitInspectionMostRecent.REL_OBJECTID) AS innertable
GO

IF OBJECT_ID('tempdb.dbo.#AirHandlingUnitBuildingProgress') IS NOT NULL
	DROP TABLE #AirHandlingUnitBuildingProgress

CREATE TABLE #AirHandlingUnitBuildingProgress 
		(FacilityNumber nvarchar(5) NULL, 
		 NumberComplete int NULL,
		 TotalTestsToDate int NULL,
		 last_edited_date datetime2(7) NULL)
GO

INSERT INTO #AirHandlingUnitBuildingProgress
SELECT      FacNum, 
			SUM(InspectionCompleteCount) AS NumberComplete, 
			COUNT(OBJECTID) AS TotalTestsToDate, 
			MIN(last_edited_date) AS LastEdited
FROM        #AirHandlingUnitInspectionProgress
GROUP BY FacNum
GO

INSERT INTO AirHandlingUnitsBuildingProgress
SELECT dbo.ViewUniversityBuildings.FacilityNumber, 
		dbo.ViewUniversityBuildings.FacilityName, 
		#AirHandlingUnitBuildingProgress.NumberComplete,
		#AirHandlingUnitBuildingProgress.TotalTestsToDate,
		#AirHandlingUnitBuildingProgress.NumberComplete / CAST(#AirHandlingUnitBuildingProgress.TotalTestsToDate AS FLOAT) AS PercentComplete,
		#AirHandlingUnitBuildingProgress.last_edited_date,
		dbo.ViewUniversityBuildings.SHAPE
FROM dbo.ViewUniversityBuildings INNER JOIN
		#AirHandlingUnitBuildingProgress ON dbo.ViewUniversityBuildings.FacilityNumber = #AirHandlingUnitBuildingProgress.FacilityNumber
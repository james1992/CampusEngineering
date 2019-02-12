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

USE FacilitiesMaintenance

-- Create a temporary table to hold confidence test maintenance most recent data
-- Table is automatically purged from tempdb after session, drop statement is there just in case to prevent errors.

TRUNCATE TABLE WaterTreatmentCondenserWaterReport
GO

INSERT INTO dbo.WaterTreatmentCondenserWaterReport

SELECT      BuildingSystem, 
			AvgConductivity, 
			AvgTRASAR,
			AvgpH, 
			AvgFreeChlorine, 
			AvgTotalBacteria, 
			AvgTemperature, 
			AvgORP, 
			YearAndMonth 
FROM  (SELECT        
			CONCAT(BaseComponents.dbo.ViewUniversityBuildings.FacilityName, '-', dbo.WaterTreatmentCondenserWaterTests.LoopType) AS BuildingSystem, AVG(dbo.WaterTreatmentCondenserWaterTests.Conductivity) AS AvgConductivity, 
			CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.TRASAR), 2, 1) AS decimal(18, 2)) AS AvgTRASAR, 
			CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.pH), 2, 1) AS decimal(18, 2)) AS AvgpH, 
			CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.FreeChlorine), 2, 1) AS decimal(18, 2)) AS AvgFreeChlorine, 
			CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.TotalBacteria), 2, 1) AS decimal(18, 2)) AS AvgTotalBacteria, 
			CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.Tempurature), 2, 1) AS decimal(18, 2)) AS AvgTemperature, 
            CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.ORP), 2, 1) AS decimal(18, 2)) AS AvgORP, 
			CONCAT(YEAR(dbo.WaterTreatmentCondenserWaterTests.SurveyDate), '-', FORMAT(dbo.WaterTreatmentCondenserWaterTests.SurveyDate, 'MM')) AS YearAndMonth
FROM        dbo.WaterTreatmentCondenserWaterTests LEFT OUTER JOIN
				BaseComponents.dbo.ViewUniversityBuildings ON dbo.WaterTreatmentCondenserWaterTests.FacNum = BaseComponents.dbo.ViewUniversityBuildings.FacilityNumber
WHERE		(BaseComponents.dbo.ViewUniversityBuildings.FacilityName IS NOT NULL)
GROUP BY	CONCAT(BaseComponents.dbo.ViewUniversityBuildings.FacilityName, '-', dbo.WaterTreatmentCondenserWaterTests.LoopType), CONCAT(YEAR(dbo.WaterTreatmentCondenserWaterTests.SurveyDate), '-', 
				FORMAT(dbo.WaterTreatmentCondenserWaterTests.SurveyDate, 'MM'))) AS innertable
GO
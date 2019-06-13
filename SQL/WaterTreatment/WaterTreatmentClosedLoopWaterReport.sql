-- =============================================
-- Author:		Jay Dahlstrom
-- Create date: 6/11/2019
-- Description:	This TSQL is designed to be run through
-- SQL Server agent on an hourly basis to update the
-- Water Treatment Closed Loops Water Report table.  
-- This tables contains the properly formatted information
-- for the PowerBI reports.
-- =============================================

-- Define the working database

USE FacilitiesMaintenance

-- Remove all of the old records in preparation for data load

TRUNCATE TABLE WaterTreatmentClosedLoopsWaterReport
GO

INSERT INTO dbo.WaterTreatmentClosedLoopsWaterReport

SELECT	BuildingSystem, 
		AvgConductivity, 
		AvgpH, 
		AvgAzole, 
		AvgTotalBacteria, 
		AvgCopper, 
		AvgIron, 
		AvgMakeupMeter, 
		AvgMildCopperCorrosionRate, 
		AvgMildSteelCorrosionRate, 
		YearAndMonth
FROM (SELECT CONCAT(BaseComponents.dbo.ViewUniversityBuildings.FacilityName, '-', dbo.WaterTreatmentClosedLoopsWaterTests.LoopType) AS BuildingSystem, 
             AVG(dbo.WaterTreatmentClosedLoopsWaterTests.Conductivity) AS AvgConductivity, 
			 CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.pH), 2, 1) AS decimal(18, 2)) AS AvgpH, 
             CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.Azole), 2, 1) AS decimal(18, 2)) AS AvgAzole, 
			 CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.TotalBacteria), 2, 1) AS decimal(18, 2)) AS AvgTotalBacteria, 
			 CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.Copper), 2, 1) AS decimal(18, 2)) AS AvgCopper, 
			 CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.Iron), 2, 1) AS decimal(18, 2)) AS AvgIron, 
			 CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.MakeupMeter), 2, 1) AS decimal(18, 2)) AS AvgMakeupMeter, 
             CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.MildCopperCorrosionRate), 2, 1) AS decimal(18, 2)) AS AvgMildCopperCorrosionRate, 
             CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.MildSteelCorrosionRate), 2, 1) AS decimal(18, 2)) AS AvgMildSteelCorrosionRate, 
             CONCAT(YEAR(dbo.WaterTreatmentClosedLoopsWaterTests.SurveyDate), '-', FORMAT(dbo.WaterTreatmentClosedLoopsWaterTests.SurveyDate, 'MM')) AS YearAndMonth
             FROM dbo.WaterTreatmentClosedLoopsWaterTests LEFT OUTER JOIN
                      BaseComponents.dbo.ViewUniversityBuildings ON dbo.WaterTreatmentClosedLoopsWaterTests.FacNum = BaseComponents.dbo.ViewUniversityBuildings.FacilityNumber
             WHERE (BaseComponents.dbo.ViewUniversityBuildings.FacilityName IS NOT NULL)
             GROUP BY CONCAT(BaseComponents.dbo.ViewUniversityBuildings.FacilityName, '-', dbo.WaterTreatmentClosedLoopsWaterTests.LoopType), 
					  CONCAT(YEAR(dbo.WaterTreatmentClosedLoopsWaterTests.SurveyDate), '-', FORMAT(dbo.WaterTreatmentClosedLoopsWaterTests.SurveyDate, 'MM'))) AS innertable
GO
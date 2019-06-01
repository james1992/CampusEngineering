-- =============================================
-- Author:		Jay Dahlstrom
-- Create date: 2/22/2019
-- Description:	This TSQL is designed to be run through
-- SQL Server agent on an hourly basis to update the
-- Water Treatment Condenser Water Report table.  
-- This tables contains the properly formatted information
-- for the monthly inspection reports email that is
-- produced by MS Flow.
-- =============================================

-- Define the working database

USE FacilitiesMaintenance

-- Remove all of the old records in preparation for data load

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
			CONCAT(BaseComponents.dbo.ViewUniversityBuildings.FacilityName, '-', dbo.WaterTreatmentCondenserWaterTests.LoopType) AS BuildingSystem, 
			AVG(dbo.WaterTreatmentCondenserWaterTests.Conductivity) AS AvgConductivity, 
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
GROUP BY	CONCAT(BaseComponents.dbo.ViewUniversityBuildings.FacilityName, '-', dbo.WaterTreatmentCondenserWaterTests.LoopType), 
			CONCAT(YEAR(dbo.WaterTreatmentCondenserWaterTests.SurveyDate), '-', FORMAT(dbo.WaterTreatmentCondenserWaterTests.SurveyDate, 'MM'))) AS innertable
GO
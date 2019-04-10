USE [FacilitiesMaintenance]
GO

/****** Object:  View [dbo].[ViewWaterTreatmentCondenserWaterMonthlyReport]    Script Date: 4/1/2019 1:27:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ViewWaterTreatmentClosedWaterLoopsTest]
AS

SELECT TOP (100) PERCENT     BuildingSystem, 
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
FROM  (SELECT        
			CONCAT(BaseComponents.dbo.ViewUniversityBuildings.FacilityName, '-', dbo.WaterTreatmentClosedLoopsWaterTests.LoopType) AS BuildingSystem, AVG(dbo.WaterTreatmentClosedLoopsWaterTests.Conductivity) AS AvgConductivity, 
			CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.pH), 2, 1) AS decimal(18, 2)) AS AvgpH, 
			CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.Azole), 2, 1) AS decimal(18, 2)) AS AvgAzole, 
			CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.TotalBacteria), 2, 1) AS decimal(18, 2)) AS AvgTotalBacteria, 
			CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.Copper), 2, 1) AS decimal(18, 2)) AS AvgCopper, 
            CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.Iron), 2, 1) AS decimal(18, 2)) AS AvgIron, 
			
			CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.MakeupMeter), 2, 1) AS decimal(18, 2)) AS AvgMakeupMeter, 
			CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.MildCopperCorrosionRate), 2, 1) AS decimal(18, 2)) AS AvgMildCopperCorrosionRate, 
			CAST(ROUND(AVG(dbo.WaterTreatmentClosedLoopsWaterTests.MildSteelCorrosionRate), 2, 1) AS decimal(18, 2)) AS AvgMildSteelCorrosionRate,
			CONCAT(YEAR(dbo.WaterTreatmentClosedLoopsWaterTests.SurveyDate), '-', FORMAT(dbo.WaterTreatmentClosedLoopsWaterTests.SurveyDate, 'MM')) AS YearAndMonth
FROM        dbo.WaterTreatmentClosedLoopsWaterTests LEFT OUTER JOIN
				BaseComponents.dbo.ViewUniversityBuildings ON dbo.WaterTreatmentClosedLoopsWaterTests.FacNum = BaseComponents.dbo.ViewUniversityBuildings.FacilityNumber
WHERE		(BaseComponents.dbo.ViewUniversityBuildings.FacilityName IS NOT NULL)
GROUP BY	CONCAT(BaseComponents.dbo.ViewUniversityBuildings.FacilityName, '-', dbo.WaterTreatmentClosedLoopsWaterTests.LoopType), CONCAT(YEAR(dbo.WaterTreatmentClosedLoopsWaterTests.SurveyDate), '-', 
				FORMAT(dbo.WaterTreatmentClosedLoopsWaterTests.SurveyDate, 'MM'))) AS innertable

				GO
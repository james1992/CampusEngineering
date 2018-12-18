Create VIEW ViewWaterTreatmentCondenserWaterReport AS

SELECT			CONCAT(BaseComponents.dbo.ViewUniversityBuildings.FacilityName, '-', dbo.WaterTreatmentCondenserWaterTests.LoopType) As BuildingSystem,
				AVG(dbo.WaterTreatmentCondenserWaterTests.Conductivity) AS AvgConductivity, 
				CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.TRASAR),2,1) AS decimal(18,2)) AS AvgTRASAR, 
				CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.pH),2,1) AS decimal(18,2)) AS AvgpH, 
				CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.FreeChlorine),2,1) AS decimal(18,2)) AS AvgFreeChlorine, 
				CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.TotalBacteria),2,1) AS decimal(18,2)) AS AvgTotalBacteria, 
				CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.Tempurature),2,1) AS decimal(18,2)) AS AvgTemperature, 
				CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.ORP),2,1) AS decimal(18,2)) AS AvgORP,
				CONCAT(YEAR(dbo.WaterTreatmentCondenserWaterTests.SurveyDate), '-', FORMAT(dbo.WaterTreatmentCondenserWaterTests.SurveyDate, 'MM')) AS YearAndMonth
FROM            dbo.WaterTreatmentCondenserWaterTests LEFT OUTER JOIN
                         BaseComponents.dbo.ViewUniversityBuildings ON dbo.WaterTreatmentCondenserWaterTests.FacNum = BaseComponents.dbo.ViewUniversityBuildings.FacilityNumber
WHERE BaseComponents.dbo.ViewUniversityBuildings.FacilityName IS NOT NULL
GROUP BY CONCAT(BaseComponents.dbo.ViewUniversityBuildings.FacilityName, '-', dbo.WaterTreatmentCondenserWaterTests.LoopType), CONCAT(YEAR(dbo.WaterTreatmentCondenserWaterTests.SurveyDate), '-', FORMAT(dbo.WaterTreatmentCondenserWaterTests.SurveyDate, 'MM'))


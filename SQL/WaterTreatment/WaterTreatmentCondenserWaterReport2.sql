Create VIEW ViewWaterTreatmentCondenserWaterReport2 AS

SELECT			CONCAT(BaseComponents.dbo.ViewUniversityBuildings.FacilityName, '-', dbo.WaterTreatmentCondenserWaterTests.LoopType) As BuildingSystem,
				dbo.WaterTreatmentCondenserWaterTests.TowerOperating AS Is_the_Tower_Running,
				AVG(dbo.WaterTreatmentCondenserWaterTests.Conductivity) AS AvgConductivity, 
				CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.TRASAR),2,1) AS decimal(18,2)) AS AvgTRASAR, 
				CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.pH),2,1) AS decimal(18,2)) AS AvgpH, 
				CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.FreeChlorine),2,1) AS decimal(18,2)) AS AvgFreeChlorine,  
				CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.ORP),2,1) AS decimal(18,2)) AS AvgORP,
				CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.TotalBacteria),2,1) AS decimal(18,2)) AS AvgTotalBacteria,
				dbo.WaterTreatmentCondenserWaterTests.PumpSpeedAdjustment AS PumpSpeedAdjustment,
				CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.StrokeSetting),2,1) AS decimal(18,2)) AS StrokeSetting, 
				CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.Tempurature),2,1) AS decimal(18,2)) AS AvgTemperature,
				dbo.WaterTreatmentCondenserWaterTests.Notes AS Notes,
				dbo.WaterTreatmentCondenserWaterTests.DataEntryUser AS EntryUser,
				CONCAT(YEAR(dbo.WaterTreatmentCondenserWaterTests.SurveyDate), '-', FORMAT(dbo.WaterTreatmentCondenserWaterTests.SurveyDate, 'MM')) AS YearAndMonth
FROM            dbo.WaterTreatmentCondenserWaterTests LEFT OUTER JOIN
                         BaseComponents.dbo.ViewUniversityBuildings ON dbo.WaterTreatmentCondenserWaterTests.FacNum = BaseComponents.dbo.ViewUniversityBuildings.FacilityNumber
WHERE BaseComponents.dbo.ViewUniversityBuildings.FacilityName IS NOT NULL
AND dbo.WaterTreatmentCondenserWaterTests.SurveyDate >= DATEADD(day,-30, getdate())
GROUP BY CONCAT(BaseComponents.dbo.ViewUniversityBuildings.FacilityName, '-', dbo.WaterTreatmentCondenserWaterTests.LoopType), CONCAT(YEAR(dbo.WaterTreatmentCondenserWaterTests.SurveyDate), '-', FORMAT(dbo.WaterTreatmentCondenserWaterTests.SurveyDate, 'MM')), dbo.WaterTreatmentCondenserWaterTests.TowerOperating, dbo.WaterTreatmentCondenserWaterTests.PumpSpeedAdjustment, dbo.WaterTreatmentCondenserWaterTests.Notes, dbo.WaterTreatmentCondenserWaterTests.DataEntryUser


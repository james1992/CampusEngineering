Create VIEW ViewWaterTreatmentCondenserWaterReport2 AS

SELECT			CONCAT(BaseComponents.dbo.ViewUniversityBuildings.FacilityName, '-', dbo.WaterTreatmentCondenserWaterTests.LoopType) As BuildingSystem,
				dbo.WaterTreatmentCondenserWaterTests.TowerOperating AS Is_the_Tower_Running,
				AVG(dbo.WaterTreatmentCondenserWaterTests.Conductivity) AS AvgConductivity, 
				CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.TRASAR),2,1) AS decimal(18,2)) AS AvgTRASAR,
				CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.FreeChlorine),2,1) AS decimal(18,2)) AS AvgFreeChlorine,
				CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.TotalBacteria),2,1) AS decimal(18,2)) AS AvgTotalBacteria,
				dbo.WaterTreatmentCondenserWaterTests.PumpSpeedAdjustment AS PumpSpeedAdjustment,
				CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.MakeupMeter),2,1) AS decimal(18,2)) AS MakeupMeter,
				CAST(ROUND(AVG(dbo.WaterTreatmentCondenserWaterTests.BlowdownMeter),2,1) AS decimal(18,2)) AS BlowdownMeter,
				dbo.WaterTreatmentCondenserWaterTests.Notes AS Notes,
				dbo.WaterTreatmentCondenserWaterTests.DataEntryUser AS EntryUser, 
				CONCAT(YEAR(dbo.WaterTreatmentCondenserWaterTests.SurveyDate), '-', FORMAT(dbo.WaterTreatmentCondenserWaterTests.SurveyDate, 'MM')) AS YearAndMonth
FROM            dbo.WaterTreatmentCondenserWaterTests LEFT OUTER JOIN
                         BaseComponents.dbo.ViewUniversityBuildings ON dbo.WaterTreatmentCondenserWaterTests.FacNum = BaseComponents.dbo.ViewUniversityBuildings.FacilityNumber
WHERE BaseComponents.dbo.ViewUniversityBuildings.FacilityName IS NOT NULL AND ((Month(SurveyDate) = Month(GETDATE())) AND (YEAR(SurveyDate) = YEAR(GETDATE())))
GROUP BY CONCAT(BaseComponents.dbo.ViewUniversityBuildings.FacilityName, '-', dbo.WaterTreatmentCondenserWaterTests.LoopType), CONCAT(YEAR(dbo.WaterTreatmentCondenserWaterTests.SurveyDate), '-', FORMAT(dbo.WaterTreatmentCondenserWaterTests.SurveyDate, 'MM')), dbo.WaterTreatmentCondenserWaterTests.TowerOperating, dbo.WaterTreatmentCondenserWaterTests.PumpSpeedAdjustment, dbo.WaterTreatmentCondenserWaterTests.Notes, dbo.WaterTreatmentCondenserWaterTests.DataEntryUser


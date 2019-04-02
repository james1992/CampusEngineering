USE [FacilitiesMaintenance]
GO

/****** Object:  View [dbo].[ViewWaterTreatmentCondenserWaterMonthlyReport]    Script Date: 4/1/2019 1:27:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ViewWaterTreatmentClosedWaterLoopsTest]
AS
SELECT        TOP (100) PERCENT BaseComponents.dbo.ViewUniversityBuildings.FacilityName, BaseComponents.dbo.ViewUniversityBuildings.FacilityNumber, BaseComponents.dbo.ViewUniversityBuildings.SHAPE,
						 dbo.WaterTreatmentCondenserWaterTests.LoopType, CONVERT(VARCHAR(10), 
                         dbo.WaterTreatmentCondenserWaterTests.SurveyDate, 111) AS SurveyDate,
						 dbo.WaterTreatmentCondenserWaterTests.Conductivity, 
						 dbo.WaterTreatmentCondenserWaterTests.pH, 
						 dbo.WaterTreatmentCondenserWaterTests.Azole,
						 dbo.WaterTreatmentCondenserWaterTests.Copper,
						 dbo.WaterTreatmentCondenserWaterTests.Iron,   
						 dbo.WaterTreatmentCondenserWaterTests.TotalBacteria,  
						 dbo.WaterTreatmentCondenserWaterTests.MakeupMeter,
						 dbo.WaterTreatmentCondenserWaterTests.MildCopperCorrosionRate,
						 dbo.WaterTreatmentCondenserWaterTests.MildSteelCorrosionRate,
                         dbo.WaterTreatmentCondenserWaterTests.Notes, 
						 dbo.WaterTreatmentCondenserWaterTests.DataEntryUser
FROM            dbo.WaterTreatmentCondenserWaterTests LEFT OUTER JOIN
                         BaseComponents.dbo.ViewUniversityBuildings ON dbo.WaterTreatmentCondenserWaterTests.FacNum = BaseComponents.dbo.ViewUniversityBuildings.FacilityNumber
ORDER BY SurveyDate DESC
GO

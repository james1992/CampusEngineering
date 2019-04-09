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
						 dbo.WaterTreatmentClosedLoopsWaterTests.LoopType, CONVERT(VARCHAR(10), 
                         dbo. WaterTreatmentClosedLoopsWaterTests.SurveyDate, 111) AS SurveyDate,
						 dbo. WaterTreatmentClosedLoopsWaterTests.Conductivity, 
						 dbo. WaterTreatmentClosedLoopsWaterTests.pH, 
						 dbo. WaterTreatmentClosedLoopsWaterTests.Azole,
						 dbo. WaterTreatmentClosedLoopsWaterTests.Copper,
						 dbo. WaterTreatmentClosedLoopsWaterTests.Iron,   
						 dbo. WaterTreatmentClosedLoopsWaterTests.TotalBacteria,  
						 dbo. WaterTreatmentClosedLoopsWaterTests.MakeupMeter,
						 dbo. WaterTreatmentClosedLoopsWaterTests.MildCopperCorrosionRate,
						 dbo. WaterTreatmentClosedLoopsWaterTests.MildSteelCorrosionRate,
                         dbo. WaterTreatmentClosedLoopsWaterTests.Notes, 
						 dbo. WaterTreatmentClosedLoopsWaterTests.DataEntryUser
FROM            dbo. WaterTreatmentClosedLoopsWaterTests LEFT OUTER JOIN
                         BaseComponents.dbo.ViewUniversityBuildings ON dbo. WaterTreatmentClosedLoopsWaterTests.FacNum = BaseComponents.dbo.ViewUniversityBuildings.FacilityNumber
ORDER BY SurveyDate DESC
GO

USE [FacilitiesMaintenance]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WaterTreatmentClosedLoopsWaterReport](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BuildingSystem] [nvarchar](200) NULL,
	[AvgConductivity] [int] NULL,
	[AvgpH] [decimal](18, 2) NULL,
	[AvgAzole] [decimal](18, 2) NULL,
	[AvgTotalBacteria] [int] NULL,
	[AvgCopper] [decimal](18, 2) NULL,
	[AvgIron] [decimal](18, 2) NULL,
	[AvgMakeupMeter] [decimal](18, 2) NULL,
	[AvgMildCopperCorrosionRate] [decimal](18, 2) NULL,
	[AvgMildSteelCorrosionRate] [decimal](18, 2) NULL,
	[YearAndMonth] [nvarchar](15) NULL,
);
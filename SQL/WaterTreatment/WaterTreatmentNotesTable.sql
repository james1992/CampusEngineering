USE [FacilitiesMaintenance]
GO

/****** Object:  Table [dbo].[WaterTreatmentNotesTable]    Script Date: 7/17/2019 10:44:53 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WaterTreatmentNotesTable](
	[UniqueID] [int] IDENTITY(1,1) NOT NULL,
	[WorkOrderNumber] [varchar](10) NOT NULL,
	[Notes] [varchar](500) NULL,
	[Date] [datetime] NOT NULL,
	[CreatedBy] [varchar](50) NOT NULL,
	[FacNum] [varchar](5) NOT NULL
) ON [PRIMARY]
GO



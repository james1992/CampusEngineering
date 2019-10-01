USE [FacilitiesConstruction]
GO

/****** Object:  Table [dbo].[BlindsAndShades]    Script Date: 9/5/2019 12:09:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BlindsAndShades](
	[UniqueID] [int] IDENTITY(1,1) NOT NULL,
	[FacNum] [varchar](5) NOT NULL,
	[Department] [varchar](50) NOT NULL,
	[Room] [varchar](50) NOT NULL,
	[Location] [varchar](50) NULL,
	[FundingSource] [varchar](50) NOT NULL,
	[Picture] [image] NULL,
	[Notes] [varchar](500) NULL,
	[UserName] [varchar](50) NULL,
	[Date] [datetime] NULL,
 CONSTRAINT [PK_BlindsAndShades] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO



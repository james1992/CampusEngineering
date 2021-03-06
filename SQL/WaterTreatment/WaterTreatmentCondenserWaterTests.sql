------------------------------------------------------------------------------------------------------------
--Written by Microsoft SQL Server Manager GUI
--Edited by Yurika Harada
--DateCreated: October 10, 2018
--DateEdited: October 10, 2018
--This code creates more customized tables for the Water Treatment Project.
--The code was edited to create the domain tables and to include the values for the domains.
------------------------------------------------------------------------------------------------------------


USE [FacilitiesMaintenance]
GO

/****** Object:  Table [dbo].[WaterTreatmentCondenserWaterTests]    Script Date: 10/10/2018 7:55:45 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--Creates a sub-table in the WaterTreatment Database
CREATE TABLE FacilitiesMaintenance.dbo.WaterTreatmentDomainsChemicalInventory
	(
	ID int NOT NULL IDENTITY,
	ChemicalInventory varchar(50) NOT NULL,

	UNIQUE (ChemicalInventory),
	PRIMARY KEY (ID)
		);

--Adds 1 value into the above table
INSERT INTO FacilitiesMaintenance.dbo.WaterTreatmentDomainsChemicalInventory (ChemicalInventory)
VALUES ('Level Okay' );
--Adds another value into the above table
INSERT INTO FacilitiesMaintenance.dbo.WaterTreatmentDomainsChemicalInventory (ChemicalInventory)
VALUES ('Needs Filling' );

--Creates another sub-table in the WaterTreatment Database
CREATE TABLE FacilitiesMaintenance.dbo.WaterTreatmentDomainsDebris
	(
	ID int NOT NULL IDENTITY,
	Debris varchar(50) NOT NULL,

	UNIQUE (Debris),
	PRIMARY KEY (ID)
		);

--Adds 1 value into the above table
INSERT INTO FacilitiesMaintenance.dbo.WaterTreatmentDomainsDebris (Debris)
VALUES ('Clean' );
--Adds another value into the above table
INSERT INTO FacilitiesMaintenance.dbo.WaterTreatmentDomainsDebris (Debris)
VALUES ('Dirty' );

--Creates a third sub-table in the WaterTreatment Database
CREATE TABLE FacilitiesMaintenance.dbo.WaterTreatmentDomainsMeteringPumpOperation
	(
	ID int NOT NULL IDENTITY,
	MeteringPumpOperation varchar(50) NOT NULL,

	UNIQUE (MeteringPumpOperation),
	PRIMARY KEY (ID)
		);

--Adds 1 value into the above table
INSERT INTO FacilitiesMaintenance.dbo.WaterTreatmentDomainsMeteringPumpOperation (MeteringPumpOperation)
VALUES ('Correct' );
--Adds another value into the above table
INSERT INTO FacilitiesMaintenance.dbo.WaterTreatmentDomainsMeteringPumpOperation (MeteringPumpOperation)
VALUES ('Not Correct' );

--Creates a fourth sub-table in the WaterTreatment Database
CREATE TABLE FacilitiesMaintenance.dbo.WaterTreatmentDomainsPumpSpeedAdjustment
	(
	ID int NOT NULL IDENTITY,
	PumpSpeedAdjustment varchar(50) NOT NULL,

	UNIQUE (PumpSpeedAdjustment),
	PRIMARY KEY (ID)
		);

--Adds 1 value into the above table
INSERT INTO FacilitiesMaintenance.dbo.WaterTreatmentDomainsPumpSpeedAdjustment (PumpSpeedAdjustment)
VALUES ('Not Adjusted' );
--Adds another value into the above table
INSERT INTO FacilitiesMaintenance.dbo.WaterTreatmentDomainsPumpSpeedAdjustment (PumpSpeedAdjustment)
VALUES ('Up' );
--Adds a third value into the above table
INSERT INTO FacilitiesMaintenance.dbo.WaterTreatmentDomainsPumpSpeedAdjustment (PumpSpeedAdjustment)
VALUES ('Down' );

--Creates the last sub-table in the WaterTreatment Database
CREATE TABLE FacilitiesMaintenance.dbo.WaterTreatmentDomainsUnitCondition
	(
	ID int NOT NULL IDENTITY,
	UnitCondition varchar(50) NOT NULL,

	UNIQUE (UnitCondition),
	PRIMARY KEY (ID)
		);

--Adds 1 value into the above table
INSERT INTO FacilitiesMaintenance.dbo.WaterTreatmentDomainsUnitCondition (UnitCondition)
VALUES ('Good' );
--Adds another value into the above table
INSERT INTO FacilitiesMaintenance.dbo.WaterTreatmentDomainsUnitCondition (UnitCondition)
VALUES ('Poor' );

--Creates main table
CREATE TABLE [dbo].[WaterTreatmentCondenserWaterTests](
	[UniqueID] [int] NOT NULL identity,
	[FacNum] [varchar](5) NOT NULL,
	[ContentType] [varchar](50) NOT NULL,
	[LoopType] [varchar](50) NOT NULL,
	[EntryGroup] [varchar](50) NOT NULL,
	[SurveyDate] [datetime] NOT NULL,
	[Conductivity] [int] NULL,
	[TRASAR] [decimal](18, 9) NULL,
	[pH] [decimal](18, 9) NULL,
	[ORP] [int] NULL,
	[MAlkalinity] [int] NULL,
	[TotalHardness] [int] NULL,
	[CalciumHardness] [int] NULL,
	[Phosphonate] [decimal](18, 9) NULL,
	[OrthoPhosphate] [decimal](18, 9) NULL,
	[Polymer] [decimal](18, 9) NULL,
	[Zinc] [decimal](18, 9) NULL,
	[Azole] [decimal](18, 9) NULL,
	[FreeChlorine] [decimal](18, 9) NULL,
	[Copper] [decimal](18, 9) NULL,
	[Iron] [decimal](18, 9) NULL,
	[TotalBacteria] [int] NULL,
	[MakeupMeter] [decimal](18, 9) NULL,
	[BlowdownMeter] [decimal](18, 9) NULL,
	[WaterMeterCycles] [decimal](18, 9) NULL,
	[MildSteelCorrosionRate] [decimal](18, 9) NULL,
	[MildCopperCorrosionRate] [decimal](18, 9) NULL,
	[MeteringPumpOperation] [varchar](50) NULL,
	[UnitCondition] [varchar](50) NULL,
	[Debris] [varchar](50) NULL,
	[Filters] [varchar](50) NULL,
	[ChemicalInventory] [varchar](50) NULL,
	[Notes] [varchar](500) NULL,
	[DataEntryUser] [varchar](50) NULL,
	[PumpSpeedAdjustment] [varchar](50) NULL,
	[StrokeSetting] [decimal](18, 9) NULL,
	[Tempurature] [decimal](18, 9) NULL,
	[Created] [datetime] NOT NULL,
	[CreatedBy] [varchar](50) NOT NULL,

PRIMARY KEY (UniqueID),
FOREIGN KEY (ChemicalInventory) REFERENCES FacilitiesMaintenance.dbo.WaterTreatmentDomainsChemicalInventory(ChemicalInventory) ON UPDATE CASCADE ON DELETE CASCADE,

FOREIGN KEY (Debris) REFERENCES FacilitiesMaintenance.dbo.WaterTreatmentDomainsDebris(Debris) ON UPDATE CASCADE ON DELETE CASCADE,

FOREIGN KEY (MeteringPumpOperation) REFERENCES FacilitiesMaintenance.dbo.WaterTreatmentDomainsMeteringPumpOperation(MeteringPumpOperation) ON UPDATE CASCADE ON DELETE CASCADE,

FOREIGN KEY (PumpSpeedAdjustment) REFERENCES FacilitiesMaintenance.dbo.WaterTreatmentDomainsPumpSpeedAdjustment(PumpSpeedAdjustment) ON UPDATE CASCADE ON DELETE CASCADE,

FOREIGN KEY (UnitCondition) REFERENCES FacilitiesMaintenance.dbo.WaterTreatmentDomainsUnitCondition(UnitCondition) ON UPDATE CASCADE ON DELETE CASCADE
);

ALTER TABLE [dbo].[WaterTreatmentCondenserWaterTests] ADD  CONSTRAINT [DF_WaterTreatmentCondenserWaterTests_Created]  DEFAULT (getdate()) FOR [Created]
GO



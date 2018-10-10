------------------------------------------------------------------------------------------------------------
--Written by Yurika Harada
--DateCreated: October 9, 2018
--DateEdited: October 9, 2018
--This code creates customized tables for the Water Treatment Project.
------------------------------------------------------------------------------------------------------------

--Creates a database named WaterTreatment
CREATE DATABASE WaterTreatment;
	GO

--Creates sub-table in the WaterTreatment Database
CREATE TABLE WaterTreatment.dbo.WaterTreatmentDomainsLeaks
	(
	ID int NOT NULL IDENTITY,
	Leaks varchar(10) NOT NULL,

	UNIQUE (Leaks),
	PRIMARY KEY (ID)
		);

--Adds 1 value into the above table
INSERT INTO WaterTreatment.dbo.WaterTreatmentDomainsLeaks (Leaks)
VALUES ('Leaks' );
--Adds another value into the above table
INSERT INTO WaterTreatment.dbo.WaterTreatmentDomainsLeaks (Leaks)
VALUES ('No Leaks' );

--Creates main table
CREATE TABLE WaterTreatment.dbo.WaterTreatmentClosedLoopsWaterTests
	(
	UniqueID int NOT NULL IDENTITY,
	FacNum varchar(5) NOT NULL,
	LoopType varchar(100) NOT NULL,
	EntryGroup varchar (10) NOT NULL,
	Conductivity int,
	pH decimal(18,5),
	MolybDate decimal(18,5),
	Nitrite int, 
	Azole decimal(18,5),
	Copper decimal(18,5),
	Iron decimal(18,5),
	TotalBacteria int,
	MakeupMeter decimal(18,5),
	MildCopperCorrosionRate decimal(18,5),
	MildSteelCorrosionRate decimal(18,5),
	Leaks varchar(10),
	Notes varchar(500),
	DataEntryUser varchar(50),
	SurveyDate datetime NOT NULL,
	CreateDate datetime NOT NULL,
	CreatedBy varchar(50),


PRIMARY KEY (UniqueID),
 FOREIGN KEY (Leaks) REFERENCES WaterTreatment.dbo.WaterTreatmentDomainsLeaks(Leaks) ON UPDATE CASCADE ON DELETE CASCADE
);
--Alter Table function makes the CreateDate feature grab the current date as a default.
ALTER TABLE WaterTreatment.dbo.WaterTreatmentClosedLoopsWaterTests ADD  CONSTRAINT [DF_EXAMPLE_date]  DEFAULT (getdate()) FOR CreateDate
GO
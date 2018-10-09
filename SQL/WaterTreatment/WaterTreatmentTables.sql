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
--Creates main table
CREATE TABLE WaterTreatment.dbo.WaterTreatmentClosedLoopsWaterTests
	(
	UniqueID int NOT NULL IDENTITY,
	FacNum varchar(5) NOT NULL,
	LoopType varchar(100) NOT NULL,
	EntryGroup varchar (10) NOT NULL,
	Conductivity int(4),
	pH decimal(2,1),
	MolybDate decimal(3,3),
	Nitrite int(3), 
	Azole decimal(2,1),
	Copper decimal(1,5),
	Iron decimal(3,3),
	TotalBacteria int(3),
	MakeupMeter decimal(6,3),
	MildCopperCorrosionRate decimal,
	MildSteelCorrosionRate decimal,
	Leaks varchar(50),
	Notes varchar(500),
	DataEntryUser varchar(50),
	SurveyDate date() NOT NULL,
	CreatedDate date(GETDATE()) NOT NULL,
	Createdby varchar(50)




	PRIMARY KEY (UniqueID),
 FOREIGN KEY (Leaks) REFERENCES WaterTreatment.dbo.WaterTreatmentDomainsLeaks(Leaks) ON UPDATE CASCADE ON DELETE CASCADE
		);
------------------------------------------------------------------------------------------------------------
--Written by Yurika Harada
--DateCreated: October 9, 2018
--DateEdited: October 9, 2018
--This code creates customized tables for the Water Treatment Project.
------------------------------------------------------------------------------------------------------------

--Creates a database named WaterTreatment
CREATE DATABASE WaterTreatment;
	GO

--Creates sub-tables in the WaterTreatment Database
CREATE TABLE WaterTreatment.dbo.DROPDOWNONE
(
ID int NOT NULL IDENTITY,
Training varchar(100) NOT NULL,
UNIQUE (Training),

PRIMARY KEY (ID)
);

CREATE TABLE WaterTreatment.dbo.DROPDOWNTWO
	(
	ID int NOT NULL IDENTITY,
	Equipment varchar(100) NOT NULL,

	UNIQUE (Equipment),
	PRIMARY KEY (ID)
		);
--Creates main table
CREATE TABLE WaterTreatment.dbo.WaterTreatmentChilledWaterTests
	(
	UniqueID int NOT NULL IDENTITY,
	FacNum int(5) NOT NULL,
	FacName varchar(100) NOT NULL,
	LoopType varchar(100) NOT NULL,
	EntryGroup varchar (10) NOT NULL,
	Conductivity int(4) NOT NULL,
	pH decimal(2,1) NOT NULL,
	MolybDate decimal(3,1) NOT NULL,
	Nitrite int(3) NOT NULL, 
	Azole decimal(2,1),
	Copper decimal(1,5),
	Iron decimal(3,2) NOT NULL,
	TotalBacteria int(3),
	MakeupMeter decimal(6,2),
	MildCopperCorrosionRate decimal,
	MildSteelCorrosionRate decimal,
	Leaks varchar(50),
	Notes varchar(500),
	DataEntryUser varchar(50),
	SurveyDate date(GETDATE()) NOT NULL, --may need to change
	UpdateChilledWaterDetails varchar(300),
	Title varchar(50),
	ItemType varchar(50),
	Path varchar(300) NOT NULL,




	PRIMARY KEY (UniqueID),
	--FOREIGN KEY (Equipment) REFERENCES DROPDOWNONE(Equipment) ON UPDATE CASCADE ON DELETE CASCADE,
	--FOREIGN KEY (TrainingType) REFERENCES DROPDOWNTWO(Training) ON UPDATE CASCADE ON DELETE CASCADE
		);
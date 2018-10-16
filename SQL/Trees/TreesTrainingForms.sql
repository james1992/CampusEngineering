------------------------------------------------------------------------------------------------------------
--Written by Yurika Harada
--Date Created: October 9, 2018
--This code creates customized tables for Trees Project managed by Sara Shores.
--These tables are meant to record what kind of training employees need and when the training is happening.
------------------------------------------------------------------------------------------------------------

--Creates a database named Trees
USE FacilitiesMaintenance;
	GO

--Creates 3 tables in the Tree Database
CREATE TABLE dbo.GroundsTrainingType
(
ID int NOT NULL IDENTITY,
Training varchar(100) NOT NULL,
UNIQUE (Training),

PRIMARY KEY (ID)
);

--Adds 1 value into the above table
INSERT INTO dbo.GroundsTrainingType (Training)
VALUES ('Manual' );
--Adds another value into the above table
INSERT INTO dbo.GroundsTrainingType (Training)
VALUES ('Class' );
--Adds a third value into the above table
INSERT INTO dbo.GroundsTrainingType (Training)
VALUES ('Field' );


CREATE TABLE dbo.GroundsTrainingEquipment
	(
	ID int NOT NULL IDENTITY,
	Equipment varchar(100) NOT NULL,

	UNIQUE (Equipment),
	PRIMARY KEY (ID)
		);

--Adds 1 value into the above table
INSERT INTO .dbo.GroundsTrainingEquipment (Equipment)
VALUES ('Chainsaw' );
--Adds another value into the above table
INSERT INTO .dbo.GroundsTrainingEquipment (Equipment)
VALUES ('Chipper' );
--Adds a third value into the above table
INSERT INTO .dbo.GroundsTrainingEquipment (Equipment)
VALUES ('Genie' );
--Adds another value into the above table
INSERT INTO .dbo.GroundsTrainingEquipment (Equipment)
VALUES ('Ground Crew' );
--Adds another value into the above table
INSERT INTO .dbo.GroundsTrainingEquipment (Equipment)
VALUES ('JLG' );
INSERT INTO .dbo.GroundsTrainingEquipment (Equipment)
VALUES ('Hi Ranger' );

CREATE TABLE .dbo.GroundsTraining 
	(
	UniqueID int NOT NULL IDENTITY,
	FullName varchar(100) NOT NULL,
	Equipment varchar(100) NOT NULL,
	TrainingType varchar(100) NOT NULL,
	TrainingDate date NOT NULL,

	PRIMARY KEY (UniqueID),
	FOREIGN KEY (Equipment) REFERENCES GroundsTrainingEquipment(Equipment) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (TrainingType) REFERENCES GroundsTrainingType(Training) ON UPDATE CASCADE ON DELETE CASCADE
		);
------------------------------------------------------------------------------------------------------------
--Written by Yurika Harada
--Date: October 9, 2018
--This code creates customized for Trees Project managed by Sara Shores.
--These tables are meant to record what kind of training employees need and when the training is happening.
------------------------------------------------------------------------------------------------------------

--Creates a database named Trees
CREATE DATABASE Trees;
	GO

--Creates 3 tables in the Tree Database
CREATE TABLE Trees.dbo.GroundsTrainingType
(
ID int NOT NULL IDENTITY,
Training varchar(100) NOT NULL,
UNIQUE (Training),

PRIMARY KEY (ID)
);

CREATE TABLE Trees.dbo.GroundsTrainingEquipment
	(
	ID int NOT NULL IDENTITY,
	Equipment varchar(100) NOT NULL,

	UNIQUE (Equipment),
	PRIMARY KEY (ID)
		);

CREATE TABLE Trees.dbo.GroundsTraining 
	(
	UniqueID int NOT NULL IDENTITY,
	FullName varchar(50) NOT NULL,
	Equipment varchar(100) NOT NULL,
	TrainingType varchar(100) NOT NULL,
	TrainingDate date NOT NULL,

	PRIMARY KEY (UniqueID),
	FOREIGN KEY (Equipment) REFERENCES GroundsTrainingEquipment(Equipment) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (TrainingType) REFERENCES GroundsTrainingType(Training) ON UPDATE CASCADE ON DELETE CASCADE
		);
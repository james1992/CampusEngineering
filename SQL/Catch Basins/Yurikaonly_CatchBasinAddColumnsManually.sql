------------------------------------------------------------------------------------------------------------
--Written by Yurika Harada
--DateCreated: October 12, 2018
--DateEdited: October 12, 2018
--This code creates a domain table and its values for the Catch Basin Project.
------------------------------------------------------------------------------------------------------------


--Creates sub-table in the WaterTreatment Database
CREATE TABLE FacilitiesMaintenance.dbo.GroundsCatchBasinsInspectionsCompleted
	(
	ID int NOT NULL IDENTITY,
	Progress varchar(50) NOT NULL,

	UNIQUE (Progress),
	PRIMARY KEY (ID)
		);

--Adds 1 value into the above table
INSERT INTO FacilitiesMaintenance.dbo.GroundsCatchBasinsInspectionsCompleted (Progress)
VALUES ('Yes' );
--Adds another value into the above table
INSERT INTO FacilitiesMaintenance.dbo.GroundsCatchBasinsInspectionsCompleted (Progress)
VALUES ('No' );
--Adds another value into the above table
INSERT INTO FacilitiesMaintenance.dbo.GroundsCatchBasinsInspectionsCompleted (Progress)
VALUES ('Done' );

ALTER TABLE GROUNDSCATCHBASINSINSPECTIONFORM
ADD FOREIGN KEY (SupplementalWork) REFERENCES FacilitiesMaintenance.dbo.GroundsCatchBasinsInspectionsCompleted(Progress);
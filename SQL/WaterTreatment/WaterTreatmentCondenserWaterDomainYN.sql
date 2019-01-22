------------------------------------------------------------------------------------------------------------
--Date Created: 1/16/2019
--This code is meant to update the table scheme for the Water Treatment Project managed by Brett M and the NALCO team.
------------------------------------------------------------------------------------------------------------

--Goes into the Facilities Maintenance database.
USE FacilitiesMaintenance;
	GO

--Creates 3 tables in the Water Treatment Domain
CREATE TABLE dbo.WaterTreatmentDomainsYN
(
ID int NOT NULL IDENTITY,
GlobalYN varchar(5) NOT NULL,
UNIQUE (GlobalYN),

PRIMARY KEY (ID)
);

--Adds 1 value into the above table
INSERT INTO dbo.WaterTreatmentDomainsYN (GlobalYN)
VALUES ('Yes' );
--Adds another value into the above table
INSERT INTO dbo.WaterTreatmentDomainsYN (GlobalYN)
VALUES ('No' );
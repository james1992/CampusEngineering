USE CampusEngineeringOperations

IF OBJECT_ID('tempdb.dbo.#ExtinguisherInspectionsMostRecent') IS NOT NULL
	DROP TABLE #ExtinguisherInspectionsMostRecent

CREATE TABLE #ExtinguisherInspectionsMostRecent (
	LocationBarCode nchar(20) null,
	MaintenanceType nchar(50) null,
	MaintenanceDate date null,
	MaintenanceStatus varchar(12) null,
	MaintenanceCount int null)
GO

INSERT INTO #ExtinguisherInspectionsMostRecent

SELECT	InnerMostRecentInspection.LocationBarCode,
		InnerMostRecentInspection.MaintenanceType,
		InnerMostRecentInspection.MaintenanceDate,
		InnerMostRecentInspection.MaintenanceStatus,
		InnerMostRecentInspection.MaintenanceCount

FROM (SELECT	LocationBarCode, 
				MaintenanceType, 
				MaintenanceDate, 
				CASE	WHEN Year(MaintenanceDate) = Year(GetDAte()) THEN 'TestComplete' 
						WHEN Year(MaintenanceDate) + 1 = Year(GetDate()) AND Month(MaintenanceDate) > Month(GetDate()) THEN 'TestComplete' 
						WHEN Year(MaintenanceDate) + 1 = Year(GetDate()) AND Month(MaintenanceDate) = Month(GetDate()) THEN 'TestDue' 
						ELSE 'Past Due' END AS MaintenanceStatus, 
				CASE	WHEN Year(MaintenanceDate) = Year(GetDAte()) THEN 1 
						WHEN Year(MaintenanceDate) + 1 = Year(GetDate()) AND Month(MaintenanceDate) > Month(GetDate()) THEN 1 
						ELSE 0 END AS MaintenanceCount
FROM dbo.FireExtinguishersInspections
WHERE (ID IN (SELECT MAX(ID) AS ID
              FROM  dbo.FireExtinguishersInspections AS subquery
              GROUP BY LocationBarCode))) AS InnerMostRecentInspection
GO

TRUNCATE TABLE sysgen.FireExtinguisherBuildingProgress
GO

INSERT INTO sysgen.FireExtinguisherBuildingProgress (FacilityNumber, FacilityName, CountExtinguishers, CountInspected, PercentInspected, InspectionMonth)

SELECT	InnerExtinguisherBuildingProgress.FacNum,
		InnerExtinguisherBuildingProgress.FacilityName,
		InnerExtinguisherBuildingProgress.CountExtinguishers,
		InnerExtinguisherBuildingProgress.CountComplete,
		InnerExtinguisherBuildingProgress.PrecentComplete,
		InnerExtinguisherBuildingProgress.InspectionMonth

FROM (SELECT TOP (100) PERCENT 
		LEFT(dbo.FIREEXTINGUISHERS.FloorID, 4) AS FacNum, 
		dbo.ViewUniversityBuildings.FacilityName, 
		COUNT(dbo.FIREEXTINGUISHERS.FacNum) AS CountExtinguishers, 
        ISNULL(SUM(#ExtinguisherInspectionsMostRecent.MaintenanceCount), 0) AS CountComplete, 
		ISNULL(SUM(#ExtinguisherInspectionsMostRecent.MaintenanceCount), 0) / CONVERT(decimal(6, 3), COUNT(dbo.FIREEXTINGUISHERS.FacNum)) AS PrecentComplete, 
		dbo.FireExtinguishersInspectionsMonth.InspectionMonth
FROM dbo.FIREEXTINGUISHERS LEFT OUTER JOIN
        dbo.ViewUniversityBuildings ON LEFT(dbo.FIREEXTINGUISHERS.FloorID, 4) = dbo.ViewUniversityBuildings.FacilityNumber LEFT OUTER JOIN
        dbo.FireExtinguishersInspectionsMonth ON LEFT(dbo.FIREEXTINGUISHERS.FloorID, 4) = dbo.FireExtinguishersInspectionsMonth.FacNum LEFT OUTER JOIN
        #ExtinguisherInspectionsMostRecent ON dbo.FIREEXTINGUISHERS.BarCode = #ExtinguisherInspectionsMostRecent.LocationBarCode
WHERE (dbo.FIREEXTINGUISHERS.FeatureStatus = N'Active')
GROUP BY LEFT(dbo.FIREEXTINGUISHERS.FloorID, 4), dbo.ViewUniversityBuildings.FacilityName, dbo.FireExtinguishersInspectionsMonth.InspectionMonth) AS InnerExtinguisherBuildingProgress
GO

UPDATE sysgen.FireExtinguisherBuildingProgress
SET sysgen.FireExtinguisherBuildingProgress.SHAPE = ViewUniversityBuildings.SHAPE
FROM sysgen.FireExtinguisherBuildingProgress
		INNER JOIN ViewUniversityBuildings
		ON FireExtinguisherBuildingProgress.FacilityNumber = ViewUniversityBuildings.FacilityNumber
GO

TRUNCATE TABLE sysgen.FireExtinguisherInspectionSheets
GO

INSERT INTO sysgen.FireExtinguisherInspectionSheets

SELECT 
		InnerInspectionSheet.FacilityNumber,
		InnerInspectionSheet.FacilityName,
		InnerInspectionSheet.Floor,
		InnerInspectionSheet.BarCode,
		InnerInspectionSheet.InspectionSequence,
		InnerInspectionSheet.LocationDescription,
		InnerInspectionSheet.LocationType,
		InnerInspectionSheet.Type,
		InnerInspectionSheet.ExtinguisherSize,
		InnerInspectionSheet.Notes,
		InnerInspectionSheet.MaintenanceStatus

FROM ( SELECT TOP (100) PERCENT 
		dbo.ViewUniversityBuildings.FacilityNumber, 
		dbo.ViewUniversityBuildings.FacilityName, 
		dbo.FIREEXTINGUISHERS.BarCode, 
		dbo.FIREEXTINGUISHERS.Floor, 
		dbo.FIREEXTINGUISHERS.InspectionSequence, 
		dbo.FIREEXTINGUISHERS.LocationDescription, 
		dbo.FIREEXTINGUISHERS.LocationType, 
		dbo.FIREEXTINGUISHERS.ExtinguisherType AS Type, 
		CONVERT(DECIMAL(3, 1), dbo.FIREEXTINGUISHERS.ExtinguisherSize) AS ExtinguisherSize, 
		dbo.FIREEXTINGUISHERS.Notes, 
		#ExtinguisherInspectionsMostRecent.MaintenanceStatus

FROM dbo.FIREEXTINGUISHERS LEFT OUTER JOIN
         #ExtinguisherInspectionsMostRecent ON dbo.FIREEXTINGUISHERS.BarCode = #ExtinguisherInspectionsMostRecent.LocationBarCode LEFT OUTER JOIN
         dbo.ViewUniversityBuildings ON dbo.FIREEXTINGUISHERS.FacNum = dbo.ViewUniversityBuildings.FacilityNumber

WHERE (dbo.FIREEXTINGUISHERS.FeatureStatus = N'Active')
ORDER BY dbo.FIREEXTINGUISHERS.Floor, dbo.FIREEXTINGUISHERS.InspectionSequence) AS InnerInspectionSheet
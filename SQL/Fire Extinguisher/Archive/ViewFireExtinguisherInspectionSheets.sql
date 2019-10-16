SELECT			TOP (100) PERCENT 
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
				dbo.ViewFireExtinguisherInspectionMostRecent.MaintenanceStatus

FROM            dbo.FIREEXTINGUISHERS LEFT OUTER JOIN
                         dbo.ViewFireExtinguisherInspectionMostRecent ON dbo.FIREEXTINGUISHERS.BarCode = dbo.ViewFireExtinguisherInspectionMostRecent.LocationBarCode LEFT OUTER JOIN
                         dbo.ViewUniversityBuildings ON dbo.FIREEXTINGUISHERS.FacNum = dbo.ViewUniversityBuildings.FacilityNumber

WHERE        (dbo.FIREEXTINGUISHERS.FeatureStatus = N'Active')
ORDER BY dbo.FIREEXTINGUISHERS.Floor, dbo.FIREEXTINGUISHERS.InspectionSequence
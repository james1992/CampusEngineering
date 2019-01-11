SELECT			TOP (100) PERCENT 
				dbo.FIREEXTINGUISHERS.FacNum, 
				COUNT(dbo.FIREEXTINGUISHERS.FacNum) AS CountExtinguishers, 
				ISNULL(SUM(dbo.ViewFireExtinguisherInspectionMostRecent.MaintenanceCount),0) AS CountComplete, 
				ISNULL(SUM(dbo.ViewFireExtinguisherInspectionMostRecent.MaintenanceCount),0) / CONVERT(decimal(6, 3), COUNT(dbo.FIREEXTINGUISHERS.FacNum)) AS PrecentComplete, 
				dbo.FireExtinguishersInspectionsMonth.InspectionMonth

FROM            dbo.FIREEXTINGUISHERS LEFT OUTER JOIN
                         dbo.FireExtinguishersInspectionsMonth ON dbo.FIREEXTINGUISHERS.FacNum = dbo.FireExtinguishersInspectionsMonth.FacNum LEFT OUTER JOIN
                         dbo.ViewFireExtinguisherInspectionMostRecent ON dbo.FIREEXTINGUISHERS.BarCode = dbo.ViewFireExtinguisherInspectionMostRecent.LocationBarCode

WHERE			(dbo.FIREEXTINGUISHERS.FeatureStatus = N'Active')
GROUP BY		dbo.FIREEXTINGUISHERS.FacNum, dbo.FireExtinguishersInspectionsMonth.InspectionMonth
SELECT	dbo.ENVIRONMENTALOILSPILLPREVENTION.SiteID, dbo.ENVIRONMENTALOILSPILLPREVENTION.Type AS SiteType, 
		dbo.ENVIRONMENTALOILSPILLPREVENTION.Capacity AS SiteCapacity, 
        dbo.ENVIRONMENTALOILSPILLPREVENTION.[Content] AS SiteContent, 
		dbo.ENVIRONMENTALOILSPILLPREVENTION.Description AS SiteDescription, 
                         
		CASE WHEN dbo.ViewOilSpillInspectionsInformation.NeedsAttention = 'Yes' THEN 'Needs Attention' 
		WHEN dbo.ENVIRONMENTALOILSPILLPREVENTION.InspectionFrequency = 'Monthly' AND MONTH(dbo.ViewOilSpillInspectionsInformation.InspectionDate) = MONTH(GETDATE()) AND YEAR(dbo.ViewOilSpillInspectionsInformation.InspectionDate) = YEAR(GETDATE()) THEN 'Inspection Complete' 
		WHEN dbo.ENVIRONMENTALOILSPILLPREVENTION.InspectionFrequency = 'Monthly' AND MONTH(dbo.ViewOilSpillInspectionsInformation.InspectionDate) + 1 = MONTH(GETDATE()) AND YEAR(dbo.ViewOilSpillInspectionsInformation.InspectionDate) = YEAR(GETDATE()) THEN 'Inspection Due' 
		WHEN dbo.ENVIRONMENTALOILSPILLPREVENTION.InspectionFrequency = 'Monthly' AND MONTH(dbo.ViewOilSpillInspectionsInformation.InspectionDate) + 1 < MONTH(GETDATE()) AND YEAR(dbo.ViewOilSpillInspectionsInformation.InspectionDate) = YEAR(GETDATE()) THEN 'Inspection Past Due' 
		WHEN dbo.ENVIRONMENTALOILSPILLPREVENTION.InspectionFrequency = 'Monthly' AND MONTH(dbo.ViewOilSpillInspectionsInformation.InspectionDate) - 11 = MONTH(GETDATE()) AND YEAR(dbo.ViewOilSpillInspectionsInformation.InspectionDate) + 1 = YEAR(GETDATE()) THEN 'Inspection Due' 
		
		
		WHEN dbo.ENVIRONMENTALOILSPILLPREVENTION.InspectionFrequency = 'Quarterly' AND DATEPART(QUARTER, dbo.ViewOilSpillInspectionsInformation.InspectionDate) = DATEPART(QUARTER, GETDATE()) AND YEAR(dbo.ViewOilSpillInspectionsInformation.InspectionDate) = YEAR(GETDATE()) THEN 'Inspection Complete' 
		WHEN dbo.ENVIRONMENTALOILSPILLPREVENTION.InspectionFrequency = 'Quarterly' AND DATEPART(QUARTER, dbo.ViewOilSpillInspectionsInformation.InspectionDate) + 1 = DATEPART(QUARTER, GETDATE()) AND YEAR(dbo.ViewOilSpillInspectionsInformation.InspectionDate) = YEAR(GETDATE()) THEN 'Inspection Due' 
		WHEN dbo.ENVIRONMENTALOILSPILLPREVENTION.InspectionFrequency = 'Quarterly' AND DATEPART(QUARTER, dbo.ViewOilSpillInspectionsInformation.InspectionDate) + 1 < DATEPART(QUARTER, GETDATE()) AND YEAR(dbo.ViewOilSpillInspectionsInformation.InspectionDate) = YEAR(GETDATE()) THEN 'Inspection Past Due' 
		WHEN dbo.ENVIRONMENTALOILSPILLPREVENTION.InspectionFrequency = 'Quarterly' AND DATEPART(QUARTER, dbo.ViewOilSpillInspectionsInformation.InspectionDate) - 3 = DATEPART(QUARTER, GETDATE()) AND YEAR(dbo.ViewOilSpillInspectionsInformation.InspectionDate) + 1 = YEAR(GETDATE()) THEN 'Inspection Due' 
		ELSE 'Inspection Past Due' 
		END AS InspectionStatus, 

        dbo.ENVIRONMENTALOILSPILLPREVENTION.InspectionFrequency, 
		dbo.ViewOilSpillInspectionsInformation.NeedsAttention, 
		dbo.ViewOilSpillInspectionsInformation.PrimaryContainmentInspected, 
        dbo.ViewOilSpillInspectionsInformation.SecondayContainmentInspected, 
		dbo.ViewOilSpillInspectionsInformation.InspectionDate, 
		dbo.ENVIRONMENTALOILSPILLPREVENTION.SHAPE
FROM            dbo.ViewOilSpillInspectionsInformation RIGHT OUTER JOIN
                         dbo.ENVIRONMENTALOILSPILLPREVENTION ON dbo.ViewOilSpillInspectionsInformation.SPCC_ID = dbo.ENVIRONMENTALOILSPILLPREVENTION.SiteID
WHERE        (dbo.ENVIRONMENTALOILSPILLPREVENTION.FeatureStatus = N'Active') AND (dbo.ENVIRONMENTALOILSPILLPREVENTION.InspectedBy = N'FOMS')
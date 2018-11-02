------------------------------------------------------------------------------------------------------------
--Written by Jay Dahlstrom
--Editted by Jay Dahlstrom
--DateCreated: March 12, 2017
--DateEdited: November 2, 2018
--This code creates a view for the Oil Inspection Project. 
--This is for the hydraulic elevators and determines which shop is responsible for inspections in the current month.
------------------------------------------------------------------------------------------------------------

Use EngineeringServices
GO

-- Copy below here into View

SELECT	dbo.ENVIRONMENTALOILSPILLPREVENTION.SiteID, 
		dbo.ENVIRONMENTALOILSPILLPREVENTION.Type AS SiteType, 
        dbo.ENVIRONMENTALOILSPILLPREVENTION.[Content] AS SiteContent, 
		dbo.ENVIRONMENTALOILSPILLPREVENTION.Capacity AS SiteCapacity, 
		dbo.ENVIRONMENTALOILSPILLPREVENTION.Description AS SiteDescription, 

		CASE WHEN MONTH(GETDATE()) = dbo.ENVIRONMENTALOILSPILLPREVENTION.QuarterlyInspectionIncrement  THEN 'Elevator Shop'
		WHEN (MONTH(GETDATE()) - dbo.ENVIRONMENTALOILSPILLPREVENTION.QuarterlyInspectionIncrement) % 3 = 0  THEN 'Elevator Shop'
		ELSE 'FOMS' END AS AssignedShop,
                         
		CASE WHEN dbo.ViewOilSpillInspectionsInformation.NeedsAttention = 'Yes' THEN 'Needs Attention' 
		WHEN dbo.ENVIRONMENTALOILSPILLPREVENTION.InspectionFrequency = 'Monthly' AND MONTH(dbo.ViewOilSpillInspectionsInformation.InspectionDate) = MONTH(GETDATE()) AND YEAR(dbo.ViewOilSpillInspectionsInformation.InspectionDate) = YEAR(GETDATE()) THEN 'Inspection Complete' 
		WHEN dbo.ENVIRONMENTALOILSPILLPREVENTION.InspectionFrequency = 'Monthly' AND MONTH(dbo.ViewOilSpillInspectionsInformation.InspectionDate) + 1 = MONTH(GETDATE()) AND YEAR(dbo.ViewOilSpillInspectionsInformation.InspectionDate) = YEAR(GETDATE()) THEN 'Inspection Due' 
		WHEN dbo.ENVIRONMENTALOILSPILLPREVENTION.InspectionFrequency = 'Monthly' AND MONTH(dbo.ViewOilSpillInspectionsInformation.InspectionDate) + 1 < MONTH(GETDATE()) AND YEAR(dbo.ViewOilSpillInspectionsInformation.InspectionDate) = YEAR(GETDATE()) THEN 'Inspection Past Due' 
		WHEN dbo.ENVIRONMENTALOILSPILLPREVENTION.InspectionFrequency = 'Monthly' AND MONTH(dbo.ViewOilSpillInspectionsInformation.InspectionDate) - 11 = MONTH(GETDATE()) AND YEAR(dbo.ViewOilSpillInspectionsInformation.InspectionDate) + 1 = YEAR(GETDATE()) THEN 'Inspection Due' 
		ELSE 'Inspection Past Due' 
		END AS InspectionStatus, 

        dbo.ENVIRONMENTALOILSPILLPREVENTION.InspectionFrequency, 
		dbo.ENVIRONMENTALOILSPILLPREVENTION.QuarterlyInspectionIncrement AS FirstElevatorShopInspection,
		dbo.ViewOilSpillInspectionsInformation.NeedsAttention, 
		dbo.ViewOilSpillInspectionsInformation.PrimaryContainmentInspected, 
        dbo.ViewOilSpillInspectionsInformation.SecondayContainmentInspected, 
		dbo.ViewOilSpillInspectionsInformation.InspectionDate, 
		dbo.ENVIRONMENTALOILSPILLPREVENTION.SHAPE
FROM            dbo.ViewOilSpillInspectionsInformation RIGHT OUTER JOIN
                         dbo.ENVIRONMENTALOILSPILLPREVENTION ON dbo.ViewOilSpillInspectionsInformation.SiteID = dbo.ENVIRONMENTALOILSPILLPREVENTION.SiteID
WHERE        (dbo.ENVIRONMENTALOILSPILLPREVENTION.FeatureStatus = N'Active') AND (dbo.ENVIRONMENTALOILSPILLPREVENTION.Type = N'Hydraulic Elevator')
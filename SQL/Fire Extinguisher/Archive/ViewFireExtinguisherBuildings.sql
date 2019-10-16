SELECT        dbo.ViewUniversityBuildings.FacilityNumber, 
dbo.ViewUniversityBuildings.FacilityName, 
dbo.FireExtinguishersBuildingInspectionsProgress.CountExtinguishers, 
dbo.FireExtinguishersBuildingInspectionsProgress.CountComplete, 
dbo.FireExtinguishersBuildingInspectionsProgress.PercentComplete, 
dbo.FireExtinguishersBuildingInspectionsProgress.InspectionMonth, 
dbo.ViewUniversityBuildings.SHAPE

FROM            dbo.ViewUniversityBuildings RIGHT OUTER JOIN
                         dbo.FireExtinguishersBuildingInspectionsProgress ON dbo.ViewUniversityBuildings.FacilityNumber = dbo.FireExtinguishersBuildingInspectionsProgress.FacNum
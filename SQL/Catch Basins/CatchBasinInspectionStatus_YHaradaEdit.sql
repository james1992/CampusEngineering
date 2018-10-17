------------------------------------------------------------------------------------------------------------
--Written by Yurika Harada
--DateCreated: October 12, 2018
--DateEdited: October 17, 2018
--This code creates a view for the Catch Basin Project. 
--The view is meant to hold the Inspection Status Column which will determine the map symbols on ArcGIS.
------------------------------------------------------------------------------------------------------------

Use FacilitiesMaintenance
GO

SELECT			dbo.GROUNDSCATCHBASINS.OBJECTID, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.StructureType, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.Inspector, 
                dbo.ViewGroundsCatchBasinInspectionsMostRecent.InspectionDate, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.Cleaned, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.SupplementalWork,
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.FollowUpInspectionRequired, 
                dbo.ViewGroundsCatchBasinInspectionsMostRecent.Notes, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.Downturn90, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.Downturn90PermenantInstall, 
                dbo.ViewGroundsCatchBasinInspectionsMostRecent.Downturn90Damaged, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisCoveringGrate, 
                dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisSumpFilled60Percent, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisInPipe, 
                dbo.ViewGroundsCatchBasinInspectionsMostRecent.DeadAnimalsOrVegitationStructur, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.SedimentSumpFilled60Percent, 
                dbo.ViewGroundsCatchBasinInspectionsMostRecent.TopSlabWithHoles, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.FrameNotFlush, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.WallsNotSound, 
                dbo.ViewGroundsCatchBasinInspectionsMostRecent.WallsGroutCracks, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.VegetationGrowingInPipeJoints, 
                dbo.ViewGroundsCatchBasinInspectionsMostRecent.SolidCoverNotInPlace, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.SolidCoverDifficultToRemove, 
                dbo.ViewGroundsCatchBasinInspectionsMostRecent.SolidCoverLockingMechanism, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.LadderMissingUnsafe, 
                dbo.ViewGroundsCatchBasinInspectionsMostRecent.OpenGrateCoveredByDebris, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.OpenGrateLockingMechanism, 
                dbo.ViewGroundsCatchBasinInspectionsMostRecent.OpenGrateNotInPlace, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.SignsofContaminationOrPollution, 
                dbo.ViewGroundsCatchBasinInspectionsMostRecent.REL_GLOBALID,


				--CASE WHEN statements:

				  CASE WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.FollowUpInspectionRequired = 'Yes' THEN 'Follow up Required'

				--Supplemental Work and Cleaning Required
				  WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.SupplementalWork = 'Yes' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.Cleaned = 'No' 
				  AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisCoveringGrate = 'Yes' OR dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisSumpFilled60Percent = 'Yes' 
				  OR dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisInPipe = 'Yes' OR dbo.ViewGroundsCatchBasinInspectionsMostRecent.DeadAnimalsOrVegitationStructur = 'Yes' 
				  THEN 'Supplemental Work and Cleaning Required'

				  --Supplemental Work only
				  WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.SupplementalWork = 'Yes'
				  AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisCoveringGrate = 'No' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisSumpFilled60Percent = 'No' 
				  AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisInPipe = 'No' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DeadAnimalsOrVegitationStructur = 'No' 
				  THEN 'Supplemental Work Required'
				  
				    --Cleaning Required
				  WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.SupplementalWork = 'No' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.Cleaned = 'No' 
				  AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisCoveringGrate = 'Yes' OR dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisSumpFilled60Percent = 'Yes' 
				  OR dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisInPipe = 'Yes' OR dbo.ViewGroundsCatchBasinInspectionsMostRecent.DeadAnimalsOrVegitationStructur = 'Yes' 
				  THEN 'Cleaning Required'

				  --Supplemental Work Done and Cleaning Needed
				  WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.SupplementalWork = 'Done' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.Cleaned = 'No' 
				  AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisCoveringGrate = 'Yes' OR dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisSumpFilled60Percent = 'Yes' 
				  OR dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisInPipe = 'Yes' OR dbo.ViewGroundsCatchBasinInspectionsMostRecent.DeadAnimalsOrVegitationStructur = 'Yes' 
				  THEN 'Supplemental Work Finished but Cleaning Required'
				  
				  --Cleaning Done but Supplemental Work NEEDED
				  WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.SupplementalWork = 'Yes' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.Cleaned = 'Yes' 
				  THEN 'Supplemental Work Required but Cleaning Done'
				  
				   --Year CASE WHEN statements
				  WHEN YEAR(dbo.ViewGroundsCatchBasinInspectionsMostRecent.InspectionDate) + 1 = YEAR(GETDATE()) THEN 'Inspection Due this Year'
				  WHEN YEAR(dbo.ViewGroundsCatchBasinInspectionsMostRecent.InspectionDate) + 2 <= YEAR(GETDATE()) THEN 'Has Not Been Inspected Within 2 Years or More'

				  --Supplemental Work and Cleaning Done
				  WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.SupplementalWork = 'Done' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.Cleaned = 'Yes' 
				  THEN 'Supplemental Work and Cleaning Done'
				  
				   --Work done, no cleaning needed.
				  WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.SupplementalWork = 'Done' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisCoveringGrate = 'No' 
				  AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisSumpFilled60Percent = 'No' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisInPipe = 'No' 
				  AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DeadAnimalsOrVegitationStructur = 'No'
				  THEN 'Supplemental Work Done and Cleaning Required'
				  
				  --Inspected this year, cleaning not needed
				  WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.SupplementalWork = 'No' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisCoveringGrate = 'Yes' 
				  AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisSumpFilled60Percent = 'Yes' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisInPipe = 'Yes' 
				  AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DeadAnimalsOrVegitationStructur = 'Yes' AND YEAR(dbo.ViewGroundsCatchBasinInspectionsMostRecent.InspectionDate) = YEAR(GETDATE())
				  THEN 'Inspected this Year, No Cleaning Required'

				  --Cleaning Done, No Supplemental Work Required
				  WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.Cleaned = 'Yes' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.SupplementalWork = 'No' 
				  THEN 'Cleaning Done, No Supplemental Work Required'

				  END AS InspectionStatus


FROM            dbo.ViewGroundsCatchBasinInspectionsMostRecent RIGHT OUTER JOIN
                         dbo.GROUNDSCATCHBASINS ON dbo.ViewGroundsCatchBasinInspectionsMostRecent.REL_GLOBALID = dbo.GROUNDSCATCHBASINS.GlobalID
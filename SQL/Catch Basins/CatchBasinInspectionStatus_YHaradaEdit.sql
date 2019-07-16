------------------------------------------------------------------------------------------------------------
--Written by Yurika Harada
--Editted by Jay Dahlstrom
--DateCreated: October 12, 2018
--DateEdited: October 24, 2018
--This code creates a view for the Catch Basin Project. 
--The view is meant to hold the Inspection Status Column which will determine the map symbols on ArcGIS.
------------------------------------------------------------------------------------------------------------

Use FacilitiesMaintenance
GO

SELECT			dbo.GROUNDSCATCHBASINS.OBJECTID, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.StructureType,
				
				--CASE WHEN statements:

				--Year CASE WHEN statements
				CASE WHEN --YEAR(dbo.ViewGroundsCatchBasinInspectionsMostRecent.InspectionDate) + 1 = YEAR(GETDATE()) THEN 'Inspection Due this Year'
				  
				-- Added this statement to satisfy Brian Davis request that points reset at Biennium end July, 2019 --> To be updated on 12/31/2020
				CAST(dbo.ViewGroundsCatchBasinInspectionsMostRecent.InspectionDate AS Date) < '07/01/2019' AND CAST(GETDATE() AS DATE) >= '07/01/2019' THEN 'Inspection Due'
				WHEN YEAR(dbo.ViewGroundsCatchBasinInspectionsMostRecent.InspectionDate) + 2 <= YEAR(GETDATE()) THEN 'Inspection Due (Prioritize)'
				WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.InspectionDate IS NULL THEN 'Inspection Due (Prioritize)'

				WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.FollowUpInspectionRequired = 'Yes' THEN 'Inspection Not Complete, Follow up Required'

				--Supplemental Work and Cleaning Required
				WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.SupplementalWork = 'Yes' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.Cleaned = 'No' 
				AND (dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisCoveringGrate = 'Yes' OR dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisSumpFilled60Percent = 'Yes' 
				OR dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisInPipe = 'Yes' OR dbo.ViewGroundsCatchBasinInspectionsMostRecent.DeadAnimalsOrVegitationStructur = 'Yes' OR 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.SedimentSumpFilled60Percent = 'Yes') 
				THEN 'Supplemental Work and Cleaning Required'

				--Supplemental Work only
				WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.SupplementalWork = 'Yes'
				AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisCoveringGrate = 'No' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisSumpFilled60Percent = 'No' 
				AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisInPipe = 'No' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DeadAnimalsOrVegitationStructur = 'No' AND 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.SedimentSumpFilled60Percent = 'No' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.Cleaned <> 'Yes' 
				THEN 'Supplemental Work Required'
				  
				--Cleaning Required
				WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.SupplementalWork = 'No' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.Cleaned = 'No' 
				AND (dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisCoveringGrate = 'Yes' OR dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisSumpFilled60Percent = 'Yes' 
				OR dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisInPipe = 'Yes' OR dbo.ViewGroundsCatchBasinInspectionsMostRecent.DeadAnimalsOrVegitationStructur = 'Yes' OR 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.SedimentSumpFilled60Percent = 'Yes') 
				THEN 'Cleaning Required'

				--Supplemental Work Done and Cleaning Needed
				WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.SupplementalWork = 'Done' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.Cleaned = 'No' 
				AND (dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisCoveringGrate = 'Yes' OR dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisSumpFilled60Percent = 'Yes' 
				OR dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisInPipe = 'Yes' OR dbo.ViewGroundsCatchBasinInspectionsMostRecent.DeadAnimalsOrVegitationStructur = 'Yes' OR 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.SedimentSumpFilled60Percent = 'Yes') 
				THEN 'Supplemental Work Done but Cleaning Required'
				  
				--Cleaning Done but Supplemental Work NEEDED
				WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.SupplementalWork = 'Yes' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.Cleaned = 'Yes' 
				THEN 'Supplemental Work Required but Cleaning Done'
				  
				--Supplemental Work and Cleaning Done
				WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.SupplementalWork = 'Done' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.Cleaned = 'Yes' 
				THEN 'Supplemental Work and Cleaning Done'
				  
				--Work done, no cleaning needed.
				WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.SupplementalWork = 'Done' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisCoveringGrate = 'No' 
				AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisSumpFilled60Percent = 'No' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisInPipe = 'No' 
				AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DeadAnimalsOrVegitationStructur = 'No' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.SedimentSumpFilled60Percent = 'No'
				THEN 'Supplemental Work Done'

				--Cleaning Done, No Supplemental Work Required
				WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.Cleaned = 'Yes' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.SupplementalWork = 'No' 
				THEN 'Cleaning Done'
				  
				--Inspected this year, no follow up
				WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.SupplementalWork = 'No' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisCoveringGrate = 'No' 
				AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisSumpFilled60Percent = 'No' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DebrisInPipe = 'No' 
				AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.DeadAnimalsOrVegitationStructur = 'No' AND dbo.ViewGroundsCatchBasinInspectionsMostRecent.SedimentSumpFilled60Percent = 'No' 
				AND YEAR(dbo.ViewGroundsCatchBasinInspectionsMostRecent.InspectionDate) = YEAR(GETDATE())
				THEN 'Inspected, No Cleaning or Supplemental Work Required'

				ELSE 'Inspection Due'

				END AS InspectionStatus,
				 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.Inspector, 
                dbo.ViewGroundsCatchBasinInspectionsMostRecent.InspectionDate, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.Cleaned, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.CleanedDate,
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.SupplementalWork AS SupplementalWorkRequired,
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
                CAST(dbo.GROUNDSCATCHBASINS.OBJECTID AS INT) AS ID,
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.DrainToLakeSticker, 
				dbo.GROUNDSCATCHBASINS.SHAPE

				


FROM            dbo.ViewGroundsCatchBasinInspectionsMostRecent RIGHT OUTER JOIN
                         dbo.GROUNDSCATCHBASINS ON dbo.ViewGroundsCatchBasinInspectionsMostRecent.REL_GLOBALID = dbo.GROUNDSCATCHBASINS.GlobalID
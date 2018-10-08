Use FacilitiesMaintenance
GO

SELECT			dbo.GROUNDSCATCHBASINS.OBJECTID, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.StructureType, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.Inspector, 
                dbo.ViewGroundsCatchBasinInspectionsMostRecent.InspectionDate, 
				dbo.ViewGroundsCatchBasinInspectionsMostRecent.Cleaned, 
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

				CASE WHEN dbo.ViewGroundsCatchBasinInspectionsMostRecent.FollowUpInspectionRequired = 'Yes' THEN 'Follow up Required'
					 WHEN YEAR(dbo.ViewGroundsCatchBasinInspectionsMostRecent.InspectionDate) = YEAR(GETDATE()) THEN 'Inspected this Year'
					 WHEN YEAR(dbo.ViewGroundsCatchBasinInspectionsMostRecent.InspectionDate) + 1 = YEAR(GETDATE()) THEN 'Inspected Last Year'
					 WHEN YEAR(dbo.ViewGroundsCatchBasinInspectionsMostRecent.InspectionDate) + 2 = YEAR(GETDATE()) THEN 'Inspected Two Years Ago'
					 WHEN YEAR(dbo.ViewGroundsCatchBasinInspectionsMostRecent.InspectionDate) + 3 <= YEAR(GETDATE()) THEN 'Inspected Three or More Years Ago'
					 ELSE 'Never Inspected'
				
				END AS InspectionStatus


FROM            dbo.ViewGroundsCatchBasinInspectionsMostRecent RIGHT OUTER JOIN
                         dbo.GROUNDSCATCHBASINS ON dbo.ViewGroundsCatchBasinInspectionsMostRecent.REL_GLOBALID = dbo.GROUNDSCATCHBASINS.GlobalID
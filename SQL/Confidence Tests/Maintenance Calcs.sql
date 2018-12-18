SELECT			OBJECTID, 
				System, 
				TestStatus, 
				CurrentMonth, 
				FacilityNumber, 
				FacilityName, 
				SystemLocation, 
				Serves, 
				MaintenanceReportYear, 
				DocumentStorage, 
				SystemDescription, 
				InspectionDate, 
				Notes, 
				UserID, 
				SHAPE, 
				CASE WHEN TestStatus = '5 Year Maintenance Complete' THEN 1 ELSE 0 END AS TestComplete
FROM            
(SELECT        dbo.CONFIDENCETESTS.OBJECTID, dbo.CONFIDENCETESTS.System, 
			   CASE WHEN MaintenanceReportYear = YEAR(InspectionDate) THEN '5 Year Maintenance Complete'
			   WHEN MaintenanceReportYear > YEAR(InspectionDate) AND YEAR(InspectionDate) >= (MaintenanceReportYear  - 5) THEN '5 Year Maintenance Complete'
			   
			   WHEN (System = 'Wet Standpipe' OR System = 'Dry Standpipe') AND MaintenanceReportYear = YEAR(GETDATE()) AND YEAR(InspectionDate) >= (MaintenanceReportYear  - 5) AND MONTH(GETDATE()) < 8 THEN '5 Year Maintenance Complete'
			   WHEN (System = 'Wet Standpipe' OR System = 'Dry Standpipe') AND MaintenanceReportYear = YEAR(GETDATE()) AND YEAR(InspectionDate) >= (MaintenanceReportYear  - 5) AND MONTH(GETDATE()) = 8 THEN '5 Year Maintenance Due'
			   WHEN (System = 'Wet Standpipe' OR System = 'Dry Standpipe') AND MaintenanceReportYear = YEAR(GETDATE()) AND YEAR(InspectionDate) >= (MaintenanceReportYear  - 5) AND MONTH(GETDATE()) > 8 THEN '5 Year Maintenance Past Due'
			   
			   WHEN (System = 'Wet Sprinkler' OR System = 'Dry Sprinkler') AND MaintenanceReportYear = YEAR(GETDATE()) AND YEAR(InspectionDate) >= (MaintenanceReportYear  - 5) AND MONTH(GETDATE()) < 7 THEN '5 Year Maintenance Complete'
			   WHEN (System = 'Wet Sprinkler' OR System = 'Dry Sprinkler') AND MaintenanceReportYear = YEAR(GETDATE()) AND YEAR(InspectionDate) >= (MaintenanceReportYear  - 5) AND MONTH(GETDATE()) = 7 THEN '5 Year Maintenance Due'
			   WHEN (System = 'Wet Sprinkler' OR System = 'Dry Sprinkler') AND MaintenanceReportYear = YEAR(GETDATE()) AND YEAR(InspectionDate) >= (MaintenanceReportYear  - 5) AND MONTH(GETDATE()) > 7 THEN '5 Year Maintenance Past Due'  
			   
			   WHEN YEAR(InspectionDate) < (MaintenanceReportYear  - 5) THEN '5 Year Maintenance Past Due'  
			   WHEN InspectionDate IS NULL THEN 'No Previously Maintenance Records' END AS TestStatus, 
			   MONTH(GETDATE()) AS CurrentMonth, 
               dbo.CONFIDENCETESTS.FacNum AS FacilityNumber, 
			   dbo.CONFIDENCETESTS.FacName AS FacilityName, 
			   dbo.CONFIDENCETESTS.Location AS SystemLocation, 
			   dbo.CONFIDENCETESTS.Serves, 
			   dbo.CONFIDENCETESTS.Documents AS DocumentStorage, 
			   dbo.CONFIDENCETESTS.SystemDescription, 
			   dbo.CONFIDENCETESTS.MaintenanceReportYear,
               dbo.ViewConfidenceTestMaintenanceMostRecent.InspectionDate, 
			   dbo.ViewConfidenceTestMaintenanceMostRecent.Notes, 
			   dbo.ViewConfidenceTestMaintenanceMostRecent.UserID, 
               dbo.CONFIDENCETESTS.SHAPE
               
			   FROM dbo.CONFIDENCETESTS LEFT OUTER JOIN
                    dbo.ViewConfidenceTestMaintenanceMostRecent ON dbo.CONFIDENCETESTS.GlobalID = dbo.ViewConfidenceTestMaintenanceMostRecent.REL_GlobalID
               WHERE (dbo.CONFIDENCETESTS.FeatureStatus = N'Active' AND dbo.CONFIDENCETESTS.MaintenanceReportYear IS NOT NULL AND
			   (dbo.CONFIDENCETESTS.System = 'Dry Sprinkler' OR dbo.CONFIDENCETESTS.System = 'Dry Standpipe' OR dbo.CONFIDENCETESTS.System = 'Wet Sprinkler' OR dbo.CONFIDENCETESTS.System = 'Wet Standpipe'))) AS innertable
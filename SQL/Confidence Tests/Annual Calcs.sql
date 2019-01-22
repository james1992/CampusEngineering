SELECT        OBJECTID, 
			System, 
			TestStatus, 
			CurrentMonth, 
			FacilityNumber, 
			FacilityName, 
			SystemLocation, 
			Serves, 
			MonthDue, 
			DocumentStorage, 
			SystemDescription, 
			QuarterInspected, 
			InspectionDate, 
			Notes, 
			UserID, 
			SHAPE, 
            CASE WHEN TestStatus = 'Confidence Test Complete' THEN 1 ELSE 0 END AS TestComplete
FROM            
			(SELECT        dbo.CONFIDENCETESTS.OBJECTID, dbo.CONFIDENCETESTS.System, 
            CASE WHEN InspectionResult = 'Yellow (Maintenance Required)' THEN 'Maintenance Required' 
			WHEN InspectionResult = 'Red (System Not Operational)' THEN 'Maintenance Required' 
			WHEN YEAR(GETDATE()) - YEAR(InspectionDate) = 0 THEN 'Confidence Test Complete' 
			WHEN MONTH(GETDATE()) = MonthDue THEN 'Confidence Test Due' 
			WHEN MONTH(GETDATE()) > MonthDue AND YEAR(GETDATE()) - YEAR(InspectionDate) = 1 THEN 'Confidence Past Due' 
			WHEN MONTH(GETDATE()) < MonthDue AND YEAR(GETDATE()) - YEAR(InspectionDate) = 1 THEN 'Confidence Test Complete' 
			WHEN YEAR(GETDATE()) - YEAR(InspectionDate) > 1 THEN 'Confidence Past Due' 
			WHEN InspectionDate IS NULL THEN 'No Previously Recorded Tests' 
			END AS TestStatus, 
			MONTH(GETDATE()) AS CurrentMonth, 
            dbo.CONFIDENCETESTS.FacNum AS FacilityNumber, 
			dbo.CONFIDENCETESTS.FacName AS FacilityName, 
			dbo.CONFIDENCETESTS.Location AS SystemLocation, 
			dbo.CONFIDENCETESTS.Serves, 
            dbo.CONFIDENCETESTS.MonthDue, 
			dbo.CONFIDENCETESTS.Documents AS DocumentStorage, 
			dbo.CONFIDENCETESTS.SystemDescription, 
			dbo.CONFIDENCETESTS.Quarter AS QuarterInspected, 
            dbo.ViewConfidenceTestInspectionsMostRecent.InspectionDate, 
			dbo.ViewConfidenceTestInspectionsMostRecent.Notes, 
			dbo.ViewConfidenceTestInspectionsMostRecent.UserID, 
            dbo.CONFIDENCETESTS.SHAPE
            FROM  dbo.CONFIDENCETESTS LEFT OUTER JOIN
                        dbo.ViewConfidenceTestInspectionsMostRecent ON dbo.CONFIDENCETESTS.GlobalID = dbo.ViewConfidenceTestInspectionsMostRecent.REL_GlobalID
                          WHERE        (dbo.CONFIDENCETESTS.FeatureStatus = N'Active') AND (dbo.CONFIDENCETESTS.System <> N'Wet Standpipe') AND (dbo.CONFIDENCETESTS.System <> N'Dry Standpipe')) AS innerTable
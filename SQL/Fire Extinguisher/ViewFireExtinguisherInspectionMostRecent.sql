SELECT			LocationBarCode, 
				MaintenanceType, 
				MaintenanceDate, 

				CASE WHEN Year(MaintenanceDate) = Year(GetDAte()) THEN 'TestComplete' 
				WHEN Year(MaintenanceDate) + 1 = Year(GetDate()) AND Month(MaintenanceDate) > Month(GetDate()) THEN 'TestComplete' 
				WHEN Year(MaintenanceDate) + 1 = Year(GetDate()) AND Month(MaintenanceDate) = Month(GetDate()) THEN 'TestDue' 
				ELSE 'Past Due' END AS MaintenanceStatus, 

				CASE WHEN Year(MaintenanceDate) = Year(GetDAte()) THEN 1 
				WHEN Year(MaintenanceDate) + 1 = Year(GetDate()) AND Month(MaintenanceDate) > Month(GetDate()) THEN 1 
				ELSE 0 END AS MaintenanceCount

FROM            dbo.FireExtinguishersInspections
WHERE        (ID IN
                    (SELECT    MAX(ID) AS ID
                               FROM dbo.FireExtinguishersInspections AS subquery
                               GROUP BY LocationBarCode))
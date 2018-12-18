UPDATE dbo.CONFIDENCETESTS
SET MaintenanceReportYear = YEAR(GETDATE())
WHERE MaintenanceReportYear = '2013'
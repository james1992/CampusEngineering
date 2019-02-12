UPDATE dbo.CONFIDENCETESTS
SET MaintenanceReportYear = MaintenanceReportYear + 5
WHERE MaintenanceReportYear = (YEAR(GETDATE()) - 1)
Use FacilitiesMaintenance
GO

SELECT        REL_GLOBALID, Notes
FROM          dbo.GROUNDSCATCHBASINSINSPECTIONFORM
WHERE (OBJECTID IN (SELECT MAX(OBJECTID) AS OBJECTID
					FROM dbo.GROUNDSCATCHBASINSINSPECTIONFORM AS subquery
					GROUP BY REL_GLOBALID))
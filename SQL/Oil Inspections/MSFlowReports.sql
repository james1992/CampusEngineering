-- =============================================
-- Author:		Yurika Harada
-- Create date: 2/19/2019
-- Description:	This TSQL is designed to create a view
-- for the Oil Inspection GIS that will be updated daily.
-- The view is used for MS Flow to send Joe daily updates
-- on any sites that need attention.
-- =============================================

-- Define the working database
USE [EngineeringServices]
GO

-- create a view with these attributes
CREATE VIEW [dbo].[ViewOilInspectionsMSFlowDailyReport]
AS
SELECT  dbo.ENVIRONMENTALOILSPILLPREVENTIONINSPECTIONS.SiteID AS SiteID, dbo.ENVIRONMENTALOILSPILLPREVENTION.Type AS SiteType, 
dbo.ENVIRONMENTALOILSPILLPREVENTIONINSPECTIONS.NeedsAttention, dbo.ENVIRONMENTALOILSPILLPREVENTION.Content, 
dbo.ENVIRONMENTALOILSPILLPREVENTION.Description AS SiteDescription, dbo.ENVIRONMENTALOILSPILLPREVENTION.Capacity AS Capacity, 
dbo.ENVIRONMENTALOILSPILLPREVENTIONINSPECTIONS.Notes,dbo.ENVIRONMENTALOILSPILLPREVENTIONINSPECTIONS.created_date, 
dbo.ENVIRONMENTALOILSPILLPREVENTIONINSPECTIONS.UserID

--join the two tables together by the SiteID
FROM ENVIRONMENTALOILSPILLPREVENTIONINSPECTIONS
LEFT JOIN dbo.ENVIRONMENTALOILSPILLPREVENTION
ON dbo.ENVIRONMENTALOILSPILLPREVENTION.SiteID = ENVIRONMENTALOILSPILLPREVENTIONINSPECTIONS.SiteID


-- only show the ones where the date is today and that need attention
WHERE convert(varchar, getdate(), 1) = convert(varchar,dbo.ENVIRONMENTALOILSPILLPREVENTIONINSPECTIONS.created_date, 1) AND
dbo.ENVIRONMENTALOILSPILLPREVENTIONINSPECTIONS.NeedsAttention='Yes'
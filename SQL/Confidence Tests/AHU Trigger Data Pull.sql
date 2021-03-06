-- =============================================
-- Author:		Jay Dahlstrom
-- Create date: 10/16/2019
-- Description:	This TSQL is designed to be run through
-- a trigger following a data insert to pull the current
-- AHU data from the FA Database for use by field crews in
-- the GIS web map.
-- =============================================

USE [CampusEngineeringOperations]
GO
/****** Object:  Trigger [dbo].[AirHandlingUnitsDataPull]    Script Date: 10/16/2019 1:16:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [dbo].[AirHandlingUnitsDataPull] 
   ON  [dbo].[AIRHANDLINGUNITS]
   AFTER INSERT, UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	UPDATE dbo.AirHandlingUnits
	SET FanName = FA_FanInformation.FanName,
		FanType = FA_FanInformation.FanType,
		DeviceNumber = FA_FanInformation.DeviceNumber,
		Location = FA_FanInformation.Location,
		AreasServed = FA_FanInformation.Serves,
		CFM = FA_FanInformation.CFM,
		HP = FA_FanInformation.HP,
		EmergencyPower = FA_FanInformation.EmergencyPower,
		VFD = FA_FanInformation.VFD,
		MotorControlLocation = FA_FanInformation.MotorControlLocation,
		FanStatus = FA_FanInformation.FanStatus
	FROM FA_FanInformation INNER JOIN
			Inserted ON FA_FanInformation.FanID = inserted.FanID
	WHERE dbo.AirHandlingUnits.FanID = inserted.FanID
END

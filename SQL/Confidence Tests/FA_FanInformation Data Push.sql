-- =============================================
-- Author:		Jay Dahlstrom
-- Create date: 10/16/2019
-- Description:	This TSQL is designed to be run through
-- a trigger following a data insert or update to push the
-- updated fan data to Air Handling Units feature class for
-- use by the field crews in the GIS web map.
-- =============================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [dbo].[FanInformationDataPush] 
   ON  [dbo].[FA_FanInformation] 
   AFTER INSERT, UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	UPDATE dbo.AirHandlingUnits
	SET FanName = i.FanName,
		FanType = i.FanType,
		DeviceNumber = i.DeviceNumber,
		Location = i.Location,
		AreasServed = i.Serves,
		CFM = i.CFM,
		HP = i.HP,
		EmergencyPower = i.EmergencyPower,
		VFD = i.VFD,
		MotorControlLocation = i.MotorControlLocation,
		FanStatus = i.FanStatus
	FROM inserted i
	WHERE dbo.AirHandlingUnits.FanID = i.FanID
END
GO

USE [CampusEngineeringOperations]
GO
/****** Object:  Trigger [dbo].[TestSqeuence]    Script Date: 2/21/2019 4:10:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER TRIGGER [dbo].[TestSqeuence]
   ON  [dbo].[a22] 
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
     -- delcare variables
     DECLARE
     @seqId int,   -- sequence value
     @aOID int,  -- add delta table OID value
     @bOID int,  -- base table OID value
     @iOID int,  -- inserted OID value
     @iId int,   -- inserted ID value
     @newId int  -- flag for whether or not a new ID value is needed


     -- set inserted variables
     SET @iOID = (SELECT TOP(1) i.OBJECTID 
                  FROM [dbo].[a22] a, inserted i 
                  WHERE a.OBJECTID = i.OBJECTID AND a.SDE_STATE_ID = i.SDE_STATE_ID)

     SET @iId = (SELECT TOP(1) i.Sequence
                 FROM [dbo].[a22] a, inserted i 
                 WHERE a.OBJECTID = i.OBJECTID AND a.SDE_STATE_ID = i.SDE_STATE_ID)

     -- set base oid variable
     SET @bOID = (SELECT TOP(1) b.OBJECTID
                  FROM [dbo].[AIRHANDLINGUNITS] b
                  WHERE b.Sequence = @iID)
     IF @bOID IS NULL
          BEGIN
               SET @bOID = -1
          END

     -- set add delta oid variable
     SET @aOID = (SELECT TOP(1) a.OBJECTID
                  FROM [dbo].[a22] a
                  WHERE a.Sequence = @iID)
     IF @aOID IS NULL
          BEGIN
               SET @aOID = -1
          END

    -- ============================================================
    -- RUN CHECK OF INSERTED ID VALUE
    -- ============================================================

     -- set default value for new id flag
     SET @newId = 0

     -- if inserted ID value is NULL, update ID field
     IF @iId IS NULL
          BEGIN
               SET @newId = @newId + 1
          END

     -- check if inserted OID equals base OID
     IF @iOID <> @bOID AND @bOID <> -1
          BEGIN
               SET @newId = @newId + 1
          END

     -- check if inserted OID equals add delta OID
     IF @iOID <> @aOID AND @bOID <> -1
          BEGIN
               SET @newId = @newId + 1
          END

    -- ============================================================
    -- CHECK IF INSERTED ID VALUE SHOULD BE UPDATED
    -- ============================================================
    IF @newId > 0
	BEGIN
    -- Insert statements for trigger here

	SET @seqId = NEXT VALUE FOR [test].[LifeSafetyID]
	UPDATE a
	SET a.Sequence = @seqId
	FROM [dbo].[a22] a, inserted i
	WHERE a.OBJECTID = i.OBJECTID AND a.SDE_STATE_ID = i.SDE_STATE_ID
	END
END

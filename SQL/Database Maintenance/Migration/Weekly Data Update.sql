USE [msdb]
GO

/****** Object:  Job [SQL - Weekly - Updates]    Script Date: 7/11/2019 2:23:00 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 7/11/2019 2:23:00 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SQL - Weekly - Updates', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'In order to improve web map performance stored procedures were implemented to replace spatial views.  This procedure runs once a week on Friday evenings to update base tables for projects that do not receive as many updates.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'fsgis', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Tree Formula]    Script Date: 7/11/2019 2:23:00 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Tree Formula', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- =============================================
-- Author:      Jay Dahlstrom
-- Create date: 10/5/2018
-- Description: Stored Procedure that runs monthly
-- to calculate the current value of trees on campus.
-- Function is based on algorithm provided by Sara Shores.
-- =============================================

-- Set working database and truncate the tree value table to start from scratch
USE FacilitiesMaintenance
GO

-- Remove values from last initiation of the script
TRUNCATE TABLE dbo.GroundsTreeValue
GO

-- Declare the variables pulled from each row in ViewGroundsTreeValueData
DECLARE @TreeNumber AS INT;
DECLARE @DSH AS FLOAT;
DECLARE @TreeType AS NCHAR(50);
DECLARE @SpeciesRating AS INT;
DECLARE @Condition AS INT;
DECLARE @Contribution INT;
DECLARE @Placement AS INT;

-- Declare placeholder variables for intermediate/final calculations and notations
DECLARE @AppraisedTrunkIncrease AS INT;
DECLARE @TreeReplacementCost AS INT;
DECLARE @BasicTreeCost AS INT;
DECLARE @AssessedValue AS INT;
DECLARE @FinalAssessedValue AS INT;
DECLARE @ValueNotes AS NCHAR(50)

-- Declare and instantiate the cursor
DECLARE @TreeValueCursor AS CURSOR;

SET @TreeValueCursor = CURSOR FOR
SELECT TreeNumber, DSH, TreeType, SpeciesRating, ConditionNumber, Contribution, Placement
FROM ViewGroundsTreeValueData
ORDER BY TREENUMBER

OPEN @TreeValueCursor

FETCH NEXT FROM @TreeValueCursor INTO @TreeNumber, @DSH, @TreeType, @SpeciesRating, @Condition, @Contribution, @Placement;

WHILE @@FETCH_STATUS = 0
BEGIN
	-- Reset all placeholder values to remove residue from previous iteration
	BEGIN
		SET @AppraisedTrunkIncrease = NULL
		SET @TreeReplacementCost = NULL
		SET @BasicTreeCost = NULL
		SET @AssessedValue = NULL
		SET @FinalAssessedValue = NULL
		SET @ValueNotes = NULL
	END
	-- Handle NULL Values that would cause the calculations to fail. If a row contains a NULL value update the notes and skip the calculations
	IF @DSH IS NULL OR @TreeType IS NULL OR @SpeciesRating IS NULL OR @Condition IS NULL OR @Contribution IS NULL OR @Placement IS NULL
		BEGIN
			SET @ValueNotes = ''More Information Required for Value''
		END
	ELSE
		-- Wrap the entire nested ELSE statment so it all runs as one
		BEGIN
			-- If the DSH is over 30" run one appraised trunk increase calculation and round to nearest int.  If under 30" run a different appraisal
			IF @DSH > 30
				SET @AppraisedTrunkIncrease = ROUND(((((@DSH * @DSH) * -.335) + (@DSH * 69.3) - 1087) - 7),0)
			ELSE
				SET @AppraisedTrunkIncrease = ROUND((((@DSH * @DSH) * .785) - 7),0)
		
			-- Calculate basic tree cost.  Cost is different depending on tree type
			IF @TreeType = ''Broadleaf Evergreen'' OR @TreeType = ''Deciduous'' OR @TreeType = ''Evergreen'' OR @TreeType = ''Palm''
				BEGIN
					SET @TreeReplacementCost = 480
					SET @BasicTreeCost = (@AppraisedTrunkIncrease * 72) + @TreeReplacementCost
				END
			ELSE
				BEGIN
					SET @TreeReplacementCost = 380;
					SET @BasicTreeCost = (@AppraisedTrunkIncrease * 57) + @TreeReplacementCost
				END

			-- Set the assessed value by multiplying basic tree cost by tree and species specific values.  Round to nearest int  
			SET @AssessedValue = ROUND((@BasicTreeCost * (@SpeciesRating * .01) * (@Condition*.01) * (((85 + @Contribution + @Placement)/3)* .01)), 0) -- the 85 is for standard site rating

			-- If the Assessed Value is less than $5000 round to nearest 10 otherwise round to nearest 100
			IF @AssessedValue < 5000
				SET @FinalAssessedValue = ROUND(@AssessedValue, -1)
			ELSE
				SET @FinalAssessedValue = ROUND(@AssessedValue, -2)

			-- If the Assessed value is less than replacement cost, use  the replacement cost
			IF @FinalAssessedValue < @TreeReplacementCost
				SET @FinalAssessedValue = @TreeReplacementCost
		END
	-- Insert the Final Assessed Values into GroundsTreeValue table.  This table is accessed by the Public Trees Map (after migration to Public database via Python script)
	INSERT INTO dbo.GroundsTreeValue (TreeNumber, TreeValue, Notes)
	VALUES (@TreeNumber, @FinalAssessedValue, @ValueNotes)

	-- Console Log the insert values for error checking if needed
	/*
	PRINT cast(@TreeNumber AS NCHAR(50)) 
	PRINT cast(@FinalAssessedValue AS NCHAR(50))
	PRINT @ValueNotes
	*/
	FETCH NEXT FsROM @TreeValueCursor INTO @TreeNumber, @DSH, @TreeType, @SpeciesRating, @Condition, @Contribution, @Placement;
END

-- End the cursor
CLOSE @TreeValueCursor
DEALLOCATE @TreeValueCursor', 
		@database_name=N'FacilitiesMaintenance', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Weekly - Friday', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=32, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20190211, 
		@active_end_date=99991231, 
		@active_start_time=200000, 
		@active_end_time=235959, 
		@schedule_uid=N'd442000b-bd7d-43ca-9186-7bad848cd032'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO



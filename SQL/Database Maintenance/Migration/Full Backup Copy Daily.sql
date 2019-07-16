USE [msdb]
GO

/****** Object:  Job [Backup - Daily - Full Copy]    Script Date: 7/11/2019 2:10:55 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 7/11/2019 2:10:55 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Backup - Daily - Full Copy', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'fsgis', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [BaseComponents]    Script Date: 7/11/2019 2:10:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'BaseComponents', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N''Y:\SQL\BaseComponents_'' + CONVERT(varchar(500),GetDate(),102) + ''.bak'')

BACKUP DATABASE [BaseComponents] TO  DISK = @MyFileName WITH  COPY_ONLY, DESCRIPTION = N''Full backup to Backup Files Network Drive of Base Components'', NOFORMAT, NOINIT, COMPRESSION,  NAME = N''BaseComponents-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO

DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N''Y:\SQL\BaseComponents_'' + CONVERT(varchar(500),GetDate(),102) + ''.bak'')

declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''BaseComponents'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''BaseComponents'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''BaseComponents'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = @MyFileName WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'BaseComponents', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [CampusEngineeringOperations]    Script Date: 7/11/2019 2:10:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'CampusEngineeringOperations', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N''Y:\SQL\CampusEngineeringOperations_'' + CONVERT(varchar(500),GetDate(),102) + ''.bak'')

BACKUP DATABASE [CampusEngineeringOperations] TO  DISK = @MyFileName WITH  COPY_ONLY,  DESCRIPTION = N''Full backup to Backup Files Network Drive of Campus Engineering & Operations'', NOFORMAT, INIT, COMPRESSION,  NAME = N''CampusEngineeringOperations-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO

DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N''Y:\SQL\CampusEngineeringOperations_'' + CONVERT(varchar(500),GetDate(),102) + ''.bak'')

declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''CampusEngineeringOperations'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''CampusEngineeringOperations'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''CampusEngineeringOperations'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = @MyFileName WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'CampusEngineeringOperations', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EngineeringServices]    Script Date: 7/11/2019 2:10:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EngineeringServices', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N''Y:\SQL\EngineeringServices_'' + CONVERT(varchar(500),GetDate(),102) + ''.bak'')

BACKUP DATABASE [EngineeringServices] TO  DISK = @MyFileName WITH  COPY_ONLY,  DESCRIPTION = N''Full backup to Backup Files Network Drive of Engineering Services'', NOFORMAT, INIT, COMPRESSION,  NAME = N''EngineeringServices-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO

DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N''Y:\SQL\EngineeringServices_'' + CONVERT(varchar(500),GetDate(),102) + ''.bak'')

declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''EngineeringServices'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''EngineeringServices'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''EngineeringServices'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = @MyFileName WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'EngineeringServices', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [FacilitiesMaintenance]    Script Date: 7/11/2019 2:10:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'FacilitiesMaintenance', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N''Y:\SQL\FacilitiesMaintenance_'' + CONVERT(varchar(500),GetDate(),102) + ''.bak'')

BACKUP DATABASE [FacilitiesMaintenance] TO  DISK = @MyFileName WITH  COPY_ONLY, DESCRIPTION = N''Full backup to Backup Files Network Drive of Facilities Maintenance'', NOFORMAT, INIT, COMPRESSION,  NAME = N''FacilitiesMaintenance-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO

DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N''Y:\SQL\FacilitiesMaintenance_'' + CONVERT(varchar(500),GetDate(),102) + ''.bak'')

declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''FacilitiesMaintenance'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''FacilitiesMaintenance'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''FacilitiesMaintenance'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = @MyFileName WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'FacilitiesMaintenance', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [FacilitiesServices]    Script Date: 7/11/2019 2:10:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'FacilitiesServices', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N''Y:\SQL\FacilitiesServices_'' + CONVERT(varchar(500),GetDate(),102) + ''.bak'')

BACKUP DATABASE [FacilitiesServices] TO  DISK = @MyFileName WITH  COPY_ONLY, DESCRIPTION = N''Full backup to Backup Files Network Drive of Facilities Services'', NOFORMAT, INIT, COMPRESSION,  NAME = N''FacilitiesServices-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO

DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N''Y:\SQL\FacilitiesServices_'' + CONVERT(varchar(500),GetDate(),102) + ''.bak'')

declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''FacilitiesServices'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''FacilitiesServices'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''FacilitiesServices'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = @MyFileName WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'FacilitiesServices', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [TransportationServices]    Script Date: 7/11/2019 2:10:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'TransportationServices', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N''Y:\SQL\TransportationServices_'' + CONVERT(varchar(500),GetDate(),102) + ''.bak'')

BACKUP DATABASE [TransportationServices] TO  DISK = @MyFileName WITH  COPY_ONLY, DESCRIPTION = N''Full backup to Backup Files Network Drive of Transportation Services'', NOFORMAT, INIT, COMPRESSION,  NAME = N''TransportationServices-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO

DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N''Y:\SQL\TransportationServices_'' + CONVERT(varchar(500),GetDate(),102) + ''.bak'')

declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''TransportationServices'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''TransportationServices'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''TransportationServices'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = @MyFileName WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'TransportationServices', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [PublicData]    Script Date: 7/11/2019 2:10:55 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'PublicData', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N''Y:\SQL\PublicData_'' + CONVERT(varchar(500),GetDate(),102) + ''.bak'')

BACKUP DATABASE [PublicData] TO  DISK = @MyFileName WITH  COPY_ONLY, DESCRIPTION = N''Full backup to Backup Files Network Drive of Public Data'', NOFORMAT, INIT, COMPRESSION,  NAME = N''PublicData-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO

DECLARE @MyFileName varchar(1000)
SELECT @MyFileName = (SELECT N''Y:\SQL\PublicData_'' + CONVERT(varchar(500),GetDate(),102) + ''.bak'')

declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''PublicData'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''PublicData'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''PublicData'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = @MyFileName WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'PublicData', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily-DatabaseCopy', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=62, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=16, 
		@freq_recurrence_factor=1, 
		@active_start_date=20181016, 
		@active_end_date=99991231, 
		@active_start_time=220000, 
		@active_end_time=235959, 
		@schedule_uid=N'4dacae00-ff25-4687-9fc9-d73a09ac4794'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO



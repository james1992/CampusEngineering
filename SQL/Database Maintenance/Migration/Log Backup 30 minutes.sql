USE [msdb]
GO

/****** Object:  Job [Backup - 30 min - Log]    Script Date: 7/11/2019 2:21:41 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 7/11/2019 2:21:41 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Backup - 30 min - Log', 
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
/****** Object:  Step [Base Components]    Script Date: 7/11/2019 2:21:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Base Components', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP LOG [BaseComponents] TO  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\BaseComponents.bak'' WITH  DESCRIPTION = N''Transaction log backup of Base Components to Local Disk.'', NOFORMAT, NOINIT,  NAME = N''BaseComponents-Transcation Log'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''BaseComponents'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''BaseComponents'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''BaseComponents'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\BaseComponents.bak'' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'BaseComponents', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Campus Engineering and Operations]    Script Date: 7/11/2019 2:21:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Campus Engineering and Operations', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP LOG [CampusEngineeringOperations] TO  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\CampusEngineeringOperations.bak'' WITH  DESCRIPTION = N''Transaction log backup of Campus Engineering & Operations to Local Disk.'', NOFORMAT, NOINIT,  NAME = N''CampusEngineeringOperations-Transcation Log'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''CampusEngineeringOperations'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''CampusEngineeringOperations'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''CampusEngineeringOperations'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\CampusEngineeringOperations.bak'' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'CampusEngineeringOperations', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Engineering Services]    Script Date: 7/11/2019 2:21:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Engineering Services', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP LOG [EngineeringServices] TO  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\EngineeringServices.bak'' WITH  DESCRIPTION = N''Transaction log backup of Engineering Services to Local Disk.'', NOFORMAT, NOINIT,  NAME = N''EngineeringServices-Transcation Log'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''EngineeringServices'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''EngineeringServices'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''EngineeringServices'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\EngineeringServices.bak'' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'EngineeringServices', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Facilities Maintenance]    Script Date: 7/11/2019 2:21:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Facilities Maintenance', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP LOG [FacilitiesMaintenance] TO  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\FacilitiesMaintenance.bak'' WITH  DESCRIPTION = N''Transaction log backup of Facilities Maintenance to Local Disk.'', NOFORMAT, NOINIT,  NAME = N''FacilitiesMaintenance-Transcation Log'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''FacilitiesMaintenance'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''FacilitiesMaintenance'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''FacilitiesMaintenance'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\FacilitiesMaintenance.bak'' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'FacilitiesMaintenance', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Facilities Services]    Script Date: 7/11/2019 2:21:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Facilities Services', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP LOG [FacilitiesServices] TO  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\FacilitiesServices.bak'' WITH  DESCRIPTION = N''Transaction log backup of Facilities Services to Local Disk.'', NOFORMAT, NOINIT,  NAME = N''FacilitiesServices-Transcation Log'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''FacilitiesServices'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''FacilitiesServices'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''FacilitiesServices'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\FacilitiesServices.bak'' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'FacilitiesServices', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Transportation Services]    Script Date: 7/11/2019 2:21:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Transportation Services', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP LOG [TransportationServices] TO  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\TransportationServices.bak'' WITH  DESCRIPTION = N''Transaction log backup of Transportation Services to Local Disk.'', NOFORMAT, NOINIT,  NAME = N''TransportationServices-Transcation Log'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''TransportationServices'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''TransportationServices'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''TransportationServices'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\TransportationServices.bak'' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'TransportationServices', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'30 Minutes', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=62, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180215, 
		@active_end_date=99991231, 
		@active_start_time=70000, 
		@active_end_time=170000, 
		@schedule_uid=N'15314444-e15c-4e25-a7b1-081df184f585'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO



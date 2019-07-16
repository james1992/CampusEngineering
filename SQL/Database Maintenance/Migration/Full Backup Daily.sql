USE [msdb]
GO

/****** Object:  Job [Backup - Daily - Full]    Script Date: 7/11/2019 2:10:30 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 7/11/2019 2:10:30 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Backup - Daily - Full', 
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
/****** Object:  Step [Bace Components]    Script Date: 7/11/2019 2:10:31 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Bace Components', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP DATABASE [BaseComponents] TO  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\BaseComponents.bak'' WITH  DESCRIPTION = N''Full backup to Local Disk of Base Components'',  RETAINDAYS = 7, NOFORMAT, INIT,  NAME = N''BaseComponents-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''BaseComponents'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''BaseComponents'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''BaseComponents'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\BaseComponents.bak'' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'BaseComponents', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [CampusEngineeringOperations]    Script Date: 7/11/2019 2:10:31 PM ******/
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
		@command=N'BACKUP DATABASE [CampusEngineeringOperations] TO  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\CampusEngineeringOperations.bak'' WITH  DESCRIPTION = N''Full backup to Local Disk of Campus Engineering & Operations'',  RETAINDAYS = 7, NOFORMAT, INIT,  NAME = N''CampusEngineeringOperations-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''CampusEngineeringOperations'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''CampusEngineeringOperations'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''CampusEngineeringOperations'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\CampusEngineeringOperations.bak'' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'CampusEngineeringOperations', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Engineering Services]    Script Date: 7/11/2019 2:10:31 PM ******/
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
		@command=N'BACKUP DATABASE [EngineeringServices] TO  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\EngineeringServices.bak'' WITH  DESCRIPTION = N''Full backup to Local Disk of Engineering Services'',  RETAINDAYS = 7, NOFORMAT, INIT,  NAME = N''EngineeringServices-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''EngineeringServices'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''EngineeringServices'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''EngineeringServices'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\EngineeringServices.bak'' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'EngineeringServices', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Facilities Maintenance]    Script Date: 7/11/2019 2:10:31 PM ******/
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
		@command=N'BACKUP DATABASE [FacilitiesMaintenance] TO  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\FacilitiesMaintenance.bak'' WITH  DESCRIPTION = N''Full backup to Local Disk of Facilities Maintenance'',  RETAINDAYS = 7, NOFORMAT, INIT,  NAME = N''FacilitiesMaintenance-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''FacilitiesMaintenance'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''FacilitiesMaintenance'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''FacilitiesMaintenance'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\FacilitiesMaintenance.bak'' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'FacilitiesMaintenance', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Facilities Services]    Script Date: 7/11/2019 2:10:31 PM ******/
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
		@command=N'BACKUP DATABASE [FacilitiesServices] TO  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\FacilitiesServices.bak'' WITH  DESCRIPTION = N''Full backup to Local Disk of Facilities Services'',  RETAINDAYS = 7, NOFORMAT, INIT,  NAME = N''FacilitiesServices-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''FacilitiesServices'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''FacilitiesServices'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''FacilitiesServices'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\FacilitiesServices.bak'' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'FacilitiesServices', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Transportation Services]    Script Date: 7/11/2019 2:10:31 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Transportation Services', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP DATABASE [TransportationServices] TO  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\TransportationServices.bak'' WITH  DESCRIPTION = N''Full backup to Local Disk of Transportation Services'',  RETAINDAYS = 7, NOFORMAT, INIT,  NAME = N''TransportationServices-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''TransportationServices'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''TransportationServices'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''TransportationServices'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\TransportationServices.bak'' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'TransportationServices', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Public Data]    Script Date: 7/11/2019 2:10:31 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Public Data', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP DATABASE [PublicData] TO  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\PublicData.bak'' WITH  DESCRIPTION = N''Full backup to Local Disk of Public Data'',  RETAINDAYS = 7, NOFORMAT, INIT,  NAME = N''PublicData-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''PublicData'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''PublicData'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''PublicData'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\PublicData.bak'' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'PublicData', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Reports]    Script Date: 7/11/2019 2:10:31 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Reports', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP DATABASE [Reports] TO  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\Reports.bak'' WITH  DESCRIPTION = N''Full backup to Local Disk of Reports'',  RETAINDAYS = 7, NOFORMAT, INIT,  NAME = N''Reports-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''Reports'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''Reports'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''Reports'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\Reports.bak'' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'Reports', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Reports Temp DB]    Script Date: 7/11/2019 2:10:31 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Reports Temp DB', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP DATABASE [ReportsTempDB] TO  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\ReportsTempDB.bak'' WITH  DESCRIPTION = N''Full backup to Local Disk of Reports Temp DB'',  RETAINDAYS = 7, NOFORMAT, INIT,  NAME = N''ReportsTempDB-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''ReportsTempDB'' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''ReportsTempDB'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''ReportsTempDB'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\ReportsTempDB.bak'' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO', 
		@database_name=N'ReportsTempDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=62, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180215, 
		@active_end_date=99991231, 
		@active_start_time=190000, 
		@active_end_time=235959, 
		@schedule_uid=N'8f9e3727-6e60-4cad-8f59-f3e14c44b3f1'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO



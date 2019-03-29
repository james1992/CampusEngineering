BACKUP DATABASE [EngineeringServices] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\EngineeringServices.bak' WITH  DESCRIPTION = N'Full backup to Local Disk of Engineering Services',  RETAINDAYS = 7, NOFORMAT, INIT,  NAME = N'EngineeringServices-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'EngineeringServices' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'EngineeringServices' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''EngineeringServices'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\EngineeringServices.bak' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO
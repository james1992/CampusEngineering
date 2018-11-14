BACKUP DATABASE [FacilitiesServices] TO  DISK = N'C:\OneDrive\OneDrive - UW\Backups\FacilitiesServices.bak' WITH  COPY_ONLY,  DESCRIPTION = N'Full backup to Office365 of Facilities Services',  RETAINDAYS = 1, NOFORMAT, INIT,  NAME = N'FacilitiesServices-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'FacilitiesServices' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'FacilitiesServices' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''FacilitiesServices'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N'C:\OneDrive\OneDrive - UW\Backups\FacilitiesServices.bak' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO

BACKUP DATABASE [FacilitiesServices] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\FacilitiesServices.bak' WITH  DESCRIPTION = N'Full backup to Local Disk of Facilities Services',  RETAINDAYS = 7, NOFORMAT, INIT,  NAME = N'FacilitiesServices-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'FacilitiesServices' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'FacilitiesServices' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''FacilitiesServices'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\FacilitiesServices.bak' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO
